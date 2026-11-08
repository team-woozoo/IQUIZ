import 'package:iquiz/features/auth/data_source/remote/models/models.dart';

abstract interface class AuthRemoteDataSource {
  Future<AuthTokenModel> signIn(SignInModel request);
  Future<SignUpResultModel> signUp(SignUpModel request);
  Future<AuthTokenModel> refresh(TokenRefreshModel request);
  Future<void> signOut(TokenRefreshModel request);
  Future<UserModel> getMe();
}
