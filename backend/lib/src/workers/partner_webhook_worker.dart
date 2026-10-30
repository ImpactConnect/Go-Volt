import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:supabase/supabase.dart';
import '../routes/partner_route.dart';

final _log = Logger('PartnerWebhookWorker');

/// Background worker that queries pending partner webhook deliveries,
/// signs them using HMAC-SHA256, and dispatches them with retry backoff.
class PartnerWebhookWorker {
  PartnerWebhookWorker({
    required SupabaseClient supabaseClient,
    http.Client? httpClient,
    Duration pollInterval = const Duration(seconds: 4),
  })  : _client = supabaseClient,
        _http = httpClient ?? http.Client(),
        _pollInterval = pollInterval;

  final SupabaseClient _client;
  final http.Client _http;
  final Duration _pollInterval;
  Timer? _timer;
  bool _isRunning = false;

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _log.info('Partner Webhook Worker started (interval: $_pollInterval)');
    _timer = Timer.periodic(_pollInterval, (_) => processPendingDeliveries());
  }

  void stop() {
    _timer?.cancel();
    _isRunning = false;
    _log.info('Partner Webhook Worker stopped.');
  }

  /// Processes batch of pending or retrying webhook deliveries.
  Future<int> processPendingDeliveries() async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();

      // Query pending deliveries that are ready to send
      final records = await _client
          .from('partner_webhook_deliveries')
          .select('*, partner_integrations(callback_url, callback_signing_secret, status)')
          .or('status.eq.pending,status.eq.retrying')
          .or('next_attempt_at.is.null,next_attempt_at.lte.$now')
          .order('created_at', ascending: true)
          .limit(20);

      if (records.isEmpty) return 0;

      int processed = 0;
      for (final raw in records) {
        final record = Map<String, dynamic>.from(raw);
        final deliveryId = record['id'] as String;
        final integration = record['partner_integrations'] as Map<String, dynamic>?;

        final callbackUrl = integration?['callback_url'] as String?;
        final signingSecret = integration?['callback_signing_secret'] as String?;
        final integrationStatus = integration?['status'] as String?;

        if (callbackUrl == null || signingSecret == null || integrationStatus != 'active') {
          // Inactive partner or no URL: mark as dead-letter
          await _client.from('partner_webhook_deliveries').update({
            'status': 'dead_letter',
            'last_error': 'Integration inactive or callback_url missing',
          }).eq('id', deliveryId);
          continue;
        }

        final payload = record['payload'] as Map<String, dynamic>;
        final rawBody = jsonEncode(payload);
        final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        final signature = computePartnerHmacSignature(
          secret: signingSecret,
          timestamp: timestamp,
          rawPayload: rawBody,
        );

        final eventId = payload['id'] as String? ?? 'evt_$deliveryId';
        final eventType = record['event_type'] as String;
        final attemptCount = (record['attempt_count'] as int? ?? 0) + 1;

        try {
          // Transition state to delivering
          await _client.from('partner_webhook_deliveries').update({
            'status': 'delivering',
            'attempt_count': attemptCount,
          }).eq('id', deliveryId);

          final response = await _http.post(
            Uri.parse(callbackUrl),
            headers: {
              'Content-Type': 'application/json',
              'X-GoVolts-Signature': signature,
              'X-GoVolts-Timestamp': timestamp.toString(),
              'X-GoVolts-Event-Id': eventId,
              'X-GoVolts-Event-Type': eventType,
            },
            body: rawBody,
          ).timeout(const Duration(seconds: 10));

          if (response.statusCode >= 200 && response.statusCode < 300) {
            // Succeeded
            await _client.from('partner_webhook_deliveries').update({
              'status': 'succeeded',
              'last_http_status': response.statusCode,
              'delivered_at': DateTime.now().toUtc().toIso8601String(),
              'last_error': null,
            }).eq('id', deliveryId);
            processed++;
          } else {
            // Failure with non-2xx status code
            await _handleRetry(deliveryId, attemptCount, response.statusCode, 'HTTP ${response.statusCode}');
          }
        } catch (e) {
          // Network error or timeout
          await _handleRetry(deliveryId, attemptCount, null, e.toString());
        }
      }

      return processed;
    } catch (e, st) {
      _log.warning('Error in Partner Webhook Worker polling loop', e, st);
      return 0;
    }
  }

  Future<void> _handleRetry(
    String deliveryId,
    int attemptCount,
    int? httpStatus,
    String error,
  ) async {
    const maxAttempts = 5;
    if (attemptCount >= maxAttempts) {
      await _client.from('partner_webhook_deliveries').update({
        'status': 'dead_letter',
        'last_http_status': httpStatus,
        'last_error': 'Exceeded $maxAttempts retry attempts. $error',
      }).eq('id', deliveryId);
      _log.severe('Webhook delivery $deliveryId permanently failed: dead-lettered.');
    } else {
      // Exponential backoff: 30s, 2m, 10m, 1h
      final backoffSeconds = switch (attemptCount) {
        1 => 30,
        2 => 120,
        3 => 600,
        _ => 3600,
      };

      final nextAttempt = DateTime.now().toUtc().add(Duration(seconds: backoffSeconds)).toIso8601String();
      await _client.from('partner_webhook_deliveries').update({
        'status': 'retrying',
        'last_http_status': httpStatus,
        'last_error': error,
        'next_attempt_at': nextAttempt,
      }).eq('id', deliveryId);
      _log.warning('Webhook delivery $deliveryId scheduled for retry at $nextAttempt (attempt $attemptCount)');
    }
  }
}
