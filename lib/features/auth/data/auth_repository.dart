import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:hive/hive.dart';

import '../../../core/constants/app_constants.dart';
import '../domain/auth_models.dart';

abstract class AuthRepository {
  Future<String?> signup({
    required String name,
    required String email,
    required String password,
  });
  Future<AppUser?> login({required String email, required String password});
  Future<bool> userExists(String email);
}

class HiveAuthRepository implements AuthRepository {
  static const _passwordSalt = 'upsc_prep_private_salt_v1';

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  String _hashPassword(String input) {
    final bytes = utf8.encode('$_passwordSalt:$input');
    return sha256.convert(bytes).toString();
  }

  Box get _box => Hive.box(AppConstants.authBox);

  @override
  Future<String?> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    if (await userExists(normalizedEmail)) {
      return 'An account with this email already exists.';
    }

    final user = AppUser(
      name: name.trim(),
      email: normalizedEmail,
      passwordHash: _hashPassword(password),
      createdAt: DateTime.now(),
    );

    await _box.put(normalizedEmail, user.toMap());
    return null;
  }

  @override
  Future<AppUser?> login({
    required String email,
    required String password,
  }) async {
    final normalizedEmail = _normalizeEmail(email);
    final raw = _box.get(normalizedEmail);
    if (raw is! Map) {
      return null;
    }

    final map = raw.cast<String, dynamic>();
    final user = AppUser.fromMap(map);
    final hashed = _hashPassword(password);
    if (user.passwordHash != hashed) {
      return null;
    }

    return user;
  }

  @override
  Future<bool> userExists(String email) async {
    return _box.containsKey(_normalizeEmail(email));
  }
}
