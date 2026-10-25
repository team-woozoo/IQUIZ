import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iquiz/core/constants/app_color.dart';

part 'themes/app_bar_theme.p.dart';

abstract final class AppTheme {
  static final light = ThemeData(
    fontFamily: 'pretendard',
    appBarTheme: _AppBarTheme.light,
    splashFactory: NoSplash.splashFactory,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(elevation: 0),
  );
}
