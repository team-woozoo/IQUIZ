import 'package:flutter/material.dart';
import 'package:iquiz/core/constants/app_color.dart';

class BaseAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BaseAppBar({
    super.key,
    this.title,
    this.actions,
    this.color = AppColor.white,
    this.textColor = AppColor.dark,
    this.leading,
  });

  final Widget? title;
  final List<Widget>? actions;
  final Color color;
  final Color textColor;
  final Widget? leading;

  static const double appbarHeight = 56;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: color,
      foregroundColor: textColor,
      elevation: 0,
      scrolledUnderElevation: 0,
      toolbarHeight: appbarHeight,
      automaticallyImplyLeading: false,
      leadingWidth: 56,
      leading: leading,
      titleSpacing: 0,
      title: title,
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(appbarHeight);
}
