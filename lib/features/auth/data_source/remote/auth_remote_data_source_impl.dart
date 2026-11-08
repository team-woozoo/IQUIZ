import 'package:dio/dio.dart';
import 'package:iquiz/app/network/app_dio.dart';
import 'package:iquiz/core/helper/future_extension.dart';
import 'package:iquiz/features/auth/data_source/remote/auth_remote_data_source.dart';
import 'package:iquiz/features/auth/data_source/remote/models/models.dart';

final class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl();

  Dio get _dio => AppDio.instance;

  @override
  Future<AuthTokenModel> signIn(SignInModel request) => _dio
      .post<Map<String, dynamic>>('/auth/login', data: request.toJson())
      .withSingleConverter(fromJson: _tokensFromJson);

  @override
  Future<SignUpResultModel> signUp(SignUpModel request) => _dio
      .post<Map<String, dynamic>>('/auth/signup', data: request.toJson())
      .withSingleConverter(
        fromJson: (json) {
          if (json['id'] is! int) {
            throw const FormatException('회원가입 응답이 올바르지 않습니다.');
          }
          return SignUpResultModel.fromJson(json);
        },
      );

  @override
  Future<AuthTokenModel> refresh(TokenRefreshModel request) => _dio
      .post<Map<String, dynamic>>('/auth/refresh', data: request.toJson())
      .withSingleConverter(fromJson: _tokensFromJson);

  @override
  Future<void> signOut(TokenRefreshModel request) async {
    await _dio.post('/auth/logout', data: request.toJson());
  }

  @override
  Future<UserModel> getMe() => _dio
      .get<Map<String, dynamic>>('/users/me')
      .withSingleConverter(
        fromJson: (json) {
          if (json['id'] is! int ||
              json['email'] is! String ||
              json['nickname'] is! String) {
            throw const FormatException('사용자 정보 응답이 올바르지 않습니다.');
          }
          return UserModel.fromJson(json);
        },
      );

  static AuthTokenModel _tokensFromJson(Map<String, dynamic> json) {
    if (json['accessToken'] is! String ||
        json['refreshToken'] is! String ||
        json['expiresIn'] is! int) {
      throw const FormatException('올바르지 않은 인증 응답입니다.');
    }
    return AuthTokenModel.fromJson(json);
  }
}
