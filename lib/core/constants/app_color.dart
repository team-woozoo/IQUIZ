import 'package:flutter/material.dart';

abstract final class AppColor {
  static const white = Color(0xFFFFFFFF);
  static const white87 = Color(0xDEFFFFFF);

  static const dark = Color(0xFF111111);
  static const iconColor = Color(0xFF2A2A37);
  static const brandColor = Color(0xFF9433FC);
  static const primaryAction = brandColor;
  static const secondarybrandColor = Color(0xFFA877DC);
  static const secondaryText = Color(0xFF767676);
  static const disabledText = Color(0xFF999999);
  static const surfaceSubtle = Color(0xFFF7F7FB);
  static const segmentedBackground = Color(0xFFF1F3F6);
  static const success = Color(0xFF12A06A);
  static const successSubtle = Color(0xFFE7F5F0);
  static const quizCorrectBackground = Color(0xFFE9F7F0);
  static const quizWrongBackground = Color(0xFFFDEFEF);
  static const optionNumber = Color(0xFFBCBCBC);
  static const danger = Color(0xFFE5484D);
  static const dangerSubtle = Color(0xFFFCeded);
  static const neutralSubtle = Color(0xFFF1F1F1);
  static const divider = Color(0xFFE5E5EC);
  static const tertiaryText = Color(0xFF505050);
  static const reviewCoverBacking = Color(0xFFD8D8D8);
  static const reviewCoverMiddle = Color(0xFFF1F1F1);

  static const darkTransparent = Color(0x00000000);
  static const lightTransparent = Color(0x00FFFFFF);
  static const backgroundLightColor = grey50;
  static const backgroundDarkColor = Color(0xFF121212);
  static final statusBarLightColor = backgroundLightColor.withValues(
    alpha: 0.5,
  );
  static const statusBarDarkColor = backgroundDarkColor;

  static const skeletonColor = Color(0xFFE2E2E2);
  static const warningColor = Color(0xFFFFB300);
  static const borderColor = Color(0xFFE3E7EC);

  static const splashBackground = Color(0xFFF1F1F5);

  static const youtubeBannerGradientColor = Color(0xFF000F18);

  // Logo
  static const flutterDark = Color(0xFF02569B); // 로고의 가장 짙은 파랑
  static const flutterLight = Color(0xFF0175C2); // 로고의 중간 밝기 파랑
  static const flutterAccent = Color(0xFF40C4FF); // 로고의 가장 밝은 하늘색

  // Steps
  static const processInitializing = grey400;
  static const processInspecting = Color(0xFF81D4FA);
  static const processTranslatingMetadata = Color(0xFF03A9F4);
  static const processDownloading = blue700;
  static const processTranscribing = Color(0xFF3F51B5);
  static const processTranslatingText = Color(0xFF9C27B0);
  static const processCompleted = Color(0xFF00C853);
  static const processFailed = red400;

  // Grey
  static const grey50 = Color(0xFFFAFAFA);
  static const grey100 = Color(0xFFF5F5F5);
  static const grey200 = Color(0xFFEEEEEE);
  static const grey300 = Color(0xFFE0E0E0);
  static const grey400 = Color(0xFFBDBDBD);
  static const grey = Color(0xFF9E9E9E);
  static const grey600 = Color(0xFF757575);
  static const grey700 = Color(0xFF616161);
  static const grey800 = Color(0xFF424242);
  static const grey850 = Color(0xFF393939);
  static const grey900 = Color(0xFF212121);

  // Blue
  static const blue50 = Color(0xFFE3F2FD);
  static const blue100 = Color(0xFFBBDEFB);
  static const blue200 = Color(0xFF90CAF9);
  static const blue300 = Color(0xFF64B5F6);
  static const blue400 = Color(0xFF42A5F5);
  static const blue = Color(0xFF2196F3);
  static const blue600 = Color(0xFF1E88E5);
  static const blue700 = Color(0xFF1976D2);
  static const blue800 = Color(0xFF1565C0);
  static const blue900 = Color(0xFF0D47A1);

  // Red
  static const red50 = Color(0xFFFFEBEE);
  static const red100 = Color(0xFFFFCDD2);
  static const red200 = Color(0xFFEF9A9A);
  static const red300 = Color(0xFFE57373);
  static const red400 = Color(0xFFEF5350);
  static const red = Color(0xFFF44336);
  static const red600 = Color(0xFFE53935);
  static const red700 = Color(0xFFD32F2F);
  static const red800 = Color(0xFFC62828);
  static const red900 = Color(0xFFB71C1C);
}
