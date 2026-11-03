import 'package:app_models/app_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/safety_sos_models.dart';

class SafetySosState {
  const SafetySosState({
    this.alerts = const [],
    this.selectedStatus,
    this.searchQuery = '',
    this.actionMessage,
    this.isLoading = false,
  });

  final List<SosDistressAlert> alerts;
  final SosAlertStatus? selectedStatus;
  final String searchQuery;
  final String? actionMessage;
  final bool isLoading;

  int get totalAlertsCount => alerts.length;

  int get activeDistressCount =>
      alerts.where((a) => a.status == SosAlertStatus.activeDistress).length;

  int get dispatched112Count => alerts
      .where((a) => a.status == SosAlertStatus.dispatchedAuthorities)
      .length;

  int get patrolEnRouteCount =>
      alerts.where((a) => a.status == SosAlertStatus.patrolEnRoute).length;

  int get resolvedCount => alerts
      .where((a) =>
          a.status == SosAlertStatus.resolvedSafe ||
          a.status == SosAlertStatus.falseAlarm)
      .length;

  List<SosDistressAlert> get filteredAlerts {
    return alerts.where((a) {
      if (selectedStatus != null && a.status != selectedStatus) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final matchRef = a.incidentRef.toLowerCase().contains(q) ||
            a.bookingRef.toLowerCase().contains(q);
        final matchVictim = a.victimName.toLowerCase().contains(q) ||
            a.victimPhone.toLowerCase().contains(q);
        final matchDriver = a.driverName?.toLowerCase().contains(q) ?? false;
        final matchLocation = a.location.address.toLowerCase().contains(q);
        if (!matchRef && !matchVictim && !matchDriver && !matchLocation) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  SafetySosState copyWith({
    List<SosDistressAlert>? alerts,
    SosAlertStatus? selectedStatus,
    bool clearSelectedStatus = false,
    String? searchQuery,
    String? actionMessage,
    bool clearActionMessage = false,
    bool? isLoading,
  }) {
    return SafetySosState(
      alerts: alerts ?? this.alerts,
      selectedStatus:
          clearSelectedStatus ? null : (selectedStatus ?? this.selectedStatus),
      searchQuery: searchQuery ?? this.searchQuery,
      actionMessage: clearActionMessage
          ? null
          : (actionMessage ?? this.actionMessage),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SafetySosNotifier extends StateNotifier<SafetySosState> {
  SafetySosNotifier() : super(const SafetySosState()) {
    _loadSeedData();
  }

  void _loadSeedData() {
    final now = DateTime.now();

    // Alert 1: Active In-Transit Distress (Passenger triggered SOS button)
    final alert1 = SosDistressAlert(
      id: 'SOS-001',
      incidentRef: 'SOS-2026-0041',
      bookingRef: 'BK-2026-9912',
      serviceType: 'Passenger Ride',
      triggeredBy: 'Passenger (In-App SOS Trigger)',
      victimName: 'Khadijah Cole',
      victimPhone: '+2348034567890',
      driverName: 'Ahmed Ibrahim',
      driverPhone: '+2348031234567',
      vehiclePlate: 'ABC-123XY',
      vehicleModel: 'Spiro Commuter EV',
      location: const LocationDto(
        latitude: 10.5180,
        longitude: 7.4380,
        address: 'Independence Way near Kaduna State Police Command HQ',
      ),
      speedKmH: 36.0,
      evBatteryPercent: 78,
      status: SosAlertStatus.activeDistress,
      triggeredAt: now.subtract(const Duration(minutes: 4)),
      audioRecordingUrl: 'https://cdn.govolts.ng/audio/sos-0041-live.aac',
      incidentNotes: [
        SosIncidentNote(
          id: 'NOTE-01',
          authorName: 'System Monitor',
          authorRole: 'Automated Telematics',
          note: 'Distress trigger detected from Passenger App. Audio recording stream initiated.',
          createdAt: now.subtract(const Duration(minutes: 4)),
        ),
      ],
    );

    // Alert 2: 112 / Police Dispatched (Crash sensor impact)
    final alert2 = SosDistressAlert(
      id: 'SOS-002',
      incidentRef: 'SOS-2026-0040',
      bookingRef: 'SCH-2026-0801',
      serviceType: 'School Run',
      triggeredBy: 'Impact Sensor (Crash Detection)',
      victimName: 'Zayd Cole (Minor Passenger)',
      victimPhone: '+2348034567890 (Mother)',
      driverName: 'Musa Bello',
      driverPhone: '+2348069876543',
      vehiclePlate: 'KD-456-EF',
      vehicleModel: 'Roam Air EV',
      location: const LocationDto(
        latitude: 10.4600,
        longitude: 7.4100,
        address: 'Nnamdi Azikiwe Expressway, Ungwan Rimi, Kaduna',
      ),
      speedKmH: 0.0,
      evBatteryPercent: 62,
      status: SosAlertStatus.dispatchedAuthorities,
      triggeredAt: now.subtract(const Duration(minutes: 25)),
      dispatchedAt: now.subtract(const Duration(minutes: 20)),
      safetyOfficerName: 'Safety Officer Amina',
      emergencyServicesContacted: const [
        'Lagos State 112 / 767 Emergency Center',
        'Kaduna State Emergency Management Agency (KADSEMA)',
        'Federal Road Safety Corps (FRSC Kaduna Command)',
      ],
      incidentNotes: [
        SosIncidentNote(
          id: 'NOTE-02',
          authorName: 'Safety Officer Amina',
          authorRole: 'Senior Safety Investigator',
          note: 'Escalated to FRSC Sector Command & KADSEMA. Ambulance and traffic patrol deployed.',
          createdAt: now.subtract(const Duration(minutes: 20)),
        ),
      ],
    );

    // Alert 3: Patrol En Route (Route deviation during Market Errand)
    final alert3 = SosDistressAlert(
      id: 'SOS-003',
      incidentRef: 'SOS-2026-0039',
      bookingRef: 'ERR-2026-0019',
      serviceType: 'Market Errand',
      triggeredBy: 'Route Deviation Geofence Alarm',
      victimName: 'Omotayo Kehinde',
      victimPhone: '+2348034567890',
      driverName: 'Fatima Abubakar',
      driverPhone: '+2348023456789',
      vehiclePlate: 'KN-789-GH',
      vehicleModel: 'Ampersand Cargo EV',
      location: const LocationDto(
        latitude: 10.4850,
        longitude: 7.4320,
        address: 'Barnawa Bypass, Kaduna',
      ),
      speedKmH: 15.0,
      evBatteryPercent: 84,
      status: SosAlertStatus.patrolEnRoute,
      triggeredAt: now.subtract(const Duration(minutes: 40)),
      dispatchedAt: now.subtract(const Duration(minutes: 32)),
      safetyOfficerName: 'Ops Agent Tunde',
      emergencyServicesContacted: const ['Go-Volts Rapid Patrol Unit 3 (EV Moped)'],
      incidentNotes: [
        SosIncidentNote(
          id: 'NOTE-03',
          authorName: 'Ops Agent Tunde',
          authorRole: 'Live Dispatcher',
          note: 'Go-Volts Mobile Patrol 3 en route. ETA 3 minutes to courier location.',
          createdAt: now.subtract(const Duration(minutes: 32)),
        ),
      ],
    );

    // Alert 4: Resolved Incident (Safe arrival confirmed)
    final alert4 = SosDistressAlert(
      id: 'SOS-004',
      incidentRef: 'SOS-2026-0038',
      bookingRef: 'BK-2026-9800',
      serviceType: 'Passenger Ride',
      triggeredBy: 'Passenger',
      victimName: 'Dr. Kabir Danladi',
      victimPhone: '+2348021112233',
      driverName: 'Zainab Danjuma',
      driverPhone: '+2348039871122',
      vehiclePlate: 'KD-882-AB',
      vehicleModel: 'Roam Commuter EV',
      location: const LocationDto(
        latitude: 10.5050,
        longitude: 7.4200,
        address: '14 Independence Way, Kaduna',
      ),
      speedKmH: 0.0,
      evBatteryPercent: 91,
      status: SosAlertStatus.resolvedSafe,
      triggeredAt: now.subtract(const Duration(hours: 3)),
      dispatchedAt: now.subtract(const Duration(hours: 2, minutes: 55)),
      resolvedAt: now.subtract(const Duration(hours: 2, minutes: 30)),
      safetyOfficerName: 'Safety Officer Amina',
      resolutionSummary: 'False alarm: Customer pocket-dialed SOS trigger. Verified safety over call.',
      incidentNotes: [
        SosIncidentNote(
          id: 'NOTE-04',
          authorName: 'Safety Officer Amina',
          authorRole: 'Senior Safety Investigator',
          note: 'Called customer; confirmed safe at destination with driver present.',
          createdAt: now.subtract(const Duration(hours: 2, minutes: 30)),
        ),
      ],
    );

    state = state.copyWith(
      alerts: [alert1, alert2, alert3, alert4],
    );
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query.trim());
  }

  void filterByStatus(SosAlertStatus? status) {
    if (status == null) {
      state = state.copyWith(clearSelectedStatus: true);
    } else {
      state = state.copyWith(selectedStatus: status);
    }
  }

  /// Dispatches external emergency services (Lagos 112/767, State Police, FRSC, Ambulance).
  Future<bool> dispatchEmergencyServices(
    String alertId, {
    required String agency,
    required String officerName,
    required String notes,
  }) async {
    final now = DateTime.now();
    final updatedAlerts = state.alerts.map((a) {
      if (a.id == alertId) {
        final existingAgencies = List<String>.from(a.emergencyServicesContacted);
        if (!existingAgencies.contains(agency)) {
          existingAgencies.add(agency);
        }

        final newNote = SosIncidentNote(
          id: 'NOTE-${now.millisecondsSinceEpoch}',
          authorName: officerName,
          authorRole: 'Safety Dispatch Officer',
          note: 'Emergency dispatch to $agency: "$notes"',
          createdAt: now,
        );

        return a.copyWith(
          status: SosAlertStatus.dispatchedAuthorities,
          emergencyServicesContacted: existingAgencies,
          safetyOfficerName: officerName,
          dispatchedAt: now,
          incidentNotes: [...a.incidentNotes, newNote],
        );
      }
      return a;
    }).toList();

    state = state.copyWith(
      alerts: updatedAlerts,
      actionMessage:
          'Emergency dispatch initiated: $agency notified by $officerName for incident $alertId.',
    );
    return true;
  }

  /// Dispatches Go-Volts EV Rapid Response Patrol Unit.
  Future<bool> dispatchPatrolUnit(
    String alertId, {
    required String patrolUnitCode,
    required String officerName,
  }) async {
    final now = DateTime.now();
    final updatedAlerts = state.alerts.map((a) {
      if (a.id == alertId) {
        final newNote = SosIncidentNote(
          id: 'NOTE-${now.millisecondsSinceEpoch}',
          authorName: officerName,
          authorRole: 'Safety Dispatch Officer',
          note: 'Go-Volts Rapid Patrol Unit $patrolUnitCode deployed to live GPS location.',
          createdAt: now,
        );

        return a.copyWith(
          status: SosAlertStatus.patrolEnRoute,
          safetyOfficerName: officerName,
          dispatchedAt: now,
          incidentNotes: [...a.incidentNotes, newNote],
        );
      }
      return a;
    }).toList();

    state = state.copyWith(
      alerts: updatedAlerts,
      actionMessage:
          'Rapid Patrol Unit $patrolUnitCode deployed for incident $alertId by $officerName.',
    );
    return true;
  }

  /// Appends an investigation note to the incident timeline.
  Future<bool> addIncidentNote(
    String alertId, {
    required String note,
    required String authorName,
    required String authorRole,
  }) async {
    final now = DateTime.now();
    final updatedAlerts = state.alerts.map((a) {
      if (a.id == alertId) {
        final newNote = SosIncidentNote(
          id: 'NOTE-${now.millisecondsSinceEpoch}',
          authorName: authorName,
          authorRole: authorRole,
          note: note,
          createdAt: now,
        );
        return a.copyWith(incidentNotes: [...a.incidentNotes, newNote]);
      }
      return a;
    }).toList();

    state = state.copyWith(
      alerts: updatedAlerts,
      actionMessage: 'Investigation note appended to incident $alertId.',
    );
    return true;
  }

  /// Closes an SOS alert as Resolved Safe or False Alarm.
  Future<bool> resolveAlert(
    String alertId, {
    required bool isFalseAlarm,
    required String resolutionSummary,
    required String officerName,
  }) async {
    final now = DateTime.now();
    final updatedAlerts = state.alerts.map((a) {
      if (a.id == alertId) {
        final newNote = SosIncidentNote(
          id: 'NOTE-${now.millisecondsSinceEpoch}',
          authorName: officerName,
          authorRole: 'Safety Officer',
          note: 'Incident closed: $resolutionSummary',
          createdAt: now,
        );

        return a.copyWith(
          status: isFalseAlarm
              ? SosAlertStatus.falseAlarm
              : SosAlertStatus.resolvedSafe,
          resolvedAt: now,
          resolutionSummary: resolutionSummary,
          safetyOfficerName: officerName,
          incidentNotes: [...a.incidentNotes, newNote],
        );
      }
      return a;
    }).toList();

    state = state.copyWith(
      alerts: updatedAlerts,
      actionMessage:
          'Incident $alertId marked ${isFalseAlarm ? 'False Alarm' : 'Resolved Safe'} by $officerName.',
    );
    return true;
  }
}

final safetySosNotifierProvider =
    StateNotifierProvider<SafetySosNotifier, SafetySosState>((ref) {
  return SafetySosNotifier();
});

