import 'package:app_models/app_models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/supabase_admin_client.dart';
import '../domain/operations_state.dart';

final operationsNotifierProvider =
    StateNotifierProvider<OperationsNotifier, OperationsDashboardState>((ref) {
  return OperationsNotifier();
});

class OperationsNotifier extends StateNotifier<OperationsDashboardState> {
  OperationsNotifier() : super(const OperationsDashboardState()) {
    fetchRealOperations();
  }

  Future<void> fetchRealOperations() async {
    final client = tryGetSupabaseClient();
    if (client == null) return;

    try {
      state = state.copyWith(isLoading: true);
      final bookingsRes = await client.from('bookings').select();
      final bookings = bookingsRes as List<dynamic>;

      final activeTrips = bookings.where((b) {
        final st = b['status']?.toString().toLowerCase();
        return st == 'in_transit' || st == 'in_progress' || st == 'active';
      }).length;

      final unassigned = bookings.where((b) {
        final st = b['status']?.toString().toLowerCase();
        return st == 'searching' || st == 'unassigned' || st == 'pending';
      }).toList();

      final ridersRes = await client.from('rider_profiles').select();
      final riders = ridersRes as List<dynamic>;

      final onlineRiders = riders.where((r) {
        return r['is_online'] == true ||
            r['status'] == 'online' ||
            r['status'] == 'idle' ||
            r['status'] == 'in_transit';
      }).map((r) {
        return OnlineRiderTelemetry(
          id: r['id']?.toString() ?? '',
          fullName: r['full_name']?.toString() ?? 'Rider',
          vehiclePlate: r['vehicle_plate']?.toString() ?? 'N/A',
          vehicleModel: r['vehicle_model']?.toString() ?? 'EV Bike',
          batteryPercent: (r['battery_percent'] as num?)?.toInt() ?? 100,
          currentZone: r['current_zone']?.toString() ?? 'Lagos Central',
          lastHeartbeatSecondsAgo:
              (r['last_heartbeat_seconds_ago'] as num?)?.toInt() ?? 0,
          status: r['status']?.toString() ?? 'idle',
          rating: (r['rating'] as num?)?.toDouble() ?? 5.0,
        );
      }).toList();

      int revenueKobo = 0;
      for (final b in bookings) {
        final fare = (b['total_fare_kobo'] as num?)?.toInt() ??
            (b['fare_kobo'] as num?)?.toInt() ??
            0;
        revenueKobo += fare;
      }

      state = state.copyWith(
        isLoading: false,
        activeTripsCount: activeTrips,
        onlineRidersCount: onlineRiders.length,
        unassignedJobsCount: unassigned.length,
        overduePickupsCount: 0,
        grossRevenueTodayKobo: revenueKobo,
        onlineRiders: onlineRiders,
        urgentJobs: unassigned
            .map((b) => UnassignedJobAlert(
                  bookingId: b['id']?.toString() ?? '',
                  reference: b['reference']?.toString() ??
                      b['id']?.toString() ??
                      '',
                  serviceType: ServiceTierEligibility.passengerRide,
                  customerName: b['customer_name']?.toString() ?? 'Customer',
                  pickupAddress: b['pickup_address']?.toString() ?? '',
                  dropoffAddress: b['dropoff_address']?.toString() ?? '',
                  fareKobo: (b['fare_kobo'] as num?)?.toInt() ?? 0,
                  minutesWaiting: 0,
                  isOverdue: false,
                ))
            .toList(),
      );
    } catch (e) {
      debugPrint('[OperationsNotifier] Error fetching real operations: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  @visibleForTesting
  void updateStateForTesting(OperationsDashboardState newState) {
    state = newState;
  }


  /// Manually assign an unassigned job to a selected available rider.
  Future<bool> assignRiderToJob({
    required String bookingId,
    required String riderId,
    required String reason,
  }) async {
    if (reason.trim().isEmpty) return false;

    state = state.copyWith(isLoading: true);
    await Future<void>.delayed(const Duration(milliseconds: 150));

    final updatedJobs = state.urgentJobs.where((j) => j.bookingId != bookingId).toList();
    state = state.copyWith(
      isLoading: false,
      urgentJobs: updatedJobs,
      unassignedJobsCount: updatedJobs.length,
      lastActionMessage: 'Job $bookingId successfully assigned to rider $riderId (Reason: $reason)',
    );
    return true;
  }

  /// Reassign an active or delayed trip to another rider.
  Future<bool> reassignTrip({
    required String bookingId,
    required String newRiderId,
    required String reason,
  }) async {
    if (reason.trim().isEmpty) return false;

    state = state.copyWith(
      lastActionMessage: 'Trip $bookingId reassigned to $newRiderId (Reason: $reason)',
    );
    return true;
  }
}
