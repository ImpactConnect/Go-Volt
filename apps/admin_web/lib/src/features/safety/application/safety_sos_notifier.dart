import 'package:app_models/app_models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/supabase_admin_client.dart';
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
    fetchRealAlerts();
  }

  Future<void> fetchRealAlerts() async {
    final client = tryGetSupabaseClient();
    if (client == null) return;

    try {
      state = state.copyWith(isLoading: true);
      final res = await client.from('bookings').select();
      final list = res as List<dynamic>;

      final sosList = list
          .where((b) => b['is_sos'] == true || b['status'] == 'sos_distress')
          .map((b) {
        final lat = (b['pickup_lat'] as num?)?.toDouble() ?? 6.4281;
        final lng = (b['pickup_lng'] as num?)?.toDouble() ?? 3.4219;
        final addr = b['pickup_address']?.toString() ?? 'Lagos';
        return SosDistressAlert(
          id: b['id']?.toString() ?? '',
          incidentRef:
              b['reference']?.toString() ?? b['id']?.toString() ?? '',
          bookingRef: b['booking_ref']?.toString() ??
              b['reference']?.toString() ??
              '',
          serviceType: 'Passenger Ride',
          triggeredBy: 'Passenger SOS',
          victimName: b['customer_name']?.toString() ?? 'Passenger',
          victimPhone: b['customer_phone']?.toString() ?? '',
          driverName: b['rider_name']?.toString(),
          driverPhone: b['rider_phone']?.toString(),
          vehiclePlate: b['rider_plate']?.toString() ?? 'N/A',
          vehicleModel: 'Go-Volt EV',
          location: LocationDto(latitude: lat, longitude: lng, address: addr),
          speedKmH: 0.0,
          evBatteryPercent: 90,
          status: SosAlertStatus.activeDistress,
          triggeredAt: DateTime.tryParse(b['created_at']?.toString() ?? '') ??
              DateTime.now(),
          incidentNotes: const [],
        );
      }).toList();

      state = state.copyWith(
        isLoading: false,
        alerts: sosList,
      );
    } catch (e) {
      debugPrint('[SafetySosNotifier] Error fetching alerts: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  @visibleForTesting
  void updateStateForTesting(SafetySosState newState) {
    state = newState;
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

