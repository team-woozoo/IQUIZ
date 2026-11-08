import 'package:iquiz/features/auth/repositories/entities/jwt_entity.dart';

import 'package:json_annotation/json_annotation.dart';

part 'token_refresh_model.g.dart';

///
/// 토큰 재발급·로그아웃 요청 정보
///
@JsonSerializable(explicitToJson: true)
class TokenRefreshModel {
  const TokenRefreshModel({required this.refreshToken});

  factory TokenRefreshModel.fromEntity(JwtEntity entity) =>
      TokenRefreshModel(refreshToken: entity.refreshToken);

  factory TokenRefreshModel.fromJson(Map<String, Object?> json) =>
      _$TokenRefreshModelFromJson(json);

  final String refreshToken;

  Map<String, Object?> toJson() => _$TokenRefreshModelToJson(this);
}
