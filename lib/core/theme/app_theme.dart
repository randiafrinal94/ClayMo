import 'package:flutter/material.dart';

import 'clay_colors.dart';

abstract final class AppTheme {
  static const fontFamily = 'Fredoka';

  static ThemeData light() {
    final scheme = ColorScheme.fromSeed(
      seedColor: ClayColors.pink.base,
      brightness: Brightness.light,
      surface: Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: fontFamily,
      // Latar digambar oleh ClayBackground; Scaffold dibiarkan transparan.
      scaffoldBackgroundColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      textTheme: Typography.blackMountainView.apply(
        fontFamily: fontFamily,
        bodyColor: ClayColors.text,
        displayColor: ClayColors.text,
      ),
    );
  }
}
