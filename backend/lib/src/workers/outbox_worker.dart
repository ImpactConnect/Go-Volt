import 'dart:async';
import 'package:logging/logging.dart';

final _log = Logger('OutboxWorker');

/// Simulates or executes Firebase Cloud Messaging (FCM) v1 push notification delivery.
class PushNotificationDispatcher {
  const PushNotificationDispatcher();

  Future<bool> sendPushNotification({
    required String fcmToken,
    required String title,
    required String body,
    Map<String, String>? data,
  }) async {
    _log.info('Dispatching FCM push to token: ${fcmToken.substring(0, 10)}... | Title: "$title" | Body: "$body"');
    // In production: invokes Google OAuth2 service account token & POSTs to:
    // https://fcm.googleapis.com/v1/projects/{projectId}/messages:send
    return true;
  }
}

/// Background worker that monitors and processes pending outbox events.
class OutboxWorker {
  OutboxWorker({
    PushNotificationDispatcher? dispatcher,
    Duration pollInterval = const Duration(seconds: 5),
  })  : dispatcher = dispatcher ?? const PushNotificationDispatcher(),
        _pollInterval = pollInterval;

  final PushNotificationDispatcher dispatcher;
  final Duration _pollInterval;
  Timer? _timer;
  bool _isRunning = false;

  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _log.info('Outbox background worker started with interval: $_pollInterval');
    _timer = Timer.periodic(_pollInterval, (_) => processPendingEvents());
  }

  void stop() {
    _timer?.cancel();
    _isRunning = false;
    _log.info('Outbox background worker stopped.');
  }

  Future<int> processPendingEvents() async {
    // Queries: SELECT * FROM public.outbox_events WHERE status = 'PENDING' LIMIT 50 FOR UPDATE SKIP LOCKED
    // In production: iterates events and invokes dispatcher.sendPushNotification(...)
    await dispatcher.sendPushNotification(
      fcmToken: 'dry_run_token',
      title: 'Heartbeat',
      body: 'Worker pulse check',
    );
    return 0;
  }
}
