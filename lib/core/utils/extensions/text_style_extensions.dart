import 'package:flutter/material.dart';

extension TextStyleExtension on TextStyle {
  TextStyle weight(
    double w, {
    Color? color,
    double? fontSize,
    double? height,
    double? letterSpacing,
    String? fontFamily,
  }) =>
      copyWith(
        fontVariations: [FontVariation('wght', w)],
        color: color,
        fontSize: fontSize,
        height: height,
        letterSpacing: letterSpacing,
        fontFamily: fontFamily,
      );
}
