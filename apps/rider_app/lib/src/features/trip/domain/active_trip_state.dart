import 'package:app_models/app_models.dart';
import 'package:equatable/equatable.dart';

/// Active trip milestone stages from dispatch acceptance to fare settlement.
enum TripMilestone {
  approachingPickup('APPROACHING_PICKUP', 'Approaching Pickup'),
  arrivedAtPickup('ARRIVED_PICKUP', 'Arrived at Pickup'),
  otpVerified('OTP_VERIFIED', 'Handover Verified'),
  inTransit('IN_TRANSIT', 'In Transit to Destination'),
  arrivedAtDestination('ARRIVED_DESTINATION', 'Arrived at Destination'),
  proofSubmitted('PROOF_SUBMITTED', 'Proof of Delivery Captured'),
  completed('COMPLETED', 'Trip Completed');

  const TripMilestone(this.code, this.label);
  final String code;
  final String label;
}

/// Final fare breakdown and platform commission settlement.
class FareSettlementDto extends Equatable {
  const FareSettlementDto({
    required this.grossFareKobo,
    required this.commissionKobo,
    required this.netEarningsKobo,
    this.tipKobo = 0,
    required this.totalCreditKobo,
    this.paymentMethod = 'Wallet',
    required this.settledAt,
  });

  factory FareSettlementDto.fromGrossAndTip({
    required int grossKobo,
    int tipKobo = 0,
    String paymentMethod = 'Wallet',
  }) {
    final commission = (grossKobo * 0.20).round();
    final net = grossKobo - commission;
    final total = net + tipKobo;
    return FareSettlementDto(
      grossFareKobo: grossKobo,
      commissionKobo: commission,
      netEarningsKobo: net,
      tipKobo: tipKobo,
      totalCreditKobo: total,
      paymentMethod: paymentMethod,
      settledAt: DateTime.now(),
    );
  }

  final int grossFareKobo;
  final int commissionKobo;
  final int netEarningsKobo;
  final int tipKobo;
  final int totalCreditKobo;
  final String paymentMethod;
  final DateTime settledAt;

  double get grossFareNaira => grossFareKobo / 100.0;
  double get commissionNaira => commissionKobo / 100.0;
  double get netEarningsNaira => netEarningsKobo / 100.0;
  double get tipNaira => tipKobo / 100.0;
  double get totalCreditNaira => totalCreditKobo / 100.0;

  @override
  List<Object?> get props => [
    grossFareKobo,
    commissionKobo,
    netEarningsKobo,
    tipKobo,
    totalCreditKobo,
    paymentMethod,
    settledAt,
  ];
}

/// State of an in-progress trip, telemetry, and proof-of-delivery workflow.
class ActiveTripState extends Equatable {
  const ActiveTripState({
    required this.job,
    this.milestone = TripMilestone.approachingPickup,
    this.currentLat = 6.4281,
    this.currentLng = 3.4219,
    this.distanceRemainingKm = 1.2,
    this.etaMinutes = 4,
    this.speedKmh = 36.0,
    this.speedLimitKmh = 45.0,
    this.otpAttemptsRemaining = 3,
    this.otpError,
    this.deliveryPhotoPath,
    this.recipientName,
    this.recipientSignature,
    this.exceptionReported,
    this.settlement,
    this.isLoading = false,
    this.errorMessage,
  });

  final DispatchOfferDto job;
  final TripMilestone milestone;
  final double currentLat;
  final double currentLng;
  final double distanceRemainingKm;
  final int etaMinutes;
  final double speedKmh;
  final double speedLimitKmh;
  final int otpAttemptsRemaining;
  final String? otpError;
  final String? deliveryPhotoPath;
  final String? recipientName;
  final String? recipientSignature;
  final String? exceptionReported;
  final FareSettlementDto? settlement;
  final bool isLoading;
  final String? errorMessage;

  bool get isSpeeding => speedKmh > speedLimitKmh;

  bool get isSchoolRun => job.serviceType == ServiceTierEligibility.schoolRunCommute;
  bool get isDelivery => job.serviceType == ServiceTierEligibility.parcelDelivery;
  bool get isRide => job.serviceType == ServiceTierEligibility.passengerRide;

  ActiveTripState copyWith({
    DispatchOfferDto? job,
    TripMilestone? milestone,
    double? currentLat,
    double? currentLng,
    double? distanceRemainingKm,
    int? etaMinutes,
    double? speedKmh,
    double? speedLimitKmh,
    int? otpAttemptsRemaining,
    String? otpError,
    bool clearOtpError = false,
    String? deliveryPhotoPath,
    String? recipientName,
    String? recipientSignature,
    String? exceptionReported,
    FareSettlementDto? settlement,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return ActiveTripState(
      job: job ?? this.job,
      milestone: milestone ?? this.milestone,
      currentLat: currentLat ?? this.currentLat,
      currentLng: currentLng ?? this.currentLng,
      distanceRemainingKm: distanceRemainingKm ?? this.distanceRemainingKm,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      speedKmh: speedKmh ?? this.speedKmh,
      speedLimitKmh: speedLimitKmh ?? this.speedLimitKmh,
      otpAttemptsRemaining: otpAttemptsRemaining ?? this.otpAttemptsRemaining,
      otpError: clearOtpError ? null : (otpError ?? this.otpError),
      deliveryPhotoPath: deliveryPhotoPath ?? this.deliveryPhotoPath,
      recipientName: recipientName ?? this.recipientName,
      recipientSignature: recipientSignature ?? this.recipientSignature,
      exceptionReported: exceptionReported ?? this.exceptionReported,
      settlement: settlement ?? this.settlement,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    job,
    milestone,
    currentLat,
    currentLng,
    distanceRemainingKm,
    etaMinutes,
    speedKmh,
    speedLimitKmh,
    otpAttemptsRemaining,
    otpError,
    deliveryPhotoPath,
    recipientName,
    recipientSignature,
    exceptionReported,
    settlement,
    isLoading,
    errorMessage,
  ];
}
