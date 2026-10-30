import 'dart:convert';
import 'package:backend/src/server.dart';
import 'package:shelf/shelf.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Handler handler;

  setUp(() {
    handler = createServerHandler();
  });

  group('Health endpoints', () {
    test('GET /health returns 200 with ok status', () async {
      final request = Request('GET', Uri.parse('http://localhost:8080/health'));
      final response = await handler(request);

      expect(response.statusCode, 200);
      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      expect(data['status'], 'healthy');
      expect(data['service'], 'go_volts_api');
      expect(response.headers['x-request-id'], isNotNull);
    });

    test('GET /api/v1/health returns 200', () async {
      final request = Request('GET', Uri.parse('http://localhost:8080/api/v1/health'));
      final response = await handler(request);
      expect(response.statusCode, 200);
    });
  });

  group('Quotes API', () {
    test('POST /api/v1/quotes generates binding upfront quote for instant ride', () async {
      final payload = {
        'service_code': 'RIDE_INSTANT',
        'pickup': {
          'latitude': 6.5244,
          'longitude': 3.3792,
          'address': 'Marina, Lagos',
        },
        'dropoff': {
          'latitude': 6.4500,
          'longitude': 3.4200,
          'address': 'Victoria Island, Lagos',
        },
      };

      final request = Request(
        'POST',
        Uri.parse('http://localhost:8080/api/v1/quotes'),
        body: jsonEncode(payload),
        headers: {'content-type': 'application/json'},
      );

      final response = await handler(request);
      expect(response.statusCode, 200);

      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      final quote = body['data'] as Map<String, dynamic>;
      final breakdown = quote['price_breakdown'] as Map<String, dynamic>;

      expect(quote['service_code'], 'RIDE_INSTANT');
      expect(quote['quote_id'], startsWith('qt_'));
      expect((breakdown['total_fare'] as num), greaterThan(500));
      expect(quote['estimated_duration_minutes'], greaterThan(0));
    });
  });

  group('Bookings API', () {
    test('POST /api/v1/bookings creates new booking entity', () async {
      final payload = {
        'quote_id': 'qt_test123',
        'payment_method': 'WALLET',
        'instructions': 'Please ring gate bell',
      };

      final request = Request(
        'POST',
        Uri.parse('http://localhost:8080/api/v1/bookings'),
        body: jsonEncode(payload),
        headers: {'content-type': 'application/json'},
      );

      final response = await handler(request);
      expect(response.statusCode, 201);

      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      final booking = body['data'] as Map<String, dynamic>;

      expect(booking['id'], startsWith('bk_'));
      expect(booking['booking_reference'], startsWith('GV-'));
      expect(booking['status'], 'SEARCHING_RIDER');
      expect(booking['payment_method'], 'WALLET');
    });

    test('GET /api/v1/bookings lists created bookings', () async {
      final request = Request('GET', Uri.parse('http://localhost:8080/api/v1/bookings'));
      final response = await handler(request);

      expect(response.statusCode, 200);
      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      final list = body['data'] as List<dynamic>;
      expect(list, isNotEmpty);
    });
  });

  group('Payments API', () {
    test('POST /api/v1/payments/initialize returns checkout url', () async {
      final payload = {
        'amount': 2500,
        'email': 'customer@example.com',
        'reference': 'ref_test_001',
      };

      final request = Request(
        'POST',
        Uri.parse('http://localhost:8080/api/v1/payments/initialize'),
        body: jsonEncode(payload),
        headers: {'content-type': 'application/json'},
      );

      final response = await handler(request);
      expect(response.statusCode, 200);

      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      expect(data['authorization_url'], contains('checkout.paystack.com'));
      expect(data['reference'], 'ref_test_001');
    });

    test('GET /api/v1/payments/verify returns verified status', () async {
      final request = Request(
        'GET',
        Uri.parse('http://localhost:8080/api/v1/payments/verify/ref_test_001'),
      );

      final response = await handler(request);
      expect(response.statusCode, 200);

      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      final meta = body['meta'] as Map<String, dynamic>;
      expect(data['status'], 'success');
      expect(meta['verified'], isTrue);
    });
  });

  group('404 Handling', () {
    test('returns standard error envelope on unknown routes', () async {
      final request = Request('GET', Uri.parse('http://localhost:8080/unknown-route'));
      final response = await handler(request);

      expect(response.statusCode, 404);
      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'ROUTE_NOT_FOUND');
    });
  });

  group('Devices API (Push Notifications)', () {
    test('POST /api/v1/devices registers FCM device token', () async {
      final payload = {
        'fcm_token': 'fcm_sample_token_xyz_123',
        'platform': 'android',
        'device_model': 'Pixel 8 Pro',
      };

      final request = Request(
        'POST',
        Uri.parse('http://localhost:8080/api/v1/devices'),
        body: jsonEncode(payload),
        headers: {
          'content-type': 'application/json',
          'authorization': 'Bearer mock-jwt-token-123',
        },
      );

      final response = await handler(request);
      expect(response.statusCode, 200);

      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      expect(data['fcm_token'], 'fcm_sample_token_xyz_123');
      expect(data['platform'], 'android');
    });
  });

  group('Plans API (Scheduled Commuter & School-Run)', () {
    test('GET /api/v1/plans returns list of active plans', () async {
      final request = Request(
        'GET',
        Uri.parse('http://localhost:8080/api/v1/plans'),
        headers: {'authorization': 'Bearer mock-jwt-token-123'},
      );

      final response = await handler(request);
      expect(response.statusCode, 200);

      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      final plans = body['data'] as List<dynamic>;
      expect(plans, isNotEmpty);
      final firstPlan = plans.first as Map<String, dynamic>;
      expect(firstPlan['plan_name'], contains('Commute'));
    });

    test('POST /api/v1/plans creates new subscription plan', () async {
      final payload = {
        'plan_name': 'Morning Campus Shuttle',
        'plan_type': 'COMMUTER_PASS',
        'pickup_address': 'Akoka, Lagos',
        'dropoff_address': 'Yaba, Lagos',
        'pickup_time': '08:00:00',
        'days_of_week': [1, 2, 3, 4, 5],
      };

      final request = Request(
        'POST',
        Uri.parse('http://localhost:8080/api/v1/plans'),
        body: jsonEncode(payload),
        headers: {
          'content-type': 'application/json',
          'authorization': 'Bearer mock-jwt-token-123',
        },
      );

      final response = await handler(request);
      expect(response.statusCode, 201);

      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      final created = body['data'] as Map<String, dynamic>;
      expect(created['id'], startsWith('plan_'));
      expect(created['plan_name'], 'Morning Campus Shuttle');
    });
  });

  group('Rider API (§6.7)', () {
    test('GET /api/v1/rider/status returns active rider status', () async {
      final request = Request(
        'GET',
        Uri.parse('http://localhost:8080/api/v1/rider/status'),
        headers: {'authorization': 'Bearer mock-jwt-token-123'},
      );

      final response = await handler(request);
      expect(response.statusCode, 200);

      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      expect(data['approval_status'], 'APPROVED');
    });

    test('POST /api/v1/rider/availability updates online status', () async {
      final payload = {'is_online': true};

      final request = Request(
        'POST',
        Uri.parse('http://localhost:8080/api/v1/rider/availability'),
        body: jsonEncode(payload),
        headers: {
          'content-type': 'application/json',
          'authorization': 'Bearer mock-jwt-token-123',
        },
      );

      final response = await handler(request);
      expect(response.statusCode, 200);

      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      expect(data['is_online'], isTrue);
    });

    test('GET /api/v1/rider/offers returns available dispatch offers', () async {
      final request = Request(
        'GET',
        Uri.parse('http://localhost:8080/api/v1/rider/offers'),
        headers: {'authorization': 'Bearer mock-jwt-token-123'},
      );

      final response = await handler(request);
      expect(response.statusCode, 200);

      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      final offers = body['data'] as List<dynamic>;
      expect(offers, isNotEmpty);
    });

    test('GET /api/v1/rider/earnings returns weekly payout ledger summary', () async {
      final request = Request(
        'GET',
        Uri.parse('http://localhost:8080/api/v1/rider/earnings'),
        headers: {'authorization': 'Bearer mock-jwt-token-123'},
      );

      final response = await handler(request);
      expect(response.statusCode, 200);

      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      expect((data['settled_week_kobo'] as num), greaterThan(0));
      expect(data['bank_name'], isNotNull);
    });
  });
}


