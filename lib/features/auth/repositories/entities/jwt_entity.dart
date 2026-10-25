/// 토큰은 Provider의 화면 상태에 포함하지 않음
final class JwtEntity {
  const JwtEntity({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresAt,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime expiresAt;

  factory JwtEntity.fromResponse(Map<String, dynamic> json) {
    final dynamic expiresIn = json['expiresIn'];
    if (expiresIn is! int || expiresIn <= 0) {
      throw const FormatException('올바르지 않은 토큰 만료 정보입니다.');
    }
    return JwtEntity(
      accessToken: _token(json, 'accessToken'),
      refreshToken: _token(json, 'refreshToken'),
      expiresAt: DateTime.now().toUtc().add(Duration(seconds: expiresIn)),
    );
  }

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
