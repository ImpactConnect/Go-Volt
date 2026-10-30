import 'package:equatable/equatable.dart';
import 'rider_dto.dart';

/// Status of a live dispatch offer sent to a rider.
enum DispatchOfferStatus {
  pending('PENDING', 'Pending Decision'),
  accepted('ACCEPTED', 'Accepted'),
  declined('DECLINED', 'Declined by Rider'),
  expired('EXPIRED', 'Offer Expired'),
  conflict('CONFLICT', 'Claimed by Another Rider');

  const DispatchOfferStatus(this.code, this.label);
  final String code;
  final String label;

  static DispatchOfferStatus fromString(String raw) {
    return DispatchOfferStatus.values.firstWhere(
      (s) => s.code == raw || s.name == raw,
      orElse: () => DispatchOfferStatus.pending,
    );
  }
}

/// Standardized rejection reasons for telemetry & dispatch feedback.
enum DispatchDeclineReason {
  batteryLow('BATTERY_LOW', 'Low battery / routing to swap kiosk'),
  distanceTooFar('DISTANCE_TOO_FAR', 'Pickup location is too far away'),
  shiftEnding('SHIFT_ENDING', 'Ending active shift / going offline'),
  trafficCongestion('TRAFFIC', 'Severe gridlock on route to pickup'),
  unsafeArea('UNSAFE_AREA', 'Safety or security concern in zone'),
  personalEmergency('EMERGENCY', 'Personal or vehicle emergency'),
  other('OTHER', 'Other operational reason');

  const DispatchDeclineReason(this.code, this.label);
  final String code;
  final String label;

  static DispatchDeclineReason fromString(String raw) {
    return DispatchDeclineReason.values.firstWhere(
      (r) => r.code == raw || r.name == raw,
      orElse: () => DispatchDeclineReason.other,
    );
  }
}

/// Dispatch offer presented to a rider when a booking/delivery match occurs.
class DispatchOfferDto extends Equatable {
  const DispatchOfferDto({
    required this.id,
    required this.jobId,
    required this.serviceType,
    required this.customerName,
    required this.grossFareKobo,
    required this.netEarningsKobo,
    required this.pickupAddress,
    required this.pickupDistanceKm,
    required this.pickupEtaMinutes,
    required this.dropoffAddress,
    required this.tripDistanceKm,
    required this.estimatedTripMinutes,
    this.paymentMethod = 'Wallet',
    required this.expiresAt,
    this.timeoutSeconds = 15,
    this.surgeMultiplier = 1.0,
    this.status = DispatchOfferStatus.pending,
    this.parcelDescription,
    this.packageWeightKg,
    this.isFragile = false,
    this.recipientPhone,
    this.childName,
    this.schoolName,
    this.guardianPhone,
    this.requiresOtp = false,
  });

  factory DispatchOfferDto.fromJson(Map<String, dynamic> json) {
    return DispatchOfferDto(
      id: json['id'] as String,
      jobId: json['job_id'] as String,
      serviceType: ServiceTierEligibility.fromString(
        json['service_type'] as String? ?? 'PARCEL_DELIVERY',
      ),
      customerName: json['customer_name'] as String? ?? 'Customer',
      grossFareKobo: (json['gross_fare_kobo'] as num?)?.toInt() ?? 0,
      netEarningsKobo: (json['net_earnings_kobo'] as num?)?.toInt() ?? 0,
      pickupAddress: json['pickup_address'] as String,
      pickupDistanceKm: (json['pickup_distance_km'] as num?)?.toDouble() ?? 1.0,
      pickupEtaMinutes: (json['pickup_eta_minutes'] as num?)?.toInt() ?? 3,
      dropoffAddress: json['dropoff_address'] as String,
      tripDistanceKm: (json['trip_distance_km'] as num?)?.toDouble() ?? 5.0,
      estimatedTripMinutes:
          (json['estimated_trip_minutes'] as num?)?.toInt() ?? 15,
      paymentMethod: json['payment_method'] as String? ?? 'Wallet',
      expiresAt: DateTime.parse(json['expires_at'] as String),
      timeoutSeconds: (json['timeout_seconds'] as num?)?.toInt() ?? 15,
      surgeMultiplier: (json['surge_multiplier'] as num?)?.toDouble() ?? 1.0,
      status: DispatchOfferStatus.fromString(
        json['status'] as String? ?? 'PENDING',
      ),
      parcelDescription: json['parcel_description'] as String?,
      packageWeightKg: (json['package_weight_kg'] as num?)?.toDouble(),
      isFragile: json['is_fragile'] as bool? ?? false,
      recipientPhone: json['recipient_phone'] as String?,
      childName: json['child_name'] as String?,
      schoolName: json['school_name'] as String?,
      guardianPhone: json['guardian_phone'] as String?,
      requiresOtp: json['requires_otp'] as bool? ?? false,
    );
  }

