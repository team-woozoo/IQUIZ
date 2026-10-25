import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:iquiz/core/logger/log.dart';

extension DioSseExtension on Dio {
  /// JSON SSE를 구독. 설정한 횟수만큼 연결 종료·일시적인 통신 오류를 재시도
  Stream<dynamic> getSseJson(
    String path, {
    int maxReconnectAttempts = 0,
    Duration reconnectDelay = const Duration(seconds: 1),
  }) {
    if (maxReconnectAttempts < 0 || reconnectDelay.isNegative) {
      throw ArgumentError('SSE 재연결 횟수와 대기 시간은 음수일 수 없습니다.');
    }
    final cancelToken = CancelToken();
    StreamSubscription<dynamic>? subscription;
    Timer? reconnectTimer;
    var reconnectAttempts = 0;
    late final StreamController<dynamic> controller;
    late final Future<void> Function() connect;

    void finishConnection([Object? error, StackTrace? stackTrace]) {
      if (cancelToken.isCancelled || controller.isClosed) return;
      if (reconnectAttempts < maxReconnectAttempts && _canReconnect(error)) {
        final delay = reconnectDelay * (1 << reconnectAttempts);
        reconnectAttempts++;
        Log.w('SSE 연결 종료. 재구독 대기 ($reconnectAttempts/$maxReconnectAttempts)');
        reconnectTimer = Timer(delay, () => unawaited(connect()));
        return;
      }
      if (error != null) controller.addError(error, stackTrace);
      unawaited(controller.close());
    }

    connect = () async {
      if (cancelToken.isCancelled || controller.isClosed) return;
      try {
        final response = await get<ResponseBody>(
          path,
          options: Options(
            responseType: ResponseType.stream,
            receiveTimeout: Duration.zero,
            headers: {'Accept': 'text/event-stream'},
          ),
          cancelToken: cancelToken,
        );
        if (cancelToken.isCancelled || controller.isClosed) return;

        final contentType = response.headers
            .value(Headers.contentTypeHeader)
            ?.split(';')
            .first
            .trim()
            .toLowerCase();
        if (response.statusCode != 200 || contentType != 'text/event-stream') {
          throw const FormatException('SSE 응답 형식이 올바르지 않습니다.');
        }
        final body = response.data;
        if (body == null) {
          throw const FormatException('SSE 응답이 비어 있습니다.');
        }

        subscription = body.stream.decodeSseJson().listen(
          controller.add,
          onError: finishConnection,
          onDone: finishConnection,
          cancelOnError: true,
        );
        if (controller.isPaused) subscription?.pause();
      } catch (error, stackTrace) {
        finishConnection(error, stackTrace);
      }
    };

    controller = StreamController<dynamic>(
      onListen: () => unawaited(connect()),
      onPause: () => subscription?.pause(),
      onResume: () => subscription?.resume(),
      onCancel: () async {
        reconnectTimer?.cancel();
        cancelToken.cancel('SSE 구독 종료');
        try {
          await subscription?.cancel();
        } on DioException catch (error) {
          if (!CancelToken.isCancel(error)) rethrow;
        }
      },
    );
    return controller.stream;
  }
}

bool _canReconnect(Object? error) {
  if (error == null) return true;
  if (error is FormatException) return false;
  if (error is DioException) {
    return switch (error.type) {
      DioExceptionType.connectionError ||
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout => true,
      DioExceptionType.badResponse => const {
        500,
        502,
        503,
        504,
      }.contains(error.response?.statusCode),
      _ => false,
    };
  }
  // 응답 본문의 소켓 오류는 DioException 래핑 없이 전달될 수도 있음
  return error is Exception;
}

extension SseJsonStreamExtension on Stream<List<int>> {
  /// UTF-8 및 줄 경계와 무관하게 data 필드를 모아 이벤트별로 디코딩
  Stream<dynamic> decodeSseJson() async* {
    final dataLines = <String>[];
    final lines = utf8.decoder.bind(this).transform(const LineSplitter());

    await for (final line in lines) {
      if (line.isEmpty) {
        if (dataLines.isNotEmpty) {
          final data = dataLines.join('\n');
          dataLines.clear();
          if (data.isNotEmpty) yield jsonDecode(data);
        }
        continue;
      }
      if (line.startsWith(':')) continue;

      final separator = line.indexOf(':');
      final field = separator == -1 ? line : line.substring(0, separator);
      if (field != 'data') continue;

      var value = separator == -1 ? '' : line.substring(separator + 1);
      if (value.startsWith(' ')) value = value.substring(1);
      dataLines.add(value);
    }
    // 빈 줄로 끝나지 않은 미완성 이벤트는 전달하지 않음
  }
}
