part of '../material_detail_page.dart';

class _MaterialDetailToolbar extends StatelessWidget {
  const _MaterialDetailToolbar({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 56,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 56),
          child: Semantics(
            header: true,
            child: Tooltip(
              message: title,
              child: Text(
                title,
                key: const ValueKey('material_title'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyle.semiBold(20, 28),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox.square(
            dimension: 56,
            child: IconButton(
              tooltip: '뒤로가기',
              onPressed: onBack,
              icon: SvgPicture.asset('assets/icons/material_back.svg'),
            ),
          ),
        ),
      ],
    ),
  );
}
