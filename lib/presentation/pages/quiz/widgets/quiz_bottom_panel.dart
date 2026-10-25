import 'package:flutter/material.dart';
import 'package:iquiz/core/constants/app_color.dart';

class QuizBottomPanel extends StatelessWidget {
  const QuizBottomPanel({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    decoration: const BoxDecoration(
      color: AppColor.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      boxShadow: [
        BoxShadow(
          color: Color(0x1A000000),
          offset: Offset(0, -6),
          blurRadius: 12,
        ),
      ],
    ),
    child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: child,
    ),
  );
}
