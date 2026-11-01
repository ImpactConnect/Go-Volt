import 'dart:async';
import 'package:app_models/app_models.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/scheduled_repository.dart';

class ScheduledTripsState extends Equatable {
  const ScheduledTripsState({
    this.trips = const [],
    this.selectedTrip,
    this.activeTabIndex = 0, // 0: Upcoming, 1: Completed, 2: Cancelled
    this.waitingTimeRemainingSeconds = 512, // 8m 32s (Screen 28)
    this.isLoading = false,
    this.errorMessage,
    this.actionMessage,
    this.lastSkipPreservedEntitlement,
  });

  final List<ScheduledTripDto> trips;
  final ScheduledTripDto? selectedTrip;
  final int activeTabIndex;
  final int waitingTimeRemainingSeconds;
  final bool isLoading;
  final String? errorMessage;
  final String? actionMessage;
  final bool? lastSkipPreservedEntitlement;

  List<ScheduledTripDto> get upcomingTrips => trips
      .where((t) =>
          t.status != ScheduledTripStatus.completed &&
          t.status != ScheduledTripStatus.cancelled &&
          t.status != ScheduledTripStatus.skipped)
      .toList();

  List<ScheduledTripDto> get completedTrips => trips
      .where((t) => t.status == ScheduledTripStatus.completed)
      .toList();

  List<ScheduledTripDto> get cancelledTrips => trips
      .where((t) =>
          t.status == ScheduledTripStatus.cancelled ||
          t.status == ScheduledTripStatus.skipped)
      .toList();

  String get formattedWaitingTime {
    final mins = waitingTimeRemainingSeconds ~/ 60;
    final secs = waitingTimeRemainingSeconds % 60;
    return '00:${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')} (10 mins)';
  }

  ScheduledTripsState copyWith({
    List<ScheduledTripDto>? trips,
    ScheduledTripDto? selectedTrip,
    int? activeTabIndex,
    int? waitingTimeRemainingSeconds,
    bool? isLoading,
    String? errorMessage,
    String? actionMessage,
    bool? lastSkipPreservedEntitlement,
  }) {
    return ScheduledTripsState(
      trips: trips ?? this.trips,
      selectedTrip: selectedTrip ?? this.selectedTrip,
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
      waitingTimeRemainingSeconds:
          waitingTimeRemainingSeconds ?? this.waitingTimeRemainingSeconds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      actionMessage: actionMessage,
      lastSkipPreservedEntitlement: lastSkipPreservedEntitlement,
    );
  }

  @override
  List<Object?> get props => [
        trips,
        selectedTrip,
        activeTabIndex,
        waitingTimeRemainingSeconds,
        isLoading,
        errorMessage,
        actionMessage,
      ];
}

final scheduledTripsNotifierProvider =
    StateNotifierProvider<ScheduledTripsNotifier, ScheduledTripsState>((ref) {
  final repository = ref.watch(scheduledRepositoryProvider);
  return ScheduledTripsNotifier(repository: repository)..loadTrips();
});

class ScheduledTripsNotifier extends StateNotifier<ScheduledTripsState> {
  ScheduledTripsNotifier({required ScheduledRepository repository})
      : _repository = repository,
        super(const ScheduledTripsState());

  final ScheduledRepository _repository;
  Timer? _countdownTimer;

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> loadTrips({String? planId}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repository.getUpcomingTrips(planId: planId);
      state = state.copyWith(
        trips: list,
        selectedTrip: list.isNotEmpty ? list.first : null,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to load trips: ${e.toString()}',
      );
    }
  }

  void selectTrip(ScheduledTripDto trip) {
    state = state.copyWith(selectedTrip: trip);
    if (trip.status == ScheduledTripStatus.arrivedAtPickup) {
      _startWaitingCountdown();
    }
  }

  void setActiveTab(int index) {
    state = state.copyWith(activeTabIndex: index);
  }

  void _startWaitingCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (state.waitingTimeRemainingSeconds > 0) {
        state = state.copyWith(
          waitingTimeRemainingSeconds: state.waitingTimeRemainingSeconds - 1,
        );
      } else {
        timer.cancel();
      }
    });
  }

  /// Advances trip lifecycle state for interactive demonstrations (Screens 26 to 31).
  void advanceTripStatus(ScheduledTripStatus nextStatus) {
    final trip = state.selectedTrip;
    if (trip == null) return;

    final updated = trip.copyWith(status: nextStatus);
    final updatedList =
        state.trips.map((t) => t.id == trip.id ? updated : t).toList();

    state = state.copyWith(
      trips: updatedList,
      selectedTrip: updated,
    );

    if (nextStatus == ScheduledTripStatus.arrivedAtPickup) {
      _startWaitingCountdown();
    }
  }

  /// Skips a trip, calculating whether entitlement is preserved per Section 21 6h cutoff rule.
  Future<bool> skipTrip(String tripId) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final result = await _repository.skipScheduledTrip(tripId: tripId);
      final preserved = result['entitlement_preserved'] as bool? ?? false;
      final msg = result['message'] as String? ?? 'Trip skipped.';

      final updatedList = state.trips.map((t) {
        if (t.id == tripId) {
          return t.copyWith(
            status: ScheduledTripStatus.skipped,
            skipReason: 'Customer skipped',
          );
        }
        return t;
      }).toList();

      state = state.copyWith(
        trips: updatedList,
        isLoading: false,
        actionMessage: msg,
        lastSkipPreservedEntitlement: preserved,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to skip trip: ${e.toString()}',
      );
      return false;
    }
  }

  /// Verifies school run 4-digit PIN handover (Screens 33–34).
  Future<bool> verifyHandover({
    required String tripId,
    required String pin,
    required String recipientName,
    required String recipientRole,
  }) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final success = await _repository.verifyHandoverPin(
        tripId: tripId,
        pin: pin,
        recipientName: recipientName,
        recipientRole: recipientRole,
      );

      if (success) {
        final updatedList = state.trips.map((t) {
          if (t.id == tripId) {
            return t.copyWith(
              status: ScheduledTripStatus.completed,
              handoverStatus: HandoverStatus.verified,
              handoverRecipientName: recipientName,
              handoverRecipientRole: recipientRole,
              handoverConfirmedAt: DateTime.now(),
            );
          }
          return t;
        }).toList();

        final updatedTrip =
            updatedList.firstWhere((t) => t.id == tripId);

        state = state.copyWith(
          trips: updatedList,
          selectedTrip: updatedTrip,
          isLoading: false,
          actionMessage: 'Handover verified and trip completed successfully.',
        );
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Invalid verification code. Please check with recipient.',
        );
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Handover verification error: ${e.toString()}',
      );
      return false;
    }
  }

  /// Submits an issue report for a trip (Screen 35).
  Future<bool> reportIssue({
    required String tripId,
    required TripIssueType issueType,
    String? notes,
  }) async {
    try {
      await _repository.reportTripIssue(
        tripId: tripId,
        issueType: issueType,
        notes: notes,
      );
      state = state.copyWith(
        actionMessage: 'Incident report received. Support will review shortly.',
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}

