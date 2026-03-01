import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

class AppLogger {
  AppLogger._();

  static const bool _enabled = bool.fromEnvironment(
    'ENABLE_APP_LOGS',
    defaultValue: true,
  );

  static void debug(String tag, String message) {
    _log('DEBUG', tag, message);
  }

  static void info(String tag, String message) {
    _log('INFO', tag, message);
  }

  static void warn(String tag, String message) {
    _log('WARN', tag, message);
  }

  static void error(
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      'ERROR',
      tag,
      message,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void _log(
    String level,
    String tag,
    String message, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (!_enabled) return;
    final line = '[$level][$tag] $message';
    developer.log(
      line,
      name: 'upse_prep_app',
      error: error,
      stackTrace: stackTrace,
    );
    if (kDebugMode) {
      // Keep a plain print line too so logs are easy to spot in logcat filters.
      // ignore: avoid_print
      print(line);
    }
  }
}
