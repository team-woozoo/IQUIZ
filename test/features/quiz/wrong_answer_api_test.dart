import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iquiz/app/network/app_dio.dart';
import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/core/exception/custom_exception.dart';
import 'package:iquiz/features/auth/services/auth_token_manager.dart';
import 'package:iquiz/features/learning_profile/repositories/enums/cognitive_type.enum.dart';
import 'package:iquiz/features/quiz/data_source/remote/models/wrong_answer_model.dart';
import 'package:iquiz/features/quiz/data_source/remote/quiz_remote_data_source_impl.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_answer_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_submission_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/wrong_answer_entity.dart';
import 'package:iquiz/features/quiz/repositories/enums/quiz_format.enum.dart';
import 'package:iquiz/features/quiz/repositories/quiz_repository_impl.dart';
import 'package:iquiz/features/quiz/usecases/get_my_wrong_answers_use_case.dart';
import 'package:iquiz/features/quiz/usecases/submit_wrong_answer_review_use_case.dart';

import '../../support/auth_fakes.dart';
import '../../support/quiz_fakes.dart';

void main() {
  late AuthTokenManager tokens;
  late QuizRepositoryImpl repository;

  setUp(() async {
    tokens = AuthTokenManager(
      local: MemoryAuthStorage()..value = testTokens(),
      remote: FakeAuthRemote(),
    );
    await tokens.restore();
    AppDio.initialize(baseUrl: 'https://example.test', session: tokens);
    repository = const QuizRepositoryImpl(QuizRemoteDataSourceImpl());
  });
  tearDown(() => tokens.dispose());

  test('오답 조회는 인증·서버 순서·원본 자료·nullable 페이지를 유지하고 보기만 정렬한다', () async {
    AppDio.instance.httpClientAdapter = CallbackAdapter((request) {
      expect(request.method, 'GET');
      expect(request.path, '/users/me/wrong-answers');
      expect(request.queryParameters, isEmpty);
      expect(request.headers['Authorization'], 'Bearer access-old');
      return jsonResponse(
        jsonEncode([
          _wrongAnswer(),
          {
            ..._wrongAnswer(),
            'questionId': 102,
            'quizId': 8,
            'format': 'OX',
            'sourcePageNo': null,
            'wrongCount': 0,
          },
        ]),
      );
    });
    final result = await GetMyWrongAnswersUseCase(repository)();
    final items = (result as Success<List<WrongAnswerEntity>>).value;
    expect(items.map((item) => item.questionId), [101, 102]);
    expect(items.first.materialId, 11);
    expect(items.first.format, QuizFormat.multipleChoice);
    expect(items.first.cognitiveType, CognitiveType.apply);
    expect(items.first.options.map((option) => option.optionId), [1001, 1002]);
    expect(items.first.options.first.isCorrect, isTrue);
    expect(items.first.lastWrongAt, DateTime.utc(2026, 10, 24, 1));
    expect(items.last.sourcePageNo, isNull);
    expect(items.last.wrongCount, 0);
    expect(items.last.format, QuizFormat.ox);
    expect(items.clear, throwsUnsupportedError);
    expect(items.first.options.clear, throwsUnsupportedError);
  });

  test('오답 응답 모델은 enum과 nullable 페이지를 JSON 왕복 변환한다', () {
    final json = {
      ..._wrongAnswer(),
      'sourcePageNo': null,
      'lastWrongAt': '2026-10-24T01:00:00.000Z',
    };
    expect(jsonDecode(jsonEncode(WrongAnswerModel.fromJson(json))), json);
  });

  test('해결할 오답이 없으면 빈 목록을 반환한다', () async {
    AppDio.instance.httpClientAdapter = CallbackAdapter(
      (_) => jsonResponse('[]'),
    );
    final result = await repository.getMyWrongAnswers();
    expect((result as Success<List<WrongAnswerEntity>>).value, isEmpty);
  });

  test('알 수 없는 enum·잘못된 페이지·음수 횟수·잘못된 보기를 실패로 처리한다', () async {
    final invalidFields = <Map<String, Object?>>[
      {'format': 'NEW_FORMAT'},
      {'cognitiveType': 'NEW_TYPE'},
      {'sourcePageNo': 0},
      {'wrongCount': -1},
      {'options': <Object?>[]},
      {
        'options': [
          {'optionId': 1001, 'orderNo': 1, 'content': '보기', 'isCorrect': false},
        ],
      },
      {
        'options': [
          {'optionId': 1001, 'orderNo': 1, 'content': '보기', 'isCorrect': true},
          {'optionId': 1001, 'orderNo': 2, 'content': '중복', 'isCorrect': false},
        ],
      },
    ];
    for (final fields in invalidFields) {
      AppDio.instance.httpClientAdapter = CallbackAdapter(
        (_) => jsonResponse(
          jsonEncode([
            {..._wrongAnswer(), ...fields},
          ]),
        ),
      );
      final result = await repository.getMyWrongAnswers();
      expect(
        (result as Failure<List<WrongAnswerEntity>>).error,
        isA<FormatException>(),
      );
    }
  });

  test('복습은 여러 퀴즈의 답안을 전용 경로로 한 번만 제출하고 서버 결과를 반환한다', () async {
    final adapter = CallbackAdapter((request) {
      expect(request.method, 'POST');
      expect(request.path, '/users/me/wrong-answers/submissions');
      expect(request.headers['Authorization'], 'Bearer access-old');
      expect(jsonDecode(jsonEncode(request.data)), {
        'answers': [
          {'questionId': 101, 'optionId': 1002},
          {'questionId': 102, 'optionId': 2002},
        ],
      });
      return jsonResponse(jsonEncode(_submission()), 201);
    });
    AppDio.instance.httpClientAdapter = adapter;
    final result = await SubmitWrongAnswerReviewUseCase(repository)(
      answers: testAnswers,
    );
    final submission = (result as Success<QuizSubmissionEntity>).value;
    expect(submission.correctCount, 1);
    expect(submission.totalCount, 2);
    expect(submission.results.map((result) => result.correct), [false, true]);
    expect(adapter.requests, hasLength(1));
  });

  test('일부 답안만 제출할 수 있으며 응답의 다른 문제나 누락된 결과는 거부한다', () async {
    const answers = [QuizAnswerEntity(questionId: 101, optionId: 1002)];
    Map<String, Object?> response(int id) => {
      'submissionId': 500,
      'correctCount': 0,
      'totalCount': 1,
      'results': [
        {'questionId': id, 'correct': false},
      ],
    };
    AppDio.instance.httpClientAdapter = CallbackAdapter(
      (_) => jsonResponse(jsonEncode(response(101)), 201),
    );
    expect(
      await repository.submitWrongAnswerReview(answers: answers),
      isA<Success<QuizSubmissionEntity>>(),
    );
    AppDio.instance.httpClientAdapter = CallbackAdapter(
      (_) => jsonResponse(jsonEncode(response(999)), 201),
    );
    expect(
      await repository.submitWrongAnswerReview(answers: answers),
      isA<Failure<QuizSubmissionEntity>>(),
    );
    AppDio.instance.httpClientAdapter = CallbackAdapter(
      (_) => jsonResponse(
        jsonEncode({...response(101), 'results': <Object?>[]}),
        201,
      ),
    );
    expect(
      await repository.submitWrongAnswerReview(answers: answers),
      isA<Failure<QuizSubmissionEntity>>(),
    );
  });

  test('잘못된 입력은 HTTP 요청 전에 거부한다', () async {
    final adapter = CallbackAdapter((_) => throw StateError('요청하면 안 됩니다.'));
    AppDio.instance.httpClientAdapter = adapter;
    final useCase = SubmitWrongAnswerReviewUseCase(repository);
    for (final answers in <List<QuizAnswerEntity>>[
      [],
      [const QuizAnswerEntity(questionId: 0, optionId: 1)],
      [const QuizAnswerEntity(questionId: 1, optionId: -1)],
      [
        const QuizAnswerEntity(questionId: 1, optionId: 1),
        const QuizAnswerEntity(questionId: 1, optionId: 2),
      ],
    ]) {
      expect(
        await useCase(answers: answers),
        isA<Failure<QuizSubmissionEntity>>(),
      );
    }
    expect(adapter.requests, isEmpty);
  });

  test('서버 INVALID_SUBMISSION 오류 내용을 보존한다', () async {
    AppDio.instance.httpClientAdapter = CallbackAdapter(
      (_) => jsonResponse(
        jsonEncode({
          'status': 400,
          'code': 'INVALID_SUBMISSION',
          'detail': '해당 문제의 보기가 아닙니다.',
        }),
        400,
      ),
    );
    final result = await repository.submitWrongAnswerReview(
      answers: testAnswers,
    );
    final error =
        (result as Failure<QuizSubmissionEntity>).error
            as InvalidSubmissionException;
    expect(error.code, 'INVALID_SUBMISSION');
    expect(error.detail, '해당 문제의 보기가 아닙니다.');
  });

  test('로그인 정보가 없으면 조회·제출 요청을 보내지 않는다', () async {
    await tokens.clear();
    final adapter = CallbackAdapter((_) => throw StateError('요청하면 안 됩니다.'));
    AppDio.instance.httpClientAdapter = adapter;
    final get = await repository.getMyWrongAnswers();
    final submit = await repository.submitWrongAnswerReview(
      answers: testAnswers,
    );
    expect(
      (get as Failure<List<WrongAnswerEntity>>).error,
      isA<UnAuthorizedException>(),
    );
    expect(
      (submit as Failure<QuizSubmissionEntity>).error,
      isA<UnAuthorizedException>(),
    );
    expect(adapter.requests, isEmpty);
  });

  test('서버 응답 유실은 자동 재제출하지 않는다', () async {
    final adapter = CallbackAdapter(
      (request) => throw DioException(
        requestOptions: request,
        type: DioExceptionType.receiveTimeout,
      ),
    );
    AppDio.instance.httpClientAdapter = adapter;
    final result = await SubmitWrongAnswerReviewUseCase(repository)(
      answers: testAnswers,
    );
    expect(
      (result as Failure<QuizSubmissionEntity>).error,
      isA<DioException>(),
    );
    expect(adapter.requests, hasLength(1));
  });

  test('진행 중 중복 제출을 막고 성공 후 같은 문제를 다시 복습할 수 있다', () async {
    final fake = FakeQuizRepository();
    final pending = Completer<Result<QuizSubmissionEntity>>();
    fake.onSubmitWrongAnswerReview = () => pending.future;
    final useCase = SubmitWrongAnswerReviewUseCase(fake);
    final answers = [...testAnswers];
    final first = useCase(answers: answers);
    answers.clear();
    final duplicate = await useCase(answers: testAnswers);
    expect(duplicate, isA<Failure<QuizSubmissionEntity>>());
    expect(fake.wrongAnswerReviewCount, 1);
    expect(fake.reviewedAnswers, hasLength(2));
    pending.complete(Result.success(testSubmission));
    expect(await first, isA<Success<QuizSubmissionEntity>>());
    expect(
      await useCase(answers: testAnswers),
      isA<Success<QuizSubmissionEntity>>(),
    );
    expect(fake.wrongAnswerReviewCount, 2);
    expect(fake.submitCount, 0);
  });

  test('제출 실패 후에도 진행 중 상태를 해제한다', () async {
    final fake = FakeQuizRepository()
      ..onSubmitWrongAnswerReview = () async =>
          Result.failure(Exception('offline'));
    final useCase = SubmitWrongAnswerReviewUseCase(fake);
    expect(
      await useCase(answers: testAnswers),
      isA<Failure<QuizSubmissionEntity>>(),
    );
    fake.onSubmitWrongAnswerReview = null;
    expect(
      await useCase(answers: testAnswers),
      isA<Success<QuizSubmissionEntity>>(),
    );
    expect(fake.wrongAnswerReviewCount, 2);
  });
}

Map<String, Object?> _wrongAnswer() => {
  'questionId': 101,
  'quizId': 7,
  'format': 'MULTIPLE_CHOICE',
  'content': '문제',
  'cognitiveType': 'APPLY',
  'conceptName': '개념',
  'materialId': 11,
  'materialTitle': '원본 자료',
  'explanation': '해설',
  'sourceQuote': '근거',
  'sourcePageNo': 3,
  'options': [
    {'optionId': 1002, 'orderNo': 2, 'content': '오답 보기', 'isCorrect': false},
    {'optionId': 1001, 'orderNo': 1, 'content': '정답 보기', 'isCorrect': true},
  ],
  'wrongCount': 2,
  'lastWrongAt': '2026-10-24T01:00:00Z',
};

Map<String, Object?> _submission() => {
  'submissionId': 500,
  'correctCount': 1,
  'totalCount': 2,
  'results': [
    {'questionId': 101, 'correct': false},
    {'questionId': 102, 'correct': true},
  ],
};
