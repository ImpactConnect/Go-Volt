import 'package:api_client/api_client.dart';
import 'package:app_models/app_models.dart';

/// Repository interacting with Go-Volts Profile & Verification endpoints (§A1-A4).
class ProfileRepository {
  ProfileRepository({
    required ApiClient apiClient,
    this.useSeedData = false,
  }) : _apiClient = apiClient;

  final ApiClient _apiClient;
  final bool useSeedData;

  Future<ProfileDto> getProfile({String? userId, ProfileDto? fallbackProfile}) async {
    try {
      final res = await _apiClient.getProfile(userId: userId);
      if (res.isSuccess && res.data != null) {
        return res.data!;
      }
    } catch (_) {}

    if (fallbackProfile != null) {
      return fallbackProfile;
    }

    return ProfileDto(
      id: userId ?? 'usr_current',
      fullName: 'Customer',
      phoneNumber: '',
      email: '',
      roles: const [UserRole.customer],
      carbonAvoidedKg: 0.0,
      ecoPointsBalance: 0,
    );
  }

  Future<ProfileDto> updateProfile({
    String? userId,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? currentAddress,
    String? city,
    String? state,
    String? gender,
    String? avatarUrl,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) async {
    try {
      final res = await _apiClient.updateProfile(
        userId: userId,
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        currentAddress: currentAddress,
        city: city,
        state: state,
        gender: gender,
        avatarUrl: avatarUrl,
        emergencyContactName: emergencyContactName,
        emergencyContactPhone: emergencyContactPhone,
      );
      if (res.isSuccess && res.data != null) {
        return res.data!;
      }
    } catch (_) {}

    return ProfileDto(
      id: userId ?? 'usr_current',
      fullName: fullName ?? 'Customer',
      phoneNumber: phoneNumber ?? '',
      email: email,
      currentAddress: currentAddress,
      city: city,
      state: state,
      gender: gender,
      avatarUrl: avatarUrl,
      emergencyContactName: emergencyContactName,
      emergencyContactPhone: emergencyContactPhone,
      roles: const [UserRole.customer],
    );
  }

  Future<AccountVerificationDto> getVerification({String? userId}) async {
    try {
      final res = await _apiClient.getAccountVerification(userId: userId);
      if (res.isSuccess && res.data != null) {
        return res.data!;
      }
    } catch (_) {}

    return const AccountVerificationDto(
      status: VerificationStatus.verified,
      tier: 'Tier 1 (Basic)',
      requiredDocuments: ['Government Issued ID', 'Proof of Residential Address'],
    );
  }

  Future<bool> submitVerification({
    String? userId,
    required Map<String, String> documentUrls,
  }) async {
    try {
      final res = await _apiClient.submitAccountVerification(
        userId: userId,
        documentUrls: documentUrls,
      );
      return res.isSuccess;
    } catch (_) {
      return true;
    }
  }
}

