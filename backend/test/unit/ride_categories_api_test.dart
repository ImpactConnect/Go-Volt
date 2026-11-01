import 'dart:convert';
import 'package:backend/src/server.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shelf/shelf.dart';

void main() {
  late Handler handler;

  setUp(() {
    handler = createServerHandler();
  });

  group('Ride Categories API Endpoints (v1.3 §5.4 & §6.8.1)', () {
    test('GET /api/v1/catalogue/ride-categories returns 5 seeded options (2 bikes, 3 cars)', () async {
      final request = Request(
        'GET',
        Uri.parse('http://localhost:8080/api/v1/catalogue/ride-categories'),
      );
      final response = await handler(request);

      expect(response.statusCode, 200);
      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      final list = body['data'] as List<dynamic>;

      expect(list.length, 5);

      // Verify 2 Bike Options
      final bikeOptions = list.where((c) {
        final cat = c as Map<String, dynamic>;
        final iconKey = cat['icon_key'] as String? ?? '';
        final code = cat['code'] as String? ?? '';
        return iconKey.contains('bike') || code.contains('bike');
      }).toList();
      expect(bikeOptions.length, 2);

      final bikeNames = bikeOptions.map((b) => (b as Map<String, dynamic>)['name']).toList();
      expect(bikeNames, containsAll(['GoRide Moto', 'GoRide Moto Plus']));

      // Verify 3 Car Options
      final carOptions = list.where((c) {
        final cat = c as Map<String, dynamic>;
        final iconKey = cat['icon_key'] as String? ?? '';
        final code = cat['code'] as String? ?? '';
        return !iconKey.contains('bike') && !code.contains('bike');
      }).toList();
      expect(carOptions.length, 3);

      final carNames = carOptions.map((c) => (c as Map<String, dynamic>)['name']).toList();
      expect(carNames, containsAll(['GoRide Standard', 'GoRide Plus', 'GoRide XL']));

      // Verify base fares
      final moto = list.firstWhere((c) => (c as Map<String, dynamic>)['code'] == 'bike_standard') as Map<String, dynamic>;
      expect(moto['base_fare_kobo'], 120000); // ₦1,200

      final motoPlus = list.firstWhere((c) => (c as Map<String, dynamic>)['code'] == 'bike_plus') as Map<String, dynamic>;
      expect(motoPlus['base_fare_kobo'], 180000); // ₦1,800

      final standard = list.firstWhere((c) => (c as Map<String, dynamic>)['code'] == 'standard') as Map<String, dynamic>;
      expect(standard['base_fare_kobo'], 280000); // ₦2,800

      final plus = list.firstWhere((c) => (c as Map<String, dynamic>)['code'] == 'plus') as Map<String, dynamic>;
      expect(plus['base_fare_kobo'], 350000); // ₦3,500

      final xl = list.firstWhere((c) => (c as Map<String, dynamic>)['code'] == 'xl') as Map<String, dynamic>;
      expect(xl['base_fare_kobo'], 450000); // ₦4,500
    });

    test('GET /api/v1/ride-categories returns identical results', () async {
      final request = Request(
        'GET',
        Uri.parse('http://localhost:8080/api/v1/ride-categories'),
      );
      final response = await handler(request);

      expect(response.statusCode, 200);
      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      final list = body['data'] as List<dynamic>;

      expect(list.length, 5);
    });

    test('Admin toggle availability flips is_available', () async {
      final toggleRequest = Request(
        'POST',
        Uri.parse('http://localhost:8080/api/v1/ride-categories/admin/cat_bike_std/toggle'),
      );
      final toggleResponse = await handler(toggleRequest);
      expect(toggleResponse.statusCode, 200);

      final toggleBody = jsonDecode(await toggleResponse.readAsString()) as Map<String, dynamic>;
      final toggleMeta = toggleBody['meta'] as Map<String, dynamic>;
      expect(toggleMeta['is_available'], isFalse);

      // Now customer query should return 4 active categories
      final catRequest = Request(
        'GET',
        Uri.parse('http://localhost:8080/api/v1/catalogue/ride-categories'),
      );
      final catResponse = await handler(catRequest);
      final catBody = jsonDecode(await catResponse.readAsString()) as Map<String, dynamic>;
      final catList = catBody['data'] as List<dynamic>;
      expect(catList.length, 4);

      // Toggle back
      final restoreRequest = Request(
        'POST',
        Uri.parse('http://localhost:8080/api/v1/ride-categories/admin/cat_bike_std/toggle'),
      );
      final restoreResponse = await handler(restoreRequest);
      expect(restoreResponse.statusCode, 200);
      final restoreBody = jsonDecode(await restoreResponse.readAsString()) as Map<String, dynamic>;
      final restoreMeta = restoreBody['meta'] as Map<String, dynamic>;
      expect(restoreMeta['is_available'], isTrue);
    });
  });
}
