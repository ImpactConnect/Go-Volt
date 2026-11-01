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
import 'routes/operating_locations_route.dart';
import 'routes/ride_categories_route.dart';
import 'routes/scheduled_routes.dart';
import 'routes/wallet_route.dart';
import 'routes/loyalty_route.dart';
import 'routes/coupons_route.dart';
import 'routes/errands_route.dart';
import 'routes/profile_route.dart';
import 'routes/settings_route.dart';
import 'routes/safety_support_route.dart';
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
  final opLocs = operatingLocationsRouter();
  v1Router.mount('/operating-locations', opLocs.call);
  v1Router.get('/operating-locations', (Request req) => opLocs.call(req.change(path: '')));
  final rideCats = rideCategoriesRouter();
  v1Router.mount('/catalogue/ride-categories', rideCats.call);
  v1Router.get('/catalogue/ride-categories', (Request req) => rideCats.call(req.change(path: '')));
  v1Router.mount('/ride-categories', rideCats.call);
  v1Router.get('/ride-categories', (Request req) => rideCats.call(req.change(path: '')));
  v1Router.mount('/scheduled', scheduledRouter().call);
  v1Router.post('/scheduled-quotes', handleCalculateQuote);
  v1Router.mount('/scheduled-plans', scheduledPlansRouter().call);
  v1Router.mount('/scheduled-trips', scheduledTripsRouter().call);
  final walletRoutes = walletRouter();
  v1Router.mount('/wallet', walletRoutes.call);
  v1Router.get('/admin/paystack-settings', (Request req) => walletRoutes.call(req.change(path: 'admin/paystack-settings')));
  v1Router.put('/admin/paystack-settings', (Request req) => walletRoutes.call(req.change(path: 'admin/paystack-settings')));
  v1Router.get('/payments/paystack-public-key', (Request req) => walletRoutes.call(req.change(path: 'payments/paystack-public-key')));
  v1Router.mount('/loyalty', loyaltyRouter().call);
  v1Router.mount('/coupons', couponsRouter().call);
  final errandsRoutes = errandsRouter();
  v1Router.mount('/errands', errandsRoutes.call);
  v1Router.mount('/profile', profileRouter().call);
  v1Router.mount('/notification-preferences', notificationPreferencesRouter().call);
  v1Router.mount('/saved-places', savedPlacesRouter().call);
  v1Router.mount('/safety', safetyRouter().call);
  v1Router.mount('/support', supportRouter().call);

  router.mount('/api/v1', v1Router.call);
  router.mount('/profile', profileRouter().call);
  router.mount('/notification-preferences', notificationPreferencesRouter().call);
  router.mount('/saved-places', savedPlacesRouter().call);
  router.mount('/safety', safetyRouter().call);
  router.mount('/support', supportRouter().call);
  router.mount('/operating-locations', opLocs.call);
  router.get('/operating-locations', (Request req) => opLocs.call(req.change(path: '')));
  router.mount('/catalogue/ride-categories', rideCats.call);
  router.get('/catalogue/ride-categories', (Request req) => rideCats.call(req.change(path: '')));
  router.mount('/ride-categories', rideCats.call);
  router.get('/ride-categories', (Request req) => rideCats.call(req.change(path: '')));
  router.mount('/scheduled', scheduledRouter().call);
  router.post('/scheduled-quotes', handleCalculateQuote);
  router.mount('/scheduled-plans', scheduledPlansRouter().call);
  router.mount('/scheduled-trips', scheduledTripsRouter().call);
  router.mount('/wallet', walletRouter().call);
  router.mount('/loyalty', loyaltyRouter().call);
  router.mount('/coupons', couponsRouter().call);
  router.mount('/errands', errandsRoutes.call);

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

