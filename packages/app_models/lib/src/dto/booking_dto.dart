import 'package:equatable/equatable.dart';
import '../enums/booking_status.dart';
import '../enums/domain_enums.dart';
import '../enums/service_code.dart';
import 'location_dto.dart';
import 'price_quote_dto.dart';

/// Full Go-Volts booking entity representing Rides, Deliveries, and Pickups.
class BookingDto extends Equatable {

  factory BookingDto.fromJson(Map<String, dynamic> json) {
    return BookingDto(
      id: json['id'] as String,
      bookingReference: json['booking_reference'] as String? ?? 'GV-${json['id']}',
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
      scheduledTime: json['scheduled_time'] != null
          ? DateTime.parse(json['scheduled_time'] as String)
          : null,
      riderId: json['rider_id'] as String?,
      riderName: json['rider_name'] as String?,
      riderPhone: json['rider_phone'] as String?,
      riderAvatarUrl: json['rider_avatar_url'] as String?,
      riderRating: (json['rider_rating'] as num?)?.toDouble(),
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
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
  const BookingDto({
    required this.id,
    required this.bookingReference,
    required this.serviceCode,
    required this.status,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.priceBreakdown,
    required this.createdAt,
    this.scheduledTime,
    this.riderId,
    this.riderName,
    this.riderPhone,
    this.riderAvatarUrl,
    this.riderRating,
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
    this.updatedAt,
  });

  final String id;
  final String bookingReference;
  final ServiceCode serviceCode;
  final BookingStatus status;
  final LocationDto pickupLocation;
  final LocationDto dropoffLocation;
  final PriceBreakdownDto priceBreakdown;
  final DateTime createdAt;
  final DateTime? scheduledTime;
  final String? riderId;
  final String? riderName;
  final String? riderPhone;
  final String? riderAvatarUrl;
  final double? riderRating;
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
  final DateTime? updatedAt;

  bool get isScheduled => scheduledTime != null;
  bool get hasAssignedRider => riderId != null && riderId!.isNotEmpty;
  bool get isTerminal => status.isTerminal;

  Map<String, dynamic> toJson() => {
        'id': id,
        'booking_reference': bookingReference,
        'service_code': serviceCode.code,
        'status': status.code,
        'pickup_location': pickupLocation.toJson(),
        'dropoff_location': dropoffLocation.toJson(),
        'price_breakdown': priceBreakdown.toJson(),
        'created_at': createdAt.toIso8601String(),
        if (scheduledTime != null)
          'scheduled_time': scheduledTime!.toIso8601String(),
        if (riderId != null) 'rider_id': riderId,
        if (riderName != null) 'rider_name': riderName,
        if (riderPhone != null) 'rider_phone': riderPhone,
        if (riderAvatarUrl != null) 'rider_avatar_url': riderAvatarUrl,
        if (riderRating != null) 'rider_rating': riderRating,
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
      ];
}
