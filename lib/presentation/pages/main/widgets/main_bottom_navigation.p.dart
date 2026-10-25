part of '../main_page.dart';

class _MainBottomNavigation extends ConsumerWidget {
  const _MainBottomNavigation();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(mainBottomNavigationProvider);
    final noteSelected = current == MainNavigationTab.note;
    final profileSelected = current == MainNavigationTab.profile;
    final noteStyle = current != MainNavigationTab.home;
    void select(MainNavigationTab tab) =>
        ref.read(mainBottomNavigationProvider.notifier).changeTab(tab);
    return Material(
      color: AppColor.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 5),
        child: Row(
          children: [
            _MainTabButton(
              tab: MainNavigationTab.home,
              label: '홈',
              asset: profileSelected
                  ? 'assets/icons/profile_home.svg'
                  : noteSelected
                  ? 'assets/icons/note_home.svg'
                  : 'assets/home/home.svg',
              selected: current == MainNavigationTab.home,
              noteStyle: noteStyle,
              onTap: () => select(MainNavigationTab.home),
            ),
            _MainTabButton(
              tab: MainNavigationTab.note,
              label: '노트',
              asset: noteSelected
                  ? 'assets/icons/note_selected.svg'
                  : 'assets/home/note.svg',
              selected: noteSelected,
              tint: profileSelected ? AppColor.disabledText : null,
              noteStyle: noteStyle,
              onTap: () => select(MainNavigationTab.note),
            ),
            _MainTabButton(
              tab: MainNavigationTab.profile,
              label: '프로필',
              asset: profileSelected
                  ? 'assets/icons/profile_selected.svg'
                  : noteSelected
                  ? 'assets/icons/note_profile.svg'
                  : 'assets/home/profile.svg',
              noteStyle: noteStyle,
              selected: profileSelected,
              tint: profileSelected ? null : AppColor.disabledText,
              onTap: () => select(MainNavigationTab.profile),
            ),
          ],
        ),
      ),
    );
  }
}

class _MainTabButton extends StatelessWidget {
  const _MainTabButton({
    required this.tab,
    required this.label,
    required this.asset,
    this.selected = false,
    this.onTap,
    this.noteStyle = false,
    this.tint,
  });

  final String label;
  final MainNavigationTab tab;
  final String asset;
  final bool selected;
  final VoidCallback? onTap;
  final bool noteStyle;
  final Color? tint;

  @override
  Widget build(BuildContext context) => Expanded(
    child: Semantics(
      button: true,
      selected: selected,
      enabled: onTap != null,
      child: InkWell(
        key: ValueKey('main_tab_${tab.name}'),
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
                    colorFilter: tint == null
                        ? null
                        : ColorFilter.mode(tint!, BlendMode.srcIn),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                style: AppTextStyle.medium(13, 13 * 1.45).copyWith(
                  color: selected
                      ? noteStyle
                            ? AppColor.primaryAction
                            : AppColor.brandColor
                      : AppColor.disabledText,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
