import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_portal/src/features/developer/application/partner_api_notifier.dart';

void main() {
  group('Phase 4: Developer Partner API & HMAC-SHA256 Signed Webhooks', () {
    test('initializes with active partner credentials and webhook endpoint', () {
      final notifier = PartnerApiNotifier();

      expect(notifier.state.apiKeys, isNotEmpty);
      expect(
        notifier.state.apiKeys.any((k) => k.environment == 'Production'),
        isTrue,
      );
      expect(notifier.state.webhookConfig.url, contains('retail-ai.ng'));
      expect(notifier.state.webhookConfig.subscribedEvents, contains('delivery.created'));
      expect(notifier.state.webhookConfig.subscribedEvents, contains('delivery.completed'));
    });

    test('computes and verifies HMAC-SHA256 signatures accurately', () {
      const secret = 'whsec_test_secret_key_12345';
      const timestamp = 1792838400;
      const rawPayload = '{"event":"delivery.completed","tracking_number":"GV-LEK-90412"}';

      final signature = PartnerApiNotifier.computeHmacSignature(
        secret: secret,
        timestamp: timestamp,
        payload: rawPayload,
      );

      expect(signature, startsWith('sha256='));

      // Verify authentic signature
      final isValid = PartnerApiNotifier.verifyHmacSignature(
        secret: secret,
        timestamp: timestamp,
        payload: rawPayload,
        providedSignature: signature,
      );
      expect(isValid, isTrue);

      // Verify tampered payload fails
      final isTamperedValid = PartnerApiNotifier.verifyHmacSignature(
        secret: secret,
        timestamp: timestamp,
        payload: '{"event":"delivery.completed","tracking_number":"GV-TAMPERED"}',
        providedSignature: signature,
      );
      expect(isTamperedValid, isFalse);

      // Verify wrong secret fails
      final isWrongSecretValid = PartnerApiNotifier.verifyHmacSignature(
        secret: 'whsec_wrong_secret',
        timestamp: timestamp,
        payload: rawPayload,
        providedSignature: signature,
      );
      expect(isWrongSecretValid, isFalse);
    });

    test('enforces Idempotency-Key guarantee: deduplicates identical retries and detects conflicts', () {
      final notifier = PartnerApiNotifier();

      const idempotencyKey = 'idem_uuid_482910_a';
      const externalReference = 'RET-POS-INV-10029';
      const branchId = 'br_lekki_01';
      final requestBody = {
        'recipient_name': 'Chief Tunde Martins',
        'destination': '12 Victoria Garden City, Lekki',
        'gross_fare_kobo': 285000,
      };

      // 1. First execution -> Creates delivery with 201
      final res1 = notifier.processPartnerDeliveryCreation(
        idempotencyKey: idempotencyKey,
        externalReference: externalReference,
        branchId: branchId,
        requestBody: requestBody,
      );

      expect(res1['status'], 'created');
      expect(res1['statusCode'], 201);
      final trackingNumber1 = (res1['body'] as Map<String, dynamic>)['tracking_number'];
      expect(trackingNumber1, isNotNull);

      // 2. Network retry with identical (idempotencyKey, externalReference) -> Returns cached without duplication
      final res2 = notifier.processPartnerDeliveryCreation(
        idempotencyKey: idempotencyKey,
        externalReference: externalReference,
        branchId: branchId,
        requestBody: requestBody,
      );

      expect(res2['status'], 'cached');
      expect(res2['statusCode'], 201);
      final trackingNumber2 = (res2['body'] as Map<String, dynamic>)['tracking_number'];
      expect(trackingNumber2, trackingNumber1); // Exact same delivery!

      // 3. Mismatched request reusing same idempotency key -> Returns 409 Conflict
      final res3 = notifier.processPartnerDeliveryCreation(
        idempotencyKey: idempotencyKey,
        externalReference: 'RET-POS-INV-DIFFERENT',
        branchId: branchId,
        requestBody: requestBody,
      );

      expect(res3['status'], 'conflict');
      expect(res3['statusCode'], 409);
      expect(res3['error'], contains('collision'));
    });

    test('dispatches test webhook ping and generates HMAC signature', () async {
      final notifier = PartnerApiNotifier();
      final initialLogsCount = notifier.state.webhookLogs.length;

      final log = await notifier.sendTestWebhookPing();

      expect(notifier.state.webhookLogs.length, initialLogsCount + 1);
      expect(log.eventType, 'delivery.created');
      expect(log.httpStatusCode, 200);
      expect(log.isDelivered, isTrue);
      expect(log.signatureHeader, startsWith('sha256='));
      expect(log.durationMs, greaterThan(0));
      expect(notifier.state.successMessage, contains('200 OK'));
    });
  });
}
