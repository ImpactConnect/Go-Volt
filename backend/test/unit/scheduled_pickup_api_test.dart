import 'dart:convert';
import 'package:backend/src/server.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shelf/shelf.dart';

void main() {
  late Handler handler;

  setUp(() {
    handler = createServerHandler();
  });

  group('Scheduled Pickup Backend API (v1.5 Section 21)', () {
    // -------------------------------------------------------------------------
    // 1. QUOTES & PRICING (Section 21.2 & 21.3 Invariants)
    // -------------------------------------------------------------------------
    test('POST /api/v1/scheduled/quotes calculates deterministic fare with 48-hour expiration', () async {
      final payload = {
        'booking_type': 'recurring',
        'purpose': 'school_run',
        'journey_type': 'one_way',
        'pickup_location': {
          'latitude': 10.5105,
          'longitude': 7.4165,
          'address': '3, Ahmadu Bello Way, Kaduna',
          'label': 'Home',
        },
        'destination_location': {
          'latitude': 10.5235,
          'longitude': 7.4385,
          'address': 'Bayero University, Kaduna',
          'label': 'School',
        },
        'pickup_time': '08:00 AM',
        'selected_days': ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
        'billing_model': 'monthly_package',
      };

      final request = Request(
        'POST',
        Uri.parse('http://localhost:8080/api/v1/scheduled/quotes'),
        body: jsonEncode(payload),
        headers: {'content-type': 'application/json'},
      );

      final response = await handler(request);
      expect(response.statusCode, 200);

      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;

      // Verify Section 21 fare rules: ₦2,000 base + ₦50/km (8km = ₦400) + ₦100 fee = ₦2,500
      expect(data['base_fare_ngn'], 2000.0);
      expect(data['service_fee_ngn'], 100.0);
      expect(data['estimated_price_per_trip_ngn'], 2500.0);

      // 5 days/week * 12 weeks = 60 trips; 60 * 2,500 = ₦150,000
      expect(data['total_trips'], 60);
      expect(data['total_fare_ngn'], 150000.0);

      // Section 21 Invariant 5: 48-hour server-side calculated quote expiration
      final issuedAt = DateTime.parse(data['issued_at'] as String);
      final expiresAt = DateTime.parse(data['expires_at'] as String);
      final expirationDiff = expiresAt.difference(issuedAt);
      expect(expirationDiff.inHours, 48);
    });

    test('POST /api/v1/scheduled-quotes endpoint alias works identically', () async {
      final payload = {
        'booking_type': 'one_off',
        'purpose': 'work_commute',
        'journey_type': 'round_trip',
        'pickup_location': {
          'latitude': 10.5105,
          'longitude': 7.4165,
          'address': '3, Ahmadu Bello Way, Kaduna',
        },
        'destination_location': {
          'latitude': 10.5280,
          'longitude': 7.4420,
          'address': 'Murtala Square, Kaduna',
        },
        'pickup_time': '08:00 AM',
        'billing_model': 'pay_per_trip',
      };

      final request = Request(
        'POST',
        Uri.parse('http://localhost:8080/api/v1/scheduled-quotes'),
        body: jsonEncode(payload),
        headers: {'content-type': 'application/json'},
      );

      final response = await handler(request);
      expect(response.statusCode, 200);

      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;

      // Round trip: legMultiplier = 2, single leg = ₦2,500, round trip = ₦5,000
      expect(data['total_fare_ngn'], 5000.0);
      expect(data['journey_type'], 'round_trip');
    });

    // -------------------------------------------------------------------------
    // 2. PLAN LIFECYCLE (Section 21.2 & 21.6)
    // -------------------------------------------------------------------------
    test('POST /api/v1/scheduled/plans submits plan in pending_review status', () async {
      final payload = {
        'purpose': 'school_run',
        'passenger_name': 'Zainab Adeleke',
        'passenger_phone': '+234 803 123 4567',
        'school_name': 'Bayero University Staff School',
        'total_trips': 60,
        'total_fare_ngn': 150000.0,
        'billing_model': 'monthly_package',
        'pickup_location': {
          'latitude': 10.5105,
          'longitude': 7.4165,
          'address': '3, Ahmadu Bello Way, Kaduna',
          'label': 'Home',
        },
        'destination_location': {
          'latitude': 10.5235,
          'longitude': 7.4385,
          'address': 'Bayero University, Kaduna',
          'label': 'School',
        },
      };

      final request = Request(
        'POST',
        Uri.parse('http://localhost:8080/api/v1/scheduled/plans'),
        body: jsonEncode(payload),
        headers: {'content-type': 'application/json'},
      );

      final response = await handler(request);
      expect(response.statusCode, 201);

      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;

      // Invariant 4: Plan must start in pending_review
      expect(data['status'], 'pending_review');
      expect(data['passenger_name'], 'Zainab Adeleke');
      expect(data['id'], startsWith('plan_'));
    });

    test('GET /api/v1/scheduled/plans lists active and pending plans', () async {
      final request = Request(
        'GET',
        Uri.parse('http://localhost:8080/api/v1/scheduled/plans'),
      );

      final response = await handler(request);
      expect(response.statusCode, 200);

      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      final list = body['data'] as List<dynamic>;

      expect(list, isNotEmpty);
      expect(list.any((p) => (p as Map<String, dynamic>)['id'] == 'plan-sch-01'), isTrue);
    });

    test('POST /api/v1/scheduled/plans/<id>/approve transitions plan to approved_awaiting_payment', () async {
      final request = Request(
        'POST',
        Uri.parse('http://localhost:8080/api/v1/scheduled/plans/plan-work-kaduna-02/approve'),
      );

      final response = await handler(request);
      expect(response.statusCode, 200);

      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;

      expect(data['status'], 'approved_awaiting_payment');
      expect(data['approval_expires_at'], isNotNull);
    });

    test('POST /api/v1/scheduled/plans/<id>/pay activates plan and credits entitlements', () async {
      final request = Request(
        'POST',
        Uri.parse('http://localhost:8080/api/v1/scheduled/plans/plan-work-kaduna-02/pay'),
        body: jsonEncode({'payment_method': 'Go-Volts Wallet'}),
        headers: {'content-type': 'application/json'},
      );

      final response = await handler(request);
      expect(response.statusCode, 200);

      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;

      // Invariant 4: Activated upon verified full payment
      expect(data['status'], 'active');
      final meta = body['meta'] as Map<String, dynamic>;
      expect(meta['status'], 'active');
      expect(meta['trips_generated'], greaterThanOrEqualTo(1));
    });

    test('POST /api/v1/scheduled/plans/<id>/pause and /resume manage plan suspension', () async {
      // Pause
      final pauseRequest = Request(
        'POST',
        Uri.parse('http://localhost:8080/api/v1/scheduled/plans/plan-sch-01/pause'),
        body: jsonEncode({'effective_date': '2026-11-10T00:00:00Z'}),
        headers: {'content-type': 'application/json'},
      );
      final pauseResponse = await handler(pauseRequest);
      expect(pauseResponse.statusCode, 200);
      final pauseBody = jsonDecode(await pauseResponse.readAsString()) as Map<String, dynamic>;
      final pauseData = pauseBody['data'] as Map<String, dynamic>;
      expect(pauseData['status'], 'paused');

      // Resume
      final resumeRequest = Request(
        'POST',
        Uri.parse('http://localhost:8080/api/v1/scheduled/plans/plan-sch-01/resume'),
      );
      final resumeResponse = await handler(resumeRequest);
      expect(resumeResponse.statusCode, 200);
      final resumeBody = jsonDecode(await resumeResponse.readAsString()) as Map<String, dynamic>;
      final resumeData = resumeBody['data'] as Map<String, dynamic>;
      expect(resumeData['status'], 'active');
    });

    // -------------------------------------------------------------------------
    // 3. 6-HOUR SKIP CUTOFF RULE (Section 21.3 Invariant 7)
    // -------------------------------------------------------------------------
    test('POST /api/v1/scheduled/trips/<id>/skip preserves entitlement when >= 6 hours before pickup', () async {
      final tripTime = DateTime.now().add(const Duration(hours: 18));
      final request = Request(
        'POST',
        Uri.parse('http://localhost:8080/api/v1/scheduled/trips/trip-sch-01/skip'),
        body: jsonEncode({'trip_time': tripTime.toIso8601String()}),
        headers: {'content-type': 'application/json'},
      );

      final response = await handler(request);
      expect(response.statusCode, 200);

      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;

      expect(data['entitlement_preserved'], isTrue);
      expect(data['status'], 'skipped');
      expect(data['message'], contains('Entitlement preserved'));
    });

    test('POST /api/v1/scheduled/trips/<id>/skip forfeits entitlement when < 6 hours before pickup', () async {
      final tripTime = DateTime.now().add(const Duration(hours: 2)); // Under 6-hour cutoff
      final request = Request(
        'POST',
        Uri.parse('http://localhost:8080/api/v1/scheduled/trips/trip-sch-01/skip'),
        body: jsonEncode({'trip_time': tripTime.toIso8601String()}),
        headers: {'content-type': 'application/json'},
      );

      final response = await handler(request);
      expect(response.statusCode, 200);

      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;

      expect(data['entitlement_preserved'], isFalse);
      expect(data['status'], 'skipped');
      expect(data['message'], contains('Entitlement forfeited'));
    });

    // -------------------------------------------------------------------------
    // 4. SCHOOL RUN HANDOVER VERIFICATION (Section 21.3 Invariant 15)
    // -------------------------------------------------------------------------
    test('POST /api/v1/scheduled/trips/<id>/verify-handover succeeds with correct 4-digit PIN', () async {
      final request = Request(
        'POST',
        Uri.parse('http://localhost:8080/api/v1/scheduled/trips/trip-sch-01/verify-handover'),
        body: jsonEncode({
          'pin': '4219',
          'recipient_name': 'Mrs. Aisha Muhammadu',
          'recipient_role': 'School Teacher',
        }),
        headers: {'content-type': 'application/json'},
      );

      final response = await handler(request);
      expect(response.statusCode, 200);

      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;

      expect(data['verified'], isTrue);
      expect(data['handover_status'], 'completed');
      expect(data['recipient_name'], 'Mrs. Aisha Muhammadu');
    });

    test('POST /api/v1/scheduled/trips/<id>/verify-handover rejects incorrect PIN with 400', () async {
      final request = Request(
        'POST',
        Uri.parse('http://localhost:8080/api/v1/scheduled/trips/trip-sch-01/verify-handover'),
        body: jsonEncode({
          'pin': '0000',
          'recipient_name': 'Unknown Contact',
          'recipient_role': 'Stranger',
        }),
        headers: {'content-type': 'application/json'},
      );

      final response = await handler(request);
      expect(response.statusCode, 400);

      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'INVALID_HANDOVER_CODE');
    });

    // -------------------------------------------------------------------------
    // 5. TRIP ISSUE REPORTING (Screen 35)
    // -------------------------------------------------------------------------
    test('POST /api/v1/scheduled/trips/<id>/report-issue records safety or driver incident', () async {
      final request = Request(
        'POST',
        Uri.parse('http://localhost:8080/api/v1/scheduled/trips/trip-sch-01/report-issue'),
        body: jsonEncode({
          'issue_type': 'DRIVER_WAS_LATE',
          'notes': 'Driver arrived 15 minutes past pickup window.',
        }),
        headers: {'content-type': 'application/json'},
      );

      final response = await handler(request);
      expect(response.statusCode, 201);

      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      final meta = body['meta'] as Map<String, dynamic>;
      expect(data['issue_type'], 'DRIVER_WAS_LATE');
      expect(meta['status'], 'recorded');
    });
  });
}
