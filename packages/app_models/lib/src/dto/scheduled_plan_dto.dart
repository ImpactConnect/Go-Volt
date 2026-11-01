import 'package:equatable/equatable.dart';
import '../enums/scheduled_enums.dart';
import 'location_dto.dart';

/// Authorized contact for school-run or minor passenger safety verification.
class AuthorizedContactDto extends Equatable {
  const AuthorizedContactDto({
    required this.id,
    required this.name,
    required this.relationship,
    required this.phone,
    this.isPrimary = false,
    this.isVerified = true,
  });

  factory AuthorizedContactDto.fromJson(Map<String, dynamic> json) {
    return AuthorizedContactDto(
      id: json['id'] as String,
      name: json['name'] as String,
      relationship: json['relationship'] as String,
      phone: json['phone'] as String,
      isPrimary: json['is_primary'] as bool? ?? false,
      isVerified: json['is_verified'] as bool? ?? true,
    );
  }

  final String id;
  final String name;
  final String relationship; // e.g., 'Mother', 'Father', 'Teacher'
  final String phone;
  final bool isPrimary;
  final bool isVerified;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'relationship': relationship,
        'phone': phone,
        'is_primary': isPrimary,
        'is_verified': isVerified,
      };

  @override
  List<Object?> get props =>
      [id, name, relationship, phone, isPrimary, isVerified];
}

/// Outbound or return leg definition of a recurring plan (Section 21.2).
class ScheduledPlanLegDto extends Equatable {
  const ScheduledPlanLegDto({
    required this.id,
    required this.planId,
    required this.direction, // oneWay, roundTrip (outbound / return)
    required this.legSequence, // 1 for outbound, 2 for return
    required this.pickupLocation,
    required this.destinationLocation,
    required this.pickupTime,
    this.pickupInstructions,
    this.destinationInstructions,
    this.weekdays = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
  });

