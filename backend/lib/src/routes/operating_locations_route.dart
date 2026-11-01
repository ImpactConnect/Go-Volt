import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

/// Route: /api/v1/operating-locations
///
/// Returns the list of active operating locations provisioned by the admin.
/// The data is read from the operating_locations Supabase table.
/// This route is public — no auth token required.
Router operatingLocationsRouter() {
  final router = Router();

  // GET /api/v1/operating-locations
  // Returns all active operating locations.
  router.get('/', (Request request) async {
    // In production this reads from Supabase via service-role key.
    // For now, returns the seeded Ogun/Shagamu location.
    final locations = _getLocations();
    return Response.ok(
      jsonEncode({'data': locations.map((l) => l.toJson()).toList()}),
      headers: {'content-type': 'application/json'},
    );
  });

  // GET /api/v1/operating-locations/states
  // Returns distinct active states.
  router.get('/states', (Request request) async {
    final locations = _getLocations();
    final states = locations.map((l) => l['state'] as String).toSet().toList()
      ..sort();
    return Response.ok(
      jsonEncode({'data': states}),
      headers: {'content-type': 'application/json'},
    );
  });

  // GET /api/v1/operating-locations/cities?state=Ogun
  // Returns active cities for a given state.
  router.get('/cities', (Request request) async {
    final state = request.url.queryParameters['state'];
    if (state == null || state.isEmpty) {
      return Response(
        400,
        body: jsonEncode({'error': 'state query parameter is required'}),
        headers: {'content-type': 'application/json'},
      );
    }
    final locations = _getLocations()
        .where(
          (l) => (l['state'] as String).toLowerCase() == state.toLowerCase(),
        )
        .toList();
    return Response.ok(
      jsonEncode({'data': locations}),
      headers: {'content-type': 'application/json'},
    );
  });

  return router;
}

/// Returns the seed data for operating locations.
/// In production, this will be replaced with a Supabase query.
List<Map<String, dynamic>> _getLocations() {
  return [
    {
      'id': 'ogun-shaganu',
      'state': 'Ogun',
      'city': 'Shaganu',
      'is_active': true,
      'status': 'fully_supported',
      'status_description': 'Fully supported',
      'available_services': [
        'instant_ride',
        'instant_delivery',
        'scheduled_ride',
        'scheduled_pickup',
      ],
      'center_lat': 6.8403,
      'center_lng': 3.6487,
    },
  ];
}

extension on Map<String, dynamic> {
  Map<String, dynamic> toJson() => this;
}
