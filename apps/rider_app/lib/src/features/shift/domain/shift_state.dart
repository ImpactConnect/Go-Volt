import 'package:app_models/app_models.dart';
import 'package:equatable/equatable.dart';

/// State of the rider's active shift, availability, and dispatch offer pipeline.
class ShiftState extends Equatable {
  const ShiftState({
    this.rider,
    this.shift = const RiderShiftDto(
      onlineHoursToday: 5.5,
      earningsTodayKobo: 2850000,
      jobsCompletedToday: 7,
      acceptanceRatePercent: 96,
      batterySwapRecommended: false,
    ),
    this.isOnline = false,
    this.activeTier = ServiceTierEligibility.parcelDelivery,
    this.batteryLevel = 94,
    this.currentZone = 'Victoria Island / Lekki',
    this.currentOffer,
    this.activeJob,
    this.isLoading = false,
    this.errorMessage,
    this.conflictMessage,
  });

  final RiderDto? rider;
  final RiderShiftDto shift;
  final bool isOnline;
  final ServiceTierEligibility activeTier;
  final int batteryLevel;
  final String currentZone;
  final DispatchOfferDto? currentOffer;
  final DispatchOfferDto? activeJob;
  final bool isLoading;
  final String? errorMessage;
  final String? conflictMessage;

  /// Guard preventing going online if battery is too low or documents expired.
  bool get canGoOnline {
    if (batteryLevel < 15) return false;
    if (rider != null && !rider!.canGoOnline) return false;
    return true;
  }

  ShiftState copyWith({
    RiderDto? rider,
    RiderShiftDto? shift,
    bool? isOnline,
    ServiceTierEligibility? activeTier,
    int? batteryLevel,
    String? currentZone,
    DispatchOfferDto? currentOffer,
    bool clearCurrentOffer = false,
    DispatchOfferDto? activeJob,
    bool clearActiveJob = false,
    bool? isLoading,
    String? errorMessage,
    bool clearErrorMessage = false,
    String? conflictMessage,
    bool clearConflictMessage = false,
  }) {
    return ShiftState(
      rider: rider ?? this.rider,
      shift: shift ?? this.shift,
      isOnline: isOnline ?? this.isOnline,
      activeTier: activeTier ?? this.activeTier,
      batteryLevel: batteryLevel ?? this.batteryLevel,
      currentZone: currentZone ?? this.currentZone,
      currentOffer: clearCurrentOffer ? null : (currentOffer ?? this.currentOffer),
      activeJob: clearActiveJob ? null : (activeJob ?? this.activeJob),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
      conflictMessage:
          clearConflictMessage ? null : (conflictMessage ?? this.conflictMessage),
    );
  }

  @override
  List<Object?> get props => [
    rider,
    shift,
    isOnline,
    activeTier,
    batteryLevel,
    currentZone,
    currentOffer,
    activeJob,
    isLoading,
    errorMessage,
    conflictMessage,
  ];
}
