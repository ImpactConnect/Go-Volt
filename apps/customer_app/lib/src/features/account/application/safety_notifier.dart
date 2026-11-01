import 'package:app_models/app_models.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/api_providers.dart';
import '../data/safety_repository.dart';

class SafetyState extends Equatable {
  const SafetyState({
    this.trustedContacts = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.statusMessage,
  });

  final List<TrustedContactDto> trustedContacts;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final String? statusMessage;

  SafetyState copyWith({
    List<TrustedContactDto>? trustedContacts,
    bool? isLoading,
    bool? isSaving,
    String? error,
    String? statusMessage,
  }) {
    return SafetyState(
      trustedContacts: trustedContacts ?? this.trustedContacts,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      statusMessage: statusMessage,
    );
  }

  @override
  List<Object?> get props => [trustedContacts, isLoading, isSaving, error, statusMessage];
}

final safetyRepositoryProvider = Provider<SafetyRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SafetyRepository(apiClient: apiClient);
});

final safetyNotifierProvider = StateNotifierProvider<SafetyNotifier, SafetyState>((ref) {
  final repo = ref.watch(safetyRepositoryProvider);
  return SafetyNotifier(repository: repo);
});

class SafetyNotifier extends StateNotifier<SafetyState> {
  SafetyNotifier({required SafetyRepository repository})
      : _repository = repository,
        super(const SafetyState()) {
    loadContacts();
  }

  final SafetyRepository _repository;

  Future<void> loadContacts({String? userId}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repository.getTrustedContacts(userId: userId);
      state = state.copyWith(trustedContacts: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addContact({
    String? userId,
    required String name,
    required String phoneNumber,
    String relationship = 'Friend',
    bool autoShareRides = false,
  }) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      final created = await _repository.addTrustedContact(
        userId: userId,
        name: name,
        phoneNumber: phoneNumber,
        relationship: relationship,
        autoShareRides: autoShareRides,
      );
      state = state.copyWith(
        trustedContacts: [...state.trustedContacts, created],
        isSaving: false,
        statusMessage: 'Trusted contact added successfully.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deleteContact({
    required String contactId,
    String? userId,
  }) async {
    state = state.copyWith(isSaving: true, error: null);
    final ok = await _repository.deleteTrustedContact(
      contactId: contactId,
      userId: userId,
    );
    if (ok) {
      final list = state.trustedContacts.where((c) => c.id != contactId).toList();
      state = state.copyWith(
        trustedContacts: list,
        isSaving: false,
        statusMessage: 'Contact removed.',
      );
      return true;
    }
    state = state.copyWith(isSaving: false, error: 'Failed to remove contact.');
    return false;
  }

  Future<bool> reportIncident({
    String? userId,
    required String category,
    required String description,
    String? relatedBookingId,
  }) async {
    state = state.copyWith(isSaving: true, error: null);
    final ok = await _repository.reportIncident(
      userId: userId,
      category: category,
      description: description,
      relatedBookingId: relatedBookingId,
    );
    state = state.copyWith(
      isSaving: false,
      statusMessage: ok ? 'Incident report sent. Fleet security alerted.' : null,
      error: ok ? null : 'Failed to submit report.',
    );
    return ok;
  }
}

