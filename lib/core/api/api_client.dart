import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'api_error.dart';
import '../auth/secure_storage.dart';

class ApiClient {
  static Dio? _instance;

  /// Invoked whenever a request comes back 401, after secure storage has
  /// been cleared, so app-level auth state can be reset in lockstep.
  static void Function()? onUnauthorized;

  static Dio get instance {
    _instance ??= _createDio();
    return _instance!;
  }

  static void reset() {
    _instance = null;
  }

  static Dio _createDio() {
    final dio = Dio(_baseOptions(_configuredBaseUrl()));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await SecureStorage.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await SecureStorage.clearAuth();
          onUnauthorized?.call();
        }
        return handler.reject(_typedError(error));
      },
    ));

    return dio;
  }

  static String _configuredBaseUrl() {
    final configuredBaseUrl =
        dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000/api';
    final normalized = _normalizeBaseUrl(configuredBaseUrl);
    final uri = Uri.tryParse(normalized);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      throw StateError('API_BASE_URL must be a valid absolute URL.');
    }
    if (kReleaseMode && uri.scheme.toLowerCase() != 'https') {
      throw StateError('API_BASE_URL must use HTTPS in release builds.');
    }
    return normalized;
  }

  static String _normalizeBaseUrl(String value) {
    final trimmed = value.trim();
    return trimmed.endsWith('/')
        ? trimmed.substring(0, trimmed.length - 1)
        : trimmed;
  }

  static BaseOptions _baseOptions(String baseUrl) => BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 12),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 20),
        headers: {'Content-Type': 'application/json'},
      );

  static DioException _typedError(DioException error) {
    final status = error.response?.statusCode;
    final data = error.response?.data;
    final responseMessage =
        data is Map ? data['error'] ?? data['message'] : null;
    final rawMessage = responseMessage is String && responseMessage.isNotEmpty
        ? responseMessage
        : error.message ?? 'Request failed';

    ApiErrorType type;
    if (status == 401) {
      type = ApiErrorType.unauthorized;
    } else if (status == 403) {
      type = ApiErrorType.forbidden;
    } else if (status == 422 || status == 400) {
      type = ApiErrorType.validation;
    } else if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      type = ApiErrorType.network;
    } else if (status != null && status >= 500) {
      type = ApiErrorType.server;
    } else {
      type = ApiErrorType.unknown;
    }

    String message;
    switch (type) {
      case ApiErrorType.network:
        message = error.type == DioExceptionType.receiveTimeout
            ? 'The server is taking too long to load this data. Try again in a moment.'
            : 'Could not reach the server. Check your connection or API server address.';
        break;
      case ApiErrorType.server:
      case ApiErrorType.unauthorized:
      case ApiErrorType.forbidden:
      case ApiErrorType.validation:
      case ApiErrorType.unknown:
        if (status == 404) {
          message =
              'This mobile API endpoint was not found on the server. Restart the API server or check the API base URL.';
        } else {
          message = rawMessage;
        }
        break;
    }

    return error.copyWith(
      error: ApiError(
        type: type,
        message: message,
        statusCode: status,
        details: data is Map<String, dynamic> ? data : null,
      ),
    );
  }

  // ── Convenience methods ──────────────────────────────────────────
  static Future<Response> get(
    String path, {
    Map<String, dynamic>? params,
  }) =>
      instance.get(path, queryParameters: params);

  static Future<Response<List<int>>> getBytes(
    String path, {
    Map<String, dynamic>? params,
  }) =>
      instance.get<List<int>>(
        path,
        queryParameters: params,
        options: Options(responseType: ResponseType.bytes),
      );

  static Future<Response> post(
    String path,
    Map<String, dynamic> data,
  ) async {
    return instance.post(path, data: data);
  }

  static Future<Response> patch(
    String path,
    Map<String, dynamic> data,
  ) async {
    return instance.patch(path, data: data);
  }

  static Future<Response> delete(String path) async {
    return instance.delete(path);
  }
}
