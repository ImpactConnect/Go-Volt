/// Standardized API response wrapper matching backend contract.
class ApiResponse<T> {

  factory ApiResponse.success(T data, {Map<String, dynamic> meta = const {}, int statusCode = 200}) {
    return ApiResponse(
      data: data,
      meta: meta,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.failure(ApiError error, {int statusCode = 400, Map<String, dynamic> meta = const {}}) {
    return ApiResponse(
      error: error,
      meta: meta,
      statusCode: statusCode,
    );
  }

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic raw) fromJsonT, {
    int statusCode = 200,
  }) {
    final errorJson = json['error'];
    final ApiError? apiError = errorJson != null
        ? ApiError.fromJson(errorJson as Map<String, dynamic>, statusCode: statusCode)
        : null;

    final dataJson = json['data'];
    final T? parsedData = (dataJson != null && apiError == null)
        ? fromJsonT(dataJson)
        : null;

    final metaJson = (json['meta'] as Map<String, dynamic>?) ?? const {};

    return ApiResponse(
      data: parsedData,
      error: apiError,
      meta: metaJson,
      statusCode: statusCode,
    );
  }
  const ApiResponse({
    this.data,
    this.error,
    this.meta = const {},
    this.statusCode = 200,
  });

  final T? data;
  final ApiError? error;
  final Map<String, dynamic> meta;
  final int statusCode;

  bool get isSuccess => error == null && statusCode >= 200 && statusCode < 300;
  bool get isError => !isSuccess;
}

/// Structured API error model.
class ApiError implements Exception {

  factory ApiError.fromJson(Map<String, dynamic> json, {int statusCode = 400}) {
    return ApiError(
      code: json['code'] as String? ?? 'UNKNOWN_ERROR',
      message: json['message'] as String? ?? 'An unexpected error occurred',
      details: (json['details'] as Map<String, dynamic>?) ?? const {},
      statusCode: (json['status_code'] as int?) ?? statusCode,
    );
  }

  factory ApiError.network([String? msg]) {
    return ApiError(
      code: 'NETWORK_ERROR',
      message: msg ?? 'Please check your internet connection and try again.',
      statusCode: 0,
    );
  }

  factory ApiError.server([String? msg, int statusCode = 500]) {
    return ApiError(
      code: 'INTERNAL_SERVER_ERROR',
      message: msg ?? 'Service temporarily unavailable. Our engineers are on it.',
      statusCode: statusCode,
    );
  }
  const ApiError({
    required this.code,
    required this.message,
    this.details = const {},
    this.statusCode = 400,
  });

  final String code;
  final String message;
  final Map<String, dynamic> details;
  final int statusCode;

  bool get isNetworkError => code == 'NETWORK_ERROR';
  bool get isUnauthorized => statusCode == 401 || code == 'UNAUTHORIZED';
  bool get isForbidden => statusCode == 403 || code == 'FORBIDDEN';
  bool get isNotFound => statusCode == 404 || code == 'NOT_FOUND';
  bool get isRateLimited => statusCode == 429 || code == 'RATE_LIMITED';

  Map<String, dynamic> toJson() => {
        'code': code,
        'message': message,
        'details': details,
        'status_code': statusCode,
      };

  @override
  String toString() => 'ApiError(code: $code, message: $message, status: $statusCode)';
}
