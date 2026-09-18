import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  static const _keyToken = 'auth_token';
  static const _keyRefreshToken = 'auth_refresh_token';
  static const _keyUserId = 'user_id';
  static const _keyFarmId = 'farm_id';
  static const _keyProfile = 'profile_json';
  static const _keyPinHash = 'pin_hash';
  static const _keyPinSalt = 'pin_salt';
  static const _keyThemeMode = 'theme_mode';
  static const _keySyncCursor = 'sync_cursor';

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

  // Access/refresh token pair — the access token is a short-lived JWT sent as
  // `Authorization: Bearer`, the refresh token a long-lived, single-use
  // opaque string exchanged at /api/mobile/refresh (rotates on every use, so
  // only ever the *latest* one is kept).
  static Future<void> saveToken(String token) =>
      _storage.write(key: _keyToken, value: token);
  static Future<String?> getToken() => _storage.read(key: _keyToken);
  static Future<void> clearToken() => _storage.delete(key: _keyToken);

  static Future<void> saveRefreshToken(String token) =>
      _storage.write(key: _keyRefreshToken, value: token);
  static Future<String?> getRefreshToken() => _storage.read(key: _keyRefreshToken);

  // User / Farm IDs
  static Future<void> saveUserId(String id) =>
      _storage.write(key: _keyUserId, value: id);
  static Future<String?> getUserId() => _storage.read(key: _keyUserId);

  static Future<void> saveFarmId(String id) =>
      _storage.write(key: _keyFarmId, value: id);
  static Future<String?> getFarmId() => _storage.read(key: _keyFarmId);
  static Future<void> clearFarmId() => _storage.delete(key: _keyFarmId);

  static Future<void> saveUserEmail(String email) =>
      _storage.write(key: _keyProfile, value: email);
  static Future<String?> getUserEmail() => _storage.read(key: _keyProfile);

  // Delete only authentication-owned keys. Other secure-storage users, such
  // as the offline sync queue, must survive logout and token expiry.
  static Future<void> clearAuth() async {
    await Future.wait([
      _storage.delete(key: _keyToken),
      _storage.delete(key: _keyRefreshToken),
      _storage.delete(key: _keyUserId),
      _storage.delete(key: _keyFarmId),
      _storage.delete(key: _keyProfile),
    ]);
  }

  // Wipes every key this store holds — PIN, auth, theme, everything. Used
  // only by the debug-only "reset app for testing" action; a real signed-in
  // user should never hit this (clearAuth()/clearPin() are the targeted,
  // user-facing equivalents).
  static Future<void> deleteAll() => _storage.deleteAll();

  // GET /api/mobile/sync's cursor — an opaque "as of" timestamp string the
  // server hands back and expects verbatim on the next call, not something
  // this app parses or computes. Null means "never synced", which the
  // server treats as "send everything".
  static Future<void> saveSyncCursor(String cursor) =>
      _storage.write(key: _keySyncCursor, value: cursor);
  static Future<String?> getSyncCursor() => _storage.read(key: _keySyncCursor);

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.trim().isNotEmpty;
  }

  // Theme mode ('light' | 'dark') — stored alongside the PIN/profile since
  // this is the same on-device keystore-backed store the app already uses
  // for every other small piece of local preference state.
  static Future<void> saveThemeMode(String mode) =>
      _storage.write(key: _keyThemeMode, value: mode);
  static Future<String?> getThemeMode() => _storage.read(key: _keyThemeMode);
}
