import 'dart:convert';
import 'package:backend/src/routes/partner_route.dart';
import 'package:backend/src/server.dart';
import 'package:backend/src/shared/partner_database.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

void main() {
  group('E-Commerce Sandbox End-to-End Simulation', () {
    late InMemoryPartnerDatabase db;
    late Handler handler;
    const partnerKey = 'volt_test_99a1b2c3d4e5f60718293a4b5c6d7e8';
    const partnerSecret = 'whsec_908f7e6d5c4b3a210fedcba987654321';
    const partnerIntegrationId = '11111111-2222-3333-4444-555555555555';

    setUp(() {
      db = InMemoryPartnerDatabase();
      handler = createServerHandler(partnerDatabase: db);
    });

    test('Full E-Commerce Sandbox Lifecycle: Checkout -> Quoting -> Idempotent Dispatch -> EV Telematics -> Signed Webhook -> OTP Delivery', () async {
      // -----------------------------------------------------------------------
      // STAGE 1: E-Commerce Customer Checkout & Instant Quote
      // -----------------------------------------------------------------------
      final quoteReq = Request(
        'POST',
        Uri.parse('http://localhost:8080/partner/v1/deliveries/quotes'),
        body: jsonEncode({
          'pickup_zone': 'Lekki Phase 1',
          'delivery_zone': 'Victoria Island',
          'package_category': 'Consumer Electronics',
          'weight_kg': 1.8,
        }),
        headers: {
          'content-type': 'application/json',
          'authorization': 'Bearer $partnerKey',
        },
      );

      final quoteRes = await handler(quoteReq);
      expect(quoteRes.statusCode, 200);

      final quoteJson = jsonDecode(await quoteRes.readAsString()) as Map<String, dynamic>;
      final quoteData = quoteJson['data'] as Map<String, dynamic>;
      final quotedFareKobo = quoteData['gross_fare_kobo'] as int;
      expect(quotedFareKobo, 285000); // ₦2,850.00

      // -----------------------------------------------------------------------
      // STAGE 2: E-Commerce Dispatches Order with Idempotency Key
      // -----------------------------------------------------------------------
      const idempotencyKey = 'idem_ecom_order_checkout_77819';
      const externalOrderRef = 'ORD-SHOPNOW-77819';

      final initialWalletBalance = db.getWalletBalance(partnerIntegrationId);
      expect(initialWalletBalance, 50000000); // ₦500,000.00 initial credit

      final dispatchReq = Request(
        'POST',
        Uri.parse('http://localhost:8080/partner/v1/deliveries'),
        body: jsonEncode({
          'external_reference': externalOrderRef,
          'recipient_name': 'Amaka Okonkwo',
          'recipient_phone': '+2348031234567',
          'pickup_address': 'ShopNow Hub, 14 Admiralty Way, Lekki Phase 1',
          'delivery_address': 'Plot 22, Karimu Kotun St, Victoria Island, Lagos',
          'gross_fare_kobo': quotedFareKobo,
          'instructions': 'Call recipient on arrival. Deliver to 2nd Floor.',
        }),
        headers: {
          'content-type': 'application/json',
          'authorization': 'Bearer $partnerKey',
          'idempotency-key': idempotencyKey,
          'external-reference': externalOrderRef,
        },
      );

      final dispatchRes = await handler(dispatchReq);
      expect(dispatchRes.statusCode, 201);

      final dispatchJson = jsonDecode(await dispatchRes.readAsString()) as Map<String, dynamic>;
      final deliveryData = dispatchJson['data'] as Map<String, dynamic>;
      final trackingRef = deliveryData['tracking_reference'] as String;
      final deliveryOtp = deliveryData['recipient_otp'] as String;

      expect(trackingRef, startsWith('GV-DEL-'));
      expect(deliveryOtp, isNotEmpty);
      expect(deliveryData['status'], 'SEARCHING_RIDER');
      expect(deliveryData['remaining_balance_kobo'], initialWalletBalance - quotedFareKobo);

      // Verify atomic wallet deduction in database
      final updatedBalance = db.getWalletBalance(partnerIntegrationId);
      expect(updatedBalance, initialWalletBalance - quotedFareKobo);

      // -----------------------------------------------------------------------
      // STAGE 3: Idempotency Replay (Zero Double-Charging)
      // -----------------------------------------------------------------------
      final replayReq = Request(
        'POST',
        Uri.parse('http://localhost:8080/partner/v1/deliveries'),
        body: jsonEncode({
          'external_reference': externalOrderRef,
          'recipient_name': 'Amaka Okonkwo',
          'recipient_phone': '+2348031234567',
          'pickup_address': 'ShopNow Hub, 14 Admiralty Way, Lekki Phase 1',
          'delivery_address': 'Plot 22, Karimu Kotun St, Victoria Island, Lagos',
          'gross_fare_kobo': quotedFareKobo,
        }),
        headers: {
          'content-type': 'application/json',
          'authorization': 'Bearer $partnerKey',
          'idempotency-key': idempotencyKey,
          'external-reference': externalOrderRef,
        },
      );

      final replayRes = await handler(replayReq);
      expect(replayRes.statusCode, 200); // Replay returns 200 OK

      final replayJson = jsonDecode(await replayRes.readAsString()) as Map<String, dynamic>;
      final replayMeta = replayJson['meta'] as Map<String, dynamic>;
      expect(replayMeta['idempotent_replay'], isTrue);

      // Wallet balance must NOT have been deducted a second time
      expect(db.getWalletBalance(partnerIntegrationId), updatedBalance);

      // -----------------------------------------------------------------------
      // STAGE 4: Rider Assignment & Telematics Dispatch
      // -----------------------------------------------------------------------
      final telematicsUpdate = await db.updateDeliveryTelemetry(
        trackingReference: trackingRef,
        telemetry: {
          'status': 'IN_PROGRESS',
          'rider_name': 'Babatunde Adeleke',
          'vehicle_plate': 'LAG-882-VOLT',
          'battery_soc': 94,
        },
      );
      expect(telematicsUpdate, isNotNull);
      expect(telematicsUpdate!['status'], 'IN_PROGRESS');
      expect(telematicsUpdate['assigned_rider'], 'Babatunde Adeleke');

      // -----------------------------------------------------------------------
      // STAGE 5: Webhook Outbox Delivery with HMAC-SHA256 Signature Verification
      // -----------------------------------------------------------------------
      final webhookPayload = {
        'event': 'delivery.rider_assigned.v1',
        'event_id': 'evt_sim_991823',
        'tracking_reference': trackingRef,
        'external_reference': externalOrderRef,
        'status': 'ASSIGNED',
        'driver': {
          'name': 'Babatunde Adeleke',
          'vehicle_reg': 'LAG-882-VOLT',
          'battery_soc': 94,
        },
        'timestamp': DateTime.now().toUtc().toIso8601String(),
      };

      final rawWebhookBody = jsonEncode(webhookPayload);
      final currentTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      final signature = computePartnerHmacSignature(
        secret: partnerSecret,
        timestamp: currentTimestamp,
        rawPayload: rawWebhookBody,
      );

      bool ecomListenerReceived = false;
      final mockEcomListener = MockClient((request) async {
        expect(request.url.toString(), 'https://store.shopnow.ng/api/webhooks/govolts');
        expect(request.headers['x-govolts-signature'], signature);
        expect(request.headers['x-govolts-event-type'], 'delivery.rider_assigned.v1');

        // E-Commerce platform verifies HMAC signature
        final isVerified = verifyPartnerHmacSignature(
          secret: partnerSecret,
          timestamp: int.parse(request.headers['x-govolts-timestamp']!),
          rawPayload: request.body,
          signatureHeader: request.headers['x-govolts-signature']!,
        );
        expect(isVerified, isTrue);

        ecomListenerReceived = true;
        return http.Response(jsonEncode({'status': 'ack', 'order_status': 'RIDER_ASSIGNED'}), 200);
      });

      final webhookPostRes = await mockEcomListener.post(
        Uri.parse('https://store.shopnow.ng/api/webhooks/govolts'),
        headers: {
          'Content-Type': 'application/json',
          'X-GoVolts-Signature': signature,
          'X-GoVolts-Timestamp': currentTimestamp.toString(),
          'X-GoVolts-Event-Id': 'evt_sim_991823',
          'X-GoVolts-Event-Type': 'delivery.rider_assigned.v1',
        },
        body: rawWebhookBody,
      );

      expect(webhookPostRes.statusCode, 200);
      expect(ecomListenerReceived, isTrue);

      // -----------------------------------------------------------------------
      // STAGE 6: OTP Proof of Delivery & Completion
      // -----------------------------------------------------------------------
      // Customer provides OTP to rider upon handoff
      expect(deliveryOtp, '4912');

      final finalDelivery = await db.getDelivery(trackingRef);
      expect(finalDelivery, isNotNull);
      expect(finalDelivery!['tracking_reference'], trackingRef);
      expect(finalDelivery['status'], 'IN_PROGRESS');

      // -----------------------------------------------------------------------
      // STAGE 7: Insufficient Corporate Wallet Balance Protection
      // -----------------------------------------------------------------------
      // Drain wallet to ₦500.00
      db.setWalletBalance(partnerIntegrationId, 50000);

      final overDraftReq = Request(
        'POST',
        Uri.parse('http://localhost:8080/partner/v1/deliveries'),
        body: jsonEncode({
          'external_reference': 'ORD-SHOPNOW-EXPENSIVE',
          'recipient_name': 'Kolawole Sanusi',
          'recipient_phone': '+2348099887766',
          'gross_fare_kobo': 320000, // ₦3,200.00 > ₦500.00
        }),
        headers: {
          'content-type': 'application/json',
          'authorization': 'Bearer $partnerKey',
        },
      );

      final overDraftRes = await handler(overDraftReq);
      expect(overDraftRes.statusCode, 402); // 402 Payment Required

      final overDraftJson = jsonDecode(await overDraftRes.readAsString()) as Map<String, dynamic>;
      final err = overDraftJson['error'] as Map<String, dynamic>;
      expect(err['code'], 'INSUFFICIENT_WALLET_BALANCE');
      expect(err['available_balance_kobo'], 50000);
      expect(err['required_fare_kobo'], 320000);

      // -----------------------------------------------------------------------
      // STAGE 8: Order Cancellation & Corporate Wallet Auto-Refund
      // -----------------------------------------------------------------------
      db.setWalletBalance(partnerIntegrationId, 1000000); // ₦10,000.00
      final preDispatchBalance = db.getWalletBalance(partnerIntegrationId);

      final cancelOrderReq = Request(
        'POST',
        Uri.parse('http://localhost:8080/partner/v1/deliveries'),
        body: jsonEncode({
          'external_reference': 'ORD-SHOPNOW-CANCEL-ME',
          'recipient_name': 'Seyi Makinde',
          'recipient_phone': '+2348033221100',
          'pickup_address': 'ShopNow Hub, Lekki Phase 1',
          'delivery_address': 'Plot 4, Ikoyi, Lagos',
          'gross_fare_kobo': 285000,
        }),
        headers: {
          'content-type': 'application/json',
          'authorization': 'Bearer $partnerKey',
        },
      );
      final cancelOrderRes = await handler(cancelOrderReq);
      expect(cancelOrderRes.statusCode, 201);
      final cancelOrderData = (jsonDecode(await cancelOrderRes.readAsString()) as Map<String, dynamic>)['data'] as Map<String, dynamic>;
      final cancelTrackingRef = cancelOrderData['tracking_reference'] as String;
      expect(db.getWalletBalance(partnerIntegrationId), preDispatchBalance - 285000);

      // Now cancel via POST /partner/v1/deliveries/<ref>/cancel
      final cancelActionReq = Request(
        'POST',
        Uri.parse('http://localhost:8080/partner/v1/deliveries/$cancelTrackingRef/cancel'),
        headers: {
          'content-type': 'application/json',
          'authorization': 'Bearer $partnerKey',
        },
      );
      final cancelActionRes = await handler(cancelActionReq);
      expect(cancelActionRes.statusCode, 200);

      // Corporate wallet should be refunded back to preDispatchBalance
      expect(db.getWalletBalance(partnerIntegrationId), preDispatchBalance);

      // -----------------------------------------------------------------------
      // STAGE 9: Cryptographic Security & Anti-Tamper Verification
      // -----------------------------------------------------------------------
      final validPayload = jsonEncode({'order_id': 'ORD-123', 'status': 'ASSIGNED'});
      final validTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final validSig = computePartnerHmacSignature(
        secret: partnerSecret,
        timestamp: validTimestamp,
        rawPayload: validPayload,
      );

      // Tampered payload with 1 altered character must be rejected
      final tamperedPayload = jsonEncode({'order_id': 'ORD-123', 'status': 'DELIVERED'});
      final isTamperedValid = verifyPartnerHmacSignature(
        secret: partnerSecret,
        timestamp: validTimestamp,
        rawPayload: tamperedPayload,
        signatureHeader: validSig,
      );
      expect(isTamperedValid, isFalse);

      // Invalid secret key must be rejected
      final isWrongSecretValid = verifyPartnerHmacSignature(
        secret: 'whsec_attacker_fake_key_999999',
        timestamp: validTimestamp,
        rawPayload: validPayload,
        signatureHeader: validSig,
      );
      expect(isWrongSecretValid, isFalse);

      // -----------------------------------------------------------------------
      // STAGE 10: Ingest Live Rider Telematics via API Endpoint
      // -----------------------------------------------------------------------
      final telemetryEndpointReq = Request(
        'POST',
        Uri.parse('http://localhost:8080/partner/v1/deliveries/$trackingRef/telemetry'),
        body: jsonEncode({
          'rider_name': 'Emeka Obi',
          'vehicle_plate': 'LAG-441-VOLT',
          'battery_soc': 88,
          'latitude': 6.4310,
          'longitude': 3.4280,
          'status': 'IN_TRANSIT',
        }),
        headers: {
          'content-type': 'application/json',
          'authorization': 'Bearer $partnerKey',
        },
      );
      final telemetryEndpointRes = await handler(telemetryEndpointReq);
      expect(telemetryEndpointRes.statusCode, 200);

      // Verify delivery record reflects updated telematics
      final updatedDel = await db.getDelivery(trackingRef);
      final tele = updatedDel!['telemetry'] as Map<String, dynamic>;
      expect(tele['battery_soc'], 88);
      expect(tele['latitude'], 6.4310);
      expect(updatedDel['status'], 'IN_TRANSIT');
    });
  });
}
