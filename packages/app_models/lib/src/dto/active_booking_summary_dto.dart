import 'package:equatable/equatable.dart';
import '../enums/booking_status.dart';
import '../enums/service_code.dart';

/// Summary of an active booking for dynamic hero rendering on the Home Dashboard.
class ActiveBookingSummaryDto extends Equatable {
  const ActiveBookingSummaryDto({
    required this.bookingId,
    required this.referenceCode,
    this.serviceType = ServiceCode.instantRide,
    this.serviceTitle = 'Ride booking',
    this.status = BookingStatus.assigned,
    this.statusBadge = 'In progress',
    this.riderName,
    this.riderAvatarUrl,
    this.statusMessage = 'Rider approaching',
    this.etaMinutes = 3,
    this.targetRoute = '/live-tracking',
  });

  factory ActiveBookingSummaryDto.fromJson(Map<String, dynamic> json) {
    return ActiveBookingSummaryDto(
      bookingId: json['booking_id'] as String,
      referenceCode: json['reference_code'] as String,
      serviceType: ServiceCode.fromString(json['service_type'] as String? ?? 'RIDE_INSTANT'),
      serviceTitle: json['service_title'] as String? ?? 'Ride booking',
      status: BookingStatus.fromString(json['status'] as String? ?? 'DRIVER_ASSIGNED'),
      statusBadge: json['status_badge'] as String? ?? 'In progress',
      riderName: json['rider_name'] as String?,
      riderAvatarUrl: json['rider_avatar_url'] as String?,
      statusMessage: json['status_message'] as String? ?? 'Rider approaching',
      etaMinutes: json['eta_minutes'] as int?,
      targetRoute: json['target_route'] as String? ?? '/live-tracking',
    );
  }

  final String bookingId;
  final String referenceCode;
  final ServiceCode serviceType;
  final String serviceTitle;
  final BookingStatus status;
  final String statusBadge;
  final String? riderName;
  final String? riderAvatarUrl;
  final String statusMessage;
  final int? etaMinutes;
  final String targetRoute;

  String get etaText => etaMinutes != null ? 'ETA $etaMinutes mins' : 'En route';

  Map<String, dynamic> toJson() => {
        'booking_id': bookingId,
        'reference_code': referenceCode,
        'service_type': serviceType.code,
        'service_title': serviceTitle,
        'status': status.code,
        'status_badge': statusBadge,
        if (riderName != null) 'rider_name': riderName,
        if (riderAvatarUrl != null) 'rider_avatar_url': riderAvatarUrl,
        'status_message': statusMessage,
        if (etaMinutes != null) 'eta_minutes': etaMinutes,
        'target_route': targetRoute,
      };

  @override
  List<Object?> get props => [
        bookingId,
        referenceCode,
        serviceType,
        serviceTitle,
        status,
        statusBadge,
        riderName,
        riderAvatarUrl,
        statusMessage,
        etaMinutes,
        targetRoute,
      ];
}
