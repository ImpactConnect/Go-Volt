import 'package:app_models/app_models.dart';
import 'package:equatable/equatable.dart';

enum SosAlertStatus {
  activeDistress('ACTIVE_DISTRESS', 'Active Distress'),
  dispatchedAuthorities('DISPATCHED_AUTHORITIES', '112 / Police Dispatched'),
  patrolEnRoute('PATROL_EN_ROUTE', 'Patrol En Route'),
  resolvedSafe('RESOLVED_SAFE', 'Resolved Safe'),
  falseAlarm('FALSE_ALARM', 'False Alarm');

  const SosAlertStatus(this.code, this.label);
  final String code;
  final String label;

  bool get isCritical =>
      this == SosAlertStatus.activeDistress ||
      this == SosAlertStatus.dispatchedAuthorities ||
      this == SosAlertStatus.patrolEnRoute;
}

class SosIncidentNote extends Equatable {
  const SosIncidentNote({
    required this.id,
    required this.authorName,
    required this.authorRole,
    required this.note,
    required this.createdAt,
  });

  final String id;
  final String authorName;
  final String authorRole;
  final String note;
  final DateTime createdAt;

  @override
  List<Object?> get props => [id, authorName, note, createdAt];
}

class SosDistressAlert extends Equatable {
  const SosDistressAlert({
    required this.id,
    required this.incidentRef,
    required this.bookingRef,
    required this.serviceType,
    required this.triggeredBy,
    required this.victimName,
    required this.victimPhone,
    this.driverName,
    this.driverPhone,
    this.vehiclePlate,
    this.vehicleModel,
    required this.location,
    required this.speedKmH,
    required this.evBatteryPercent,
    required this.status,
    required this.triggeredAt,
    this.emergencyServicesContacted = const [],
    this.dispatchedAt,
    this.safetyOfficerName,
    this.audioRecordingUrl,
    this.incidentNotes = const [],
    this.resolvedAt,
    this.resolutionSummary,
  });

  final String id;
  final String incidentRef;
  final String bookingRef;
  final String serviceType; // 'Passenger Ride', 'School Run', 'Market Errand', 'Parcel Delivery'
  final String triggeredBy; // 'Passenger', 'Driver', 'Impact Sensor (Crash)'
  final String victimName;
  final String victimPhone;
  final String? driverName;
  final String? driverPhone;
  final String? vehiclePlate;
  final String? vehicleModel;
  final LocationDto location;
  final double speedKmH;
  final int evBatteryPercent;
  final SosAlertStatus status;
  final DateTime triggeredAt;
  final List<String> emergencyServicesContacted;
  final DateTime? dispatchedAt;
  final String? safetyOfficerName;
  final String? audioRecordingUrl;
  final List<SosIncidentNote> incidentNotes;
  final DateTime? resolvedAt;
  final String? resolutionSummary;

  bool get isActive => status.isCritical;

  SosDistressAlert copyWith({
    String? id,
    String? incidentRef,
    String? bookingRef,
    String? serviceType,
    String? triggeredBy,
    String? victimName,
    String? victimPhone,
    String? driverName,
    String? driverPhone,
    String? vehiclePlate,
    String? vehicleModel,
    LocationDto? location,
    double? speedKmH,
    int? evBatteryPercent,
    SosAlertStatus? status,
    DateTime? triggeredAt,
    List<String>? emergencyServicesContacted,
    DateTime? dispatchedAt,
    String? safetyOfficerName,
    String? audioRecordingUrl,
    List<SosIncidentNote>? incidentNotes,
    DateTime? resolvedAt,
    String? resolutionSummary,
  }) {
    return SosDistressAlert(
      id: id ?? this.id,
      incidentRef: incidentRef ?? this.incidentRef,
      bookingRef: bookingRef ?? this.bookingRef,
      serviceType: serviceType ?? this.serviceType,
      triggeredBy: triggeredBy ?? this.triggeredBy,
      victimName: victimName ?? this.victimName,
      victimPhone: victimPhone ?? this.victimPhone,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      location: location ?? this.location,
      speedKmH: speedKmH ?? this.speedKmH,
      evBatteryPercent: evBatteryPercent ?? this.evBatteryPercent,
      status: status ?? this.status,
      triggeredAt: triggeredAt ?? this.triggeredAt,
      emergencyServicesContacted:
          emergencyServicesContacted ?? this.emergencyServicesContacted,
      dispatchedAt: dispatchedAt ?? this.dispatchedAt,
      safetyOfficerName: safetyOfficerName ?? this.safetyOfficerName,
      audioRecordingUrl: audioRecordingUrl ?? this.audioRecordingUrl,
      incidentNotes: incidentNotes ?? this.incidentNotes,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolutionSummary: resolutionSummary ?? this.resolutionSummary,
    );
  }

  @override
  List<Object?> get props => [
        id,
        incidentRef,
        bookingRef,
        status,
        triggeredAt,
        dispatchedAt,
        resolvedAt,
        incidentNotes,
      ];
}