  factory ScheduledPlanLegDto.fromJson(Map<String, dynamic> json) {
    return ScheduledPlanLegDto(
      id: json['id'] as String,
      planId: json['plan_id'] as String,
      direction:
          JourneyDirection.fromString(json['direction'] as String?),
      legSequence: (json['leg_sequence'] as num?)?.toInt() ?? 1,
      pickupLocation: LocationDto.fromJson(
        json['pickup_location'] as Map<String, dynamic>,
      ),
      destinationLocation: LocationDto.fromJson(
        json['destination_location'] as Map<String, dynamic>,
      ),
      pickupTime: json['pickup_time'] as String,
      pickupInstructions: json['pickup_instructions'] as String?,
      destinationInstructions: json['destination_instructions'] as String?,
      weekdays: (json['weekdays'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
    );
  }

  final String id;
  final String planId;
  final JourneyDirection direction;
  final int legSequence;
  final LocationDto pickupLocation;
  final LocationDto destinationLocation;
  final String pickupTime;
  final String? pickupInstructions;
  final String? destinationInstructions;
  final List<String> weekdays;

  Map<String, dynamic> toJson() => {
        'id': id,
        'plan_id': planId,
        'direction': direction.value,
        'leg_sequence': legSequence,
        'pickup_location': pickupLocation.toJson(),
        'destination_location': destinationLocation.toJson(),
        'pickup_time': pickupTime,
        if (pickupInstructions != null)
          'pickup_instructions': pickupInstructions,
        if (destinationInstructions != null)
          'destination_instructions': destinationInstructions,
        'weekdays': weekdays,
      };

  @override
  List<Object?> get props =>
      [id, planId, direction, legSequence, pickupTime, weekdays];
}

/// Entitlement allowance account for pre-purchased package plans (Section 21.2).
class TripEntitlementAccountDto extends Equatable {
  const TripEntitlementAccountDto({
    required this.id,
    required this.planId,
    required this.customerId,
    required this.totalEntitlements,
    required this.usedEntitlements,
    required this.remainingEntitlements,
    required this.validFrom,
    required this.validUntil,
    this.status = 'ACTIVE',
  });

  factory TripEntitlementAccountDto.fromJson(Map<String, dynamic> json) {
    return TripEntitlementAccountDto(
      id: json['id'] as String,
      planId: json['plan_id'] as String,
      customerId: json['customer_id'] as String,
      totalEntitlements: (json['total_entitlements'] as num).toInt(),
      usedEntitlements: (json['used_entitlements'] as num).toInt(),
      remainingEntitlements: (json['remaining_entitlements'] as num).toInt(),
      validFrom: DateTime.parse(json['valid_from'] as String),
      validUntil: DateTime.parse(json['valid_until'] as String),
      status: json['status'] as String? ?? 'ACTIVE',
    );
  }

  final String id;
  final String planId;
  final String customerId;
  final int totalEntitlements;
  final int usedEntitlements;
  final int remainingEntitlements;
  final DateTime validFrom;
  final DateTime validUntil;
  final String status;

  Map<String, dynamic> toJson() => {
        'id': id,
        'plan_id': planId,
        'customer_id': customerId,
        'total_entitlements': totalEntitlements,
        'used_entitlements': usedEntitlements,
        'remaining_entitlements': remainingEntitlements,
        'valid_from': validFrom.toIso8601String(),
        'valid_until': validUntil.toIso8601String(),
        'status': status,
      };

  @override
  List<Object?> get props => [
        id,
        planId,
        totalEntitlements,
        usedEntitlements,
        remainingEntitlements,
        status,
      ];
}

/// Recurring Commute & School-Run subscription plan entity.
class ScheduledPlanDto extends Equatable {
  const ScheduledPlanDto({
    required this.id,
    required this.planReference,
    required this.planType, // 'COMMUTE_PLAN', 'SCHOOL_RUN_PLAN', 'ONE_OFF_FUTURE'
    required this.purpose,
    required this.title,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.scheduledDays,
    required this.pickupTime,
    this.returnTime,
    required this.passengerName,
    this.passengerPhone = '+234 803 123 4567',
    this.schoolName,
    this.legs = const [],
    required this.totalTrips,
    required this.usedTrips,
    required this.remainingTrips,
    required this.status, // PlanStatus
    required this.startDate,
    required this.expiryDate,
    this.packageId,
    this.billingModel = PackageBillingModel.payPerTrip,
    this.totalAmountNgn = 0,
    this.amountPaidNgn = 0,
    this.preferredRiderId,
    this.preferredRiderName,
    this.approvedQuoteId,
    this.paymentDeadlineAt,
    this.effectivePauseDate,
    this.renewalQuoteId,
    this.handoverOtp,
    this.handoverOtpExpiresAt,
    this.authorizedContacts = const [],
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory ScheduledPlanDto.fromJson(Map<String, dynamic> json) {
    return ScheduledPlanDto(
      id: json['id'] as String,
      planReference: json['plan_reference'] as String,
      planType: json['plan_type'] as String? ?? 'COMMUTE_PLAN',
      purpose: TripPurpose.fromString(json['purpose'] as String?),
      title: json['title'] as String,
      pickupLocation: LocationDto.fromJson(
        json['pickup_location'] as Map<String, dynamic>,
      ),
      dropoffLocation: LocationDto.fromJson(
        json['dropoff_location'] as Map<String, dynamic>,
      ),
      scheduledDays: (json['scheduled_days'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'],
      pickupTime: json['pickup_time'] as String,
      returnTime: json['return_time'] as String?,
      passengerName: json['passenger_name'] as String,
      passengerPhone:
          json['passenger_phone'] as String? ?? '+234 803 123 4567',
      schoolName: json['school_name'] as String?,
      legs: (json['legs'] as List<dynamic>?)
              ?.map((e) =>
                  ScheduledPlanLegDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      totalTrips: (json['total_trips'] as num).toInt(),
      usedTrips: (json['used_trips'] as num).toInt(),
      remainingTrips: (json['remaining_trips'] as num).toInt(),
      status: PlanStatus.fromString(json['status'] as String?),
      startDate: DateTime.parse(json['start_date'] as String),
      expiryDate: DateTime.parse(json['expiry_date'] as String),
      packageId: json['package_id'] as String?,
      billingModel:
          PackageBillingModel.fromString(json['billing_model'] as String?),
      totalAmountNgn: (json['total_amount_ngn'] as num?)?.toDouble() ?? 0,
      amountPaidNgn: (json['amount_paid_ngn'] as num?)?.toDouble() ?? 0,
      preferredRiderId: json['preferred_rider_id'] as String?,
      preferredRiderName: json['preferred_rider_name'] as String?,
      approvedQuoteId: json['approved_quote_id'] as String?,
      paymentDeadlineAt: (json['payment_deadline_at'] ?? json['approval_expires_at']) != null
          ? DateTime.tryParse(
              (json['payment_deadline_at'] ?? json['approval_expires_at'])
                  as String,
            )
          : null,
      effectivePauseDate: json['effective_pause_date'] != null
          ? DateTime.tryParse(json['effective_pause_date'] as String)
          : null,
      renewalQuoteId: json['renewal_quote_id'] as String?,
      handoverOtp: json['handover_otp'] as String?,
      handoverOtpExpiresAt: json['handover_otp_expires_at'] != null
          ? DateTime.tryParse(json['handover_otp_expires_at'] as String)
          : null,
      authorizedContacts: (json['authorized_contacts'] as List<dynamic>?)
              ?.map((e) =>
                  AuthorizedContactDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      notes: json['notes'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  final String id;
  final String planReference;
  final String planType;
  final TripPurpose purpose;
  final String title;
  final LocationDto pickupLocation;
  final LocationDto dropoffLocation;
  final List<String> scheduledDays;
  final String pickupTime;
  final String? returnTime;
  final String passengerName;
  final String passengerPhone;
  final String? schoolName;
  final List<ScheduledPlanLegDto> legs;
  final int totalTrips;
  final int usedTrips;
  final int remainingTrips;
  final PlanStatus status;
  final DateTime startDate;
  final DateTime expiryDate;
  final String? packageId;
  final PackageBillingModel billingModel;
  final double totalAmountNgn;
  final double amountPaidNgn;
  final String? preferredRiderId;
  final String? preferredRiderName;
  final String? approvedQuoteId;
  final DateTime? paymentDeadlineAt;
  final DateTime? effectivePauseDate;
  final String? renewalQuoteId;
  final String? handoverOtp;
  final DateTime? handoverOtpExpiresAt;
  final List<AuthorizedContactDto> authorizedContacts;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isSchoolRun => purpose == TripPurpose.schoolRun;
  bool get isActive => status == PlanStatus.active;
  bool get isPendingReview => status == PlanStatus.pendingReview;
  bool get isApprovedAwaitingPayment =>
      status == PlanStatus.approvedAwaitingPayment;
  bool get isPaused => status == PlanStatus.paused;
  bool get isPaid => amountPaidNgn >= totalAmountNgn && totalAmountNgn > 0;
  DateTime? get approvalExpiresAt => paymentDeadlineAt;
  DateTime? get pauseEffectiveDate => effectivePauseDate;
  DateTime? get paidAt => updatedAt;

  /// Usage progress ratio between 0.0 and 1.0.
  double get usageProgress =>
      totalTrips > 0 ? (usedTrips / totalTrips).clamp(0.0, 1.0) : 0.0;

  /// Baseline cutoff policy: 6 hours before scheduled pickup time.
  bool canSkipWithoutPenalty(DateTime tripDateTime, {DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    final difference = tripDateTime.difference(currentTime);
    return difference.inHours >= 6;
  }

  ScheduledPlanDto copyWith({
    PlanStatus? status,
    int? usedTrips,
    int? remainingTrips,
    double? amountPaidNgn,
    DateTime? effectivePauseDate,
    DateTime? pauseEffectiveDate,
    DateTime? approvalExpiresAt,
    bool? isPaid,
    DateTime? paidAt,
    String? handoverOtp,
    DateTime? handoverOtpExpiresAt,
    String? preferredRiderId,
    String? preferredRiderName,
  }) {
    return ScheduledPlanDto(
      id: id,
      planReference: planReference,
      planType: planType,
      purpose: purpose,
      title: title,
      pickupLocation: pickupLocation,
      dropoffLocation: dropoffLocation,
      scheduledDays: scheduledDays,
      pickupTime: pickupTime,
      returnTime: returnTime,
      passengerName: passengerName,
      passengerPhone: passengerPhone,
      schoolName: schoolName,
      legs: legs,
      totalTrips: totalTrips,
      usedTrips: usedTrips ?? this.usedTrips,
      remainingTrips: remainingTrips ?? this.remainingTrips,
      status: status ?? this.status,
      startDate: startDate,
      expiryDate: expiryDate,
      packageId: packageId,
      billingModel: billingModel,
      totalAmountNgn: totalAmountNgn,
      amountPaidNgn: (isPaid == true && totalAmountNgn > 0)
          ? totalAmountNgn
          : (amountPaidNgn ?? this.amountPaidNgn),
      preferredRiderId: preferredRiderId ?? this.preferredRiderId,
      preferredRiderName: preferredRiderName ?? this.preferredRiderName,
      approvedQuoteId: approvedQuoteId,
      paymentDeadlineAt: approvalExpiresAt ?? paymentDeadlineAt,
      effectivePauseDate:
          pauseEffectiveDate ?? effectivePauseDate ?? this.effectivePauseDate,
      renewalQuoteId: renewalQuoteId,
      handoverOtp: handoverOtp ?? this.handoverOtp,
      handoverOtpExpiresAt: handoverOtpExpiresAt ?? this.handoverOtpExpiresAt,
      authorizedContacts: authorizedContacts,
      notes: notes,
      createdAt: createdAt,
      updatedAt: paidAt ?? updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'plan_reference': planReference,
        'plan_type': planType,
        'purpose': purpose.value,
        'title': title,
        'pickup_location': pickupLocation.toJson(),
        'dropoff_location': dropoffLocation.toJson(),
        'scheduled_days': scheduledDays,
        'pickup_time': pickupTime,
        if (returnTime != null) 'return_time': returnTime,
        'passenger_name': passengerName,
        'passenger_phone': passengerPhone,
        if (schoolName != null) 'school_name': schoolName,
        'legs': legs.map((l) => l.toJson()).toList(),
        'total_trips': totalTrips,
        'used_trips': usedTrips,
        'remaining_trips': remainingTrips,
        'status': status.value,
        'start_date': startDate.toIso8601String(),
        'expiry_date': expiryDate.toIso8601String(),
        if (packageId != null) 'package_id': packageId,
        'billing_model': billingModel.value,
        'total_amount_ngn': totalAmountNgn,
        'amount_paid_ngn': amountPaidNgn,
        if (preferredRiderId != null) 'preferred_rider_id': preferredRiderId,
        if (preferredRiderName != null)
          'preferred_rider_name': preferredRiderName,
        if (approvedQuoteId != null) 'approved_quote_id': approvedQuoteId,
        if (paymentDeadlineAt != null) ...{
          'payment_deadline_at': paymentDeadlineAt!.toIso8601String(),
          'approval_expires_at': paymentDeadlineAt!.toIso8601String(),
        },
        if (effectivePauseDate != null)
          'effective_pause_date': effectivePauseDate!.toIso8601String(),
        if (renewalQuoteId != null) 'renewal_quote_id': renewalQuoteId,
        if (handoverOtp != null) 'handover_otp': handoverOtp,
        if (handoverOtpExpiresAt != null)
          'handover_otp_expires_at': handoverOtpExpiresAt!.toIso8601String(),
        'authorized_contacts':
            authorizedContacts.map((c) => c.toJson()).toList(),
        if (notes != null) 'notes': notes,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        planReference,
        planType,
        purpose,
        title,
        status,
        remainingTrips,
        handoverOtp,
        amountPaidNgn,
      ];
}
