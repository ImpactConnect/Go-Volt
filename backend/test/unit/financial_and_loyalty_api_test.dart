import 'dart:convert';
import 'package:backend/src/routes/loyalty_route.dart';
import 'package:backend/src/routes/wallet_route.dart';
import 'package:backend/src/server.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shelf/shelf.dart';

void main() {
  late Handler handler;

  setUp(() {
    handler = createServerHandler();
    seedWalletTransactionsForTest('usr-customer-01');
    seedLoyaltyFixtureForTest('usr-customer-01');
  });

  group('Wallet & Double-Entry Ledger API Tests (Master Tech Spec §5.8 & §8)', () {
    test('GET /api/v1/wallet/me returns authoritative ledger balance and currency', () async {
      final req = Request('GET', Uri.parse('http://localhost/api/v1/wallet/me'));
      final res = await handler(req);

      expect(res.statusCode, equals(200));
      final body = jsonDecode(await res.readAsString()) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;

      expect(data['currency'], equals('NGN'));
      expect(data['balance'], isA<num>());
      expect(data['balance'], greaterThanOrEqualTo(0));
    });

    test('GET /api/v1/wallet/transactions returns ledger-verified entries', () async {
      final req = Request('GET', Uri.parse('http://localhost/api/v1/wallet/transactions'));
      final res = await handler(req);

      expect(res.statusCode, equals(200));
      final body = jsonDecode(await res.readAsString()) as Map<String, dynamic>;
      final list = body['data'] as List<dynamic>;

      expect(list, isNotEmpty);
      final firstTx = list.first as Map<String, dynamic>;
      expect(firstTx.containsKey('amount'), isTrue);
      expect(firstTx.containsKey('is_credit'), isTrue);
      expect(firstTx.containsKey('reference'), isTrue);
      expect(firstTx['status'], equals('COMPLETED'));
    });

    test('POST /api/v1/wallet/top-up/initialize and verify rejects unpaid and credits verified payments', () async {
      // 1. Initialize
      final initReq = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/wallet/top-up/initialize'),
        body: jsonEncode({'amount_naira': 2500.0}),
        headers: {'content-type': 'application/json'},
      );
      final initRes = await handler(initReq);
      expect(initRes.statusCode, equals(200));
      final initBody = jsonDecode(await initRes.readAsString()) as Map<String, dynamic>;
      final initData = initBody['data'] as Map<String, dynamic>;
      final refCode = initData['reference'] as String;
      expect(refCode, isNotEmpty);

      // 2. Verify without payment completion - MUST BE REJECTED (Best practice security)
      final unpaidReq = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/wallet/top-up/verify'),
        body: jsonEncode({'reference': refCode, 'amount_naira': 2500.0}),
        headers: {'content-type': 'application/json'},
      );
      final unpaidRes = await handler(unpaidReq);
      expect(unpaidRes.statusCode, equals(400));
      final unpaidBody = jsonDecode(await unpaidRes.readAsString()) as Map<String, dynamic>;
      final err = unpaidBody['error'] as Map<String, dynamic>;
      expect(err['code'], equals('PAYMENT_NOT_CONFIRMED'));

      // 3. Mark payment verified by gateway/webhook and re-verify - MUST SUCCEED
      markTopUpPaidForTest(refCode, amountNaira: 2500.0);
      final paidReq = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/wallet/top-up/verify'),
        body: jsonEncode({'reference': refCode, 'amount_naira': 2500.0}),
        headers: {'content-type': 'application/json'},
      );
      final paidRes = await handler(paidReq);
      expect(paidRes.statusCode, equals(200));
      final paidBody = jsonDecode(await paidRes.readAsString()) as Map<String, dynamic>;
      final paidData = paidBody['data'] as Map<String, dynamic>;
      expect(paidData['balance'], isA<num>());
      expect(paidData['status'], equals('COMPLETED'));
    });
  });

  group('Loyalty & Eco-Points API Tests (Master Tech Spec §5.9 & §8.6)', () {
    test('GET /api/v1/loyalty/me returns points balance, tier, and referred friends', () async {
      final req = Request('GET', Uri.parse('http://localhost/api/v1/loyalty/me'));
      final res = await handler(req);

      expect(res.statusCode, equals(200));
      final body = jsonDecode(await res.readAsString()) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;

      expect(data['points_balance'], isA<int>());
      expect(data['tier_name'], contains('Green Pioneer'));
      expect(data['referral_code'], equals('VOLT-ALEX99'));
      final friends = data['referred_friends'] as List<dynamic>;
      expect(friends, isNotEmpty);
    });

    test('POST /api/v1/loyalty/redeem converts points into wallet credit atomically', () async {
      final req = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/loyalty/redeem'),
        body: jsonEncode({'points': 500, 'credit_naira': 50.0}),
        headers: {'content-type': 'application/json'},
      );
      final res = await handler(req);

      expect(res.statusCode, equals(200));
      final body = jsonDecode(await res.readAsString()) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      expect(data['status'], equals('success'));
      expect(data['wallet_credit_naira'], equals(50.0));
    });

    test('GET /api/v1/loyalty/conversion-rule returns dynamic admin-configured rule', () async {
      final req = Request('GET', Uri.parse('http://localhost/api/v1/loyalty/conversion-rule'));
      final res = await handler(req);

      expect(res.statusCode, equals(200));
      final body = jsonDecode(await res.readAsString()) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      expect(data['points_required'], isA<int>());
      expect(data['minimum_points'], isA<int>());
      expect(data['preset_points'], isA<List<dynamic>>());
    });

    test('Admin PUT /api/v1/loyalty/admin/conversion-rules dynamically modifies conversion rates and thresholds', () async {
      final updateReq = Request(
        'PUT',
        Uri.parse('http://localhost/api/v1/loyalty/admin/conversion-rules'),
        body: jsonEncode({
          'points_required': 20, // 20 pts = ₦1 (5 kobo per pt)
          'credit_amount_kobo': 100,
          'minimum_points': 400, // new minimum
          'maximum_points': 8000,
          'preset_points': [400, 800, 1600, 3200],
        }),
        headers: {'content-type': 'application/json'},
      );
      final updateRes = await handler(updateReq);
      expect(updateRes.statusCode, equals(200));

      final body = jsonDecode(await updateRes.readAsString()) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      expect(data['minimum_points'], equals(400));
      expect(data['points_required'], equals(20));

      // Attempt redemption below new admin-set minimum threshold (300 < 400)
      final rejectReq = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/loyalty/redeem'),
        body: jsonEncode({'points': 300}),
        headers: {'content-type': 'application/json'},
      );
      final rejectRes = await handler(rejectReq);
      expect(rejectRes.statusCode, equals(400));
      final rejectBody = jsonDecode(await rejectRes.readAsString()) as Map<String, dynamic>;
      final rejectError = rejectBody['error'] as Map<String, dynamic>;
      expect(rejectError['code'], equals('BELOW_MINIMUM_POINTS'));

      // Redeem at or above new admin-set threshold (400 pts -> 400 * 1 / 20 = ₦20)
      final redeemReq = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/loyalty/redeem'),
        body: jsonEncode({'points': 400}),
        headers: {'content-type': 'application/json'},
      );
      final redeemRes = await handler(redeemReq);
      expect(redeemRes.statusCode, equals(200));
      final redeemBody = jsonDecode(await redeemRes.readAsString()) as Map<String, dynamic>;
      final redeemData = redeemBody['data'] as Map<String, dynamic>;
      expect(redeemData['wallet_credit_naira'], equals(20.0));
    });
  });

  group('Coupons & Campaign Vouchers API Tests (Master Tech Spec §5.9 & §8.7)', () {
    test('GET /api/v1/coupons/me returns active promo catalogue', () async {
      final req = Request('GET', Uri.parse('http://localhost/api/v1/coupons/me'));
      final res = await handler(req);

      expect(res.statusCode, equals(200));
      final body = jsonDecode(await res.readAsString()) as Map<String, dynamic>;
      final list = body['data'] as List<dynamic>;

      expect(list.any((c) => (c as Map<String, dynamic>)['code'] == 'VOLTFIRST'), isTrue);
      expect(list.any((c) => (c as Map<String, dynamic>)['code'] == 'SCHOOLDROP'), isTrue);
    });

    test('POST /api/v1/coupons/validate validates valid coupon with met minimum spend', () async {
      final req = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/coupons/validate'),
        body: jsonEncode({'code': 'VOLTFIRST', 'order_amount': 2500.0}),
        headers: {'content-type': 'application/json'},
      );
      final res = await handler(req);

      expect(res.statusCode, equals(200));
      final body = jsonDecode(await res.readAsString()) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      expect(data['valid'], isTrue);
      expect(data['code'], equals('VOLTFIRST'));
      expect(data['discount_amount'], equals(500.0));
    });

    test('POST /api/v1/coupons/validate rejects unmet minimum spend', () async {
      final req = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/coupons/validate'),
        body: jsonEncode({'code': 'VOLTFIRST', 'order_amount': 500.0}),
        headers: {'content-type': 'application/json'},
      );
      final res = await handler(req);

      expect(res.statusCode, equals(400));
      final body = jsonDecode(await res.readAsString()) as Map<String, dynamic>;
      final error = body['error'] as Map<String, dynamic>;
      expect(error['code'], equals('MIN_SPEND_NOT_MET'));
    });
  });
}
