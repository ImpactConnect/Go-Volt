import 'dart:async';
import 'package:app_config/app_config.dart';
import 'package:app_models/app_models.dart';
import 'package:dio/dio.dart';
import 'api_response.dart';

typedef TokenProvider = FutureOr<String?> Function();

/// Resilient HTTP client for Go-Volts REST endpoints.
class ApiClient {
  ApiClient({
    required AppConfig config,
    TokenProvider? tokenProvider,
    Dio? customDio,
  })  : _config = config,
        _tokenProvider = tokenProvider {
    _dio = customDio ??
        Dio(
          BaseOptions(
            baseUrl: _config.apiBaseUrl,
            connectTimeout: const Duration(seconds: 15),
            receiveTimeout: const Duration(seconds: 15),
            sendTimeout: const Duration(seconds: 15),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'X-Client-App': _config.appName,
              'X-Client-Env': _config.environment.key,
            },
          ),
        );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_tokenProvider != null) {
            final token = await _tokenProvider();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
            }
          }
          options.headers['X-Request-Id'] =
              DateTime.now().microsecondsSinceEpoch.toString();
          handler.next(options);
        },
        onError: (DioException err, handler) {
          handler.next(err);
        },
      ),
    );
  }

  final AppConfig _config;
  final TokenProvider? _tokenProvider;
  late final Dio _dio;

  Dio get dio => _dio;

  // ---------------------------------------------------------------------------
  // QUOTES & PRICING
  // ---------------------------------------------------------------------------

  Future<ApiResponse<QuoteDto>> getQuote({
    required ServiceCode serviceCode,
    required LocationDto pickup,
    required LocationDto dropoff,
    DateTime? scheduledTime,
    PackageCategory? packageCategory,
  }) async {
    return _send<QuoteDto>(
      method: 'POST',
      path: '/quotes',
      data: {
        'service_code': serviceCode.code,
        'pickup': pickup.toJson(),
        'dropoff': dropoff.toJson(),
        if (scheduledTime != null)
          'scheduled_time': scheduledTime.toIso8601String(),
        if (packageCategory != null)
          'package_category': packageCategory.code,
      },
      parser: (data) => QuoteDto.fromJson(data as Map<String, dynamic>),
    );
  }

  // ---------------------------------------------------------------------------
  // BOOKINGS
  // ---------------------------------------------------------------------------

  Future<ApiResponse<BookingDto>> createBooking({
    required String quoteId,
    required PaymentMethod paymentMethod,
    String? instructions,
    String? recipientName,
    String? recipientPhone,
  }) async {
    return _send<BookingDto>(
      method: 'POST',
      path: '/bookings',
      data: {
        'quote_id': quoteId,
        'payment_method': paymentMethod.code,
        'instructions': ?instructions,
        'recipient_name': ?recipientName,
        'recipient_phone': ?recipientPhone,
      },
      parser: (data) => BookingDto.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<BookingDto>> getBooking(String bookingId) async {
    return _send<BookingDto>(
      method: 'GET',
      path: '/bookings/$bookingId',
      parser: (data) => BookingDto.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<BookingDto>> cancelBooking(
    String bookingId, {
    required String reason,
  }) async {
    return _send<BookingDto>(
      method: 'POST',
      path: '/bookings/$bookingId/cancel',
      data: {'reason': reason},
      parser: (data) => BookingDto.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<List<BookingDto>>> listBookings({
    String? status,
    int limit = 20,
    int offset = 0,
  }) async {
    return _send<List<BookingDto>>(
      method: 'GET',
      path: '/bookings',
      queryParameters: {
        'status': ?status,
        'limit': limit,
        'offset': offset,
      },
      parser: (data) {
        final list = data as List<dynamic>? ?? [];
        return list
            .map((e) => BookingDto.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  // ---------------------------------------------------------------------------
  // USER PROFILE
  // ---------------------------------------------------------------------------

  Future<ApiResponse<ProfileDto>> getProfile() async {
    return _send<ProfileDto>(
      method: 'GET',
      path: '/users/profile',
      parser: (data) => ProfileDto.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<ProfileDto>> updateProfile({
    String? fullName,
    String? email,
    String? avatarUrl,
  }) async {
    return _send<ProfileDto>(
      method: 'PATCH',
      path: '/users/profile',
      data: {
        'full_name': ?fullName,
        'email': ?email,
        'avatar_url': ?avatarUrl,
      },
      parser: (data) => ProfileDto.fromJson(data as Map<String, dynamic>),
    );
  }

  // ---------------------------------------------------------------------------
  // WALLET
  // ---------------------------------------------------------------------------

  Future<ApiResponse<WalletDto>> getWallet() async {
    return _send<WalletDto>(
      method: 'GET',
      path: '/wallet',
      parser: (data) => WalletDto.fromJson(data as Map<String, dynamic>),
    );
  }

  Future<ApiResponse<List<WalletTransactionDto>>> listWalletTransactions({
    int limit = 20,
    int offset = 0,
  }) async {
    return _send<List<WalletTransactionDto>>(
      method: 'GET',
      path: '/wallet/transactions',
      queryParameters: {'limit': limit, 'offset': offset},
      parser: (data) {
        final list = data as List<dynamic>? ?? [];
        return list
            .map((e) => WalletTransactionDto.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
  }

  // ---------------------------------------------------------------------------
  // PAYMENT (Paystack Backend Adapter)
  // ---------------------------------------------------------------------------

  Future<ApiResponse<Map<String, dynamic>>> initializePayment({
    required double amount,
    required String email,
    required String reference,
    String? bookingId,
  }) async {
    return _send<Map<String, dynamic>>(
      method: 'POST',
      path: '/payments/initialize',
      data: {
        'amount': amount,
        'email': email,
        'reference': reference,
        'booking_id': ?bookingId,
      },
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyPayment(String reference) async {
    return _send<Map<String, dynamic>>(
      method: 'GET',
      path: '/payments/verify/$reference',
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  // ---------------------------------------------------------------------------
  // DEVICE TOKENS (Push Notifications)
  // ---------------------------------------------------------------------------

  Future<ApiResponse<Map<String, dynamic>>> registerDevice({
    required String fcmToken,
    required String platform,
    String? deviceModel,
  }) async {
    return _send<Map<String, dynamic>>(
      method: 'POST',
      path: '/devices',
      data: {
        'fcm_token': fcmToken,
        'platform': platform,
        'device_model': ?deviceModel,
      },
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> unregisterDevice({
    required String fcmToken,
  }) async {
    return _send<Map<String, dynamic>>(
      method: 'DELETE',
      path: '/devices',
      data: {'fcm_token': fcmToken},
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  // ---------------------------------------------------------------------------
  // SCHEDULED PLANS (Commuter & School-Run)
  // ---------------------------------------------------------------------------

  Future<ApiResponse<List<Map<String, dynamic>>>> getScheduledPlans() async {
    return _send<List<Map<String, dynamic>>>(
      method: 'GET',
      path: '/plans',
      parser: (data) {
        final list = data as List<dynamic>? ?? [];
        return list.cast<Map<String, dynamic>>();
      },
    );
  }

  Future<ApiResponse<Map<String, dynamic>>> createScheduledPlan({
    required String planName,
    required String planType,
    required String pickupAddress,
    required double pickupLat,
    required double pickupLng,
    required String dropoffAddress,
    required double dropoffLat,
    required double dropoffLng,
    required String pickupTime,
    required List<int> daysOfWeek,
  }) async {
    return _send<Map<String, dynamic>>(
      method: 'POST',
      path: '/plans',
      data: {
        'plan_name': planName,
        'plan_type': planType,
        'pickup_address': pickupAddress,
        'pickup_lat': pickupLat,
        'pickup_lng': pickupLng,
        'dropoff_address': dropoffAddress,
        'dropoff_lat': dropoffLat,
        'dropoff_lng': dropoffLng,
        'pickup_time': pickupTime,
        'days_of_week': daysOfWeek,
      },
      parser: (data) => data as Map<String, dynamic>,
    );
  }


  // ---------------------------------------------------------------------------
  // INTERNAL REQUEST DISPATCHER
  // ---------------------------------------------------------------------------

  Future<ApiResponse<T>> _send<T>({
    required String method,
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParameters,
    required T Function(dynamic data) parser,
  }) async {
    try {
      final response = await _dio.request<dynamic>(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(method: method),
      );

      final statusCode = response.statusCode ?? 200;
      final body = response.data;

      if (body is Map<String, dynamic>) {
        return ApiResponse<T>.fromJson(body, parser, statusCode: statusCode);
      }

      return ApiResponse<T>.success(parser(body), statusCode: statusCode);
    } on DioException catch (e) {
      return _handleDioError<T>(e);
    } catch (e) {
      return ApiResponse<T>.failure(
        ApiError(
          code: 'UNEXPECTED_ERROR',
          message: e.toString(),
          statusCode: 500,
        ),
        statusCode: 500,
      );
    }
  }

  ApiResponse<T> _handleDioError<T>(DioException e) {
    final response = e.response;
    final statusCode = response?.statusCode ?? 0;

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.connectionError) {
      return ApiResponse<T>.failure(
        ApiError.network(),
        statusCode: 0,
      );
    }

    if (response != null && response.data is Map<String, dynamic>) {
      final body = response.data as Map<String, dynamic>;
      final errorJson = body['error'];
      if (errorJson is Map<String, dynamic>) {
        return ApiResponse<T>.failure(
          ApiError.fromJson(errorJson, statusCode: statusCode),
          statusCode: statusCode,
        );
      }
    }

    return ApiResponse<T>.failure(
      ApiError.server(e.message, statusCode),
      statusCode: statusCode,
    );
  }
}
