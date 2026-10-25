import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:iquiz/app/router/router.dart';
import 'package:iquiz/app/style/app_text_style.dart';
import 'package:iquiz/core/constants/app_color.dart';
import 'package:iquiz/core/exception/custom_exception.dart';
import 'package:iquiz/features/learning_profile/repositories/entities/weak_concept_entity.dart';
import 'package:iquiz/features/quiz/repositories/entities/study_material_entity.dart';
import 'package:iquiz/features/quiz/repositories/enums/quiz_generation_status.enum.dart';
import 'package:iquiz/presentation/pages/home/providers/home_bottom_navigation.dart';
import 'package:iquiz/presentation/pages/home/providers/my_weak_concepts_provider.dart';
import 'package:iquiz/presentation/pages/profile/profile_page.dart';
import 'package:iquiz/presentation/pages/wrong_answers/wrong_answers_page.dart';
import 'package:iquiz/presentation/providers/material/material_providers.dart';
import 'package:iquiz/presentation/providers/quiz/quiz_generation_activity_provider.dart';
import 'package:iquiz/presentation/widgets/base_app_bar.dart';
import 'package:iquiz/presentation/widgets/base_page.dart';

part 'home_state.dart';
part 'home_event.dart';
part 'widgets/home_app_bar.p.dart';
part 'widgets/home_list_message.p.dart';
part 'widgets/home_search_sheet.p.dart';
part 'widgets/recent_material_list.p.dart';
part 'widgets/recent_material_tile.p.dart';
part 'widgets/recent_material_content.p.dart';
part 'widgets/generating_material_list.p.dart';
part 'widgets/review_recommendation_card.p.dart';
part 'widgets/review_book_cover.p.dart';
part 'widgets/review_recommendation_content.p.dart';
part 'widgets/home_content.p.dart';
part 'widgets/home_bottom_navigation.p.dart';

/// 탭 이동은 라우트를 교체하지 않고 홈 PageView 안에서 처리
class HomePage extends BasePage {
  const HomePage({super.key, this.initialTab = HomeNavigationTab.home});
  final HomeNavigationTab initialTab;

  @override
  void onReady(WidgetRef ref) => ref
      .read(homeBottomNavigationProvider.notifier)
      .changeTab(initialTab.isEnabled ? initialTab : HomeNavigationTab.home);

  @override
  Widget buildBottomNavigationBar(BuildContext context) =>
      const _HomeBottomNavigation();

  @override
  Widget buildPage(BuildContext context, WidgetRef ref) {
    final startTab = initialTab.isEnabled ? initialTab : HomeNavigationTab.home;
    final controller = usePageController(initialPage: startTab.index);
    final currentTab = ref.watch(homeBottomNavigationProvider);
    final fade = useAnimationController(
      duration: const Duration(milliseconds: 200),
    );
    ref.listen(homeBottomNavigationProvider, (_, next) {
      FocusManager.instance.primaryFocus?.unfocus();
      if (controller.hasClients) controller.jumpToPage(next.index);
    });
    useEffect(() {
      fade.forward(from: 0);
      return null;
    }, [currentTab]);

    const pages = [_HomeContent(), WrongAnswersPage(), ProfilePage()];
    return PageView(
      key: const ValueKey('home_pages'),
      controller: controller,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        for (final (index, page) in pages.indexed)
          _HomeTabPage(
            key: ValueKey(HomeNavigationTab.values[index]),
            active: currentTab.index == index,
            child: FadeTransition(opacity: fade, child: page),
          ),
      ],
    );
  }
}

class _HomeTabPage extends HookWidget {
  const _HomeTabPage({super.key, required this.active, required this.child});
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
