import 'package:equatable/equatable.dart';
import '../enums/domain_enums.dart';
import '../enums/service_code.dart';

/// Service operating zone with availability indicators.
class ServiceAreaDto extends Equatable {
  const ServiceAreaDto({
    required this.id,
    required this.name,
    this.state = 'Ogun',
    this.status = ServiceAreaStatus.fullySupported,
    this.statusDescription,
    this.availableServices = const [
      ServiceCode.instantRide,
      ServiceCode.instantDelivery,
      ServiceCode.scheduledRide,
      ServiceCode.scheduledPickup,
    ],
  });

  factory ServiceAreaDto.fromJson(Map<String, dynamic> json) {
    final status = ServiceAreaStatus.fromString(json['status'] as String? ?? 'FULLY_SUPPORTED');
    final rawServices = json['available_services'] as List<dynamic>?;
    final services = rawServices != null
        ? rawServices.map((s) => ServiceCode.fromString(s.toString())).toList()
        : const [
            ServiceCode.instantRide,
            ServiceCode.instantDelivery,
            ServiceCode.scheduledRide,
            ServiceCode.scheduledPickup,
          ];

    return ServiceAreaDto(
      id: json['id'] as String,
      name: json['name'] as String,
      state: json['state'] as String? ?? 'Ogun',
      status: status,
      statusDescription: json['status_description'] as String?,
      availableServices: services,
    );
  }

  final String id;
  final String name;
  final String state;
  final ServiceAreaStatus status;
  final String? statusDescription;
  final List<ServiceCode> availableServices;

  String get effectiveStatusDescription => statusDescription ?? status.displayName;

  bool get isFullySupported => status == ServiceAreaStatus.fullySupported;
  bool get isLimited => status == ServiceAreaStatus.limited;
  bool get isUnavailable => status == ServiceAreaStatus.unavailable;

  bool isServiceAvailable(ServiceCode service) {
    if (isUnavailable) return false;
    return availableServices.contains(service);
  }

  String get displayName => '$name, $state';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'state': state,
        'status': status.code,
        'status_description': effectiveStatusDescription,
        'available_services': availableServices.map((s) => s.code).toList(),
      };

  @override
  List<Object?> get props => [id, name, state, status, statusDescription, availableServices];
}
