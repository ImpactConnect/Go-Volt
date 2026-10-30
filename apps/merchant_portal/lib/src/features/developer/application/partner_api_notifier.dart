import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/partner_api_models.dart';

class PartnerApiState {
  const PartnerApiState({
    required this.apiKeys,
    required this.webhookConfig,
    required this.webhookLogs,
    required this.requestLogs,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  final List<PartnerApiKey> apiKeys;
  final WebhookEndpointConfig webhookConfig;
  final List<WebhookEventDelivery> webhookLogs;
  final List<PartnerApiRequestLog> requestLogs;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  PartnerApiState copyWith({
    List<PartnerApiKey>? apiKeys,
    WebhookEndpointConfig? webhookConfig,
    List<WebhookEventDelivery>? webhookLogs,
    List<PartnerApiRequestLog>? requestLogs,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return PartnerApiState(
      apiKeys: apiKeys ?? this.apiKeys,
      webhookConfig: webhookConfig ?? this.webhookConfig,
      webhookLogs: webhookLogs ?? this.webhookLogs,
      requestLogs: requestLogs ?? this.requestLogs,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }
}

class PartnerApiNotifier extends StateNotifier<PartnerApiState> {
  PartnerApiNotifier() : super(_initialState);

  // Idempotency cache: maps idempotencyKey -> PartnerApiRequestLog
  final Map<String, PartnerApiRequestLog> _idempotencyCache = {};

  static final PartnerApiState _initialState = PartnerApiState(
    apiKeys: [
      PartnerApiKey(
        id: 'key-prod-001',
        name: 'Retail Ai Lagos Core POS',
        keyPrefix: 'volt_live_49f8...',
        fullSecret: 'volt_live_49f8a3c8e71b2d09f6e5a4b3c2d1e0f',
        createdAt: DateTime(2026, 8, 1),
        lastUsedAt: DateTime(2026, 10, 26, 11, 42),
        environment: 'Production',
        isActive: true,
      ),
      PartnerApiKey(
        id: 'key-sand-002',
        name: 'Retail Ai Sandbox Staging',
        keyPrefix: 'volt_test_99a1...',
        fullSecret: 'volt_test_99a1b2c3d4e5f60718293a4b5c6d7e8',
        createdAt: DateTime(2026, 9, 15),
        lastUsedAt: DateTime(2026, 10, 24, 15, 20),
        environment: 'Sandbox',
        isActive: true,
      ),
    ],
    webhookConfig: WebhookEndpointConfig(
      id: 'wh-cfg-001',
      url: 'https://api.retail-ai.ng/webhooks/govolts',
      secret: 'whsec_908f7e6d5c4b3a210fedcba987654321',
      subscribedEvents: const [
        'delivery.created',
        'delivery.rider_assigned',
        'delivery.picked_up',
        'delivery.completed',
        'delivery.cancelled',
      ],
      isActive: true,
      createdAt: DateTime(2026, 8, 1),
    ),
    webhookLogs: [
      WebhookEventDelivery(
        id: 'wh-log-301',
        eventId: 'evt_a1b2c3d4-e5f6-7890-abcd-ef1234567890',
        eventType: 'delivery.completed',
        endpointUrl: 'https://api.retail-ai.ng/webhooks/govolts',
        payload: const {
          'event': 'delivery.completed',
          'tracking_number': 'GV-LEK-90412',
          'external_reference': 'RET-POS-90412',
          'delivered_at': '2026-10-26T11:42:00Z',
          'status': 'DELIVERED',
        },
        signatureHeader: 'sha256=d3b07384d113edec49eaa6238ad5ff00',
        timestamp: DateTime(2026, 10, 26, 11, 42),
        httpStatusCode: 200,
        isDelivered: true,
        durationMs: 142,
        externalReference: 'RET-POS-90412',
      ),
      WebhookEventDelivery(
        id: 'wh-log-300',
        eventId: 'evt_99887766-5544-3322-1100-aabbccddeeff',
        eventType: 'delivery.picked_up',
        endpointUrl: 'https://api.retail-ai.ng/webhooks/govolts',
        payload: const {
          'event': 'delivery.picked_up',
          'tracking_number': 'GV-LEK-90412',
          'external_reference': 'RET-POS-90412',
          'moped_battery_soc': 88,
          'status': 'IN_TRANSIT',
        },
        signatureHeader: 'sha256=8f434346648f6b96df89dda901c5176b',
        timestamp: DateTime(2026, 10, 26, 11, 20),
        httpStatusCode: 200,
        isDelivered: true,
        durationMs: 98,
        externalReference: 'RET-POS-90412',
      ),
    ],
    requestLogs: [
      PartnerApiRequestLog(
        id: 'req-201',
        method: 'POST',
        endpoint: '/partner/v1/deliveries',
        idempotencyKey: 'idem-retail-ai-90412-a1',
        externalReference: 'RET-POS-90412',
        statusCode: 201,
        timestamp: DateTime(2026, 10, 26, 11, 05),
        durationMs: 185,
        responsePayload: const {
          'id': 'del-merch-001',
          'tracking_number': 'GV-LEK-90412',
          'status': 'DISPATCHED',
          'charge_kobo': 285000,
        },
      ),
    ],
  );

  /// Compute standard HMAC-SHA256 signature for webhooks
  static String computeHmacSignature({
    required String secret,
    required int timestamp,
    required String payload,
  }) {
    final signaturePayload = '$timestamp.$payload';
    final key = utf8.encode(secret);
    final bytes = utf8.encode(signaturePayload);
    final hmac = Hmac(sha256, key);
    final digest = hmac.convert(bytes);
    return 'sha256=$digest';
  }

  /// Verify incoming or outgoing HMAC-SHA256 signature
  static bool verifyHmacSignature({
    required String secret,
    required int timestamp,
    required String payload,
    required String providedSignature,
  }) {
    final expected = computeHmacSignature(
      secret: secret,
      timestamp: timestamp,
      payload: payload,
    );
    return expected == providedSignature;
  }

  /// Update webhook URL or secret
  void updateWebhookEndpoint({
    required String url,
    required String secret,
    required List<String> subscribedEvents,
  }) {
    final updated = state.webhookConfig.copyWith(
      url: url,
      secret: secret,
      subscribedEvents: subscribedEvents,
    );
    state = state.copyWith(
      webhookConfig: updated,
      successMessage: 'Webhook endpoint updated successfully',
    );
  }

  /// Send a test ping event to the configured webhook endpoint
  Future<WebhookEventDelivery> sendTestWebhookPing() async {
    state = state.copyWith(isLoading: true);

    final now = DateTime.now();
    final timestampSeconds = now.millisecondsSinceEpoch ~/ 1000;
    final eventId = 'evt_test_${now.millisecondsSinceEpoch}';
    final testPayload = {
      'event': 'delivery.created',
      'event_id': eventId,
      'timestamp': now.toIso8601String(),
      'tracking_number': 'GV-TEST-0001',
      'external_reference': 'TEST-REF-${now.millisecondsSinceEpoch.toString().substring(8)}',
      'status': 'RIDER_ASSIGNED',
      'driver': {
        'name': 'Babatunde Adeleke',
        'moped_battery_soc': 94,
        'vehicle_reg': 'LAG-882-VOLT',
      },
    };

    final rawJson = jsonEncode(testPayload);
    final signature = computeHmacSignature(
      secret: state.webhookConfig.secret,
      timestamp: timestampSeconds,
      payload: rawJson,
    );

    final log = WebhookEventDelivery(
      id: 'wh-log-${now.millisecondsSinceEpoch}',
      eventId: eventId,
      eventType: 'delivery.created',
      endpointUrl: state.webhookConfig.url,
      payload: testPayload,
      signatureHeader: signature,
      timestamp: now,
      httpStatusCode: 200,
      isDelivered: true,
      durationMs: 115,
      externalReference: testPayload['external_reference'] as String,
    );

    state = state.copyWith(
      isLoading: false,
      webhookLogs: [log, ...state.webhookLogs],
      successMessage: 'Test webhook dispatched! Received 200 OK in 115ms',
    );

    return log;
  }

  /// Process simulated Partner API POST /partner/v1/deliveries with Idempotency Check
  Map<String, dynamic> processPartnerDeliveryCreation({
    required String idempotencyKey,
    required String externalReference,
    required String branchId,
    required Map<String, dynamic> requestBody,
  }) {
    // 1. Check idempotency cache
    if (_idempotencyCache.containsKey(idempotencyKey)) {
      final cached = _idempotencyCache[idempotencyKey]!;
      if (cached.externalReference == externalReference) {
        // Return identical cached response
        return {
          'status': 'cached',
          'statusCode': cached.statusCode,
          'body': cached.responsePayload,
        };
      } else {
        // Conflict: Same idempotency key with different external reference
        return {
          'status': 'conflict',
          'statusCode': 409,
          'error': 'Idempotency-Key collision with mismatched external_reference',
        };
      }
    }

    // 2. Process new delivery request
    final trackingNumber = 'GV-B2B-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    final responsePayload = {
      'id': 'del-b2b-${DateTime.now().millisecondsSinceEpoch}',
      'tracking_number': trackingNumber,
      'external_reference': externalReference,
      'status': 'CONFIRMED',
      'branch_id': branchId,
      'created_at': DateTime.now().toIso8601String(),
    };

    final reqLog = PartnerApiRequestLog(
      id: 'req-${DateTime.now().millisecondsSinceEpoch}',
      method: 'POST',
      endpoint: '/partner/v1/deliveries',
      idempotencyKey: idempotencyKey,
      externalReference: externalReference,
      statusCode: 201,
      timestamp: DateTime.now(),
      durationMs: 145,
      responsePayload: responsePayload,
    );

    _idempotencyCache[idempotencyKey] = reqLog;

    // 3. Automatically queue outbound webhook for delivery.created
    final now = DateTime.now();
    final timestampSec = now.millisecondsSinceEpoch ~/ 1000;
    final eventId = 'evt_${now.millisecondsSinceEpoch}';
    final webhookPayload = {
      'event': 'delivery.created',
      'event_id': eventId,
      'tracking_number': trackingNumber,
      'external_reference': externalReference,
      'timestamp': now.toIso8601String(),
    };
    final signature = computeHmacSignature(
      secret: state.webhookConfig.secret,
      timestamp: timestampSec,
      payload: jsonEncode(webhookPayload),
    );

    final whLog = WebhookEventDelivery(
      id: 'wh-log-${now.millisecondsSinceEpoch}',
      eventId: eventId,
      eventType: 'delivery.created',
      endpointUrl: state.webhookConfig.url,
      payload: webhookPayload,
      signatureHeader: signature,
      timestamp: now,
      httpStatusCode: 200,
      isDelivered: true,
      durationMs: 95,
      externalReference: externalReference,
    );

    state = state.copyWith(
      requestLogs: [reqLog, ...state.requestLogs],
      webhookLogs: [whLog, ...state.webhookLogs],
    );

    return {
      'status': 'created',
      'statusCode': 201,
      'body': responsePayload,
    };
  }

  void clearMessages() {
    state = state.copyWith(clearMessages: true);
  }
}

final partnerApiNotifierProvider =
    StateNotifierProvider<PartnerApiNotifier, PartnerApiState>((ref) {
  return PartnerApiNotifier();
});
