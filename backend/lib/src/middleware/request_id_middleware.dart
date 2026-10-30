import 'package:shelf/shelf.dart';
import 'package:uuid/uuid.dart';

const String requestIdHeader = 'X-Request-Id';
const _uuid = Uuid();

/// Middleware that assigns an `X-Request-Id` to each incoming request if not provided,
/// and propagates it to the response headers for end-to-end tracing.
Middleware requestIdMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      final requestId = request.headers[requestIdHeader] ?? _uuid.v4();
      final updatedRequest = request.change(
        headers: {requestIdHeader: requestId},
        context: {'requestId': requestId},
      );

      final response = await innerHandler(updatedRequest);
      return response.change(headers: {requestIdHeader: requestId});
    };
  };
}
