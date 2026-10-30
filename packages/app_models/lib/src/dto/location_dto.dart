import 'package:equatable/equatable.dart';

/// Geographic coordinate and address representation.
class LocationDto extends Equatable {

  factory LocationDto.fromJson(Map<String, dynamic> json) {
    return LocationDto(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'] as String,
      label: json['label'] as String?,
      landmark: json['landmark'] as String?,
      contactName: json['contact_name'] as String?,
      contactPhone: json['contact_phone'] as String?,
      city: json['city'] as String? ?? 'Lagos',
      state: json['state'] as String? ?? 'Lagos',
    );
  }
  const LocationDto({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.label,
    this.landmark,
    this.contactName,
    this.contactPhone,
    this.city = 'Lagos',
    this.state = 'Lagos',
  });

  final double latitude;
  final double longitude;
  final String address;
  final String? label;
  final String? landmark;
  final String? contactName;
  final String? contactPhone;
  final String city;
  final String state;

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        if (label != null) 'label': label,
        if (landmark != null) 'landmark': landmark,
        if (contactName != null) 'contact_name': contactName,
        if (contactPhone != null) 'contact_phone': contactPhone,
        'city': city,
        'state': state,
      };

  LocationDto copyWith({
    double? latitude,
    double? longitude,
    String? address,
    String? label,
    String? landmark,
    String? contactName,
    String? contactPhone,
    String? city,
    String? state,
  }) {
    return LocationDto(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      label: label ?? this.label,
      landmark: landmark ?? this.landmark,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      city: city ?? this.city,
      state: state ?? this.state,
    );
  }

  @override
  List<Object?> get props => [
        latitude,
        longitude,
        address,
        label,
        landmark,
        contactName,
        contactPhone,
        city,
        state,
      ];
}
