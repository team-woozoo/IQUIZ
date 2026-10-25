part of '../home_page.dart';

class _HomeAppBar extends HookConsumerWidget
    with HomeEvent
    implements PreferredSizeWidget {
  const _HomeAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(BaseAppBar.appbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // final opening = useState(false);
    return BaseAppBar(
      title: Padding(
        padding: const EdgeInsets.only(left: 16),
        child: SvgPicture.asset(
          'assets/home/wordmark.svg',
          semanticsLabel: '아이퀴즈',
        ),
      ),
      actions: [
        IconButton(
          tooltip: '자료 검색',
          constraints: const BoxConstraints.tightFor(width: 56, height: 56),
          padding: EdgeInsets.zero,
          onPressed: () {},
          icon: SvgPicture.asset('assets/home/search.svg'),
        ),
        IconButton(
          tooltip: '학습 자료 업로드',
          constraints: const BoxConstraints.tightFor(width: 56, height: 56),
          padding: EdgeInsets.zero,
          style: IconButton.styleFrom(shape: const CircleBorder()),
          onPressed: () => onUploadTapped(context),
          icon: SvgPicture.asset('assets/home/add.svg'),
        ),
      ],
    );
  }
}
