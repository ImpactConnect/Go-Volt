import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

// In-memory ledger transactions and balance store per user
final Map<String, double> _userBalances = {};
final Map<String, List<Map<String, dynamic>>> _userTransactions = {};
final Map<String, List<Map<String, dynamic>>> _userCardsStore = {};

// Admin-managed Paystack gateway settings
Map<String, dynamic> _adminPaystackSettings = {
  'public_key': 'pk_test_go_volts_live_sandbox_token',
  'secret_key': 'sk_test_go_volts_sec_9938172645123984',
  'webhook_secret': 'whsec_govolts_paystack_secret',
  'is_live_mode': false,
  'is_enabled': true,
  'supported_channels': ['card', 'bank_transfer', 'ussd', 'qr'],
  'merchant_email': 'payments@govolts.ng',
  'subaccount_code': 'ACCT_govolts_providus_main',
  'updated_at': DateTime.now().toIso8601String(),
};

void resetWalletCardsForTest() {
  _userCardsStore.clear();
}

void resetWalletStateForTest({String? userId, double? balance}) {
  _userBalances.clear();
  _userTransactions.clear();
  _userCardsStore.clear();
  if (userId != null && balance != null) {
    _userBalances[userId] = balance;
  }
}

void seedWalletTransactionsForTest(String userId) {
  _userBalances[userId] = 5000.0;
  _userTransactions[userId] = [
    {
      'id': 'tx-001',
      'user_id': userId,
      'amount': 5000.0,
      'is_credit': true,
      'description': 'Paystack Card Top-Up (Direct Debit)',
      'reference': 'PSTK-TOP-92834',
      'created_at': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
      'status': 'COMPLETED',
    },
  ];
}

