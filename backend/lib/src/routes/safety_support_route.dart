import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

// In-memory stores for Safety and Support
final Map<String, List<Map<String, dynamic>>> _trustedContactsStore = {};
final Map<String, List<Map<String, dynamic>>> _safetyReportsStore = {};
final Map<String, List<Map<String, dynamic>>> _supportTicketsStore = {};

void resetSafetySupportStoreForTest() {
  _trustedContactsStore.clear();
  _safetyReportsStore.clear();
  _supportTicketsStore.clear();
}

List<Map<String, dynamic>> _getOrCreateTrustedContacts(String userId) {
  return _trustedContactsStore.putIfAbsent(userId, () {
    return [
      {
        'id': 'tc_01',
        'name': 'Sarah Okafor',
        'phone_number': '+234 802 334 5566',
        'relationship': 'Spouse',
        'auto_share_rides': true,
        'user_id': userId,
        'created_at': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      },
      {
        'id': 'tc_02',
        'name': 'Chinedu Okafor',
        'phone_number': '+234 803 778 9900',
        'relationship': 'Brother',
        'auto_share_rides': false,
        'user_id': userId,
        'created_at': DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
      },
    ];
  });
}

List<Map<String, dynamic>> _getOrCreateSupportTickets(String userId) {
  return _supportTicketsStore.putIfAbsent(userId, () {
    return [
      {
        'id': 'tkt_001',
        'ticket_number': 'TKT-82910',
        'service_category': 'scheduled',
        'issue_type': 'School Run Route Modification',
        'subject': 'Request to adjust morning pickup window by 10 minutes',
        'description': 'Kindly adjust morning pickup from 07:15 AM to 07:25 AM due to school assembly timing changes.',
        'related_entity_id': 'plan_sch_01',
        'status': 'IN_PROGRESS',
        'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
        'updated_at': DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
        'user_id': userId,
        'resolution_notes': null,
        'messages': [
          {
            'id': 'msg_01',
            'ticket_id': 'tkt_001',
            'sender_id': userId,
            'sender_name': 'Customer',
            'sender_role': 'customer',
            'message': 'Kindly adjust morning pickup from 07:15 AM to 07:25 AM due to school assembly timing changes.',
            'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
          },
          {
            'id': 'msg_02',
            'ticket_id': 'tkt_001',
            'sender_id': 'agent_01',
            'sender_name': 'Go-Volts Support Desk',
            'sender_role': 'agent',
            'message': 'Hello! We have flagged this with fleet dispatch in Victoria Island. The route manager is verifying driver availability.',
            'created_at': DateTime.now().subtract(const Duration(hours: 4)).toIso8601String(),
          },
        ],
      },
    ];
  });
}

final List<Map<String, dynamic>> _systemFaqs = [
  {
    'id': 'faq_01',
    'category': 'Rides',
    'question': 'How are Go-Volts EV rides different from conventional petrol hailing?',
    'answer': 'Go-Volts operates a 100% electric, zero-emission fleet powered by solar swap stations across Lagos. You produce zero exhaust fumes and avoid ~120g CO₂ per kilometer.',
    'helpful_count': 142,
  },
  {
    'id': 'faq_02',
    'category': 'Delivery',
    'question': 'What are the parcel size and weight restrictions?',
    'answer': 'Our electric courier bikes safely transport parcels up to 25kg and dimensions within 50cm x 50cm x 50cm. Fragile electronics and documents receive dedicated secure padding.',
    'helpful_count': 98,
  },
  {
    'id': 'faq_03',
    'category': 'Market Errand',
    'question': 'How does pricing work for "Buy Items from a Shop"?',
    'answer': 'You pay the verified market shelf price for items plus a flat service fee and distance delivery fee. Any price difference during shopping is updated in real time before checkout.',
    'helpful_count': 115,
  },
  {
    'id': 'faq_04',
    'category': 'School Run',
    'question': 'How does school-run custody transfer and child safety work?',
    'answer': 'All School-Run captains undergo LASRRA, NIN, and criminal background vetting. Custody transfer requires a single-use 6-digit OTP code before releasing a child at school or home.',
    'helpful_count': 230,
  },
  {
    'id': 'faq_05',
    'category': 'Wallet',
    'question': 'How do I top up my wallet with instant settlement?',
    'answer': 'You can top up using any Nigerian debit card via Paystack or transfer to your dedicated Providus virtual NUBAN account. Funds credit your ledger automatically within seconds.',
    'helpful_count': 187,
  },
  {
    'id': 'faq_06',
    'category': 'Safety',
    'question': 'What happens when I trigger emergency SOS in the app?',
    'answer': 'The app connects directly to Lagos State Emergency Services (112 / 767) while instantly alerting Go-Volts 24/7 Rapid Response fleet monitoring with your live vehicle GPS coordinates.',
    'helpful_count': 310,
  },
];

