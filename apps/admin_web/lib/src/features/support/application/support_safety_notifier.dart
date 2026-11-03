import 'package:app_models/app_models.dart' hide TicketStatus;
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/admin_auth_notifier.dart';
import '../domain/support_safety_models.dart';

class SupportSafetyState extends Equatable {
  const SupportSafetyState({
    required this.tickets,
    required this.incidents,
    this.faqs = const [],
    this.selectedTab = 0, // 0 = Support Tickets, 1 = FAQ Knowledge Base, 2 = Confidential Safety
    this.ticketCategoryFilter,
    this.ticketStatusFilter,
    this.faqCategoryFilter,
    this.actionMessage,
  });

  final List<SupportTicketModel> tickets;
  final List<SafetyIncidentModel> incidents;
  final List<SupportFaqDto> faqs;
  final int selectedTab;
  final String? ticketCategoryFilter;
  final TicketStatus? ticketStatusFilter;
  final String? faqCategoryFilter;
  final String? actionMessage;

  int get openTicketsCount => tickets.where((t) => t.status != TicketStatus.resolved).length;
  int get activeIncidentsCount =>
      incidents.where((i) => i.status != SafetyIncidentStatus.resolved).length;
  int get totalFaqsCount => faqs.length;

  List<SupportTicketModel> get filteredTickets {
    return tickets.where((t) {
      if (ticketCategoryFilter != null && t.serviceCategory != ticketCategoryFilter) {
        return false;
      }
      if (ticketStatusFilter != null && t.status != ticketStatusFilter) {
        return false;
      }
      return true;
    }).toList();
  }

  List<SupportFaqDto> get filteredFaqs {
    if (faqCategoryFilter == null || faqCategoryFilter == 'All') {
      return faqs;
    }
    return faqs.where((f) => f.category.toLowerCase() == faqCategoryFilter!.toLowerCase()).toList();
  }

  SupportSafetyState copyWith({
    List<SupportTicketModel>? tickets,
    List<SafetyIncidentModel>? incidents,
    List<SupportFaqDto>? faqs,
    int? selectedTab,
    String? ticketCategoryFilter,
    bool clearTicketCategoryFilter = false,
    TicketStatus? ticketStatusFilter,
    bool clearTicketStatusFilter = false,
    String? faqCategoryFilter,
    bool clearFaqCategoryFilter = false,
    String? actionMessage,
  }) {
    return SupportSafetyState(
      tickets: tickets ?? this.tickets,
      incidents: incidents ?? this.incidents,
      faqs: faqs ?? this.faqs,
      selectedTab: selectedTab ?? this.selectedTab,
      ticketCategoryFilter: clearTicketCategoryFilter
          ? null
          : (ticketCategoryFilter ?? this.ticketCategoryFilter),
      ticketStatusFilter:
          clearTicketStatusFilter ? null : (ticketStatusFilter ?? this.ticketStatusFilter),
      faqCategoryFilter:
          clearFaqCategoryFilter ? null : (faqCategoryFilter ?? this.faqCategoryFilter),
      actionMessage: actionMessage,
    );
  }

  @override
  List<Object?> get props => [
        tickets,
        incidents,
        faqs,
        selectedTab,
        ticketCategoryFilter,
        ticketStatusFilter,
        faqCategoryFilter,
        actionMessage,
      ];
}

