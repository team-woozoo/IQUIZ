import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:iquiz/features/auth/data_source/local/auth_local_data_source.dart';
import 'package:iquiz/features/auth/data_source/remote/auth_remote_data_source.dart';
import 'package:iquiz/features/auth/data_source/remote/models/user_model.dart';
import 'package:iquiz/features/auth/repositories/entities/jwt_entity.dart';

JwtEntity testTokens([String suffix = 'old']) => JwtEntity(
  accessToken: 'access-$suffix',
  refreshToken: 'refresh-$suffix',
  expiresAt: DateTime.utc(2030),
);

class MemoryAuthStorage implements AuthLocalDataSource {
  JwtEntity? value;
  int writes = 0;
  Exception? writeError;

  @override
  Future<JwtEntity?> read() async => value;
  @override
  Future<void> write(JwtEntity tokens) async {
    if (writeError != null) throw writeError!;
    writes++;
    value = tokens;
  }

  @override
  Future<void> delete() async => value = null;
}

class FakeAuthRemote implements AuthRemoteDataSource {
  int refreshCount = 0;
  final refreshing = Completer<void>();
  Future<JwtEntity> Function(String)? onRefresh;
  Future<void> Function(String)? onSignOut;
  String? revokedToken;

  @override
  Future<UserModel> getMe() async =>
      const UserModel(id: 42, email: 'test@example.com', nickname: '퀴즈');

  @override
  Future<JwtEntity> signIn({
    required String email,
    required String password,
  }) async => testTokens();
  @override
  Future<int> signUp({
    required String email,
    required String password,
    required String nickname,
  }) async => 1;
  @override
  Future<JwtEntity> refresh(String refreshToken) async {
    refreshCount++;
    if (!refreshing.isCompleted) refreshing.complete();
    return onRefresh == null
        ? testTokens('new')
        : await onRefresh!(refreshToken);
  }

  @override
  Future<void> signOut(String refreshToken) async {
    revokedToken = refreshToken;
    await onSignOut?.call(refreshToken);
  }
}

class CallbackAdapter implements HttpClientAdapter {
  CallbackAdapter(this.respond);
  final FutureOr<ResponseBody> Function(RequestOptions) respond;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    await requestStream?.drain<void>();
    return respond(options);
  }

  @override
  void close({bool force = false}) {}
}

ResponseBody jsonResponse(String body, [int status = 200]) =>
    ResponseBody.fromString(
      body,
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );

ResponseBody unauthorized() => jsonResponse(
  '{"status":401,"code":"UNAUTHORIZED","detail":"로그인이 필요합니다."}',
  401,
);
