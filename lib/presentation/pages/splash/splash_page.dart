import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iquiz/app/di/network/network.dart';
import 'package:iquiz/presentation/pages/splash/providers/splash_animation.dart';
import 'package:iquiz/presentation/providers/config/app_config_provier.dart';
import 'package:iquiz/presentation/providers/config/detect_force_update_provider.dart';
import 'package:iquiz/presentation/providers/user/user_auth_provider.dart';
import 'package:iquiz/presentation/widgets/base_page.dart';
import 'package:lottie/lottie.dart';

part 'splash_state.dart';
part 'splash_event.dart';
part 'widgets/splash_animation.p.dart';
part 'widgets/splash_failure.p.dart';

class SplashPage extends BasePage with SplashState, SplashEvent {
  const SplashPage({super.key});

  @override
  void onReady(WidgetRef ref) => unawaited(routePage(ref));

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    final showFailure = showInitializationFailure(ref);
    final controller = useSplashController();
    useEffect(() => onAnimationAttached(ref, controller), [controller]);

    // 초기화 실패도 첫 재생이 끝난 뒤 표시
    return showFailure
        ? const _SplashFailure()
        : _SplashAnimation(controller: controller);
  }
}
