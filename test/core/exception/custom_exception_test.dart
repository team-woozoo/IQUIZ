import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:iquiz/core/exception/custom_exception.dart';

void main() {
  test('입력값 검증 응답의 서버 메시지와 필드별 사유를 보존한다', () {
    final exception = _parse('''
      {
        "status": 400,
        "title": "Bad Request",
        "detail": "입력값이 올바르지 않습니다.",
        "code": "INVALID_INPUT",
        "errors": [
          {
            "field": "difficulty",
            "message": "EASY, NORMAL, HARD 중 하나여야 합니다."
          },
          {"field": "questionCount", "message": "1 이상이어야 합니다."}
        ]
      }
    ''');

    expect(exception, isA<InvalidInputException>());
    expect(exception.status, 400);
    expect(exception.detail, '입력값이 올바르지 않습니다.');
    expect(exception.message, exception.detail);
    expect(exception.errors.map((error) => error.field), [
      'difficulty',
      'questionCount',
    ]);
    expect(exception.errors.first.message, 'EASY, NORMAL, HARD 중 하나여야 합니다.');
    expect(exception.errors.clear, throwsUnsupportedError);
  });

  test('동일한 401 응답이어도 인증 코드를 구별한다', () {
    final unauthorized = _parse('''
      {"status": 401, "code": "UNAUTHORIZED", "detail": "토큰이 만료되었습니다."}
    ''');
    final credentials = _parse('''
      {"status": 401, "code": "INVALID_CREDENTIALS", "detail": "로그인 실패"}
    ''');
    final refresh = _parse('''
      {"status": 401, "code": "INVALID_REFRESH_TOKEN", "detail": "재로그인 필요"}
    ''');

    expect(unauthorized, isA<UnAuthorizedException>());
    expect(credentials, isA<InvalidCredentialException>());
    expect(refresh, isA<InvalidRefreshTokenException>());
    expect(unauthorized.detail, '토큰이 만료되었습니다.');
  });

  test('없는 자료와 퀴즈, 작업은 404 안에서도 코드로 구별한다', () {
    for (final entry in <String, Type>{
      'MATERIAL_NOT_FOUND': MaterialNotFoundException,
      'QUIZ_NOT_FOUND': QuizNotFoundException,
      'JOB_NOT_FOUND': JobNotFoundException,
    }.entries) {
      final exception = CustomException.fromJson({
        'status': 404,
        'code': entry.key,
        'detail': '찾을 수 없습니다.',
      });

      expect(exception.runtimeType, entry.value);
      expect(exception.status, 404);
    }
  });

  test('HTTP 200으로 조회된 실패 작업의 error 객체를 변환한다', () {
    final job = jsonDecode('''
      {
        "id": 7,
        "status": "FAILED",
        "quizId": null,
        "error": {
          "code": "GENERATION_FAILED",
          "detail": "퀴즈 생성에 실패했습니다. 다시 시도해 주세요."
        }
      }
    ''') as Map<String, dynamic>;
    final exception = CustomException.fromJson(
      job['error'] as Map<String, dynamic>,
    );

    expect(exception, isA<GenerationFailedException>());
    expect(exception.status, isNull);
    expect(exception.detail, '퀴즈 생성에 실패했습니다. 다시 시도해 주세요.');
    expect(exception.errors, isEmpty);

    final noQuestions = _parse('''
      {"code": "NO_VALID_QUESTIONS", "detail": "생성 가능한 문제가 없습니다."}
    ''');
    expect(noQuestions, isA<NoValidQuestionsException>());
    expect(noQuestions.status, isNull);
  });

  test('서버가 보낸 상태를 코드의 기본 상태로 덮어쓰지 않는다', () {
    final exception = _parse('''
      {
        "type": "about:blank",
        "title": "Bad Request",
        "status": 400,
        "detail": "글자를 읽을 수 없는 파일입니다.",
        "instance": "/materials",
        "code": "EXTRACTION_FAILED"
      }
    ''');

    expect(exception, isA<ExtractionFailedException>());
    expect(exception.status, 400);
    expect(exception.detail, '글자를 읽을 수 없는 파일입니다.');
  });

  test('앱에서 모르는 코드도 인증 오류로 바꾸지 않고 원문을 보존한다', () {
    final exception = _parse('''
      {"status": 503, "code": "SERVICE_UNAVAILABLE", "detail": "서버 점검 중입니다."}
    ''');

    expect(exception, isA<UnknownApiException>());
    expect(exception.code, 'SERVICE_UNAVAILABLE');
    expect(exception.detail, '서버 점검 중입니다.');
    expect(exception.status, 503);
  });
}

CustomException _parse(String source) {
  return CustomException.fromJson(jsonDecode(source) as Map<String, dynamic>);
}
