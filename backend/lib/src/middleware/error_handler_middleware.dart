import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';

final _log = Logger('ErrorHandler');

/// Middleware catching unhandled exceptions and formatting standard JSON error envelopes.
Middleware errorHandlerMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      try {
        return await innerHandler(request);
      } catch (error, stackTrace) {
        final requestId = request.context['requestId'] as String? ?? 'unknown';
        const statusCode = 500;

        final body = jsonEncode({
          'error': {
            'code': 'INTERNAL_SERVER_ERROR',
            'message': 'An unexpected error occurred processing your request.',
            'status_code': statusCode,
          },
          'meta': {
            'request_id': requestId,
            'timestamp': DateTime.now().toUtc().toIso8601String(),
          },
        });

        _log.severe('[$requestId] Unhandled server error: $error', error, stackTrace);

        return Response(
          statusCode,
          body: body,
          headers: {'content-type': 'application/json'},
        );
      }
    };
  };
}
