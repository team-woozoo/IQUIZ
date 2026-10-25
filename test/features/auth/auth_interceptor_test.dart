import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iquiz/app/network/auth_interceptor.dart';
import 'package:iquiz/core/exception/custom_exception.dart';
import 'package:iquiz/features/auth/repositories/entities/jwt_entity.dart';
import 'package:iquiz/features/auth/services/auth_token_manager.dart';

import '../../support/auth_fakes.dart';

void main() {
  late MemoryAuthStorage storage;
  late FakeAuthRemote remote;
  late AuthTokenManager tokens;
  late Dio dio;

  setUp(() async {
    storage = MemoryAuthStorage()..value = testTokens();
    remote = FakeAuthRemote();
    tokens = AuthTokenManager(local: storage, remote: remote);
    await tokens.restore();
    dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    dio.interceptors.add(AuthInterceptor(dio: dio, tokens: tokens));
  });
  tearDown(() {
    dio.close(force: true);
    tokens.dispose();
  });

  test('다른 서버로 향하는 요청은 인증 본문과 토큰을 전송하기 전에 차단한다', () async {
    final adapter = CallbackAdapter((_) => jsonResponse('{}'));
    dio.httpClientAdapter = adapter;
    for (final url in [
      'https://other.test/users/me',
      'http://example.test/users/me',
      'https://example.test:8443/users/me',
      'https://user:password@example.test/users/me',
      'https://other.test/auth/login',
      'https://other.test/auth/refresh',
    ]) {
      await expectLater(
        dio.post<dynamic>(url, data: {'password': 'sensitive'}),
        throwsA(
          isA<DioException>().having((e) => e.error, '오류', isA<StateError>()),
        ),
      );
    }
    expect(adapter.requests, isEmpty);
    expect(remote.refreshCount, 0);
  });

  test('같은 서버의 절대 주소를 허용하고 요청별 리디렉션 설정을 차단한다', () async {
    final adapter = CallbackAdapter((request) {
      expect(request.headers['Authorization'], 'Bearer access-old');
      expect(request.followRedirects, isFalse);
      return jsonResponse('{}');
    });
    dio.httpClientAdapter = adapter;
    await dio.get<dynamic>(
      'https://example.test/users/me',
      options: Options(followRedirects: true),
    );
    expect(adapter.requests, hasLength(1));
  });

  test('동시 인증 오류 20개가 재발급 한 번을 공유하고 두 토큰을 저장한다', () async {
    final gate = Completer<JwtEntity>();
    final allSent = Completer<void>();
    remote.onRefresh = (_) => gate.future;
    var failed = 0;
    dio.httpClientAdapter = CallbackAdapter((request) {
      if (request.headers['Authorization'] == 'Bearer access-old') {
        if (++failed == 20) allSent.complete();
        return unauthorized();
      }
      expect(request.headers['Authorization'], 'Bearer access-new');
      return jsonResponse('{"ok":true}');
    });
    final requests = Future.wait(
      List.generate(20, (i) => dio.get<dynamic>('/$i')),
    );
    await allSent.future;
    await remote.refreshing.future;
    expect(remote.refreshCount, 1);
    gate.complete(testTokens('new'));
    expect((await requests).length, 20);
    expect(storage.value?.accessToken, 'access-new');
    expect(storage.value?.refreshToken, 'refresh-new');
    expect(remote.refreshCount, 1);
  });

  test('늦게 도착한 이전 토큰의 오류는 이미 갱신된 토큰으로 재시도한다', () async {
    final lateResponse = Completer<ResponseBody>();
    final lateSent = Completer<void>();
    dio.httpClientAdapter = CallbackAdapter((request) {
      if (request.headers['Authorization'] == 'Bearer access-new') {
        return jsonResponse('{}');
      }
      if (request.path == '/late') {
        lateSent.complete();
        return lateResponse.future;
      }
      return unauthorized();
    });
    final late = dio.get<dynamic>('/late');
    await lateSent.future;
    await dio.get<dynamic>('/fast');
    lateResponse.complete(unauthorized());
    await late;
    expect(remote.refreshCount, 1);
  });

  test('INVALID_REFRESH_TOKEN은 토큰을 지우고 재발급을 반복하지 않는다', () async {
    remote.onRefresh = (_) async => throw const InvalidRefreshTokenException();
    dio.httpClientAdapter = CallbackAdapter((_) => unauthorized());
    var ended = 0;
    tokens.addListener(() => ended++);
    await expectLater(
      dio.get<dynamic>('/me'),
      throwsA(
        isA<DioException>().having(
          (e) => e.error,
          '인증 오류',
          isA<InvalidRefreshTokenException>(),
        ),
      ),
    );
    expect(storage.value, isNull);
    expect(tokens.accessToken, isNull);
    expect(ended, 1);
    await expectLater(dio.get<dynamic>('/me'), throwsA(isA<DioException>()));
    expect(remote.refreshCount, 1);
  });

  test('일반 401과 INVALID_CREDENTIALS는 재발급하지 않는다', () async {
    dio.httpClientAdapter = CallbackAdapter(
      (_) =>
          jsonResponse('{"code":"INVALID_CREDENTIALS","detail":"로그인 실패"}', 401),
    );
    await expectLater(dio.get<dynamic>('/me'), throwsA(isA<DioException>()));
    expect(remote.refreshCount, 0);
    expect(tokens.hasTokens, isTrue);
  });

  test('재발급 응답 유실은 토큰을 삭제하거나 같은 Refresh 토큰을 자동 재사용하지 않는다', () async {
    remote.onRefresh = (_) async => throw DioException(
      requestOptions: RequestOptions(path: '/auth/refresh'),
      type: DioExceptionType.receiveTimeout,
    );
    dio.httpClientAdapter = CallbackAdapter((_) => unauthorized());
    for (var i = 0; i < 2; i++) {
      await expectLater(dio.get<dynamic>('/me'), throwsA(isA<DioException>()));
    }
    expect(remote.refreshCount, 1);
    expect(storage.value?.refreshToken, 'refresh-old');
    expect(tokens.hasTokens, isTrue);
  });

  test('재시도도 UNAUTHORIZED이면 한 번만 재시도하고 세션을 종료한다', () async {
    final adapter = CallbackAdapter((_) => unauthorized());
    dio.httpClientAdapter = adapter;
    await expectLater(dio.get<dynamic>('/me'), throwsA(isA<DioException>()));
    expect(adapter.requests.length, 2);
    expect(remote.refreshCount, 1);
    expect(storage.value, isNull);
  });

  test('재발급 중 로그아웃하면 늦은 응답을 저장하지 않고 최신 토큰을 서버에서 폐기한다', () async {
    final gate = Completer<JwtEntity>();
    remote.onRefresh = (_) => gate.future;
    final adapter = CallbackAdapter((_) => unauthorized());
    dio.httpClientAdapter = adapter;
    final request = expectLater(
      dio.get<dynamic>('/me'),
      throwsA(isA<DioException>()),
    );
    await remote.refreshing.future;
    final logout = tokens.signOut();
    expect(tokens.accessToken, isNull);
    gate.complete(testTokens('new'));
    await Future.wait([request, logout]);
    expect(storage.value, isNull);
    expect(storage.writes, 0);
    expect(adapter.requests.length, 1);
    expect(remote.revokedToken, 'refresh-new');
  });

  test('서버 로그아웃 실패 시에도 로컬 토큰을 삭제한다', () async {
    remote.onSignOut = (_) async => throw Exception('offline');
    await tokens.signOut();
    expect(storage.value, isNull);
    expect(tokens.hasTokens, isFalse);
    expect(remote.revokedToken, 'refresh-old');
  });

  test('로그아웃 전에 시작한 로그인 응답으로 세션을 복원하지 않는다', () async {
    final oldGeneration = tokens.generation;
    await tokens.signOut();
    await expectLater(
      tokens.saveLogin(testTokens('late'), oldGeneration),
      throwsA(isA<UnAuthorizedException>()),
    );
    expect(storage.value, isNull);
  });

  test('multipart 업로드를 복제하여 인증 재시도한다', () async {
    final adapter = CallbackAdapter(
      (request) => request.headers['Authorization'] == 'Bearer access-old'
          ? unauthorized()
          : jsonResponse('{}'),
    );
    dio.httpClientAdapter = adapter;
    final form = FormData.fromMap({
      'file': MultipartFile.fromBytes([1, 2, 3], filename: 'test.pdf'),
    });
    await dio.post<dynamic>('/materials', data: form);
    expect(adapter.requests.length, 2);
    expect(adapter.requests.last.data, isNot(same(form)));
    expect(remote.refreshCount, 1);
  });

  test('회전된 토큰 저장 실패 시 이전 Refresh 토큰을 남기지 않는다', () async {
    storage.writeError = Exception('storage unavailable');
    dio.httpClientAdapter = CallbackAdapter((_) => unauthorized());
    await expectLater(dio.get<dynamic>('/me'), throwsA(isA<DioException>()));
    expect(storage.value, isNull);
    expect(tokens.hasTokens, isFalse);
  });
}
