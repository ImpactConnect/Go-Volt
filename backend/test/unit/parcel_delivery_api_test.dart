import 'dart:convert';
import 'package:backend/src/server.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shelf/shelf.dart';

void main() {
  late Handler handler;

  setUp(() {
    handler = createServerHandler();
  });

  group('Parcel Delivery API Endpoints (v1.4 §6.4 & §22)', () {
    test('GET /api/v1/delivery/catalogue returns active delivery options, categories and policy notice',
        () async {
      final request = Request(
        'GET',
        Uri.parse('http://localhost:8080/api/v1/delivery/catalogue?lat=6.4281&lng=3.4219'),
      );
      final response = await handler(request);

      expect(response.statusCode, 200);
      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;

      expect(data['delivery_options'], isA<List<dynamic>>());
      expect(data['package_categories'], isA<List<dynamic>>());
      expect(data['size_bands'], isA<List<dynamic>>());
      expect(data['handling_options'], isA<List<dynamic>>());
      expect(data['policy_version'], 'v1.4');
      expect(data['prohibited_items_notice'], contains('Hazardous materials'));
    });

    test('GET /api/v1/delivery/policies/current returns restricted items and declared value rules',
        () async {
      final request = Request(
        'GET',
        Uri.parse('http://localhost:8080/api/v1/delivery/policies/current'),
      );
      final response = await handler(request);

      expect(response.statusCode, 200);
      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;

      expect(data['policy_version'], 'v1.4');
      expect(data['restricted_items'], isNotEmpty);
      expect(data['declared_value_policy'], contains('automatic insurance coverage'));
    });

    test('POST /api/v1/deliveries/quotes calculates authoritative kobo fare snapshot',
        () async {
      final payload = {
        'pickup': {
          'latitude': 6.4281,
          'longitude': 3.4219,
          'address': 'Eko Hotel and Suites',
        },
        'dropoff': {
          'latitude': 6.4357,
          'longitude': 3.4418,
          'address': 'Palms Mall',
        },
        'delivery_option': {
          'code': 'STANDARD',
          'title': 'Standard Delivery',
          'subtitle': 'Delivery within 2 - 4 hours',
          'base_fare_kobo': 200000,
        },
        'weight_kg': 1.5,
        'size_band': {
          'code': 'SMALL',
          'label': 'Small (Up to 2 kg)',
          'surcharge_kobo': 0,
        },
        'handling_options': [
          {
            'code': 'FRAGILE',
            'label': 'Fragile (Handle with care)',
            'surcharge_kobo': 20000,
            'is_enabled': true,
          }
        ],
        'coupon_code': 'DELIVER20',
      };

      final request = Request(
        'POST',
        Uri.parse('http://localhost:8080/api/v1/deliveries/quotes'),
        body: jsonEncode(payload),
        headers: {'content-type': 'application/json'},
      );

      final response = await handler(request);
      expect(response.statusCode, 200);

      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;

      expect(data['base_fare_kobo'], 200000);
      expect(data['distance_fare_kobo'], 30000);
      expect(data['handling_fare_kobo'], 20000);
      expect(data['discount_kobo'], 40000); // 20% of 200,000 kobo base fare
      expect(data['total_amount_kobo'], 210000); // 250,000 - 40,000
    });

    test('POST /api/v1/deliveries creates booking and GET /api/v1/deliveries/<id> retrieves it',
        () async {
      final payload = {
        'delivery_option': {
          'code': 'STANDARD',
          'title': 'Standard Delivery',
          'subtitle': 'Delivery within 2 - 4 hours',
          'base_fare_kobo': 200000,
        },
        'recipient': {
          'full_name': 'John Doe',
          'phone_number': '+234 803 123 4567',
          'delivery_address': 'Palms Mall, Lekki, Lagos',
        },
        'payment_method': 'WALLET',
      };

      final createRequest = Request(
        'POST',
        Uri.parse('http://localhost:8080/api/v1/deliveries'),
        body: jsonEncode(payload),
        headers: {
          'content-type': 'application/json',
          'Idempotency-Key': 'idem_test_parcel_001',
        },
      );

      final createResponse = await handler(createRequest);
      expect(createResponse.statusCode, 201);

      final createBody = jsonDecode(await createResponse.readAsString()) as Map<String, dynamic>;
      final created = createBody['data'] as Map<String, dynamic>;
      final deliveryId = created['id'] as String;
      expect(created['tracking_number'], startsWith('DVL'));
      expect(created['rider_name'], 'Daniel Okafor');

      // GET /api/v1/deliveries/<id>
      final getRequest = Request(
        'GET',
        Uri.parse('http://localhost:8080/api/v1/deliveries/$deliveryId'),
      );
      final getResponse = await handler(getRequest);
      expect(getResponse.statusCode, 200);

      final getBody = jsonDecode(await getResponse.readAsString()) as Map<String, dynamic>;
      final fetched = getBody['data'] as Map<String, dynamic>;
      expect(fetched['id'], deliveryId);

      // POST /api/v1/deliveries/<id>/cancel
      final cancelRequest = Request(
        'POST',
        Uri.parse('http://localhost:8080/api/v1/deliveries/$deliveryId/cancel'),
      );
      final cancelResponse = await handler(cancelRequest);
      expect(cancelResponse.statusCode, 200);
      final cancelBody = jsonDecode(await cancelResponse.readAsString()) as Map<String, dynamic>;
      final cancelData = cancelBody['data'] as Map<String, dynamic>;
      expect(cancelData['status'], 'CANCELLED');
    });
  });
}
