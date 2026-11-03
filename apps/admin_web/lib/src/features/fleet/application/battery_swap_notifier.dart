import 'package:app_models/app_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/battery_swap_models.dart';

class BatterySwapState {
  const BatterySwapState({
    this.stations = const [],
    this.selectedStatus,
    this.searchQuery = '',
    this.actionMessage,
    this.isLoading = false,
  });

  final List<BatterySwapStationModel> stations;
  final String? selectedStatus;
  final String searchQuery;
  final String? actionMessage;
  final bool isLoading;

  int get totalStationsCount => stations.length;

  int get totalChargedPacks => stations.fold<int>(
        0,
        (sum, s) => sum + s.chargedPacksAvailable,
      );

  int get totalChargingPacks => stations.fold<int>(
        0,
        (sum, s) => sum + s.chargingPacks,
      );

  int get totalQuarantinedPacks => stations.fold<int>(
        0,
        (sum, s) => sum + s.quarantinedPacks,
      );

  int get totalDailySwaps => stations.fold<int>(
        0,
        (sum, s) => sum + s.dailySwapCount,
      );

  List<BatterySwapStationModel> get filteredStations {
    return stations.where((s) {
      if (selectedStatus != null && s.status != selectedStatus) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final matchName = s.name.toLowerCase().contains(q);
        final matchAddress = s.address.toLowerCase().contains(q);
        if (!matchName && !matchAddress) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  BatterySwapState copyWith({
    List<BatterySwapStationModel>? stations,
    String? selectedStatus,
    bool clearSelectedStatus = false,
    String? searchQuery,
    String? actionMessage,
    bool clearActionMessage = false,
    bool? isLoading,
  }) {
    return BatterySwapState(
      stations: stations ?? this.stations,
      selectedStatus:
          clearSelectedStatus ? null : (selectedStatus ?? this.selectedStatus),
      searchQuery: searchQuery ?? this.searchQuery,
      actionMessage: clearActionMessage
          ? null
          : (actionMessage ?? this.actionMessage),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class BatterySwapNotifier extends StateNotifier<BatterySwapState> {
  BatterySwapNotifier() : super(const BatterySwapState()) {
    _loadSeedData();
  }

  void _loadSeedData() {
    List<BatteryBayModel> generateBays({
      required int chargedCount,
      required int chargingCount,
      int quarantinedCount = 0,
      String? quarantineReason,
    }) {
      final bays = <BatteryBayModel>[];
      var currentBay = 1;

      // Charged bays
      for (int i = 0; i < chargedCount; i++) {
        bays.add(BatteryBayModel(
          bayNumber: currentBay,
          batterySerial: 'BAT-EV-${currentBay.toString().padLeft(4, '0')}',
          socPercent: 92 + (i % 8),
          sohHealthPercent: 96,
          temperatureCelsius: 27.5,
          isCharging: false,
          isQuarantined: false,
          isLocked: true,
        ));
        currentBay++;
      }

      // Charging bays
      for (int i = 0; i < chargingCount; i++) {
        bays.add(BatteryBayModel(
          bayNumber: currentBay,
          batterySerial: 'BAT-EV-${currentBay.toString().padLeft(4, '0')}',
          socPercent: 35 + (i * 4),
          sohHealthPercent: 94,
          temperatureCelsius: 32.0,
          isCharging: true,
          isQuarantined: false,
          isLocked: true,
        ));
        currentBay++;
      }

      // Quarantined bays
      for (int i = 0; i < quarantinedCount; i++) {
        bays.add(BatteryBayModel(
          bayNumber: currentBay,
          batterySerial: 'BAT-EV-${currentBay.toString().padLeft(4, '0')}',
          socPercent: 48,
          sohHealthPercent: 68,
          temperatureCelsius: 44.5,
          isCharging: false,
          isQuarantined: true,
          quarantineReason: quarantineReason ?? 'Thermal Runaway Warning (>44°C cell temperature)',
          isLocked: true,
        ));
        currentBay++;
      }

      // Remaining empty or standby bays up to 24
      while (currentBay <= 24) {
        bays.add(BatteryBayModel(
          bayNumber: currentBay,
          batterySerial: 'BAT-EV-${currentBay.toString().padLeft(4, '0')}',
          socPercent: 90,
          sohHealthPercent: 95,
          temperatureCelsius: 28.0,
          isCharging: false,
          isQuarantined: false,
          isLocked: true,
        ));
        currentBay++;
      }

      return bays;
    }

    // Station 1: Victoria Island Central
    final stn1 = BatterySwapStationModel(
      id: 'STN-01',
      name: 'Victoria Island Central Swap Hub',
      address: 'Ahmadu Bello Way / Adeola Odeku, VI, Lagos',
      location: const LocationDto(
        latitude: 6.4281,
        longitude: 3.4219,
        address: 'Ahmadu Bello Way / Adeola Odeku, VI, Lagos',
      ),
      totalCabinetBays: 24,
      powerSource: 'Solar PV + Grid Active',
      temperatureCelsius: 28.2,
      dailySwapCount: 184,
      status: 'OPERATIONAL',
      bays: generateBays(
        chargedCount: 16,
        chargingCount: 7,
        quarantinedCount: 1,
        quarantineReason: 'Cell impedance mismatch flagged by BMS',
      ),
    );

    // Station 2: Lekki Phase 1
    final stn2 = BatterySwapStationModel(
      id: 'STN-02',
      name: 'Lekki Phase 1 Solar Swap Station',
      address: 'Admiralty Way, Lekki Phase 1, Lagos',
      location: const LocationDto(
        latitude: 6.4474,
        longitude: 3.4723,
        address: 'Admiralty Way, Lekki Phase 1, Lagos',
      ),
      totalCabinetBays: 24,
      powerSource: '100% Rooftop Solar + BESS',
      temperatureCelsius: 27.8,
      dailySwapCount: 122,
      status: 'OPERATIONAL',
      bays: generateBays(chargedCount: 18, chargingCount: 6),
    );

    // Station 3: Ikeja Commercial Hub
    final stn3 = BatterySwapStationModel(
      id: 'STN-03',
      name: 'Ikeja Commercial Fulfilment Hub',
      address: 'Allen Avenue, Ikeja, Lagos',
      location: const LocationDto(
        latitude: 6.6018,
        longitude: 3.3515,
        address: 'Allen Avenue, Ikeja, Lagos',
      ),
      totalCabinetBays: 24,
      powerSource: 'Grid Active + Diesel Standby',
      temperatureCelsius: 31.0,
      dailySwapCount: 210,
      status: 'OPERATIONAL',
      bays: generateBays(
        chargedCount: 14,
        chargingCount: 9,
        quarantinedCount: 1,
        quarantineReason: 'Thermal runaway threshold warning (>44°C cell temperature)',
      ),
    );

    // Station 4: Yaba Tech Corridor Hub
    final stn4 = BatterySwapStationModel(
      id: 'STN-04',
      name: 'Yaba Tech Corridor Hub',
      address: 'Herbert Macaulay Way, Yaba, Lagos',
      location: const LocationDto(
        latitude: 6.5095,
        longitude: 3.3711,
        address: 'Herbert Macaulay Way, Yaba, Lagos',
      ),
      totalCabinetBays: 24,
      powerSource: 'Solar PV + Grid Active',
      temperatureCelsius: 33.5,
      dailySwapCount: 95,
      status: 'HIGH_DEMAND',
      bays: generateBays(chargedCount: 6, chargingCount: 18),
    );

    state = state.copyWith(
      stations: [stn1, stn2, stn3, stn4],
    );
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query.trim());
  }

  void filterByStatus(String? status) {
    if (status == null) {
      state = state.copyWith(clearSelectedStatus: true);
    } else {
      state = state.copyWith(selectedStatus: status);
    }
  }

  /// Quarantines a degraded or overheating battery pack inside a swap bay.
  Future<bool> quarantineBatteryBay(
    String stationId,
    int bayNumber, {
    required String reason,
    required String officerName,
  }) async {
    final updatedStations = state.stations.map((stn) {
      if (stn.id == stationId) {
        final updatedBays = stn.bays.map((bay) {
          if (bay.bayNumber == bayNumber) {
            return bay.copyWith(
              isQuarantined: true,
              quarantineReason: reason,
              isCharging: false,
              isLocked: true,
            );
          }
          return bay;
        }).toList();

        return stn.copyWith(bays: updatedBays);
      }
      return stn;
    }).toList();

    state = state.copyWith(
      stations: updatedStations,
      actionMessage:
          'Bay #$bayNumber at $stationId quarantined by $officerName ($reason). Charging halted.',
    );
    return true;
  }

  /// Releases a previously quarantined battery bay after technician inspection.
  Future<bool> releaseQuarantineBay(
    String stationId,
    int bayNumber, {
    required String officerName,
  }) async {
    final updatedStations = state.stations.map((stn) {
      if (stn.id == stationId) {
        final updatedBays = stn.bays.map((bay) {
          if (bay.bayNumber == bayNumber) {
            return bay.copyWith(
              isQuarantined: false,
              quarantineReason: null,
              isCharging: true,
            );
          }
          return bay;
        }).toList();

        return stn.copyWith(bays: updatedBays);
      }
      return stn;
    }).toList();

    state = state.copyWith(
      stations: updatedStations,
      actionMessage:
          'Bay #$bayNumber at $stationId released from quarantine by $officerName.',
    );
    return true;
  }

  /// Remote unlocks a specific battery bay for technician service or emergency extraction.
  Future<bool> remoteUnlockBay(
    String stationId,
    int bayNumber, {
    required String officerName,
  }) async {
    final updatedStations = state.stations.map((stn) {
      if (stn.id == stationId) {
        final updatedBays = stn.bays.map((bay) {
          if (bay.bayNumber == bayNumber) {
            return bay.copyWith(isLocked: false);
          }
          return bay;
        }).toList();

        return stn.copyWith(bays: updatedBays);
      }
      return stn;
    }).toList();

    state = state.copyWith(
      stations: updatedStations,
      actionMessage:
          'Remote unlock command executed for Bay #$bayNumber at $stationId by $officerName.',
    );
    return true;
  }

  /// Toggles maintenance mode for an entire swap station.
  Future<bool> toggleStationMaintenance(
    String stationId, {
    required String reason,
    required String officerName,
  }) async {
    final updatedStations = state.stations.map((stn) {
      if (stn.id == stationId) {
        final isMaint = stn.status == 'MAINTENANCE';
        return stn.copyWith(
          status: isMaint ? 'OPERATIONAL' : 'MAINTENANCE',
        );
      }
      return stn;
    }).toList();

    state = state.copyWith(
      stations: updatedStations,
      actionMessage:
          'Station $stationId status toggled by $officerName ($reason).',
    );
    return true;
  }
}

final batterySwapNotifierProvider =
    StateNotifierProvider<BatterySwapNotifier, BatterySwapState>((ref) {
  return BatterySwapNotifier();
});

