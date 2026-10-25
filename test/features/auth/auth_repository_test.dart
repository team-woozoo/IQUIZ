import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:iquiz/app/network/app_dio.dart';
import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/core/exception/custom_exception.dart';
import 'package:iquiz/features/auth/data_source/remote/auth_remote_data_source_impl.dart';
import 'package:iquiz/features/auth/repositories/auth_repository_impl.dart';
import 'package:iquiz/features/auth/repositories/entities/user_entity.dart';
import 'package:iquiz/features/auth/services/auth_token_manager.dart';

import '../../support/auth_fakes.dart';

void main() {
  late MemoryAuthStorage local;
  late AuthTokenManager manager;
  late AuthRepositoryImpl repository;
  late Dio dio;

  setUp(() {
    local = MemoryAuthStorage();
    const remote = AuthRemoteDataSourceImpl();
    manager = AuthTokenManager(local: local, remote: remote);
    AppDio.initialize(baseUrl: 'https://example.test', session: manager);
    dio = AppDio.instance;
    repository = AuthRepositoryImpl(remote: remote, tokens: manager);
  });
  tearDown(() => manager.dispose());
  tearDownAll(() => AppDio.instance.close(force: true));

  test('회원가입 201은 ID만 반환하고 로그인 200 후 DataSource에서 내 정보를 조회한다', () async {
    dio.httpClientAdapter = CallbackAdapter((request) {
      switch (request.path) {
        case '/auth/signup':
          expect(request.headers.containsKey('Authorization'), isFalse);
          expect(request.data, {
            'email': 'test@example.com',
            'password': 'pw',
            'nickname': '퀴즈',
          });
          return jsonResponse('{"id":42}', 201);
        case '/auth/login':
          expect(request.headers.containsKey('Authorization'), isFalse);
          return jsonResponse(
            '{"accessToken":"access","refreshToken":"refresh","expiresIn":1800}',
          );
        case '/users/me':
          expect(request.headers['Authorization'], 'Bearer access');
          return jsonResponse(
            '{"id":42,"email":"test@example.com","nickname":"퀴즈"}',
          );
        default:
          fail('예상하지 않은 요청: ${request.path}');
      }
    });

    final signup = await repository.signUp(
      email: 'test@example.com',
      password: 'pw',
      nickname: '퀴즈',
    );
    expect((signup as Success<int>).value, 42);
    expect(local.value, isNull);
    final login = await repository.signIn(
      email: 'test@example.com',
      password: 'pw',
    );
    expect((login as Success<UserEntity>).value.nickname, '퀴즈');
    expect(local.value?.refreshToken, 'refresh');
    expect(local.value?.expiresAt.isUtc, isTrue);
  });

  test('이메일 중복과 필드 오류를 기존 CustomException으로 보존한다', () async {
    dio.httpClientAdapter = CallbackAdapter(
      (_) => jsonResponse(
        '{"status":409,"code":"EMAIL_ALREADY_EXISTS","detail":"이미 가입된 이메일입니다.","errors":[{"field":"email","message":"다른 이메일을 입력해 주세요."}]}',
        409,
      ),
    );
    final result = await repository.signUp(
      email: 'test@example.com',
      password: 'pw',
      nickname: '퀴즈',
    );
    final error = (result as Failure<int>).error;
    expect(error, isA<EmailAlreadyExistsException>());
    expect((error as CustomException).errors.single.field, 'email');
  });

  test('자동 로그인 중 네트워크 장애는 저장된 토큰을 지우지 않는다', () async {
    local.value = testTokens();
    dio.httpClientAdapter = CallbackAdapter(
      (request) => throw DioException(
        requestOptions: request,
        type: DioExceptionType.connectionError,
      ),
    );

    expect(await repository.restore(), isA<Failure<UserEntity?>>());
    expect(local.value?.refreshToken, 'refresh-old');
  });

  test('잘못된 내 정보 응답은 Entity로 변환하지 않고 실패로 반환한다', () async {
    local.value = testTokens();
    dio.httpClientAdapter = CallbackAdapter(
      (_) => jsonResponse(
        '{"id":"42","email":"test@example.com","nickname":"퀴즈"}',
      ),
    );

    final result = await repository.restore();

    expect((result as Failure<UserEntity?>).error, isA<FormatException>());
  });
}
