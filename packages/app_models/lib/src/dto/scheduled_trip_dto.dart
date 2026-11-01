import 'package:equatable/equatable.dart';
import '../enums/scheduled_enums.dart';
import 'location_dto.dart';
import 'rider_dto.dart';

/// Single milestone along a scheduled trip's execution path (e.g. for School Run).
class ScheduledMilestoneDto extends Equatable {
  const ScheduledMilestoneDto({
    required this.id,
    required this.title,
    required this.timeStr,
    this.isCompleted = false,
    this.isCurrent = false,
    this.timestamp,
  });

  factory ScheduledMilestoneDto.fromJson(Map<String, dynamic> json) {
    return ScheduledMilestoneDto(
      id: json['id'] as String,
      title: json['title'] as String,
      timeStr: json['time_str'] as String,
      isCompleted: json['is_completed'] as bool? ?? false,
      isCurrent: json['is_current'] as bool? ?? false,
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String)
          : null,
    );
  }

  final String id;
  final String title;
  final String timeStr;
  final bool isCompleted;
  final bool isCurrent;
  final DateTime? timestamp;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'time_str': timeStr,
        'is_completed': isCompleted,
        'is_current': isCurrent,
        if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, title, timeStr, isCompleted, isCurrent];
}

/// Concrete scheduled journey entity representing an individual trip execution.
class ScheduledTripDto extends Equatable {
  const ScheduledTripDto({
    required this.id,
    required this.tripReference,
    this.planId,
    this.planLegId,
    required this.customerId,
    this.passengerProfileId,
    required this.tripPurpose,
    this.journeyDirection = JourneyDirection.oneWay,
    this.legSequence = 1,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.scheduledPickupAt,
    required this.scheduledDateStr,
    required this.scheduledTimeStr,
    required this.status,
    this.assignedDriver,
    required this.passengerName,
    required this.passengerPhone,
    this.specialInstructions,
    required this.quoteId,
    required this.fareNgn,
    this.isSchoolRun = false,
    this.handoverCode,
    this.handoverStatus = HandoverStatus.notStarted,
    this.handoverRecipientName,
    this.handoverRecipientRole,
    this.handoverConfirmedAt,
    this.milestones = const [],
    this.waitingTimeRemainingSeconds,
    this.paymentStatus = 'PAID',
    this.paymentMethod = 'Go-Volts Wallet',
    this.transactionId,
    this.paidAt,
    this.skipReason,
    this.cancelledAt,
  });

