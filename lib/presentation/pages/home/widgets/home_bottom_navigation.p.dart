part of '../home_page.dart';

class _HomeBottomNavigation extends ConsumerWidget with HomeState, HomeEvent {
  const _HomeBottomNavigation();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = currentNavigationTab(ref);
    final noteSelected = current == HomeNavigationTab.note;
    final profileSelected = current == HomeNavigationTab.profile;
    void select(HomeNavigationTab tab) => onNavigationTabSelected(ref, tab);
    return Material(
      color: AppColor.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Row(
          children: [
            _HomeTabButton(
              tab: HomeNavigationTab.home,
              label: '홈',
              asset: profileSelected
                  ? 'assets/icons/profile_home.svg'
                  : noteSelected
                  ? 'assets/icons/note_home.svg'
                  : 'assets/home/home.svg',
              selected: current == HomeNavigationTab.home,
              onTap: () => select(HomeNavigationTab.home),
            ),
            _HomeTabButton(
              tab: HomeNavigationTab.note,
              label: '노트',
              asset: noteSelected
                  ? 'assets/icons/note_selected.svg'
                  : 'assets/home/note.svg',
              selected: noteSelected,
              onTap: () => select(HomeNavigationTab.note),
            ),
            _HomeTabButton(
              tab: HomeNavigationTab.profile,
              label: '프로필',
              asset: profileSelected
                  ? 'assets/icons/profile_selected.svg'
                  : noteSelected
                  ? 'assets/icons/note_profile.svg'
                  : 'assets/home/profile.svg',
              selected: profileSelected,
              onTap: () => select(HomeNavigationTab.profile),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeTabButton extends StatelessWidget {
  const _HomeTabButton({
    required this.tab,
    required this.label,
    required this.asset,
    this.selected = false,
    this.onTap,
  });

  final String label;
  final HomeNavigationTab tab;
  final String asset;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Semantics(
      button: true,
      selected: selected,
      enabled: onTap != null,
      child: InkWell(
        key: ValueKey('home_tab_${tab.name}'),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 10, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox.square(
                dimension: 24,
                child: Align(
                  alignment: asset == 'assets/icons/note_selected.svg'
                      ? const Alignment(0, -0.537)
                      : asset == 'assets/home/note.svg'
                      ? const Alignment(0, -0.54)
                      : Alignment.center,
                  child: SvgPicture.asset(
                    asset,
                    colorFilter: ColorFilter.mode(
                      selected ? AppColor.iconColor : AppColor.disabledText,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyle.medium(13, 13 * 1.45).copyWith(
                  color: selected ? AppColor.iconColor : AppColor.disabledText,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
