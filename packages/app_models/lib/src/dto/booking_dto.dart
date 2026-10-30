import 'package:equatable/equatable.dart';
import '../enums/booking_status.dart';
import '../enums/domain_enums.dart';
import '../enums/service_code.dart';
import 'location_dto.dart';
import 'price_quote_dto.dart';

/// Full Go-Volts booking entity representing Rides, Deliveries, and Pickups.
///
/// Complies with Technical Specification v1.3 §5.5 and Ride Flow screens RIDE-06 to RIDE-16.
class BookingDto extends Equatable {
  const BookingDto({
    required this.id,
    required this.bookingReference,
    required this.serviceCode,
    required this.status,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.priceBreakdown,
    required this.createdAt,
    this.pricingQuoteId,
    this.rideCategoryId,
    this.rideCategoryName,
    this.scheduledTime,
    this.riderId,
    this.riderName,
    this.riderPhone,
    this.riderAvatarUrl,
    this.riderRating,
    this.driverTripsCount,
    this.vehicleType = VehicleType.electricBike,
    this.vehiclePlate,
    this.vehicleModel,
    this.paymentMethod = PaymentMethod.wallet,
    this.paymentStatus = PaymentStatus.pending,
    this.packageCategory,
    this.packageWeightKg,
    this.recipientName,
    this.recipientPhone,
    this.instructions,
    this.cancellationReason,
    this.etaMinutes,
    this.distanceKm,
    this.durationMinutes,
    this.carbonSavedGrams,
    this.statusDescription,
    this.updatedAt,
  });

