import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

// In-memory notification preferences and saved places store
final Map<String, Map<String, dynamic>> _notificationPreferencesStore = {};
final Map<String, List<Map<String, dynamic>>> _savedPlacesStore = {};

void resetSettingsStoreForTest() {
  _notificationPreferencesStore.clear();
  _savedPlacesStore.clear();
}

Map<String, dynamic> _getOrCreateNotificationPreferences(String userId) {
  return _notificationPreferencesStore.putIfAbsent(userId, () {
    return {
      'ride_booking_updates': true,
      'ride_rider_assigned': true,
      'ride_trip_status': true,
      'parcel_delivery_updates': true,
      'parcel_rider_assigned': true,
      'parcel_delivery_completion': true,
      'errand_agent_updates': true,
      'errand_shopping_updates': true,
      'errand_payment_updates': true,
      'rewards_and_points': true,
      'promotions_and_coupons': false,
      'security_and_account_alerts': true,
      'sms_dispatch_alerts': true,
      'school_run_security_alerts': true,
    };
  });
}

List<Map<String, dynamic>> _getOrCreateSavedPlaces(String userId) {
  return _savedPlacesStore.putIfAbsent(userId, () {
    return [
      {
        'id': 'plc_home_01',
        'label': 'Home',
        'address': '14 Admiralty Way, Lekki Phase 1, Lagos',
        'type': 'HOME',
        'latitude': 6.4474,
        'longitude': 3.4735,
        'additional_instructions': 'Security gate call Flat 4',
        'is_used_in_active_plan': true,
        'user_id': userId,
      },
      {
        'id': 'plc_work_01',
        'label': 'Work Office',
        'address': '18 Adeola Odeku St, Victoria Island, Lagos',
        'type': 'WORK',
        'latitude': 6.4281,
        'longitude': 3.4219,
        'additional_instructions': 'Reception on 4th floor',
        'is_used_in_active_plan': true,
        'user_id': userId,
      },
      {
        'id': 'plc_school_01',
        'label': 'Corona School Victoria Island',
        'address': '6 Waziri Ibrahim Cres, Victoria Island, Lagos',
        'type': 'SCHOOL',
        'latitude': 6.4350,
        'longitude': 3.4310,
        'additional_instructions': 'Gate B for school-run drop-off and OTP handover',
        'is_used_in_active_plan': true,
        'user_id': userId,
      },
      {
        'id': 'plc_gym_01',
        'label': 'Gym & Fitness Hub',
        'address': 'Plot 12 Lekki-Epe Expressway, Lagos',
        'type': 'CUSTOM',
        'latitude': 6.4420,
        'longitude': 3.4800,
        'additional_instructions': 'Visitor parking bay',
        'is_used_in_active_plan': false,
        'user_id': userId,
      },
    ];
  });
}

Router notificationPreferencesRouter() {
  final router = Router();

  // GET /api/v1/notification-preferences/
  router.get('/', (Request request) async {
    final userId = request.url.queryParameters['user_id'] ?? 'usr-customer-01';
    final prefs = _getOrCreateNotificationPreferences(userId);
    return Response.ok(
      jsonEncode({'data': prefs}),
      headers: {'content-type': 'application/json'},
    );
  });

  // PATCH /api/v1/notification-preferences/
  router.patch('/', (Request request) async {
    final bodyStr = await request.readAsString();
    Map<String, dynamic> body = {};
    if (bodyStr.isNotEmpty) {
      body = jsonDecode(bodyStr) as Map<String, dynamic>;
    }

    final userId = body['user_id'] as String? ?? request.url.queryParameters['user_id'] ?? 'usr-customer-01';
    final prefs = _getOrCreateNotificationPreferences(userId);

    body.forEach((key, value) {
      if (key != 'user_id' && value is bool) {
        prefs[key] = value;
      }
    });

    return Response.ok(
      jsonEncode({'data': prefs}),
      headers: {'content-type': 'application/json'},
    );
  });

  return router;
}

