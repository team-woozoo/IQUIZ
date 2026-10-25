import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:iquiz/core/auth/auth_session.dart';
import 'package:iquiz/core/exception/custom_exception.dart';

final class AuthInterceptor extends Interceptor {
  AuthInterceptor({required this.dio, required this.tokens});

  final Dio dio;
  final AuthSession tokens;
  static const _generation = 'auth.sessionGeneration';
  static const _retried = 'auth.retried';

  static bool _isPublicRequest(RequestOptions options) =>
      options.method == 'POST' &&
      const {
        '/auth/login',
        '/auth/signup',
        '/auth/refresh',
        '/auth/logout',
      }.contains(Uri.parse(options.path).path);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final base = Uri.parse(dio.options.baseUrl);
    final target = options.uri;
    if (target.scheme != base.scheme ||
        target.host != base.host ||
        target.port != base.port ||
        target.userInfo.isNotEmpty) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: StateError('설정된 API 서버 외의 주소로 요청할 수 없습니다.'),
        ),
      );
      return;
    }
    // 토큰과 인증 요청 본문이 리디렉션으로 다른 서버에 전달되지 않도록 처리
    options.followRedirects = false;
    if (_isPublicRequest(options)) {
      handler.next(options);
      return;
    }
    final token = tokens.accessToken;
    final isOldRetry =
        options.extra[_retried] == true &&
        options.extra[_generation] != tokens.generation;
    if (token == null || isOldRetry) {
      handler.reject(
        DioException(
          requestOptions: options,
          error: const UnAuthorizedException(),
        ),
      );
      return;
    }
    options.extra[_generation] = tokens.generation;
    options.headers['Authorization'] = 'Bearer $token';
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final error = err;
    final request = error.requestOptions;
    // 같은 Dio로 재발급해도 인증 API의 실패는 다시 재발급하지 않음
    if (_isPublicRequest(request)) {
      handler.next(error);
      return;
    }
    final data = await _errorData(error);
    final dynamic code = data is Map<String, dynamic> ? data['code'] : null;
    final sameSession = request.extra[_generation] == tokens.generation;
    if (code != 'UNAUTHORIZED' || !sameSession || !tokens.hasTokens) {
      handler.next(error);
      return;
    }
    if (request.extra[_retried] == true) {
      try {
        await tokens.clear();
      } on Exception catch (failure) {
        handler.next(DioException(requestOptions: request, error: failure));
        return;
      }
      handler.next(error);
      return;
    }
    // 임의 스트림은 재생 가능 여부를 알 수 없으므로 자동으로 재전송하지 않음
    if (request.data is Stream) {
      handler.next(error);
      return;
    }
    try {
      final dynamic failedAuthorization = request.headers['Authorization'];
      if (failedAuthorization == 'Bearer ${tokens.accessToken}') {
        await tokens.refreshAccessToken();
      }
      if (request.extra[_generation] != tokens.generation ||
          request.cancelToken?.isCancelled == true) {
        handler.next(error);
        return;
      }
      final dynamic body = request.data;
      final retry = request.copyWith(
        data: body is FormData ? body.clone() : body,
        extra: {...request.extra, _retried: true},
        headers: {
          ...request.headers,
          'Authorization': 'Bearer ${tokens.accessToken}',
        },
      );
      handler.resolve(await dio.fetch<dynamic>(retry));
    } on DioException catch (failure) {
      handler.next(failure);
    } on Exception catch (failure) {
      handler.next(DioException(requestOptions: request, error: failure));
    }
  }

  /// 스트리밍 요청의 HTTP 인증 오류 본문도 JSON으로 읽어 재발급 여부를 판단
  static Future<Object?> _errorData(DioException error) async {
    final dynamic data = error.response?.data;
    if (data is! ResponseBody) return data;
    final contentType = error.response?.headers
        .value(Headers.contentTypeHeader)
        ?.split(';')
        .first
        .trim()
        .toLowerCase();
    if (contentType != 'application/json' &&
        contentType?.endsWith('+json') != true) {
      return null;
    }
    try {
      return jsonDecode(await utf8.decoder.bind(data.stream).join());
    } catch (_) {
      return null;
    }
  }
}
