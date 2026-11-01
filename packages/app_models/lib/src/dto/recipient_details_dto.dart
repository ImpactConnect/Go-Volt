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
      fullName: json['full_name'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      countryCode: json['country_code'] as String? ?? '+234',
      deliveryAddress:
          json['delivery_address'] as String? ?? '',
      additionalAddressInfo: json['additional_address_info'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      saveAsRecipient: json['save_as_recipient'] as bool? ?? false,
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
    fullName: '',
    phoneNumber: '',
    countryCode: '+234',
    deliveryAddress: '',
    additionalAddressInfo: '',
    saveAsRecipient: false,
  );

  static const List<RecipientDetailsDto> recentRecipients = [];

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
