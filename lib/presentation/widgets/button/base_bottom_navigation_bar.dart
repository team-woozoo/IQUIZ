import 'package:flutter/material.dart';
import 'package:inspire_blur/inspire_blur.dart';
import 'package:iquiz/app/style/app_text_style.dart';
import 'package:iquiz/core/constants/app_color.dart';
import 'package:iquiz/core/services/app_size.dart';
import 'package:iquiz/core/services/bounce_tapper.dart';

class BaseBottomNavigationBar extends StatelessWidget {
  const BaseBottomNavigationBar._({
    super.key,
    required this.btnText,
    required this.onBtnClicked,
    required this.isDividedBtnFormat,
    this.backgroundColor,
    this.leftBtnText,
    this.onLeftBtnClicked,
    this.buttonKey,
    this.leftButtonKey,
  });

  /// 콜백을 null로 전달하면 버튼을 비활성화
  factory BaseBottomNavigationBar.singleBtn({
    Key? key,
    required String btnText,
    required VoidCallback? onBtnClicked,
    Color? backgroundColor,
    Key? buttonKey,
  }) => BaseBottomNavigationBar._(
    key: key,
    btnText: btnText,
    onBtnClicked: onBtnClicked,
    backgroundColor: backgroundColor,
    buttonKey: buttonKey,
    isDividedBtnFormat: false,
  );

  /// 왼쪽 보조 버튼과 오른쪽 주요 버튼에 필요한 값을 각각 받음
  factory BaseBottomNavigationBar.dividedBtn({
    Key? key,
    required String leftBtnText,
    required String rightBtnText,
    required VoidCallback? onLeftBtnClicked,
    required VoidCallback? onRightBtnClicked,
    Key? leftButtonKey,
    Key? rightButtonKey,
    Color? backgroundColor,
  }) => BaseBottomNavigationBar._(
    key: key,
    isDividedBtnFormat: true,
    leftBtnText: leftBtnText,
    btnText: rightBtnText,
    onLeftBtnClicked: onLeftBtnClicked,
    onBtnClicked: onRightBtnClicked,
    leftButtonKey: leftButtonKey,
    buttonKey: rightButtonKey,
    backgroundColor: backgroundColor,
  );

  final String btnText;
  final VoidCallback? onBtnClicked;
  final bool isDividedBtnFormat;
  final Color? backgroundColor;
  final String? leftBtnText;
  final VoidCallback? onLeftBtnClicked;
  final Key? buttonKey;
  final Key? leftButtonKey;

  static double get overlayHeight => ((AppSize.bottomInset + 10) * 2) + 52;

  @override
  Widget build(BuildContext context) {
    final bottomInsetOverlay = AppSize.bottomInset + 10;
    final primary = _BottomNavigationButton(
      key: buttonKey,
      title: btnText,
      onTap: onBtnClicked,
      backgroundColor: backgroundColor ?? AppColor.brandColor,
      foregroundColor: AppColor.white,
    );
    return SizedBox(
      height: overlayHeight,
      child: Stack(
        children: [
          Positioned.fill(
            child: IgnorePointer(
              child: Inspire.backdropBlur(
                config: InspireBlurConfig.bottomToTop(
                  sigma: 16,
                  fadeCurve: Curves.linear,
                ),
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [AppColor.lightTransparent, AppColor.white],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 16,
            right: 16,
            bottom: bottomInsetOverlay,
            child: !isDividedBtnFormat
                ? primary
                : Row(
                    children: [
                      Expanded(
                        child: _BottomNavigationButton(
                          key: leftButtonKey,
                          title: leftBtnText!,
                          onTap: onLeftBtnClicked,
                          backgroundColor: AppColor.splashBackground,
                          foregroundColor: AppColor.dark,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: primary),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

class _BottomNavigationButton extends StatelessWidget {
  const _BottomNavigationButton({
    super.key,
    required this.title,
    required this.onTap,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  final String title;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    enabled: onTap != null,
    child: BounceTapper(
      enable: onTap != null,
      highlightColor: AppColor.darkTransparent,
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(
            title,
            style: AppTextStyle.title4.copyWith(color: foregroundColor),
          ),
        ),
      ),
    ),
  );
}