  factory ScheduledTripDto.fromJson(Map<String, dynamic> json) {
    return ScheduledTripDto(
      id: json['id'] as String,
      tripReference: json['trip_reference'] as String,
      planId: json['plan_id'] as String?,
      planLegId: json['plan_leg_id'] as String?,
      customerId: json['customer_id'] as String,
      passengerProfileId: json['passenger_profile_id'] as String?,
      tripPurpose: TripPurpose.fromString(json['trip_purpose'] as String?),
      journeyDirection:
          JourneyDirection.fromString(json['journey_direction'] as String?),
      legSequence: (json['leg_sequence'] as num?)?.toInt() ?? 1,
      pickupLocation: LocationDto.fromJson(
        json['pickup_location'] as Map<String, dynamic>,
      ),
      destinationLocation: LocationDto.fromJson(
        json['destination_location'] as Map<String, dynamic>,
      ),
      scheduledPickupAt: DateTime.parse(json['scheduled_pickup_at'] as String),
      scheduledDateStr: json['scheduled_date_str'] as String,
      scheduledTimeStr: json['scheduled_time_str'] as String,
      status: ScheduledTripStatus.fromString(json['status'] as String?),
      assignedDriver: json['assigned_driver'] != null
          ? RiderDto.fromJson(json['assigned_driver'] as Map<String, dynamic>)
          : null,
      passengerName: json['passenger_name'] as String,
      passengerPhone: json['passenger_phone'] as String,
      specialInstructions: json['special_instructions'] as String?,
      quoteId: json['quote_id'] as String,
      fareNgn: (json['fare_ngn'] as num).toDouble(),
      isSchoolRun: json['is_school_run'] as bool? ?? false,
      handoverCode: json['handover_code'] as String?,
      handoverStatus:
          HandoverStatus.fromString(json['handover_status'] as String?),
      handoverRecipientName: json['handover_recipient_name'] as String?,
      handoverRecipientRole: json['handover_recipient_role'] as String?,
      handoverConfirmedAt: json['handover_confirmed_at'] != null
          ? DateTime.tryParse(json['handover_confirmed_at'] as String)
          : null,
      milestones: (json['milestones'] as List<dynamic>?)
              ?.map((e) =>
                  ScheduledMilestoneDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      waitingTimeRemainingSeconds:
          (json['waiting_time_remaining_seconds'] as num?)?.toInt(),
      paymentStatus: json['payment_status'] as String? ?? 'PAID',
      paymentMethod:
          json['payment_method'] as String? ?? 'Go-Volts Wallet',
      transactionId: json['transaction_id'] as String?,
      paidAt: json['paid_at'] != null
          ? DateTime.tryParse(json['paid_at'] as String)
          : null,
      skipReason: json['skip_reason'] as String?,
      cancelledAt: json['cancelled_at'] != null
          ? DateTime.tryParse(json['cancelled_at'] as String)
          : null,
    );
  }

  final String id;
  final String tripReference;
  final String? planId;
  final String? planLegId;
  final String customerId;
  final String? passengerProfileId;
  final TripPurpose tripPurpose;
  final JourneyDirection journeyDirection;
  final int legSequence;
  final LocationDto pickupLocation;
  final LocationDto destinationLocation;
  final DateTime scheduledPickupAt;
  final String scheduledDateStr;
  final String scheduledTimeStr;
  final ScheduledTripStatus status;
  final RiderDto? assignedDriver;
  final String passengerName;
  final String passengerPhone;
  final String? specialInstructions;
  final String quoteId;
  final double fareNgn;
  final bool isSchoolRun;
  final String? handoverCode;
  final HandoverStatus handoverStatus;
  final String? handoverRecipientName;
  final String? handoverRecipientRole;
  final DateTime? handoverConfirmedAt;
  final List<ScheduledMilestoneDto> milestones;
  final int? waitingTimeRemainingSeconds;
  final String paymentStatus;
  final String paymentMethod;
  final String? transactionId;
  final DateTime? paidAt;
  final String? skipReason;
  final DateTime? cancelledAt;

  bool get isAssigned => assignedDriver != null;
  bool get isCompleted => status == ScheduledTripStatus.completed;
  bool get isCancelled => status == ScheduledTripStatus.cancelled;
  bool get isSkipped => status == ScheduledTripStatus.skipped;

  String get pickupAddress => pickupLocation.address;
  String get destinationAddress => destinationLocation.address;
  String get planTitle => isSchoolRun ? 'School Run' : tripPurpose.label;
  TripPurpose get purpose => tripPurpose;

  /// Section 21.3 invariant: Skip is eligible without penalty only >= 6 hours before pickup.
  bool canSkipWithoutPenalty({DateTime? now}) {
    final current = now ?? DateTime.now();
    return scheduledPickupAt.difference(current).inHours >= 6;
  }

  ScheduledTripDto copyWith({
    ScheduledTripStatus? status,
    RiderDto? assignedDriver,
    HandoverStatus? handoverStatus,
    String? handoverRecipientName,
    String? handoverRecipientRole,
    DateTime? handoverConfirmedAt,
    int? waitingTimeRemainingSeconds,
    List<ScheduledMilestoneDto>? milestones,
    String? skipReason,
    DateTime? cancelledAt,
  }) {
    return ScheduledTripDto(
      id: id,
      tripReference: tripReference,
      planId: planId,
      planLegId: planLegId,
      customerId: customerId,
      passengerProfileId: passengerProfileId,
      tripPurpose: tripPurpose,
      journeyDirection: journeyDirection,
      legSequence: legSequence,
      pickupLocation: pickupLocation,
      destinationLocation: destinationLocation,
      scheduledPickupAt: scheduledPickupAt,
      scheduledDateStr: scheduledDateStr,
      scheduledTimeStr: scheduledTimeStr,
      status: status ?? this.status,
      assignedDriver: assignedDriver ?? this.assignedDriver,
      passengerName: passengerName,
      passengerPhone: passengerPhone,
      specialInstructions: specialInstructions,
      quoteId: quoteId,
      fareNgn: fareNgn,
      isSchoolRun: isSchoolRun,
      handoverCode: handoverCode,
      handoverStatus: handoverStatus ?? this.handoverStatus,
      handoverRecipientName:
          handoverRecipientName ?? this.handoverRecipientName,
      handoverRecipientRole:
          handoverRecipientRole ?? this.handoverRecipientRole,
      handoverConfirmedAt: handoverConfirmedAt ?? this.handoverConfirmedAt,
      milestones: milestones ?? this.milestones,
      waitingTimeRemainingSeconds:
          waitingTimeRemainingSeconds ?? this.waitingTimeRemainingSeconds,
      paymentStatus: paymentStatus,
      paymentMethod: paymentMethod,
      transactionId: transactionId,
      paidAt: paidAt,
      skipReason: skipReason ?? this.skipReason,
      cancelledAt: cancelledAt ?? this.cancelledAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'trip_reference': tripReference,
        if (planId != null) 'plan_id': planId,
        if (planLegId != null) 'plan_leg_id': planLegId,
        'customer_id': customerId,
        if (passengerProfileId != null)
          'passenger_profile_id': passengerProfileId,
        'trip_purpose': tripPurpose.value,
        'journey_direction': journeyDirection.value,
        'leg_sequence': legSequence,
        'pickup_location': pickupLocation.toJson(),
        'destination_location': destinationLocation.toJson(),
        'scheduled_pickup_at': scheduledPickupAt.toIso8601String(),
        'scheduled_date_str': scheduledDateStr,
        'scheduled_time_str': scheduledTimeStr,
        'status': status.value,
        if (assignedDriver != null)
          'assigned_driver': assignedDriver!.toJson(),
        'passenger_name': passengerName,
        'passenger_phone': passengerPhone,
        if (specialInstructions != null)
          'special_instructions': specialInstructions,
        'quote_id': quoteId,
        'fare_ngn': fareNgn,
        'is_school_run': isSchoolRun,
        if (handoverCode != null) 'handover_code': handoverCode,
        'handover_status': handoverStatus.value,
        if (handoverRecipientName != null)
          'handover_recipient_name': handoverRecipientName,
        if (handoverRecipientRole != null)
          'handover_recipient_role': handoverRecipientRole,
        if (handoverConfirmedAt != null)
          'handover_confirmed_at': handoverConfirmedAt!.toIso8601String(),
        'milestones': milestones.map((m) => m.toJson()).toList(),
        if (waitingTimeRemainingSeconds != null)
          'waiting_time_remaining_seconds': waitingTimeRemainingSeconds,
        'payment_status': paymentStatus,
        'payment_method': paymentMethod,
        if (transactionId != null) 'transaction_id': transactionId,
        if (paidAt != null) 'paid_at': paidAt!.toIso8601String(),
        if (skipReason != null) 'skip_reason': skipReason,
        if (cancelledAt != null) 'cancelled_at': cancelledAt!.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        id,
        tripReference,
        status,
        scheduledPickupAt,
        assignedDriver,
        handoverStatus,
      ];
}
