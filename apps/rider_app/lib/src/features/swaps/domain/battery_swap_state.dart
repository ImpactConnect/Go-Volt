import 'package:equatable/equatable.dart';

/// Representation of an authorized Go-Volts EV battery swapping kiosk station.
class BatterySwapStationDto extends Equatable {
  const BatterySwapStationDto({
    required this.id,
    required this.name,
    required this.address,
    required this.distanceKm,
    required this.availablePacks,
    required this.totalSlots,
    this.isOpen = true,
  });

  final String id;
  final String name;
  final String address;
  final double distanceKm;
  final int availablePacks;
  final int totalSlots;
  final bool isOpen;

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        distanceKm,
        availablePacks,
        totalSlots,
        isOpen,
      ];
}

/// State tracking current battery health, station locator, active locker reservation, and QR unlock.
class BatterySwapState extends Equatable {
  const BatterySwapState({
    this.batteryHealthPercent = 94,
    this.estimatedRangeKm = 68,
    this.reservedStationId,
    this.reservedStationName,
    this.reservationExpirySeconds = 900, // 15 mins
    this.unlockedLockerNumber,
    this.stations = const [],
    this.isLoading = false,
  });

  final int batteryHealthPercent;
  final int estimatedRangeKm;
  final String? reservedStationId;
  final String? reservedStationName;
  final int reservationExpirySeconds;
  final int? unlockedLockerNumber;
  final List<BatterySwapStationDto> stations;
  final bool isLoading;

  bool get hasActiveReservation => reservedStationId != null;

  BatterySwapState copyWith({
    int? batteryHealthPercent,
    int? estimatedRangeKm,
    String? reservedStationId,
    String? reservedStationName,
    int? reservationExpirySeconds,
    int? unlockedLockerNumber,
    List<BatterySwapStationDto>? stations,
    bool? isLoading,
  }) {
    return BatterySwapState(
      batteryHealthPercent:
          batteryHealthPercent ?? this.batteryHealthPercent,
      estimatedRangeKm: estimatedRangeKm ?? this.estimatedRangeKm,
      reservedStationId: reservedStationId ?? this.reservedStationId,
      reservedStationName: reservedStationName ?? this.reservedStationName,
      reservationExpirySeconds:
          reservationExpirySeconds ?? this.reservationExpirySeconds,
      unlockedLockerNumber: unlockedLockerNumber ?? this.unlockedLockerNumber,
      stations: stations ?? this.stations,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
        batteryHealthPercent,
        estimatedRangeKm,
        reservedStationId,
        reservedStationName,
        reservationExpirySeconds,
        unlockedLockerNumber,
        stations,
        isLoading,
      ];
}
