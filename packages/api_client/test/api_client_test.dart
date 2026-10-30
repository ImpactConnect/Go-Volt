import 'package:api_client/api_client.dart';
import 'package:app_config/app_config.dart';
import 'package:app_models/app_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ApiResponse & ApiError', () {
    test('parses success envelope correctly', () {
      final json = {
        'data': {
          'id': 'bk-001',
          'booking_reference': 'GV-2026-0001',
          'service_code': 'RIDE_INSTANT',
          'status': 'PENDING',
          'pickup_location': {
            'latitude': 6.5244,
            'longitude': 3.3792,
            'address': 'Marina, Lagos',
          },
          'dropoff_location': {
            'latitude': 6.4500,
            'longitude': 3.4200,
            'address': 'Victoria Island, Lagos',
          },
          'price_breakdown': {
            'base_fare': 500,
            'distance_fare': 1000,
            'time_fare': 200,
            'total_fare': 1750,
            'platform_fee': 50,
          },
          'created_at': '2026-10-24T12:00:00.000Z',
        },
        'meta': {'request_id': 'req-123'},
      };

      final response = ApiResponse<BookingDto>.fromJson(
        json,
        (raw) => BookingDto.fromJson(raw as Map<String, dynamic>),
      );

      expect(response.isSuccess, isTrue);
      expect(response.isError, isFalse);
      expect(response.data?.bookingReference, 'GV-2026-0001');
      expect(response.meta['request_id'], 'req-123');
    });

    test('parses error envelope correctly', () {
      final json = {
        'error': {
          'code': 'INSUFFICIENT_FUNDS',
          'message': 'Your wallet balance is insufficient for this booking.',
          'details': {'required': 2500, 'current_balance': 500},
          'status_code': 402,
        },
      };

      final response = ApiResponse<BookingDto>.fromJson(
        json,
        (raw) => BookingDto.fromJson(raw as Map<String, dynamic>),
        statusCode: 402,
      );

      expect(response.isSuccess, isFalse);
      expect(response.isError, isTrue);
      expect(response.error?.code, 'INSUFFICIENT_FUNDS');
      expect(response.error?.statusCode, 402);
      expect(response.error?.details['required'], 2500);
    });

    test('ApiError classification getters', () {
      expect(const ApiError(code: 'UNAUTHORIZED', message: '', statusCode: 401).isUnauthorized, isTrue);
      expect(const ApiError(code: 'FORBIDDEN', message: '', statusCode: 403).isForbidden, isTrue);
      expect(const ApiError(code: 'NOT_FOUND', message: '', statusCode: 404).isNotFound, isTrue);
      expect(const ApiError(code: 'RATE_LIMITED', message: '', statusCode: 429).isRateLimited, isTrue);
      expect(ApiError.network().isNetworkError, isTrue);
    });
  });

  group('ApiClient', () {
    test('initializes with default AppConfig and injects headers', () {
      final config = AppConfig.dev();
      final client = ApiClient(
        config: config,
        tokenProvider: () => 'test-bearer-token',
      );

      expect(client.dio.options.baseUrl, config.apiBaseUrl);
      expect(client.dio.options.headers['X-Client-App'], 'Go-Volts Dev');
      expect(client.dio.options.headers['X-Client-Env'], 'dev');
    });
  });
}
