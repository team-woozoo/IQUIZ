import 'package:iquiz/app/network/api_error.dart';
import 'package:iquiz/core/error/result.dart';
import 'package:iquiz/core/exception/custom_exception.dart';
import 'package:iquiz/features/auth/data_source/remote/auth_remote_data_source.dart';
import 'package:iquiz/features/auth/repositories/auth_repository.dart';
import 'package:iquiz/features/auth/repositories/entities/user_entity.dart';
import 'package:iquiz/features/auth/services/auth_token_manager.dart';

final class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({required this.remote, required this.tokens});

  final AuthRemoteDataSource remote;
  final AuthTokenManager tokens;

  Future<UserEntity> _me() async {
    final version = tokens.generation;
    final response = await remote.getMe();
    if (version != tokens.generation || !tokens.hasTokens) {
      throw const UnAuthorizedException();
    }
    return UserEntity(
      id: response.id,
      email: response.email,
      nickname: response.nickname,
    );
  }

  @override
  Future<Result<UserEntity?>> restore() async {
    try {
      await tokens.restore();
      return Result.success(tokens.hasTokens ? await _me() : null);
    } on Exception catch (error) {
      final mapped = mapApiError(error);
      if (mapped is InvalidRefreshTokenException ||
          mapped is UnAuthorizedException) {
        return Result.success(null);
      }
      return Result.failure(mapped);
    }
  }

  @override
  Future<Result<UserEntity>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await tokens.waitForSignOut();
      final version = tokens.generation;
      final result = await remote.signIn(email: email, password: password);
      await tokens.saveLogin(result, version);
      return Result.success(await _me());
    } on Exception catch (error) {
      return Result.failure(mapApiError(error));
    }
  }

  @override
  Future<Result<int>> signUp({
    required String email,
    required String password,
    required String nickname,
  }) async {
    try {
      return Result.success(
        await remote.signUp(
          email: email,
          password: password,
          nickname: nickname,
        ),
      );
    } on Exception catch (error) {
      return Result.failure(mapApiError(error));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      await tokens.signOut();
      return Result.success(null);
    } on Exception catch (error) {
      return Result.failure(error);
    }
  }
}
