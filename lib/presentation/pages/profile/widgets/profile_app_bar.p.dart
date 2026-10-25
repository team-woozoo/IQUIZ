part of '../profile_page.dart';

class _ProfileAppBar extends HookConsumerWidget
    with HomeEvent
    implements PreferredSizeWidget {
  const _ProfileAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(BaseAppBar.appbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opening = useState(false);
    return BaseAppBar(
      title: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: Text('프로필', style: AppTextStyle.semiBold(24, 31.2)),
      ),
      actions: [
        IconButton(
          tooltip: '자료 검색',
          constraints: const BoxConstraints.tightFor(width: 56, height: 56),
          padding: EdgeInsets.zero,
          onPressed: () => onSearchTapped(ref, opening),
          icon: SvgPicture.asset('assets/home/search.svg'),
        ),
        IconButton(
          tooltip: '학습 자료 업로드',
          constraints: const BoxConstraints.tightFor(width: 56, height: 56),
          padding: EdgeInsets.zero,
          onPressed: () => onUploadTapped(context),
          icon: SvgPicture.asset('assets/home/add.svg'),
        ),
      ],
    );
  }
}
