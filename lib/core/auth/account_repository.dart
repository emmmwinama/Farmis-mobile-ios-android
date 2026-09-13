import 'package:dio/dio.dart';
import 'account_models.dart';

typedef AuthResult = ({String accessToken, String refreshToken, AccountUser user});

/// Talks to Ulimi's mobile auth endpoints (`/api/mobile/login|refresh|logout`
/// — see `docs/MOBILE-API.md` in the Ulimi-app repo). There is deliberately
/// no register/Google-sign-in/password-reset here: none of those exist on
/// the backend yet. An account is created on the web app; this app only
/// signs in to one that already exists.
class AccountRepository {
  final Dio _dio;
  const AccountRepository(this._dio);

  Future<AuthResult> login({
    required String email,
    required String password,
    String device = '',
  }) async {
    final res = await _dio.post('/api/mobile/login', data: {
      'email': email,
      'password': password,
      'device': device,
    });
    return _authResult(res.data as Map<String, dynamic>);
  }

  Future<AuthResult> refresh(String refreshToken) async {
    final res = await _dio.post('/api/mobile/refresh', data: {'refresh_token': refreshToken});
    return _authResult(res.data as Map<String, dynamic>);
  }

  Future<void> logout(String? refreshToken) async {
    await _dio.post('/api/mobile/logout', data: {
      if (refreshToken != null) 'refresh_token': refreshToken,
    });
  }

  AuthResult _authResult(Map<String, dynamic> data) {
    final accessToken = data['access_token'] as String?;
    final refreshToken = data['refresh_token'] as String?;
    if (accessToken == null || accessToken.isEmpty || refreshToken == null || refreshToken.isEmpty) {
      throw DioException(requestOptions: RequestOptions(), error: 'No session token returned');
    }
    return (
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: AccountUser.fromJson(data['user'] as Map<String, dynamic>),
    );
  }
}
