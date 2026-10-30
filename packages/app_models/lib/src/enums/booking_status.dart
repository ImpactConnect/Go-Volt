/// Complete lifecycle states of a Go-Volts booking.
enum BookingStatus {
  draft('DRAFT', 'Draft'),
  pending('PENDING', 'Pending'),
  searchingRider('SEARCHING_RIDER', 'Finding Rider'),
  assigned('ASSIGNED', 'Rider Assigned'),
  arrivedAtPickup('ARRIVED_AT_PICKUP', 'Rider Arrived'),
  parcelCollected('PARCEL_COLLECTED', 'Parcel Picked Up'),
  inProgress('IN_PROGRESS', 'In Transit'),
  arrivedAtDropoff('ARRIVED_AT_DROPOFF', 'Arrived at Destination'),
  delivered('DELIVERED', 'Delivered'),
  completed('COMPLETED', 'Completed'),
  cancelled('CANCELLED', 'Cancelled'),
  failed('FAILED', 'Failed');

  const BookingStatus(this.code, this.label);

  final String code;
  final String label;

  bool get isTerminal =>
      this == completed || this == delivered || this == cancelled || this == failed;
  bool get isActive => !isTerminal && this != draft;

  static BookingStatus fromString(String raw) {
    final normalized = raw.toUpperCase().replaceAll('-', '_');
    return BookingStatus.values.firstWhere(
      (s) => s.code == normalized || s.name.toUpperCase() == normalized,
      orElse: () => BookingStatus.pending,
    );
  }
}
