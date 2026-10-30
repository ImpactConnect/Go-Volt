import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/battery_swap_state.dart';

final batterySwapNotifierProvider =
    StateNotifierProvider<BatterySwapNotifier, BatterySwapState>((ref) {
  return BatterySwapNotifier();
});

/// Manages battery swapping hub availability, reservations, and locker unlocks.
class BatterySwapNotifier extends StateNotifier<BatterySwapState> {
  BatterySwapNotifier() : super(const BatterySwapState()) {
    _loadInitialStations();
  }

  void _loadInitialStations() {
    state = state.copyWith(
      stations: const [
        BatterySwapStationDto(
          id: 'st_ikeja',
          name: 'Ikeja Central Kiosk',
          address: '42 Allen Avenue, Ikeja, Lagos',
          distanceKm: 1.4,
          availablePacks: 12,
          totalSlots: 16,
        ),
        BatterySwapStationDto(
          id: 'st_vi',
          name: 'Victoria Island Solar Hub',
          address: '18 Adeola Odeku St, Victoria Island',
          distanceKm: 4.2,
          availablePacks: 9,
          totalSlots: 16,
        ),
        BatterySwapStationDto(
          id: 'st_lekki',
          name: 'Lekki Phase 1 Kiosk',
          address: 'Admiralty Way (opp. Ebeano), Lekki',
          distanceKm: 6.1,
          availablePacks: 14,
          totalSlots: 20,
        ),
        BatterySwapStationDto(
          id: 'st_yaba',
          name: 'Yaba Tech Station',
          address: 'Herbert Macaulay Way, Yaba',
          distanceKm: 8.5,
          availablePacks: 7,
          totalSlots: 12,
        ),
      ],
    );
  }

  /// Reserve a battery slot for 15 minutes at a designated station.
  bool reserveSlot(String stationId) {
    final stationIndex = state.stations.indexWhere((s) => s.id == stationId);
    if (stationIndex == -1) return false;

    final station = state.stations[stationIndex];
    if (station.availablePacks <= 0) return false;

    final updated = List<BatterySwapStationDto>.from(state.stations);
    updated[stationIndex] = BatterySwapStationDto(
      id: station.id,
      name: station.name,
      address: station.address,
      distanceKm: station.distanceKm,
      availablePacks: station.availablePacks - 1,
      totalSlots: station.totalSlots,
    );

    state = state.copyWith(
      reservedStationId: stationId,
      reservedStationName: station.name,
      reservationExpirySeconds: 900,
      stations: updated,
    );
    return true;
  }

  /// Cancel existing reservation and release slot back into the station pool.
  void cancelReservation() {
    if (state.reservedStationId == null) return;
    final stationId = state.reservedStationId!;
    final stationIndex = state.stations.indexWhere((s) => s.id == stationId);

    List<BatterySwapStationDto> updated = state.stations;
    if (stationIndex != -1) {
      final s = state.stations[stationIndex];
      updated = List<BatterySwapStationDto>.from(state.stations);
      updated[stationIndex] = BatterySwapStationDto(
        id: s.id,
        name: s.name,
        address: s.address,
        distanceKm: s.distanceKm,
        availablePacks: s.availablePacks + 1,
        totalSlots: s.totalSlots,
      );
    }

    state = BatterySwapState(
      batteryHealthPercent: state.batteryHealthPercent,
      estimatedRangeKm: state.estimatedRangeKm,
      reservedStationId: null,
      reservedStationName: null,
      stations: updated,
    );
  }

  /// Simulates scanning station QR code to unlock a fresh battery locker door.
  Future<int?> unlockLockerWithQr(String qrToken) async {
    state = state.copyWith(isLoading: true);
    await Future<void>.delayed(const Duration(milliseconds: 200));

    const lockerNum = 4;
    state = state.copyWith(
      isLoading: false,
      unlockedLockerNumber: lockerNum,
      batteryHealthPercent: 100,
      estimatedRangeKm: 85,
      reservedStationId: null,
      reservedStationName: null,
    );
    return lockerNum;
  }
}
