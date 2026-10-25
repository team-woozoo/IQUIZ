import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:iquiz/app/style/app_text_style.dart';
import 'package:iquiz/core/constants/app_color.dart';
import 'package:iquiz/presentation/pages/home/home_page.dart';
import 'package:iquiz/presentation/pages/profile/profile_page.dart';
import 'package:iquiz/presentation/pages/main/providers/main_bottom_navigation.dart';
import 'package:iquiz/presentation/pages/wrong_answers/wrong_answers_page.dart';
import 'package:iquiz/presentation/widgets/base_page.dart';

part 'widgets/main_bottom_navigation.p.dart';

/// 탭 이동은 라우트를 교체하지 않고 메인 PageView 안에서 처리
class MainPage extends BasePage {
  const MainPage({super.key, this.initialTab = MainNavigationTab.home});
  final MainNavigationTab initialTab;

  @override
  void onReady(WidgetRef ref) => ref
      .read(mainBottomNavigationProvider.notifier)
      .changeTab(initialTab.isEnabled ? initialTab : MainNavigationTab.home);

  @override
  Widget buildBottomNavigationBar(BuildContext context) =>
      const _MainBottomNavigation();

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    final startTab = initialTab.isEnabled ? initialTab : MainNavigationTab.home;
    final controller = usePageController(initialPage: startTab.index);
    final currentTab = ref.watch(mainBottomNavigationProvider);
    final fade = useAnimationController(
      duration: const Duration(milliseconds: 200),
    );
    ref.listen(mainBottomNavigationProvider, (_, next) {
      FocusManager.instance.primaryFocus?.unfocus();
      if (controller.hasClients) controller.jumpToPage(next.index);
    });
    useEffect(() {
      fade.forward(from: 0);
      return null;
    }, [currentTab]);

    const pages = [HomePage(), WrongAnswersPage(), ProfilePage()];
    return PageView(
      key: const ValueKey('main_pages'),
      controller: controller,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final (index, page) in pages.indexed)
          _MainTabPage(
            key: ValueKey(MainNavigationTab.values[index]),
            active: currentTab.index == index,
            child: FadeTransition(opacity: fade, child: page),
          ),
      ],
    );
  }
}

class _MainTabPage extends HookWidget {
  const _MainTabPage({super.key, required this.active, required this.child});
  final bool active;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    useAutomaticKeepAlive();
    return ExcludeFocus(
      excluding: !active,
      child: TickerMode(
        enabled: active,
        child: Offstage(offstage: !active, child: child),
      ),
    );
  }
}
