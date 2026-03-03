import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // Theme 1: Collector's Office (default light)
  static const Color _oxfordBlue = Color(0xFF002147);
  static const Color _antiqueGold = Color(0xFFD4AF37);
  static const Color _offWhite = Color(0xFFF8F9FA);
  static const Color _surfaceLight = Color(0xFFFFFFFF);
  static const Color _textOnLight = Color(0xFF111827);

  // Theme 3: Midnight Aspirant (dark)
  static const Color _charcoal = Color(0xFF121212);
  static const Color _slateBlue = Color(0xFF37474F);
  static const Color _amber = Color(0xFFFFC107);
  static const Color _surfaceDark = Color(0xFF1A1A1A);

  static ThemeData get light {
    const scheme = ColorScheme(
      brightness: Brightness.light,
      primary: _oxfordBlue,
      onPrimary: Colors.white,
      secondary: _antiqueGold,
      onSecondary: Colors.black,
      error: Color(0xFFB3261E),
      onError: Colors.white,
      surface: _surfaceLight,
      onSurface: _textOnLight,
    );

    final baseText = Typography.blackCupertino;
    final headingStyle = baseText.titleLarge?.copyWith(
      fontFamily: 'Inter',
      color: _oxfordBlue,
      fontWeight: FontWeight.w700,
      letterSpacing: 0.2,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: _offWhite,
      textTheme: baseText.copyWith(
        displayLarge: headingStyle,
        displayMedium: headingStyle,
        displaySmall: headingStyle,
        headlineLarge: headingStyle,
        headlineMedium: headingStyle,
        headlineSmall: headingStyle,
        titleLarge: headingStyle,
        titleMedium: headingStyle?.copyWith(fontSize: 18),
        titleSmall: headingStyle?.copyWith(fontSize: 16),
        bodyLarge: baseText.bodyLarge?.copyWith(
          fontFamily: 'Inter',
          color: _textOnLight,
          height: 1.35,
        ),
        bodyMedium: baseText.bodyMedium?.copyWith(
          fontFamily: 'Inter',
          color: _textOnLight,
          height: 1.35,
        ),
        bodySmall: baseText.bodySmall?.copyWith(
          fontFamily: 'Inter',
          color: _textOnLight.withValues(alpha: 0.8),
        ),
        labelLarge: baseText.labelLarge?.copyWith(
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.light,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: const AppBarTheme(
        backgroundColor: _offWhite,
        foregroundColor: _oxfordBlue,
        centerTitle: false,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: _surfaceLight,
        elevation: 3,
        shadowColor: Colors.black.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _antiqueGold,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _oxfordBlue,
          side: const BorderSide(color: _oxfordBlue, width: 1.2),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _oxfordBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceLight,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: _oxfordBlue.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _oxfordBlue, width: 1.4),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _offWhite,
        selectedColor: _antiqueGold.withValues(alpha: 0.2),
        labelStyle: const TextStyle(color: _textOnLight, fontFamily: 'Inter'),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: _surfaceLight,
        indicatorColor: Color(0x26D4AF37),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _antiqueGold,
        foregroundColor: Colors.black,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _antiqueGold,
        circularTrackColor: Color(0x22002147),
      ),
    );
  }

  static ThemeData get dark {
    const scheme = ColorScheme(
      brightness: Brightness.dark,
      primary: _amber,
      onPrimary: Colors.black,
      secondary: _slateBlue,
      onSecondary: Colors.white,
      error: Color(0xFFF2B8B5),
      onError: Colors.black,
      surface: _surfaceDark,
      onSurface: Colors.white,
    );

    final baseText = Typography.whiteCupertino;
    final headingStyle = baseText.titleLarge?.copyWith(
      fontFamily: 'Inter',
      color: Colors.white,
      fontWeight: FontWeight.w700,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: _charcoal,
      textTheme: baseText.copyWith(
        displayLarge: headingStyle,
        displayMedium: headingStyle,
        displaySmall: headingStyle,
        headlineLarge: headingStyle,
        headlineMedium: headingStyle,
        headlineSmall: headingStyle,
        titleLarge: headingStyle,
        titleMedium: headingStyle?.copyWith(fontSize: 18),
        titleSmall: headingStyle?.copyWith(fontSize: 16),
        bodyLarge: baseText.bodyLarge?.copyWith(fontFamily: 'Inter', height: 1.35),
        bodyMedium: baseText.bodyMedium?.copyWith(fontFamily: 'Inter', height: 1.35),
        bodySmall: baseText.bodySmall?.copyWith(
          fontFamily: 'Inter',
          color: Colors.white70,
        ),
      ),
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.dark,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: const AppBarTheme(
        backgroundColor: _charcoal,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: _surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _amber,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: _slateBlue),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _amber,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
      ),
      chipTheme: const ChipThemeData(
        backgroundColor: _slateBlue,
        selectedColor: Color(0x66FFC107),
        labelStyle: TextStyle(color: Colors.white, fontFamily: 'Inter'),
      ),
      navigationBarTheme: const NavigationBarThemeData(
        backgroundColor: _charcoal,
        indicatorColor: Color(0x33FFC107),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _amber,
        foregroundColor: Colors.black,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _amber,
        circularTrackColor: Color(0x4437474F),
      ),
    );
  }

  // Smart theming: dark mode after 7 PM and before 6 AM.
  static ThemeMode smartMode([DateTime? now]) {
    final hour = (now ?? DateTime.now()).hour;
    if (hour >= 19 || hour < 6) return ThemeMode.dark;
    return ThemeMode.light;
  }
}
