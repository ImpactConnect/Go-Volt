import 'package:app_models/app_models.dart';
import 'package:equatable/equatable.dart';

/// State of recurring scheduled pickup and school-run plans in Go-Volts customer app.
class ScheduledState extends Equatable {
  const ScheduledState({
    this.plans = const [],
    this.selectedPlan,
    this.isLoading = false,
    this.actionMessage,
    this.errorMessage,
  });

  final List<ScheduledPlanDto> plans;
  final ScheduledPlanDto? selectedPlan;
  final bool isLoading;
  final String? actionMessage;
  final String? errorMessage;

  ScheduledPlanDto? get schoolRunPlan =>
      plans.where((p) => p.isSchoolRun).firstOrNull;

  ScheduledPlanDto? get commutePlan =>
      plans.where((p) => !p.isSchoolRun).firstOrNull;

  ScheduledState copyWith({
    List<ScheduledPlanDto>? plans,
    ScheduledPlanDto? selectedPlan,
    bool? isLoading,
    String? actionMessage,
    String? errorMessage,
  }) {
    return ScheduledState(
      plans: plans ?? this.plans,
      selectedPlan: selectedPlan ?? this.selectedPlan,
      isLoading: isLoading ?? this.isLoading,
      actionMessage: actionMessage,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [plans, selectedPlan, isLoading, actionMessage, errorMessage];
}
