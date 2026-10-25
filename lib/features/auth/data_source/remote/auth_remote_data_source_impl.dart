import 'package:dio/dio.dart';
import 'package:iquiz/app/network/app_dio.dart';
import 'package:iquiz/core/helper/future_extension.dart';
import 'package:iquiz/features/auth/data_source/remote/auth_remote_data_source.dart';
import 'package:iquiz/features/auth/data_source/remote/models/user_model.dart';
import 'package:iquiz/features/auth/repositories/entities/jwt_entity.dart';

final class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl();

  Dio get _dio => AppDio.instance;

  @override
  Future<JwtEntity> signIn({required String email, required String password}) =>
      _dio
          .post<Map<String, dynamic>>(
            '/auth/login',
            data: {'email': email, 'password': password},
          )
          .withSingleConverter(fromJson: JwtEntity.fromResponse);

  @override
  Future<int> signUp({
    required String email,
    required String password,
    required String nickname,
  }) => _dio
      .post<Map<String, dynamic>>(
        '/auth/signup',
        data: {'email': email, 'password': password, 'nickname': nickname},
      )
      .withSingleConverter(
        fromJson: (json) {
          final dynamic id = json['id'];
          if (id is! int) {
            throw const FormatException('회원가입 응답이 올바르지 않습니다.');
          }
          return id;
        },
      );

  @override
  Future<JwtEntity> refresh(String refreshToken) => _dio
      .post<Map<String, dynamic>>(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      )
      .withSingleConverter(fromJson: JwtEntity.fromResponse);

  @override
  Future<void> signOut(String refreshToken) async {
    await _dio.post('/auth/logout', data: {'refreshToken': refreshToken});
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
}
