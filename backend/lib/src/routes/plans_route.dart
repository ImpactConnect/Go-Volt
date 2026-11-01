import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:uuid/uuid.dart';

import '../middleware/auth_middleware.dart';

final _log = Logger('PlansRoute');
const _uuid = Uuid();

final List<Map<String, dynamic>> _mockPlans = [
  {
    'id': 'plan_commute_01',
    'user_id': 'usr_mock_001',
    'plan_name': 'Weekday Commute Pass',
    'plan_type': 'COMMUTER_PASS',
    'service_code': 'RIDE_SCHEDULED',
    'pickup_address': 'Shaganu Central Hub, Ogun State',
    'pickup_lat': 6.8403,
    'pickup_lng': 3.6487,
    'dropoff_address': 'Remo High Street, Shaganu, Ogun State',
    'dropoff_lat': 6.8450,
    'dropoff_lng': 3.6520,
    'pickup_time': '07:30:00',
    'days_of_week': [1, 2, 3, 4, 5],
    'is_active': true,
    'total_trips_allocated': 20,
    'trips_remaining': 16,
    'start_date': '2026-10-01',
    'end_date': '2026-10-31',
  },
  {
    'id': 'plan_school_01',
    'user_id': 'usr_mock_001',
    'plan_name': 'Babcock Staff School Morning Pickup',
    'plan_type': 'SCHOOL_RUN',
    'service_code': 'RIDE_SCHEDULED',
    'pickup_address': 'Shaganu Central Hub, Ogun State',
    'pickup_lat': 6.8403,
    'pickup_lng': 3.6487,
    'dropoff_address': 'Babcock Staff School, Ilishan-Remo, Ogun State',
    'dropoff_lat': 6.8920,
    'dropoff_lng': 3.7190,
    'pickup_time': '07:15:00',
    'days_of_week': [1, 2, 3, 4, 5],
    'is_active': true,
    'total_trips_allocated': 20,
    'trips_remaining': 19,
    'start_date': '2026-10-01',
    'end_date': '2026-10-31',
  }
];

Router plansRouter() {
  final router = Router();

  // GET /api/v1/plans — List scheduled plans for user
  router.get('/', (Request request) async {
    final userId = request.context[kAuthUserIdKey] as String? ?? 'usr_mock_001';
    final userPlans = _mockPlans.where((p) => p['user_id'] == userId).toList();

    return Response.ok(
      jsonEncode({
        'data': userPlans,
        'meta': {'count': userPlans.length},
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /api/v1/plans — Create new recurring scheduled plan
  router.post('/', (Request request) async {
    final userId = request.context[kAuthUserIdKey] as String? ?? 'usr_mock_001';
    final rawBody = await request.readAsString();
    final body = jsonDecode(rawBody) as Map<String, dynamic>;

    final planId = 'plan_${_uuid.v4().substring(0, 8)}';
    final newPlan = {
      'id': planId,
      'user_id': userId,
      'plan_name': body['plan_name'] ?? 'Scheduled Plan',
      'plan_type': body['plan_type'] ?? 'COMMUTER_PASS',
      'service_code': body['service_code'] ?? 'RIDE_SCHEDULED',
      'pickup_address': body['pickup_address'] ?? 'Shaganu Central Hub, Ogun State',
      'pickup_lat': body['pickup_lat'] ?? 6.8403,
      'pickup_lng': body['pickup_lng'] ?? 3.6487,
      'dropoff_address': body['dropoff_address'] ?? 'Remo High Street, Shaganu, Ogun State',
      'dropoff_lat': body['dropoff_lat'] ?? 6.8450,
      'dropoff_lng': body['dropoff_lng'] ?? 3.6520,
      'pickup_time': body['pickup_time'] ?? '08:00:00',
      'days_of_week': body['days_of_week'] ?? [1, 2, 3, 4, 5],
      'is_active': true,
      'total_trips_allocated': 20,
      'trips_remaining': 20,
      'start_date': DateTime.now().toIso8601String().substring(0, 10),
      'end_date': DateTime.now().add(const Duration(days: 30)).toIso8601String().substring(0, 10),
    };

    _mockPlans.add(newPlan);
    _log.info('New scheduled plan created: $planId for user: $userId');

    return Response(
      201,
      body: jsonEncode({
        'data': newPlan,
        'meta': {'status': 'created'},
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  return router;
}
