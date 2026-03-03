import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color _primary = Color(0xFF1A227F);
  static const Color _lightBg = Color(0xFFF6F6F8);
  static const Color _darkBg = Color(0xFF121320);
  static const Color _surfaceLight = Colors.white;
  static const Color _surfaceDark = Color(0xFF1A1D2E);
  static const Color _textOnLight = Color(0xFF0F172A);
  static const Color _textOnDark = Color(0xFFF1F5F9);

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: _primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: _primary,
      onPrimary: Colors.white,
      surface: _surfaceLight,
      onSurface: _textOnLight,
    );

    final baseText = Typography.blackCupertino;
    final headingStyle = baseText.titleLarge?.copyWith(
      fontFamily: 'Inter',
      color: _textOnLight,
      fontWeight: FontWeight.w700,
      letterSpacing: -0.2,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: _lightBg,
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
      fontFamily: 'Inter',
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.light,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: const AppBarTheme(
        backgroundColor: _lightBg,
        foregroundColor: _textOnLight,
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: _surfaceLight,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _textOnLight,
          side: BorderSide(color: _primary.withValues(alpha: 0.2), width: 1),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primary,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceLight,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _primary.withValues(alpha: 0.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _primary, width: 1.2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFFEFF1F5),
        selectedColor: _primary.withValues(alpha: 0.15),
        labelStyle: const TextStyle(color: _textOnLight, fontFamily: 'Inter'),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _surfaceLight,
        indicatorColor: _primary.withValues(alpha: 0.15),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: _primary,
        circularTrackColor: _primary.withValues(alpha: 0.2),
      ),
    );
  }

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: _primary,
      brightness: Brightness.dark,
    ).copyWith(
      primary: _primary,
      onPrimary: Colors.white,
      surface: _surfaceDark,
      onSurface: _textOnDark,
    );

    final baseText = Typography.whiteCupertino;
    final headingStyle = baseText.titleLarge?.copyWith(
      fontFamily: 'Inter',
      color: _textOnDark,
      fontWeight: FontWeight.w700,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: _darkBg,
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
          color: const Color(0xFF94A3B8),
        ),
      ),
      fontFamily: 'Inter',
      cupertinoOverrideTheme: const CupertinoThemeData(
        brightness: Brightness.dark,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      appBarTheme: const AppBarTheme(
        backgroundColor: _darkBg,
        foregroundColor: _textOnDark,
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        color: _surfaceDark,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _textOnDark,
          side: BorderSide(color: _primary.withValues(alpha: 0.3)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF93A4FF),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x33121320),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _primary.withValues(alpha: 0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: _primary, width: 1.2),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: const Color(0xFF23283D),
        selectedColor: _primary.withValues(alpha: 0.35),
        labelStyle: const TextStyle(color: _textOnDark, fontFamily: 'Inter'),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: _darkBg,
        indicatorColor: _primary.withValues(alpha: 0.3),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primary,
        foregroundColor: Colors.white,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: _primary,
        circularTrackColor: _primary.withValues(alpha: 0.25),
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
