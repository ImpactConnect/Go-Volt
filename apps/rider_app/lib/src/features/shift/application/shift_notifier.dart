import 'dart:async';
import 'package:app_models/app_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../onboarding/data/rider_repository.dart';
import '../domain/shift_state.dart';

final shiftNotifierProvider =
    StateNotifierProvider<ShiftNotifier, ShiftState>((ref) {
  final riderRepository = ref.watch(riderRepositoryProvider);
  return ShiftNotifier(riderRepository: riderRepository);
});

/// Manages active shift operations, availability, and live dispatch offers.
class ShiftNotifier extends StateNotifier<ShiftState> {
  ShiftNotifier({required this.riderRepository}) : super(const ShiftState()) {
    _initialize();
  }

  final RiderRepository riderRepository;
  Timer? _offerCountdownTimer;

  Future<void> _initialize() async {
    state = state.copyWith(isLoading: true);
    try {
      final rider = await riderRepository.getRiderProfile();
      final shift = await riderRepository.getShiftMetrics();
      state = state.copyWith(
        rider: rider,
        shift: shift,
        isOnline: rider.status == RiderStatus.online,
        batteryLevel: rider.batteryLevelPercent,
        currentZone: rider.activeServiceZone,
        isLoading: false,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  /// Toggle online / offline availability with battery & compliance validation.
  Future<bool> toggleAvailability() async {
    if (!state.isOnline) {
      // Trying to go online: enforce guards
      if (!state.canGoOnline) {
        state = state.copyWith(
          errorMessage: state.batteryLevel < 15
              ? 'Battery critically low (${state.batteryLevel}%). Please swap at nearest station before going online.'
              : 'Regulatory documents pending or expired. Online mode restricted.',
        );
        return false;
      }
    }

    final targetStatus =
        state.isOnline ? RiderStatus.offline : RiderStatus.online;
    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final updatedStatus = await riderRepository.updateAvailability(
        newStatus: targetStatus,
        latitude: 6.4281, // Victoria Island coords
        longitude: 3.4219,
        batteryLevel: state.batteryLevel,
      );

      state = state.copyWith(
        isOnline: updatedStatus == RiderStatus.online,
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Unable to update availability. Check internet connection.',
      );
      return false;
    }
  }

  /// Change active service tier eligibility filter.
  void setServiceTier(ServiceTierEligibility tier) {
    state = state.copyWith(activeTier: tier);
  }

  /// Set battery level (used for simulation and BMS telemetry updates).
  void updateBatteryLevel(int level) {
    state = state.copyWith(batteryLevel: level);
    if (level < 15 && state.isOnline) {
      // Force offline when battery drops below safe operating threshold
      state = state.copyWith(
        isOnline: false,
        errorMessage: 'Battery level reached critical threshold ($level%). Shift switched offline.',
      );
    }
  }

  /// Triggers or receives an incoming dispatch job offer.
  Future<void> triggerIncomingOffer({DispatchOfferDto? customOffer}) async {
    _offerCountdownTimer?.cancel();

    final offer = customOffer ??
        await riderRepository.fetchSampleDispatchOffer(tier: state.activeTier);

    state = state.copyWith(
      currentOffer: offer,
      clearConflictMessage: true,
      clearErrorMessage: true,
    );

    // Auto-countdown timer for offer expiration
    _offerCountdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.currentOffer == null) {
        timer.cancel();
        return;
      }

      if (state.currentOffer!.isExpired) {
        timer.cancel();
        state = state.copyWith(
          clearCurrentOffer: true,
          errorMessage: 'Dispatch offer timed out and was reassigned.',
        );
      }
    });
  }

  /// Accept the pending dispatch offer with 409 conflict handling.
  Future<bool> acceptOffer() async {
    final offer = state.currentOffer;
    if (offer == null) return false;

    _offerCountdownTimer?.cancel();
    state = state.copyWith(isLoading: true, clearErrorMessage: true);

    try {
      final success = await riderRepository.acceptDispatchOffer(offer.id);
      if (success) {
        state = state.copyWith(
          isLoading: false,
          activeJob: offer.copyWith(status: DispatchOfferStatus.accepted),
          clearCurrentOffer: true,
        );
        return true;
      } else {
        // Handled as 409 conflict
        state = state.copyWith(
          isLoading: false,
          clearCurrentOffer: true,
          conflictMessage: 'Offer is no longer available. Another nearby EV rider accepted.',
        );
        return false;
      }
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        clearCurrentOffer: true,
        conflictMessage: 'Offer is no longer available. Another nearby EV rider accepted.',
      );
      return false;
    }
  }

  /// Decline the active dispatch offer with structured telemetry reason.
  Future<void> declineOffer(DispatchDeclineReason reason, {String? note}) async {
    final offer = state.currentOffer;
    if (offer == null) return;

    _offerCountdownTimer?.cancel();
    await riderRepository.declineDispatchOffer(
      offerId: offer.id,
      reason: reason,
      note: note,
    );

    state = state.copyWith(
      clearCurrentOffer: true,
    );
  }

  /// Dismiss active error or conflict alert.
  void clearAlerts() {
    state = state.copyWith(
      clearErrorMessage: true,
      clearConflictMessage: true,
    );
  }

  @override
  void dispose() {
    _offerCountdownTimer?.cancel();
    super.dispose();
  }
}
