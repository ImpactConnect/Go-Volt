import 'package:app_models/app_models.dart';
import 'package:equatable/equatable.dart';

/// State of a real-time live trip or delivery in Go-Volts customer app.
class LiveTrackingState extends Equatable {
  const LiveTrackingState({
    required this.booking,
    this.riderLocation,
    this.batteryPercentage = 88,
    this.etaMinutes = 3,
    this.distanceKm = 1.2,
    this.isAudioRecording = false,
    this.isEmergencyActive = false,
    this.isCancelling = false,
    this.cancellationFeeKobo = 0,
    this.disputeSubmitted = false,
    this.rating = 5.0,
    this.tipAmountKobo = 0,
    this.feedbackText,
    this.errorMessage,
  });

  final BookingDto booking;
  final LocationDto? riderLocation;
  final int batteryPercentage;
  final int etaMinutes;
  final double distanceKm;
  final bool isAudioRecording;
  final bool isEmergencyActive;
  final bool isCancelling;
  final int cancellationFeeKobo;
  final bool disputeSubmitted;
  final double rating;
  final int tipAmountKobo;
  final String? feedbackText;
  final String? errorMessage;

  BookingStatus get status => booking.status;
  bool get isAssigned => status == BookingStatus.assigned;
  bool get isArrivedAtPickup => status == BookingStatus.arrivedAtPickup;
  bool get isInProgress => status == BookingStatus.inProgress;
  bool get isCompleted => status == BookingStatus.completed;
  bool get isCancelled => status == BookingStatus.cancelled;

  LiveTrackingState copyWith({
    BookingDto? booking,
    LocationDto? riderLocation,
    int? batteryPercentage,
    int? etaMinutes,
    double? distanceKm,
    bool? isAudioRecording,
    bool? isEmergencyActive,
    bool? isCancelling,
    int? cancellationFeeKobo,
    bool? disputeSubmitted,
    double? rating,
    int? tipAmountKobo,
    String? feedbackText,
    String? errorMessage,
  }) {
    return LiveTrackingState(
      booking: booking ?? this.booking,
      riderLocation: riderLocation ?? this.riderLocation,
      batteryPercentage: batteryPercentage ?? this.batteryPercentage,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      distanceKm: distanceKm ?? this.distanceKm,
      isAudioRecording: isAudioRecording ?? this.isAudioRecording,
      isEmergencyActive: isEmergencyActive ?? this.isEmergencyActive,
      isCancelling: isCancelling ?? this.isCancelling,
      cancellationFeeKobo: cancellationFeeKobo ?? this.cancellationFeeKobo,
      disputeSubmitted: disputeSubmitted ?? this.disputeSubmitted,
      rating: rating ?? this.rating,
      tipAmountKobo: tipAmountKobo ?? this.tipAmountKobo,
      feedbackText: feedbackText ?? this.feedbackText,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        booking,
        riderLocation,
        batteryPercentage,
        etaMinutes,
        distanceKm,
        isAudioRecording,
        isEmergencyActive,
        isCancelling,
        cancellationFeeKobo,
        disputeSubmitted,
        rating,
        tipAmountKobo,
      ];
}
