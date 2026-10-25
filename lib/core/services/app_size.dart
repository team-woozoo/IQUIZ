import 'dart:math';

import 'package:flutter/material.dart';
import 'package:iquiz/core/logger/log.dart';

abstract final class AppSize {
  static late double topInset;
  static late double bottomInset;
  static late double _screenWidth;
  static late double _screenHeight;
  static late double originScreenWidth;
  static late double originScreenHeight;

  static bool _isInitialized = false;

  // (412 * 915)
  static double ratioHeight(double givenHeight) =>
      (givenHeight / 915) * _screenHeight;

  static double ratioWidth(double givenWidth) =>
      (givenWidth / 412) * _screenWidth;

  static double pxToRatio(double pxHeight) {
    return min(1.0, pxHeight / _screenHeight);
  }

  static void init(BuildContext context) {
    if (_isInitialized) return;
    topInset = MediaQuery.paddingOf(context).top;
    bottomInset = MediaQuery.paddingOf(context).bottom;
    _screenWidth = MediaQuery.sizeOf(context).width;
    _screenHeight = MediaQuery.sizeOf(context).height;
    originScreenWidth = MediaQuery.sizeOf(context).width;
    originScreenHeight = MediaQuery.sizeOf(context).height;

    Log.i('bottom inset: $bottomInset');

    _isInitialized = true;
  }
}
