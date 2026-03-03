import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';

import '../../../core/constants/app_constants.dart';
import '../domain/auth_models.dart';

abstract class AuthRepository {
  Future<String?> signup({
    required String name,
    required String identifier,
    required String password,
  });
  Future<AppUser?> login({
    required String identifier,
    required String password,
  });
  Future<bool> userExists(String identifier);
  Future<AppUser?> restoreSession();
  Future<void> clearSession();
}

class HiveAuthRepository implements AuthRepository {
  static const _passwordSalt = 'upsc_prep_private_salt_v1';
  static const _sessionKey = '__active_session__';
  static const _sessionTtl = Duration(hours: 6);

  final _emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  bool _isEmail(String input) => _emailRegex.hasMatch(input.trim());

  bool _isPhone(String input) {
    final raw = input.trim();
    if (raw.isEmpty) return false;
    if (!RegExp(r'^[0-9+\-\s()]+$').hasMatch(raw)) return false;

    var digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('00')) {
      digits = digits.substring(2);
    }

    if (digits.length == 10) return true;
    if (digits.length == 11 && digits.startsWith('0')) return true;
    if (digits.length == 12 && digits.startsWith('91')) return true;
    return false;
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  String _normalizePhone(String phone) {
    var digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('00')) {
      digits = digits.substring(2);
    }

    String? local10;
    if (digits.length == 10) {
      local10 = digits;
    } else if (digits.length == 11 && digits.startsWith('0')) {
      local10 = digits.substring(1);
    } else if (digits.length == 12 && digits.startsWith('91')) {
      local10 = digits.substring(2);
    }

    if (local10 != null) {
      return '+91$local10';
    }
    return phone.trim();
  }

  Set<String> _phoneKeys(String input) {
    final keys = <String>{};
    final raw = input.trim();
    if (raw.isEmpty) return keys;

    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return keys;

    keys.add(raw);
    keys.add(digits);
    keys.add(raw.toLowerCase());

    if (digits.length == 10) {
      keys.add('+91$digits');
      keys.add('0$digits');
      keys.add('91$digits');
    } else if (digits.length == 11 && digits.startsWith('0')) {
      final local10 = digits.substring(1);
      keys.add(local10);
      keys.add('+91$local10');
      keys.add('91$local10');
    } else if (digits.length == 12 && digits.startsWith('91')) {
      final local10 = digits.substring(2);
      keys.add(local10);
      keys.add('+91$digits');
      keys.add('0$local10');
      keys.add('91$local10');
    }

    return keys;
  }

  Set<String> _candidateKeys(String identifier) {
    final keys = <String>{identifier.trim(), identifier.trim().toLowerCase()};
    final parsed = _normalizeIdentifier(identifier);
    if (parsed.error != null) return keys;

    keys.add(parsed.normalized);
    if (parsed.type == 'phone') {
      keys.addAll(_phoneKeys(identifier));
      keys.addAll(_phoneKeys(parsed.normalized));
    }
    return keys;
  }

  ({String normalized, String type, String? error}) _normalizeIdentifier(
    String input,
  ) {
    final raw = input.trim();
    if (raw.isEmpty) {
      return (normalized: '', type: '', error: 'Email or phone is required.');
    }

    if (_isEmail(raw)) {
      return (normalized: _normalizeEmail(raw), type: 'email', error: null);
    }

    if (_isPhone(raw)) {
      return (normalized: _normalizePhone(raw), type: 'phone', error: null);
    }

    return (
      normalized: '',
      type: '',
      error: 'Enter a valid email or a valid 10-digit phone number.'
    );
  }

  String _hashPassword(String input) {
    final bytes = utf8.encode('$_passwordSalt:$input');
    return sha256.convert(bytes).toString();
  }

  Box get _box => Hive.box(AppConstants.authBox);

  @override
  Future<String?> signup({
    required String name,
    required String identifier,
    required String password,
  }) async {
    final normalized = _normalizeIdentifier(identifier);
    if (normalized.error != null) {
      return normalized.error;
    }

    if (await userExists(identifier)) {
      return 'An account with this email or phone already exists.';
    }

    final user = AppUser(
      name: name.trim(),
      identifier: normalized.normalized,
      identifierType: normalized.type,
      passwordHash: _hashPassword(password),
      createdAt: DateTime.now(),
    );

    await _box.put(normalized.normalized, user.toMap());
    return null;
  }

  @override
  Future<AppUser?> login({
    required String identifier,
    required String password,
  }) async {
    final normalized = _normalizeIdentifier(identifier);
    if (normalized.error != null) {
      return null;
    }

    Map<dynamic, dynamic>? rawMap;
    String? matchedKey;
    for (final key in _candidateKeys(identifier)) {
      final raw = _box.get(key);
      if (raw is Map) {
        rawMap = raw;
        matchedKey = key;
        break;
      }
    }

    if (rawMap == null) {
      return null;
    }

    final map = rawMap.cast<String, dynamic>();
    final user = AppUser.fromMap(map);
    final hashed = _hashPassword(password);
    if (user.passwordHash != hashed) {
      return null;
    }

    final sessionValue = user.identifier.isNotEmpty
        ? user.identifier
        : (matchedKey ?? normalized.normalized);
    await _box.put(_sessionKey, {
      'identifier': sessionValue,
      'loginAt': DateTime.now().toIso8601String(),
    });
    return user;
  }

  @override
  Future<bool> userExists(String identifier) async {
    for (final key in _candidateKeys(identifier)) {
      if (_box.containsKey(key)) return true;
    }
    return false;
  }

  @override
  Future<AppUser?> restoreSession() async {
    final stored = _box.get(_sessionKey);
    if (stored == null) {
      return null;
    }

    String? sessionIdentifier;
    DateTime? loginAt;

    if (stored is String && stored.trim().isNotEmpty) {
      // Legacy session format; expire it to enforce TTL behavior.
      await clearSession();
      return null;
    }

    if (stored is Map) {
      sessionIdentifier = (stored['identifier'] as String?)?.trim();
      loginAt = DateTime.tryParse((stored['loginAt'] as String?) ?? '');
    }

    if (sessionIdentifier == null || sessionIdentifier.isEmpty || loginAt == null) {
      await clearSession();
      return null;
    }

    if (DateTime.now().difference(loginAt) > _sessionTtl) {
      await clearSession();
      return null;
    }

    for (final key in _candidateKeys(sessionIdentifier)) {
      final raw = _box.get(key);
      if (raw is! Map) continue;
      return AppUser.fromMap(raw.cast<String, dynamic>());
    }

    return null;
  }

  @override
  Future<void> clearSession() async {
    await _box.delete(_sessionKey);
    final settingsBox = Hive.box(AppConstants.settingsBox);
    await settingsBox.put(AppConstants.onboardingSeenKey, false);
  }
}
