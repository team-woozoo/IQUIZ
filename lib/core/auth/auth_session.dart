/// 네트워크 계층에서 필요한 인증 기능. 구체적인 저장소나 인증 구현은 알지 않음
abstract interface class AuthSession {
  String? get accessToken;
  int get generation;
  bool get hasTokens;

  Future<void> refreshAccessToken();
  Future<void> clear();
}
