import 'package:iquiz/features/auth/data_source/remote/models/auth_token_model.dart';

/// 토큰은 Provider의 화면 상태에 포함하지 않음
final class JwtEntity {
  const JwtEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  factory JwtEntity.fromModel(AuthTokenModel model) {
    if (model.expiresIn <= 0 ||
        model.accessToken.isEmpty ||
        model.refreshToken.isEmpty) {
      throw const FormatException('올바르지 않은 인증 응답입니다.');
    }
    return JwtEntity(
      accessToken: model.accessToken,
      refreshToken: model.refreshToken,
      expiresAt: DateTime.now().toUtc().add(Duration(seconds: model.expiresIn)),
    );
  }

  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  factory JwtEntity.fromStorage(Map<String, dynamic> json) => JwtEntity(
    accessToken: _token(json, 'accessToken'),
    refreshToken: _token(json, 'refreshToken'),
    expiresAt: DateTime.parse(json['expiresAt'] as String).toUtc(),
  );

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'expiresAt': expiresAt.toUtc().toIso8601String(),
  };

  static String _token(Map<String, dynamic> json, String key) {
    final dynamic value = json[key];
    if (value is! String || value.isEmpty) {
      throw const FormatException('올바르지 않은 인증 응답입니다.');
    }
    return value;
  }

  @override
  String toString() => 'AuthTokens(<redacted>)';
}
