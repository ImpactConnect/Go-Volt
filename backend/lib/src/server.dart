import 'package:shelf/shelf.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:shelf_router/shelf_router.dart';

import 'middleware/auth_middleware.dart';
import 'middleware/error_handler_middleware.dart';
import 'middleware/request_id_middleware.dart';
import 'routes/bookings_route.dart';
import 'routes/devices_route.dart';
import 'routes/health_route.dart';
import 'routes/payments_route.dart';
import 'routes/plans_route.dart';
import 'routes/quotes_route.dart';
import 'routes/rider_route.dart';
import 'routes/partner_route.dart';
import 'routes/deliveries_route.dart';

import 'shared/partner_database.dart';

/// Configures and returns the root Shelf request handler with all middlewares and routes.
Handler createServerHandler({
  String? paystackSecretKey,
  String? jwtSecret,
  PartnerDatabase? partnerDatabase,
}) {
  final router = Router();

  // Root health endpoint
  router.get('/health', healthHandler);

  // Partner v1 sub-router (§6.10, §6.11)
  router.mount('/partner/v1', partnerRouter(database: partnerDatabase).call);

  // API v1 sub-router
  final v1Router = Router();
  v1Router.get('/health', healthHandler);
  v1Router.post('/quotes', createQuoteHandler);
  v1Router.mount('/bookings', bookingsRouter().call);
  v1Router.mount('/payments', paymentsRouter(paystackSecretKey: paystackSecretKey).call);
  v1Router.mount('/devices', devicesRouter().call);
  v1Router.mount('/plans', plansRouter().call);
  v1Router.mount('/rider', riderRouter().call);
  v1Router.mount('/delivery', deliveriesRouter().call);
  v1Router.mount('/deliveries', deliveriesRouter().call);

  router.mount('/api/v1', v1Router.call);

  // Fallback 404
  router.all('/<ignored|.*>', (Request request) {
    return Response.notFound(
      '{"error":{"code":"ROUTE_NOT_FOUND","message":"The requested endpoint does not exist."}}',
      headers: {'content-type': 'application/json'},
    );
  });

  final pipeline = const Pipeline()
      .addMiddleware(corsHeaders())
      .addMiddleware(requestIdMiddleware())
      .addMiddleware(errorHandlerMiddleware())
      .addMiddleware(authMiddleware(jwtSecret: jwtSecret))
      .addHandler(router.call);

  return pipeline;
}

