import 'package:flutter/material.dart';
import 'package:iquiz/core/constants/app_color.dart';

abstract final class AppTextStyle {
  /// [height]는 픽셀 단위의 행 높이이며, Flutter의 배율로 변환
  static TextStyle pretendardStyle(double size, double? height) => TextStyle(
    color: AppColor.dark,
    fontFamily: 'pretendard',
    fontWeight: FontWeight.w400,
    leadingDistribution: TextLeadingDistribution.even,
    letterSpacing: -0.025 * size,
    fontSize: size,
    height: height == null ? null : height / size,
  );

  static TextStyle reqular(double size, double? height) =>
      pretendardStyle(size, height).copyWith(fontWeight: FontWeight.w400);

  static TextStyle medium(double size, double? height) =>
      pretendardStyle(size, height).copyWith(fontWeight: FontWeight.w500);

  static TextStyle semiBold(double size, double? height) =>
      pretendardStyle(size, height).copyWith(fontWeight: FontWeight.w600);

  static TextStyle bold(double size, double? height) =>
      pretendardStyle(size, height).copyWith(fontWeight: FontWeight.w700);

  // Headline: SemiBold / Headline 1은 130%, 나머지는 140%.
  static final TextStyle headline1 = semiBold(36, 36 * 1.3);
  static final TextStyle headline2 = semiBold(32, 32 * 1.4);
  static final TextStyle headline3 = semiBold(28, 28 * 1.4);

  // Title: SemiBold / 140%.
  static final TextStyle title1 = semiBold(24, 24 * 1.4);
  static final TextStyle title2 = semiBold(20, 20 * 1.4);
  static final TextStyle title3 = semiBold(18, 18 * 1.4);
  static final TextStyle title4 = semiBold(16, 16 * 1.4);

  // Body: SemiBold / 145%.
  static final TextStyle body1 = semiBold(15, 15 * 1.45);
  static final TextStyle body2 = semiBold(14, 14 * 1.45);
  static final TextStyle body3 = semiBold(13, 13 * 1.45);
  static final TextStyle body4 = semiBold(12, 12 * 1.45);

  // Btn 1·2: SemiBold / Btn 3·4·5: Medium.
  static final TextStyle btn1 = semiBold(16, 16 * 1.4);
  static final TextStyle btn2 = semiBold(15, 15 * 1.45);
  static final TextStyle btn3 = medium(14, 14 * 1.45);
  static final TextStyle btn4 = medium(13, 13 * 1.45);
  static final TextStyle btn5 = medium(12, 12 * 1.45);

  // 이전 스타일 이름과의 호환을 위한 대응 스타일
  static final TextStyle highlight = headline2;
  static final TextStyle newBody = body1;
  static final TextStyle alert1 = body4;
  static final TextStyle alert2 = pretendardStyle(12, 12 * 1.45);
}
