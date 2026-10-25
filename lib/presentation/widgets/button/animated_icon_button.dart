import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:iquiz/core/constants/app_color.dart';
import 'package:iquiz/core/services/bounce_tapper.dart';

class AnimatedIconButton extends StatelessWidget {
  const AnimatedIconButton({
    super.key,
    required this.onTap,
    required this.iconPath,
    this.iconColor = AppColor.iconColor,
    this.iconSize = 34,
    this.dimension = 48,
  });

  final VoidCallback onTap;
  final String iconPath;
  final Color iconColor;
  final double iconSize;
  final double dimension;

  @override
  Widget build(BuildContext context) {
    final highlightBorderRadius = dimension / 2;
    return BounceTapper(
      onTap: onTap,
      highlightBorderRadius: BorderRadius.circular(highlightBorderRadius),
      highlightColor: AppColor.splashBackground,
      child: SizedBox.square(
        dimension: dimension,
        child: Center(
          child: SvgPicture.asset(
            iconPath,
            width: iconSize,
            height: iconSize,
            colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
          ),
        ),
      ),
    );
  }
}
