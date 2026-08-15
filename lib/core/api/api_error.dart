enum ApiErrorType {
  unauthorized,
  forbidden,
  validation,
  network,
  server,
  unknown,
}

class ApiError implements Exception {
  final ApiErrorType type;
  final String message;
  final int? statusCode;
  final Map<String, dynamic>? details;

  const ApiError({
    required this.type,
    required this.message,
    this.statusCode,
    this.details,
  });

  @override
  String toString() => message;
}
