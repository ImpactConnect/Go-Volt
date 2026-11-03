import 'package:app_models/app_models.dart';
import 'package:equatable/equatable.dart';

class BatteryBayModel extends Equatable {
  const BatteryBayModel({
    required this.bayNumber,
    required this.batterySerial,
    required this.socPercent,
    this.sohHealthPercent = 95,
    this.temperatureCelsius = 28.0,
    this.isCharging = false,
    this.isQuarantined = false,
    this.quarantineReason,
    this.isLocked = true,
  });

  final int bayNumber;
  final String batterySerial;
  final int socPercent;
  final int sohHealthPercent;
  final double temperatureCelsius;
  final bool isCharging;
  final bool isQuarantined;
  final String? quarantineReason;
  final bool isLocked;

  bool get isReadyForSwap => socPercent >= 90 && !isQuarantined;

  BatteryBayModel copyWith({
    int? bayNumber,
    String? batterySerial,
    int? socPercent,
    int? sohHealthPercent,
    double? temperatureCelsius,
    bool? isCharging,
    bool? isQuarantined,
    String? quarantineReason,
    bool? isLocked,
  }) {
    return BatteryBayModel(
      bayNumber: bayNumber ?? this.bayNumber,
      batterySerial: batterySerial ?? this.batterySerial,
      socPercent: socPercent ?? this.socPercent,
      sohHealthPercent: sohHealthPercent ?? this.sohHealthPercent,
      temperatureCelsius: temperatureCelsius ?? this.temperatureCelsius,
      isCharging: isCharging ?? this.isCharging,
      isQuarantined: isQuarantined ?? this.isQuarantined,
      quarantineReason: quarantineReason ?? this.quarantineReason,
      isLocked: isLocked ?? this.isLocked,
    );
  }

  @override
  List<Object?> get props => [
        bayNumber,
        batterySerial,
        socPercent,
        sohHealthPercent,
        temperatureCelsius,
        isCharging,
        isQuarantined,
        quarantineReason,
        isLocked,
      ];
}

class BatterySwapStationModel extends Equatable {
  const BatterySwapStationModel({
    required this.id,
    required this.name,
    required this.address,
    required this.location,
    this.totalCabinetBays = 24,
    this.powerSource = 'Solar PV + Grid Active',
    this.temperatureCelsius = 28.5,
    required this.dailySwapCount,
    this.status = 'OPERATIONAL', // OPERATIONAL, HIGH_DEMAND, MAINTENANCE, OFFLINE
    this.bays = const [],
  });

  final String id;
  final String name;
  final String address;
  final LocationDto location;
  final int totalCabinetBays;
  final String powerSource;
  final double temperatureCelsius;
  final int dailySwapCount;
  final String status;
  final List<BatteryBayModel> bays;

  int get chargedPacksAvailable =>
      bays.where((b) => b.isReadyForSwap).length;

  int get chargingPacks =>
      bays.where((b) => b.isCharging && !b.isQuarantined).length;

  int get quarantinedPacks =>
      bays.where((b) => b.isQuarantined).length;

  bool get isOperational => status == 'OPERATIONAL' || status == 'HIGH_DEMAND';

  BatterySwapStationModel copyWith({
    String? id,
    String? name,
    String? address,
    LocationDto? location,
    int? totalCabinetBays,
    String? powerSource,
    double? temperatureCelsius,
    int? dailySwapCount,
    String? status,
    List<BatteryBayModel>? bays,
  }) {
    return BatterySwapStationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      location: location ?? this.location,
      totalCabinetBays: totalCabinetBays ?? this.totalCabinetBays,
      powerSource: powerSource ?? this.powerSource,
      temperatureCelsius: temperatureCelsius ?? this.temperatureCelsius,
      dailySwapCount: dailySwapCount ?? this.dailySwapCount,
      status: status ?? this.status,
      bays: bays ?? this.bays,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        totalCabinetBays,
        status,
        bays,
      ];
}

