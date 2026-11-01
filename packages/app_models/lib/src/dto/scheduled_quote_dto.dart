import 'package:equatable/equatable.dart';
import '../enums/scheduled_enums.dart';
import 'location_dto.dart';

/// Pre-calculated pricing option for package selection.
class ScheduledPackageOptionDto extends Equatable {
  const ScheduledPackageOptionDto({
    required this.id,
    required this.billingModel,
    required this.title,
    required this.subtitle,
    required this.pricePerTripNgn,
    required this.totalAmountNgn,
    required this.totalTrips,
    this.savingsPercent = 0,
    this.isPopular = false,
  });

  factory ScheduledPackageOptionDto.fromJson(Map<String, dynamic> json) {
    return ScheduledPackageOptionDto(
      id: json['id'] as String,
      billingModel: PackageBillingModel.fromString(json['billing_model'] as String?),
      title: json['title'] as String,
      subtitle: json['subtitle'] as String,
      pricePerTripNgn: (json['price_per_trip_ngn'] as num).toDouble(),
      totalAmountNgn: (json['total_amount_ngn'] as num).toDouble(),
      totalTrips: (json['total_trips'] as num).toInt(),
      savingsPercent: (json['savings_percent'] as num?)?.toDouble() ?? 0,
      isPopular: json['is_popular'] as bool? ?? false,
    );
  }

  final String id;
  final PackageBillingModel billingModel;
  final String title;
  final String subtitle;
  final double pricePerTripNgn;
  final double totalAmountNgn;
  final int totalTrips;
  final double savingsPercent;
  final bool isPopular;

  Map<String, dynamic> toJson() => {
        'id': id,
        'billing_model': billingModel.value,
        'title': title,
        'subtitle': subtitle,
        'price_per_trip_ngn': pricePerTripNgn,
        'total_amount_ngn': totalAmountNgn,
        'total_trips': totalTrips,
        'savings_percent': savingsPercent,
        'is_popular': isPopular,
      };

  @override
  List<Object?> get props => [
        id,
        billingModel,
        title,
        pricePerTripNgn,
        totalAmountNgn,
        totalTrips,
        savingsPercent,
      ];
}

/// Immutable price quote for a one-off scheduled trip or recurring package plan.
class ScheduledQuoteDto extends Equatable {
  const ScheduledQuoteDto({
    required this.quoteId,
    required this.bookingType,
    required this.purpose,
    required this.journeyType,
    required this.pickupLocation,
    required this.destinationLocation,
    this.returnPickupLocation,
    this.returnDestinationLocation,
    this.scheduledDate,
    this.pickupTime = '08:00 AM',
    this.returnPickupTime,
    this.selectedDays = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
    this.startDate,
    this.endDate,
    required this.billingModel,
    required this.baseFareNgn,
    required this.distanceKm,
    required this.distanceFareNgn,
    required this.serviceFeeNgn,
    required this.totalFareNgn,
    required this.estimatedPricePerTripNgn,
    required this.totalTrips,
    this.validityMinutes = 15,
    required this.issuedAt,
    required this.expiresAt,
    this.status = 'READY',
  });

