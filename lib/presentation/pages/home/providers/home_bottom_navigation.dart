import 'package:iquiz/presentation/providers/user/user_auth_provider.dart';
import 'package:riverpod/riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'home_bottom_navigation.g.dart';

enum HomeNavigationTab {
  home('홈'),
  note('노트'),
  profile('프로필');

  const HomeNavigationTab(this.label);
  final String label;

  bool get isEnabled => true;
}

@Riverpod(keepAlive: true)
class HomeBottomNavigation extends _$HomeBottomNavigation {
  @override
  HomeNavigationTab build() {
    ref.watch(userAuthProvider.select((auth) => auth.user?.id));
    return HomeNavigationTab.home;
  }

  void changeTab(HomeNavigationTab tab) {
    if (!tab.isEnabled || state == tab) return;
    state = tab;
  }
}
