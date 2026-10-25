import 'package:json_annotation/json_annotation.dart';

part 'auth_token_model.g.dart';

///
/// 로그인·재발급 인증 토큰
///
@JsonSerializable()
class AuthTokenModel {
  const AuthTokenModel({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
  });

  factory AuthTokenModel.fromJson(Map<String, Object?> json) =>
      _$AuthTokenModelFromJson(json);

  final String accessToken;
  final String refreshToken;
  final int expiresIn;

  Map<String, Object?> toJson() => _$AuthTokenModelToJson(this);
}