  factory ScheduledQuoteDto.fromJson(Map<String, dynamic> json) {
    return ScheduledQuoteDto(
      quoteId: json['quote_id'] as String,
      bookingType:
          ScheduledBookingType.fromString(json['booking_type'] as String?),
      purpose: TripPurpose.fromString(json['purpose'] as String?),
      journeyType:
          JourneyDirection.fromString(json['journey_type'] as String?),
      pickupLocation: LocationDto.fromJson(
        json['pickup_location'] as Map<String, dynamic>,
      ),
      destinationLocation: LocationDto.fromJson(
        json['destination_location'] as Map<String, dynamic>,
      ),
      returnPickupLocation: json['return_pickup_location'] != null
          ? LocationDto.fromJson(
              json['return_pickup_location'] as Map<String, dynamic>)
          : null,
      returnDestinationLocation: json['return_destination_location'] != null
          ? LocationDto.fromJson(
              json['return_destination_location'] as Map<String, dynamic>)
          : null,
      scheduledDate: json['scheduled_date'] != null
          ? DateTime.tryParse(json['scheduled_date'] as String)
          : null,
      pickupTime: json['pickup_time'] as String? ?? '08:00 AM',
      returnPickupTime: json['return_pickup_time'] as String?,
      selectedDays: (json['selected_days'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'] as String)
          : null,
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'] as String)
          : null,
      billingModel:
          PackageBillingModel.fromString(json['billing_model'] as String?),
      baseFareNgn: (json['base_fare_ngn'] as num).toDouble(),
      distanceKm: (json['distance_km'] as num).toDouble(),
      distanceFareNgn: (json['distance_fare_ngn'] as num).toDouble(),
      serviceFeeNgn: (json['service_fee_ngn'] as num).toDouble(),
      totalFareNgn: (json['total_fare_ngn'] as num).toDouble(),
      estimatedPricePerTripNgn:
          (json['estimated_price_per_trip_ngn'] as num).toDouble(),
      totalTrips: (json['total_trips'] as num).toInt(),
      validityMinutes: (json['validity_minutes'] as num?)?.toInt() ?? 15,
      issuedAt: DateTime.parse(json['issued_at'] as String),
      expiresAt: DateTime.parse(json['expires_at'] as String),
      status: json['status'] as String? ?? 'READY',
    );
  }

  final String quoteId;
  final ScheduledBookingType bookingType;
  final TripPurpose purpose;
  final JourneyDirection journeyType;
  final LocationDto pickupLocation;
  final LocationDto destinationLocation;
  final LocationDto? returnPickupLocation;
  final LocationDto? returnDestinationLocation;
  final DateTime? scheduledDate;
  final String pickupTime;
  final String? returnPickupTime;
  final List<String> selectedDays;
  final DateTime? startDate;
  final DateTime? endDate;
  final PackageBillingModel billingModel;
  final double baseFareNgn;
  final double distanceKm;
  final double distanceFareNgn;
  final double serviceFeeNgn;
  final double totalFareNgn;
  final double estimatedPricePerTripNgn;
  final int totalTrips;
  final int validityMinutes;
  final DateTime issuedAt;
  final DateTime expiresAt;
  final String status;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get isOneOff => bookingType == ScheduledBookingType.oneOff;

  TripPurpose get tripPurpose => purpose;
  JourneyDirection get journeyDirection => journeyType;
  double get distanceFeeNgn => distanceFareNgn;
  double get totalAmountNgn => totalFareNgn;
  double get perTripEstimateNgn => estimatedPricePerTripNgn;
  int get totalTripsCount => totalTrips;
  DateTime get quotedAt => issuedAt;
  bool get isRoundTrip => journeyType == JourneyDirection.roundTrip;

  Map<String, dynamic> toJson() => {
        'quote_id': quoteId,
        'booking_type': bookingType.value,
        'purpose': purpose.value,
        'journey_type': journeyType.value,
        'pickup_location': pickupLocation.toJson(),
        'destination_location': destinationLocation.toJson(),
        if (returnPickupLocation != null)
          'return_pickup_location': returnPickupLocation!.toJson(),
        if (returnDestinationLocation != null)
          'return_destination_location': returnDestinationLocation!.toJson(),
        if (scheduledDate != null)
          'scheduled_date': scheduledDate!.toIso8601String(),
        'pickup_time': pickupTime,
        if (returnPickupTime != null) 'return_pickup_time': returnPickupTime,
        'selected_days': selectedDays,
        if (startDate != null) 'start_date': startDate!.toIso8601String(),
        if (endDate != null) 'end_date': endDate!.toIso8601String(),
        'billing_model': billingModel.value,
        'base_fare_ngn': baseFareNgn,
        'distance_km': distanceKm,
        'distance_fare_ngn': distanceFareNgn,
        'service_fee_ngn': serviceFeeNgn,
        'total_fare_ngn': totalFareNgn,
        'estimated_price_per_trip_ngn': estimatedPricePerTripNgn,
        'total_trips': totalTrips,
        'validity_minutes': validityMinutes,
        'issued_at': issuedAt.toIso8601String(),
        'expires_at': expiresAt.toIso8601String(),
        'status': status,
      };

  @override
  List<Object?> get props => [
        quoteId,
        bookingType,
        purpose,
        totalFareNgn,
        totalTrips,
        expiresAt,
      ];
}
