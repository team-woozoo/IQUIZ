import 'package:iquiz/presentation/providers/user/user_auth_provider.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'main_bottom_navigation.g.dart';

enum MainNavigationTab {
  home('홈'),
  note('노트'),
  profile('프로필');

  const MainNavigationTab(this.label);
  final String label;

  bool get isEnabled => true;
}

@Riverpod(keepAlive: true)
class MainBottomNavigation extends _$MainBottomNavigation {
  @override
  MainNavigationTab build() {
    ref.watch(userAuthProvider.select((auth) => auth.user?.id));
    return MainNavigationTab.home;
  }

  void changeTab(MainNavigationTab tab) {
    if (!tab.isEnabled || state == tab) return;
    state = tab;
  }
}
