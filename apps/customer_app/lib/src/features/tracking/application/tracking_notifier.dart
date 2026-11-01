import 'package:app_models/app_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/api_providers.dart';
import '../../booking/application/booking_notifier.dart';
import '../data/tracking_repository.dart';
import '../domain/live_tracking_state.dart';

final trackingRepositoryProvider = Provider<TrackingRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return TrackingRepository(apiClient: apiClient);
});

final liveTrackingNotifierProvider =
    StateNotifierProvider<LiveTrackingNotifier, LiveTrackingState?>((ref) {
  final repository = ref.watch(trackingRepositoryProvider);
  final activeBooking = ref.watch(bookingNotifierProvider).activeBooking;
  return LiveTrackingNotifier(
    repository: repository,
    initialBooking: activeBooking,
  );
});

class LiveTrackingNotifier extends StateNotifier<LiveTrackingState?> {
  LiveTrackingNotifier({
    required TrackingRepository repository,
    BookingDto? initialBooking,
  })  : _repository = repository,
        super(
          initialBooking != null
              ? LiveTrackingState(
                  booking: initialBooking,
                  riderLocation: initialBooking.pickupLocation,
                )
              : null,
        );

  final TrackingRepository _repository;

  /// Initializes tracking with a specific booking.
  void initTracking(BookingDto booking) {
    state = LiveTrackingState(
      booking: booking,
      riderLocation: booking.pickupLocation,
      etaMinutes: 3,
      distanceKm: 1.2,
      batteryPercentage: 88,
    );
  }

  /// Advances trip status to simulate or reflect live operational updates.
  void advanceTripStatus(BookingStatus newStatus) {
    if (state == null) return;
    final currentBooking = state!.booking;
    final updatedBooking = BookingDto(
      id: currentBooking.id,
      bookingReference: currentBooking.bookingReference,
      serviceCode: currentBooking.serviceCode,
      status: newStatus,
      pickupLocation: currentBooking.pickupLocation,
      dropoffLocation: currentBooking.dropoffLocation,
      priceBreakdown: currentBooking.priceBreakdown,
      createdAt: currentBooking.createdAt,
      scheduledTime: currentBooking.scheduledTime,
      riderId: currentBooking.riderId,
      riderName: currentBooking.riderName,
      riderPhone: currentBooking.riderPhone,
      riderRating: currentBooking.riderRating,
      vehicleType: currentBooking.vehicleType,
      vehiclePlate: currentBooking.vehiclePlate,
      vehicleModel: currentBooking.vehicleModel,
      paymentMethod: currentBooking.paymentMethod,
      paymentStatus: newStatus == BookingStatus.completed
          ? PaymentStatus.captured
          : currentBooking.paymentStatus,
      packageCategory: currentBooking.packageCategory,
      packageWeightKg: currentBooking.packageWeightKg,
      recipientName: currentBooking.recipientName,
      recipientPhone: currentBooking.recipientPhone,
      instructions: currentBooking.instructions,
    );

    int newEta = state!.etaMinutes;
    double newDist = state!.distanceKm;
    if (newStatus == BookingStatus.arrivedAtPickup) {
      newEta = 0;
      newDist = 0.0;
    } else if (newStatus == BookingStatus.inProgress) {
      newEta = 18;
      newDist = 7.4;
    } else if (newStatus == BookingStatus.completed) {
      newEta = 0;
      newDist = 0.0;
    }

    state = state!.copyWith(
      booking: updatedBooking,
      etaMinutes: newEta,
      distanceKm: newDist,
    );
  }

  /// Toggles in-cabin / trip audio recording for passenger safety.
  void toggleAudioRecording() {
    if (state == null) return;
    state = state!.copyWith(
      isAudioRecording: !state!.isAudioRecording,
    );
  }

  /// Triggers emergency assistance / SOS state.
  void triggerEmergencyAlert() {
    if (state == null) return;
    state = state!.copyWith(
      isEmergencyActive: true,
      isAudioRecording: true,
    );
  }

  /// Dismisses emergency assistance modal.
  void dismissEmergencyAlert() {
    if (state == null) return;
    state = state!.copyWith(isEmergencyActive: false);
  }

  /// Cancels the trip with policy verification.
  Future<bool> cancelTrip(String reason) async {
    if (state == null) return false;
    state = state!.copyWith(isCancelling: true);
    final result = await _repository.cancelTrip(
      bookingId: state!.booking.id,
      reason: reason,
    );
    final fee = (result['fee_kobo'] as num?)?.toInt() ?? 0;
    advanceTripStatus(BookingStatus.cancelled);
    state = state!.copyWith(
      isCancelling: false,
      cancellationFeeKobo: fee,
    );
    return true;
  }

  /// Sets post-trip star rating and driver tip.
  void setTripRating(double rating, {int? tipKobo, String? feedback}) {
    if (state == null) return;
    state = state!.copyWith(
      rating: rating,
      tipAmountKobo: tipKobo ?? state!.tipAmountKobo,
      feedbackText: feedback ?? state!.feedbackText,
    );
  }

  /// Submits the final review to the backend.
  Future<bool> submitTripRating() async {
    if (state == null) return false;
    return _repository.submitTripRating(
      bookingId: state!.booking.id,
      rating: state!.rating,
      tipAmountKobo: state!.tipAmountKobo,
      feedback: state!.feedbackText,
    );
  }

  /// Submits a dispute ticket for the booking.
  Future<String> submitDispute(String category, String description) async {
    final bookingId = state?.booking.id ?? 'GV-TRK-8392';
    final caseRef = await _repository.submitDispute(
      bookingId: bookingId,
      category: category,
      description: description,
    );
    if (state != null) {
      state = state!.copyWith(disputeSubmitted: true);
    }
    return caseRef;
  }
}
