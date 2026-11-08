part of 'splash_page.dart';

mixin class SplashState {
  /// 스플래시 애니메이션이 끝났고 앱 초기화가 실패했는지 구독해 오류 화면 표시 여부를 반환
  bool showInitializationFailure(WidgetRef ref) {
    final auth = ref.watch(userAuthProvider);
    final completed = ref.watch(splashAnimationProvider);
    return auth.status == AuthStatus.failure && completed;
  }

  /// 초기화 오류가 설정 문제인지 연결·인증 복원 문제인지 구분해 안내 문구를 반환
  String initializationFailureMessage(WidgetRef ref) {
    Object? error = ref.watch(userAuthProvider).error;
    while (error is ProviderException) {
      error = error.exception;
    }
    return error is FormatException
        ? '서버 연결 설정을 확인하지 못했습니다.\n잠시 후 다시 시도해 주세요.'
        : '앱을 시작하지 못했습니다.\n네트워크 연결을 확인한 뒤 다시 시도해 주세요.';
  }

  /// 스플래시 재생용 애니메이션 컨트롤러를 생성
  /// 접근성 설정으로 재생 시간이 단축돼도 최소 노출 시간을 유지
  AnimationController useSplashController() => useAnimationController(
    // 접근성 설정으로 재생 시간이 단축돼도 최소 노출 시간을 유지
    animationBehavior: AnimationBehavior.preserve,
  );
}
