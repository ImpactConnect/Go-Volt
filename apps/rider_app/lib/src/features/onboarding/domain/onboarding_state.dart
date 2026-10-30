import 'package:app_models/app_models.dart';
import 'package:equatable/equatable.dart';

/// State representation for rider onboarding and KYC progression.
class OnboardingState extends Equatable {
  const OnboardingState({
    this.currentStep = 0,
    this.fullName = '',
    this.phoneNumber = '',
    this.email = '',
    this.residentialAddress = '',
    this.lagosLga = 'Ikeja',
    this.emergencyContactName = '',
    this.emergencyContactPhone = '',
    this.documents = const [],
    this.vehicleType = VehicleType.electricBike,
    this.vehiclePlate = '',
    this.vehicleModel = 'Spiro Commando EV',
    this.chassisNumber = '',
    this.batteryCapacityKwh = '3.2 kWh (Dual Swappable)',
    this.guarantor,
    this.assessmentAnswers = const {},
    this.assessmentScore = 0,
    this.trainingCompleted = false,
    this.submittedRider,
    this.isLoading = false,
    this.errorMessage,
  });

  final int currentStep;
  final String fullName;
  final String phoneNumber;
  final String email;
  final String residentialAddress;
  final String lagosLga;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final List<RiderDocumentDto> documents;
  final VehicleType vehicleType;
  final String vehiclePlate;
  final String vehicleModel;
  final String chassisNumber;
  final String batteryCapacityKwh;
  final RiderGuarantorDto? guarantor;
  final Map<int, int> assessmentAnswers;
  final int assessmentScore;
  final bool trainingCompleted;
  final RiderDto? submittedRider;
  final bool isLoading;
  final String? errorMessage;

  bool get hasRequiredDocuments {
    final types = documents.map((d) => d.type).toSet();
    return types.contains(DocumentType.nationalId) &&
        types.contains(DocumentType.driversLicense) &&
        types.contains(DocumentType.vehicleRegistration);
  }

  bool get canSubmitApplication =>
      fullName.isNotEmpty &&
      phoneNumber.isNotEmpty &&
      residentialAddress.isNotEmpty &&
      vehiclePlate.isNotEmpty &&
      guarantor != null &&
      trainingCompleted &&
      hasRequiredDocuments;

  OnboardingState copyWith({
    int? currentStep,
    String? fullName,
    String? phoneNumber,
    String? email,
    String? residentialAddress,
    String? lagosLga,
    String? emergencyContactName,
    String? emergencyContactPhone,
    List<RiderDocumentDto>? documents,
    VehicleType? vehicleType,
    String? vehiclePlate,
    String? vehicleModel,
    String? chassisNumber,
    String? batteryCapacityKwh,
    RiderGuarantorDto? guarantor,
    Map<int, int>? assessmentAnswers,
    int? assessmentScore,
    bool? trainingCompleted,
    RiderDto? submittedRider,
    bool? isLoading,
    String? errorMessage,
  }) {
    return OnboardingState(
      currentStep: currentStep ?? this.currentStep,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      residentialAddress: residentialAddress ?? this.residentialAddress,
      lagosLga: lagosLga ?? this.lagosLga,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone:
          emergencyContactPhone ?? this.emergencyContactPhone,
      documents: documents ?? this.documents,
      vehicleType: vehicleType ?? this.vehicleType,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      chassisNumber: chassisNumber ?? this.chassisNumber,
      batteryCapacityKwh: batteryCapacityKwh ?? this.batteryCapacityKwh,
      guarantor: guarantor ?? this.guarantor,
      assessmentAnswers: assessmentAnswers ?? this.assessmentAnswers,
      assessmentScore: assessmentScore ?? this.assessmentScore,
      trainingCompleted: trainingCompleted ?? this.trainingCompleted,
      submittedRider: submittedRider ?? this.submittedRider,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    currentStep,
    fullName,
    phoneNumber,
    email,
    residentialAddress,
    lagosLga,
    emergencyContactName,
    emergencyContactPhone,
    documents,
    vehicleType,
    vehiclePlate,
    vehicleModel,
    chassisNumber,
    batteryCapacityKwh,
    guarantor,
    assessmentAnswers,
    assessmentScore,
    trainingCompleted,
    submittedRider,
    isLoading,
    errorMessage,
  ];
}