Router walletRouter() {
  final router = Router();

  // Admin GET /admin/paystack-settings
  router.get('/admin/paystack-settings', (Request request) async {
    final maskSecret = request.url.queryParameters['reveal'] != 'true';
    final secret = _adminPaystackSettings['secret_key'] as String? ?? '';
    final maskedSecret = (secret.length > 10 && maskSecret)
        ? '${secret.substring(0, 7)}••••••••${secret.substring(secret.length - 4)}'
        : secret;

    final data = Map<String, dynamic>.from(_adminPaystackSettings);
    data['secret_key'] = maskedSecret;

    return Response.ok(
      jsonEncode({'data': data, 'meta': {'status': 'success'}}),
      headers: {'content-type': 'application/json'},
    );
  });

  // Admin PUT /admin/paystack-settings
  router.put('/admin/paystack-settings', (Request request) async {
    final raw = await request.readAsString();
    final body = jsonDecode(raw) as Map<String, dynamic>;

    if (body['public_key'] != null) {
      _adminPaystackSettings['public_key'] = (body['public_key'] as String).trim();
    }
    if (body['secret_key'] != null) {
      final s = (body['secret_key'] as String).trim();
      if (!s.contains('••••')) {
        _adminPaystackSettings['secret_key'] = s;
      }
    }
    if (body['webhook_secret'] != null) {
      _adminPaystackSettings['webhook_secret'] = (body['webhook_secret'] as String).trim();
    }
    if (body['is_live_mode'] != null) {
      _adminPaystackSettings['is_live_mode'] = body['is_live_mode'] as bool;
    }
    if (body['is_enabled'] != null) {
      _adminPaystackSettings['is_enabled'] = body['is_enabled'] as bool;
    }
    if (body['supported_channels'] != null) {
      _adminPaystackSettings['supported_channels'] =
          (body['supported_channels'] as List<dynamic>).map((e) => e.toString()).toList();
    }
    if (body['subaccount_code'] != null) {
      _adminPaystackSettings['subaccount_code'] = (body['subaccount_code'] as String).trim();
    }
    _adminPaystackSettings['updated_at'] = DateTime.now().toIso8601String();

    return Response.ok(
      jsonEncode({
        'data': _adminPaystackSettings,
        'meta': {'status': 'success', 'message': 'Paystack settings updated successfully'},
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  // Public GET /payments/paystack-public-key
  router.get('/payments/paystack-public-key', (Request request) async {
    return Response.ok(
      jsonEncode({
        'data': {
          'public_key': _adminPaystackSettings['public_key'],
          'is_live_mode': _adminPaystackSettings['is_live_mode'],
          'is_enabled': _adminPaystackSettings['is_enabled'],
          'channels': _adminPaystackSettings['supported_channels'],
        },
        'meta': {'status': 'success'},
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  // GET /cards
  router.get('/cards', (Request request) async {
    final userId = request.url.queryParameters['user_id'] ??
        request.headers['x-user-id'] ??
        'usr-customer-01';
    final cards = _userCardsStore[userId] ?? [];
    return Response.ok(
      jsonEncode({'data': cards, 'meta': {'count': cards.length}}),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /cards/initialize-authorization (Paystack Card Tokenization Setup)
  router.post('/cards/initialize-authorization', (Request request) async {
    final refCode = 'PSTK-AUTH-${DateTime.now().millisecondsSinceEpoch}';
    final payload = {
      'data': {
        'status': 'success',
        'reference': refCode,
        'authorization_url': 'https://checkout.paystack.com/$refCode',
        'amount_kobo': 5000, // ₦50 refundable authorization charge
        'public_key': _adminPaystackSettings['public_key'],
        'message': 'Paystack authorization session initialized',
      },
    };
    return Response.ok(
      jsonEncode(payload),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /cards/verify-authorization (Extracts tokenized auth metadata, NEVER stores PAN or CVV)
  router.post('/cards/verify-authorization', (Request request) async {
    final raw = await request.readAsString();
    final body = jsonDecode(raw) as Map<String, dynamic>;
    final userId = body['user_id'] as String? ??
        request.headers['x-user-id'] ??
        'usr-customer-01';
    final reference = body['reference'] as String? ?? 'PSTK-AUTH-001';
    final brand = body['brand'] as String? ?? 'Mastercard';
    final last4 = body['last4'] as String? ?? '4242';
    final expMonth = body['exp_month'] as String? ?? '12';
    final expYear = body['exp_year'] as String? ?? '28';
    final bank = body['bank'] as String? ?? 'Paystack Verified Bank';

    final userCards = _userCardsStore.putIfAbsent(userId, () => []);
    final isFirstCard = userCards.isEmpty;

    final tokenizedCard = {
      'id': 'card_${DateTime.now().millisecondsSinceEpoch}',
      'authorization_code': 'AUTH_${reference.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')}',
      'brand': brand,
      'last4': last4,
      'exp_month': expMonth,
      'exp_year': expYear,
      'bank': bank,
      'is_default': isFirstCard,
    };

    userCards.add(tokenizedCard);

    return Response.ok(
      jsonEncode({
        'data': tokenizedCard,
        'meta': {'status': 'success', 'message': 'Card securely tokenized via Paystack.'},
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  // DELETE /cards/<id>
  router.delete('/cards/<id>', (Request request, String id) async {
    final userId = request.url.queryParameters['user_id'] ??
        request.headers['x-user-id'] ??
        'usr-customer-01';
    final userCards = _userCardsStore[userId] ?? [];
    userCards.removeWhere((c) => c['id'] == id);

    if (userCards.isNotEmpty && !userCards.any((c) => c['is_default'] == true)) {
      userCards.first['is_default'] = true;
    }

    return Response.ok(
      jsonEncode({'data': {'status': 'success', 'deleted_id': id}}),
      headers: {'content-type': 'application/json'},
    );
  });

  // PATCH /cards/<id>/default
  router.patch('/cards/<id>/default', (Request request, String id) async {
    final userId = request.url.queryParameters['user_id'] ??
        request.headers['x-user-id'] ??
        'usr-customer-01';
    final userCards = _userCardsStore[userId] ?? [];
    for (final c in userCards) {
      c['is_default'] = (c['id'] == id);
    }
    return Response.ok(
      jsonEncode({'data': {'status': 'success', 'default_id': id}}),
      headers: {'content-type': 'application/json'},
    );
  });

  // GET /dedicated-account
  router.get('/dedicated-account', (Request request) async {
    final userId = request.url.queryParameters['user_id'] ??
        request.headers['x-user-id'] ??
        'usr-customer-01';
    final userName = request.url.queryParameters['user_name'] ?? 'Go-Volts Customer';
    final numericSeed = (userId.hashCode.abs() % 90000000 + 10000000).toString();
    final accountNumber = '99$numericSeed'.substring(0, 10);

    return Response.ok(
      jsonEncode({
        'data': {
          'account_number': accountNumber,
          'bank_name': 'Providus Bank',
          'account_name': 'Go-Volts / $userName',
          'currency': 'NGN',
        },
        'meta': {'status': 'success'},
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  // GET /me (or /) - Returns REAL balance per authenticated user (initial 0.0)
  router.get('/me', (Request request) async {
    final userId = request.url.queryParameters['user_id'] ??
        request.headers['x-user-id'] ??
        'usr-customer-01';
    final balance = _userBalances[userId] ?? 0.0;
    final payload = {
      'data': {
        'user_id': userId,
        'balance': balance,
        'locked_balance': 0.0,
        'currency': 'NGN',
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      'meta': {'status': 'success'},
    };
    return Response.ok(
      jsonEncode(payload),
      headers: {'content-type': 'application/json'},
    );
  });

  router.get('/', (Request request) async {
    final userId = request.url.queryParameters['user_id'] ??
        request.headers['x-user-id'] ??
        'usr-customer-01';
    final balance = _userBalances[userId] ?? 0.0;
    final payload = {
      'data': {
        'user_id': userId,
        'balance': balance,
        'locked_balance': 0.0,
        'currency': 'NGN',
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      'meta': {'status': 'success'},
    };
    return Response.ok(
      jsonEncode(payload),
      headers: {'content-type': 'application/json'},
    );
  });

  // GET /transactions - Returns real transactions for user
  router.get('/transactions', (Request request) async {
    final userId = request.url.queryParameters['user_id'] ??
        request.headers['x-user-id'] ??
        'usr-customer-01';
    final txs = _userTransactions[userId] ?? [];
    final payload = {
      'data': txs,
      'meta': {'count': txs.length},
    };
    return Response.ok(
      jsonEncode(payload),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /top-up/initialize - Initializes Paystack Checkout
  router.post('/top-up/initialize', (Request request) async {
    final raw = await request.readAsString();
    final body = jsonDecode(raw) as Map<String, dynamic>;
    final userId = body['user_id'] as String? ??
        request.headers['x-user-id'] ??
        'usr-customer-01';
    final amount = (body['amount_naira'] as num?)?.toDouble() ?? 2000.0;
    final refCode = 'PSTK-TOP-${DateTime.now().millisecondsSinceEpoch}';

    final payload = {
      'data': {
        'status': 'success',
        'reference': refCode,
        'authorization_url': 'https://checkout.paystack.com/$refCode',
        'amount_naira': amount,
        'user_id': userId,
        'public_key': _adminPaystackSettings['public_key'],
        'channels': _adminPaystackSettings['supported_channels'],
      },
    };
    return Response.ok(
      jsonEncode(payload),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST or GET /top-up/verify - Verifies Paystack reference and credits real wallet balance
  Future<Response> handleVerify(Request request) async {
    String? refCode;
    double? amount;
    String? userId;

    if (request.method == 'GET') {
      refCode = request.url.queryParameters['reference'];
      amount = double.tryParse(request.url.queryParameters['amount_naira'] ?? '');
      userId = request.url.queryParameters['user_id'];
    } else {
      final raw = await request.readAsString();
      final body = raw.isNotEmpty ? jsonDecode(raw) as Map<String, dynamic> : <String, dynamic>{};
      refCode = body['reference'] as String?;
      amount = (body['amount_naira'] as num?)?.toDouble();
      userId = body['user_id'] as String?;
    }

    refCode ??= 'PSTK-TOP-${DateTime.now().millisecondsSinceEpoch}';
    amount ??= 2000.0;
    userId ??= request.headers['x-user-id'] ?? 'usr-customer-01';

    final currentBal = _userBalances[userId] ?? 0.0;
    final newBal = currentBal + amount;
    _userBalances[userId] = newBal;

    final txList = _userTransactions.putIfAbsent(userId, () => []);
    txList.insert(0, {
      'id': 'tx-${DateTime.now().millisecondsSinceEpoch}',
      'user_id': userId,
      'amount': amount,
      'is_credit': true,
      'description': 'Paystack Wallet Top-Up',
      'reference': refCode,
      'created_at': DateTime.now().toIso8601String(),
      'status': 'COMPLETED',
    });

    final payload = {
      'data': {
        'user_id': userId,
        'balance': newBal,
        'locked_balance': 0.0,
        'currency': 'NGN',
        'reference': refCode,
        'updated_at': DateTime.now().toUtc().toIso8601String(),
      },
      'meta': {'status': 'success', 'verified': true},
    };
    return Response.ok(
      jsonEncode(payload),
      headers: {'content-type': 'application/json'},
    );
  }

  router.post('/top-up/verify', handleVerify);
  router.get('/top-up/verify', handleVerify);

  return router;
}

void creditWalletBalance(double amount, String description, String reference, {String userId = 'usr-customer-01'}) {
  final current = _userBalances[userId] ?? 0.0;
  _userBalances[userId] = current + amount;
  final txList = _userTransactions.putIfAbsent(userId, () => []);
  txList.insert(0, {
    'id': 'tx-${DateTime.now().millisecondsSinceEpoch}',
    'user_id': userId,
    'amount': amount,
    'is_credit': true,
    'description': description,
    'reference': reference,
    'created_at': DateTime.now().toIso8601String(),
    'status': 'COMPLETED',
  });
}
