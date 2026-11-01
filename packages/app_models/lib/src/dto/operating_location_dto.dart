import 'package:equatable/equatable.dart';

/// Represents a city/state where Go-Volt operates.
/// Provisioned by admin panel; fetched from the `operating_locations` DB table.
class OperatingLocationDto extends Equatable {
  const OperatingLocationDto({
    required this.id,
    required this.state,
    required this.city,
    this.isActive = true,
    this.status = 'fully_supported',
    this.statusDescription = 'Fully supported',
    this.availableServices = const [],
    this.centerLat,
    this.centerLng,
  });

  factory OperatingLocationDto.fromJson(Map<String, dynamic> json) {
    final rawServices = json['available_services'] as List<dynamic>? ?? [];
    return OperatingLocationDto(
      id: json['id'] as String? ?? '',
      state: json['state'] as String? ?? '',
      city: json['city'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
      status: json['status'] as String? ?? 'fully_supported',
      statusDescription: json['status_description'] as String? ?? 'Fully supported',
      availableServices: rawServices.map((s) => s.toString()).toList(),
      centerLat: (json['center_lat'] as num?)?.toDouble(),
      centerLng: (json['center_lng'] as num?)?.toDouble(),
    );
  }

  final String id;
  final String state;
  final String city;
  final bool isActive;

  /// One of: 'fully_supported', 'limited', 'coming_soon'
  final String status;
  final String statusDescription;
  final List<String> availableServices;

  /// Approximate city centre latitude (nullable until set in admin).
  final double? centerLat;

  /// Approximate city centre longitude (nullable until set in admin).
  final double? centerLng;

  bool get isFullySupported => status == 'fully_supported';
  bool get isLimited => status == 'limited';
  bool get isComingSoon => status == 'coming_soon';

  /// Human-readable display label: "Shagamu, Ogun"
  String get displayName => '$city, $state';

  Map<String, dynamic> toJson() => {
        'id': id,
        'state': state,
        'city': city,
        'is_active': isActive,
        'status': status,
        'status_description': statusDescription,
        'available_services': availableServices,
        if (centerLat != null) 'center_lat': centerLat,
        if (centerLng != null) 'center_lng': centerLng,
      };

  OperatingLocationDto copyWith({
    String? id,
    String? state,
    String? city,
    bool? isActive,
    String? status,
    String? statusDescription,
    List<String>? availableServices,
    double? centerLat,
    double? centerLng,
  }) {
    return OperatingLocationDto(
      id: id ?? this.id,
      state: state ?? this.state,
      city: city ?? this.city,
      isActive: isActive ?? this.isActive,
      status: status ?? this.status,
      statusDescription: statusDescription ?? this.statusDescription,
      availableServices: availableServices ?? this.availableServices,
      centerLat: centerLat ?? this.centerLat,
      centerLng: centerLng ?? this.centerLng,
    );
  }

  @override
  List<Object?> get props => [
        id,
        state,
        city,
        isActive,
        status,
        statusDescription,
        availableServices,
        centerLat,
        centerLng,
      ];
}

