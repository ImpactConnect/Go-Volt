import 'package:equatable/equatable.dart';
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
  final String relationship; // e.g., 'Mother', 'Father', 'Aunt'
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
  List<Object?> get props => [id, name, relationship, phone, isPrimary, isVerified];
}

/// Recurring Commute & School-Run subscription plan entity.
class ScheduledPlanDto extends Equatable {
  const ScheduledPlanDto({
    required this.id,
    required this.planReference,
    required this.planType, // 'COMMUTE_PLAN', 'SCHOOL_RUN_PLAN', 'ONE_OFF_FUTURE'
    required this.title,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.scheduledDays,
    required this.pickupTime,
    this.returnTime,
    required this.passengerName,
    this.schoolName,
    required this.totalTrips,
    required this.usedTrips,
    required this.remainingTrips,
    required this.status, // 'ACTIVE', 'PENDING_REVIEW', 'PAUSED', 'EXPIRED', 'CANCELLED'
    required this.startDate,
    required this.expiryDate,
    this.handoverOtp,
    this.handoverOtpExpiresAt,
    this.authorizedContacts = const [],
    this.notes,
  });

  factory ScheduledPlanDto.fromJson(Map<String, dynamic> json) {
    return ScheduledPlanDto(
      id: json['id'] as String,
      planReference: json['plan_reference'] as String,
      planType: json['plan_type'] as String,
      title: json['title'] as String,
      pickupLocation: LocationDto.fromJson(
        json['pickup_location'] as Map<String, dynamic>,
      ),
      dropoffLocation: LocationDto.fromJson(
        json['dropoff_location'] as Map<String, dynamic>,
      ),
      scheduledDays: (json['scheduled_days'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      pickupTime: json['pickup_time'] as String,
      returnTime: json['return_time'] as String?,
      passengerName: json['passenger_name'] as String,
      schoolName: json['school_name'] as String?,
      totalTrips: (json['total_trips'] as num).toInt(),
      usedTrips: (json['used_trips'] as num).toInt(),
      remainingTrips: (json['remaining_trips'] as num).toInt(),
      status: json['status'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      expiryDate: DateTime.parse(json['expiry_date'] as String),
      handoverOtp: json['handover_otp'] as String?,
      handoverOtpExpiresAt: json['handover_otp_expires_at'] != null
          ? DateTime.parse(json['handover_otp_expires_at'] as String)
          : null,
      authorizedContacts: (json['authorized_contacts'] as List<dynamic>?)
              ?.map((e) =>
                  AuthorizedContactDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      notes: json['notes'] as String?,
    );
  }

  final String id;
  final String planReference;
  final String planType;
  final String title;
  final LocationDto pickupLocation;
  final LocationDto dropoffLocation;
  final List<String> scheduledDays;
  final String pickupTime;
  final String? returnTime;
  final String passengerName;
  final String? schoolName;
  final int totalTrips;
  final int usedTrips;
  final int remainingTrips;
  final String status;
  final DateTime startDate;
  final DateTime expiryDate;
  final String? handoverOtp;
  final DateTime? handoverOtpExpiresAt;
  final List<AuthorizedContactDto> authorizedContacts;
  final String? notes;

  bool get isSchoolRun => planType == 'SCHOOL_RUN_PLAN';
  bool get isActive => status == 'ACTIVE';
  bool get isPendingReview => status == 'PENDING_REVIEW';
  bool get isPaused => status == 'PAUSED';

  /// Baseline cutoff policy: 6 hours before scheduled pickup time.
  /// If skip requested before 6 hours, entitlement is preserved.
  /// If after, entitlement is forfeited per published terms.
  bool canSkipWithoutPenalty(DateTime tripDateTime, {DateTime? now}) {
    final currentTime = now ?? DateTime.now();
    final difference = tripDateTime.difference(currentTime);
    return difference.inHours >= 6;
  }

  ScheduledPlanDto copyWith({
    String? status,
    int? usedTrips,
    int? remainingTrips,
    String? handoverOtp,
    DateTime? handoverOtpExpiresAt,
  }) {
    return ScheduledPlanDto(
      id: id,
      planReference: planReference,
      planType: planType,
      title: title,
      pickupLocation: pickupLocation,
      dropoffLocation: dropoffLocation,
      scheduledDays: scheduledDays,
      pickupTime: pickupTime,
      returnTime: returnTime,
      passengerName: passengerName,
      schoolName: schoolName,
      totalTrips: totalTrips,
      usedTrips: usedTrips ?? this.usedTrips,
      remainingTrips: remainingTrips ?? this.remainingTrips,
      status: status ?? this.status,
      startDate: startDate,
      expiryDate: expiryDate,
      handoverOtp: handoverOtp ?? this.handoverOtp,
      handoverOtpExpiresAt: handoverOtpExpiresAt ?? this.handoverOtpExpiresAt,
      authorizedContacts: authorizedContacts,
      notes: notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'plan_reference': planReference,
        'plan_type': planType,
        'title': title,
        'pickup_location': pickupLocation.toJson(),
        'dropoff_location': dropoffLocation.toJson(),
        'scheduled_days': scheduledDays,
        'pickup_time': pickupTime,
        if (returnTime != null) 'return_time': returnTime,
        'passenger_name': passengerName,
        if (schoolName != null) 'school_name': schoolName,
        'total_trips': totalTrips,
        'used_trips': usedTrips,
        'remaining_trips': remainingTrips,
        'status': status,
        'start_date': startDate.toIso8601String(),
        'expiry_date': expiryDate.toIso8601String(),
        if (handoverOtp != null) 'handover_otp': handoverOtp,
        if (handoverOtpExpiresAt != null)
          'handover_otp_expires_at': handoverOtpExpiresAt!.toIso8601String(),
        'authorized_contacts':
            authorizedContacts.map((c) => c.toJson()).toList(),
        if (notes != null) 'notes': notes,
      };

  @override
  List<Object?> get props => [
        id,
        planReference,
        planType,
        title,
        status,
        remainingTrips,
        handoverOtp,
      ];
}
