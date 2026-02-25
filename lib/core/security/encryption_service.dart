import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class EncryptionService {
  const EncryptionService({FlutterSecureStorage? secureStorage})
    : _secureStorage = secureStorage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _secureStorage;

  static const _tokenKey = 'private_auth_token';

  Future<void> saveAuthToken(String token) =>
      _secureStorage.write(key: _tokenKey, value: token);

  Future<String?> getAuthToken() => _secureStorage.read(key: _tokenKey);

  Future<void> clearAuthToken() => _secureStorage.delete(key: _tokenKey);
}
