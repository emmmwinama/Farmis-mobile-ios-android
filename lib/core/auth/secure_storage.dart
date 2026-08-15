import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static const _keyToken = 'auth_token';
  static const _keyUserId = 'user_id';
  static const _keyFarmId = 'farm_id';
  static const _keyProfile = 'profile_json';

  // Token
  static Future<void> saveToken(String token) =>
      _storage.write(key: _keyToken, value: token);
  static Future<String?> getToken() => _storage.read(key: _keyToken);
  static Future<void> clearToken() => _storage.delete(key: _keyToken);

  // User / Farm IDs
  static Future<void> saveUserId(String id) =>
      _storage.write(key: _keyUserId, value: id);
  static Future<String?> getUserId() => _storage.read(key: _keyUserId);

  static Future<void> saveFarmId(String id) =>
      _storage.write(key: _keyFarmId, value: id);
  static Future<String?> getFarmId() => _storage.read(key: _keyFarmId);
  static Future<void> clearFarmId() => _storage.delete(key: _keyFarmId);

  static Future<void> saveProfileJson(String json) =>
      _storage.write(key: _keyProfile, value: json);
  static Future<String?> getProfileJson() => _storage.read(key: _keyProfile);

  // Delete only authentication-owned keys. Other secure-storage users, such
  // as the offline sync queue, must survive logout and token expiry.
  static Future<void> clearAuth() async {
    await Future.wait([
      _storage.delete(key: _keyToken),
      _storage.delete(key: _keyUserId),
      _storage.delete(key: _keyFarmId),
      _storage.delete(key: _keyProfile),
    ]);
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.trim().isNotEmpty;
  }
}
