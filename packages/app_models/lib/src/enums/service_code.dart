/// Core service offerings provided by Go-Volts.
enum ServiceCode {
  instantRide('RIDE_INSTANT', 'Ride Electric', 'Fast, zero-emission urban commute'),
  scheduledRide('RIDE_SCHEDULED', 'Scheduled Ride', 'Reserve a clean ride in advance'),
  instantDelivery('DELIVERY_INSTANT', 'Send Package', 'On-demand eco-friendly parcel delivery'),
  scheduledPickup('PICKUP_SCHEDULED', 'Scheduled Pickup', 'Plan recurring or scheduled collections');

  const ServiceCode(this.code, this.displayName, this.description);

  final String code;
  final String displayName;
  final String description;

  bool get isRide => this == ServiceCode.instantRide || this == ServiceCode.scheduledRide;
  bool get isDelivery => this == ServiceCode.instantDelivery || this == ServiceCode.scheduledPickup;
  bool get isScheduled => this == ServiceCode.scheduledRide || this == ServiceCode.scheduledPickup;

  static ServiceCode fromString(String raw) {
    return ServiceCode.values.firstWhere(
      (s) => s.code == raw || s.name == raw,
      orElse: () => ServiceCode.instantRide,
    );
  }
}
