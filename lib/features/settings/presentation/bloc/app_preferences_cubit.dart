import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';

class AppPreferencesState {
  const AppPreferencesState({
    this.themeMode = ThemeMode.system,
    this.fontScale = 1.0,
    this.lineHeight = 1.35,
  });

  final ThemeMode themeMode;
  final double fontScale;
  final double lineHeight;

  AppPreferencesState copyWith({
    ThemeMode? themeMode,
    double? fontScale,
    double? lineHeight,
  }) {
    return AppPreferencesState(
      themeMode: themeMode ?? this.themeMode,
      fontScale: fontScale ?? this.fontScale,
      lineHeight: lineHeight ?? this.lineHeight,
    );
  }
}

class AppPreferencesCubit extends Cubit<AppPreferencesState> {
  AppPreferencesCubit(this._settingsBox) : super(const AppPreferencesState()) {
    _load();
  }

  final Box _settingsBox;

  static const _themeModeKey = 'theme_mode';
  static const _fontScaleKey = 'font_scale';
  static const _lineHeightKey = 'line_height';

  void _load() {
    final storedTheme = _settingsBox.get(_themeModeKey)?.toString() ?? 'system';
    final storedFontScale = (_settingsBox.get(_fontScaleKey) as num?)?.toDouble() ?? 1.0;
    final storedLineHeight =
        (_settingsBox.get(_lineHeightKey) as num?)?.toDouble() ?? 1.35;
    emit(
      AppPreferencesState(
        themeMode: _themeModeFromString(storedTheme),
        fontScale: storedFontScale.clamp(0.85, 1.4),
        lineHeight: storedLineHeight.clamp(1.1, 2.0),
      ),
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _settingsBox.put(_themeModeKey, mode.name);
    emit(state.copyWith(themeMode: mode));
  }

  Future<void> setFontScale(double value) async {
    final clamped = value.clamp(0.85, 1.4);
    await _settingsBox.put(_fontScaleKey, clamped);
    emit(state.copyWith(fontScale: clamped));
  }

  Future<void> setLineHeight(double value) async {
    final clamped = value.clamp(1.1, 2.0);
    await _settingsBox.put(_lineHeightKey, clamped);
    emit(state.copyWith(lineHeight: clamped));
  }

  ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
