import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../middleware/auth_middleware.dart';

final _log = Logger('DevicesRoute');

// In-memory store for registered tokens before Postgres connection
final Map<String, Map<String, dynamic>> _registeredDevices = {};

Router devicesRouter() {
  final router = Router();

  // POST /api/v1/devices — Register or update FCM token
  router.post('/', (Request request) async {
    final userId = request.context[kAuthUserIdKey] as String? ?? 'usr_anonymous';
    final rawBody = await request.readAsString();
    final body = jsonDecode(rawBody) as Map<String, dynamic>;

    final fcmToken = body['fcm_token'] as String?;
    final platform = body['platform'] as String? ?? 'android';
    final deviceModel = body['device_model'] as String?;

    if (fcmToken == null || fcmToken.isEmpty) {
      return Response(
        400,
        body: jsonEncode({
          'error': {
            'code': 'INVALID_TOKEN',
            'message': 'fcm_token is required.',
          }
        }),
        headers: {'content-type': 'application/json'},
      );
    }

    final record = {
      'user_id': userId,
      'fcm_token': fcmToken,
      'platform': platform,
      'device_model': deviceModel,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    };

    _registeredDevices['$userId:$fcmToken'] = record;
    _log.info('Device token registered for user: $userId, platform: $platform');

    return Response.ok(
      jsonEncode({
        'data': record,
        'meta': {'status': 'registered'},
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  // DELETE /api/v1/devices — Unregister device on sign out
  router.delete('/', (Request request) async {
    final userId = request.context[kAuthUserIdKey] as String? ?? 'usr_anonymous';
    final rawBody = await request.readAsString();
    final body = jsonDecode(rawBody) as Map<String, dynamic>;
    final fcmToken = body['fcm_token'] as String?;

    if (fcmToken != null) {
      _registeredDevices.remove('$userId:$fcmToken');
      _log.info('Device token unregistered for user: $userId');
    }

    return Response.ok(
      jsonEncode({'meta': {'status': 'unregistered'}}),
      headers: {'content-type': 'application/json'},
    );
  });

  return router;
}
