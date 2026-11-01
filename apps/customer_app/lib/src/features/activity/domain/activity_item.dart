import 'package:app_models/app_models.dart';
import 'package:equatable/equatable.dart';

enum ActivityServiceType {
  ride,
  delivery,
  scheduled;

  String get label => switch (this) {
        ActivityServiceType.ride => 'Ride',
        ActivityServiceType.delivery => 'Delivery',
        ActivityServiceType.scheduled => 'Scheduled',
      };
}

enum ActivityStatus {
  active,
  upcoming,
  completed,
  cancelled;

  String get label => switch (this) {
        ActivityStatus.active => 'Active',
        ActivityStatus.upcoming => 'Upcoming',
        ActivityStatus.completed => 'Completed',
        ActivityStatus.cancelled => 'Cancelled',
      };
}

/// Unified activity item entity for Rides, Parcel Deliveries and Scheduled Trips.
///
/// Complies with Go-Volts Master Tech Specification v1.5 §1.5 & Customer Screen Spec H07.
class ActivityItem extends Equatable {
  const ActivityItem({
    required this.id,
    required this.reference,
    required this.serviceType,
    required this.status,
    required this.title,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.timestamp,
    required this.fareKobo,
    this.driverName,
    this.driverRating = 4.8,
    this.driverTripsCount = 320,
    this.driverPhotoUrl,
    this.vehicleModel,
    this.vehiclePlate,
    this.recipientName,
    this.recipientPhone,
    this.cancellationReason,
    this.refundStatus,
    this.receipt,
    this.schoolPassengerName,
  });

  final String id;
  final String reference;
  final ActivityServiceType serviceType;
  final ActivityStatus status;
  final String title;
  final String pickupAddress;
  final String dropoffAddress;
  final DateTime timestamp;
  final int fareKobo;
  final String? driverName;
  final double driverRating;
  final int driverTripsCount;
  final String? driverPhotoUrl;
  final String? vehicleModel;
  final String? vehiclePlate;
  final String? recipientName;
  final String? recipientPhone;
  final String? cancellationReason;
  final String? refundStatus;
  final TripReceiptDto? receipt;
  final String? schoolPassengerName;

  double get fareNaira => fareKobo / 100.0;
  String get formattedFare => '₦${(fareNaira).toStringAsFixed(0)}';

  @override
  List<Object?> get props => [
        id,
        reference,
        serviceType,
        status,
        title,
        pickupAddress,
        dropoffAddress,
        timestamp,
        fareKobo,
        driverName,
        driverRating,
        driverTripsCount,
        driverPhotoUrl,
        vehicleModel,
        vehiclePlate,
        recipientName,
        recipientPhone,
        cancellationReason,
        refundStatus,
        receipt,
        schoolPassengerName,
      ];
}
