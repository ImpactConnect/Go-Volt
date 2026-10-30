import 'dart:convert';
import 'package:backend/src/routes/partner_route.dart';
import 'package:backend/src/server.dart';
import 'package:backend/src/shared/partner_database.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shelf/shelf.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Partner API & Webhook Production Readiness Tests', () {
    test('computePartnerHmacSignature and verifyPartnerHmacSignature produce matching signatures', () {
      const secret = 'whsec_test_secret_1234567890abcdef';
      const timestamp = 1793200000;
      const rawPayload = '{"event":"delivery.rider_assigned.v1","booking_id":"bk_001"}';

      final signature = computePartnerHmacSignature(
        secret: secret,
        timestamp: timestamp,
        rawPayload: rawPayload,
      );

      expect(signature, startsWith('sha256='));

      final isValid = verifyPartnerHmacSignature(
        secret: secret,
        timestamp: timestamp,
        rawPayload: rawPayload,
        signatureHeader: signature,
      );

      expect(isValid, isTrue);

      final isTamperedValid = verifyPartnerHmacSignature(
        secret: secret,
        timestamp: timestamp,
        rawPayload: '{"event":"tampered"}',
        signatureHeader: signature,
      );

      expect(isTamperedValid, isFalse);
    });

    test('PartnerDatabase validates API key prefix and hash correctly', () async {
      final db = InMemoryPartnerDatabase();

      final validContext = await db.validateApiKey('volt_test_99a1b2c3d4e5f60718293a4b5c6d7e8');
      expect(validContext, isNotNull);
      expect(validContext!.displayName, 'Retail AI Sandbox');
      expect(validContext.hasScope('deliveries:create'), isTrue);
      expect(validContext.hasScope('superadmin:access'), isFalse);

      final invalidContext = await db.validateApiKey('volt_fake_invalid_key_99999999');
      expect(invalidContext, isNull);
    });

    test('partnerRouter rejects requests with invalid API key', () async {
      final db = InMemoryPartnerDatabase();
      final handler = createServerHandler(partnerDatabase: db);

      final req = Request(
        'POST',
        Uri.parse('http://localhost:8080/partner/v1/deliveries/quotes'),
        body: jsonEncode({'pickup_zone': 'Lekki Phase 1'}),
        headers: {
          'content-type': 'application/json',
          'authorization': 'Bearer volt_invalid_fake_key_000',
        },
      );

      final res = await handler(req);
      expect(res.statusCode, 401);

      final body = jsonDecode(await res.readAsString()) as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'UNAUTHORIZED');
    });

    test('partnerRouter accepts valid Bearer token and creates persistent delivery with OTP', () async {
      final db = InMemoryPartnerDatabase();
      final handler = createServerHandler(partnerDatabase: db);

      final req = Request(
        'POST',
        Uri.parse('http://localhost:8080/partner/v1/deliveries'),
        body: jsonEncode({
          'recipient_name': 'Amina Bello',
          'external_reference': 'ECOM-ORDER-1001',
          'delivery_address': 'Victoria Island, Lagos',
          'gross_fare_kobo': 285000,
        }),
        headers: {
          'content-type': 'application/json',
          'authorization': 'Bearer volt_test_99a1b2c3d4e5f60718293a4b5c6d7e8',
          'idempotency-key': 'idem_key_test_001',
        },
      );

      final res = await handler(req);
      expect(res.statusCode, 201);

      final body = jsonDecode(await res.readAsString()) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      expect(data['recipient_name'], 'Amina Bello');
      expect(data['recipient_otp'], isNotNull);
      expect(data['external_reference'], 'ECOM-ORDER-1001');

      // Check delivery can be retrieved via GET
      final trackingRef = data['tracking_reference'] as String;
      final getReq = Request(
        'GET',
        Uri.parse('http://localhost:8080/partner/v1/deliveries/$trackingRef'),
      );
      final getRes = await handler(getReq);
      expect(getRes.statusCode, 200);
    });

    test('Webhook dispatch simulation verifies HTTP client receives valid HMAC signature', () async {
      const partnerSecret = 'whsec_ecom_partner_9921';
      const eventPayload = {
        'id': 'evt_99120',
        'type': 'delivery.rider_assigned.v1',
        'data': {
          'delivery_id': 'del_1001',
          'rider_name': 'Musa Ibrahim',
          'vehicle_plate': 'LAG-102',
        }
      };

      final rawBody = jsonEncode(eventPayload);
      final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final expectedSignature = computePartnerHmacSignature(
        secret: partnerSecret,
        timestamp: timestamp,
        rawPayload: rawBody,
      );

      bool webhookReceived = false;
      final mockClient = MockClient((request) async {
        expect(request.url.toString(), 'https://api.partner.ng/webhooks');
        expect(request.headers['x-govolts-signature'], expectedSignature);
        expect(request.headers['x-govolts-event-type'], 'delivery.rider_assigned.v1');
        webhookReceived = true;
        return http.Response(jsonEncode({'received': true}), 200);
      });

      final response = await mockClient.post(
        Uri.parse('https://api.partner.ng/webhooks'),
        headers: {
          'Content-Type': 'application/json',
          'X-GoVolts-Signature': expectedSignature,
          'X-GoVolts-Timestamp': timestamp.toString(),
          'X-GoVolts-Event-Id': 'evt_99120',
          'X-GoVolts-Event-Type': 'delivery.rider_assigned.v1',
        },
        body: rawBody,
      );

      expect(response.statusCode, 200);
      expect(webhookReceived, isTrue);
    });

    test('Corporate wallet balance is debited upon delivery dispatch', () async {
      final db = InMemoryPartnerDatabase();
      final partner = InMemoryPartnerDatabase.defaultPartner;

      final initialBalance = db.getWalletBalance(partner.integrationId);
      expect(initialBalance, 50000000); // ₦500,000.00

      final delivery = await db.createDeliveryBooking(
        partner: partner,
        deliveryInput: {
          'gross_fare_kobo': 250000, // ₦2,500.00
          'external_reference': 'TEST-ORDER-WAL-01',
        },
      );

      expect(delivery['remaining_balance_kobo'], 49750000);
      expect(db.getWalletBalance(partner.integrationId), 49750000);
    });

    test('partnerRouter rejects delivery creation with 402 Payment Required when wallet balance is insufficient', () async {
      final db = InMemoryPartnerDatabase();
      final partner = InMemoryPartnerDatabase.defaultPartner;
      // Set balance to only 100,000 kobo (₦1,000.00)
      db.setWalletBalance(partner.integrationId, 100000);

      final handler = createServerHandler(partnerDatabase: db);

      final req = Request(
        'POST',
        Uri.parse('http://localhost:8080/partner/v1/deliveries'),
        body: jsonEncode({
          'pickup_address': 'Store A',
          'delivery_address': 'Customer B',
          'recipient_name': 'Amaka Okonkwo',
          'recipient_phone': '+2348011223344',
          'gross_fare_kobo': 350000, // ₦3,500.00 > ₦1,000.00
        }),
        headers: {
          'content-type': 'application/json',
          'authorization': 'Bearer volt_test_99a1b2c3d4e5f60718293a4b5c6d7e8',
        },
      );

      final res = await handler(req);
      expect(res.statusCode, 402);

      final body = jsonDecode(await res.readAsString()) as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], 'INSUFFICIENT_WALLET_BALANCE');
      expect(error['available_balance_kobo'], 100000);
      expect(error['required_fare_kobo'], 350000);
    });
  });
}
