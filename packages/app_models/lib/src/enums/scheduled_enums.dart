/// Enums for Go-Volts Scheduled Pickup (MVP v1.5).
library;

/// Type of scheduled booking: single future journey or recurring arrangement.
enum ScheduledBookingType {
  oneOff('one_off', 'One-off trip'),
  recurring('recurring', 'Recurring trip');

  const ScheduledBookingType(this.value, this.label);
  final String value;
  final String label;

  static ScheduledBookingType fromString(String? val) {
    return switch (val?.toLowerCase().trim()) {
      'recurring' || 'recurring_trip' => ScheduledBookingType.recurring,
      _ => ScheduledBookingType.oneOff,
    };
  }
}

/// Trip purpose classification.
enum TripPurpose {
  schoolRun('school_run', 'School run'),
  workCommute('work_commute', 'Work commute'),
  personal('personal', 'Personal'),
  other('other', 'Other');

  const TripPurpose(this.value, this.label);
  final String value;
  final String label;

  static TripPurpose fromString(String? val) {
    return switch (val?.toLowerCase().trim()) {
      'school_run' || 'schoolrun' => TripPurpose.schoolRun,
      'work_commute' || 'workcommute' => TripPurpose.workCommute,
      'personal' => TripPurpose.personal,
      _ => TripPurpose.other,
    };
  }
}

/// Direction of trip or leg.
enum JourneyDirection {
  oneWay('one_way', 'One way'),
  roundTrip('round_trip', 'Round trip');

  const JourneyDirection(this.value, this.label);
  final String value;
  final String label;

  static JourneyDirection fromString(String? val) {
    return switch (val?.toLowerCase().trim()) {
      'round_trip' || 'roundtrip' => JourneyDirection.roundTrip,
      _ => JourneyDirection.oneWay,
    };
  }
}

/// Frequency for recurring schedules.
enum ScheduleFrequency {
  weekly('weekly', 'Weekly'),
  monthly('monthly', 'Monthly');

  const ScheduleFrequency(this.value, this.label);
  final String value;
  final String label;

  static ScheduleFrequency fromString(String? val) {
    return switch (val?.toLowerCase().trim()) {
      'monthly' => ScheduleFrequency.monthly,
      _ => ScheduleFrequency.weekly,
    };
  }
}

/// Plan lifecycle states according to Section 21.6.
enum PlanStatus {
  draft('draft', 'Draft'),
  pendingReview('pending_review', 'Under Review'),
  approvedAwaitingPayment('approved_awaiting_payment', 'Approved'),
  active('active', 'Active'),
  paused('paused', 'Paused'),
  rejected('rejected', 'Rejected'),
  expired('expired', 'Expired'),
  cancelled('cancelled', 'Cancelled');

  const PlanStatus(this.value, this.label);
  final String value;
  final String label;

  static PlanStatus fromString(String? val) {
    return switch (val?.toLowerCase().trim()) {
      'pending_review' => PlanStatus.pendingReview,
      'approved_awaiting_payment' || 'approved' =>
        PlanStatus.approvedAwaitingPayment,
      'active' => PlanStatus.active,
      'paused' => PlanStatus.paused,
      'rejected' => PlanStatus.rejected,
      'expired' => PlanStatus.expired,
      'cancelled' => PlanStatus.cancelled,
      _ => PlanStatus.draft,
    };
  }
}

/// Commercial billing model for scheduled transport.
enum PackageBillingModel {
  payPerTrip('pay_per_trip', 'Pay per trip'),
  weeklyPackage('weekly_package', 'Weekly package'),
  monthlyPackage('monthly_package', 'Monthly package');

  const PackageBillingModel(this.value, this.label);
  final String value;
  final String label;

  static PackageBillingModel fromString(String? val) {
    return switch (val?.toLowerCase().trim()) {
      'weekly' || 'weekly_package' => PackageBillingModel.weeklyPackage,
      'monthly' || 'monthly_package' => PackageBillingModel.monthlyPackage,
      _ => PackageBillingModel.payPerTrip,
    };
  }
}

/// Individual scheduled trip execution lifecycle states (Section 21.6).
enum ScheduledTripStatus {
  scheduled('scheduled', 'Scheduled'),
  awaitingAssignment('awaiting_assignment', 'Awaiting Assignment'),
  driverOfferPending('driver_offer_pending', 'Offer Pending'),
  driverAssigned('driver_assigned', 'Driver Assigned'),
  driverApproaching('driver_approaching', 'Driver Approaching'),
  arrivedAtPickup('arrived_at_pickup', 'Arrived at Pickup'),
  pickupConfirmed('pickup_confirmed', 'Pickup Confirmed'),
  inProgress('in_progress', 'Trip in Progress'),
  arrivedAtDestination('arrived_at_destination', 'Arrived at Destination'),
  handoverPending('handover_pending', 'Handover Pending'),
  completed('completed', 'Completed'),
  skipped('skipped', 'Skipped'),
  cancelled('cancelled', 'Cancelled'),
  failed('failed', 'Failed');

  const ScheduledTripStatus(this.value, this.label);
  final String value;
  final String label;

  static ScheduledTripStatus fromString(String? val) {
    return switch (val?.toLowerCase().trim()) {
      'awaiting_assignment' => ScheduledTripStatus.awaitingAssignment,
      'driver_offer_pending' => ScheduledTripStatus.driverOfferPending,
      'driver_assigned' => ScheduledTripStatus.driverAssigned,
      'driver_approaching' => ScheduledTripStatus.driverApproaching,
      'arrived_at_pickup' => ScheduledTripStatus.arrivedAtPickup,
      'pickup_confirmed' => ScheduledTripStatus.pickupConfirmed,
      'in_progress' => ScheduledTripStatus.inProgress,
      'arrived_at_destination' => ScheduledTripStatus.arrivedAtDestination,
      'handover_pending' => ScheduledTripStatus.handoverPending,
      'completed' => ScheduledTripStatus.completed,
      'skipped' => ScheduledTripStatus.skipped,
      'cancelled' => ScheduledTripStatus.cancelled,
      'failed' => ScheduledTripStatus.failed,
      _ => ScheduledTripStatus.scheduled,
    };
  }
}

/// School-run child handover verification states.
enum HandoverStatus {
  notStarted('not_started', 'Not Started'),
  codePending('code_pending', 'Verification Pending'),
  verified('verified', 'Handover Verified'),
  completed('completed', 'Handover Completed'),
  exception('exception', 'Handover Exception');

  const HandoverStatus(this.value, this.label);
  final String value;
  final String label;

  static HandoverStatus fromString(String? val) {
    return switch (val?.toLowerCase().trim()) {
      'code_pending' => HandoverStatus.codePending,
      'verified' => HandoverStatus.verified,
      'completed' => HandoverStatus.completed,
      'exception' => HandoverStatus.exception,
      _ => HandoverStatus.notStarted,
    };
  }
}

/// Reportable trip issues.
enum TripIssueType {
  driverDidNotArrive('driver_did_not_arrive', 'Driver didn\'t arrive'),
  driverWasLate('driver_was_late', 'Driver was late'),
  safetyConcern('safety_concern', 'Safety concern'),
  wrongRoute('wrong_route', 'Wrong route'),
  handoverIssue('handover_issue', 'Handover issue'),
  vehicleIssue('vehicle_issue', 'Vehicle issue'),
  otherIssue('other_issue', 'Other issue');

  const TripIssueType(this.value, this.label);
  final String value;
  final String label;
}
