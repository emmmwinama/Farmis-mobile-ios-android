import 'package:dio/dio.dart';
import 'account_models.dart';

typedef AuthResult = ({String token, Account account});

class AccountRepository {
  final Dio _dio;
  const AccountRepository(this._dio);

  Future<AuthResult> login({required String email, required String password}) async {
    final res = await _dio.post('/api/mobile/login', data: {
      'email': email,
      'password': password,
    });
    return _authResult(res.data as Map<String, dynamic>);
  }

  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    String? farmName,
  }) async {
    final res = await _dio.post('/api/mobile/register', data: {
      'name': name,
      'email': email,
      'password': password,
      if (farmName != null && farmName.trim().isNotEmpty) 'farmName': farmName.trim(),
    });
    return _authResult(res.data as Map<String, dynamic>);
  }

  AuthResult _authResult(Map<String, dynamic> data) {
    final token = data['token'] as String?;
    if (token == null || token.isEmpty) {
      throw DioException(requestOptions: RequestOptions(), error: 'No session token returned');
    }
    return (token: token, account: Account.fromJson(data));
  }

  /// Requests a one-time reset code by email. Always succeeds server-side
  /// regardless of whether the email is registered (avoids leaking which
  /// emails have accounts) — no return value to act on beyond "it was sent."
  Future<void> requestPasswordReset(String email) async {
    await _dio.post('/api/mobile/forgot-password', data: {'email': email});
  }

  Future<void> resetPassword({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await _dio.post('/api/mobile/reset-password', data: {
      'email': email,
      'code': code,
      'newPassword': newPassword,
    });
  }

  Future<Account> fetchProfile() async {
    final res = await _dio.get('/api/mobile/profile');
    return Account.fromJson(res.data as Map<String, dynamic>);
  }

  /// Pushes the full local export up to the cloud. Returns the row counts the
  /// backend accepted, keyed by table name.
  Future<Map<String, int>> backup(Map<String, dynamic> exportJson) async {
    final res = await _dio.post('/api/mobile/backup', data: exportJson);
    final counts = (res.data as Map<String, dynamic>)['counts'] as Map<String, dynamic>? ?? {};
    return counts.map((k, v) => MapEntry(k, (v as num).toInt()));
  }

  /// Pulls the farm's latest cloud backup down — used to restore onto a new
  /// device. Returns the same JSON shape the local export/import already uses.
  Future<Map<String, dynamic>> restore() async {
    final res = await _dio.get('/api/mobile/backup');
    return res.data as Map<String, dynamic>;
  }
}
