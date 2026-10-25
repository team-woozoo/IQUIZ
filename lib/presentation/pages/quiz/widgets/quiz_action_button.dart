import 'package:flutter/material.dart';
import 'package:iquiz/app/style/app_text_style.dart';
import 'package:iquiz/core/constants/app_color.dart';

class QuizActionButton extends StatelessWidget {
  const QuizActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.secondary = false,
    this.color = AppColor.brandColor,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool secondary;
  final Color color;

  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: onPressed,
    style: FilledButton.styleFrom(
      backgroundColor: secondary ? AppColor.splashBackground : color,
      foregroundColor: secondary ? AppColor.dark : AppColor.white,
      minimumSize: const Size.fromHeight(52.4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: AppTextStyle.semiBold(16, 22.4),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
    ),
    child: Text(label, textAlign: TextAlign.center),
  );
}
