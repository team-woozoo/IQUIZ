part of '../material_detail_page.dart';

class _MaterialPlayAction extends StatelessWidget {
  const _MaterialPlayAction({
    required this.onPressed,
    required this.onGenerate,
    this.busy = false,
  });

  final VoidCallback? onPressed;
  final VoidCallback onGenerate;
  final bool busy;

  @override
  Widget build(BuildContext context) => BaseBottomNavigationBar.dividedBtn(
    leftBtnText: busy ? '불러오는 중...' : '기존 문제',
    rightBtnText: '문제 생성',
    leftButtonKey: const ValueKey('material_play_button'),
    rightButtonKey: const ValueKey('material_generate_button'),
    onLeftBtnClicked: busy ? null : onPressed,
    onRightBtnClicked: onGenerate,
  );
}
