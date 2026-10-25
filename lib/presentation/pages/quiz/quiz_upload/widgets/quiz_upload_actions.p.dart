part of '../quiz_upload_page.dart';

class _UploadBottomAction extends StatelessWidget {
  const _UploadBottomAction({required this.label, required this.onPressed});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => BaseBottomNavigationBar.singleBtn(
    btnText: label,
    onBtnClicked: onPressed,
    backgroundColor: onPressed == null
        ? const Color(0xFFF4EAFE)
        : AppColor.brandColor,
  );
}

/// 본문을 하단 바 뒤까지 그려 공통 바의 투명도와 배경 블러를 유지
class _UploadActionLayout extends StatelessWidget {
  const _UploadActionLayout({required this.child, this.action});

  final Widget child;
  final Widget? action;

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      child,
      if (action case final Widget button)
        Align(alignment: Alignment.bottomCenter, child: button),
    ],
  );
}
