import 'package:app_models/app_models.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/api_providers.dart';
import '../data/settings_repository.dart';

class SettingsState extends Equatable {
  const SettingsState({
    this.notifications = const NotificationPreferencesDto(),
    this.language = 'English (Nigeria)',
    this.appearance = 'System Default',
    this.anonymousTelematics = true,
    this.locationPermissionsEnabled = true,
    this.isLoading = false,
    this.isSaving = false,
    this.statusMessage,
  });

  final NotificationPreferencesDto notifications;
  final String language;
  final String appearance;
  final bool anonymousTelematics;
  final bool locationPermissionsEnabled;
  final bool isLoading;
  final bool isSaving;
  final String? statusMessage;

  SettingsState copyWith({
    NotificationPreferencesDto? notifications,
    String? language,
    String? appearance,
    bool? anonymousTelematics,
    bool? locationPermissionsEnabled,
    bool? isLoading,
    bool? isSaving,
    String? statusMessage,
  }) {
    return SettingsState(
      notifications: notifications ?? this.notifications,
      language: language ?? this.language,
      appearance: appearance ?? this.appearance,
      anonymousTelematics: anonymousTelematics ?? this.anonymousTelematics,
      locationPermissionsEnabled: locationPermissionsEnabled ?? this.locationPermissionsEnabled,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      statusMessage: statusMessage,
    );
  }

  @override
  List<Object?> get props => [
        notifications,
        language,
        appearance,
        anonymousTelematics,
        locationPermissionsEnabled,
        isLoading,
        isSaving,
        statusMessage,
      ];
}

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return SettingsRepository(apiClient: apiClient);
});

final settingsNotifierProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final repo = ref.watch(settingsRepositoryProvider);
  return SettingsNotifier(repository: repo);
});

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier({required SettingsRepository repository})
      : _repository = repository,
        super(const SettingsState()) {
    loadPreferences();
  }

  final SettingsRepository _repository;

  Future<void> loadPreferences({String? userId}) async {
    state = state.copyWith(isLoading: true);
    try {
      final prefs = await _repository.getNotificationPreferences(userId: userId);
      state = state.copyWith(notifications: prefs, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> updateNotificationPreference({
    String? userId,
    required NotificationPreferencesDto Function(NotificationPreferencesDto current) update,
  }) async {
    final updated = update(state.notifications);
    state = state.copyWith(notifications: updated, isSaving: true);
    try {
      final persisted = await _repository.updateNotificationPreferences(
        userId: userId,
        preferences: updated,
      );
      state = state.copyWith(notifications: persisted, isSaving: false);
    } catch (_) {
      state = state.copyWith(isSaving: false);
    }
  }

  void setLanguage(String lang) {
    state = state.copyWith(language: lang);
  }

  void setAppearance(String theme) {
    state = state.copyWith(appearance: theme);
  }

  void toggleTelematics(bool value) {
    state = state.copyWith(anonymousTelematics: value);
  }

  void toggleLocationPermissions(bool value) {
    state = state.copyWith(locationPermissionsEnabled: value);
  }
}

