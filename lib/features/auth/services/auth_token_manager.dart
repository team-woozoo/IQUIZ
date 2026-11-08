import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:iquiz/app/network/api_error.dart';
import 'package:iquiz/core/auth/auth_session.dart';
import 'package:iquiz/core/exception/custom_exception.dart';
import 'package:iquiz/features/auth/data_source/local/auth_local_data_source.dart';
import 'package:iquiz/features/auth/data_source/remote/auth_remote_data_source.dart';
import 'package:iquiz/features/auth/data_source/remote/models/token_refresh_model.dart';
import 'package:iquiz/features/auth/repositories/entities/jwt_entity.dart';

/// 토큰 교체/삭제를 직렬화하고 회전하는 Refresh 토큰의 중복 사용을 방지
final class AuthTokenManager extends ChangeNotifier implements AuthSession {
  AuthTokenManager({required this.local, required this.remote});

  final AuthLocalDataSource local;
  final AuthRemoteDataSource remote;
  JwtEntity? _tokens;
  Future<JwtEntity>? _refreshing;
  Future<void>? _signingOut;
  Future<void> _storageQueue = Future<void>.value();
  bool _loaded = false;
  bool _disposed = false;
  int _generation = 0;

  @override
  String? get accessToken => _tokens?.accessToken;
  @override
  int get generation => _generation;
  @override
  bool get hasTokens => _tokens != null;

  @override
  Future<void> refreshAccessToken() async {
    await refresh();
  }

  Future<void> waitForSignOut() async => await _signingOut;

  Future<void> restore() async {
    if (_loaded) return;
    final version = _generation;
    final tokens = await _storage(local.read);
    if (!_isCurrentSession(version)) return;
    _tokens = tokens;
    _loaded = true;
  }

  Future<void> saveLogin(JwtEntity tokens, int expectedGeneration) async {
    _requireCurrentSession(expectedGeneration);
    final version = ++_generation;
    _refreshing = null;
    await _persistTokens(tokens, version);
    _requireCurrentSession(version);
    _tokens = tokens;
    _loaded = true;
  }

  Future<JwtEntity> refresh() {
    final pending = _refreshing;
    if (pending != null) return pending;
    final tokens = _tokens;
    if (tokens == null || _disposed) {
      return Future.error(const UnAuthorizedException());
    }
    final version = _generation;
    late final Future<JwtEntity> operation;
    operation = _refresh(tokens, version).then((value) {
      if (identical(_refreshing, operation)) _refreshing = null;
      return value;
    });
    // 실패한 Future도 유지해 응답 유실 시 이미 소비된 토큰의 자동 재전송 방지
    // 재로그인 시 해제
    _refreshing = operation;
    return operation;
  }

  Future<JwtEntity> _refresh(JwtEntity previous, int version) async {
    try {
      final tokens = JwtEntity.fromModel(
        await remote.refresh(TokenRefreshModel.fromEntity(previous)),
      );
      await _persistRefreshedTokens(tokens, version);
      if (_isCurrentSession(version)) _tokens = tokens;
      // 로그아웃이 대기 중이면 서버 폐기에 사용할 최신 Refresh 토큰을 반환
      return tokens;
    } on Exception catch (error) {
      final mapped = mapApiError(error);
      if (mapped is InvalidRefreshTokenException && version == _generation) {
        await clear();
      }
      throw mapped;
    }
  }

  bool _isCurrentSession(int version) => !_disposed && version == _generation;

  void _requireCurrentSession(int version) {
    if (!_isCurrentSession(version)) throw const UnAuthorizedException();
  }

  Future<void> _persistTokens(JwtEntity tokens, int version) =>
      _storage(() async {
        if (_isCurrentSession(version)) await local.write(tokens);
      });

  Future<void> _persistRefreshedTokens(JwtEntity tokens, int version) async {
    try {
      await _persistTokens(tokens, version);
    } on Exception {
      // 회전한 Refresh 토큰 저장에 실패하면 이전 토큰으로 복원하지 않음
      if (version == _generation) await clear();
      rethrow;
    }
  }

  @override
  Future<void> clear() async {
    _invalidate();
    await _storage(local.delete);
  }

  Future<void> signOut() =>
      _signingOut ??= _signOut().whenComplete(() => _signingOut = null);

  Future<void> _signOut() async {
    final previous = _tokens;
    final pending = _refreshing;
    _invalidate();
    try {
      final tokens = await _latestTokens(previous, pending);
      if (tokens != null) {
        await remote.signOut(TokenRefreshModel.fromEntity(tokens));
      }
    } on Exception {
      // 서버 응답과 관계없이 로컬 로그아웃을 완료
    } finally {
      await _storage(local.delete);
    }
  }

  Future<JwtEntity?> _latestTokens(
    JwtEntity? previous,
    Future<JwtEntity>? pending,
  ) async {
    try {
      return await pending ?? previous;
    } on Exception {
      // 재발급이 실패해도 기존 토큰으로 서버 로그아웃은 시도
      return previous;
    }
  }

  void _invalidate() {
    _generation++;
    _tokens = null;
    _refreshing = null;
    _loaded = true;
    if (!_disposed) notifyListeners();
  }

  Future<T> _storage<T>(Future<T> Function() action) {
    final operation = _storageQueue.then((_) => action());
    _storageQueue = operation.then<void>(
      (_) {},
      onError: (Object _, StackTrace _) {},
    );
    return operation;
  }

  @override
  void dispose() {
    _disposed = true;
    _generation++;
    super.dispose();
  }
}
