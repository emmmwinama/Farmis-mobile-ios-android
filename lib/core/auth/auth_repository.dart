import 'dart:convert';

import '../api/api_client.dart';
import '../../models/auth_result.dart';
import 'secure_storage.dart';

class AuthRepository {
  Future<AuthResult> login(String email, String password) async {
    final response = await ApiClient.post('/mobile/login', {
      'email': email.trim().toLowerCase(),
      'password': password,
    });
    final result = AuthResult.fromJson(response.data as Map<String, dynamic>);

    await SecureStorage.clearAuth();
    await _persistAuthResult(result);

    return result;
  }

  Future<AuthResult?> loadStoredAuth() async {
    final json = await SecureStorage.getProfileJson();
    if (json == null) return null;

    try {
      return AuthResult.fromJson(
        jsonDecode(json) as Map<String, dynamic>,
      );
    } catch (_) {
      await SecureStorage.clearAuth();
      return null;
    }
  }

  Future<AuthResult?> refreshProfile() async {
    final token = await SecureStorage.getToken();
    if (token == null) return null;

    final response = await ApiClient.get('/mobile/profile');
    final result = AuthResult.fromJsonWithToken(
      response.data as Map<String, dynamic>,
      token,
    );
    await _persistAuthResult(result);
    return result;
  }

  Future<void> logout() async {
    await SecureStorage.clearAuth();
  }

  Future<bool> isLoggedIn() => SecureStorage.isLoggedIn();

  Future<void> _persistAuthResult(AuthResult result) async {
    await SecureStorage.saveToken(result.token);
    await SecureStorage.saveUserId(result.user.id);
    await SecureStorage.saveProfileJson(jsonEncode(result.toJson()));
    if (result.farm != null) {
      await SecureStorage.saveFarmId(result.farm!.id);
    } else {
      await SecureStorage.clearFarmId();
    }
  }
}
