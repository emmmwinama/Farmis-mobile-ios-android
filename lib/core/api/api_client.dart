import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/secure_storage.dart';
import 'api_config.dart';

/// Dio client for Ulimi's mobile API. Attaches the stored access token and
/// active farm id to every request, and transparently refreshes an expired
/// access token once before giving up — see [_RefreshInterceptor].
final apiClientProvider = Provider<Dio>((ref) {
  final dio = Dio(BaseOptions(
    baseUrl: apiBaseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    contentType: 'application/json',
  ));

  dio.interceptors.add(InterceptorsWrapper(
    onRequest: (options, handler) async {
      final token = await SecureStorage.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      final farmId = await SecureStorage.getFarmId();
      if (farmId != null && farmId.isNotEmpty) {
        options.headers['X-Farm-Id'] = farmId;
      }
      handler.next(options);
    },
  ));

  dio.interceptors.add(_RefreshInterceptor(dio));

  return dio;
});

/// A request that 401s because the access token expired gets exactly one
/// silent retry: refresh the token pair at /api/mobile/refresh, then replay
/// the original request with the new access token. A 401 on /login,
/// /refresh, or /logout themselves is a real auth failure, not an expired
/// token — never intercepted, or this would loop.
///
/// If the refresh itself fails (the refresh token is dead — expired, or
/// already rotated by a concurrent call), the stored session is cleared and
/// the original 401 is passed through; the router's redirect re-checks
/// [SecureStorage.isLoggedIn] on the next navigation and sends the user back
/// to /login.
class _RefreshInterceptor extends Interceptor {
  _RefreshInterceptor(this._dio);

  final Dio _dio;
  Future<bool>? _refreshing;

  static const _unrefreshablePaths = [
    '/api/mobile/login',
    '/api/mobile/refresh',
    '/api/mobile/logout',
  ];

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final path = err.requestOptions.path;
    final is401 = err.response?.statusCode == 401;
    if (!is401 || _unrefreshablePaths.any(path.contains)) {
      return handler.next(err);
    }

    final refreshed = await (_refreshing ??= _refresh());
    if (!refreshed) {
      return handler.next(err);
    }

    try {
      final token = await SecureStorage.getToken();
      final retryOptions = err.requestOptions;
      retryOptions.headers['Authorization'] = 'Bearer $token';
      final response = await _dio.fetch(retryOptions);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Future<bool> _refresh() async {
    try {
      final refreshToken = await SecureStorage.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) return false;

      final res = await Dio(BaseOptions(baseUrl: apiBaseUrl)).post(
        '/api/mobile/refresh',
        data: {'refresh_token': refreshToken},
      );
      final data = res.data as Map<String, dynamic>;
      await SecureStorage.saveToken(data['access_token'] as String);
      await SecureStorage.saveRefreshToken(data['refresh_token'] as String);
      return true;
    } catch (_) {
      await SecureStorage.clearAuth();
      return false;
    } finally {
      _refreshing = null;
    }
  }
}

/// Extracts a user-facing message from a failed API call. Validation errors
/// come back as `{errors: {field: [msg, ...]}}`; every other error as
/// `{error: string}`.
String apiErrorMessage(Object error, {String fallback = 'Something went wrong. Please try again.'}) {
  if (error is DioException) {
    final data = error.response?.data;
    if (data is Map) {
      if (data['error'] is String) return data['error'] as String;
      final errors = data['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final firstField = errors.values.first;
        if (firstField is List && firstField.isNotEmpty) return firstField.first.toString();
      }
    }
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return 'Could not reach the server. Check your connection and try again.';
    }
  }
  return fallback;
}
