import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iquiz/app/style/app_text_style.dart';
import 'package:iquiz/core/constants/app_color.dart';

class QuizToolbar extends StatelessWidget implements PreferredSizeWidget {
  const QuizToolbar({
    super.key,
    required this.onBack,
    this.current,
    this.total,
  });
  final VoidCallback onBack;
  final int? current;
  final int? total;

  @override
  Size get preferredSize => const Size.fromHeight(56);

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 56,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: SizedBox(
            width: 56,
            height: 56,
            child: IconButton(
              tooltip: '뒤로가기',
              onPressed: onBack,
              icon: SvgPicture.asset('assets/icons/quiz_back.svg'),
            ),
          ),
        ),
        if (current != null && total != null)
          Semantics(
            label: '$total문제 중 $current번째 문제',
            child: Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: '$current',
                    style: AppTextStyle.semiBold(18, 26.1),
                  ),
                  TextSpan(
                    text: ' / $total',
                    style: AppTextStyle.medium(
                      18,
                      26.1,
                    ).copyWith(color: AppColor.disabledText),
                  ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}
