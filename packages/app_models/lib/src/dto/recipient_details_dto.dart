import 'package:equatable/equatable.dart';

/// DTO modeling recipient information and dropoff instructions (Screen 5: Recipient Details).
class RecipientDetailsDto extends Equatable {
  const RecipientDetailsDto({
    required this.fullName,
    required this.phoneNumber,
    this.countryCode = '+234',
    required this.deliveryAddress,
    this.additionalAddressInfo,
    this.latitude,
    this.longitude,
    this.saveAsRecipient = true,
  });

  factory RecipientDetailsDto.fromJson(Map<String, dynamic> json) {
    return RecipientDetailsDto(
      fullName: json['full_name'] as String? ?? 'John Doe',
      phoneNumber: json['phone_number'] as String? ?? '0803 123 4567',
      countryCode: json['country_code'] as String? ?? '+234',
      deliveryAddress:
          json['delivery_address'] as String? ?? 'Palms Mall, Lekki, Lagos',
      additionalAddressInfo: json['additional_address_info'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      saveAsRecipient: json['save_as_recipient'] as bool? ?? true,
    );
  }

  final String fullName;
  final String phoneNumber;
  final String countryCode;
  final String deliveryAddress;
  final String? additionalAddressInfo;
  final double? latitude;
  final double? longitude;
  final bool saveAsRecipient;

  String get formattedPhone => '$countryCode $phoneNumber';

  RecipientDetailsDto copyWith({
    String? fullName,
    String? phoneNumber,
    String? countryCode,
    String? deliveryAddress,
    String? additionalAddressInfo,
    double? latitude,
    double? longitude,
    bool? saveAsRecipient,
  }) {
    return RecipientDetailsDto(
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      countryCode: countryCode ?? this.countryCode,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      additionalAddressInfo:
          additionalAddressInfo ?? this.additionalAddressInfo,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      saveAsRecipient: saveAsRecipient ?? this.saveAsRecipient,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'full_name': fullName,
      'phone_number': phoneNumber,
      'country_code': countryCode,
      'delivery_address': deliveryAddress,
      if (additionalAddressInfo != null)
        'additional_address_info': additionalAddressInfo,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
      'save_as_recipient': saveAsRecipient,
    };
  }

  static const RecipientDetailsDto defaultRecipient = RecipientDetailsDto(
    fullName: 'John Doe',
    phoneNumber: '0803 123 4567',
    countryCode: '+234',
    deliveryAddress: 'Palms Mall, Lekki, Lagos',
    additionalAddressInfo: 'Shop B12, Second floor',
    saveAsRecipient: true,
  );

  static const List<RecipientDetailsDto> recentRecipients = [
    RecipientDetailsDto(
      fullName: 'Sarah Ahmed',
      phoneNumber: '0802 345 6789',
      countryCode: '+234',
      deliveryAddress: 'Lekki Phase 1, Lagos',
      saveAsRecipient: true,
    ),
    RecipientDetailsDto(
      fullName: 'Michael Brown',
      phoneNumber: '0809 876 5432',
      countryCode: '+234',
      deliveryAddress: 'Victoria Island, Lagos',
      saveAsRecipient: true,
    ),
  ];

  @override
  List<Object?> get props => [
        fullName,
        phoneNumber,
        countryCode,
        deliveryAddress,
        additionalAddressInfo,
        latitude,
        longitude,
        saveAsRecipient,
      ];
}
