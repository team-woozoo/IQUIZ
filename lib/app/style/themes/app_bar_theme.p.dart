part of '../app_theme.dart';

abstract final class _AppBarTheme {
  static const light = AppBarTheme(
    foregroundColor: AppColor.white,
    backgroundColor: AppColor.white,
    systemOverlayStyle: SystemUiOverlayStyle.dark,
    elevation: 0,
    scrolledUnderElevation: 0,
    centerTitle: false,
  );
}
