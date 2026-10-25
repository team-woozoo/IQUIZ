part of '../notice_page.dart';

class _NoticeBottomNavigation extends ConsumerWidget
    with NoticeState, NoticeEvent {
  const _NoticeBottomNavigation();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final config = configInfo(ref).asData?.value;
    return BaseBottomNavigationBar.singleBtn(
      btnText: '업데이트',
      backgroundColor: AppColor.brandColor,
      onBtnClicked: config == null
          ? null
          : () => onUpdateTapped(ref, config.noticeUrl),
    );
  }
}
