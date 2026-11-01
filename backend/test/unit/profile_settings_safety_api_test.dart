import 'dart:convert';
import 'package:backend/src/server.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shelf/shelf.dart';

void main() {
  late Handler handler;

  setUp(() {
    handler = createServerHandler();
  });

  group('Profile & Verification API Tests (Master Spec §A1-A4)', () {
    test('GET /api/v1/profile/me returns customer profile with dynamic metadata', () async {
      final req = Request('GET', Uri.parse('http://localhost/api/v1/profile/me?user_id=usr_tst_01'));
      final res = await handler(req);

      expect(res.statusCode, equals(200));
      final body = jsonDecode(await res.readAsString()) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      expect(data['id'], equals('usr_tst_01'));
      expect(data['full_name'], isNotEmpty);
      expect(data['carbon_avoided_kg'], isNotNull);
    });

    test('PATCH /api/v1/profile/me updates user legal name and contact address', () async {
      final updatePayload = {
        'user_id': 'usr_tst_01',
        'full_name': 'Daniel Emeka Okafor',
        'current_address': 'Plot 25 Admiralty Way, Lekki Phase 1',
        'city': 'Lekki',
      };
      final req = Request(
        'PATCH',
        Uri.parse('http://localhost/api/v1/profile/me'),
        body: jsonEncode(updatePayload),
        headers: {'content-type': 'application/json'},
      );
      final res = await handler(req);

      expect(res.statusCode, equals(200));
      final body = jsonDecode(await res.readAsString()) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      expect(data['full_name'], equals('Daniel Emeka Okafor'));
      expect(data['current_address'], equals('Plot 25 Admiralty Way, Lekki Phase 1'));
    });

    test('GET and POST /api/v1/profile/verification tracks authoritative document status', () async {
      final getReq = Request('GET', Uri.parse('http://localhost/api/v1/profile/verification?user_id=usr_tst_01'));
      final getRes = await handler(getReq);
      expect(getRes.statusCode, equals(200));

      final submitPayload = {
        'user_id': 'usr_tst_01',
        'document_urls': {
          'voter_card': 'https://storage.govolts.ng/docs/usr_tst_01/voters.jpg',
        },
      };
      final postReq = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/profile/verification/submit'),
        body: jsonEncode(submitPayload),
        headers: {'content-type': 'application/json'},
      );
      final postRes = await handler(postReq);
      expect(postRes.statusCode, equals(200));
      final body = jsonDecode(await postRes.readAsString()) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      final verification = data['verification'] as Map<String, dynamic>;
      expect(verification['status'], equals('PENDING'));
    });
  });

  group('Settings & Saved Places API Tests (Master Spec §B1-B3)', () {
    test('GET and PATCH /api/v1/notification-preferences updates service-grouped alerts', () async {
      final patchPayload = {
        'user_id': 'usr_tst_01',
        'promotions_and_coupons': true,
        'errand_agent_updates': false,
      };
      final patchReq = Request(
        'PATCH',
        Uri.parse('http://localhost/api/v1/notification-preferences'),
        body: jsonEncode(patchPayload),
        headers: {'content-type': 'application/json'},
      );
      final patchRes = await handler(patchReq);
      expect(patchRes.statusCode, equals(200));

      final body = jsonDecode(await patchRes.readAsString()) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      expect(data['promotions_and_coupons'], isTrue);
      expect(data['errand_agent_updates'], isFalse);
    });

    test('GET, POST and DELETE /api/v1/saved-places enforces dependent plan deletion guard', () async {
      // 1. Get places
      final getReq = Request('GET', Uri.parse('http://localhost/api/v1/saved-places?user_id=usr_tst_01'));
      final getRes = await handler(getReq);
      expect(getRes.statusCode, equals(200));
      final getBody = jsonDecode(await getRes.readAsString()) as Map<String, dynamic>;
      final places = getBody['data'] as List<dynamic>;
      expect(places.length, greaterThanOrEqualTo(2));

      // 2. Add new place
      final postPayload = {
        'user_id': 'usr_tst_01',
        'label': 'Grandma\'s House',
        'address': '5 Glover Rd, Ikoyi, Lagos',
        'type': 'CUSTOM',
        'latitude': 6.4520,
        'longitude': 3.4400,
        'additional_instructions': 'Ring bell at blue gate',
      };
      final postReq = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/saved-places'),
        body: jsonEncode(postPayload),
        headers: {'content-type': 'application/json'},
      );
      final postRes = await handler(postReq);
      expect(postRes.statusCode, equals(200));
      final postBody = jsonDecode(await postRes.readAsString()) as Map<String, dynamic>;
      final postData = postBody['data'] as Map<String, dynamic>;
      final newPlaceId = postData['id'] as String;

      // 3. Delete Home (which is used in active plan) without force -> Expect 409 Conflict
      final homePlace = places.firstWhere((p) => (p as Map<String, dynamic>)['is_used_in_active_plan'] == true) as Map<String, dynamic>;
      final conflictDelReq = Request('DELETE', Uri.parse('http://localhost/api/v1/saved-places/${homePlace['id']}?user_id=usr_tst_01'));
      final conflictDelRes = await handler(conflictDelReq);
      expect(conflictDelRes.statusCode, equals(409));

      // 4. Delete the newly created custom place (not used in plan) -> Expect 200 OK
      final okDelReq = Request('DELETE', Uri.parse('http://localhost/api/v1/saved-places/$newPlaceId?user_id=usr_tst_01'));
      final okDelRes = await handler(okDelReq);
      expect(okDelRes.statusCode, equals(200));
    });
  });

  group('Safety & Support API Tests (Master Spec §D1-D5)', () {
    test('Safety endpoints manage trusted contacts and incident reports', () async {
      // 1. Get contacts
      final getReq = Request('GET', Uri.parse('http://localhost/api/v1/safety/trusted-contacts?user_id=usr_tst_01'));
      final getRes = await handler(getReq);
      expect(getRes.statusCode, equals(200));

      // 2. Add contact
      final postPayload = {
        'user_id': 'usr_tst_01',
        'name': 'Amina Bello',
        'phone_number': '+234 809 112 2334',
        'relationship': 'Colleague',
        'auto_share_rides': true,
      };
      final postReq = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/safety/trusted-contacts'),
        body: jsonEncode(postPayload),
        headers: {'content-type': 'application/json'},
      );
      final postRes = await handler(postReq);
      expect(postRes.statusCode, equals(200));
      final postBody = jsonDecode(await postRes.readAsString()) as Map<String, dynamic>;
      final postData = postBody['data'] as Map<String, dynamic>;
      final contactId = postData['id'] as String;

      // 3. Delete contact
      final delReq = Request('DELETE', Uri.parse('http://localhost/api/v1/safety/trusted-contacts/$contactId?user_id=usr_tst_01'));
      final delRes = await handler(delReq);
      expect(delRes.statusCode, equals(200));

      // 4. Report safety incident
      final reportPayload = {
        'user_id': 'usr_tst_01',
        'category': 'Emergency Battery Check',
        'description': 'Driver vehicle reporting low battery in traffic on Lekki-Ikoyi Link Bridge.',
      };
      final reportReq = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/safety/report-incident'),
        body: jsonEncode(reportPayload),
        headers: {'content-type': 'application/json'},
      );
      final reportRes = await handler(reportReq);
      expect(reportRes.statusCode, equals(200));
    });

    test('Support endpoints return FAQs, creates ticket and handles customer replies', () async {
      // 1. GET FAQs
      final faqReq = Request('GET', Uri.parse('http://localhost/api/v1/support/faqs?category=School%20Run'));
      final faqRes = await handler(faqReq);
      expect(faqRes.statusCode, equals(200));
      final faqBody = jsonDecode(await faqRes.readAsString()) as Map<String, dynamic>;
      expect(faqBody['data'], isNotEmpty);

      // 2. POST create support ticket
      final createPayload = {
        'user_id': 'usr_tst_01',
        'service_category': 'parcel',
        'issue_type': 'Delayed Delivery',
        'subject': 'Package pending pickup for over 25 minutes',
        'description': 'Driver has not moved towards the Victoria Island pickup point.',
        'related_entity_id': 'del_998822',
      };
      final createReq = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/support/tickets'),
        body: jsonEncode(createPayload),
        headers: {'content-type': 'application/json'},
      );
      final createRes = await handler(createReq);
      expect(createRes.statusCode, equals(200));
      final createBody = jsonDecode(await createRes.readAsString()) as Map<String, dynamic>;
      final createData = createBody['data'] as Map<String, dynamic>;
      final ticketId = createData['id'] as String;
      expect(createData['status'], equals('SUBMITTED'));

      // 3. POST reply to ticket
      final replyPayload = {
        'user_id': 'usr_tst_01',
        'message': 'Update: The sender confirms the rider just arrived at the front desk.',
      };
      final replyReq = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/support/tickets/$ticketId/reply'),
        body: jsonEncode(replyPayload),
        headers: {'content-type': 'application/json'},
      );
      final replyRes = await handler(replyReq);
      expect(replyRes.statusCode, equals(200));
      final replyBody = jsonDecode(await replyRes.readAsString()) as Map<String, dynamic>;
      final replyData = replyBody['data'] as Map<String, dynamic>;
      final ticketData = replyData['ticket'] as Map<String, dynamic>;
      final messages = ticketData['messages'] as List<dynamic>;
      expect(messages.length, greaterThanOrEqualTo(2));
      final lastMsg = messages.last as Map<String, dynamic>;
      expect(lastMsg['message'], contains('sender confirms'));
    });
  });
}
