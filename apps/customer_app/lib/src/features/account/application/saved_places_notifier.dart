import 'package:app_models/app_models.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/api_providers.dart';
import '../data/saved_places_repository.dart';

class SavedPlacesState extends Equatable {
  const SavedPlacesState({
    this.places = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.statusMessage,
  });

  final List<SavedPlaceDto> places;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final String? statusMessage;

  SavedPlacesState copyWith({
    List<SavedPlaceDto>? places,
    bool? isLoading,
    bool? isSaving,
    String? error,
    String? statusMessage,
  }) {
    return SavedPlacesState(
      places: places ?? this.places,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      statusMessage: statusMessage,
    );
  }

  @override
  List<Object?> get props => [places, isLoading, isSaving, error, statusMessage];
}

final savedPlacesRepositoryProvider = Provider<SavedPlacesRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SavedPlacesRepository(apiClient: apiClient);
});

final savedPlacesNotifierProvider = StateNotifierProvider<SavedPlacesNotifier, SavedPlacesState>((ref) {
  final repo = ref.watch(savedPlacesRepositoryProvider);
  return SavedPlacesNotifier(repository: repo);
});

class SavedPlacesNotifier extends StateNotifier<SavedPlacesState> {
  SavedPlacesNotifier({required SavedPlacesRepository repository})
      : _repository = repository,
        super(const SavedPlacesState()) {
    loadPlaces();
  }

  final SavedPlacesRepository _repository;

  Future<void> loadPlaces({String? userId}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final list = await _repository.getPlaces(userId: userId);
      state = state.copyWith(places: list, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<bool> addPlace({
    String? userId,
    required String label,
    required String address,
    required SavedPlaceType type,
    required double latitude,
    required double longitude,
    String? additionalInstructions,
  }) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      final created = await _repository.addPlace(
        userId: userId,
        label: label,
        address: address,
        type: type,
        latitude: latitude,
        longitude: longitude,
        additionalInstructions: additionalInstructions,
      );
      state = state.copyWith(
        places: [...state.places, created],
        isSaving: false,
        statusMessage: 'Place saved successfully.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  Future<bool> updatePlace({
    required String placeId,
    String? userId,
    String? label,
    String? address,
    SavedPlaceType? type,
    double? latitude,
    double? longitude,
    String? additionalInstructions,
  }) async {
    state = state.copyWith(isSaving: true, error: null);
    try {
      final updated = await _repository.updatePlace(
        placeId: placeId,
        userId: userId,
        label: label,
        address: address,
        type: type,
        latitude: latitude,
        longitude: longitude,
        additionalInstructions: additionalInstructions,
      );
      if (updated != null) {
        final list = state.places.map((p) => p.id == placeId ? updated : p).toList();
        state = state.copyWith(places: list, isSaving: false);
        return true;
      }
      state = state.copyWith(isSaving: false);
      return false;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }

  Future<bool> deletePlace({
    required String placeId,
    String? userId,
    bool force = false,
  }) async {
    state = state.copyWith(isSaving: true, error: null);
    final error = await _repository.deletePlace(
      placeId: placeId,
      userId: userId,
      force: force,
    );
    if (error == null) {
      final list = state.places.where((p) => p.id != placeId).toList();
      state = state.copyWith(places: list, isSaving: false, statusMessage: 'Place removed.');
      return true;
    }
    state = state.copyWith(isSaving: false, error: error);
    return false;
  }
}

