import 'package:app_models/app_models.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/api_providers.dart';
import '../data/profile_repository.dart';

class ProfileState extends Equatable {
  const ProfileState({
    this.profile,
    this.verification = const AccountVerificationDto(
      status: VerificationStatus.verified,
      tier: 'Tier 1 (Basic)',
    ),
    this.isLoading = false,
    this.isSaving = false,
    this.error,
    this.successMessage,
  });

  final ProfileDto? profile;
  final AccountVerificationDto verification;
  final bool isLoading;
  final bool isSaving;
  final String? error;
  final String? successMessage;

  ProfileState copyWith({
    ProfileDto? profile,
    AccountVerificationDto? verification,
    bool? isLoading,
    bool? isSaving,
    String? error,
    String? successMessage,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      verification: verification ?? this.verification,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      error: error,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [profile, verification, isLoading, isSaving, error, successMessage];
}

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProfileRepository(apiClient: apiClient);
});

final profileNotifierProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final repo = ref.watch(profileRepositoryProvider);
  return ProfileNotifier(repository: repo);
});

class ProfileNotifier extends StateNotifier<ProfileState> {
  ProfileNotifier({required ProfileRepository repository})
      : _repository = repository,
        super(const ProfileState());

  final ProfileRepository _repository;

  Future<void> loadProfile({String? userId, ProfileDto? sessionProfile}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final profile = await _repository.getProfile(userId: userId, fallbackProfile: sessionProfile);
      final verification = await _repository.getVerification(userId: userId ?? profile.id);
      state = state.copyWith(
        profile: profile,
        verification: verification,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        profile: sessionProfile ?? state.profile,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<bool> updateProfile({
    String? userId,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? currentAddress,
    String? city,
    String? stateLoc,
    String? gender,
    String? avatarUrl,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) async {
    state = state.copyWith(isSaving: true, error: null, successMessage: null);
    try {
      final updated = await _repository.updateProfile(
        userId: userId ?? state.profile?.id,
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        currentAddress: currentAddress,
        city: city,
        state: stateLoc,
        gender: gender,
        avatarUrl: avatarUrl,
        emergencyContactName: emergencyContactName,
        emergencyContactPhone: emergencyContactPhone,
      );
      state = state.copyWith(
        profile: updated,
        isSaving: false,
        successMessage: 'Profile updated successfully.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSaving: false,
        error: 'Failed to update profile. Please try again.',
      );
      return false;
    }
  }

  Future<bool> submitVerification({
    String? userId,
    required Map<String, String> documentUrls,
  }) async {
    state = state.copyWith(isSaving: true, error: null, successMessage: null);
    try {
      final success = await _repository.submitVerification(
        userId: userId ?? state.profile?.id,
        documentUrls: documentUrls,
      );
      if (success) {
        state = state.copyWith(
          verification: state.verification.copyWith(
            status: VerificationStatus.pending,
            submittedAt: DateTime.now(),
          ),
          isSaving: false,
          successMessage: 'Verification documents submitted for review.',
        );
        return true;
      }
      state = state.copyWith(isSaving: false, error: 'Submission failed.');
      return false;
    } catch (e) {
      state = state.copyWith(isSaving: false, error: e.toString());
      return false;
    }
  }
}