Router safetyRouter() {
  final router = Router();

  // GET /api/v1/safety/trusted-contacts
  router.get('/trusted-contacts', (Request request) async {
    final userId = request.url.queryParameters['user_id'] ?? 'usr-customer-01';
    final contacts = _getOrCreateTrustedContacts(userId);
    return Response.ok(
      jsonEncode({'data': contacts}),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /api/v1/safety/trusted-contacts
  router.post('/trusted-contacts', (Request request) async {
    final bodyStr = await request.readAsString();
    Map<String, dynamic> body = {};
    if (bodyStr.isNotEmpty) {
      body = jsonDecode(bodyStr) as Map<String, dynamic>;
    }

    final userId = body['user_id'] as String? ?? request.url.queryParameters['user_id'] ?? 'usr-customer-01';
    final contacts = _getOrCreateTrustedContacts(userId);

    final newContact = {
      'id': 'tc_${DateTime.now().millisecondsSinceEpoch}',
      'name': body['name'] as String? ?? 'Contact',
      'phone_number': body['phone_number'] as String? ?? '',
      'relationship': body['relationship'] as String? ?? 'Friend',
      'auto_share_rides': body['auto_share_rides'] as bool? ?? false,
      'user_id': userId,
      'created_at': DateTime.now().toIso8601String(),
    };

    contacts.add(newContact);

    return Response.ok(
      jsonEncode({'data': newContact}),
      headers: {'content-type': 'application/json'},
    );
  });

  // DELETE /api/v1/safety/trusted-contacts/<id>
  router.delete('/trusted-contacts/<id>', (Request request, String id) async {
    final userId = request.url.queryParameters['user_id'] ?? 'usr-customer-01';
    final contacts = _getOrCreateTrustedContacts(userId);
    final index = contacts.indexWhere((c) => c['id'] == id);

    if (index == -1) {
      return Response.notFound(
        jsonEncode({'error': {'code': 'NOT_FOUND', 'message': 'Trusted contact not found.'}}),
        headers: {'content-type': 'application/json'},
      );
    }

    final removed = contacts.removeAt(index);
    return Response.ok(
      jsonEncode({'data': {'message': 'Trusted contact removed.', 'contact': removed}}),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /api/v1/safety/report-incident
  router.post('/report-incident', (Request request) async {
    final bodyStr = await request.readAsString();
    Map<String, dynamic> body = {};
    if (bodyStr.isNotEmpty) {
      body = jsonDecode(bodyStr) as Map<String, dynamic>;
    }

    final userId = body['user_id'] as String? ?? request.url.queryParameters['user_id'] ?? 'usr-customer-01';
    final reports = _safetyReportsStore.putIfAbsent(userId, () => []);

    final report = {
      'id': 'sft_${DateTime.now().millisecondsSinceEpoch}',
      'user_id': userId,
      'category': body['category'] as String? ?? 'General Safety',
      'description': body['description'] as String? ?? '',
      'related_booking_id': body['related_booking_id'] as String?,
      'created_at': DateTime.now().toIso8601String(),
      'status': 'LOGGED',
    };
    reports.add(report);

    return Response.ok(
      jsonEncode({
        'data': {
          'message': 'Safety report received. Fleet security has been notified.',
          'report': report,
        }
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  return router;
}

Router supportRouter() {
  final router = Router();

  // GET /api/v1/support/faqs
  router.get('/faqs', (Request request) async {
    final category = request.url.queryParameters['category'];
    var faqs = _systemFaqs;
    if (category != null && category.isNotEmpty && category.toLowerCase() != 'all') {
      faqs = faqs.where((f) => f['category'].toString().toLowerCase() == category.toLowerCase()).toList();
    }

    return Response.ok(
      jsonEncode({'data': faqs}),
      headers: {'content-type': 'application/json'},
    );
  });

  // GET /api/v1/support/tickets
  router.get('/tickets', (Request request) async {
    final userId = request.url.queryParameters['user_id'] ?? 'usr-customer-01';
    final tickets = _getOrCreateSupportTickets(userId);
    return Response.ok(
      jsonEncode({'data': tickets}),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /api/v1/support/tickets
  router.post('/tickets', (Request request) async {
    final bodyStr = await request.readAsString();
    Map<String, dynamic> body = {};
    if (bodyStr.isNotEmpty) {
      body = jsonDecode(bodyStr) as Map<String, dynamic>;
    }

    final userId = body['user_id'] as String? ?? request.url.queryParameters['user_id'] ?? 'usr-customer-01';
    final tickets = _getOrCreateSupportTickets(userId);

    final ticketNumber = 'TKT-${DateTime.now().millisecondsSinceEpoch % 100000}';
    final description = body['description'] as String? ?? '';
    final subject = body['subject'] as String? ?? (description.length > 40 ? '${description.substring(0, 40)}...' : description);

    final newTicket = {
      'id': 'tkt_${DateTime.now().millisecondsSinceEpoch}',
      'ticket_number': ticketNumber,
      'service_category': body['service_category'] as String? ?? 'general',
      'issue_type': body['issue_type'] as String? ?? 'General Support',
      'subject': subject,
      'description': description,
      'related_entity_id': body['related_entity_id'] as String?,
      'status': 'SUBMITTED',
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
      'user_id': userId,
      'resolution_notes': null,
      'messages': [
        {
          'id': 'msg_${DateTime.now().millisecondsSinceEpoch}',
          'ticket_id': 'tkt_${DateTime.now().millisecondsSinceEpoch}',
          'sender_id': userId,
          'sender_name': 'Customer',
          'sender_role': 'customer',
          'message': description,
          'created_at': DateTime.now().toIso8601String(),
        }
      ],
    };

    tickets.insert(0, newTicket);

    return Response.ok(
      jsonEncode({'data': newTicket}),
      headers: {'content-type': 'application/json'},
    );
  });

  // GET /api/v1/support/tickets/<id>
  router.get('/tickets/<id>', (Request request, String id) async {
    final userId = request.url.queryParameters['user_id'] ?? 'usr-customer-01';
    final tickets = _getOrCreateSupportTickets(userId);
    final ticket = tickets.firstWhere(
      (t) => t['id'] == id || t['ticket_number'] == id,
      orElse: () => {},
    );

    if (ticket.isEmpty) {
      return Response.notFound(
        jsonEncode({'error': {'code': 'NOT_FOUND', 'message': 'Support ticket not found.'}}),
        headers: {'content-type': 'application/json'},
      );
    }

    return Response.ok(
      jsonEncode({'data': ticket}),
      headers: {'content-type': 'application/json'},
    );
  });

  // POST /api/v1/support/tickets/<id>/reply
  router.post('/tickets/<id>/reply', (Request request, String id) async {
    final bodyStr = await request.readAsString();
    Map<String, dynamic> body = {};
    if (bodyStr.isNotEmpty) {
      body = jsonDecode(bodyStr) as Map<String, dynamic>;
    }

    final userId = body['user_id'] as String? ?? request.url.queryParameters['user_id'] ?? 'usr-customer-01';
    final tickets = _getOrCreateSupportTickets(userId);
    final index = tickets.indexWhere((t) => t['id'] == id || t['ticket_number'] == id);

    if (index == -1) {
      return Response.notFound(
        jsonEncode({'error': {'code': 'NOT_FOUND', 'message': 'Support ticket not found.'}}),
        headers: {'content-type': 'application/json'},
      );
    }

    final ticket = tickets[index];
    final replyMessage = {
      'id': 'msg_${DateTime.now().millisecondsSinceEpoch}',
      'ticket_id': ticket['id'],
      'sender_id': userId,
      'sender_name': body['sender_name'] as String? ?? 'Customer',
      'sender_role': 'customer',
      'message': body['message'] as String? ?? '',
      'created_at': DateTime.now().toIso8601String(),
    };

    final msgs = List<Map<String, dynamic>>.from(ticket['messages'] as List<dynamic>? ?? []);
    msgs.add(replyMessage);
    ticket['messages'] = msgs;
    ticket['updated_at'] = DateTime.now().toIso8601String();

    return Response.ok(
      jsonEncode({
        'data': {
          'message': 'Reply sent successfully.',
          'ticket': ticket,
        }
      }),
      headers: {'content-type': 'application/json'},
    );
  });

  return router;
}
