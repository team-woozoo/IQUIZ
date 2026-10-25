part of 'splash_page.dart';

mixin class SplashState {
  bool showInitializationFailure(WidgetRef ref) {
    final auth = ref.watch(userAuthProvider);
    final completed = ref.watch(splashAnimationProvider);
    return auth.status == AuthStatus.failure && completed;
  }

  AnimationController useSplashController() => useAnimationController(
    // 접근성 설정으로 재생 시간이 단축돼도 최소 노출 시간을 유지
    animationBehavior: AnimationBehavior.preserve,
  );
}
