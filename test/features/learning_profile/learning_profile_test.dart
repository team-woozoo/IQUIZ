import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iquiz/app/di/learning_profile/learning_profile.dart';
import 'package:iquiz/app/network/app_dio.dart';
import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/core/exception/custom_exception.dart';
import 'package:iquiz/features/auth/services/auth_token_manager.dart';
import 'package:iquiz/features/learning_profile/data_source/remote/models/models.dart';
import 'package:iquiz/features/learning_profile/repositories/entities/cognitive_type_score_entity.dart';
import 'package:iquiz/features/learning_profile/repositories/entities/weak_concept_entity.dart';
import 'package:iquiz/features/learning_profile/repositories/enums/cognitive_type.enum.dart';

import '../../support/auth_fakes.dart';

void main() {
  late AuthTokenManager tokens;
  late FakeAuthRemote authRemote;
  late ProviderContainer container;

  setUp(() async {
    authRemote = FakeAuthRemote();
    tokens = AuthTokenManager(
      local: MemoryAuthStorage()..value = testTokens(),
      remote: authRemote,
    );
    await tokens.restore();
    AppDio.initialize(baseUrl: 'https://example.test', session: tokens);
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
    tokens.dispose();
  });

  test('DI 생성만으로 요청하지 않고 취약 개념 조회에 인증 헤더만 전송한다', () async {
    final adapter = CallbackAdapter((request) {
      expect(request.method, 'GET');
      expect(request.path, '/users/me/weak-concepts');
      expect(request.headers['Authorization'], 'Bearer access-old');
      expect(request.data, isNull);
      expect(request.queryParameters, isEmpty);
      return jsonResponse(
        jsonEncode([
          _weakConcept(),
          {
            ..._weakConcept(),
            'conceptId': 13,
            'materialId': 4,
            'materialTitle': '운영체제 심화',
          },
        ]),
      );
    });
    AppDio.instance.httpClientAdapter = adapter;
    final useCase = container.read(getMyWeakConceptsUseCaseProvider);
    expect(adapter.requests, isEmpty);

    final result = await useCase();
    final concepts = (result as Success<List<WeakConceptEntity>>).value;
    expect(concepts.map((concept) => concept.conceptId), [12, 13]);
    expect(concepts.map((concept) => concept.materialId), [3, 4]);
    expect(concepts.map((concept) => concept.conceptName), ['동기화', '동기화']);
    expect(concepts.first.answeredCount, 10);
    expect(concepts.first.correctAnswerCount, 3);
    expect(concepts.first.accuracy, 0.3);
    expect(concepts.clear, throwsUnsupportedError);
    expect(adapter.requests, hasLength(1));
  });

  test('취약 개념이 없으면 빈 목록을 반환한다', () async {
    AppDio.instance.httpClientAdapter = CallbackAdapter(
      (_) => jsonResponse('[]'),
    );
    final result = await container.read(getMyWeakConceptsUseCaseProvider)();
    expect((result as Success<List<WeakConceptEntity>>).value, isEmpty);
  });

  test('다섯 인지 유형과 미풀이 null·0%·데이터 부족을 구분한다', () async {
    final scores = [
      _score('REMEMBER', answered: 0, correct: 0, accuracy: null),
      _score('UNDERSTAND', answered: 2, correct: 0, accuracy: 0),
      _score('APPLY', answered: 10, correct: 8, accuracy: 0.8, enough: true),
      _score('ANALYZE', answered: 4, correct: 2, accuracy: 0.5),
      _score('EVALUATE', answered: 1, correct: 1, accuracy: 1),
    ];
    final adapter = CallbackAdapter((request) {
      expect(request.method, 'GET');
      expect(request.path, '/users/me/cognitive-type-scores');
      expect(request.headers['Authorization'], 'Bearer access-old');
      expect(request.data, isNull);
      expect(request.queryParameters, isEmpty);
      return jsonResponse(jsonEncode(scores));
    });
    AppDio.instance.httpClientAdapter = adapter;
    final result = await container.read(
      getMyCognitiveTypeScoresUseCaseProvider,
    )();
    final entities = (result as Success<List<CognitiveTypeScoreEntity>>).value;
    expect(entities.map((score) => score.cognitiveType), CognitiveType.values);
    expect(entities.first.accuracy, isNull);
    expect(entities[1].accuracy, 0.0);
    expect(entities[1].isEnoughData, isFalse);
    expect(entities[2].isEnoughData, isTrue);
    expect(entities.last.accuracy, 1.0);
    expect(entities.last.isEnoughData, isFalse);
    expect(entities.clear, throwsUnsupportedError);
  });

  test('생성된 JSON 모델이 null과 서버 필드·enum 값을 그대로 보존한다', () {
    final json = _score('REMEMBER', answered: 0, correct: 0, accuracy: null);
    expect(CognitiveTypeScoreModel.fromJson(json).toJson(), json);
    expect(WeakConceptModel.fromJson(_weakConcept()).toJson(), _weakConcept());
  });

  test('인증 오류는 기존 토큰 재발급 후 같은 GET 요청을 재시도한다', () async {
    final adapter = CallbackAdapter((request) {
      if (request.headers['Authorization'] == 'Bearer access-old') {
        return unauthorized();
      }
      expect(request.headers['Authorization'], 'Bearer access-new');
      return jsonResponse('[]');
    });
    AppDio.instance.httpClientAdapter = adapter;
    final result = await container.read(getMyWeakConceptsUseCaseProvider)();
    expect(result, isA<Success<List<WeakConceptEntity>>>());
    expect(authRemote.refreshCount, 1);
    expect(adapter.requests.map((request) => request.path), [
      '/users/me/weak-concepts',
      '/users/me/weak-concepts',
    ]);
  });

  test('비로그인 상태에서는 두 API 모두 서버 호출 없이 인증 실패로 반환한다', () async {
    await tokens.clear();
    final adapter = CallbackAdapter((_) => throw StateError('요청하면 안 됩니다.'));
    AppDio.instance.httpClientAdapter = adapter;
    final concepts = await container.read(getMyWeakConceptsUseCaseProvider)();
    final scores = await container.read(
      getMyCognitiveTypeScoresUseCaseProvider,
    )();
    expect(
      (concepts as Failure<List<WeakConceptEntity>>).error,
      isA<UnAuthorizedException>(),
    );
    expect(
      (scores as Failure<List<CognitiveTypeScoreEntity>>).error,
      isA<UnAuthorizedException>(),
    );
    expect(adapter.requests, isEmpty);
  });

  test('두 API가 서버 오류의 code·detail·status를 보존한다', () async {
    AppDio.instance.httpClientAdapter = CallbackAdapter(
      (_) => jsonResponse(
        '{"code":"INTERNAL_ERROR","detail":"분석 정보를 불러오지 못했습니다.","status":500}',
        500,
      ),
    );
    final concepts = await container.read(getMyWeakConceptsUseCaseProvider)();
    final scores = await container.read(
      getMyCognitiveTypeScoresUseCaseProvider,
    )();
    for (final error in [
      (concepts as Failure<List<WeakConceptEntity>>).error,
      (scores as Failure<List<CognitiveTypeScoreEntity>>).error,
    ]) {
      expect(error, isA<InternalErrorException>());
      expect((error as CustomException).code, 'INTERNAL_ERROR');
      expect(error.detail, '분석 정보를 불러오지 못했습니다.');
      expect(error.status, 500);
    }
  });

  for (final invalid in [
    _score('NEW_TYPE', answered: 1, correct: 1, accuracy: 1),
    _score('REMEMBER', answered: 0, correct: 0, accuracy: 0),
    _score('REMEMBER', answered: 1, correct: 0, accuracy: null),
    _score('REMEMBER', answered: 1, correct: 2, accuracy: 1),
    _score('REMEMBER', answered: 1, correct: 1, accuracy: 1.5),
  ]) {
    test('잘못된 인지 유형·집계를 성공 데이터로 전달하지 않는다: $invalid', () async {
      AppDio.instance.httpClientAdapter = CallbackAdapter(
        (_) => jsonResponse(jsonEncode([invalid])),
      );
      final result = await container.read(
        getMyCognitiveTypeScoresUseCaseProvider,
      )();
      expect(
        (result as Failure<List<CognitiveTypeScoreEntity>>).error,
        isA<FormatException>(),
      );
    });
  }
}

Map<String, Object?> _weakConcept() => {
  'conceptId': 12,
  'conceptName': '동기화',
  'materialId': 3,
  'materialTitle': '운영체제',
  'answeredCount': 10,
  'correctAnswerCount': 3,
  'accuracy': 0.3,
};

Map<String, Object?> _score(
  String type, {
  required int answered,
  required int correct,
  required num? accuracy,
  bool enough = false,
}) => {
  'cognitiveType': type,
  'answeredCount': answered,
  'correctAnswerCount': correct,
  'accuracy': accuracy,
  'isEnoughData': enough,
};
