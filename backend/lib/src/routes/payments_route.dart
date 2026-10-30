import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

final _log = Logger('PaymentsRoute');

Router paymentsRouter({String? paystackSecretKey}) {
  final router = Router();
  final secret = paystackSecretKey ?? 'sk_test_placeholder';

  // POST /initialize
  router.post('/initialize', (Request request) async {
    final rawBody = await request.readAsString();
    final body = jsonDecode(rawBody) as Map<String, dynamic>;

    final amount = (body['amount'] as num).toDouble();
    final email = body['email'] as String;
    final reference = body['reference'] as String;

    final payload = {
      'data': {
        'authorization_url': 'https://checkout.paystack.com/access_code_placeholder',
        'access_code': 'acc_${reference.hashCode.abs()}',
        'reference': reference,
        'amount': amount,
        'email': email,
      },
      'meta': {'status': 'success'},
    };

    return Response.ok(
      jsonEncode(payload),
      headers: {'content-type': 'application/json'},
    );
  });

  // GET /verify/<reference>
  router.get('/verify/<reference>', (Request request, String reference) async {
    final payload = {
      'data': {
        'status': 'success',
        'reference': reference,
        'amount': 250000,
        'gateway_response': 'Successful',
        'paid_at': DateTime.now().toUtc().toIso8601String(),
        'channel': 'card',
        'currency': 'NGN',
      },
      'meta': {'verified': true},
    };

    return Response.ok(
      jsonEncode(payload),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /webhook
  router.post('/webhook', (Request request) async {
    final signature = request.headers['x-paystack-signature'];
    final rawBody = await request.readAsString();

    if (signature != null && secret != 'sk_test_placeholder') {
      final hmac = Hmac(sha512, utf8.encode(secret));
      final digest = hmac.convert(utf8.encode(rawBody));
      if (digest.toString() != signature) {
        return Response(401, body: 'Invalid webhook signature');
      }
    }

    final event = jsonDecode(rawBody) as Map<String, dynamic>;
    final eventType = event['event'] as String? ?? '';

    if (eventType == 'charge.success') {
      final data = event['data'] as Map<String, dynamic>? ?? {};
      final reference = data['reference'] as String? ?? 'unknown';
      _log.info('Verified charge for ref: $reference');
    }

    return Response.ok(jsonEncode({'status': 'event_received'}));
  });

  return router;
}
