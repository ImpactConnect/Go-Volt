import 'package:equatable/equatable.dart';

/// DTO for package pickup details from an individual or commercial hub (Screen B2 & ME-B01).
class PackagePickupDetailsDto extends Equatable {
  const PackagePickupDetailsDto({
    required this.pickupBusinessName,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.contactPerson,
    required this.phoneNumber,
    this.referenceOrderNumber,
    this.pickupInstructions,
  });

  factory PackagePickupDetailsDto.fromJson(Map<String, dynamic> json) {
    return PackagePickupDetailsDto(
      pickupBusinessName: json['pickup_business_name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      contactPerson: json['contact_person'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      referenceOrderNumber: json['reference_order_number'] as String?,
      pickupInstructions: json['pickup_instructions'] as String?,
    );
  }

  final String pickupBusinessName;
  final String address;
  final double latitude;
  final double longitude;
  final String contactPerson;
  final String phoneNumber;
  final String? referenceOrderNumber;
  final String? pickupInstructions;

  Map<String, dynamic> toJson() => {
        'pickup_business_name': pickupBusinessName,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'contact_person': contactPerson,
        'phone_number': phoneNumber,
        if (referenceOrderNumber != null)
          'reference_order_number': referenceOrderNumber,
        if (pickupInstructions != null)
          'pickup_instructions': pickupInstructions,
      };

  @override
  List<Object?> get props => [
        pickupBusinessName,
        address,
        latitude,
        longitude,
        contactPerson,
        phoneNumber,
        referenceOrderNumber,
      ];
}

