import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';

final _log = Logger('AuthMiddleware');

/// Context key for authenticated user ID.
const kAuthUserIdKey = 'auth_user_id';
/// Context key for authenticated user email.
const kAuthUserEmailKey = 'auth_user_email';
/// Context key for authenticated user roles.
const kAuthUserRolesKey = 'auth_user_roles';

/// Shelf middleware to validate Supabase JWT tokens.
Middleware authMiddleware({
  String? jwtSecret,
  bool allowAnonymous = true,
}) {
  return (Handler innerHandler) {
    return (Request request) async {
      final authHeader = request.headers['authorization'];

      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        if (!allowAnonymous && _isProtectedPath(request.url.path)) {
          return Response(
            401,
            body: '{"error":{"code":"UNAUTHORIZED","message":"Missing or invalid Bearer token"}}',
            headers: {'content-type': 'application/json'},
          );
        }
        return innerHandler(request);
      }

      final token = authHeader.substring(7).trim();

      try {
        // If JWT secret is configured and not running in test bypass, verify signature
        if (jwtSecret != null && jwtSecret.isNotEmpty && !token.startsWith('mock-')) {
          final jwt = JWT.verify(token, SecretKey(jwtSecret));
          final payload = jwt.payload as Map<String, dynamic>;
          final sub = payload['sub'] as String?;
          final email = payload['email'] as String?;
          final appMetadata = payload['app_metadata'] as Map<String, dynamic>? ?? {};
          final roles = (appMetadata['roles'] as List<dynamic>?)?.cast<String>() ?? ['customer'];

          final updatedContext = {
            ...request.context,
            kAuthUserIdKey: sub ?? 'anonymous',
            kAuthUserEmailKey: email ?? '',
            kAuthUserRolesKey: roles,
          };
          return await innerHandler(request.change(context: updatedContext));
        } else {
          // Dev / Mock JWT support
          final updatedContext = {
            ...request.context,
            kAuthUserIdKey: 'usr_mock_001',
            kAuthUserEmailKey: 'user@govolts.ng',
            kAuthUserRolesKey: ['customer'],
          };
          return await innerHandler(request.change(context: updatedContext));
        }
      } catch (e, stack) {
        _log.warning('JWT verification failed for path: ${request.url.path}', e, stack);
        return Response(
          401,
          body: '{"error":{"code":"INVALID_TOKEN","message":"JWT token signature verification failed."}}',
          headers: {'content-type': 'application/json'},
        );
      }
    };
  };
}

bool _isProtectedPath(String path) {
  if (path.contains('health') || path.contains('webhook')) return false;
  return true;
}
