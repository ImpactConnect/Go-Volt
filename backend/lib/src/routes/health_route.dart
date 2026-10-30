import 'dart:convert';
import 'package:shelf/shelf.dart';

/// Health check route for load balancers and deployment verification.
Response healthHandler(Request request) {
  final requestId = request.context['requestId'] as String? ?? 'unknown';

  final payload = {
    'data': {
      'status': 'healthy',
      'service': 'go_volts_api',
      'version': '0.1.0',
      'environment': 'development',
      'uptime_seconds': 0,
    },
    'meta': {
      'request_id': requestId,
      'timestamp': DateTime.now().toUtc().toIso8601String(),
    },
  };

  return Response.ok(
    jsonEncode(payload),
    headers: {'content-type': 'application/json'},
  );
}
