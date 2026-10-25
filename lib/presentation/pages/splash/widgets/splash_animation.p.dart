part of '../splash_page.dart';

class _SplashAnimation extends StatelessWidget with SplashEvent {
  const _SplashAnimation({required this.controller});
  final AnimationController controller;

  @override
  Widget build(BuildContext context) => Center(
    child: Lottie.asset(
      'assets/lottie/iquiz_splash.json',
      controller: controller,
      repeat: false,
      onLoaded: (composition) =>
          onAnimationLoaded(controller, composition.duration),
    ),
  );
}
