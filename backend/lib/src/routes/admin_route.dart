import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

// ============================================================================
// IN-MEMORY STORES FOR ADMIN OPERATIONS
// ============================================================================

List<Map<String, dynamic>> _sosAlerts = [];
List<Map<String, dynamic>> _batteryStations = [];
List<Map<String, dynamic>> _adminErrands = [];
List<Map<String, dynamic>> _scheduledManifest = [];
List<Map<String, dynamic>> _calendarExceptions = [];
List<Map<String, dynamic>> _kycSubmissions = [];
List<Map<String, dynamic>> _adminFaqs = [];

void resetAdminStoreForTest() {
  _initStores();
}

void _initStores() {
  final now = DateTime.now();

  // 1. SOS Distress Alerts
  _sosAlerts = [
    {
      'id': 'SOS-001',
      'incident_ref': 'SOS-2026-0041',
      'booking_ref': 'BK-2026-9912',
      'service_type': 'Passenger Ride',
      'triggered_by': 'Passenger (In-App SOS Trigger)',
      'victim_name': 'Khadijah Cole',
      'victim_phone': '+2348034567890',
      'driver_name': 'Ahmed Ibrahim',
      'driver_phone': '+2348031234567',
      'vehicle_plate': 'ABC-123XY',
      'vehicle_model': 'Spiro Commuter EV',
      'latitude': 6.4281,
      'longitude': 3.4219,
      'address': 'Adeola Odeku St near Victoria Island Police Post, Lagos',
      'speed_kmh': 36.0,
      'ev_battery_percent': 78,
      'status': 'ACTIVE_DISTRESS',
      'triggered_at': now.subtract(const Duration(minutes: 4)).toIso8601String(),
      'audio_recording_url': 'https://cdn.govolts.ng/audio/sos-0041-live.aac',
      'emergency_services_contacted': <String>[],
      'incident_notes': [
        {
          'id': 'NOTE-01',
          'author_name': 'System Monitor',
          'author_role': 'Automated Telematics',
          'note': 'Distress trigger detected from Passenger App. Audio recording stream initiated.',
          'created_at': now.subtract(const Duration(minutes: 4)).toIso8601String(),
        },
      ],
    },
    {
      'id': 'SOS-002',
      'incident_ref': 'SOS-2026-0040',
      'booking_ref': 'SCH-2026-0801',
      'service_type': 'School Run',
      'triggered_by': 'Impact Sensor (Crash Detection)',
      'victim_name': 'Zayd Cole (Minor Passenger)',
      'victim_phone': '+2348034567890 (Mother)',
      'driver_name': 'Musa Bello',
      'driver_phone': '+2348069876543',
      'vehicle_plate': 'KD-456-EF',
      'vehicle_model': 'Roam Air EV',
      'latitude': 6.4474,
      'longitude': 3.4723,
      'address': 'Admiralty Way, Lekki Phase 1, Lagos',
      'speed_kmh': 0.0,
      'ev_battery_percent': 62,
      'status': 'DISPATCHED_AUTHORITIES',
      'triggered_at': now.subtract(const Duration(minutes: 25)).toIso8601String(),
      'dispatched_at': now.subtract(const Duration(minutes: 20)).toIso8601String(),
      'safety_officer_name': 'Safety Officer Amina',
      'emergency_services_contacted': [
        'Lagos State 112 / 767 Emergency Center',
        'Federal Road Safety Corps (FRSC Lagos Command)',
      ],
      'incident_notes': [
        {
          'id': 'NOTE-02',
          'author_name': 'Safety Officer Amina',
          'author_role': 'Senior Safety Investigator',
          'note': 'Escalated to Lagos 112 & FRSC Sector Command. Ambulance deployed to Lekki pin.',
          'created_at': now.subtract(const Duration(minutes: 20)).toIso8601String(),
        },
      ],
    },
    {
      'id': 'SOS-003',
      'incident_ref': 'SOS-2026-0039',
      'booking_ref': 'ERR-2026-0019',
      'service_type': 'Market Errand',
      'triggered_by': 'Route Deviation Geofence Alarm',
      'victim_name': 'Omotayo Kehinde',
      'victim_phone': '+2348034567890',
      'driver_name': 'Fatima Abubakar',
      'driver_phone': '+2348023456789',
      'vehicle_plate': 'KN-789-GH',
      'vehicle_model': 'Ampersand Cargo EV',
      'latitude': 6.6018,
      'longitude': 3.3515,
      'address': 'Allen Avenue, Ikeja, Lagos',
      'speed_kmh': 15.0,
      'ev_battery_percent': 84,
      'status': 'PATROL_EN_ROUTE',
      'triggered_at': now.subtract(const Duration(minutes: 40)).toIso8601String(),
      'dispatched_at': now.subtract(const Duration(minutes: 32)).toIso8601String(),
      'safety_officer_name': 'Ops Agent Tunde',
      'emergency_services_contacted': ['Go-Volts Rapid Patrol Unit 3 (EV Moped)'],
      'incident_notes': [
        {
          'id': 'NOTE-03',
          'author_name': 'Ops Agent Tunde',
          'author_role': 'Live Dispatcher',
          'note': 'Go-Volts Mobile Patrol 3 en route. ETA 3 minutes to courier location.',
          'created_at': now.subtract(const Duration(minutes: 32)).toIso8601String(),
        },
      ],
    },
  ];

  // 2. Battery Swap Stations (4 across Lagos)
  List<Map<String, dynamic>> generateBays(int charged, int charging, int quarantined, {String? reason}) {
    final bays = <Map<String, dynamic>>[];
    var currentBay = 1;
    for (int i = 0; i < charged; i++) {
      bays.add({
        'bay_number': currentBay,
        'battery_serial': 'BAT-EV-${currentBay.toString().padLeft(4, '0')}',
        'soc_percent': 92 + (i % 8),
        'soh_health_percent': 96,
        'temperature_celsius': 27.5,
        'is_charging': false,
        'is_quarantined': false,
        'quarantine_reason': null,
        'is_locked': true,
      });
      currentBay++;
    }
    for (int i = 0; i < charging; i++) {
      bays.add({
        'bay_number': currentBay,
        'battery_serial': 'BAT-EV-${currentBay.toString().padLeft(4, '0')}',
        'soc_percent': 35 + (i * 4),
        'soh_health_percent': 94,
        'temperature_celsius': 32.0,
        'is_charging': true,
        'is_quarantined': false,
        'quarantine_reason': null,
        'is_locked': true,
      });
      currentBay++;
    }
    for (int i = 0; i < quarantined; i++) {
      bays.add({
        'bay_number': currentBay,
        'battery_serial': 'BAT-EV-${currentBay.toString().padLeft(4, '0')}',
        'soc_percent': 48,
        'soh_health_percent': 68,
        'temperature_celsius': 44.5,
        'is_charging': false,
        'is_quarantined': true,
        'quarantine_reason': reason ?? 'Thermal Runaway Warning (>44°C cell temperature)',
        'is_locked': true,
      });
      currentBay++;
    }
    while (currentBay <= 24) {
      bays.add({
        'bay_number': currentBay,
        'battery_serial': 'BAT-EV-${currentBay.toString().padLeft(4, '0')}',
        'soc_percent': 90,
        'soh_health_percent': 95,
        'temperature_celsius': 28.0,
        'is_charging': false,
        'is_quarantined': false,
        'quarantine_reason': null,
        'is_locked': true,
      });
      currentBay++;
    }
    return bays;
  }

  _batteryStations = [
    {
      'id': 'STN-01',
      'name': 'Victoria Island Central Swap Hub',
      'address': 'Ahmadu Bello Way / Adeola Odeku, VI, Lagos',
      'latitude': 6.4281,
      'longitude': 3.4219,
      'total_cabinet_bays': 24,
      'power_source': 'Solar PV + Grid Active',
      'temperature_celsius': 28.2,
      'daily_swap_count': 184,
      'status': 'OPERATIONAL',
      'bays': generateBays(16, 7, 1, reason: 'Cell impedance mismatch flagged by BMS'),
    },
    {
      'id': 'STN-02',
      'name': 'Lekki Phase 1 Solar Swap Station',
      'address': 'Admiralty Way, Lekki Phase 1, Lagos',
      'latitude': 6.4474,
      'longitude': 3.4723,
      'total_cabinet_bays': 24,
      'power_source': '100% Rooftop Solar + BESS',
      'temperature_celsius': 27.8,
      'daily_swap_count': 122,
      'status': 'OPERATIONAL',
      'bays': generateBays(18, 6, 0),
    },
    {
      'id': 'STN-03',
      'name': 'Ikeja Commercial Fulfilment Hub',
      'address': 'Allen Avenue, Ikeja, Lagos',
      'latitude': 6.6018,
      'longitude': 3.3515,
      'total_cabinet_bays': 24,
      'power_source': 'Grid Active + Diesel Standby',
      'temperature_celsius': 31.0,
      'daily_swap_count': 210,
      'status': 'OPERATIONAL',
      'bays': generateBays(14, 9, 1, reason: 'Thermal runaway threshold warning (>44°C cell temperature)'),
    },
    {
      'id': 'STN-04',
      'name': 'Yaba Tech Corridor Hub',
      'address': 'Herbert Macaulay Way, Yaba, Lagos',
      'latitude': 6.5095,
      'longitude': 3.3711,
      'total_cabinet_bays': 24,
      'power_source': 'Solar PV + Grid Active',
      'temperature_celsius': 33.5,
      'daily_swap_count': 95,
      'status': 'HIGH_DEMAND',
      'bays': generateBays(6, 18, 0),
    },
  ];

  // 3. Market Errands
  _adminErrands = [
    {
      'id': 'ERRAND-001',
      'reference_number': 'ERR-2026-0019',
      'type': 'buyItems',
      'status': 'inProgress',
      'customer_id': 'usr_001',
      'customer_name': 'Omotayo Kehinde',
      'customer_phone': '+2348034567890',
      'shop_name': 'Kakuri Main Market',
      'estimated_budget_kobo': 1500000, // ₦15,000
      'actual_spent_kobo': 1680000,    // ₦16,800 (₦1,800 delta)
      'reconciliation_status': 'PENDING',
      'dispute_flag': true,
      'dispute_reason': 'Item brand substitution: Royal Golden Penny 5kg swapped with Mama Gold 5kg',
      'assigned_rider_id': 'RIDER-001',
      'assigned_rider_name': 'Ahmed Ibrahim',
    },
    {
      'id': 'ERRAND-002',
      'reference_number': 'ERR-2026-0020',
      'type': 'pickupPackage',
      'status': 'assigned',
      'customer_id': 'usr_002',
      'customer_name': 'Babatunde Balogun',
      'customer_phone': '+2348021112233',
      'shop_name': 'Jumia Hub Victoria Island',
      'estimated_budget_kobo': 0,
      'actual_spent_kobo': 0,
      'reconciliation_status': 'NOT_REQUIRED',
      'dispute_flag': false,
      'assigned_rider_id': 'RIDER-002',
      'assigned_rider_name': 'Musa Bello',
    },
  ];

  // 4. Scheduled Commute & School-Run Manifest
  _scheduledManifest = [
    {
      'trip_id': 'TRIP-SCH-01',
      'plan_id': 'PLAN-SCH-2026-01',
      'student_id': 'STUD-01',
      'student_name': 'Zayd Cole',
      'school_name': 'Corona School Victoria Island',
      'pickup_address': 'Plot 12 Admiralty Way, Lekki',
      'dropoff_address': 'Waziri Ibrahim St, VI, Lagos',
      'scheduled_pickup_time': '07:15',
      'driver_id': 'RIDER-001',
      'driver_name': 'Ahmed Ibrahim',
      'driver_battery_soc': 94,
      'handover_otp': '482910',
      'status': 'EN_ROUTE_PICKUP',
      'is_handover_verified': false,
      'authorized_guardians': [
        {'name': 'Sarah Cole', 'relationship': 'Mother', 'phone': '+2348034567890'},
        {'name': 'Mr. Anthony Cole', 'relationship': 'Father', 'phone': '+2348021114455'},
      ],
    },
  ];

  _calendarExceptions = [
    {
      'id': 'EXC-01',
      'school_name': 'Corona School Victoria Island',
      'school_id': 'SCH-01',
      'exception_date': '2026-11-15',
      'reason': 'State Mid-Term Holiday Break',
      'notify_parents': true,
      'notify_drivers': true,
      'created_by': 'Admin Officer',
    },
  ];

  // 5. Customer KYC Submissions
  _kycSubmissions = [
    {
      'user_id': 'usr_kyc_01',
      'full_name': 'Babatunde Balogun',
      'email': 'babatunde.balogun@govolts.ng',
      'phone_number': '+2348021112233',
      'nin': '78912345678',
      'status': 'PENDING',
      'submitted_at': now.subtract(const Duration(hours: 3)).toIso8601String(),
      'document_urls': {
        'nin_slip': 'https://storage.govolts.ng/docs/babatunde/nin.jpg',
        'utility_bill': 'https://storage.govolts.ng/docs/babatunde/utility.jpg',
      },
      'tier': 'Tier 2 (Full Verification)',
    },
    {
      'user_id': 'usr_kyc_02',
      'full_name': 'Maryam Usman',
      'email': 'maryam.usman@govolts.ng',
      'phone_number': '+2348039998877',
      'nin': '12345678901',
      'status': 'PENDING',
      'submitted_at': now.subtract(const Duration(hours: 6)).toIso8601String(),
      'document_urls': {
        'voter_card': 'https://storage.govolts.ng/docs/maryam/voters.jpg',
      },
      'tier': 'Tier 1 (Basic)',
    },
  ];

  // 6. Admin FAQs CMS
  _adminFaqs = [
    {
      'id': 'faq_01',
      'category': 'Rides',
      'question': 'How are Go-Volts EV rides zero-emission?',
      'answer': 'Go-Volts operates 100% electric bikes charged via solar swap stations across Lagos.',
      'helpful_count': 142,
    },
    {
      'id': 'faq_02',
      'category': 'Battery Swap',
      'question': 'How fast is a battery pack swap?',
      'answer': 'Under 90 seconds! Riders pull into a smart cabinet, insert their empty pack, and grab a fully-charged battery.',
      'helpful_count': 88,
    },
  ];
}