class SupportSafetyNotifier extends StateNotifier<SupportSafetyState> {
  SupportSafetyNotifier(this.ref)
      : super(
          SupportSafetyState(
            tickets: _seedTickets,
            incidents: _seedIncidents,
            faqs: _seedFaqs,
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
      description:
          'Customer reports left pouch containing ID cards on moped after dropoff at Victoria Island.',
      createdAt: DateTime(2026, 10, 24, 14, 10),
      assignedAgentId: 'staff_ops_kemi',
      serviceCategory: 'rides',
      messages: [
        SupportTicketMessageDto(
          id: 'msg_01',
          ticketId: 'tick_801',
          senderId: 'cust_dangote',
          senderName: 'Fatima Dangote',
          senderRole: 'customer',
          message:
              'Hello, I completed a ride from Admiralty Way to Victoria Island around 1:30 PM. I believe I left my brown leather pouch in the moped carrier box.',
          createdAt: DateTime(2026, 10, 24, 14, 10),
        ),
        SupportTicketMessageDto(
          id: 'msg_02',
          ticketId: 'tick_801',
          senderId: 'staff_ops_kemi',
          senderName: 'Agent Kemi (Go-Volts Support)',
          senderRole: 'agent',
          message:
              'Hello Fatima, we have contacted rider Tunde Lawal. He has inspected the carrier and confirmed the pouch is secure. He will deliver it to our VI Swap Hub for pickup.',
          createdAt: DateTime(2026, 10, 24, 14, 35),
        ),
      ],
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
      description:
          'Trip was billed with surge multiplier although booked 10 minutes prior to surge window.',
      createdAt: DateTime(2026, 10, 24, 15, 30),
      serviceCategory: 'wallet',
      messages: [
        SupportTicketMessageDto(
          id: 'msg_03',
          ticketId: 'tick_802',
          senderId: 'cust_nwosu',
          senderName: 'Emeka Nwosu',
          senderRole: 'customer',
          message:
              'I was charged ₦2,800 instead of the quoted ₦2,500. The invoice showed a 1.2x surge, but my booking was initiated before the peak surge window.',
          createdAt: DateTime(2026, 10, 24, 15, 30),
        ),
      ],
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
      description:
          'Resolved by triggering fallback push notification token for rider verification.',
      createdAt: DateTime(2026, 10, 23, 11, 0),
      assignedAgentId: 'staff_ops_ade',
      serviceCategory: 'general',
      messages: [
        SupportTicketMessageDto(
          id: 'msg_04',
          ticketId: 'tick_803',
          senderId: 'cust_uche',
          senderName: 'Kalu Uche',
          senderRole: 'customer',
          message: 'The OTP took over 5 minutes to arrive on my MTN line.',
          createdAt: DateTime(2026, 10, 23, 11, 0),
        ),
        SupportTicketMessageDto(
          id: 'msg_05',
          ticketId: 'tick_803',
          senderId: 'staff_ops_ade',
          senderName: 'Agent Adeola',
          senderRole: 'agent',
          message:
              'We have recalibrated our telecom routing to use primary WhatsApp & in-app push verification fallback for your account. Issue resolved.',
          createdAt: DateTime(2026, 10, 23, 11, 20),
        ),
      ],
    ),
    SupportTicketModel(
      id: 'tick_804',
      ticketRef: 'TICK-2026-804',
      customerName: 'Alexander Cole',
      riderName: 'Aminu Dantata',
      category: 'Item Substitution',
      priority: TicketPriority.high,
      status: TicketStatus.open,
      subject: 'Market Errand: Replacement pepper brand pricing discrepancy',
      description:
          'Customer requested Tatase pepper but store substituted with Rodo without price confirmation.',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      serviceCategory: 'market_errand',
      messages: [
        SupportTicketMessageDto(
          id: 'msg_06',
          ticketId: 'tick_804',
          senderId: 'cust_cole',
          senderName: 'Alexander Cole',
          senderRole: 'customer',
          message:
              'The shopping rider purchased a more expensive pepper pack without contacting me first, contrary to my errand preference setting.',
          createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ],
    ),
    SupportTicketModel(
      id: 'tick_805',
      ticketRef: 'TICK-2026-805',
      customerName: 'Dr. Aisha Adeleke',
      riderName: 'Tunde Adeleke',
      category: 'School Run Safeguarding',
      priority: TicketPriority.urgent,
      status: TicketStatus.inProgress,
      subject: 'Scheduled Commute: Morning pickup time alignment',
      description:
          'Parent requests morning pickup window shifted 10 minutes earlier for Corona VI morning assembly.',
      createdAt: DateTime.now().subtract(const Duration(hours: 5)),
      serviceCategory: 'scheduled',
      messages: [
        SupportTicketMessageDto(
          id: 'msg_07',
          ticketId: 'cust_adeleke',
          senderId: 'cust_adeleke',
          senderName: 'Dr. Aisha Adeleke',
          senderRole: 'customer',
          message:
              'Please adjust our morning pickup at Block 4 Admiralty Way to 7:05 AM instead of 7:15 AM so Tari arrives before assembly begins.',
          createdAt: DateTime.now().subtract(const Duration(hours: 5)),
        ),
        SupportTicketMessageDto(
          id: 'msg_08',
          ticketId: 'cust_adeleke',
          senderId: 'staff_ops_kemi',
          senderName: 'Agent Kemi (School-Run Ops)',
          senderRole: 'agent',
          message:
              'Noted Dr. Adeleke. We have updated your recurring scheduled manifest and informed chaperone rider Tunde Adeleke.',
          createdAt: DateTime.now().subtract(const Duration(hours: 4)),
        ),
      ],
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
      description:
          'Automated geofence telemetry triggered alert: Rider stopped outside school designated dropoff bay for 7 minutes. Safety team contacted guardian immediately.',
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
      description:
          'Electric motorcycle rear-ended by minibus during heavy congestion. Automatic crash detection triggered emergency beacon.',
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

  static final List<SupportFaqDto> _seedFaqs = [
    const SupportFaqDto(
      id: 'faq_01',
      category: 'Rides',
      question: 'How do I schedule a zero-emission electric bike ride?',
      answer:
          'Select "Book a Ride" from the home dashboard, enter pickup and destination points, choose an electric bike category (Eco Commute or Roam Air EV), and confirm payment.',
      helpfulCount: 42,
    ),
    const SupportFaqDto(
      id: 'faq_02',
      category: 'Delivery',
      question: 'What items are prohibited on Go-Volts parcel delivery?',
      answer:
          'Flammable liquids, firearms, unpackaged fragile glassware, and packages weighing over 30kg are strictly prohibited under Lagos State logistics guidelines.',
      helpfulCount: 29,
    ),
    const SupportFaqDto(
      id: 'faq_03',
      category: 'Market Errand',
      question: 'How does item substitution work during market errands?',
      answer:
          'If an item is out of stock, your assigned shopper will call or chat with you in-app based on your substitution preference before purchasing an alternative.',
      helpfulCount: 35,
    ),
    const SupportFaqDto(
      id: 'faq_04',
      category: 'School Run',
      question: 'How does the single-use handover OTP protect my child?',
      answer:
          'Every pickup and delivery requires a 6-digit OTP sent exclusively to the authorized parent. The chaperone rider cannot complete the trip without entering this code.',
      helpfulCount: 58,
    ),
    const SupportFaqDto(
      id: 'faq_05',
      category: 'Wallet',
      question: 'How do I top up my Go-Volts wallet using Paystack?',
      answer:
          'Navigate to Wallet > Top Up, enter the desired amount, and select Debit Card (Paystack 3DS) or Bank Transfer to your dedicated virtual NUBAN account.',
      helpfulCount: 64,
    ),
    const SupportFaqDto(
      id: 'faq_06',
      category: 'Safety',
      question: 'What emergency numbers can I dial in Lagos State?',
      answer:
          'You can dial Lagos State Emergency Response directly at 112 or 767, or call our 24/7 Go-Volts Operations Rapid Hotline at 0700-GOVOLTS.',
      helpfulCount: 71,
    ),
  ];

  void setTab(int index) {
    state = state.copyWith(selectedTab: index);
  }

  void filterTicketsByCategory(String? category) {
    if (category == null || category == 'All') {
      state = state.copyWith(clearTicketCategoryFilter: true);
    } else {
      state = state.copyWith(ticketCategoryFilter: category);
    }
  }

  void filterTicketsByStatus(TicketStatus? status) {
    if (status == null) {
      state = state.copyWith(clearTicketStatusFilter: true);
    } else {
      state = state.copyWith(ticketStatusFilter: status);
    }
  }

  void filterFaqsByCategory(String? category) {
    if (category == null || category == 'All') {
      state = state.copyWith(clearFaqCategoryFilter: true);
    } else {
      state = state.copyWith(faqCategoryFilter: category);
    }
  }

  /// Sends an authoritative support agent response message to a ticket chat.
  Future<bool> sendAgentReply({
    required String ticketId,
    required String message,
    required String agentName,
    required String agentId,
  }) async {
    if (message.trim().isEmpty) return false;

    final newMessage = SupportTicketMessageDto(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      ticketId: ticketId,
      senderId: agentId,
      senderName: agentName,
      senderRole: 'agent',
      message: message.trim(),
      createdAt: DateTime.now(),
    );

    final updatedTickets = state.tickets.map((t) {
      if (t.id == ticketId) {
        return t.copyWith(
          status: t.status == TicketStatus.open ? TicketStatus.inProgress : t.status,
          assignedAgentId: agentId,
          messages: [...t.messages, newMessage],
        );
      }
      return t;
    }).toList();

    state = state.copyWith(
      tickets: updatedTickets,
      actionMessage: 'Reply delivered to ticket $ticketId.',
    );
    return true;
  }

  /// Updates ticket status (e.g. In Progress, Resolved).
  void updateTicketStatus(String ticketId, TicketStatus newStatus) {
    final updated = state.tickets.map((t) {
      if (t.id == ticketId) {
        return t.copyWith(status: newStatus);
      }
      return t;
    }).toList();

    state = state.copyWith(
      tickets: updated,
      actionMessage: 'Ticket $ticketId updated to ${newStatus.name}.',
    );
  }

  void resolveTicket(String ticketId) {
    updateTicketStatus(ticketId, TicketStatus.resolved);
  }

  /// Add a new knowledge base FAQ article.
  void addFaq({
    required String category,
    required String question,
    required String answer,
  }) {
    final newFaq = SupportFaqDto(
      id: 'faq_${DateTime.now().millisecondsSinceEpoch}',
      category: category,
      question: question.trim(),
      answer: answer.trim(),
      helpfulCount: 0,
    );

    state = state.copyWith(
      faqs: [...state.faqs, newFaq],
      actionMessage: 'FAQ "${newFaq.question}" published successfully.',
    );
  }

  /// Update an existing FAQ article.
  void updateFaq(SupportFaqDto updatedFaq) {
    final updated = state.faqs.map((f) => f.id == updatedFaq.id ? updatedFaq : f).toList();
    state = state.copyWith(
      faqs: updated,
      actionMessage: 'FAQ updated successfully.',
    );
  }

  /// Delete an FAQ article from knowledge base.
  void deleteFaq(String faqId) {
    final updated = state.faqs.where((f) => f.id != faqId).toList();
    state = state.copyWith(
      faqs: updated,
      actionMessage: 'FAQ article removed from Knowledge Base.',
    );
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

  void clearActionMessage() {
    state = state.copyWith(actionMessage: null);
  }
}

final supportSafetyNotifierProvider =
    StateNotifierProvider<SupportSafetyNotifier, SupportSafetyState>((ref) {
  return SupportSafetyNotifier(ref);
});
