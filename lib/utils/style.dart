import 'package:flutter/material.dart';

class Style {
  static const TextStyle loginTextStyle = const TextStyle(
    inherit: false,
    fontSize: 18.0,
    fontWeight: FontWeight.w700,
    color: Colors.white,
    textBaseline: TextBaseline.alphabetic,
  );

  static const TextStyle inputTextStyle = const TextStyle(
    inherit: false,
    fontSize: 18.0,
    color: Colors.white,
    textBaseline: TextBaseline.alphabetic,
  );

  static const TextStyle tipsTextStyle = const TextStyle(
      fontSize: 14.0,
      color: Colors.white
  );
  static const Color COLOR_THEME = const Color(0xFF029de0);
  static const Color COLOR_BACKGROUND = const Color(0xfff5f5f5);
  static const double BAR_HEIGHT = 20.0;
}