// Automatically seed on module load
void _ensureInitialized() {
  if (_sosAlerts.isEmpty && _batteryStations.isEmpty) {
    _initStores();
  }
}

// ============================================================================
// RESPONSE HELPERS
// ============================================================================

Response _jsonOk(dynamic data, {Map<String, dynamic>? meta}) {
  return Response.ok(
    jsonEncode({
      'meta': meta ?? {
        'status': 'success',
        'timestamp': DateTime.now().toIso8601String(),
      },
      'data': data,
    }),
    headers: {'content-type': 'application/json'},
  );
}

Response _jsonError(int statusCode, String code, String message) {
  return Response(
    statusCode,
    body: jsonEncode({
      'meta': {
        'status': 'error',
        'code': code,
        'message': message,
        'timestamp': DateTime.now().toIso8601String(),
      },
    }),
    headers: {'content-type': 'application/json'},
  );
}

// ============================================================================
// ADMIN ROUTER
// ============================================================================

Router adminRouter() {
  _ensureInitialized();
  final router = Router();

  // --------------------------------------------------------------------------
  // 1. SYSTEM OVERVIEW PLATFORM KPIS
  // --------------------------------------------------------------------------
  router.get('/overview', (Request request) async {
    final activeDistress = _sosAlerts.where((a) => a['status'] == 'ACTIVE_DISTRESS').length;
    final totalChargedPacks = _batteryStations.fold<int>(
      0,
      (sum, s) {
        final bays = s['bays'] as List;
        return sum +
            bays.where((b) {
              final bay = b as Map<String, dynamic>;
              final soc = bay['soc_percent'] as int;
              final isQuarantined = bay['is_quarantined'] == true;
              return soc >= 90 && !isQuarantined;
            }).length;
      },
    );
    final totalQuarantinedPacks = _batteryStations.fold<int>(
      0,
      (sum, s) {
        final bays = s['bays'] as List;
        return sum +
            bays.where((b) {
              final bay = b as Map<String, dynamic>;
              return bay['is_quarantined'] == true;
            }).length;
      },
    );
    final pendingKyc = _kycSubmissions.where((k) => k['status'] == 'PENDING').length;
    final activeErrands = _adminErrands.where((e) => e['status'] == 'inProgress').length;
    final activeSchoolRuns = _scheduledManifest.where((m) => m['status'] == 'EN_ROUTE_PICKUP').length;

    return _jsonOk({
      'active_distress_alerts': activeDistress,
      'total_swap_stations': _batteryStations.length,
      'total_charged_packs': totalChargedPacks,
      'total_quarantined_packs': totalQuarantinedPacks,
      'pending_kyc_reviews': pendingKyc,
      'active_errands': activeErrands,
      'active_school_runs': activeSchoolRuns,
      'system_status': activeDistress > 0 ? 'CRITICAL_ALERT' : 'OPTIMAL',
    });
  });

  // --------------------------------------------------------------------------
  // 2. EMERGENCY SOS RAPID DISPATCH DESK (§5.3)
  // --------------------------------------------------------------------------
  router.get('/sos/alerts', (Request request) async {
    final status = request.url.queryParameters['status'];
    final q = request.url.queryParameters['search']?.toLowerCase();

    var alerts = List<Map<String, dynamic>>.from(_sosAlerts);
    if (status != null && status.isNotEmpty) {
      alerts = alerts.where((a) => a['status'] == status).toList();
    }
    if (q != null && q.isNotEmpty) {
      alerts = alerts.where((a) {
        final ref = (a['incident_ref'] as String).toLowerCase();
        final victim = (a['victim_name'] as String).toLowerCase();
        final addr = (a['address'] as String).toLowerCase();
        return ref.contains(q) || victim.contains(q) || addr.contains(q);
      }).toList();
    }
    return _jsonOk(alerts);
  });

  router.get('/sos/alerts/<id>', (Request request, String id) async {
    final alert = _sosAlerts.firstWhere((a) => a['id'] == id, orElse: () => {});
    if (alert.isEmpty) {
      return _jsonError(404, 'NOT_FOUND', 'Distress alert $id not found.');
    }
    return _jsonOk(alert);
  });

  router.post('/sos/alerts/<id>/dispatch-agency', (Request request, String id) async {
    final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    final agency = body['agency'] as String?;
    final officerName = body['officerName'] as String?;
    final notes = body['notes'] as String? ?? 'External emergency response dispatched';

    if (agency == null || officerName == null) {
      return _jsonError(400, 'BAD_REQUEST', 'Missing agency or officerName.');
    }

    final index = _sosAlerts.indexWhere((a) => a['id'] == id);
    if (index == -1) {
      return _jsonError(404, 'NOT_FOUND', 'Distress alert $id not found.');
    }

    final alert = Map<String, dynamic>.from(_sosAlerts[index]);
    final agencies = (alert['emergency_services_contacted'] as List? ?? []).cast<String>().toList();
    if (!agencies.contains(agency)) agencies.add(agency);

    final incidentNotes = (alert['incident_notes'] as List? ?? []).cast<Map<String, dynamic>>().toList();
    incidentNotes.add({
      'id': 'NOTE-${DateTime.now().millisecondsSinceEpoch}',
      'author_name': officerName,
      'author_role': 'Safety Dispatch Officer',
      'note': 'Emergency dispatch to $agency: "$notes"',
      'created_at': DateTime.now().toIso8601String(),
    });

    alert['status'] = 'DISPATCHED_AUTHORITIES';
    alert['emergency_services_contacted'] = agencies;
    alert['safety_officer_name'] = officerName;
    alert['dispatched_at'] = DateTime.now().toIso8601String();
    alert['incident_notes'] = incidentNotes;

    _sosAlerts[index] = alert;
    return _jsonOk(alert, meta: {
      'status': 'success',
      'message': 'Emergency services dispatched to $agency for incident $id.',
    });
  });

  router.post('/sos/alerts/<id>/dispatch-patrol', (Request request, String id) async {
    final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    final patrolUnitCode = body['patrolUnitCode'] as String? ?? 'UNIT-ALPHA-EV';
    final officerName = body['officerName'] as String? ?? 'Live Dispatcher';

    final index = _sosAlerts.indexWhere((a) => a['id'] == id);
    if (index == -1) {
      return _jsonError(404, 'NOT_FOUND', 'Distress alert $id not found.');
    }

    final alert = Map<String, dynamic>.from(_sosAlerts[index]);
    final incidentNotes = (alert['incident_notes'] as List? ?? []).cast<Map<String, dynamic>>().toList();
    incidentNotes.add({
      'id': 'NOTE-${DateTime.now().millisecondsSinceEpoch}',
      'author_name': officerName,
      'author_role': 'Safety Dispatch Officer',
      'note': 'Go-Volts Rapid Patrol Unit $patrolUnitCode deployed to live GPS location.',
      'created_at': DateTime.now().toIso8601String(),
    });

    alert['status'] = 'PATROL_EN_ROUTE';
    alert['safety_officer_name'] = officerName;
    alert['dispatched_at'] = DateTime.now().toIso8601String();
    alert['incident_notes'] = incidentNotes;

    _sosAlerts[index] = alert;
    return _jsonOk(alert);
  });

  router.post('/sos/alerts/<id>/notes', (Request request, String id) async {
    final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    final note = body['note'] as String?;
    final authorName = body['authorName'] as String?;
    final authorRole = body['authorRole'] as String? ?? 'Safety Investigator';

    if (note == null || authorName == null) {
      return _jsonError(400, 'BAD_REQUEST', 'Missing note or authorName.');
    }

    final index = _sosAlerts.indexWhere((a) => a['id'] == id);
    if (index == -1) {
      return _jsonError(404, 'NOT_FOUND', 'Distress alert $id not found.');
    }

    final alert = Map<String, dynamic>.from(_sosAlerts[index]);
    final incidentNotes = (alert['incident_notes'] as List? ?? []).cast<Map<String, dynamic>>().toList();
    incidentNotes.add({
      'id': 'NOTE-${DateTime.now().millisecondsSinceEpoch}',
      'author_name': authorName,
      'author_role': authorRole,
      'note': note,
      'created_at': DateTime.now().toIso8601String(),
    });

    alert['incident_notes'] = incidentNotes;
    _sosAlerts[index] = alert;
    return _jsonOk(alert);
  });

  router.post('/sos/alerts/<id>/resolve', (Request request, String id) async {
    final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    final isFalseAlarm = body['isFalseAlarm'] as bool? ?? false;
    final resolutionSummary = body['resolutionSummary'] as String? ?? 'Incident resolved';
    final officerName = body['officerName'] as String? ?? 'Safety Officer';

    final index = _sosAlerts.indexWhere((a) => a['id'] == id);
    if (index == -1) {
      return _jsonError(404, 'NOT_FOUND', 'Distress alert $id not found.');
    }

    final alert = Map<String, dynamic>.from(_sosAlerts[index]);
    final incidentNotes = (alert['incident_notes'] as List? ?? []).cast<Map<String, dynamic>>().toList();
    incidentNotes.add({
      'id': 'NOTE-${DateTime.now().millisecondsSinceEpoch}',
      'author_name': officerName,
      'author_role': 'Safety Officer',
      'note': 'Incident closed: $resolutionSummary',
      'created_at': DateTime.now().toIso8601String(),
    });

    alert['status'] = isFalseAlarm ? 'FALSE_ALARM' : 'RESOLVED_SAFE';
    alert['resolved_at'] = DateTime.now().toIso8601String();
    alert['resolution_summary'] = resolutionSummary;
    alert['safety_officer_name'] = officerName;
    alert['incident_notes'] = incidentNotes;

    _sosAlerts[index] = alert;
    return _jsonOk(alert);
  });

  // --------------------------------------------------------------------------
  // 3. EV BATTERY SWAP & TELEMATICS STATION DESK (§5.4)
  // --------------------------------------------------------------------------
  router.get('/battery-swap/stations', (Request request) async {
    final status = request.url.queryParameters['status'];
    final q = request.url.queryParameters['search']?.toLowerCase();

    var stations = List<Map<String, dynamic>>.from(_batteryStations);
    if (status != null && status.isNotEmpty) {
      stations = stations.where((s) => s['status'] == status).toList();
    }
    if (q != null && q.isNotEmpty) {
      stations = stations.where((s) {
        final name = (s['name'] as String).toLowerCase();
        final addr = (s['address'] as String).toLowerCase();
        return name.contains(q) || addr.contains(q);
      }).toList();
    }
    return _jsonOk(stations);
  });

  router.get('/battery-swap/stations/<id>', (Request request, String id) async {
    final station = _batteryStations.firstWhere((s) => s['id'] == id, orElse: () => {});
    if (station.isEmpty) {
      return _jsonError(404, 'NOT_FOUND', 'Swap station $id not found.');
    }
    return _jsonOk(station);
  });

  router.post('/battery-swap/stations/<id>/bays/<bayNumber>/quarantine',
      (Request request, String id, String bayNumberStr) async {
    final bayNumber = int.tryParse(bayNumberStr);
    if (bayNumber == null) return _jsonError(400, 'BAD_REQUEST', 'Invalid bay number.');

    final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    final reason = body['reason'] as String? ?? 'Thermal runaway threshold warning (>44°C)';
    final officerName = body['officerName'] as String? ?? 'Ops Fleet Specialist';

    final stnIndex = _batteryStations.indexWhere((s) => s['id'] == id);
    if (stnIndex == -1) return _jsonError(404, 'NOT_FOUND', 'Station $id not found.');

    final station = Map<String, dynamic>.from(_batteryStations[stnIndex]);
    final bays = (station['bays'] as List).cast<Map<String, dynamic>>().toList();

    final bayIndex = bays.indexWhere((b) => b['bay_number'] == bayNumber);
    if (bayIndex == -1) return _jsonError(404, 'NOT_FOUND', 'Bay #$bayNumber not found at $id.');

    final bay = Map<String, dynamic>.from(bays[bayIndex]);
    bay['is_quarantined'] = true;
    bay['quarantine_reason'] = reason;
    bay['is_charging'] = false;
    bay['is_locked'] = true;
    bays[bayIndex] = bay;

    station['bays'] = bays;
    _batteryStations[stnIndex] = station;

    return _jsonOk(station, meta: {
      'status': 'success',
      'message': 'Bay #$bayNumber quarantined by $officerName ($reason).',
    });
  });

  router.post('/battery-swap/stations/<id>/bays/<bayNumber>/release',
      (Request request, String id, String bayNumberStr) async {
    final bayNumber = int.tryParse(bayNumberStr);
    if (bayNumber == null) return _jsonError(400, 'BAD_REQUEST', 'Invalid bay number.');

    final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    final officerName = body['officerName'] as String? ?? 'Ops Fleet Specialist';

    final stnIndex = _batteryStations.indexWhere((s) => s['id'] == id);
    if (stnIndex == -1) return _jsonError(404, 'NOT_FOUND', 'Station $id not found.');

    final station = Map<String, dynamic>.from(_batteryStations[stnIndex]);
    final bays = (station['bays'] as List).cast<Map<String, dynamic>>().toList();

    final bayIndex = bays.indexWhere((b) => b['bay_number'] == bayNumber);
    if (bayIndex == -1) return _jsonError(404, 'NOT_FOUND', 'Bay #$bayNumber not found at $id.');

    final bay = Map<String, dynamic>.from(bays[bayIndex]);
    bay['is_quarantined'] = false;
    bay['quarantine_reason'] = null;
    bay['is_charging'] = true;
    bays[bayIndex] = bay;

    station['bays'] = bays;
    _batteryStations[stnIndex] = station;

    return _jsonOk(station, meta: {
      'status': 'success',
      'message': 'Bay #$bayNumber released from quarantine by $officerName.',
    });
  });

  router.post('/battery-swap/stations/<id>/bays/<bayNumber>/unlock',
      (Request request, String id, String bayNumberStr) async {
    final bayNumber = int.tryParse(bayNumberStr);
    if (bayNumber == null) return _jsonError(400, 'BAD_REQUEST', 'Invalid bay number.');

    final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    final officerName = body['officerName'] as String? ?? 'Ops Fleet Specialist';

    final stnIndex = _batteryStations.indexWhere((s) => s['id'] == id);
    if (stnIndex == -1) return _jsonError(404, 'NOT_FOUND', 'Station $id not found.');

    final station = Map<String, dynamic>.from(_batteryStations[stnIndex]);
    final bays = (station['bays'] as List).cast<Map<String, dynamic>>().toList();

    final bayIndex = bays.indexWhere((b) => b['bay_number'] == bayNumber);
    if (bayIndex == -1) return _jsonError(404, 'NOT_FOUND', 'Bay #$bayNumber not found at $id.');

    final bay = Map<String, dynamic>.from(bays[bayIndex]);
    bay['is_locked'] = false;
    bays[bayIndex] = bay;

    station['bays'] = bays;
    _batteryStations[stnIndex] = station;

    return _jsonOk(station, meta: {
      'status': 'success',
      'message': 'Bay #$bayNumber unlocked by $officerName.',
    });
  });

  router.post('/battery-swap/stations/<id>/maintenance', (Request request, String id) async {
    final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    final reason = body['reason'] as String? ?? 'Routine maintenance';
    final officerName = body['officerName'] as String? ?? 'Ops Fleet Specialist';

    final stnIndex = _batteryStations.indexWhere((s) => s['id'] == id);
    if (stnIndex == -1) return _jsonError(404, 'NOT_FOUND', 'Station $id not found.');

    final station = Map<String, dynamic>.from(_batteryStations[stnIndex]);
    final currentStatus = station['status'] as String;
    final newStatus = currentStatus == 'MAINTENANCE' ? 'OPERATIONAL' : 'MAINTENANCE';

    station['status'] = newStatus;
    _batteryStations[stnIndex] = station;

    return _jsonOk(station, meta: {
      'status': 'success',
      'message': 'Station $id status changed to $newStatus by $officerName ($reason).',
    });
  });

  // --------------------------------------------------------------------------
  // 4. MARKET ERRAND SHOPPING SUPERVISION HUB (§5.2 & v1.6)
  // --------------------------------------------------------------------------
  router.get('/errands', (Request request) async {
    final status = request.url.queryParameters['status'];
    final type = request.url.queryParameters['type'];
    final q = request.url.queryParameters['search']?.toLowerCase();

    var list = List<Map<String, dynamic>>.from(_adminErrands);
    if (status != null && status.isNotEmpty) {
      list = list.where((e) => e['status'] == status).toList();
    }
    if (type != null && type.isNotEmpty) {
      list = list.where((e) => e['type'] == type).toList();
    }
    if (q != null && q.isNotEmpty) {
      list = list.where((e) {
        final ref = (e['reference_number'] as String).toLowerCase();
        final cust = (e['customer_name'] as String).toLowerCase();
        final shop = (e['shop_name'] as String).toLowerCase();
        return ref.contains(q) || cust.contains(q) || shop.contains(q);
      }).toList();
    }
    return _jsonOk(list);
  });

  router.post('/errands/<id>/reassign', (Request request, String id) async {
    final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    final riderId = body['riderId'] as String?;
    final riderName = body['riderName'] as String?;
    final reason = body['reason'] as String? ?? 'Standby EV shopper reassignment';

    if (riderId == null || riderName == null) {
      return _jsonError(400, 'BAD_REQUEST', 'Missing riderId or riderName.');
    }

    final index = _adminErrands.indexWhere((e) => e['id'] == id);
    if (index == -1) return _jsonError(404, 'NOT_FOUND', 'Errand $id not found.');

    final errand = Map<String, dynamic>.from(_adminErrands[index]);
    errand['assigned_rider_id'] = riderId;
    errand['assigned_rider_name'] = riderName;
    errand['reassignment_reason'] = reason;
    _adminErrands[index] = errand;

    return _jsonOk(errand);
  });

  router.post('/errands/<id>/reconciliation/approve', (Request request, String id) async {
    final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    final actualSpentKobo = body['actualSpentKobo'] as int?;
    final officerName = body['officerName'] as String?;
    final officerRole = body['officerRole'] as String? ?? 'ops_agent';

    if (actualSpentKobo == null || officerName == null) {
      return _jsonError(400, 'BAD_REQUEST', 'Missing actualSpentKobo or officerName.');
    }

    final index = _adminErrands.indexWhere((e) => e['id'] == id);
    if (index == -1) return _jsonError(404, 'NOT_FOUND', 'Errand $id not found.');

    final errand = Map<String, dynamic>.from(_adminErrands[index]);
    final budgetKobo = errand['estimated_budget_kobo'] as int;
    final deltaKobo = (actualSpentKobo - budgetKobo).abs();

    // DUAL MAKER-CHECKER ENFORCEMENT: > ₦10,000 (1,000,000 kobo) delta requires finance or super_admin
    const dualMakerCheckerThresholdKobo = 1000000;
    if (deltaKobo > dualMakerCheckerThresholdKobo &&
        officerRole != 'finance' &&
        officerRole != 'super_admin') {
      return _jsonError(
        403,
        'FORBIDDEN',
        'Reconciliation delta exceeds ₦10,000. Dual Maker-Checker requires Finance Officer or Super Admin approval.',
      );
    }

    errand['actual_spent_kobo'] = actualSpentKobo;
    errand['reconciliation_status'] = 'APPROVED';
    errand['reconciliation_approved_by'] = officerName;
    errand['dispute_flag'] = false;
    _adminErrands[index] = errand;

    return _jsonOk(errand);
  });

  // --------------------------------------------------------------------------
  // 5. SCHEDULED COMMUTE & SCHOOL-RUN COMMAND DESK (§5.2)
  // --------------------------------------------------------------------------
  router.get('/scheduled/manifest', (Request request) async {
    return _jsonOk({
      'manifest': _scheduledManifest,
      'exceptions': _calendarExceptions,
      'active_runs_count': _scheduledManifest.where((m) => m['status'] == 'EN_ROUTE_PICKUP').length,
    });
  });

  router.post('/scheduled/handover/verify-otp', (Request request) async {
    final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    final tripId = body['tripId'] as String?;
    final otpCode = body['otpCode'] as String?;
    final officerName = body['officerName'] as String? ?? 'Ops Chaperone Desk';

    if (tripId == null || otpCode == null) {
      return _jsonError(400, 'BAD_REQUEST', 'Missing tripId or otpCode.');
    }

    final index = _scheduledManifest.indexWhere((m) => m['trip_id'] == tripId);
    if (index == -1) return _jsonError(404, 'NOT_FOUND', 'Scheduled trip $tripId not found.');

    final trip = Map<String, dynamic>.from(_scheduledManifest[index]);
    final expectedOtp = trip['handover_otp'] as String;

    if (otpCode != expectedOtp) {
      return _jsonError(400, 'INVALID_OTP', 'Invalid OTP code. Handover verification rejected.');
    }

    trip['is_handover_verified'] = true;
    trip['status'] = 'STUDENT_HANDOVER_CONFIRMED';
    trip['verified_by'] = officerName;
    trip['verified_at'] = DateTime.now().toIso8601String();
    _scheduledManifest[index] = trip;

    return _jsonOk(trip, meta: {
      'status': 'success',
      'message': 'Student handover safely authenticated via 6-digit OTP code.',
    });
  });

  router.post('/scheduled/handover/emergency-bypass', (Request request) async {
    final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    final tripId = body['tripId'] as String?;
    final bypassReason = body['bypassReason'] as String?;
    final officerName = body['officerName'] as String? ?? 'Safety Supervisor';

    if (tripId == null || bypassReason == null) {
      return _jsonError(400, 'BAD_REQUEST', 'Missing tripId or bypassReason.');
    }

    final index = _scheduledManifest.indexWhere((m) => m['trip_id'] == tripId);
    if (index == -1) return _jsonError(404, 'NOT_FOUND', 'Scheduled trip $tripId not found.');

    final trip = Map<String, dynamic>.from(_scheduledManifest[index]);
    trip['is_handover_verified'] = true;
    trip['status'] = 'BYPASS_CONFIRMED';
    trip['bypass_reason'] = bypassReason;
    trip['bypassed_by'] = officerName;
    _scheduledManifest[index] = trip;

    return _jsonOk(trip);
  });

  router.post('/scheduled/exceptions', (Request request) async {
    final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    final schoolName = body['schoolName'] as String?;
    final reason = body['reason'] as String?;
    final date = body['exceptionDate'] as String?;
    final officerName = body['officerName'] as String? ?? 'Admin Officer';

    if (schoolName == null || reason == null || date == null) {
      return _jsonError(400, 'BAD_REQUEST', 'Missing schoolName, reason or exceptionDate.');
    }

    final newException = {
      'id': 'EXC-${DateTime.now().millisecondsSinceEpoch}',
      'school_name': schoolName,
      'school_id': body['schoolId'] ?? 'SCH-01',
      'exception_date': date,
      'reason': reason,
      'notify_parents': body['notifyParents'] ?? true,
      'notify_drivers': body['notifyDrivers'] ?? true,
      'created_by': officerName,
    };

    _calendarExceptions.add(newException);
    return _jsonOk(newException);
  });

  // --------------------------------------------------------------------------
  // 6. CUSTOMER KYC & IDENTITY VERIFICATION GATEWAY (§A4)
  // --------------------------------------------------------------------------
  router.get('/kyc/queue', (Request request) async {
    final status = request.url.queryParameters['status'];
    var queue = List<Map<String, dynamic>>.from(_kycSubmissions);
    if (status != null && status.isNotEmpty) {
      queue = queue.where((k) => k['status'] == status).toList();
    }
    return _jsonOk(queue);
  });

  router.post('/kyc/<userId>/review', (Request request, String userId) async {
    final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    final decision = body['decision'] as String?; // APPROVED, REJECTED
    final reviewerName = body['reviewerName'] as String? ?? 'Compliance Officer';
    final rejectionReason = body['rejectionReason'] as String?;

    if (decision != 'APPROVED' && decision != 'REJECTED') {
      return _jsonError(400, 'BAD_REQUEST', 'Decision must be APPROVED or REJECTED.');
    }

    final index = _kycSubmissions.indexWhere((k) => k['user_id'] == userId);
    if (index == -1) {
      return _jsonError(404, 'NOT_FOUND', 'KYC submission for user $userId not found.');
    }

    final kyc = Map<String, dynamic>.from(_kycSubmissions[index]);
    kyc['status'] = decision;
    kyc['reviewed_by'] = reviewerName;
    kyc['reviewed_at'] = DateTime.now().toIso8601String();
    if (decision == 'REJECTED') {
      kyc['rejection_reason'] = rejectionReason ?? 'Document unreadable or invalid';
    } else {
      kyc['verified_at'] = DateTime.now().toIso8601String();
    }

    _kycSubmissions[index] = kyc;
    return _jsonOk(kyc);
  });

  // --------------------------------------------------------------------------
  // 7. FAQ CMS MANAGEMENT
  // --------------------------------------------------------------------------
  router.get('/faq', (Request request) async {
    return _jsonOk(_adminFaqs);
  });

  router.post('/faq', (Request request) async {
    final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    final question = body['question'] as String?;
    final answer = body['answer'] as String?;
    final category = body['category'] as String? ?? 'General';

    if (question == null || answer == null) {
      return _jsonError(400, 'BAD_REQUEST', 'Question and answer are required.');
    }

    final newFaq = {
      'id': 'faq_${DateTime.now().millisecondsSinceEpoch}',
      'category': category,
      'question': question,
      'answer': answer,
      'helpful_count': 0,
    };
    _adminFaqs.add(newFaq);
    return _jsonOk(newFaq);
  });

  router.put('/faq/<faqId>', (Request request, String faqId) async {
    final body = jsonDecode(await request.readAsString()) as Map<String, dynamic>;
    final index = _adminFaqs.indexWhere((f) => f['id'] == faqId);
    if (index == -1) return _jsonError(404, 'NOT_FOUND', 'FAQ $faqId not found.');

    final faq = Map<String, dynamic>.from(_adminFaqs[index]);
    if (body['question'] != null) faq['question'] = body['question'];
    if (body['answer'] != null) faq['answer'] = body['answer'];
    if (body['category'] != null) faq['category'] = body['category'];

    _adminFaqs[index] = faq;
    return _jsonOk(faq);
  });

  router.delete('/faq/<faqId>', (Request request, String faqId) async {
    final index = _adminFaqs.indexWhere((f) => f['id'] == faqId);
    if (index == -1) return _jsonError(404, 'NOT_FOUND', 'FAQ $faqId not found.');

    _adminFaqs.removeAt(index);
    return _jsonOk({'deleted': true, 'id': faqId});
  });

  return router;
}
