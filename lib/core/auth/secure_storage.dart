import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static const _keyToken = 'auth_token';
  static const _keyUserId = 'user_id';
  static const _keyFarmId = 'farm_id';
  static const _keyProfile = 'profile_json';
  static const _keyPinHash = 'pin_hash';
  static const _keyPinSalt = 'pin_salt';

  // Local app-lock PIN — replaces server login. The salt is random per
  // device/install; OS keychain-backed storage (already used for the old
  // JWT) makes a salted SHA-256 hash adequate for a local device lock, no
  // need for a slower KDF since this isn't protecting an internet-facing
  // credential.
  static Future<void> savePin(String pin) async {
    final salt = _generateSalt();
    final hash = _hashPin(pin, salt);
    await Future.wait([
      _storage.write(key: _keyPinSalt, value: salt),
      _storage.write(key: _keyPinHash, value: hash),
    ]);
  }

  static Future<bool> hasPin() async {
    final hash = await _storage.read(key: _keyPinHash);
    return hash != null && hash.isNotEmpty;
  }

  static Future<bool> verifyPin(String pin) async {
    final salt = await _storage.read(key: _keyPinSalt);
    final storedHash = await _storage.read(key: _keyPinHash);
    if (salt == null || storedHash == null) return false;
    return _hashPin(pin, salt) == storedHash;
  }

  static Future<void> clearPin() async {
    await Future.wait([
      _storage.delete(key: _keyPinHash),
      _storage.delete(key: _keyPinSalt),
    ]);
  }

  static String _generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  static String _hashPin(String pin, String salt) {
    final digest = sha256.convert(utf8.encode('$salt:$pin'));
    return digest.toString();
  }

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
