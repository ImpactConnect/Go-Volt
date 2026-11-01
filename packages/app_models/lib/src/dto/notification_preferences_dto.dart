import 'package:equatable/equatable.dart';

/// Customer notification preferences grouped strictly by Go-Volts service (§B2).
class NotificationPreferencesDto extends Equatable {
  const NotificationPreferencesDto({
    // Ride Notifications
    this.rideBookingUpdates = true,
    this.rideRiderAssigned = true,
    this.rideTripStatus = true,

    // Parcel Delivery Notifications
    this.parcelDeliveryUpdates = true,
    this.parcelRiderAssigned = true,
    this.parcelDeliveryCompletion = true,

    // Market Errand Notifications
    this.errandAgentUpdates = true,
    this.errandShoppingUpdates = true,
    this.errandPaymentUpdates = true,

    // General & Account Notifications
    this.rewardsAndPoints = true,
    this.promotionsAndCoupons = false,
    this.securityAndAccountAlerts = true,
    this.smsDispatchAlerts = true,
    this.schoolRunSecurityAlerts = true,
  });

  factory NotificationPreferencesDto.fromJson(Map<String, dynamic> json) {
    return NotificationPreferencesDto(
      rideBookingUpdates: json['ride_booking_updates'] as bool? ?? true,
      rideRiderAssigned: json['ride_rider_assigned'] as bool? ?? true,
      rideTripStatus: json['ride_trip_status'] as bool? ?? true,

      parcelDeliveryUpdates: json['parcel_delivery_updates'] as bool? ?? true,
      parcelRiderAssigned: json['parcel_rider_assigned'] as bool? ?? true,
      parcelDeliveryCompletion: json['parcel_delivery_completion'] as bool? ?? true,

      errandAgentUpdates: json['errand_agent_updates'] as bool? ?? true,
      errandShoppingUpdates: json['errand_shopping_updates'] as bool? ?? true,
      errandPaymentUpdates: json['errand_payment_updates'] as bool? ?? true,

      rewardsAndPoints: json['rewards_and_points'] as bool? ?? true,
      promotionsAndCoupons: json['promotions_and_coupons'] as bool? ?? false,
      securityAndAccountAlerts: json['security_and_account_alerts'] as bool? ?? true,
      smsDispatchAlerts: json['sms_dispatch_alerts'] as bool? ?? true,
      schoolRunSecurityAlerts: json['school_run_security_alerts'] as bool? ?? true,
    );
  }

  final bool rideBookingUpdates;
  final bool rideRiderAssigned;
  final bool rideTripStatus;

  final bool parcelDeliveryUpdates;
  final bool parcelRiderAssigned;
  final bool parcelDeliveryCompletion;

  final bool errandAgentUpdates;
  final bool errandShoppingUpdates;
  final bool errandPaymentUpdates;

  final bool rewardsAndPoints;
  final bool promotionsAndCoupons;
  final bool securityAndAccountAlerts;
  final bool smsDispatchAlerts;
  final bool schoolRunSecurityAlerts;

  NotificationPreferencesDto copyWith({
    bool? rideBookingUpdates,
    bool? rideRiderAssigned,
    bool? rideTripStatus,
    bool? parcelDeliveryUpdates,
    bool? parcelRiderAssigned,
    bool? parcelDeliveryCompletion,
    bool? errandAgentUpdates,
    bool? errandShoppingUpdates,
    bool? errandPaymentUpdates,
    bool? rewardsAndPoints,
    bool? promotionsAndCoupons,
    bool? securityAndAccountAlerts,
    bool? smsDispatchAlerts,
    bool? schoolRunSecurityAlerts,
  }) {
    return NotificationPreferencesDto(
      rideBookingUpdates: rideBookingUpdates ?? this.rideBookingUpdates,
      rideRiderAssigned: rideRiderAssigned ?? this.rideRiderAssigned,
      rideTripStatus: rideTripStatus ?? this.rideTripStatus,
      parcelDeliveryUpdates: parcelDeliveryUpdates ?? this.parcelDeliveryUpdates,
      parcelRiderAssigned: parcelRiderAssigned ?? this.parcelRiderAssigned,
      parcelDeliveryCompletion: parcelDeliveryCompletion ?? this.parcelDeliveryCompletion,
      errandAgentUpdates: errandAgentUpdates ?? this.errandAgentUpdates,
      errandShoppingUpdates: errandShoppingUpdates ?? this.errandShoppingUpdates,
      errandPaymentUpdates: errandPaymentUpdates ?? this.errandPaymentUpdates,
      rewardsAndPoints: rewardsAndPoints ?? this.rewardsAndPoints,
      promotionsAndCoupons: promotionsAndCoupons ?? this.promotionsAndCoupons,
      securityAndAccountAlerts: securityAndAccountAlerts ?? this.securityAndAccountAlerts,
      smsDispatchAlerts: smsDispatchAlerts ?? this.smsDispatchAlerts,
      schoolRunSecurityAlerts: schoolRunSecurityAlerts ?? this.schoolRunSecurityAlerts,
    );
  }

  Map<String, dynamic> toJson() => {
        'ride_booking_updates': rideBookingUpdates,
        'ride_rider_assigned': rideRiderAssigned,
        'ride_trip_status': rideTripStatus,
        'parcel_delivery_updates': parcelDeliveryUpdates,
        'parcel_rider_assigned': parcelRiderAssigned,
        'parcel_delivery_completion': parcelDeliveryCompletion,
        'errand_agent_updates': errandAgentUpdates,
        'errand_shopping_updates': errandShoppingUpdates,
        'errand_payment_updates': errandPaymentUpdates,
        'rewards_and_points': rewardsAndPoints,
        'promotions_and_coupons': promotionsAndCoupons,
        'security_and_account_alerts': securityAndAccountAlerts,
        'sms_dispatch_alerts': smsDispatchAlerts,
        'school_run_security_alerts': schoolRunSecurityAlerts,
      };

  @override
  List<Object?> get props => [
        rideBookingUpdates,
        rideRiderAssigned,
        rideTripStatus,
        parcelDeliveryUpdates,
        parcelRiderAssigned,
        parcelDeliveryCompletion,
        errandAgentUpdates,
        errandShoppingUpdates,
        errandPaymentUpdates,
        rewardsAndPoints,
        promotionsAndCoupons,
        securityAndAccountAlerts,
        smsDispatchAlerts,
        schoolRunSecurityAlerts,
      ];
}

