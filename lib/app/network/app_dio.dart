import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:iquiz/app/network/auth_interceptor.dart';
import 'package:iquiz/core/auth/auth_session.dart';

class AppDio with DioMixin implements Dio {
  static final AppDio _instance = AppDio._();

  bool _initialized = false;

  static AppDio get instance {
    if (!_instance._initialized) {
      throw StateError('앱 설정 로딩 후 네트워크를 먼저 초기화해야 합니다.');
    }
    return _instance;
  }

  /// 객체 연결은 앱 초기화 계층에서 수행하고 요청 중에는 설정을 조회하지 않음
  static void initialize({
    required String baseUrl,
    required AuthSession session,
    bool allowInsecureHttp = false,
  }) {
    final url = baseUrl.trim();
    final uri = Uri.tryParse(url);
    if (uri == null ||
        !uri.hasAuthority ||
        uri.host.isEmpty ||
        uri.userInfo.isNotEmpty ||
        uri.hasQuery ||
        uri.hasFragment ||
        (uri.scheme != 'https' &&
            !(allowInsecureHttp && kDebugMode && uri.scheme == 'http'))) {
      throw const FormatException('서버 주소는 사용자 정보·쿼리·프래그먼트가 없는 HTTPS 주소여야 합니다.');
    }

    final dio = _instance;
    dio.options.baseUrl = url;
    dio.interceptors.removeWhere(
      (interceptor) => interceptor is AuthInterceptor,
    );
    dio.interceptors.insert(0, AuthInterceptor(dio: dio, tokens: session));
    dio._initialized = true;
  }

  AppDio._() {
    httpClientAdapter = HttpClientAdapter();
    options = BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      followRedirects: false,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );
  }

  /// multipart 업로드 설정
  Future<Response<T>> postMultipart<T>(String path, {required FormData data}) =>
      post<T>(
        path,
        data: data,
        options: Options(
          contentType: Headers.multipartFormDataContentType,
          sendTimeout: const Duration(minutes: 2),
          receiveTimeout: const Duration(minutes: 2),
        ),
      );
}
