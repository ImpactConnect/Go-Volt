import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

List<Map<String, dynamic>> _couponsStore = [
  {
    'id': 'cp_first_01',
    'code': 'VOLTFIRST',
    'title': '₦500 Off First 3 Clean EV Rides',
    'discount_amount': 500.0,
    'min_order_amount': 1500.0,
    'expiry_date': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
    'is_used': false,
    'is_active': true,
    'description': 'Welcome reward for first-time Go-Volts riders',
  },
  {
    'id': 'cp_lekki_02',
    'code': 'CLEANLEKKI',
    'title': '₦1,000 Off Scheduled Commutes',
    'discount_amount': 1000.0,
    'min_order_amount': 5000.0,
    'expiry_date': DateTime.now().add(const Duration(days: 60)).toIso8601String(),
    'is_used': false,
    'is_active': true,
    'description': 'Discount for weekly or monthly scheduled commutes',
  },
  {
    'id': 'cp_school_03',
    'code': 'SCHOOLDROP',
    'title': '₦2,500 Off School Run Package',
    'discount_amount': 2500.0,
    'min_order_amount': 10000.0,
    'expiry_date': DateTime.now().add(const Duration(days: 90)).toIso8601String(),
    'is_used': false,
    'is_active': true,
    'description': 'Subscription voucher for registered student school runs',
  },
  {
    'id': 'cp_eco_04',
    'code': 'ECOSEND',
    'title': '20% Off Eco-Parcel Delivery Across Ogun State',
    'discount_amount': 400.0,
    'min_order_amount': 1000.0,
    'expiry_date': DateTime.now().add(const Duration(days: 45)).toIso8601String(),
    'is_used': false,
    'is_active': true,
    'description': 'Express parcel delivery discount',
  },
];

void resetCouponsStateForTest() {
  _couponsStore = [
    {
      'id': 'cp_first_01',
      'code': 'VOLTFIRST',
      'title': '₦500 Off First 3 Clean EV Rides',
      'discount_amount': 500.0,
      'min_order_amount': 1500.0,
      'expiry_date': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      'is_used': false,
      'is_active': true,
      'description': 'Welcome reward for first-time Go-Volts riders',
    },
    {
      'id': 'cp_lekki_02',
      'code': 'CLEANLEKKI',
      'title': '₦1,000 Off Scheduled Commutes',
      'discount_amount': 1000.0,
      'min_order_amount': 5000.0,
      'expiry_date': DateTime.now().add(const Duration(days: 60)).toIso8601String(),
      'is_used': false,
      'is_active': true,
      'description': 'Discount for weekly or monthly scheduled commutes',
    },
    {
      'id': 'cp_school_03',
      'code': 'SCHOOLDROP',
      'title': '₦2,500 Off School Run Package',
      'discount_amount': 2500.0,
      'min_order_amount': 10000.0,
      'expiry_date': DateTime.now().add(const Duration(days: 90)).toIso8601String(),
      'is_used': false,
      'is_active': true,
      'description': 'Subscription voucher for registered student school runs',
    },
    {
      'id': 'cp_eco_04',
      'code': 'ECOSEND',
      'title': '20% Off Eco-Parcel Delivery Across Ogun State',
      'discount_amount': 400.0,
      'min_order_amount': 1000.0,
      'expiry_date': DateTime.now().add(const Duration(days: 45)).toIso8601String(),
      'is_used': false,
      'is_active': true,
      'description': 'Express parcel delivery discount',
    },
  ];
}

