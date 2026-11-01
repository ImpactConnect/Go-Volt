import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'wallet_route.dart';

final Map<String, int> _userPointsStore = {};
final Map<String, List<Map<String, dynamic>>> _userReferredFriendsStore = {};

Map<String, dynamic> _activeConversionRule = {
  'id': 'lcr-001',
  'points_required': 10,
  'credit_amount_kobo': 100, // 10 pts = ₦1 (100 kobo)
  'minimum_points': 200,
  'maximum_points': 10000,
  'preset_points': [200, 500, 1000, 2500],
  'status': 'active',
  'version': 1,
  'effective_from': DateTime.now().toIso8601String(),
};

final Map<String, String> _userReferralCodes = {};

String getOrGenerateUserReferralCode(String userId, [String? userName]) {
  if (_userReferralCodes.containsKey(userId)) {
    return _userReferralCodes[userId]!;
  }
  final cleanName = (userName ?? '').replaceAll(RegExp(r'[^a-zA-Z]'), '').toUpperCase();
  final tag = cleanName.length >= 3 ? cleanName.substring(0, 3) : 'VOLT';
  final hexSuffix = (userId.hashCode.abs() % 0xFFFF).toRadixString(16).toUpperCase().padLeft(4, '0');
  final uniqueCode = 'VOLT-$tag$hexSuffix';
  _userReferralCodes[userId] = uniqueCode;
  return uniqueCode;
}

void seedLoyaltyFixtureForTest(String userId) {
  _userPointsStore[userId] = 4200;
  _userReferralCodes[userId] = 'VOLT-ALEX99';
  _userReferredFriendsStore[userId] = [
    {
      'name': 'Babatunde F.',
      'date': 'Yesterday',
      'status': 'First Ride Completed',
      'reward_amount_naira': 500.0,
    },
    {
      'name': 'Chioma E.',
      'date': '3 days ago',
      'status': 'Registered',
      'reward_amount_naira': 0.0,
    },
  ];
}

void resetLoyaltyStateForTest({String? userId, int? points}) {
  _userPointsStore.clear();
  _userReferredFriendsStore.clear();
  _userReferralCodes.clear();
  if (userId != null && points != null) {
    _userPointsStore[userId] = points;
  }
  _activeConversionRule = {
    'id': 'lcr-001',
    'points_required': 10,
    'credit_amount_kobo': 100,
    'minimum_points': 200,
    'maximum_points': 10000,
    'preset_points': [200, 500, 1000, 2500],
    'status': 'active',
    'version': 1,
    'effective_from': DateTime.now().toIso8601String(),
  };
}

