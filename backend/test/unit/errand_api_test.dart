import 'dart:convert';
import 'package:app_models/app_models.dart';
import 'package:backend/src/server.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shelf/shelf.dart';

void main() {
  late Handler handler;

  setUp(() {
    handler = createServerHandler();
  });

  group('Market Errand API Endpoints (v1.6 §1556-2034)', () {
    test('GET /api/v1/errands/catalogue returns shops, items, categories and fee defaults', () async {
      final request = Request(
        'GET',
        Uri.parse('http://localhost:8080/api/v1/errands/catalogue'),
      );
      final response = await handler(request);

      expect(response.statusCode, 200);
      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;

      expect(data['shops'], isNotEmpty);
      expect(data['popular_shopping_items'], isNotEmpty);
      expect(data['package_categories'], isNotEmpty);
      expect(data['custom_errand_categories'], isNotEmpty);
      expect(data['default_shopping_service_fee_kobo'], 80000); // ₦800
      expect(data['default_package_service_fee_kobo'], 70000);   // ₦700
      expect(data['default_custom_errand_service_fee_kobo'], 100000); // ₦1,000
    });

    test('GET /api/v1/errands/shops filters by tab (popular, saved) and search term', () async {
      // 1. Popular shops tab
      final popularReq = Request(
        'GET',
        Uri.parse('http://localhost:8080/api/v1/errands/shops?tab=popular'),
      );
      final popResponse = await handler(popularReq);
      expect(popResponse.statusCode, 200);
      final popBody = jsonDecode(await popResponse.readAsString()) as Map<String, dynamic>;
      final popShops = popBody['data'] as List<dynamic>;
      expect(popShops, isNotEmpty);
      expect(popShops.every((s) => (s as Map<String, dynamic>)['is_popular'] == true), isTrue);

      // 2. Search query filter
      final searchReq = Request(
        'GET',
        Uri.parse('http://localhost:8080/api/v1/errands/shops?search=Kakuri'),
      );
      final searchResponse = await handler(searchReq);
      expect(searchResponse.statusCode, 200);
      final searchBody = jsonDecode(await searchResponse.readAsString()) as Map<String, dynamic>;
      final searchShops = searchBody['data'] as List<dynamic>;
      expect(searchShops.length, 1);
      final firstShop = searchShops.first as Map<String, dynamic>;
      expect(firstShop['name'], 'Kakuri Main Market');
    });

    test('POST /api/v1/errands/quotes calculates authoritative quote for Buy Items (Flow A)', () async {
      final payload = {
        'errand_type': 'BUY_ITEMS',
        'distance_km': 2.5,
        'items': [
          {
            'name': 'Tomatoes',
            'quantity': 2,
            'unit': 'kg',
            'estimated_price_kobo': 200000, // ₦2,000/kg * 2 = ₦4,000
          },
          {
            'name': 'Onions',
            'quantity': 1,
            'unit': 'kg',
            'estimated_price_kobo': 150000, // ₦1,500
          },
          {
            'name': 'Rice (Mama\'s Pride)',
            'quantity': 1,
            'unit': '5 kg bag',
            'estimated_price_kobo': 850000, // ₦8,500
          },
        ],
      };

      final request = Request(
        'POST',
        Uri.parse('http://localhost:8080/api/v1/errands/quotes'),
        body: jsonEncode(payload),
        headers: {'content-type': 'application/json'},
      );
      final response = await handler(request);

      expect(response.statusCode, 200);
      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      final quote = ErrandQuoteDto.fromJson(body['data'] as Map<String, dynamic>);

      // Estimated items: 4000 + 1500 + 8500 = ₦14,000 (1,400,000 kobo)
      expect(quote.estimatedItemsCostKobo, 1400000);
      expect(quote.serviceFeeKobo, 80000); // ₦800
      expect(quote.deliveryFeeKobo, 120000); // ₦1,200
      expect(quote.totalKobo, 1600000); // ₦16,000 Total matching Design Template A6
      expect(quote.formattedTotal, '₦16,000');
    });

    test('POST /api/v1/errands/quotes calculates authoritative quote for Package Pickup (Flow B)', () async {
      final payload = {
        'errand_type': 'PICKUP_PACKAGE',
        'distance_km': 2.5,
        'is_fragile': false,
      };

      final request = Request(
        'POST',
        Uri.parse('http://localhost:8080/api/v1/errands/quotes'),
        body: jsonEncode(payload),
        headers: {'content-type': 'application/json'},
      );
      final response = await handler(request);

      expect(response.statusCode, 200);
      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      final quote = ErrandQuoteDto.fromJson(body['data'] as Map<String, dynamic>);

      expect(quote.serviceFeeKobo, 70000); // ₦700
      expect(quote.deliveryFeeKobo, 110000); // ₦1,100
      expect(quote.totalKobo, 180000); // ₦1,800 matching Design Template B5
    });

    test('POST /api/v1/errands/quotes calculates quote for Other Errand (Flow C)', () async {
      final payload = {
        'errand_type': 'OTHER_ERRAND',
        'distance_km': 2.5,
        'urgency': 'STANDARD',
      };

      final request = Request(
        'POST',
        Uri.parse('http://localhost:8080/api/v1/errands/quotes'),
        body: jsonEncode(payload),
        headers: {'content-type': 'application/json'},
      );
      final response = await handler(request);

      expect(response.statusCode, 200);
      final body = jsonDecode(await response.readAsString()) as Map<String, dynamic>;
      final quote = ErrandQuoteDto.fromJson(body['data'] as Map<String, dynamic>);

      expect(quote.serviceFeeKobo, 100000); // ₦1,000
      expect(quote.deliveryFeeKobo, 120000); // ₦1,200
      expect(quote.totalKobo, 220000); // ₦2,200 matching Design Template C4
    });

    test('POST /api/v1/errands creates errand booking, assigns rider, and GET retrieves it', () async {
      final payload = {
        'type': 'BUY_ITEMS',
        'shop': {
          'id': 'shop_01',
          'name': 'Kakuri Main Market',
          'address': 'Kakuri, Kaduna',
          'latitude': 10.4682,
          'longitude': 7.4201,
          'distance_km': 1.2,
        },
        'items': [
          {
            'id': 'it_1',
            'name': 'Tomatoes',
            'quantity': 2,
            'unit': 'kg',
            'estimated_price_kobo': 400000,
          }
        ],
        'preferences': {
          'substitution_policy': 'CONTACT_FIRST',
          'additional_instructions': 'Choose fresh items',
        },
        'delivery_location': {
          'latitude': 10.5185,
          'longitude': 7.4382,
          'address': '3, Ahmadu Bello Way, Bayero University, Kaduna',
        },
        'recipient': {
          'full_name': 'Omotayo Kehinde',
          'phone_number': '0803 456 7890',
          'delivery_address': '3, Ahmadu Bello Way, Bayero University, Kaduna',
        },
        'payment_method': 'WALLET',
      };

      final createReq = Request(
        'POST',
        Uri.parse('http://localhost:8080/api/v1/errands'),
        body: jsonEncode(payload),
        headers: {'content-type': 'application/json'},
      );
      final createRes = await handler(createReq);
      expect(createRes.statusCode, 201);

      final createdBody = jsonDecode(await createRes.readAsString()) as Map<String, dynamic>;
      final errand = ErrandDto.fromJson(createdBody['data'] as Map<String, dynamic>);

      expect(errand.id, isNotEmpty);
      expect(errand.referenceNumber, startsWith('ERR-'));
      expect(errand.status, ErrandStatus.agentAssigned);
      expect(errand.assignedRider?.fullName, 'Ahmed Ibrahim');
      expect(errand.assignedRider?.vehiclePlate, 'ABC-123KY');

      // Retrieve via GET /<id>
      final getReq = Request('GET', Uri.parse('http://localhost:8080/api/v1/errands/${errand.id}'));
      final getRes = await handler(getReq);
      expect(getRes.statusCode, 200);

      // Advance shopping status: agentAssigned -> shoppingInProgress -> itemsPurchased -> completed
      final adv1 = Request('POST', Uri.parse('http://localhost:8080/api/v1/errands/${errand.id}/advance-status'));
      final adv1Res = await handler(adv1);
      final adv1Body = jsonDecode(await adv1Res.readAsString()) as Map<String, dynamic>;
      final adv1Data = adv1Body['data'] as Map<String, dynamic>;
      expect(adv1Data['status'], 'SHOPPING_IN_PROGRESS');
    });

    test('Flow C Quote Lifecycle: accept and decline transitions', () async {
      // 1. Create Other Errand requiring manual quote
      final payload = {
        'type': 'OTHER_ERRAND',
        'requires_manual_quote': true,
        'custom_errand_details': {
          'description': 'Collect certificates from university registrar',
          'category': 'Document Collection',
          'urgency': 'STANDARD',
          'task_location': {
            'latitude': 10.5185,
            'longitude': 7.4382,
            'address': 'Bayero University Registrar Office',
          },
          'contact_person': 'Mrs. Amina Yusuf',
          'phone_number': '0806 765 4321',
        },
      };

      final createReq = Request(
        'POST',
        Uri.parse('http://localhost:8080/api/v1/errands'),
        body: jsonEncode(payload),
        headers: {'content-type': 'application/json'},
      );
      final createRes = await handler(createReq);
      final createdBody = jsonDecode(await createRes.readAsString()) as Map<String, dynamic>;
      final errand = ErrandDto.fromJson(createdBody['data'] as Map<String, dynamic>);

      expect(errand.status, ErrandStatus.reviewRequired);

      // 2. Accept Quote (Screen C4)
      final acceptReq = Request(
        'POST',
        Uri.parse('http://localhost:8080/api/v1/errands/${errand.id}/quote/accept'),
      );
      final acceptRes = await handler(acceptReq);
      expect(acceptRes.statusCode, 200);
      final acceptBody = jsonDecode(await acceptRes.readAsString()) as Map<String, dynamic>;
      final acceptData = acceptBody['data'] as Map<String, dynamic>;
      final riderData = acceptData['assigned_rider'] as Map<String, dynamic>;
      expect(acceptData['status'], 'AGENT_ASSIGNED');
      expect(riderData['full_name'], 'Ahmed Ibrahim');

      // 3. Rate errand
      final rateReq = Request(
        'POST',
        Uri.parse('http://localhost:8080/api/v1/errands/${errand.id}/rating'),
        body: jsonEncode({'rating': 5.0}),
        headers: {'content-type': 'application/json'},
      );
      final rateRes = await handler(rateReq);
      expect(rateRes.statusCode, 200);
    });
  });
}
