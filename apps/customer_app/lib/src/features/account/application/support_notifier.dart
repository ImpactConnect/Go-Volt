import 'package:app_models/app_models.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/api_providers.dart';
import '../data/support_repository.dart';

class SupportState extends Equatable {
  const SupportState({
    this.faqs = const [],
    this.tickets = const [],
    this.selectedTicket,
    this.selectedCategory = 'All',
    this.searchQuery = '',
    this.isLoading = false,
    this.isSubmitting = false,
    this.error,
    this.statusMessage,
  });

  final List<SupportFaqDto> faqs;
  final List<SupportTicketDto> tickets;
  final SupportTicketDto? selectedTicket;
  final String selectedCategory;
  final String searchQuery;
  final bool isLoading;
  final bool isSubmitting;
  final String? error;
  final String? statusMessage;

  List<SupportFaqDto> get filteredFaqs {
    var list = faqs;
    if (selectedCategory != 'All') {
      list = list.where((f) => f.category.toLowerCase() == selectedCategory.toLowerCase()).toList();
    }
    if (searchQuery.isNotEmpty) {
      final q = searchQuery.toLowerCase();
      list = list.where((f) => f.question.toLowerCase().contains(q) || f.answer.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  SupportState copyWith({
    List<SupportFaqDto>? faqs,
    List<SupportTicketDto>? tickets,
    SupportTicketDto? selectedTicket,
    String? selectedCategory,
    String? searchQuery,
    bool? isLoading,
    bool? isSubmitting,
    String? error,
    String? statusMessage,
  }) {
    return SupportState(
      faqs: faqs ?? this.faqs,
      tickets: tickets ?? this.tickets,
      selectedTicket: selectedTicket ?? this.selectedTicket,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      statusMessage: statusMessage,
    );
  }

  @override
  List<Object?> get props => [
        faqs,
        tickets,
        selectedTicket,
        selectedCategory,
        searchQuery,
        isLoading,
        isSubmitting,
        error,
        statusMessage,
      ];
}

final supportRepositoryProvider = Provider<SupportRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SupportRepository(apiClient: apiClient);
});

final supportNotifierProvider = StateNotifierProvider<SupportNotifier, SupportState>((ref) {
  final repo = ref.watch(supportRepositoryProvider);
  return SupportNotifier(repository: repo);
});

class SupportNotifier extends StateNotifier<SupportState> {
  SupportNotifier({required SupportRepository repository})
      : _repository = repository,
        super(const SupportState()) {
    loadFaqs();
    loadTickets();
  }

  final SupportRepository _repository;

  Future<void> loadFaqs({String? category}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repository.getFaqs(category: category);
      state = state.copyWith(faqs: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> loadTickets({String? userId}) async {
    try {
      final list = await _repository.getTickets(userId: userId);
      state = state.copyWith(tickets: list);
    } catch (_) {}
  }

  void filterCategory(String category) {
    state = state.copyWith(selectedCategory: category);
  }

  void updateSearch(String query) {
    state = state.copyWith(searchQuery: query.trim());
  }

  Future<SupportTicketDto?> createTicket({
    String? userId,
    required String serviceCategory,
    required String issueType,
    required String subject,
    required String description,
    String? relatedEntityId,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final created = await _repository.createTicket(
        userId: userId,
        serviceCategory: serviceCategory,
        issueType: issueType,
        subject: subject,
        description: description,
        relatedEntityId: relatedEntityId,
      );
      state = state.copyWith(
        tickets: [created, ...state.tickets],
        selectedTicket: created,
        isSubmitting: false,
        statusMessage: 'Support ticket submitted successfully.',
      );
      return created;
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      return null;
    }
  }

  Future<void> loadTicketDetails(String ticketId, {String? userId}) async {
    state = state.copyWith(isLoading: true);
    final ticket = await _repository.getTicketDetails(ticketId: ticketId, userId: userId);
    if (ticket != null) {
      state = state.copyWith(selectedTicket: ticket, isLoading: false);
    } else {
      // Find from local tickets if offline
      SupportTicketDto? local;
      try {
        local = state.tickets.firstWhere((t) => t.id == ticketId || t.ticketNumber == ticketId);
      } catch (_) {
        local = null;
      }
      state = state.copyWith(selectedTicket: local, isLoading: false);
    }
  }

  Future<bool> replyToTicket({
    required String ticketId,
    String? userId,
    required String message,
    String? senderName,
  }) async {
    state = state.copyWith(isSubmitting: true, error: null);
    final updated = await _repository.replyToTicket(
      ticketId: ticketId,
      userId: userId,
      message: message,
      senderName: senderName,
    );
    if (updated != null) {
      final list = state.tickets.map((t) => t.id == ticketId ? updated : t).toList();
      state = state.copyWith(
        tickets: list,
        selectedTicket: updated,
        isSubmitting: false,
        statusMessage: 'Reply sent.',
      );
      return true;
    }
    state = state.copyWith(isSubmitting: false, error: 'Failed to send reply.');
    return false;
  }
}

