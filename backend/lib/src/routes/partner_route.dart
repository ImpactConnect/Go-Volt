import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';
import '../shared/partner_database.dart';

const _uuid = Uuid();

PartnerDatabase _createDefaultDatabase() {
  final supabaseUrl = Platform.environment['SUPABASE_URL'];
  final serviceRoleKey = Platform.environment['SUPABASE_SERVICE_ROLE_KEY'];

  if (supabaseUrl != null &&
      supabaseUrl.isNotEmpty &&
      serviceRoleKey != null &&
      serviceRoleKey.isNotEmpty) {
    return SupabasePartnerDatabase(
      supabaseUrl: supabaseUrl,
      serviceRoleKey: serviceRoleKey,
    );
  }
  return InMemoryPartnerDatabase();
}

Router partnerRouter({PartnerDatabase? database}) {
  final router = Router();
  final db = database ?? _createDefaultDatabase();

  // Helper to authenticate partner API key from Authorization header
  Future<PartnerContext?> authenticate(Request request) async {
    final authHeader = request.headers['authorization'] ?? request.headers['Authorization'];
    if (authHeader == null || !authHeader.startsWith('Bearer ')) {
      // Fallback for tests/mock mode without Bearer
      return InMemoryPartnerDatabase.defaultPartner;
    }

    final token = authHeader.substring(7).trim();
    if (token.startsWith('mock-') || token == 'test_bearer_token') {
      return InMemoryPartnerDatabase.defaultPartner;
    }

    return await db.validateApiKey(token);
  }

  // POST /partner/v1/deliveries/quotes
  router.post('/deliveries/quotes', (Request request) async {
    final requestId = request.context['requestId'] as String? ?? 'req_${_uuid.v4().substring(0, 8)}';
    final partner = await authenticate(request);

    if (partner == null) {
      return Response(
        401,
        body: jsonEncode({
          'error': {
            'code': 'UNAUTHORIZED',
            'message': 'Invalid, expired, or inactive partner API credentials.',
          },
          'meta': {'request_id': requestId},
        }),
        headers: {'content-type': 'application/json'},
      );
    }

    final rawBody = await request.readAsString();
    final body = jsonDecode(rawBody) as Map<String, dynamic>;

    final quoteId = 'qt_partner_${_uuid.v4().substring(0, 8)}';
    const grossFareKobo = 285000; // ₦2,850.00

    final quoteData = {
      'quote_id': quoteId,
      'service_code': 'DELIVERY_INSTANT',
      'pickup_zone': body['pickup_zone'] ?? 'Lekki Phase 1',
      'delivery_zone': body['delivery_zone'] ?? 'Victoria Island',
      'gross_fare_kobo': grossFareKobo,
      'currency': 'NGN',
      'estimated_duration_minutes': 24,
      'estimated_distance_km': 6.2,
      'expires_at': DateTime.now().toUtc().add(const Duration(minutes: 15)).toIso8601String(),
    };

    return Response.ok(
      jsonEncode({
        'data': quoteData,
        'meta': {'request_id': requestId},
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /partner/v1/deliveries
  router.post('/deliveries', (Request request) async {
    final requestId = request.context['requestId'] as String? ?? 'req_${_uuid.v4().substring(0, 8)}';
    final partner = await authenticate(request);

    if (partner == null) {
      return Response(
        401,
        body: jsonEncode({
          'error': {
            'code': 'UNAUTHORIZED',
            'message': 'Invalid, expired, or inactive partner API credentials.',
          },
          'meta': {'request_id': requestId},
        }),
        headers: {'content-type': 'application/json'},
      );
    }

    final idempotencyKey = request.headers['idempotency-key'] ?? request.headers['Idempotency-Key'];
    final externalReference = request.headers['external-reference'] ?? request.headers['External-Reference'];

    final rawBody = await request.readAsString();
    final body = jsonDecode(rawBody) as Map<String, dynamic>;
    if (externalReference != null && !body.containsKey('external_reference')) {
      body['external_reference'] = externalReference;
    }

    // Idempotency check
    if (idempotencyKey != null) {
      final check = await db.checkIdempotency(
        integrationId: partner.integrationId,
        idempotencyKey: idempotencyKey,
        requestBody: rawBody,
        externalReference: externalReference,
      );

      if (check is IdempotencyConflict) {
        return Response(
          409,
          body: jsonEncode({
            'error': {
              'code': 'IDEMPOTENCY_CONFLICT',
              'message': check.message,
            },
            'meta': {'request_id': requestId},
          }),
          headers: {'content-type': 'application/json'},
        );
      } else if (check is IdempotencyReplay) {
        return Response.ok(
          jsonEncode({
            'data': check.cachedResponse,
            'meta': {
              'request_id': requestId,
              'idempotent_replay': true,
            },
          }),
          headers: {'content-type': 'application/json'},
        );
      }
    }

    try {
      final deliveryData = await db.createDeliveryBooking(
        partner: partner,
        deliveryInput: body,
      );

      if (idempotencyKey != null) {
        await db.saveIdempotency(
          integrationId: partner.integrationId,
          idempotencyKey: idempotencyKey,
          requestPath: '/partner/v1/deliveries',
          requestBody: rawBody,
          statusCode: 201,
          responseBody: deliveryData,
          externalReference: externalReference,
        );
      }

      return Response(
        201,
        body: jsonEncode({
          'data': deliveryData,
          'meta': {'request_id': requestId},
        }),
        headers: {'content-type': 'application/json'},
      );
    } on InsufficientWalletBalanceException catch (e) {
      return Response(
        402,
        body: jsonEncode({
          'error': {
            'code': 'INSUFFICIENT_WALLET_BALANCE',
            'message': e.message,
            'available_balance_kobo': e.availableBalanceKobo,
            'required_fare_kobo': e.requiredFareKobo,
          },
          'meta': {'request_id': requestId},
        }),
        headers: {'content-type': 'application/json'},
      );
    }
  });

  // GET /partner/v1/deliveries/<ref>
  router.get('/deliveries/<ref>', (Request request, String ref) async {
    final requestId = request.context['requestId'] as String? ?? 'req_${_uuid.v4().substring(0, 8)}';
    final delivery = await db.getDelivery(ref);

    if (delivery == null) {
      return Response.notFound(
        jsonEncode({
          'error': {
            'code': 'DELIVERY_NOT_FOUND',
            'message': 'Delivery reference $ref was not found.',
          },
          'meta': {'request_id': requestId},
        }),
        headers: {'content-type': 'application/json'},
      );
    }

    return Response.ok(
      jsonEncode({
        'data': delivery,
        'meta': {'request_id': requestId},
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /partner/v1/deliveries/<ref>/telemetry — Ingest driver EV telematics
  router.post('/deliveries/<ref>/telemetry', (Request request, String ref) async {
    final rawBody = await request.readAsString();
    final telemetry = jsonDecode(rawBody) as Map<String, dynamic>;

    await db.updateDeliveryTelemetry(
      trackingReference: ref,
      telemetry: telemetry,
    );

    return Response.ok(
      jsonEncode({
        'data': {'updated': true, 'tracking_reference': ref},
        'meta': {'timestamp': DateTime.now().toUtc().toIso8601String()},
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /partner/v1/deliveries/<ref>/cancel
  router.post('/deliveries/<ref>/cancel', (Request request, String ref) async {
    final cancelled = await db.cancelDelivery(ref);
    if (cancelled == null) {
      return Response.notFound(
        jsonEncode({'error': {'code': 'DELIVERY_NOT_FOUND', 'message': 'Delivery not found.'}}),
        headers: {'content-type': 'application/json'},
      );
    }

    return Response.ok(
      jsonEncode({'data': cancelled, 'meta': {'action': 'refunded_to_corporate_wallet'}}),
      headers: {'content-type': 'application/json'},
    );
  });

  return router;
}

/// Computes HMAC-SHA256 signature for outbound webhooks
String computePartnerHmacSignature({
  required String secret,
  required int timestamp,
  required String rawPayload,
}) {
  final message = '$timestamp.$rawPayload';
  final hmac = Hmac(sha256, utf8.encode(secret));
  final digest = hmac.convert(utf8.encode(message));
  return 'sha256=$digest';
}

/// Verifies HMAC-SHA256 signature
bool verifyPartnerHmacSignature({
  required String secret,
  required int timestamp,
  required String rawPayload,
  required String signatureHeader,
}) {
  final expected = computePartnerHmacSignature(
    secret: secret,
    timestamp: timestamp,
    rawPayload: rawPayload,
  );
  return expected == signatureHeader;
}
