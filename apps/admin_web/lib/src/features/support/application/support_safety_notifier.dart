import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/admin_auth_notifier.dart';
import '../domain/support_safety_models.dart';

class SupportSafetyState extends Equatable {
  const SupportSafetyState({
    required this.tickets,
    required this.incidents,
    this.selectedTab = 0, // 0 = Support Tickets, 1 = Confidential Safety
  });

  final List<SupportTicketModel> tickets;
  final List<SafetyIncidentModel> incidents;
  final int selectedTab;

  int get openTicketsCount => tickets.where((t) => t.status != TicketStatus.resolved).length;
  int get activeIncidentsCount => incidents.where((i) => i.status != SafetyIncidentStatus.resolved).length;

  SupportSafetyState copyWith({
    List<SupportTicketModel>? tickets,
    List<SafetyIncidentModel>? incidents,
    int? selectedTab,
  }) {
    return SupportSafetyState(
      tickets: tickets ?? this.tickets,
      incidents: incidents ?? this.incidents,
      selectedTab: selectedTab ?? this.selectedTab,
    );
  }

  @override
  List<Object?> get props => [tickets, incidents, selectedTab];
}

class SupportSafetyNotifier extends StateNotifier<SupportSafetyState> {
  SupportSafetyNotifier(this.ref)
      : super(
          SupportSafetyState(
            tickets: _seedTickets,
            incidents: _seedIncidents,
          ),
        );

  final Ref ref;

  static final List<SupportTicketModel> _seedTickets = [
    SupportTicketModel(
      id: 'tick_801',
      ticketRef: 'TICK-2026-801',
      customerName: 'Fatima Dangote',
      riderName: 'Tunde Lawal',
      category: 'Lost Item',
      priority: TicketPriority.high,
      status: TicketStatus.inProgress,
      subject: 'Left leather pouch on moped rear carrier',
      description: 'Customer reports left pouch containing ID cards on moped after dropoff at Victoria Island.',
      createdAt: DateTime(2026, 10, 24, 14, 10),
      assignedAgentId: 'staff_ops_kemi',
    ),
    SupportTicketModel(
      id: 'tick_802',
      ticketRef: 'TICK-2026-802',
      customerName: 'Emeka Nwosu',
      riderName: 'Ibrahim Danladi',
      category: 'Fare Dispute',
      priority: TicketPriority.normal,
      status: TicketStatus.open,
      subject: 'Billed ₦300 extra during off-peak commute',
      description: 'Trip was billed with surge multiplier although booked 10 minutes prior to surge window.',
      createdAt: DateTime(2026, 10, 24, 15, 30),
    ),
    SupportTicketModel(
      id: 'tick_803',
      ticketRef: 'TICK-2026-803',
      customerName: 'Kalu Uche',
      riderName: 'Emeka Obi',
      category: 'App Bug',
      priority: TicketPriority.normal,
      status: TicketStatus.resolved,
      subject: 'In-app OTP notification delayed by SMS gateway',
      description: 'Resolved by triggering fallback push notification token for rider verification.',
      createdAt: DateTime(2026, 10, 23, 11, 0),
      assignedAgentId: 'staff_ops_ade',
    ),
  ];

  static final List<SafetyIncidentModel> _seedIncidents = [
    SafetyIncidentModel(
      id: 'safe_inc_001',
      incidentRef: 'INC-SAFE-2026-001',
      bookingRef: 'GV-SCH-7719',
      incidentType: 'Child Safeguarding Escort Deviation',
      severity: SafetyIncidentSeverity.critical,
      status: SafetyIncidentStatus.investigating,
      partiesInvolved: 'Student: Tari Adeleke (Age 11) · Rider: Emeka Obi · School: Corona VI',
      locationNarrative: 'Ahmadu Bello Way, VI (GPS deviation of 450m detected)',
      description: 'Automated geofence telemetry triggered alert: Rider stopped outside school designated dropoff bay for 7 minutes. Safety team contacted guardian immediately.',
      reportedAt: DateTime(2026, 10, 24, 8, 15),
      investigationNotes: const [
        '08:16 - Geofence breach automated alert triggered',
        '08:18 - Safety officer called rider; rider reported minor road closure and pedestrian escort',
        '08:22 - School gatekeeper and parent verified safe arrival via secondary OTP',
      ],
      lawEnforcementReportRef: null,
    ),
    SafetyIncidentModel(
      id: 'safe_inc_002',
      incidentRef: 'INC-SAFE-2026-002',
      bookingRef: 'GV-LKG-3091',
      incidentType: 'Severe Collision / Vehicle Impact',
      severity: SafetyIncidentSeverity.critical,
      status: SafetyIncidentStatus.escalatedAuthorities,
      partiesInvolved: 'Rider: Musa Aliyu · Third Party: Commercial Minibus (Danfo)',
      locationNarrative: 'Third Mainland Bridge, Ebute Metta descent',
      description: 'Electric motorcycle rear-ended by minibus during heavy congestion. Automatic crash detection triggered emergency beacon.',
      reportedAt: DateTime(2026, 10, 22, 18, 40),
      investigationNotes: const [
        '18:41 - Accelerometer impact sensor detected 6.5G deceleration',
        '18:44 - Emergency dispatch directed LASAMBUS ambulance team to coordinates',
        '19:10 - Rider hospitalized with stable vitals; helmet saved from head trauma',
        '20:00 - Police incident FIR filed at Ebute Metta Division',
      ],
      lawEnforcementReportRef: 'NPF-LAG-2026-4491-FIR',
      resolvedAt: null,
    ),
  ];

  void setTab(int index) {
    state = state.copyWith(selectedTab: index);
  }

  void resolveTicket(String ticketId) {
    final updated = state.tickets.map((t) {
      if (t.id == ticketId) {
        return t.copyWith(status: TicketStatus.resolved);
      }
      return t;
    }).toList();

    state = state.copyWith(tickets: updated);
  }

  void addSafetyInvestigationNote(String incidentId, String note) {
    final authState = ref.read(adminAuthNotifierProvider);
    if (!authState.role.canAccessSafety) return;

    final timestampStr = DateTime.now().toIso8601String().substring(11, 16);
    final formattedNote = '$timestampStr - $note (${authState.userName})';

    final updated = state.incidents.map((inc) {
      if (inc.id == incidentId) {
        return inc.copyWith(
          investigationNotes: [...inc.investigationNotes, formattedNote],
        );
      }
      return inc;
    }).toList();

    state = state.copyWith(incidents: updated);
  }

  void resolveSafetyIncident(String incidentId) {
    final authState = ref.read(adminAuthNotifierProvider);
    if (!authState.role.canAccessSafety) return;

    final updated = state.incidents.map((inc) {
      if (inc.id == incidentId) {
        return inc.copyWith(
          status: SafetyIncidentStatus.resolved,
          resolvedAt: DateTime.now(),
        );
      }
      return inc;
    }).toList();

    state = state.copyWith(incidents: updated);
  }
}

final supportSafetyNotifierProvider =
    StateNotifierProvider<SupportSafetyNotifier, SupportSafetyState>((ref) {
  return SupportSafetyNotifier(ref);
});
