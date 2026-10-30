import 'package:app_models/app_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/trip_repository.dart';
import '../domain/active_trip_state.dart';

final activeTripNotifierProvider = StateNotifierProvider.family<
    ActiveTripNotifier, ActiveTripState, DispatchOfferDto>((ref, job) {
  final tripRepo = ref.watch(tripRepositoryProvider);
  return ActiveTripNotifier(job: job, tripRepository: tripRepo);
});

/// Controls the lifecycle, verification milestones, and telematics of an active trip.
class ActiveTripNotifier extends StateNotifier<ActiveTripState> {
  ActiveTripNotifier({
    required DispatchOfferDto job,
    required this.tripRepository,
  }) : super(ActiveTripState(job: job));

  final TripRepository tripRepository;

  /// Rider arrived at pickup location pin.
  Future<void> markArrivedAtPickup() async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    await tripRepository.markArrivedAtPickup(state.job.jobId);
    state = state.copyWith(
      isLoading: false,
      milestone: TripMilestone.arrivedAtPickup,
      distanceRemainingKm: 0.0,
      etaMinutes: 0,
    );
  }

  /// Verify passenger commute OTP (4 digits) or School-Run / delivery OTP (6 digits).
  Future<bool> verifyOtp(String otp) async {
    if (state.otpAttemptsRemaining <= 0) {
      state = state.copyWith(
        otpError: 'Maximum OTP attempts exceeded. Please contact Go-Volts Dispatch Support.',
      );
      return false;
    }

    state = state.copyWith(isLoading: true, clearOtpError: true);
    final isValid = await tripRepository.verifyOtp(state.job.jobId, otp);

    if (isValid) {
      state = state.copyWith(
        isLoading: false,
        milestone: TripMilestone.otpVerified,
        clearOtpError: true,
      );
      return true;
    } else {
      final remaining = state.otpAttemptsRemaining - 1;
      state = state.copyWith(
        isLoading: false,
        otpAttemptsRemaining: remaining,
        otpError: remaining > 0
            ? 'Incorrect OTP code. $remaining attempt${remaining > 1 ? 's' : ''} remaining.'
            : 'Maximum OTP attempts exceeded. Please contact Go-Volts Dispatch Support.',
      );
      return false;
    }
  }

  /// Start transit to destination waypoint.
  Future<void> startTransit() async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    await tripRepository.startTransit(state.job.jobId);
    state = state.copyWith(
      isLoading: false,
      milestone: TripMilestone.inTransit,
      distanceRemainingKm: state.job.tripDistanceKm,
      etaMinutes: state.job.estimatedTripMinutes,
    );
  }

  /// Rider arrived at dropoff destination pin.
  Future<void> markArrivedAtDestination() async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    await tripRepository.markArrivedAtDestination(state.job.jobId);
    state = state.copyWith(
      isLoading: false,
      milestone: TripMilestone.arrivedAtDestination,
      distanceRemainingKm: 0.0,
      etaMinutes: 0,
    );
  }

  /// Submit digital proof of delivery.
  Future<bool> submitProofOfDelivery({
    required String photoUrl,
    required String recipientName,
    required String signature,
  }) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    final success = await tripRepository.submitProofOfDelivery(
      jobId: state.job.jobId,
      photoUrl: photoUrl,
      recipientName: recipientName,
      signature: signature,
    );

    if (success) {
      state = state.copyWith(
        isLoading: false,
        deliveryPhotoPath: photoUrl,
        recipientName: recipientName,
        recipientSignature: signature,
        milestone: TripMilestone.proofSubmitted,
      );
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to upload proof of delivery. Please retry.',
      );
      return false;
    }
  }

  /// File delivery exception.
  Future<void> reportException(String reason, {String? notes}) async {
    state = state.copyWith(isLoading: true);
    await tripRepository.reportException(
      jobId: state.job.jobId,
      reason: reason,
      notes: notes,
    );
    state = state.copyWith(
      isLoading: false,
      exceptionReported: reason,
    );
  }

  /// Complete trip, trigger financial escrow settlement, and transition to summary screen.
  Future<void> completeTrip({int tipKobo = 0}) async {
    state = state.copyWith(isLoading: true, clearErrorMessage: true);
    final settlement = await tripRepository.completeAndSettleTrip(
      jobId: state.job.jobId,
      grossFareKobo: state.job.grossFareKobo,
      tipKobo: tipKobo,
      paymentMethod: state.job.paymentMethod,
    );

    state = state.copyWith(
      isLoading: false,
      milestone: TripMilestone.completed,
      settlement: settlement,
    );
  }
}