  final String id;
  final String jobId;
  final ServiceTierEligibility serviceType;
  final String customerName;
  final int grossFareKobo;
  final int netEarningsKobo;
  final String pickupAddress;
  final double pickupDistanceKm;
  final int pickupEtaMinutes;
  final String dropoffAddress;
  final double tripDistanceKm;
  final int estimatedTripMinutes;
  final String paymentMethod;
  final DateTime expiresAt;
  final int timeoutSeconds;
  final double surgeMultiplier;
  final DispatchOfferStatus status;

  // Delivery-specific attributes
  final String? parcelDescription;
  final double? packageWeightKg;
  final bool isFragile;
  final String? recipientPhone;

  // School-Run specific attributes
  final String? childName;
  final String? schoolName;
  final String? guardianPhone;
  final bool requiresOtp;

  double get netEarningsNaira => netEarningsKobo / 100.0;
  double get grossFareNaira => grossFareKobo / 100.0;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  int get remainingSeconds {
    final diff = expiresAt.difference(DateTime.now()).inSeconds;
    return diff > 0 ? diff : 0;
  }

  DispatchOfferDto copyWith({
    DispatchOfferStatus? status,
  }) {
    return DispatchOfferDto(
      id: id,
      jobId: jobId,
      serviceType: serviceType,
      customerName: customerName,
      grossFareKobo: grossFareKobo,
      netEarningsKobo: netEarningsKobo,
      pickupAddress: pickupAddress,
      pickupDistanceKm: pickupDistanceKm,
      pickupEtaMinutes: pickupEtaMinutes,
      dropoffAddress: dropoffAddress,
      tripDistanceKm: tripDistanceKm,
      estimatedTripMinutes: estimatedTripMinutes,
      paymentMethod: paymentMethod,
      expiresAt: expiresAt,
      timeoutSeconds: timeoutSeconds,
      surgeMultiplier: surgeMultiplier,
      status: status ?? this.status,
      parcelDescription: parcelDescription,
      packageWeightKg: packageWeightKg,
      isFragile: isFragile,
      recipientPhone: recipientPhone,
      childName: childName,
      schoolName: schoolName,
      guardianPhone: guardianPhone,
      requiresOtp: requiresOtp,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'job_id': jobId,
    'service_type': serviceType.code,
    'customer_name': customerName,
    'gross_fare_kobo': grossFareKobo,
    'net_earnings_kobo': netEarningsKobo,
    'pickup_address': pickupAddress,
    'pickup_distance_km': pickupDistanceKm,
    'pickup_eta_minutes': pickupEtaMinutes,
    'dropoff_address': dropoffAddress,
    'trip_distance_km': tripDistanceKm,
    'estimated_trip_minutes': estimatedTripMinutes,
    'payment_method': paymentMethod,
    'expires_at': expiresAt.toIso8601String(),
    'timeout_seconds': timeoutSeconds,
    'surge_multiplier': surgeMultiplier,
    'status': status.code,
    if (parcelDescription != null) 'parcel_description': parcelDescription,
    if (packageWeightKg != null) 'package_weight_kg': packageWeightKg,
    'is_fragile': isFragile,
    if (recipientPhone != null) 'recipient_phone': recipientPhone,
    if (childName != null) 'child_name': childName,
    if (schoolName != null) 'school_name': schoolName,
    if (guardianPhone != null) 'guardian_phone': guardianPhone,
    'requires_otp': requiresOtp,
  };

  @override
  List<Object?> get props => [
    id,
    jobId,
    serviceType,
    customerName,
    grossFareKobo,
    netEarningsKobo,
    pickupAddress,
    pickupDistanceKm,
    pickupEtaMinutes,
    dropoffAddress,
    tripDistanceKm,
    estimatedTripMinutes,
    paymentMethod,
    expiresAt,
    timeoutSeconds,
    surgeMultiplier,
    status,
    parcelDescription,
    packageWeightKg,
    isFragile,
    recipientPhone,
    childName,
    schoolName,
    guardianPhone,
    requiresOtp,
  ];
}
