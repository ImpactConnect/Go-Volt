import 'package:app_models/app_models.dart' hide TicketStatus;
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/admin_auth_notifier.dart';
import '../../../core/data/supabase_admin_client.dart';
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
          const SupportSafetyState(
            tickets: [],
            incidents: [],
            faqs: [],
          ),
        ) {
    fetchRealSupport();
  }

  final Ref ref;

    @visibleForTesting
  void updateStateForTesting(SupportSafetyState newState) {
    state = newState;
  }

  Future<void> fetchRealSupport() async {
    final client = tryGetSupabaseClient();
    if (client == null) return;
    try {
      state = state.copyWith(
        tickets: const [],
        incidents: const [],
        faqs: const [],
      );
    } catch (e) {
      debugPrint('[SupportSafetyNotifier] Error fetching support data: $e');
    }
  }

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
