import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iquiz/app/network/auth_interceptor.dart';
import 'package:iquiz/core/helper/sse_extension.dart';
import 'package:iquiz/core/helper/stream_extenstion.dart';
import 'package:iquiz/features/auth/services/auth_token_manager.dart';
import 'package:iquiz/features/quiz/data_source/remote/models/quiz_generation_job_model.dart';

import '../../support/auth_fakes.dart';

const _sseHeaders = {
  Headers.contentTypeHeader: ['text/event-stream; charset=utf-8'],
};

void main() {
  test('UTF-8 한 글자와 이벤트가 여러 조각으로 나뉘어도 JSON을 복원한다', () async {
    final bytes = utf8.encode(
      'data: {"jobId":12,"status":"PROCESSING","message":"생성 중"}\n\n',
    );
    final events = await Stream<List<int>>.fromIterable(
      bytes.map((byte) => [byte]),
    ).decodeSseJson().toList();

    expect(events, [
      {'jobId': 12, 'status': 'PROCESSING', 'message': '생성 중'},
    ]);
  });

  test('주석과 메타데이터를 건너뛰고 여러 data 줄을 한 이벤트로 합친다', () async {
    final events = await Stream<List<int>>.value(
      utf8.encode(
        ': heartbeat\r\n\r\n'
        'id: 1\r\nevent: job\r\nretry: 1000\r\n'
        'data: {"jobId":12,\r\n'
        'data: "status":"DONE","quizId":42}\r\n\r\n',
      ),
    ).decodeSseJson().toList();

    expect(events, [
      {'jobId': 12, 'status': 'DONE', 'quizId': 42},
    ]);
  });

  test('빈 이벤트와 빈 줄로 끝나지 않은 이벤트는 전달하지 않는다', () async {
    final events = await Stream<List<int>>.value(
      utf8.encode('data:\n\ndata\n\ndata: {"jobId":12}\n'),
    ).decodeSseJson().toList();

    expect(events, isEmpty);
  });

  test('올바르지 않은 JSON은 스트림 오류로 전달한다', () async {
    final events = Stream<List<int>>.value(
      utf8.encode('data: invalid-json\n\n'),
    ).decodeSseJson();

    await expectLater(events, emitsError(isA<FormatException>()));
  });

  group('Dio SSE 연결', () {
    late Dio dio;

    setUp(() {
      dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    });
    tearDown(() => dio.close(force: true));

    test('SSE 전용 옵션으로 요청하고 기존 Stream 확장으로 모델을 변환한다', () async {
      dio.httpClientAdapter = CallbackAdapter((request) {
        expect(request.headers['Accept'], 'text/event-stream');
        expect(request.responseType, ResponseType.stream);
        expect(request.receiveTimeout, Duration.zero);
        return ResponseBody.fromString(
          'data: {"jobId":12,"status":"DONE","quizId":42}\n\n',
          200,
          headers: _sseHeaders,
        );
      });

      final jobs = await dio
          .getSseJson('/jobs/12/events')
          .withSingleConverter(fromJson: QuizGenerationJobModel.fromJson)
          .toList();

      expect(jobs.single.jobId, 12);
      expect(jobs.single.quizId, 42);
    });

    test('일반 JSON 응답을 SSE로 해석하지 않는다', () async {
      dio.httpClientAdapter = CallbackAdapter(
        (_) => jsonResponse('{"jobId":12}'),
      );

      await expectLater(
        dio.getSseJson('/jobs/12/events'),
        emitsError(isA<FormatException>()),
      );
    });

    test('응답 헤더를 기다리는 중에도 구독 취소 시 요청을 취소한다', () async {
      final requested = Completer<RequestOptions>();
      final pending = Completer<ResponseBody>();
      dio.httpClientAdapter = CallbackAdapter((request) {
        requested.complete(request);
        return pending.future;
      });

      final subscription = dio.getSseJson('/jobs/12/events').listen((_) {});
      final request = await requested.future;
      await subscription.cancel().timeout(const Duration(seconds: 2));
      expect(request.cancelToken?.isCancelled, isTrue);

      pending.complete(ResponseBody.fromString('', 200, headers: _sseHeaders));
    });

    test('이벤트를 받은 뒤 구독을 취소하면 HTTP 연결도 종료한다', () async {
      final source = StreamController<Uint8List>();
      var closed = false;
      dio.httpClientAdapter = CallbackAdapter(
        (_) => ResponseBody(
          source.stream,
          200,
          headers: _sseHeaders,
          onClose: () => closed = true,
        ),
      );

      final received = Completer<void>();
      final subscription = dio.getSseJson('/jobs/12/events').listen((_) {
        received.complete();
      });
      source.add(Uint8List.fromList(utf8.encode('data: {"jobId":12}\n\n')));
      await received.future;
      await subscription.cancel().timeout(const Duration(seconds: 2));
      expect(closed, isTrue);
      await source.close();
    });

    test('최초 SSE 요청의 UNAUTHORIZED도 토큰 재발급 후 다시 연결한다', () async {
      final tokens = AuthTokenManager(
        local: MemoryAuthStorage()..value = testTokens(),
        remote: FakeAuthRemote(),
      );
      await tokens.restore();
      addTearDown(tokens.dispose);
      dio.interceptors.add(AuthInterceptor(dio: dio, tokens: tokens));
      final adapter = CallbackAdapter((request) {
        if (request.headers['Authorization'] == 'Bearer access-old') {
          return unauthorized();
        }
        expect(request.headers['Authorization'], 'Bearer access-new');
        return ResponseBody.fromString(
          'data: {"jobId":12,"status":"DONE","quizId":42}\n\n',
          200,
          headers: _sseHeaders,
        );
      });
      dio.httpClientAdapter = adapter;

      final events = await dio.getSseJson('/jobs/12/events').toList();

      expect(events, hasLength(1));
      expect(adapter.requests, hasLength(2));
      expect(tokens.accessToken, 'access-new');
    });
  });
}
