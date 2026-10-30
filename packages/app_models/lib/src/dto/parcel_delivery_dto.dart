import 'package:equatable/equatable.dart';

import '../enums/booking_status.dart';
import '../enums/domain_enums.dart';
import 'delivery_option_dto.dart';
import 'location_dto.dart';
import 'parcel_details_dto.dart';
import 'parcel_price_breakdown_dto.dart';
import 'proof_of_delivery_dto.dart';
import 'recipient_details_dto.dart';

/// Comprehensive DTO representing an active or completed parcel delivery booking.
class ParcelDeliveryDto extends Equatable {
  const ParcelDeliveryDto({
    required this.id,
    required this.trackingNumber,
    required this.status,
    required this.deliveryOption,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.recipient,
    required this.packageDetails,
    required this.priceBreakdown,
    this.paymentMethod = PaymentMethod.wallet,
    this.riderName,
    this.riderPhone,
    this.riderRating = 4.9,
    this.riderTotalTrips = 320,
    this.riderVehicle = 'Yamaha Bike - ABC-123XY',
    this.riderAvatarUrl,
    this.proofOfDelivery,
    required this.createdAt,
    this.pickupTimestamp,
    this.etaMinutes = 6,
  });

  factory ParcelDeliveryDto.fromJson(Map<String, dynamic> json) {
    return ParcelDeliveryDto(
      id: json['id'] as String? ?? 'del_101',
      trackingNumber: json['tracking_number'] as String? ?? 'DVL12345678',
      status: BookingStatus.fromString(json['status'] as String? ?? 'ASSIGNED'),
      deliveryOption: json['delivery_option'] != null
          ? DeliveryOptionDto.fromJson(
              json['delivery_option'] as Map<String, dynamic>)
          : DeliveryOptionDto.standard,
      pickupLocation: json['pickup_location'] != null
          ? LocationDto.fromJson(json['pickup_location'] as Map<String, dynamic>)
          : const LocationDto(
              latitude: 6.4281,
              longitude: 3.4219,
              address: 'Eko Hotel and Suites, Victoria Island, Lagos',
              label: 'Eko Hotel and Suites',
            ),
      destinationLocation: json['destination_location'] != null
          ? LocationDto.fromJson(
              json['destination_location'] as Map<String, dynamic>)
          : const LocationDto(
              latitude: 6.4357,
              longitude: 3.4418,
              address: 'Palms Mall, Lekki, Lagos',
              label: 'Palms Mall',
            ),
      recipient: json['recipient'] != null
          ? RecipientDetailsDto.fromJson(
              json['recipient'] as Map<String, dynamic>)
          : RecipientDetailsDto.defaultRecipient,
      packageDetails: json['package_details'] != null
          ? ParcelDetailsDto.fromJson(
              json['package_details'] as Map<String, dynamic>)
          : ParcelDetailsDto.defaultFragile,
      priceBreakdown: json['price_breakdown'] != null
          ? ParcelPriceBreakdownDto.fromJson(
              json['price_breakdown'] as Map<String, dynamic>)
          : ParcelPriceBreakdownDto.defaultBreakdown,
      paymentMethod: PaymentMethod.fromString(
          json['payment_method'] as String? ?? 'WALLET'),
      riderName: json['rider_name'] as String? ?? 'Daniel Okafor',
      riderPhone: json['rider_phone'] as String? ?? '+234 802 000 1122',
      riderRating: (json['rider_rating'] as num?)?.toDouble() ?? 4.9,
      riderTotalTrips: (json['rider_total_trips'] as num?)?.toInt() ?? 320,
      riderVehicle:
          json['rider_vehicle'] as String? ?? 'Yamaha Bike - ABC-123XY',
      riderAvatarUrl: json['rider_avatar_url'] as String?,
      proofOfDelivery: json['proof_of_delivery'] != null
          ? ProofOfDeliveryDto.fromJson(
              json['proof_of_delivery'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
      pickupTimestamp: json['pickup_timestamp'] != null
          ? DateTime.parse(json['pickup_timestamp'] as String)
          : null,
      etaMinutes: (json['eta_minutes'] as num?)?.toInt() ?? 6,
    );
  }

  final String id;
  final String trackingNumber;
  final BookingStatus status;
  final DeliveryOptionDto deliveryOption;
  final LocationDto pickupLocation;
  final LocationDto destinationLocation;
  final RecipientDetailsDto recipient;
  final ParcelDetailsDto packageDetails;
  final ParcelPriceBreakdownDto priceBreakdown;
  final PaymentMethod paymentMethod;
  final String? riderName;
  final String? riderPhone;
  final double riderRating;
  final int riderTotalTrips;
  final String riderVehicle;
  final String? riderAvatarUrl;
  final ProofOfDeliveryDto? proofOfDelivery;
  final DateTime createdAt;
  final DateTime? pickupTimestamp;
  final int etaMinutes;

  String get formattedEta => '$etaMinutes min';

  ParcelDeliveryDto copyWith({
    String? id,
    String? trackingNumber,
    BookingStatus? status,
    DeliveryOptionDto? deliveryOption,
    LocationDto? pickupLocation,
    LocationDto? destinationLocation,
    RecipientDetailsDto? recipient,
    ParcelDetailsDto? packageDetails,
    ParcelPriceBreakdownDto? priceBreakdown,
    PaymentMethod? paymentMethod,
    String? riderName,
    String? riderPhone,
    double? riderRating,
    int? riderTotalTrips,
    String? riderVehicle,
    String? riderAvatarUrl,
    ProofOfDeliveryDto? proofOfDelivery,
    DateTime? createdAt,
    DateTime? pickupTimestamp,
    int? etaMinutes,
  }) {
    return ParcelDeliveryDto(
      id: id ?? this.id,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      status: status ?? this.status,
      deliveryOption: deliveryOption ?? this.deliveryOption,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      destinationLocation: destinationLocation ?? this.destinationLocation,
      recipient: recipient ?? this.recipient,
      packageDetails: packageDetails ?? this.packageDetails,
      priceBreakdown: priceBreakdown ?? this.priceBreakdown,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      riderName: riderName ?? this.riderName,
      riderPhone: riderPhone ?? this.riderPhone,
      riderRating: riderRating ?? this.riderRating,
      riderTotalTrips: riderTotalTrips ?? this.riderTotalTrips,
      riderVehicle: riderVehicle ?? this.riderVehicle,
      riderAvatarUrl: riderAvatarUrl ?? this.riderAvatarUrl,
      proofOfDelivery: proofOfDelivery ?? this.proofOfDelivery,
      createdAt: createdAt ?? this.createdAt,
      pickupTimestamp: pickupTimestamp ?? this.pickupTimestamp,
      etaMinutes: etaMinutes ?? this.etaMinutes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tracking_number': trackingNumber,
      'status': status.code,
      'delivery_option': deliveryOption.toJson(),
      'pickup_location': pickupLocation.toJson(),
      'destination_location': destinationLocation.toJson(),
      'recipient': recipient.toJson(),
      'package_details': packageDetails.toJson(),
      'price_breakdown': priceBreakdown.toJson(),
      'payment_method': paymentMethod.code,
      if (riderName != null) 'rider_name': riderName,
      if (riderPhone != null) 'rider_phone': riderPhone,
      'rider_rating': riderRating,
      'rider_total_trips': riderTotalTrips,
      'rider_vehicle': riderVehicle,
      if (riderAvatarUrl != null) 'rider_avatar_url': riderAvatarUrl,
      if (proofOfDelivery != null)
        'proof_of_delivery': proofOfDelivery!.toJson(),
      'created_at': createdAt.toIso8601String(),
      if (pickupTimestamp != null)
        'pickup_timestamp': pickupTimestamp!.toIso8601String(),
      'eta_minutes': etaMinutes,
    };
  }

  static final ParcelDeliveryDto sampleDelivery = ParcelDeliveryDto(
    id: 'del_001_dvl',
    trackingNumber: 'DVL12345678',
    status: BookingStatus.assigned,
    deliveryOption: DeliveryOptionDto.standard,
    pickupLocation: const LocationDto(
      latitude: 6.4281,
      longitude: 3.4219,
      address: 'Eko Hotel and Suites, Victoria Island, Lagos',
      label: 'Eko Hotel and Suites',
    ),
    destinationLocation: const LocationDto(
      latitude: 6.4357,
      longitude: 3.4418,
      address: 'Palms Mall, Lekki, Lagos',
      label: 'Palms Mall',
    ),
    recipient: RecipientDetailsDto.defaultRecipient,
    packageDetails: ParcelDetailsDto.defaultFragile,
    priceBreakdown: ParcelPriceBreakdownDto.defaultBreakdown,
    paymentMethod: PaymentMethod.wallet,
    riderName: 'Daniel Okafor',
    riderPhone: '+234 802 000 1122',
    riderRating: 4.9,
    riderTotalTrips: 320,
    riderVehicle: 'Yamaha Bike - ABC-123XY',
    createdAt: DateTime(2026, 10, 29, 9, 30),
    pickupTimestamp: DateTime(2026, 10, 29, 10, 5),
    etaMinutes: 6,
  );

  @override
  List<Object?> get props => [
        id,
        trackingNumber,
        status,
        deliveryOption,
        pickupLocation,
        destinationLocation,
        recipient,
        packageDetails,
        priceBreakdown,
        paymentMethod,
        riderName,
        riderPhone,
        riderRating,
        riderTotalTrips,
        riderVehicle,
        riderAvatarUrl,
        proofOfDelivery,
        createdAt,
        pickupTimestamp,
        etaMinutes,
      ];
}
