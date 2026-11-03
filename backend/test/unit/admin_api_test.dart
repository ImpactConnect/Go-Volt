import 'dart:convert';
import 'package:backend/src/routes/admin_route.dart';
import 'package:backend/src/server.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shelf/shelf.dart';

void main() {
  late Handler handler;

  setUp(() {
    resetAdminStoreForTest();
    handler = createServerHandler();
  });

  group('Admin REST Gateway — System Overview (§5.1)', () {
    test('GET /api/v1/admin/overview returns aggregated ecosystem KPIs', () async {
      final req = Request('GET', Uri.parse('http://localhost/api/v1/admin/overview'));
      final res = await handler(req);

      expect(res.statusCode, equals(200));
      final body = jsonDecode(await res.readAsString()) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;

      expect(data['active_distress_alerts'], equals(1));
      expect(data['total_swap_stations'], equals(4));
      expect(data['total_charged_packs'], greaterThan(40));
      expect(data['total_quarantined_packs'], equals(2));
      expect(data['pending_kyc_reviews'], equals(2));
      expect(data['active_errands'], equals(1));
      expect(data['active_school_runs'], equals(1));
      expect(data['system_status'], equals('CRITICAL_ALERT'));
    });
  });

  group('Admin REST Gateway — Safety SOS Rapid Dispatch (§5.3)', () {
    test('GET /api/v1/admin/sos/alerts searches and filters by status', () async {
      // List all
      final allReq = Request('GET', Uri.parse('http://localhost/api/v1/admin/sos/alerts'));
      final allRes = await handler(allReq);
      expect(allRes.statusCode, equals(200));
      final allBody = jsonDecode(await allRes.readAsString()) as Map<String, dynamic>;
      final allList = allBody['data'] as List;
      expect(allList.length, equals(3));

      // Filter by status
      final filterReq = Request(
        'GET',
        Uri.parse('http://localhost/api/v1/admin/sos/alerts?status=ACTIVE_DISTRESS'),
      );
      final filterRes = await handler(filterReq);
      final filterBody = jsonDecode(await filterRes.readAsString()) as Map<String, dynamic>;
      final filterList = filterBody['data'] as List;
      expect(filterList.length, equals(1));
      expect((filterList.first as Map)['victim_name'], equals('Khadijah Cole'));

      // Search by victim name
      final searchReq = Request(
        'GET',
        Uri.parse('http://localhost/api/v1/admin/sos/alerts?search=Omotayo'),
      );
      final searchRes = await handler(searchReq);
      final searchBody = jsonDecode(await searchRes.readAsString()) as Map<String, dynamic>;
      final searchList = searchBody['data'] as List;
      expect(searchList.length, equals(1));
      expect((searchList.first as Map)['incident_ref'], equals('SOS-2026-0039'));
    });

    test('POST /api/v1/admin/sos/alerts/<id>/dispatch-agency contacts emergency center', () async {
      final payload = {
        'agency': 'Lagos State 112 / 767 Emergency Center',
        'officerName': 'Officer Danjuma',
        'notes': 'Dispatched rapid medical response to Victoria Island pin',
      };
      final req = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/admin/sos/alerts/SOS-001/dispatch-agency'),
        body: jsonEncode(payload),
        headers: {'content-type': 'application/json'},
      );
      final res = await handler(req);
      expect(res.statusCode, equals(200));

      final body = jsonDecode(await res.readAsString()) as Map<String, dynamic>;
      final alert = body['data'] as Map<String, dynamic>;
      expect(alert['status'], equals('DISPATCHED_AUTHORITIES'));
      expect(alert['emergency_services_contacted'],
          contains('Lagos State 112 / 767 Emergency Center'));
      expect(alert['safety_officer_name'], equals('Officer Danjuma'));
      expect((alert['incident_notes'] as List).length, greaterThanOrEqualTo(2));
    });

    test('POST /api/v1/admin/sos/alerts/<id>/dispatch-patrol deploys Go-Volts EV unit', () async {
      final payload = {
        'patrolUnitCode': 'UNIT-ALPHA-EV',
        'officerName': 'Dispatcher Tunde',
      };
      final req = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/admin/sos/alerts/SOS-001/dispatch-patrol'),
        body: jsonEncode(payload),
        headers: {'content-type': 'application/json'},
      );
      final res = await handler(req);
      expect(res.statusCode, equals(200));

      final body = jsonDecode(await res.readAsString()) as Map<String, dynamic>;
      final alert = body['data'] as Map<String, dynamic>;
      expect(alert['status'], equals('PATROL_EN_ROUTE'));
      expect(
        (alert['incident_notes'] as List)
            .cast<Map<String, dynamic>>()
            .any((n) => (n['note'] as String).contains('UNIT-ALPHA-EV')),
        isTrue,
      );
    });

    test('POST /api/v1/admin/sos/alerts/<id>/resolve closes distress alarm', () async {
      final payload = {
        'isFalseAlarm': false,
        'resolutionSummary': 'Passenger safely escorted; false alarm resolved',
        'officerName': 'Officer Danjuma',
      };
      final req = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/admin/sos/alerts/SOS-001/resolve'),
        body: jsonEncode(payload),
        headers: {'content-type': 'application/json'},
      );
      final res = await handler(req);
      expect(res.statusCode, equals(200));

      final body = jsonDecode(await res.readAsString()) as Map<String, dynamic>;
      final alert = body['data'] as Map<String, dynamic>;
      expect(alert['status'], equals('RESOLVED_SAFE'));
      expect(alert['resolved_at'], isNotNull);
      expect(alert['resolution_summary'], contains('Passenger safely escorted'));
    });
  });

  group('Admin REST Gateway — EV Battery Swap Station Telematics (§5.4)', () {
    test('GET /api/v1/admin/battery-swap/stations returns swap hubs and cabinet bays', () async {
      final req = Request('GET', Uri.parse('http://localhost/api/v1/admin/battery-swap/stations'));
      final res = await handler(req);
      expect(res.statusCode, equals(200));

      final body = jsonDecode(await res.readAsString()) as Map<String, dynamic>;
      final stations = body['data'] as List;
      expect(stations.length, equals(4));

      // Get station 2
      final stn2Req = Request(
        'GET',
        Uri.parse('http://localhost/api/v1/admin/battery-swap/stations/STN-02'),
      );
      final stn2Res = await handler(stn2Req);
      expect(stn2Res.statusCode, equals(200));
      final stn2Body = jsonDecode(await stn2Res.readAsString()) as Map<String, dynamic>;
      final stn2 = stn2Body['data'] as Map<String, dynamic>;
      expect(stn2['name'], contains('Lekki Phase 1'));
      expect((stn2['bays'] as List).length, equals(24));
    });

    test('POST /api/v1/admin/battery-swap/stations/<id>/bays/<bayNumber>/quarantine and release',
        () async {
      // Quarantine Bay #01 at STN-02
      final quarantinePayload = {
        'reason': 'Thermal runaway warning (>44°C cell temperature)',
        'officerName': 'Fleet Specialist Aliyu',
      };
      final qReq = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/admin/battery-swap/stations/STN-02/bays/1/quarantine'),
        body: jsonEncode(quarantinePayload),
        headers: {'content-type': 'application/json'},
      );
      final qRes = await handler(qReq);
      expect(qRes.statusCode, equals(200));

      final qBody = jsonDecode(await qRes.readAsString()) as Map<String, dynamic>;
      final qStation = qBody['data'] as Map<String, dynamic>;
      final bay1 = (qStation['bays'] as List)
          .cast<Map<String, dynamic>>()
          .firstWhere((b) => b['bay_number'] == 1);
      expect(bay1['is_quarantined'], isTrue);
      expect(bay1['is_charging'], isFalse);
      expect(bay1['quarantine_reason'], contains('Thermal runaway warning'));

      // Release Bay #01
      final releasePayload = {'officerName': 'Fleet Specialist Aliyu'};
      final rReq = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/admin/battery-swap/stations/STN-02/bays/1/release'),
        body: jsonEncode(releasePayload),
        headers: {'content-type': 'application/json'},
      );
      final rRes = await handler(rReq);
      expect(rRes.statusCode, equals(200));

      final rBody = jsonDecode(await rRes.readAsString()) as Map<String, dynamic>;
      final rStation = rBody['data'] as Map<String, dynamic>;
      final bay1After = (rStation['bays'] as List)
          .cast<Map<String, dynamic>>()
          .firstWhere((b) => b['bay_number'] == 1);
      expect(bay1After['is_quarantined'], isFalse);
      expect(bay1After['is_charging'], isTrue);
    });

    test('POST /api/v1/admin/battery-swap/stations/<id>/bays/<bayNumber>/unlock triggers solenoid',
        () async {
      final unlockPayload = {'officerName': 'Fleet Specialist Aliyu'};
      final req = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/admin/battery-swap/stations/STN-01/bays/3/unlock'),
        body: jsonEncode(unlockPayload),
        headers: {'content-type': 'application/json'},
      );
      final res = await handler(req);
      expect(res.statusCode, equals(200));

      final body = jsonDecode(await res.readAsString()) as Map<String, dynamic>;
      final station = body['data'] as Map<String, dynamic>;
      final bay3 = (station['bays'] as List)
          .cast<Map<String, dynamic>>()
          .firstWhere((b) => b['bay_number'] == 3);
      expect(bay3['is_locked'], isFalse);
    });

    test('POST /api/v1/admin/battery-swap/stations/<id>/maintenance toggles station status',
        () async {
      final req = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/admin/battery-swap/stations/STN-03/maintenance'),
        body: jsonEncode({'reason': 'Cabinet transformer servicing', 'officerName': 'Fleet Aliyu'}),
        headers: {'content-type': 'application/json'},
      );
      final res = await handler(req);
      expect(res.statusCode, equals(200));

      final body = jsonDecode(await res.readAsString()) as Map<String, dynamic>;
      final station = body['data'] as Map<String, dynamic>;
      expect(station['status'], equals('MAINTENANCE'));
    });
  });

  group('Admin REST Gateway — Market Errand Supervision & Maker-Checker (§5.2 & v1.6)', () {
    test('POST /api/v1/admin/errands/<id>/reassign switches assigned shopper', () async {
      final payload = {
        'riderId': 'RIDER-004',
        'riderName': 'Zainab Danjuma',
        'reason': 'Faster market transit standby EV',
      };
      final req = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/admin/errands/ERRAND-001/reassign'),
        body: jsonEncode(payload),
        headers: {'content-type': 'application/json'},
      );
      final res = await handler(req);
      expect(res.statusCode, equals(200));

      final body = jsonDecode(await res.readAsString()) as Map<String, dynamic>;
      final errand = body['data'] as Map<String, dynamic>;
      expect(errand['assigned_rider_name'], equals('Zainab Danjuma'));
    });

    test('POST /api/v1/admin/errands/<id>/reconciliation/approve enforces Dual Maker-Checker',
        () async {
      // Delta > ₦10,000 (Budget: ₦15,000, Actual: ₦27,000 => Delta ₦12,000 = 1,200,000 kobo)
      final largeDeltaPayload = {
        'actualSpentKobo': 2700000,
        'officerName': 'Ops Agent Tunde',
        'officerRole': 'ops_agent', // Not finance or super_admin
      };
      final rejectedReq = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/admin/errands/ERRAND-001/reconciliation/approve'),
        body: jsonEncode(largeDeltaPayload),
        headers: {'content-type': 'application/json'},
      );
      final rejectedRes = await handler(rejectedReq);
      expect(rejectedRes.statusCode, equals(403));
      final rejectedBody = jsonDecode(await rejectedRes.readAsString()) as Map<String, dynamic>;
      expect(
        (rejectedBody['meta'] as Map<String, dynamic>)['message'],
        contains('Dual Maker-Checker requires Finance Officer or Super Admin'),
      );

      // Same request approved by Finance Officer
      final approvedPayload = {
        'actualSpentKobo': 2700000,
        'officerName': 'Finance Lead Folake',
        'officerRole': 'finance',
      };
      final approvedReq = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/admin/errands/ERRAND-001/reconciliation/approve'),
        body: jsonEncode(approvedPayload),
        headers: {'content-type': 'application/json'},
      );
      final approvedRes = await handler(approvedReq);
      expect(approvedRes.statusCode, equals(200));
      final approvedBody = jsonDecode(await approvedRes.readAsString()) as Map<String, dynamic>;
      final errand = approvedBody['data'] as Map<String, dynamic>;
      expect(errand['reconciliation_status'], equals('APPROVED'));
      expect(errand['reconciliation_approved_by'], equals('Finance Lead Folake'));
    });
  });

  group('Admin REST Gateway — Scheduled Commute & School-Run Desk (§5.2)', () {
    test('POST /api/v1/admin/scheduled/handover/verify-otp verifies 6-digit OTP', () async {
      // Wrong OTP
      final wrongReq = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/admin/scheduled/handover/verify-otp'),
        body: jsonEncode({'tripId': 'TRIP-SCH-01', 'otpCode': '000000'}),
        headers: {'content-type': 'application/json'},
      );
      final wrongRes = await handler(wrongReq);
      expect(wrongRes.statusCode, equals(400));

      // Correct OTP
      final correctReq = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/admin/scheduled/handover/verify-otp'),
        body: jsonEncode({
          'tripId': 'TRIP-SCH-01',
          'otpCode': '482910',
          'officerName': 'Chaperone Desk',
        }),
        headers: {'content-type': 'application/json'},
      );
      final correctRes = await handler(correctReq);
      expect(correctRes.statusCode, equals(200));

      final body = jsonDecode(await correctRes.readAsString()) as Map<String, dynamic>;
      final trip = body['data'] as Map<String, dynamic>;
      expect(trip['is_handover_verified'], isTrue);
      expect(trip['status'], equals('STUDENT_HANDOVER_CONFIRMED'));
    });

    test('POST /api/v1/admin/scheduled/handover/emergency-bypass logs bypass reason', () async {
      final bypassPayload = {
        'tripId': 'TRIP-SCH-01',
        'bypassReason': 'Guardian phone battery flat; physical national ID verified by chaperone',
        'officerName': 'Supervisor Emeka',
      };
      final req = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/admin/scheduled/handover/emergency-bypass'),
        body: jsonEncode(bypassPayload),
        headers: {'content-type': 'application/json'},
      );
      final res = await handler(req);
      expect(res.statusCode, equals(200));

      final body = jsonDecode(await res.readAsString()) as Map<String, dynamic>;
      final trip = body['data'] as Map<String, dynamic>;
      expect(trip['status'], equals('BYPASS_CONFIRMED'));
      expect(trip['bypass_reason'], contains('Guardian phone battery flat'));
    });

    test('POST /api/v1/admin/scheduled/exceptions registers school calendar holiday', () async {
      final excPayload = {
        'schoolName': 'Corona School Victoria Island',
        'schoolId': 'SCH-01',
        'exceptionDate': '2026-11-20',
        'reason': 'Inter-House Sports Day (Early closure)',
        'notifyParents': true,
        'notifyDrivers': true,
        'officerName': 'Admin Amina',
      };
      final req = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/admin/scheduled/exceptions'),
        body: jsonEncode(excPayload),
        headers: {'content-type': 'application/json'},
      );
      final res = await handler(req);
      expect(res.statusCode, equals(200));

      final body = jsonDecode(await res.readAsString()) as Map<String, dynamic>;
      final exc = body['data'] as Map<String, dynamic>;
      expect(exc['school_name'], equals('Corona School Victoria Island'));
      expect(exc['reason'], contains('Inter-House Sports'));
    });
  });

  group('Admin REST Gateway — KYC Verification & FAQ CMS (§A4 & CMS)', () {
    test('POST /api/v1/admin/kyc/<userId>/review approves customer verification', () async {
      final reviewPayload = {
        'decision': 'APPROVED',
        'reviewerName': 'Compliance Lead Babatunde',
      };
      final req = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/admin/kyc/usr_kyc_01/review'),
        body: jsonEncode(reviewPayload),
        headers: {'content-type': 'application/json'},
      );
      final res = await handler(req);
      expect(res.statusCode, equals(200));

      final body = jsonDecode(await res.readAsString()) as Map<String, dynamic>;
      final kyc = body['data'] as Map<String, dynamic>;
      expect(kyc['status'], equals('APPROVED'));
      expect(kyc['reviewed_by'], equals('Compliance Lead Babatunde'));
      expect(kyc['verified_at'], isNotNull);
    });

    test('FAQ CMS: GET, POST, and DELETE /api/v1/admin/faq', () async {
      // Create new FAQ
      final createPayload = {
        'category': 'Fleet',
        'question': 'What is the top speed of a Roam Commuter EV?',
        'answer': 'The Roam Commuter has an electronically governed top speed of 80 km/h.',
      };
      final createReq = Request(
        'POST',
        Uri.parse('http://localhost/api/v1/admin/faq'),
        body: jsonEncode(createPayload),
        headers: {'content-type': 'application/json'},
      );
      final createRes = await handler(createReq);
      expect(createRes.statusCode, equals(200));
      final createBody = jsonDecode(await createRes.readAsString()) as Map<String, dynamic>;
      final newFaq = createBody['data'] as Map<String, dynamic>;
      final faqId = newFaq['id'] as String;

      // Delete FAQ
      final delReq = Request('DELETE', Uri.parse('http://localhost/api/v1/admin/faq/$faqId'));
      final delRes = await handler(delReq);
      expect(delRes.statusCode, equals(200));
    });
  });
}
