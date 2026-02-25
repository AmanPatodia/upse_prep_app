import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const _seed = Color(0xFF0E7490);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.light,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: Typography.blackCupertino,
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.light,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      cardTheme: const CardThemeData(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: Brightness.dark,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      textTheme: Typography.whiteCupertino,
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.dark,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      cardTheme: const CardThemeData(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
    );
  }
}
