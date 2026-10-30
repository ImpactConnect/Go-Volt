import 'package:app_models/app_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/operations_state.dart';

final operationsNotifierProvider =
    StateNotifierProvider<OperationsNotifier, OperationsDashboardState>((ref) {
  return OperationsNotifier();
});

class OperationsNotifier extends StateNotifier<OperationsDashboardState> {
  OperationsNotifier() : super(const OperationsDashboardState()) {
    _loadInitialTelemetry();
  }

  void _loadInitialTelemetry() {
    state = state.copyWith(
      onlineRiders: const [
        OnlineRiderTelemetry(
          id: 'RDR-001',
          fullName: 'Babajide Ogundipe',
          vehiclePlate: 'LAG-428-EV',
          vehicleModel: 'Roam Air EV Bike',
          batteryPercent: 92,
          currentZone: 'Lekki Phase 1',
          lastHeartbeatSecondsAgo: 3,
          status: 'idle',
          rating: 4.96,
        ),
        OnlineRiderTelemetry(
          id: 'RDR-002',
          fullName: 'Emeka Nwosu',
          vehiclePlate: 'LAG-889-ET',
          vehicleModel: 'Spiro EV Trike',
          batteryPercent: 78,
          currentZone: 'Victoria Island',
          lastHeartbeatSecondsAgo: 5,
          status: 'in_transit',
          rating: 4.88,
        ),
        OnlineRiderTelemetry(
          id: 'RDR-003',
          fullName: 'Aminu Dantata',
          vehiclePlate: 'LAG-310-EV',
          vehicleModel: 'Roam Air EV Bike',
          batteryPercent: 14,
          currentZone: 'Oniru / Lekki Toll',
          lastHeartbeatSecondsAgo: 2,
          status: 'low_battery',
          rating: 4.91,
        ),
        OnlineRiderTelemetry(
          id: 'RDR-004',
          fullName: 'Tunde Adeleke',
          vehiclePlate: 'LAG-992-ET',
          vehicleModel: 'Spiro EV Trike (School Chaperone)',
          batteryPercent: 86,
          currentZone: 'Ikoyi / Parkview',
          lastHeartbeatSecondsAgo: 8,
          status: 'idle',
          rating: 5.0,
        ),
      ],
      urgentJobs: const [
        UnassignedJobAlert(
          bookingId: 'BK-GV-9021',
          reference: 'GV-BK-89021',
          serviceType: ServiceTierEligibility.schoolRunCommute,
          customerName: 'Dr. Aisha Adeleke',
          pickupAddress: 'Block 4 Admiralty Way, Lekki',
          dropoffAddress: 'Corona School, Victoria Island',
          fareKobo: 400000,
          minutesWaiting: 8,
          isOverdue: true,
        ),
        UnassignedJobAlert(
          bookingId: 'BK-GV-9022',
          reference: 'GV-BK-89022',
          serviceType: ServiceTierEligibility.parcelDelivery,
          customerName: 'Chidinma Okafor',
          pickupAddress: 'Plot 14 Admiralty Way, Lekki',
          dropoffAddress: 'Ahmadu Bello Way, VI',
          fareKobo: 300000,
          minutesWaiting: 12,
          isOverdue: true,
        ),
        UnassignedJobAlert(
          bookingId: 'BK-GV-9023',
          reference: 'GV-BK-89023',
          serviceType: ServiceTierEligibility.passengerRide,
          customerName: 'Kehinde Balogun',
          pickupAddress: 'Ozumba Mbadiwe Ave, VI',
          dropoffAddress: 'Marina Bus Stop, Lagos Island',
          fareKobo: 250000,
          minutesWaiting: 4,
          isOverdue: false,
        ),
      ],
    );
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
