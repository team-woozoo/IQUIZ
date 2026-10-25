import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iquiz/app/di/auth/auth.dart';
import 'package:iquiz/app/di/quiz/quiz.dart';
import 'package:iquiz/app/network/app_dio.dart';
import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/core/exception/custom_exception.dart';
import 'package:iquiz/features/auth/data_source/remote/auth_remote_data_source_impl.dart';
import 'package:iquiz/features/auth/services/auth_token_manager.dart';
import 'package:iquiz/features/quiz/repositories/entities/quiz_generation_options_entity.dart';
import 'package:iquiz/features/quiz/data_source/remote/quiz_remote_data_source_impl.dart';

import '../../support/auth_fakes.dart';

void main() {
  late AuthTokenManager tokens;
  late Dio dio;
  late AuthRemoteDataSourceImpl remote;

  setUp(() {
    remote = const AuthRemoteDataSourceImpl();
    tokens = AuthTokenManager(local: MemoryAuthStorage(), remote: remote);
    AppDio.initialize(baseUrl: 'https://example.test/api', session: tokens);
    dio = AppDio.instance;
  });

  tearDown(() {
    tokens.dispose();
  });
  tearDownAll(() => AppDio.instance.close(force: true));

  test('API 주소는 유효한 HTTPS 주소만 허용한다', () {
    for (final address in [
      '',
      '/api',
      'http://example.test',
      'ftp://example.test',
      'https://user:password@example.test',
      'https://example.test?token=secret',
      'https://example.test#fragment',
    ]) {
      expect(
        () => AppDio.initialize(baseUrl: address, session: tokens),
        throwsFormatException,
        reason: address,
      );
    }
    expect(dio.options.baseUrl, 'https://example.test/api');
  });

  test('개발용 HTTP는 명시적으로 허용한 debug 실행에서만 사용한다', () {
    AppDio.initialize(
      baseUrl: 'http://localhost:8080',
      session: tokens,
      allowInsecureHttp: true,
    );
    expect(dio.options.baseUrl, 'http://localhost:8080');
  });

  test('설정 로딩 전에도 DataSource와 인증 관리자를 생성할 수 있다', () {
    final container = ProviderContainer(
      overrides: [
        authLocalDataSourceProvider.overrideWithValue(MemoryAuthStorage()),
      ],
    );
    addTearDown(container.dispose);

    expect(QuizRemoteDataSourceImpl.new, returnsNormally);
    expect(container.read(authTokenManagerProvider).hasTokens, isFalse);
  });

  test('한 Dio로 로그인, PDF 업로드, 토큰 재발급 후 업로드 재시도를 처리한다', () async {
    final adapter = CallbackAdapter((request) {
      switch (request.path) {
        case '/auth/login':
          expect(request.headers.containsKey('Authorization'), isFalse);
          return jsonResponse(
            '{"accessToken":"access-old","refreshToken":"refresh-old","expiresIn":1800}',
          );
        case '/auth/refresh':
          expect(request.headers.containsKey('Authorization'), isFalse);
          expect(request.data, {'refreshToken': 'refresh-old'});
          return jsonResponse(
            '{"accessToken":"access-new","refreshToken":"refresh-new","expiresIn":1800}',
          );
        case '/auth/logout':
          expect(request.headers.containsKey('Authorization'), isFalse);
          return jsonResponse('', 204);
        case '/materials':
          if (request.headers['Authorization'] == 'Bearer access-old') {
            return unauthorized();
          }
          expect(request.headers['Authorization'], 'Bearer access-new');
          return jsonResponse('{"materialId":7}', 201);
        case '/materials/7/quizzes':
          expect(request.headers['Authorization'], 'Bearer access-new');
          expect(request.data, {
            'format': 'MULTIPLE_CHOICE',
            'difficulty': 'HARD',
          });
          return jsonResponse('{"jobId":42}', 202);
        default:
          fail('예상하지 않은 요청: ${request.path}');
      }
    });
    dio.httpClientAdapter = adapter;
    final version = tokens.generation;
    final login = await remote.signIn(
      email: 'test@example.com',
      password: 'pw',
    );
    await tokens.saveLogin(login, version);

    final container = ProviderContainer();
    addTearDown(container.dispose);
    final result = await container.read(uploadFileUseCaseProvider)(
      fileBytes: [1, 2, 3],
      fileName: 'test.pdf',
      options: const QuizGenerationOptionsEntity(
        format: .multipleChoice,
        difficulty: .hard,
      ),
    );

    expect((result as Success<int>).value, 42);
    expect(tokens.accessToken, 'access-new');
    expect(adapter.requests.map((request) => request.path), [
      '/auth/login',
      '/materials',
      '/auth/refresh',
      '/materials',
      '/materials/7/quizzes',
    ]);

    await tokens.signOut();
    expect(adapter.requests.last.path, '/auth/logout');
    expect(adapter.requests.last.headers.containsKey('Authorization'), isFalse);
  });

  test('업로드 UseCase는 서버 파일 오류를 실패 결과로 전달한다', () async {
    await tokens.saveLogin(testTokens(), tokens.generation);
    dio.httpClientAdapter = CallbackAdapter(
      (_) => jsonResponse(
        '{"code":"FILE_TOO_LARGE","detail":"파일 크기 상한을 초과했습니다.","status":413}',
        413,
      ),
    );
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final result = await container.read(uploadFileUseCaseProvider)(
      fileBytes: [1, 2, 3],
      fileName: 'test.pdf',
      options: const QuizGenerationOptionsEntity(
        format: .multipleChoice,
        difficulty: .hard,
      ),
    );

    expect((result as Failure<int>).error, isA<FileTooLargeException>());
  });

  test('같은 Dio의 재발급 요청이 실패해도 재발급을 반복하지 않는다', () async {
    await tokens.saveLogin(testTokens(), tokens.generation);
    final adapter = CallbackAdapter((_) => unauthorized());
    dio.httpClientAdapter = adapter;

    await expectLater(
      dio.get<dynamic>('/users/me'),
      throwsA(isA<DioException>()),
    );

    expect(adapter.requests.map((request) => request.path), [
      '/users/me',
      '/auth/refresh',
    ]);
  });
}
