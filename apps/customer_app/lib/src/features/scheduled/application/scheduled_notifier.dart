import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/scheduled_repository.dart';
import '../domain/scheduled_state.dart';
import 'package:app_models/app_models.dart';

// scheduledRepositoryProvider is imported from data/scheduled_repository.dart

final scheduledNotifierProvider =
    StateNotifierProvider<ScheduledNotifier, ScheduledState>((ref) {
  final repository = ref.watch(scheduledRepositoryProvider);
  return ScheduledNotifier(repository: repository);
});

class ScheduledNotifier extends StateNotifier<ScheduledState> {
  ScheduledNotifier({required ScheduledRepository repository})
      : _repository = repository,
        super(const ScheduledState()) {
    loadPlans();
  }

  final ScheduledRepository _repository;

  /// Loads recurring commute and school-run plans.
  Future<void> loadPlans() async {
    state = state.copyWith(isLoading: true);
    final plans = await _repository.getCustomerPlans();
    state = state.copyWith(
      plans: plans,
      selectedPlan: plans.firstOrNull,
      isLoading: false,
    );
  }

  /// Sets the currently inspected plan.
  void selectPlan(ScheduledPlanDto plan) {
    state = state.copyWith(selectedPlan: plan);
  }

  /// Skips the next scheduled trip and applies 6-hour policy cutoff.
  Future<Map<String, dynamic>> skipNextTrip(
    String planId,
    DateTime tripTime,
  ) async {
    state = state.copyWith(isLoading: true);
    final result = await _repository.skipScheduledTrip(
      planId: planId,
      tripTime: tripTime,
    );
    final preserved = result['entitlement_preserved'] as bool? ?? true;

    // Update locally
    final updatedPlans = state.plans.map((p) {
      if (p.id == planId) {
        final remaining = preserved ? p.remainingTrips : p.remainingTrips - 1;
        return p.copyWith(
          remainingTrips: remaining,
          usedTrips: preserved ? p.usedTrips : p.usedTrips + 1,
        );
      }
      return p;
    }).toList();

    state = state.copyWith(
      plans: updatedPlans,
      selectedPlan: updatedPlans.firstWhere((p) => p.id == planId),
      isLoading: false,
      actionMessage: result['message'] as String? ??
          (preserved
              ? 'Trip skipped. Your entitlement has been preserved.'
              : 'Trip skipped after cutoff. Entitlement was forfeited.'),
    );

    return result;
  }

  /// Refreshes/generates a new handover OTP.
  Future<void> refreshHandoverOtp(String planId) async {
    final otp = await _repository.refreshHandoverOtp(planId);
    final updatedPlans = state.plans.map((p) {
      if (p.id == planId) {
        return p.copyWith(
          handoverOtp: otp,
          handoverOtpExpiresAt: DateTime.now().add(const Duration(minutes: 45)),
        );
      }
      return p;
    }).toList();

    state = state.copyWith(
      plans: updatedPlans,
      selectedPlan: updatedPlans.firstWhere((p) => p.id == planId),
    );
  }

  /// Pauses or resumes a plan subscription.
  Future<void> togglePlanPause(ScheduledPlanDto plan) async {
    state = state.copyWith(isLoading: true);
    final updated = await _repository.togglePlanPause(plan);
    final updatedPlans = state.plans.map((p) {
      return p.id == updated.id ? updated : p;
    }).toList();

    state = state.copyWith(
      plans: updatedPlans,
      selectedPlan: updated,
      isLoading: false,
      actionMessage: updated.isPaused
          ? 'Subscription paused. Upcoming trips temporarily suspended.'
          : 'Subscription resumed! Trips active.',
    );
  }
}