  factory BookingDto.fromJson(Map<String, dynamic> json) {
    final ref = (json['public_reference'] as String?) ??
        (json['booking_reference'] as String?) ??
        'GV-${json['id']}';

    return BookingDto(
      id: json['id'] as String,
      bookingReference: ref,
      serviceCode: ServiceCode.fromString(json['service_code'] as String),
      status: BookingStatus.fromString(json['status'] as String),
      pickupLocation: LocationDto.fromJson(
        json['pickup_location'] as Map<String, dynamic>,
      ),
      dropoffLocation: LocationDto.fromJson(
        json['dropoff_location'] as Map<String, dynamic>,
      ),
      priceBreakdown: PriceBreakdownDto.fromJson(
        json['price_breakdown'] as Map<String, dynamic>,
      ),
      createdAt: DateTime.parse(json['created_at'] as String),
      pricingQuoteId: json['pricing_quote_id'] as String?,
      rideCategoryId: json['ride_category_id'] as String?,
      rideCategoryName: json['ride_category_name'] as String?,
      scheduledTime: json['scheduled_time'] != null
          ? DateTime.parse(json['scheduled_time'] as String)
          : null,
      riderId: json['rider_id'] as String?,
      riderName: json['rider_name'] as String?,
      riderPhone: json['rider_phone'] as String?,
      riderAvatarUrl: json['rider_avatar_url'] as String?,
      riderRating: (json['rider_rating'] as num?)?.toDouble(),
      driverTripsCount: (json['driver_trips_count'] as num?)?.toInt(),
      vehicleType: VehicleType.fromString(
        json['vehicle_type'] as String? ?? 'EV_BIKE',
      ),
      vehiclePlate: json['vehicle_plate'] as String?,
      vehicleModel: json['vehicle_model'] as String?,
      paymentMethod: PaymentMethod.fromString(
        json['payment_method'] as String? ?? 'WALLET',
      ),
      paymentStatus: PaymentStatus.fromString(
        json['payment_status'] as String? ?? 'PENDING',
      ),
      packageCategory: json['package_category'] != null
          ? PackageCategory.fromString(json['package_category'] as String)
          : null,
      packageWeightKg: (json['package_weight_kg'] as num?)?.toDouble(),
      recipientName: json['recipient_name'] as String?,
      recipientPhone: json['recipient_phone'] as String?,
      instructions: json['instructions'] as String?,
      cancellationReason: json['cancellation_reason'] as String?,
      etaMinutes: (json['eta_minutes'] as num?)?.toInt(),
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      durationMinutes: (json['duration_minutes'] as num?)?.toInt(),
      carbonSavedGrams: (json['carbon_saved_grams'] as num?)?.toInt(),
      statusDescription: json['status_description'] as String?,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  final String id;
  final String bookingReference;
  final ServiceCode serviceCode;
  final BookingStatus status;
  final LocationDto pickupLocation;
  final LocationDto dropoffLocation;
  final PriceBreakdownDto priceBreakdown;
  final DateTime createdAt;
  final String? pricingQuoteId;
  final String? rideCategoryId;
  final String? rideCategoryName;
  final DateTime? scheduledTime;
  final String? riderId;
  final String? riderName;
  final String? riderPhone;
  final String? riderAvatarUrl;
  final double? riderRating;
  final int? driverTripsCount;
  final VehicleType vehicleType;
  final String? vehiclePlate;
  final String? vehicleModel;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final PackageCategory? packageCategory;
  final double? packageWeightKg;
  final String? recipientName;
  final String? recipientPhone;
  final String? instructions;
  final String? cancellationReason;
  final int? etaMinutes;
  final double? distanceKm;
  final int? durationMinutes;
  final int? carbonSavedGrams;
  final String? statusDescription;
  final DateTime? updatedAt;

  /// Public non-sequential reference code (v1.3 §5.1 & §5.5).
  String get publicReference => bookingReference;

  bool get isScheduled => scheduledTime != null;
  bool get hasAssignedRider =>
      (riderId != null && riderId!.isNotEmpty) ||
      (riderName != null && riderName!.isNotEmpty);
  bool get isTerminal => status.isTerminal;

  BookingDto copyWith({
    String? id,
    String? bookingReference,
    ServiceCode? serviceCode,
    BookingStatus? status,
    LocationDto? pickupLocation,
    LocationDto? dropoffLocation,
    PriceBreakdownDto? priceBreakdown,
    DateTime? createdAt,
    String? pricingQuoteId,
    String? rideCategoryId,
    String? rideCategoryName,
    DateTime? scheduledTime,
    String? riderId,
    String? riderName,
    String? riderPhone,
    String? riderAvatarUrl,
    double? riderRating,
    int? driverTripsCount,
    VehicleType? vehicleType,
    String? vehiclePlate,
    String? vehicleModel,
    PaymentMethod? paymentMethod,
    PaymentStatus? paymentStatus,
    PackageCategory? packageCategory,
    double? packageWeightKg,
    String? recipientName,
    String? recipientPhone,
    String? instructions,
    String? cancellationReason,
    int? etaMinutes,
    double? distanceKm,
    int? durationMinutes,
    int? carbonSavedGrams,
    String? statusDescription,
    DateTime? updatedAt,
  }) {
    return BookingDto(
      id: id ?? this.id,
      bookingReference: bookingReference ?? this.bookingReference,
      serviceCode: serviceCode ?? this.serviceCode,
      status: status ?? this.status,
      pickupLocation: pickupLocation ?? this.pickupLocation,
      dropoffLocation: dropoffLocation ?? this.dropoffLocation,
      priceBreakdown: priceBreakdown ?? this.priceBreakdown,
      createdAt: createdAt ?? this.createdAt,
      pricingQuoteId: pricingQuoteId ?? this.pricingQuoteId,
      rideCategoryId: rideCategoryId ?? this.rideCategoryId,
      rideCategoryName: rideCategoryName ?? this.rideCategoryName,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      riderId: riderId ?? this.riderId,
      riderName: riderName ?? this.riderName,
      riderPhone: riderPhone ?? this.riderPhone,
      riderAvatarUrl: riderAvatarUrl ?? this.riderAvatarUrl,
      riderRating: riderRating ?? this.riderRating,
      driverTripsCount: driverTripsCount ?? this.driverTripsCount,
      vehicleType: vehicleType ?? this.vehicleType,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      packageCategory: packageCategory ?? this.packageCategory,
      packageWeightKg: packageWeightKg ?? this.packageWeightKg,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      instructions: instructions ?? this.instructions,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      distanceKm: distanceKm ?? this.distanceKm,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      carbonSavedGrams: carbonSavedGrams ?? this.carbonSavedGrams,
      statusDescription: statusDescription ?? this.statusDescription,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'booking_reference': bookingReference,
        'public_reference': publicReference,
        'service_code': serviceCode.code,
        'status': status.code,
        'pickup_location': pickupLocation.toJson(),
        'dropoff_location': dropoffLocation.toJson(),
        'price_breakdown': priceBreakdown.toJson(),
        'created_at': createdAt.toIso8601String(),
        if (pricingQuoteId != null) 'pricing_quote_id': pricingQuoteId,
        if (rideCategoryId != null) 'ride_category_id': rideCategoryId,
        if (rideCategoryName != null) 'ride_category_name': rideCategoryName,
        if (scheduledTime != null)
          'scheduled_time': scheduledTime!.toIso8601String(),
        if (riderId != null) 'rider_id': riderId,
        if (riderName != null) 'rider_name': riderName,
        if (riderPhone != null) 'rider_phone': riderPhone,
        if (riderAvatarUrl != null) 'rider_avatar_url': riderAvatarUrl,
        if (riderRating != null) 'rider_rating': riderRating,
        if (driverTripsCount != null) 'driver_trips_count': driverTripsCount,
        'vehicle_type': vehicleType.code,
        if (vehiclePlate != null) 'vehicle_plate': vehiclePlate,
        if (vehicleModel != null) 'vehicle_model': vehicleModel,
        'payment_method': paymentMethod.code,
        'payment_status': paymentStatus.code,
        if (packageCategory != null)
          'package_category': packageCategory!.code,
        if (packageWeightKg != null) 'package_weight_kg': packageWeightKg,
        if (recipientName != null) 'recipient_name': recipientName,
        if (recipientPhone != null) 'recipient_phone': recipientPhone,
        if (instructions != null) 'instructions': instructions,
        if (cancellationReason != null)
          'cancellation_reason': cancellationReason,
        if (etaMinutes != null) 'eta_minutes': etaMinutes,
        if (distanceKm != null) 'distance_km': distanceKm,
        if (durationMinutes != null) 'duration_minutes': durationMinutes,
        if (carbonSavedGrams != null) 'carbon_saved_grams': carbonSavedGrams,
        if (statusDescription != null)
          'status_description': statusDescription,
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        bookingReference,
        serviceCode,
        status,
        pickupLocation,
        dropoffLocation,
        priceBreakdown,
        riderId,
        vehiclePlate,
        scheduledTime,
        etaMinutes,
      ];
}