Router couponsRouter() {
  final router = Router();

  // Customer: GET /me or / (returns only active, non-expired coupons created by admin)
  router.get('/me', (Request request) async {
    final now = DateTime.now();
    final activeCoupons = _couponsStore.where((c) {
      final isActive = c['is_active'] as bool? ?? true;
      final isUsed = c['is_used'] as bool? ?? false;
      final expiry = DateTime.tryParse(c['expiry_date'] as String? ?? '') ?? now;
      return isActive && !isUsed && expiry.isAfter(now);
    }).toList();

    final payload = {
      'data': activeCoupons,
      'meta': {'count': activeCoupons.length},
    };
    return Response.ok(
      jsonEncode(payload),
      headers: {'content-type': 'application/json'},
    );
  });

  router.get('/', (Request request) async {
    final now = DateTime.now();
    final activeCoupons = _couponsStore.where((c) {
      final isActive = c['is_active'] as bool? ?? true;
      final isUsed = c['is_used'] as bool? ?? false;
      final expiry = DateTime.tryParse(c['expiry_date'] as String? ?? '') ?? now;
      return isActive && !isUsed && expiry.isAfter(now);
    }).toList();

    final payload = {
      'data': activeCoupons,
      'meta': {'count': activeCoupons.length},
    };
    return Response.ok(
      jsonEncode(payload),
      headers: {'content-type': 'application/json'},
    );
  });

  // Admin: GET /admin (returns all coupons including inactive/expired)
  router.get('/admin', (Request request) async {
    final payload = {
      'data': _couponsStore,
      'meta': {'count': _couponsStore.length},
    };
    return Response.ok(
      jsonEncode(payload),
      headers: {'content-type': 'application/json'},
    );
  });

  // Admin: POST /admin (creates a new admin promo code)
  router.post('/admin', (Request request) async {
    final raw = await request.readAsString();
    final body = jsonDecode(raw) as Map<String, dynamic>;

    final code = (body['code'] as String? ?? '').trim().toUpperCase();
    if (code.isEmpty) {
      return Response(400,
          body: jsonEncode({'error': {'code': 'INVALID_CODE', 'message': 'Coupon code is required.'}}),
          headers: {'content-type': 'application/json'});
    }

    if (_couponsStore.any((c) => (c['code'] as String).toUpperCase() == code)) {
      return Response(409,
          body: jsonEncode({'error': {'code': 'DUPLICATE_CODE', 'message': 'Promo code "$code" already exists.'}}),
          headers: {'content-type': 'application/json'});
    }

    final newCoupon = {
      'id': 'cp_${code.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}',
      'code': code,
      'title': body['title'] as String? ?? 'Admin Reward Voucher',
      'discount_amount': (body['discount_amount'] as num?)?.toDouble() ?? 500.0,
      'min_order_amount': (body['min_order_amount'] as num?)?.toDouble() ?? 1000.0,
      'expiry_date': body['expiry_date'] as String? ??
          DateTime.now().add(const Duration(days: 30)).toIso8601String(),
      'is_used': false,
      'is_active': body['is_active'] as bool? ?? true,
      'description': body['description'] as String? ?? 'Created by administrator',
    };

    _couponsStore.insert(0, newCoupon);

    final payload = {
      'data': newCoupon,
      'meta': {'status': 'success', 'message': 'Coupon created successfully by admin.'},
    };
    return Response.ok(
      jsonEncode(payload),
      headers: {'content-type': 'application/json'},
    );
  });

  // Admin: PATCH /admin/<codeOrId>/toggle
  router.patch('/admin/<codeOrId>/toggle', (Request request, String codeOrId) async {
    final index = _couponsStore.indexWhere(
      (c) => (c['code'] as String).toUpperCase() == codeOrId.toUpperCase() || c['id'] == codeOrId,
    );

    if (index == -1) {
      return Response(404,
          body: jsonEncode({'error': {'code': 'NOT_FOUND', 'message': 'Coupon "$codeOrId" not found.'}}),
          headers: {'content-type': 'application/json'});
    }

    final current = _couponsStore[index];
    final currentStatus = current['is_active'] as bool? ?? true;
    _couponsStore[index] = {
      ...current,
      'is_active': !currentStatus,
    };

    final payload = {
      'data': _couponsStore[index],
      'meta': {'status': 'success'},
    };
    return Response.ok(
      jsonEncode(payload),
      headers: {'content-type': 'application/json'},
    );
  });

  // Customer: POST /validate
  router.post('/validate', (Request request) async {
    final raw = await request.readAsString();
    final body = jsonDecode(raw) as Map<String, dynamic>;
    final code = (body['code'] as String? ?? '').trim().toUpperCase();
    final orderAmount = (body['order_amount'] as num?)?.toDouble() ?? 0.0;

    final now = DateTime.now();
    final match = _couponsStore.firstWhere(
      (c) {
        final matchesCode = (c['code'] as String).toUpperCase() == code;
        final isActive = c['is_active'] as bool? ?? true;
        final isUsed = c['is_used'] as bool? ?? false;
        final expiry = DateTime.tryParse(c['expiry_date'] as String? ?? '') ?? now;
        return matchesCode && isActive && !isUsed && expiry.isAfter(now);
      },
      orElse: () => {},
    );

    if (match.isEmpty) {
      return Response(404,
          body: jsonEncode({
            'error': {'code': 'INVALID_COUPON', 'message': 'Promo code "$code" is invalid or expired.'}
          }),
          headers: {'content-type': 'application/json'});
    }

    final minOrder = match['min_order_amount'] as double;
    if (orderAmount > 0 && orderAmount < minOrder) {
      return Response(400,
          body: jsonEncode({
            'error': {
              'code': 'MIN_SPEND_NOT_MET',
              'message': 'Minimum spend of ₦${minOrder.toStringAsFixed(0)} required for this voucher.'
            }
          }),
          headers: {'content-type': 'application/json'});
    }

    final payload = {
      'data': {
        'valid': true,
        'code': match['code'],
        'title': match['title'],
        'discount_amount': match['discount_amount'],
      },
    };
    return Response.ok(
      jsonEncode(payload),
      headers: {'content-type': 'application/json'},
    );
  });

  return router;
}
