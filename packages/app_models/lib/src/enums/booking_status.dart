/// Complete lifecycle states of a Go-Volts booking.
enum BookingStatus {
  draft('DRAFT', 'Draft'),
  pending('PENDING', 'Pending'),
  searchingRider('SEARCHING_RIDER', 'Finding Rider'),
  assigned('ASSIGNED', 'Rider Assigned'),
  arrivedAtPickup('ARRIVED_AT_PICKUP', 'Rider Arrived'),
  inProgress('IN_PROGRESS', 'In Transit'),
  arrivedAtDropoff('ARRIVED_AT_DROPOFF', 'Arrived at Destination'),
  completed('COMPLETED', 'Completed'),
  cancelled('CANCELLED', 'Cancelled'),
  failed('FAILED', 'Failed');

  const BookingStatus(this.code, this.label);

  final String code;
  final String label;

  bool get isTerminal => this == completed || this == cancelled || this == failed;
  bool get isActive => !isTerminal && this != draft;

  static BookingStatus fromString(String raw) {
    return BookingStatus.values.firstWhere(
      (s) => s.code == raw || s.name == raw,
      orElse: () => BookingStatus.pending,
    );
  }
}
