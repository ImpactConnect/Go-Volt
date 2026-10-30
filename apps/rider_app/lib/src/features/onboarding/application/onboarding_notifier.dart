import 'package:app_models/app_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/rider_repository.dart';
import '../domain/onboarding_state.dart';

final onboardingNotifierProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingState>((ref) {
      final repository = ref.watch(riderRepositoryProvider);
      return OnboardingNotifier(repository: repository);
    });

/// Manages multi-step rider KYC registration, document uploads, and certification.
class OnboardingNotifier extends StateNotifier<OnboardingState> {
  OnboardingNotifier({required this.repository})
    : super(const OnboardingState());

  final RiderRepository repository;

  void goToStep(int step) {
    state = state.copyWith(currentStep: step);
  }

  void nextStep() {
    if (state.currentStep < 5) {
      state = state.copyWith(currentStep: state.currentStep + 1);
    }
  }

  void previousStep() {
    if (state.currentStep > 0) {
      state = state.copyWith(currentStep: state.currentStep - 1);
    }
  }

  void updatePersonalDetails({
    required String fullName,
    required String phoneNumber,
    required String email,
    required String residentialAddress,
    required String lagosLga,
    required String emergencyContactName,
    required String emergencyContactPhone,
  }) {
    state = state.copyWith(
      fullName: fullName,
      phoneNumber: phoneNumber,
      email: email,
      residentialAddress: residentialAddress,
      lagosLga: lagosLga,
      emergencyContactName: emergencyContactName,
      emergencyContactPhone: emergencyContactPhone,
    );
  }

  void addDocument(RiderDocumentDto document) {
    final updatedList = List<RiderDocumentDto>.from(state.documents)
      ..removeWhere((d) => d.type == document.type)
      ..add(document);
    state = state.copyWith(documents: updatedList);
  }

  void removeDocument(String documentId) {
    final updatedList =
        state.documents.where((d) => d.id != documentId).toList();
    state = state.copyWith(documents: updatedList);
  }

  void updateVehicleDetails({
    required VehicleType vehicleType,
    required String vehiclePlate,
    required String vehicleModel,
    required String chassisNumber,
    required String batteryCapacityKwh,
  }) {
    state = state.copyWith(
      vehicleType: vehicleType,
      vehiclePlate: vehiclePlate,
      vehicleModel: vehicleModel,
      chassisNumber: chassisNumber,
      batteryCapacityKwh: batteryCapacityKwh,
    );
  }

  void updateGuarantorDetails({
    required String fullName,
    required String phoneNumber,
    required String relationship,
    required String residentialAddress,
  }) {
    final guarantor = RiderGuarantorDto(
      fullName: fullName,
      phoneNumber: phoneNumber,
      relationship: relationship,
      residentialAddress: residentialAddress,
      isVerified: false,
    );
    state = state.copyWith(guarantor: guarantor);
  }

  void selectAssessmentAnswer(int questionIndex, int optionIndex) {
    final updated = Map<int, int>.from(state.assessmentAnswers);
    updated[questionIndex] = optionIndex;
    state = state.copyWith(assessmentAnswers: updated);
  }

  void completeTraining(int score) {
    state = state.copyWith(assessmentScore: score, trainingCompleted: true);
  }

  Future<bool> submitApplication() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final rider = await repository.submitApplication(state);
      state = state.copyWith(
        isLoading: false,
        submittedRider: rider,
        currentStep: 5, // Status & review screen
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to submit application: $e',
      );
      return false;
    }
  }
}
