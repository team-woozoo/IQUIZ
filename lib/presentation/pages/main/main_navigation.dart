import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iquiz/app/router/router.dart';
import 'package:iquiz/presentation/pages/main/providers/main_bottom_navigation.dart';

/// 메인 라우트가 유지된 상태에서도 '홈으로' 동작은 홈 탭을 선택
void goToHome(BuildContext context) {
  ProviderScope.containerOf(context, listen: false)
      .read(mainBottomNavigationProvider.notifier)
      .changeTab(MainNavigationTab.home);
  const HomeRoute().go(context);
}