Router loyaltyRouter() {
  final router = Router();

  // GET /me
  router.get('/me', (Request request) async {
    final userId = request.url.queryParameters['user_id'] ??
        request.headers['x-user-id'] ??
        'usr-customer-01';
    final userName = request.url.queryParameters['user_name'];
    final uniqueReferralCode = getOrGenerateUserReferralCode(userId, userName);

    final pointsRequired = (_activeConversionRule['points_required'] as num).toInt();
    final creditAmountKobo = (_activeConversionRule['credit_amount_kobo'] as num).toInt();
    final effectiveConversionRate = ((pointsRequired * 100) / creditAmountKobo).round();

    final userPoints = _userPointsStore[userId] ?? 0;
    final userReferredFriends = _userReferredFriendsStore[userId] ?? [];
    final referralEarnings = userReferredFriends
        .where((f) => f['status'] == 'First Ride Completed')
        .fold<double>(0.0, (sum, f) => sum + ((f['reward_amount_naira'] as num?)?.toDouble() ?? 500.0));

    final String tierName;
    final String nextTierName;
    final int nextTierThreshold;
    final int tierFloor;
    if (userPoints >= 2500) {
      tierName = 'Green Pioneer (Level 3)';
      nextTierName = 'Eco Champion (Level 4)';
      nextTierThreshold = 5000;
      tierFloor = 2500;
    } else if (userPoints >= 500) {
      tierName = 'Eco Cruiser (Level 2)';
      nextTierName = 'Green Pioneer (Level 3)';
      nextTierThreshold = 2500;
      tierFloor = 500;
    } else {
      tierName = 'Starter (Level 1)';
      nextTierName = 'Eco Cruiser (Level 2)';
      nextTierThreshold = 500;
      tierFloor = 0;
    }

    final payload = {
      'data': {
        'points_balance': userPoints,
        'conversion_rate': effectiveConversionRate,
        'tier_name': tierName,
        'points_expiring_soon': userPoints > 100 ? (userPoints * 0.05).round() : 0,
        'referral_code': uniqueReferralCode,
        'referral_count': userReferredFriends.length,
        'referral_earnings': referralEarnings,
        'next_tier_name': nextTierName,
        'next_tier_points_threshold': nextTierThreshold,
        'current_tier_points_floor': tierFloor,
        'referred_friends': userReferredFriends,
        'conversion_rule': _activeConversionRule,
      },
      'meta': {'status': 'success'},
    };
    return Response.ok(
      jsonEncode(payload),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /referral-code/generate
  router.post('/referral-code/generate', (Request request) async {
    final raw = await request.readAsString();
    final body = raw.isNotEmpty ? jsonDecode(raw) as Map<String, dynamic> : <String, dynamic>{};
    final userId = body['user_id'] as String? ?? request.headers['x-user-id'] ?? 'usr-customer-new';
    final userName = body['user_name'] as String?;
    final code = getOrGenerateUserReferralCode(userId, userName);

    return Response.ok(
      jsonEncode({
        'data': {
          'referral_code': code,
          'user_id': userId,
        },
        'meta': {'status': 'success'},
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  // GET /conversion-rule
  router.get('/conversion-rule', (Request request) async {
    final payload = {
      'data': _activeConversionRule,
      'meta': {'status': 'success'},
    };
    return Response.ok(
      jsonEncode(payload),
      headers: {'content-type': 'application/json'},
    );
  });

  // Admin GET /admin/conversion-rules
  router.get('/admin/conversion-rules', (Request request) async {
    final payload = {
      'data': [_activeConversionRule],
      'meta': {'status': 'success', 'count': 1},
    };
    return Response.ok(
      jsonEncode(payload),
      headers: {'content-type': 'application/json'},
    );
  });

  // Admin PUT /admin/conversion-rules
  router.put('/admin/conversion-rules', (Request request) async {
    final raw = await request.readAsString();
    final body = jsonDecode(raw) as Map<String, dynamic>;

    final currentVersion = (_activeConversionRule['version'] as num?)?.toInt() ?? 1;
    final pointsRequired = (body['points_required'] as num?)?.toInt() ??
        (_activeConversionRule['points_required'] as num).toInt();
    final creditAmountKobo = (body['credit_amount_kobo'] as num?)?.toInt() ??
        (_activeConversionRule['credit_amount_kobo'] as num).toInt();
    final minPoints = (body['minimum_points'] as num?)?.toInt() ??
        (_activeConversionRule['minimum_points'] as num).toInt();
    final maxPoints = (body['maximum_points'] as num?)?.toInt() ??
        (_activeConversionRule['maximum_points'] as num).toInt();
    final presetPoints = body['preset_points'] != null
        ? (body['preset_points'] as List<dynamic>).map((e) => (e as num).toInt()).toList()
        : List<int>.from(_activeConversionRule['preset_points'] as List);

    _activeConversionRule = {
      'id': 'lcr-${DateTime.now().millisecondsSinceEpoch}',
      'points_required': pointsRequired,
      'credit_amount_kobo': creditAmountKobo,
      'minimum_points': minPoints,
      'maximum_points': maxPoints,
      'preset_points': presetPoints,
      'status': 'active',
      'version': currentVersion + 1,
      'effective_from': DateTime.now().toIso8601String(),
    };

    final payload = {
      'data': _activeConversionRule,
      'meta': {'status': 'success', 'message': 'Loyalty conversion rule updated successfully.'},
    };
    return Response.ok(
      jsonEncode(payload),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /redeem
  router.post('/redeem', (Request request) async {
    final raw = await request.readAsString();
    final body = jsonDecode(raw) as Map<String, dynamic>;
    final userId = body['user_id'] as String? ?? request.headers['x-user-id'] ?? 'usr-customer-01';

    final minThreshold = (_activeConversionRule['minimum_points'] as num).toInt();
    final maxThreshold = (_activeConversionRule['maximum_points'] as num).toInt();
    final pointsRequired = (_activeConversionRule['points_required'] as num).toInt();
    final creditAmountKobo = (_activeConversionRule['credit_amount_kobo'] as num).toInt();

    final points = (body['points'] as num?)?.toInt() ?? minThreshold;
    final userPoints = _userPointsStore[userId] ?? 0;

    if (points < minThreshold) {
      return Response(400,
          body: jsonEncode({
            'error': {
              'code': 'BELOW_MINIMUM_POINTS',
              'message': 'Minimum redemption threshold is $minThreshold Eco-Points.',
            }
          }),
          headers: {'content-type': 'application/json'});
    }

    if (points > maxThreshold) {
      return Response(400,
          body: jsonEncode({
            'error': {
              'code': 'EXCEEDS_MAXIMUM_POINTS',
              'message': 'Maximum redemption limit is $maxThreshold Eco-Points.',
            }
          }),
          headers: {'content-type': 'application/json'});
    }

    if (points > userPoints) {
      return Response(400,
          body: jsonEncode({
            'error': {'code': 'INSUFFICIENT_POINTS', 'message': 'Insufficient Eco-Points available.'}
          }),
          headers: {'content-type': 'application/json'});
    }

    final dynamicCreditNaira = (points * (creditAmountKobo / 100.0)) / pointsRequired;

    final remaining = userPoints - points;
    _userPointsStore[userId] = remaining;

    creditWalletBalance(
      dynamicCreditNaira,
      'Eco-Points Redemption ($points pts)',
      'RWD-RED-${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
    );

    final payload = {
      'data': {
        'status': 'success',
        'points_deducted': points,
        'remaining_points': remaining,
        'wallet_credit_naira': dynamicCreditNaira,
      },
    };
    return Response.ok(
      jsonEncode(payload),
      headers: {'content-type': 'application/json'},
    );
  });

  return router;
}
