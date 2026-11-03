import 'package:app_models/app_models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/supabase_admin_client.dart';
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
    fetchRealStations();
  }

  Future<void> fetchRealStations() async {
    final client = tryGetSupabaseClient();
    if (client == null) return;

    try {
      state = state.copyWith(isLoading: true);
      final res = await client.from('battery_swap_stations').select();
      final list = res as List<dynamic>;

      final mapped = list.map((s) {
        final lat = (s['latitude'] as num?)?.toDouble() ?? 6.4281;
        final lng = (s['longitude'] as num?)?.toDouble() ?? 3.4219;
        final addr = s['address']?.toString() ?? 'Lagos';
        return BatterySwapStationModel(
          id: s['id']?.toString() ?? '',
          name: s['name']?.toString() ?? 'EV Swap Station',
          address: addr,
          location: LocationDto(latitude: lat, longitude: lng, address: addr),
          totalCabinetBays: (s['total_cabinet_bays'] as num?)?.toInt() ?? 24,
          powerSource:
              s['power_source']?.toString() ?? 'Solar PV + Grid Active',
          temperatureCelsius:
              (s['temperature_celsius'] as num?)?.toDouble() ?? 28.5,
          dailySwapCount: (s['daily_swap_count'] as num?)?.toInt() ?? 0,
          status: s['status']?.toString() ?? 'OPERATIONAL',
          bays: const [],
        );
      }).toList();

      state = state.copyWith(
        isLoading: false,
        stations: mapped,
      );
    } catch (e) {
      debugPrint('[BatterySwapNotifier] Error fetching swap stations: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  @visibleForTesting
  void updateStateForTesting(BatterySwapState newState) {
    state = newState;
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

