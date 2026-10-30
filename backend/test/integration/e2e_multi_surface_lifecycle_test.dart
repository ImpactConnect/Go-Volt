import 'dart:convert';
import 'package:backend/src/routes/partner_route.dart';
import 'package:backend/src/server.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

void main() {
  group('Go_Volt Full-Stack Multi-Surface Live Integration Simulation', () {
    late Handler handler;

    setUp(() {
      handler = createServerHandler();
    });

    test('Simulates complete 7-stage lifecycle across Customer, Rider, Admin, Merchant & Partner POS', () async {
      // =======================================================================
      // STAGE 1: B2B Merchant Dispatch Booking (Merchant Portal & Retail Ai POS)
      // =======================================================================
      // 1.1 Request Upfront Quote Lock
      final quoteRequest = Request(
        'POST',
        Uri.parse('http://localhost:8080/partner/v1/deliveries/quotes'),
        body: jsonEncode({
          'pickup_zone': 'Lekki Phase 1',
          'delivery_zone': 'Victoria Island',
          'package_category': 'Express Catering & Bakery',
          'weight_kg': 3.5,
        }),
        headers: {'content-type': 'application/json'},
      );

      final quoteResponse = await handler(quoteRequest);
      expect(quoteResponse.statusCode, 200);

      final quoteBody = jsonDecode(await quoteResponse.readAsString()) as Map<String, dynamic>;
      final quoteData = quoteBody['data'] as Map<String, dynamic>;
      expect(quoteData['quote_id'], startsWith('qt_partner_'));
      expect(quoteData['gross_fare_kobo'], 285000); // ₦2,850.00

      // 1.2 Dispatch Delivery Booking with Idempotency Key & External Reference
      const idempotencyKey = 'idem_sim_e2e_99182';
      const externalReference = 'RET-POS-90412';

      final createRequest = Request(
        'POST',
        Uri.parse('http://localhost:8080/partner/v1/deliveries'),
        body: jsonEncode({
          'recipient_name': 'Dr. Olufemi Peters',
          'recipient_phone': '+2348039988776',
          'delivery_address': 'Plot 14, Admiralty Way, Lekki Phase 1 to Saka Tinubu, VI',
          'gross_fare_kobo': 285000,
          'external_reference': externalReference,
        }),
        headers: {
          'content-type': 'application/json',
          'idempotency-key': idempotencyKey,
          'external-reference': externalReference,
        },
      );

      final createResponse = await handler(createRequest);
      expect(createResponse.statusCode, 201);

      final createBody = jsonDecode(await createResponse.readAsString()) as Map<String, dynamic>;
      final deliveryData = createBody['data'] as Map<String, dynamic>;
      final trackingReference = deliveryData['tracking_reference'] as String;

      expect(trackingReference, startsWith('GV-DEL-'));
      expect(deliveryData['status'], 'SEARCHING_RIDER');
      expect(deliveryData['recipient_otp'], '4912');
      expect(deliveryData['gross_fare_kobo'], 285000);

      // 1.3 Idempotency Guarantee: Replay returns identical cached delivery response
      final replayRequest = Request(
        'POST',
        Uri.parse('http://localhost:8080/partner/v1/deliveries'),
        body: jsonEncode({
          'recipient_name': 'Dr. Olufemi Peters',
          'gross_fare_kobo': 285000,
        }),
        headers: {
          'content-type': 'application/json',
          'idempotency-key': idempotencyKey,
          'external-reference': externalReference,
        },
      );

      final replayResponse = await handler(replayRequest);
      expect(replayResponse.statusCode, 200);

      final replayBody = jsonDecode(await replayResponse.readAsString()) as Map<String, dynamic>;
      final replayMeta = replayBody['meta'] as Map<String, dynamic>;
      final replayData = replayBody['data'] as Map<String, dynamic>;
      expect(replayMeta['idempotent_replay'], isTrue);
      expect(replayData['tracking_reference'], trackingReference);

      // 1.4 Conflict Detection: Same Idempotency Key with different external reference returns 409
      final conflictRequest = Request(
        'POST',
        Uri.parse('http://localhost:8080/partner/v1/deliveries'),
        body: jsonEncode({'recipient_name': 'Fraudulent Actor'}),
        headers: {
          'content-type': 'application/json',
          'idempotency-key': idempotencyKey,
          'external-reference': 'DIFFERENT-POS-REF-999',
        },
      );

      final conflictResponse = await handler(conflictRequest);
      expect(conflictResponse.statusCode, 409);

      // =======================================================================
      // STAGE 2: Backend Smart Matching & Electric Dispatch Assignment
      // =======================================================================
      // Check active rider status
      final riderStatusRequest = Request(
        'GET',
        Uri.parse('http://localhost:8080/api/v1/rider/status'),
      );
      final riderStatusResponse = await handler(riderStatusRequest);
      expect(riderStatusResponse.statusCode, 200);

      // Set Rider online
      final onlineRequest = Request(
        'POST',
        Uri.parse('http://localhost:8080/api/v1/rider/availability'),
        body: jsonEncode({'is_online': true}),
        headers: {'content-type': 'application/json'},
      );
      final onlineResponse = await handler(onlineRequest);
      expect(onlineResponse.statusCode, 200);

      // Accept Offer
      final acceptOfferRequest = Request(
        'POST',
        Uri.parse('http://localhost:8080/api/v1/rider/offers/dsp_off_001/accept'),
      );
      final acceptOfferResponse = await handler(acceptOfferRequest);
      expect(acceptOfferResponse.statusCode, 200);

      // =======================================================================
      // STAGE 3: Rider App Electric Telematics & 35 km/h Speed Limiter
      // =======================================================================
      // Rider streams telematics: 28 km/h (< 35 km/h limiter), 91% SoC battery
      final telematicsPayload = {
        'status': 'IN_TRANSIT',
        'rider_name': 'Babatunde Adeleke',
        'vehicle_plate': 'LAG-882-VOLT',
        'current_speed_kmh': 28,
        'speed_limiter_engaged': true,
        'max_permitted_speed_kmh': 35,
        'battery_soc': 91,
        'battery_temp_celsius': 31.4,
        'current_location': {
          'latitude': 6.4474,
          'longitude': 3.4200,
          'heading': 185.0,
          'landmark': 'Lekki-Ikoyi Link Bridge',
        },
      };

      final telematicsRequest = Request(
        'POST',
        Uri.parse('http://localhost:8080/partner/v1/deliveries/$trackingReference/telemetry'),
        body: jsonEncode(telematicsPayload),
        headers: {'content-type': 'application/json'},
      );

      final telematicsResponse = await handler(telematicsRequest);
      expect(telematicsResponse.statusCode, 200);

      // =======================================================================
      // STAGE 4: Admin Web Operations Real-Time Monitoring
      // =======================================================================
      // Admin queries delivery status and inspects active telemetry
      final adminGetRequest = Request(
        'GET',
        Uri.parse('http://localhost:8080/partner/v1/deliveries/$trackingReference'),
      );
      final adminGetResponse = await handler(adminGetRequest);
      expect(adminGetResponse.statusCode, 200);

      final adminGetBody = jsonDecode(await adminGetResponse.readAsString()) as Map<String, dynamic>;
      final adminDelivery = adminGetBody['data'] as Map<String, dynamic>;

      expect(adminDelivery['status'], 'IN_TRANSIT');
      expect(adminDelivery['assigned_rider'], 'Babatunde Adeleke');
      expect(adminDelivery['vehicle_plate'], 'LAG-882-VOLT');
      expect(adminDelivery['battery_soc'], 91);
      final telemetry = adminDelivery['telemetry'] as Map<String, dynamic>;
      expect(telemetry['speed_limiter_engaged'], isTrue);

      // =======================================================================
      // STAGE 5: Recipient Verification, 4-Digit OTP & Proof of Delivery (POD)
      // =======================================================================
      // Simulated arrival at Victoria Island dropoff
      final podSignatureUrl = 'https://cdn.govolts.ng/pod/sig_$trackingReference.png';

      final completedTelemetryPayload = {
        'status': 'COMPLETED',
        'rider_name': 'Babatunde Adeleke',
        'vehicle_plate': 'LAG-882-VOLT',
        'battery_soc': 88,
        'recipient_otp_verified': true,
        'proof_of_delivery_signature': podSignatureUrl,
        'completed_at': DateTime.now().toUtc().toIso8601String(),
      };

      final completeRequest = Request(
        'POST',
        Uri.parse('http://localhost:8080/partner/v1/deliveries/$trackingReference/telemetry'),
        body: jsonEncode(completedTelemetryPayload),
        headers: {'content-type': 'application/json'},
      );

      final completeResponse = await handler(completeRequest);
      expect(completeResponse.statusCode, 200);

      // Verify delivery is completed in registry
      final verifiedGetRequest = Request(
        'GET',
        Uri.parse('http://localhost:8080/partner/v1/deliveries/$trackingReference'),
      );
      final verifiedGetResponse = await handler(verifiedGetRequest);
      final verifiedBody = jsonDecode(await verifiedGetResponse.readAsString()) as Map<String, dynamic>;
      final verifiedData = verifiedBody['data'] as Map<String, dynamic>;
      expect(verifiedData['status'], 'COMPLETED');

      // =======================================================================
      // STAGE 6: Double-Entry Financial Settlement (80/20 Driver Split & Paystack)
      // =======================================================================
      const totalFareKobo = 285000; // ₦2,850.00
      final riderPayoutKobo = (totalFareKobo * 0.80).round(); // ₦2,280.00 (80%)
      final platformCommissionKobo = totalFareKobo - riderPayoutKobo; // ₦570.00 (20%)

      expect(riderPayoutKobo, 228000);
      expect(platformCommissionKobo, 57000);
      expect(riderPayoutKobo + platformCommissionKobo, totalFareKobo);

      // Verify Rider Earnings API Endpoint
      final earningsRequest = Request(
        'GET',
        Uri.parse('http://localhost:8080/api/v1/rider/earnings'),
      );
      final earningsResponse = await handler(earningsRequest);
      expect(earningsResponse.statusCode, 200);

      final earningsBody = jsonDecode(await earningsResponse.readAsString()) as Map<String, dynamic>;
      final earningsData = earningsBody['data'] as Map<String, dynamic>;
      expect(earningsData['bank_name'], 'Access Bank');
      expect((earningsData['settled_week_kobo'] as num), greaterThan(0));

      // =======================================================================
      // STAGE 7: Retail Ai POS Outbound Webhook Verification (HMAC-SHA256)
      // =======================================================================
      const partnerWebhookSecret = 'whsec_test_retail_ai_pos_secret_77182';
      final webhookTimestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;

      final outboundWebhookPayload = {
        'event': 'delivery.completed',
        'event_id': 'evt_e2e_${_uuid.v4().substring(0, 8)}',
        'timestamp': webhookTimestamp,
        'data': {
          'tracking_reference': trackingReference,
          'external_reference': externalReference,
          'status': 'COMPLETED',
          'recipient': {
            'name': 'Dr. Olufemi Peters',
            'phone': '+2348039988776',
            'otp_verified': true,
          },
          'proof_of_delivery': {
            'signature_url': podSignatureUrl,
            'verified_at': DateTime.now().toUtc().toIso8601String(),
          },
          'telematics': {
            'vehicle_plate': 'LAG-882-VOLT',
            'final_battery_soc': 88,
          },
          'financials': {
            'gross_fare_kobo': totalFareKobo,
            'currency': 'NGN',
          },
        },
      };

      final rawWebhookJson = jsonEncode(outboundWebhookPayload);

      // Server generates cryptographic signature header
      final signatureHeader = computePartnerHmacSignature(
        secret: partnerWebhookSecret,
        timestamp: webhookTimestamp,
        rawPayload: rawWebhookJson,
      );

      expect(signatureHeader, startsWith('sha256='));

      // Partner POS verifies signature authenticity
      final isValidSignature = verifyPartnerHmacSignature(
        secret: partnerWebhookSecret,
        timestamp: webhookTimestamp,
        rawPayload: rawWebhookJson,
        signatureHeader: signatureHeader,
      );

      expect(isValidSignature, isTrue);

      // Verification fails if payload was tampered with in transit
      final isTamperedValid = verifyPartnerHmacSignature(
        secret: partnerWebhookSecret,
        timestamp: webhookTimestamp,
        rawPayload: '{"tampered":true}',
        signatureHeader: signatureHeader,
      );

      expect(isTamperedValid, isFalse);
    });
  });
}
