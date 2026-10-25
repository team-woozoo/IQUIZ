import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:iquiz/app/network/app_dio.dart';
import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/core/exception/custom_exception.dart';
import 'package:iquiz/features/auth/services/auth_token_manager.dart';
import 'package:iquiz/features/quiz/data_source/remote/quiz_remote_data_source_impl.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_submission_entity.dart';
import 'package:iquiz/features/quiz/repositories/quiz_repository_impl.dart';
import 'package:iquiz/features/quiz/usecases/get_my_quizzes_use_case.dart';
import 'package:iquiz/features/quiz/usecases/submit_quiz_use_case.dart';

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

  test('답안을 실제 questionId·optionId로 전송하고 서버 채점 결과를 변환한다', () async {
    final adapter = CallbackAdapter((request) {
      expect(request.method, 'POST');
      expect(request.path, '/quizzes/7/submissions');
      expect(request.headers['Authorization'], 'Bearer access-old');
      expect(jsonDecode(jsonEncode(request.data)), {
        'answers': [
          {'questionId': 101, 'optionId': 1002},
          {'questionId': 102, 'optionId': 2002},
        ],
      });
      return jsonResponse(jsonEncode(_submissionJson()), 201);
    });
    AppDio.instance.httpClientAdapter = adapter;
    final result = await SubmitQuizUseCase(repository)(
      quizId: 7,
      answers: testAnswers,
    );
    final submission = (result as Success<QuizSubmissionEntity>).value;
    expect(submission.submissionId, 500);
    expect(submission.correctCount, 1);
    expect(submission.correctRate, 50);
    expect(submission.results.first.correct, isFalse);
    expect(adapter.requests, hasLength(1));
  });

  test('목록의 최근 제출·미제출·자료 없는 퀴즈와 빈 목록을 보존한다', () async {
    final adapter = CallbackAdapter((request) {
      expect(request.path, '/quizzes');
      expect(request.method, 'GET');
      return jsonResponse(
        jsonEncode([
          _summaryJson(),
          {
            ..._summaryJson(),
            'quizId': 8,
            'materialTitle': null,
            'submissionCount': 0,
            'lastSubmission': null,
          },
        ]),
      );
    });
    AppDio.instance.httpClientAdapter = adapter;
    final result = await GetMyQuizzesUseCase(repository)();
    result.fold(
      onSuccess: (quizzes) {
        expect(quizzes.map((quiz) => quiz.quizId), [7, 8]);
        expect(quizzes.first.lastSubmission?.correctCount, 1);
        expect(
          quizzes.first.lastSubmission?.submittedAt,
          DateTime.utc(2026, 10, 19),
        );
        expect(quizzes.last.lastSubmission, isNull);
        expect(quizzes.last.materialTitle, isNull);
      },
      onFailure: (error) => fail(error.toString()),
    );
    AppDio.instance.httpClientAdapter = CallbackAdapter(
      (_) => jsonResponse('[]'),
    );
    final empty = await GetMyQuizzesUseCase(repository)();
    empty.fold(
      onSuccess: (quizzes) => expect(quizzes, isEmpty),
      onFailure: (error) => fail('$error'),
    );
  });

  test('INVALID_SUBMISSION의 code와 한국어 detail을 보존한다', () async {
    AppDio.instance.httpClientAdapter = CallbackAdapter(
      (_) => jsonResponse(
        '{"status":400,"code":"INVALID_SUBMISSION","detail":"다른 문제의 보기입니다."}',
        400,
      ),
    );
    final result = await SubmitQuizUseCase(repository)(
      quizId: 7,
      answers: testAnswers,
    );
    final error = (result as Failure<QuizSubmissionEntity>).error;
    expect(error, isA<InvalidSubmissionException>());
    expect((error as CustomException).detail, '다른 문제의 보기입니다.');
  });

  test('빈 답안과 중복 문제를 서버 요청 전에 거부한다', () async {
    final adapter = CallbackAdapter((_) => throw StateError('요청하면 안 됩니다.'));
    AppDio.instance.httpClientAdapter = adapter;
    final useCase = SubmitQuizUseCase(repository);
    expect(
      await useCase(quizId: 7, answers: []),
      isA<Failure<QuizSubmissionEntity>>(),
    );
    expect(
      await useCase(quizId: 7, answers: [testAnswers.first, testAnswers.first]),
      isA<Failure<QuizSubmissionEntity>>(),
    );
    expect(adapter.requests, isEmpty);
  });

  test('문제별 결과와 전체 점수가 모순되는 응답을 성공으로 처리하지 않는다', () async {
    AppDio.instance.httpClientAdapter = CallbackAdapter(
      (_) => jsonResponse(
        jsonEncode({..._submissionJson(), 'correctCount': 2}),
        201,
      ),
    );
    final result = await SubmitQuizUseCase(repository)(
      quizId: 7,
      answers: testAnswers,
    );
    expect(result, isA<Failure<QuizSubmissionEntity>>());
  });
}

Map<String, Object?> _submissionJson() => {
  'submissionId': 500,
  'correctCount': 1,
  'totalCount': 2,
  'results': [
    {'questionId': 101, 'correct': false},
    {'questionId': 102, 'correct': true},
  ],
};

Map<String, Object?> _summaryJson() => {
  'quizId': 7,
  'materialTitle': '운영체제',
  'format': 'MULTIPLE_CHOICE',
  'difficulty': 'NORMAL',
  'questionCount': 2,
  'createdAt': '2026-10-19T00:00:00Z',
  'submissionCount': 1,
  'lastSubmission': {'correctCount': 1, 'submittedAt': '2026-10-19T00:00:00Z'},
};
