import 'package:iquiz/features/auth/repositories/entities/jwt_entity.dart';
import 'package:iquiz/features/auth/data_source/remote/models/user_model.dart';

abstract interface class AuthRemoteDataSource {
  Future<JwtEntity> signIn({required String email, required String password});
  Future<int> signUp({
    required String email,
    required String password,
    required String nickname,
  });
  Future<JwtEntity> refresh(String refreshToken);
  Future<void> signOut(String refreshToken);
  Future<UserModel> getMe();
}
