import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'splash_animation.g.dart';

/// 앱 시작 시 스플래시 애니메이션을 한 번 재생했는지 공유
@Riverpod(keepAlive: true)
class SplashAnimation extends _$SplashAnimation {
  @override
  bool build() {
    return false;
  }

  void complete() {
    state = true;
  }
}
