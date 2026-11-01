import 'dart:convert';
import 'package:logging/logging.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../middleware/auth_middleware.dart';

final _log = Logger('RiderRoute');

// In-memory state store for rider data
final Map<String, Map<String, dynamic>> _riderProfiles = {
  'usr_rider_001': {
    'user_id': 'usr_rider_001',
    'full_name': 'Babajide Ogundipe',
    'phone_number': '+2348031122334',
    'approval_status': 'APPROVED',
    'onboarding_status': 'APPROVED',
    'is_online': false,
    'current_zone': 'Lekki Phase 1',
    'battery_health': 92,
    'rating': 4.96,
    'completed_trips': 428,
  }
};

final List<Map<String, dynamic>> _mockOffers = [
  {
    'offer_id': 'dsp_off_001',
    'booking_id': 'bk_test_101',
    'service_code': 'RIDE_INSTANT',
    'pickup_address': 'Shaganu Central Hub, Ogun State',
    'dropoff_address': 'Remo Commercial Plaza, Shaganu, Ogun State',
    'pickup_distance_km': 1.2,
    'trip_distance_km': 6.8,
    'estimated_duration_minutes': 18,
    'net_earnings_kobo': 240000, // ₦2,400.00
    'expires_in_seconds': 30,
    'status': 'PENDING',
  }
];

Router riderRouter() {
  final router = Router();

  // POST /api/v1/rider/onboarding — Submit profile and document metadata
  router.post('/onboarding', (Request request) async {
    final userId = request.context[kAuthUserIdKey] as String? ?? 'usr_rider_001';
    final rawBody = await request.readAsString();
    final body = jsonDecode(rawBody) as Map<String, dynamic>;

    final profile = {
      'user_id': userId,
      'full_name': body['full_name'] ?? 'Rider Candidate',
      'approval_status': 'PENDING',
      'onboarding_status': 'DOCUMENTS_SUBMITTED',
      'is_online': false,
      'submitted_at': DateTime.now().toUtc().toIso8601String(),
    };
    _riderProfiles[userId] = profile;

    _log.info('Rider onboarding submitted for user: $userId');
    return Response.ok(
      jsonEncode({'data': profile, 'meta': {'status': 'submitted'}}),
      headers: {'content-type': 'application/json'},
    );
  });

  // GET /api/v1/rider/status — Retrieve approval and capability status
  router.get('/status', (Request request) async {
    final userId = request.context[kAuthUserIdKey] as String? ?? 'usr_rider_001';
    final profile = _riderProfiles[userId] ?? {
      'user_id': userId,
      'approval_status': 'APPROVED',
      'onboarding_status': 'APPROVED',
      'is_online': false,
      'rating': 4.96,
    };

    return Response.ok(
      jsonEncode({'data': profile}),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /api/v1/rider/availability — Toggle online/offline presence
  router.post('/availability', (Request request) async {
    final userId = request.context[kAuthUserIdKey] as String? ?? 'usr_rider_001';
    final rawBody = await request.readAsString();
    final body = jsonDecode(rawBody) as Map<String, dynamic>;
    final isOnline = body['is_online'] as bool? ?? false;

    final profile = _riderProfiles.putIfAbsent(userId, () => {'user_id': userId});
    profile['is_online'] = isOnline;
    profile['last_heartbeat'] = DateTime.now().toUtc().toIso8601String();

    _log.info('Rider availability set to $isOnline for user: $userId');
    return Response.ok(
      jsonEncode({'data': profile, 'meta': {'status': isOnline ? 'online' : 'offline'}}),
      headers: {'content-type': 'application/json'},
    );
  });

  // GET /api/v1/rider/offers — Available dispatch offers
  router.get('/offers', (Request request) async {
    return Response.ok(
      jsonEncode({'data': _mockOffers}),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /api/v1/rider/offers/<id>/accept — Atomically accept offer
  router.post('/offers/<id>/accept', (Request request, String id) async {
    final offerIndex = _mockOffers.indexWhere((o) => o['offer_id'] == id);
    if (offerIndex == -1) {
      return Response(
        409,
        body: jsonEncode({
          'error': {
            'code': 'OFFER_NO_LONGER_AVAILABLE',
            'message': 'Offer has expired or was accepted by another rider.',
          }
        }),
        headers: {'content-type': 'application/json'},
      );
    }

    final accepted = _mockOffers.removeAt(offerIndex);
    accepted['status'] = 'ACCEPTED';

    return Response.ok(
      jsonEncode({'data': accepted, 'meta': {'status': 'accepted'}}),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /api/v1/rider/offers/<id>/decline — Decline offer
  router.post('/offers/<id>/decline', (Request request, String id) async {
    _mockOffers.removeWhere((o) => o['offer_id'] == id);
    return Response.ok(
      jsonEncode({'meta': {'status': 'declined'}}),
      headers: {'content-type': 'application/json'},
    );
  });

  // GET /api/v1/rider/earnings — Weekly earnings breakdown and ledger
  router.get('/earnings', (Request request) async {
    final earningsData = {
      'settled_week_kobo': 8425000, // ₦84,250.00
      'gross_week_kobo': 9800000,
      'commission_week_kobo': 1960000, // 20%
      'tips_week_kobo': 585000, // 100% pass-through
      'bank_name': 'Access Bank',
      'masked_account_number': '•••• 4412',
      'next_payout_date': 'Tuesday, 08:00 AM',
      'entries': [
        {
          'id': 'led_entry_001',
          'reference': 'TX-2026-90412',
          'entry_type': 'TRIP_FARE',
          'net_amount_kobo': 240000,
          'description': 'Marina to VI Express Ride',
          'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        },
        {
          'id': 'led_entry_002',
          'reference': 'TX-2026-90413',
          'entry_type': 'TIP',
          'net_amount_kobo': 50000,
          'description': 'Customer Tip (100% pass-through)',
          'created_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
        }
      ]
    };

    return Response.ok(
      jsonEncode({'data': earningsData}),
      headers: {'content-type': 'application/json'},
    );
  });

  return router;
}
