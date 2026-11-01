import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

// In-memory profile and verification store
final Map<String, Map<String, dynamic>> _profilesStore = {};
final Map<String, Map<String, dynamic>> _verificationStore = {};

void resetProfileStoreForTest() {
  _profilesStore.clear();
  _verificationStore.clear();
}

Map<String, dynamic> _getOrCreateProfile(String userId, {String? fullName, String? email, String? phone}) {
  return _profilesStore.putIfAbsent(userId, () {
    return {
      'id': userId,
      'full_name': fullName ?? 'Customer',
      'email': email ?? '$userId@govolts.ng',
      'phone_number': phone ?? '+234 801 234 5678',
      'avatar_url': null,
      'roles': ['customer'],
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'carbon_avoided_kg': 14.8,
      'eco_points_balance': 450,
      'gender': 'prefer_not_to_say',
      'state': 'Lagos',
      'city': 'Lagos Island',
      'current_address': '14 Admiralty Way, Lekki Phase 1, Lagos',
      'emergency_contact_name': null,
      'emergency_contact_phone': null,
    };
  });
}

Map<String, dynamic> _getOrCreateVerification(String userId) {
  return _verificationStore.putIfAbsent(userId, () {
    return {
      'status': 'VERIFIED',
      'tier': 'Tier 1 (Basic)',
      'rejection_reason': null,
      'submitted_at': DateTime.now().subtract(const Duration(days: 14)).toIso8601String(),
      'verified_at': DateTime.now().subtract(const Duration(days: 14)).toIso8601String(),
      'required_documents': ['Government Issued ID', 'Proof of Residential Address'],
      'document_urls': {
        'nin_slip': 'https://storage.govolts.ng/docs/$userId/nin.jpg',
      },
    };
  });
}

Router profileRouter() {
  final router = Router();

  // GET /api/v1/profile/me
  router.get('/me', (Request request) async {
    final userId = request.url.queryParameters['user_id'] ?? 'usr-customer-01';
    final profile = _getOrCreateProfile(userId);
    return Response.ok(
      jsonEncode({'data': profile}),
      headers: {'content-type': 'application/json'},
    );
  });

  // GET /api/v1/profile/
  router.get('/', (Request request) async {
    final userId = request.url.queryParameters['user_id'] ?? 'usr-customer-01';
    final profile = _getOrCreateProfile(userId);
    return Response.ok(
      jsonEncode({'data': profile}),
      headers: {'content-type': 'application/json'},
    );
  });

  // PATCH /api/v1/profile/me
  router.patch('/me', (Request request) async {
    final bodyStr = await request.readAsString();
    Map<String, dynamic> body = {};
    if (bodyStr.isNotEmpty) {
      body = jsonDecode(bodyStr) as Map<String, dynamic>;
    }

    final userId = body['user_id'] as String? ?? request.url.queryParameters['user_id'] ?? 'usr-customer-01';
    final profile = _getOrCreateProfile(userId);

    if (body.containsKey('full_name')) profile['full_name'] = body['full_name'];
    if (body.containsKey('email')) profile['email'] = body['email'];
    if (body.containsKey('phone_number')) profile['phone_number'] = body['phone_number'];
    if (body.containsKey('gender')) profile['gender'] = body['gender'];
    if (body.containsKey('current_address')) profile['current_address'] = body['current_address'];
    if (body.containsKey('city')) profile['city'] = body['city'];
    if (body.containsKey('state')) profile['state'] = body['state'];
    if (body.containsKey('avatar_url')) profile['avatar_url'] = body['avatar_url'];
    if (body.containsKey('emergency_contact_name')) profile['emergency_contact_name'] = body['emergency_contact_name'];
    if (body.containsKey('emergency_contact_phone')) profile['emergency_contact_phone'] = body['emergency_contact_phone'];
    profile['updated_at'] = DateTime.now().toIso8601String();

    return Response.ok(
      jsonEncode({'data': profile}),
      headers: {'content-type': 'application/json'},
    );
  });

  // GET /api/v1/profile/verification
  router.get('/verification', (Request request) async {
    final userId = request.url.queryParameters['user_id'] ?? 'usr-customer-01';
    final verification = _getOrCreateVerification(userId);
    return Response.ok(
      jsonEncode({'data': verification}),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /api/v1/profile/verification/submit
  router.post('/verification/submit', (Request request) async {
    final bodyStr = await request.readAsString();
    Map<String, dynamic> body = {};
    if (bodyStr.isNotEmpty) {
      body = jsonDecode(bodyStr) as Map<String, dynamic>;
    }

    final userId = body['user_id'] as String? ?? request.url.queryParameters['user_id'] ?? 'usr-customer-01';
    final verification = _getOrCreateVerification(userId);

    verification['status'] = 'PENDING';
    verification['submitted_at'] = DateTime.now().toIso8601String();
    if (body.containsKey('document_urls')) {
      final docMap = body['document_urls'] as Map<String, dynamic>? ?? {};
      verification['document_urls'] = {
        ...(verification['document_urls'] as Map<String, dynamic>? ?? {}),
        ...docMap,
      };
    }

    return Response.ok(
      jsonEncode({
        'data': {
          'message': 'Verification documents submitted successfully for review.',
          'verification': verification,
        }
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  return router;
}

