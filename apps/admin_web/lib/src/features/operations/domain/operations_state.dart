import 'package:app_models/app_models.dart';

class OnlineRiderTelemetry {
  const OnlineRiderTelemetry({
    required this.id,
    required this.fullName,
    required this.vehiclePlate,
    required this.vehicleModel,
    required this.batteryPercent,
    required this.currentZone,
    required this.lastHeartbeatSecondsAgo,
    required this.status,
    required this.rating,
  });

  final String id;
  final String fullName;
  final String vehiclePlate;
  final String vehicleModel;
  final int batteryPercent;
  final String currentZone;
  final int lastHeartbeatSecondsAgo;
  final String status; // 'idle', 'in_transit', 'low_battery'
  final double rating;

  bool get isBatteryCritical => batteryPercent < 15;
}

class UnassignedJobAlert {
  const UnassignedJobAlert({
    required this.bookingId,
    required this.reference,
    required this.serviceType,
    required this.customerName,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.fareKobo,
    required this.minutesWaiting,
    required this.isOverdue,
  });

  final String bookingId;
  final String reference;
  final ServiceTierEligibility serviceType;
  final String customerName;
  final String pickupAddress;
  final String dropoffAddress;
  final int fareKobo;
  final int minutesWaiting;
  final bool isOverdue;

  double get fareNaira => fareKobo / 100.0;
}

class OperationsDashboardState {
  const OperationsDashboardState({
    this.activeTripsCount = 0,
    this.onlineRidersCount = 0,
    this.unassignedJobsCount = 0,
    this.overduePickupsCount = 0,
    this.avgResponseTimeMins = 0.0,
    this.grossRevenueTodayKobo = 0,
    this.surgeMultiplier = 1.0,
    this.activeZone = 'Lagos Central',
    this.onlineRiders = const [],
    this.urgentJobs = const [],
    this.isLoading = false,
    this.lastActionMessage,
  });

  final int activeTripsCount;
  final int onlineRidersCount;
  final int unassignedJobsCount;
  final int overduePickupsCount;
  final double avgResponseTimeMins;
  final int grossRevenueTodayKobo;
  final double surgeMultiplier;
  final String activeZone;
  final List<OnlineRiderTelemetry> onlineRiders;
  final List<UnassignedJobAlert> urgentJobs;
  final bool isLoading;
  final String? lastActionMessage;

  double get grossRevenueNaira => grossRevenueTodayKobo / 100.0;

  OperationsDashboardState copyWith({
    int? activeTripsCount,
    int? onlineRidersCount,
    int? unassignedJobsCount,
    int? overduePickupsCount,
    double? avgResponseTimeMins,
    int? grossRevenueTodayKobo,
    double? surgeMultiplier,
    String? activeZone,
    List<OnlineRiderTelemetry>? onlineRiders,
    List<UnassignedJobAlert>? urgentJobs,
    bool? isLoading,
    String? lastActionMessage,
  }) {
    return OperationsDashboardState(
      activeTripsCount: activeTripsCount ?? this.activeTripsCount,
      onlineRidersCount: onlineRidersCount ?? this.onlineRidersCount,
      unassignedJobsCount: unassignedJobsCount ?? this.unassignedJobsCount,
      overduePickupsCount: overduePickupsCount ?? this.overduePickupsCount,
      avgResponseTimeMins: avgResponseTimeMins ?? this.avgResponseTimeMins,
      grossRevenueTodayKobo: grossRevenueTodayKobo ?? this.grossRevenueTodayKobo,
      surgeMultiplier: surgeMultiplier ?? this.surgeMultiplier,
      activeZone: activeZone ?? this.activeZone,
      onlineRiders: onlineRiders ?? this.onlineRiders,
      urgentJobs: urgentJobs ?? this.urgentJobs,
      isLoading: isLoading ?? this.isLoading,
      lastActionMessage: lastActionMessage ?? this.lastActionMessage,
    );
  }
}
