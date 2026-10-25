import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iquiz/app/network/app_dio.dart';
import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/core/exception/custom_exception.dart';
import 'package:iquiz/features/auth/services/auth_token_manager.dart';
import 'package:iquiz/features/quiz/data_source/remote/quiz_remote_data_source_impl.dart';
import 'package:iquiz/features/quiz/repositories/entities/material_concept_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_summary_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/study_material_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_generation_options_entity.dart';
import 'package:iquiz/features/quiz/repositories/enums/material_concept_state.enum.dart';
import 'package:iquiz/features/quiz/repositories/quiz_repository_impl.dart';
import 'package:iquiz/features/quiz/usecases/get_my_materials_use_case.dart';
import 'package:iquiz/features/quiz/usecases/get_my_material_use_case.dart';
import 'package:iquiz/features/quiz/usecases/get_my_material_concepts_use_case.dart';
import 'package:iquiz/features/quiz/usecases/get_my_quizzes_use_case.dart';
import 'package:iquiz/features/quiz/usecases/request_weakness_quiz_generation_use_case.dart';
import 'package:iquiz/features/quiz/usecases/request_material_quiz_generation_use_case.dart';

import '../../support/auth_fakes.dart';
import '../../support/material_fakes.dart';

void main() {
  late AuthTokenManager tokens;
  late QuizRepositoryImpl repository;
  const options = QuizGenerationOptionsEntity(format: .ox, difficulty: .normal);

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

  test('자료 목록의 전체 문제 기준 정답률·미풀이 포함 오답·생성 상태를 보존한다', () async {
    AppDio.instance.httpClientAdapter = CallbackAdapter((request) {
      expect(request.method, 'GET');
      expect(request.path, '/materials');
      expect(request.headers['Authorization'], 'Bearer access-old');
      return jsonResponse(jsonEncode([materialJson()]));
    });
    final result = await GetMyMaterialsUseCase(repository)();
    final items = (result as Success<List<StudyMaterialEntity>>).value;
    final material = items.single;
    expect(material.questionCount, 10);
    expect(material.answeredCount, 2);
    expect(material.correctCount, 2);
    expect(material.wrongCount, 8);
    expect(material.accuracy, 0.2);
    expect(material.generating, isTrue);
    expect(material.createdAt, DateTime.utc(2026, 10, 14, 1));
    expect(items.clear, throwsUnsupportedError);
  });

  test('문제 없는 null 정답률과 문제가 있지만 미풀이인 0 정답률을 구분한다', () async {
    AppDio.instance.httpClientAdapter = CallbackAdapter(
      (_) => jsonResponse(
        jsonEncode([
          {
            ...materialJson(),
            'questionCount': 0,
            'answeredCount': 0,
            'correctCount': 0,
            'wrongCount': 0,
            'accuracy': null,
          },
          {
            ...materialJson(id: 2),
            'answeredCount': 0,
            'correctCount': 0,
            'wrongCount': 10,
            'accuracy': 0,
          },
        ]),
      ),
    );
    final result = await repository.getMyMaterials();
    final items = (result as Success<List<StudyMaterialEntity>>).value;
    expect(items.first.accuracy, isNull);
    expect(items.last.accuracy, 0);
    expect(items.last.wrongCount, 10);
  });

  test('자료 상세는 해당 경로를 조회하고 ID 불일치를 거부한다', () async {
    AppDio.instance.httpClientAdapter = CallbackAdapter((request) {
      expect(request.path, '/materials/1');
      return jsonResponse(jsonEncode(materialJson()));
    });
    final result = await GetMyMaterialUseCase(repository)(materialId: 1);
    expect((result as Success<StudyMaterialEntity>).value.materialId, 1);
    AppDio.instance.httpClientAdapter = CallbackAdapter(
      (_) => jsonResponse(jsonEncode(materialJson(id: 2))),
    );
    expect(
      await repository.getMyMaterial(materialId: 1),
      isA<Failure<StudyMaterialEntity>>(),
    );
  });

  test('자료 상세·개념의 404는 빈 목록으로 바꾸지 않고 MATERIAL_NOT_FOUND를 보존한다', () async {
    AppDio.instance.httpClientAdapter = CallbackAdapter(
      (_) => jsonResponse(
        jsonEncode({
          'status': 404,
          'code': 'MATERIAL_NOT_FOUND',
          'detail': '자료가 없습니다.',
        }),
        404,
      ),
    );
    final detail = await repository.getMyMaterial(materialId: 1);
    final concepts = await repository.getMyMaterialConcepts(materialId: 1);
    expect(
      (detail as Failure<StudyMaterialEntity>).error,
      isA<MaterialNotFoundException>(),
    );
    expect(
      (concepts as Failure<List<MaterialConceptEntity>>).error,
      isA<MaterialNotFoundException>(),
    );
  });

  test('개념의 서버 순서·미확인 상태·비연속 페이지를 유지한다', () async {
    AppDio.instance.httpClientAdapter = CallbackAdapter((request) {
      expect(request.path, '/materials/1/concepts');
      return jsonResponse(
        jsonEncode([
          materialConceptJson(),
          {
            ...materialConceptJson(status: 'UNCHECKED'),
            'conceptId': 13,
            'answeredCount': 0,
            'correctCount': 0,
            'accuracy': 0,
          },
          {
            ...materialConceptJson(status: 'UNCHECKED'),
            'conceptId': 14,
            'questionCount': 0,
            'answeredCount': 0,
            'correctCount': 0,
            'accuracy': null,
          },
        ]),
      );
    });
    final result = await GetMyMaterialConceptsUseCase(repository)(
      materialId: 1,
    );
    final items = (result as Success<List<MaterialConceptEntity>>).value;
    expect(items.map((e) => e.conceptId), [12, 13, 14]);
    expect(items.first.status, MaterialConceptState.weak);
    expect(items[1].status, MaterialConceptState.unchecked);
    expect(items.last.accuracy, isNull);
    expect(items.first.pageNos, [3, 4, 7]);
    expect(() => items.first.pageNos.add(8), throwsUnsupportedError);
  });

  test('알 수 없는 개념 상태나 모순된 집계는 성공으로 처리하지 않는다', () async {
    AppDio.instance.httpClientAdapter = CallbackAdapter(
      (_) =>
          jsonResponse(jsonEncode([materialConceptJson(status: 'NEW_STATUS')])),
    );
    expect(
      await repository.getMyMaterialConcepts(materialId: 1),
      isA<Failure<List<MaterialConceptEntity>>>(),
    );
    for (final patch in [
      {'wrongCount': 0},
      {'answeredCount': 11},
      {'correctCount': 3},
      {'accuracy': null},
      {'accuracy': 1.1},
    ]) {
      AppDio.instance.httpClientAdapter = CallbackAdapter(
        (_) => jsonResponse(
          jsonEncode([
            {...materialJson(), ...patch},
          ]),
        ),
      );
      expect(
        await repository.getMyMaterials(),
        isA<Failure<List<StudyMaterialEntity>>>(),
      );
    }
  });

  test('퀴즈 필터를 쿼리로 전송하고 nullable 자료 ID와 빈 기록을 보존한다', () async {
    AppDio.instance.httpClientAdapter = CallbackAdapter((request) {
      expect(request.path, '/quizzes');
      if (request.queryParameters.isNotEmpty) {
        expect(request.queryParameters, {'materialId': 1});
        return jsonResponse('[]');
      }
      return jsonResponse(
        jsonEncode([
          {
            'quizId': 7,
            'materialId': null,
            'materialTitle': null,
            'format': 'OX',
            'difficulty': 'NORMAL',
            'questionCount': 5,
            'createdAt': '2026-10-24T00:00:00Z',
            'submissionCount': 0,
            'lastSubmission': null,
          },
          {
            'quizId': 8,
            'materialId': 1,
            'materialTitle': '네트워크',
            'format': 'OX',
            'difficulty': 'NORMAL',
            'questionCount': 10,
            'createdAt': '2026-10-24T00:00:00Z',
            'submissionCount': 0,
            'lastSubmission': null,
          },
        ]),
      );
    });
    final all = await GetMyQuizzesUseCase(repository)();
    all.fold(
      onSuccess: (items) {
        expect(items.first.materialId, isNull);
        expect(items.first.lastSubmission, isNull);
        expect(items.last.materialId, 1);
      },
      onFailure: (error) => fail('$error'),
    );
    final filtered = await GetMyQuizzesUseCase(repository)(materialId: 1);
    filtered.fold(
      onSuccess: (items) => expect(items, isEmpty),
      onFailure: (error) => fail('$error'),
    );
  });

  test('기존 자료 생성은 PDF 업로드 없이 해당 자료 경로와 설정만 전송한다', () async {
    final adapter = CallbackAdapter((request) {
      expect(request.method, 'POST');
      expect(request.path, '/materials/42/quizzes');
      expect(request.data, {'format': 'OX', 'difficulty': 'NORMAL'});
      return jsonResponse('{"jobId":11}', 202);
    });
    AppDio.instance.httpClientAdapter = adapter;
    final result = await RequestMaterialQuizGenerationUseCase(repository)(
      materialId: 42,
      options: options,
    );
    expect((result as Success<int>).value, 11);
    expect(adapter.requests, hasLength(1));
  });

  test('기존 자료 생성의 자료 없음·동시 생성·한도 오류와 잘못된 ID를 처리한다', () async {
    for (final (code, status, matcher) in [
      ('MATERIAL_NOT_FOUND', 404, isA<MaterialNotFoundException>()),
      ('GENERATION_IN_PROGRESS', 409, isA<GenerationInProgressException>()),
      (
        'DAILY_GENERATION_LIMIT_EXCEEDED',
        429,
        isA<DailyGenerationLimitExceededException>(),
      ),
    ]) {
      AppDio.instance.httpClientAdapter = CallbackAdapter(
        (_) => jsonResponse(
          jsonEncode({'status': status, 'code': code, 'detail': '서버 안내'}),
          status,
        ),
      );
      final result = await RequestMaterialQuizGenerationUseCase(repository)(
        materialId: 42,
        options: options,
      );
      expect((result as Failure<int>).error, matcher);
    }
    final adapter = CallbackAdapter((_) => throw StateError('요청하면 안 됩니다.'));
    AppDio.instance.httpClientAdapter = adapter;
    expect(
      await RequestMaterialQuizGenerationUseCase(repository)(
        materialId: 0,
        options: options,
      ),
      isA<Failure<int>>(),
    );
    expect(adapter.requests, isEmpty);
  });

  test('약점 생성 옵션을 전송하고 반환된 jobId로 기존 SSE 흐름을 사용한다', () async {
    AppDio.instance.httpClientAdapter = CallbackAdapter((request) {
      if (request.method == 'POST') {
        expect(request.path, '/concepts/12/quizzes');
        expect(request.data, {'format': 'OX', 'difficulty': 'NORMAL'});
        return jsonResponse('{"jobId":11}', 202);
      }
      expect(request.path, '/jobs/11/events');
      return ResponseBody.fromString(
        'data: {"jobId":11,"status":"DONE","quizId":9,"errorCode":null}\n\n',
        200,
        headers: {
          Headers.contentTypeHeader: ['text/event-stream'],
        },
      );
    });
    final result = await RequestWeaknessQuizGenerationUseCase(repository)(
      conceptId: 12,
      options: options,
    );
    final jobId = (result as Success<int>).value;
    final events = await repository.watchGenerationJob(jobId: jobId).toList();
    expect(events, hasLength(1));
    events.single.fold(
      onSuccess: (job) => expect(job.quizId, 9),
      onFailure: (error) => fail('$error'),
    );
  });

  test('약점 생성의 개념 없음·동시 생성·일일 제한 오류를 구분한다', () async {
    final cases = [
      ('CONCEPT_NOT_FOUND', 404, isA<ConceptNotFoundException>()),
      ('GENERATION_IN_PROGRESS', 409, isA<GenerationInProgressException>()),
      (
        'DAILY_GENERATION_LIMIT_EXCEEDED',
        429,
        isA<DailyGenerationLimitExceededException>(),
      ),
    ];
    for (final (code, status, matcher) in cases) {
      AppDio.instance.httpClientAdapter = CallbackAdapter(
        (_) => jsonResponse(
          jsonEncode({'status': status, 'code': code, 'detail': '서버 안내'}),
          status,
        ),
      );
      final result = await RequestWeaknessQuizGenerationUseCase(repository)(
        conceptId: 12,
        options: options,
      );
      final error = (result as Failure<int>).error;
      expect(error, matcher);
      expect((error as CustomException).detail, '서버 안내');
    }
  });

  test('잘못된 자료·개념 ID는 네트워크 요청 전에 거부한다', () async {
    final adapter = CallbackAdapter((_) => throw StateError('요청하면 안 됩니다.'));
    AppDio.instance.httpClientAdapter = adapter;
    expect(
      await GetMyMaterialUseCase(repository)(materialId: 0),
      isA<Failure<StudyMaterialEntity>>(),
    );
    expect(
      await GetMyMaterialConceptsUseCase(repository)(materialId: -1),
      isA<Failure<List<MaterialConceptEntity>>>(),
    );
    final quizzes = await GetMyQuizzesUseCase(repository)(materialId: 0);
    expect(quizzes, isA<Failure<List<QuizSummaryEntity>>>());
    expect(
      await RequestWeaknessQuizGenerationUseCase(repository)(
        conceptId: 0,
        options: options,
      ),
      isA<Failure<int>>(),
    );
    expect(adapter.requests, isEmpty);
  });
}
