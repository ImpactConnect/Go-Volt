import 'package:app_models/app_models.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/scheduled_repository.dart';

class ScheduledPlansState extends Equatable {
  const ScheduledPlansState({
    this.plans = const [],
    this.selectedPlan,
    this.activeTabIndex = 0,
    this.isLoading = false,
    this.errorMessage,
    this.actionSuccessMessage,
  });

  final List<ScheduledPlanDto> plans;
  final ScheduledPlanDto? selectedPlan;
  final int activeTabIndex; // 0: Active, 1: Upcoming, 2: Past
  final bool isLoading;
  final String? errorMessage;
  final String? actionSuccessMessage;

  List<ScheduledPlanDto> get activePlans =>
      plans.where((p) => p.status == PlanStatus.active).toList();

  List<ScheduledPlanDto> get upcomingPlans => plans
      .where((p) =>
          p.status == PlanStatus.approvedAwaitingPayment ||
          p.status == PlanStatus.pendingReview)
      .toList();

  List<ScheduledPlanDto> get pastPlans => plans
      .where((p) =>
          p.status == PlanStatus.expired ||
          p.status == PlanStatus.cancelled ||
          p.status == PlanStatus.rejected)
      .toList();

  ScheduledPlansState copyWith({
    List<ScheduledPlanDto>? plans,
    ScheduledPlanDto? selectedPlan,
    int? activeTabIndex,
    bool? isLoading,
    String? errorMessage,
    String? actionSuccessMessage,
  }) {
    return ScheduledPlansState(
      plans: plans ?? this.plans,
      selectedPlan: selectedPlan ?? this.selectedPlan,
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      actionSuccessMessage: actionSuccessMessage,
    );
  }

  @override
  List<Object?> get props => [
        plans,
        selectedPlan,
        activeTabIndex,
        isLoading,
        errorMessage,
        actionSuccessMessage,
      ];
}

final scheduledPlansNotifierProvider =
    StateNotifierProvider<ScheduledPlansNotifier, ScheduledPlansState>((ref) {
  final repository = ref.watch(scheduledRepositoryProvider);
  return ScheduledPlansNotifier(repository: repository)..loadPlans();
});

class ScheduledPlansNotifier extends StateNotifier<ScheduledPlansState> {
  ScheduledPlansNotifier({required ScheduledRepository repository})
      : _repository = repository,
        super(const ScheduledPlansState());

  final ScheduledRepository _repository;

  Future<void> loadPlans() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repository.getCustomerPlans();
      state = state.copyWith(
        plans: list,
        selectedPlan: list.isNotEmpty ? list.first : null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load plans: ${e.toString()}',
      );
    }
  }

  void selectPlan(ScheduledPlanDto plan) {
    state = state.copyWith(selectedPlan: plan);
  }

  void setActiveTab(int index) {
    state = state.copyWith(activeTabIndex: index);
  }

  /// Simulates operational approval for testing review pipeline (Screen 14 -> 15).
  Future<ScheduledPlanDto?> simulateApproval(String planId) async {
    try {
      final updated = await _repository.approvePlan(planId);
      final updatedList = state.plans.map((p) => p.id == planId ? updated : p).toList();
      state = state.copyWith(
        plans: updatedList,
        selectedPlan: updated,
      );
      return updated;
    } catch (_) {
      return null;
    }
  }

  /// Processes payment for plan and transitions to Active (Screens 16–17).
  Future<bool> payForPlan({
    required String planId,
    required String paymentMethod,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final updated = await _repository.payForPlan(
        planId: planId,
        paymentMethod: paymentMethod,
      );
      final updatedList = state.plans.map((p) => p.id == planId ? updated : p).toList();
      state = state.copyWith(
        plans: updatedList,
        selectedPlan: updated,
        isLoading: false,
        actionSuccessMessage: 'Plan payment completed successfully!',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Payment failed: ${e.toString()}',
      );
      return false;
    }
  }

  /// Pauses active plan (Screen 23).
  Future<bool> pausePlan({
    required String planId,
    required DateTime effectiveDate,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final updated = await _repository.pausePlan(
        planId: planId,
        effectiveDate: effectiveDate,
      );
      final updatedList = state.plans.map((p) => p.id == planId ? updated : p).toList();
      state = state.copyWith(
        plans: updatedList,
        selectedPlan: updated,
        isLoading: false,
        actionSuccessMessage: 'Plan paused effective from requested date.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to pause plan: ${e.toString()}',
      );
      return false;
    }
  }

  /// Cancels plan (Screen 21).
  Future<bool> cancelPlan({
    required String planId,
    required String reason,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final updated = await _repository.cancelPlan(
        planId: planId,
        reason: reason,
      );
      final updatedList = state.plans.map((p) => p.id == planId ? updated : p).toList();
      state = state.copyWith(
        plans: updatedList,
        selectedPlan: updated,
        isLoading: false,
        actionSuccessMessage: 'Plan cancelled.',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to cancel plan: ${e.toString()}',
      );
      return false;
    }
  }
}