Router savedPlacesRouter() {
  final router = Router();

  // GET /api/v1/saved-places/
  router.get('/', (Request request) async {
    final userId = request.url.queryParameters['user_id'] ?? 'usr-customer-01';
    final places = _getOrCreateSavedPlaces(userId);
    return Response.ok(
      jsonEncode({'data': places}),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /api/v1/saved-places/
  router.post('/', (Request request) async {
    final bodyStr = await request.readAsString();
    Map<String, dynamic> body = {};
    if (bodyStr.isNotEmpty) {
      body = jsonDecode(bodyStr) as Map<String, dynamic>;
    }

    final userId = body['user_id'] as String? ?? request.url.queryParameters['user_id'] ?? 'usr-customer-01';
    final places = _getOrCreateSavedPlaces(userId);

    final newPlace = {
      'id': 'plc_${DateTime.now().millisecondsSinceEpoch}',
      'label': body['label'] as String? ?? 'Saved Place',
      'address': body['address'] as String? ?? 'Lagos, Nigeria',
      'type': (body['type'] as String? ?? 'CUSTOM').toUpperCase(),
      'latitude': (body['latitude'] as num?)?.toDouble() ?? 6.4474,
      'longitude': (body['longitude'] as num?)?.toDouble() ?? 3.4735,
      'additional_instructions': body['additional_instructions'] as String?,
      'is_used_in_active_plan': false,
      'user_id': userId,
    };

    places.add(newPlace);

    return Response.ok(
      jsonEncode({'data': newPlace}),
      headers: {'content-type': 'application/json'},
    );
  });

  // PATCH /api/v1/saved-places/<id>
  router.patch('/<id>', (Request request, String id) async {
    final bodyStr = await request.readAsString();
    Map<String, dynamic> body = {};
    if (bodyStr.isNotEmpty) {
      body = jsonDecode(bodyStr) as Map<String, dynamic>;
    }

    final userId = body['user_id'] as String? ?? request.url.queryParameters['user_id'] ?? 'usr-customer-01';
    final places = _getOrCreateSavedPlaces(userId);
    final index = places.indexWhere((p) => p['id'] == id);

    if (index == -1) {
      return Response.notFound(
        jsonEncode({'error': {'code': 'NOT_FOUND', 'message': 'Saved place not found.'}}),
        headers: {'content-type': 'application/json'},
      );
    }

    final place = places[index];
    if (body.containsKey('label')) place['label'] = body['label'];
    if (body.containsKey('address')) place['address'] = body['address'];
    if (body.containsKey('type')) place['type'] = (body['type'] as String).toUpperCase();
    if (body.containsKey('latitude')) place['latitude'] = (body['latitude'] as num).toDouble();
    if (body.containsKey('longitude')) place['longitude'] = (body['longitude'] as num).toDouble();
    if (body.containsKey('additional_instructions')) place['additional_instructions'] = body['additional_instructions'];

    return Response.ok(
      jsonEncode({'data': place}),
      headers: {'content-type': 'application/json'},
    );
  });

  // DELETE /api/v1/saved-places/<id>
  router.delete('/<id>', (Request request, String id) async {
    final userId = request.url.queryParameters['user_id'] ?? 'usr-customer-01';
    final force = request.url.queryParameters['force'] == 'true';
    final places = _getOrCreateSavedPlaces(userId);
    final index = places.indexWhere((p) => p['id'] == id);

    if (index == -1) {
      return Response.notFound(
        jsonEncode({'error': {'code': 'NOT_FOUND', 'message': 'Saved place not found.'}}),
        headers: {'content-type': 'application/json'},
      );
    }

    final place = places[index];
    if (place['is_used_in_active_plan'] == true && !force) {
      return Response(
        409,
        body: jsonEncode({
          'error': {
            'code': 'PLACE_LINKED_TO_ACTIVE_PLAN',
            'message': 'Cannot delete "${place['label']}" because it is linked to an active School-Run commute plan. Please reassign the plan destination before deleting.',
            'is_used_in_active_plan': true,
          }
        }),
        headers: {'content-type': 'application/json'},
      );
    }

    final removed = places.removeAt(index);
    return Response.ok(
      jsonEncode({'data': {'message': 'Place removed successfully.', 'deleted_place': removed}}),
      headers: {'content-type': 'application/json'},
    );
  });

  return router;
}
