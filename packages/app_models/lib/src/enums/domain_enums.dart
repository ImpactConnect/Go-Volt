/// Dispatch attempt states for matching riders to bookings.
enum DispatchStatus {
  unassigned('UNASSIGNED'),
  queued('QUEUED'),
  dispatched('DISPATCHED'),
  accepted('ACCEPTED'),
  rejected('REJECTED'),
  timeout('TIMEOUT'),
  cancelled('CANCELLED');

  const DispatchStatus(this.code);

  final String code;

  static DispatchStatus fromString(String raw) {
    return DispatchStatus.values.firstWhere(
      (d) => d.code == raw || d.name == raw,
      orElse: () => DispatchStatus.unassigned,
    );
  }
}

/// Payment lifecycle states.
enum PaymentStatus {
  pending('PENDING', 'Payment Pending'),
  authorized('AUTHORIZED', 'Authorized'),
  captured('CAPTURED', 'Paid'),
  failed('FAILED', 'Payment Failed'),
  refunded('REFUNDED', 'Refunded'),
  partiallyRefunded('PARTIALLY_REFUNDED', 'Partially Refunded');

  const PaymentStatus(this.code, this.label);

  final String code;
  final String label;

  static PaymentStatus fromString(String raw) {
    return PaymentStatus.values.firstWhere(
      (p) => p.code == raw || p.name == raw,
      orElse: () => PaymentStatus.pending,
    );
  }
}

/// Available payment methods.
enum PaymentMethod {
  wallet('WALLET', 'Go-Volts Wallet'),
  card('CARD', 'Debit / Credit Card'),
  bankTransfer('BANK_TRANSFER', 'Bank Transfer'),
  cash('CASH', 'Cash on Pickup/Delivery');

  const PaymentMethod(this.code, this.label);

  final String code;
  final String label;

  static PaymentMethod fromString(String raw) {
    return PaymentMethod.values.firstWhere(
      (m) => m.code == raw || m.name == raw,
      orElse: () => PaymentMethod.wallet,
    );
  }
}

/// Zero-emission electric vehicle categories.
enum VehicleType {
  electricBike('EV_BIKE', 'Electric Bike', 1, 15.0),
  electricTricycle('EV_TRIKE', 'Electric Trike', 3, 100.0),
  electricVan('EV_VAN', 'Electric Van', 1, 500.0);

  const VehicleType(this.code, this.displayName, this.maxPassengers, this.maxPayloadKg);

  final String code;
  final String displayName;
  final int maxPassengers;
  final double maxPayloadKg;

  static VehicleType fromString(String raw) {
    return VehicleType.values.firstWhere(
      (v) => v.code == raw || v.name == raw,
      orElse: () => VehicleType.electricBike,
    );
  }
}

/// Standardized categories for delivery and pickup parcels.
enum PackageCategory {
  documents('DOCUMENTS', 'Documents & Letters'),
  electronics('ELECTRONICS', 'Electronics & Gadgets'),
  clothing('CLOTHING', 'Clothing & Fashion'),
  food('FOOD', 'Food & Perishables'),
  groceries('GROCERIES', 'Groceries & Supplies'),
  fragile('FRAGILE', 'Fragile & Glassware'),
  general('GENERAL', 'General Parcel');

  const PackageCategory(this.code, this.label);

  final String code;
  final String label;

  static PackageCategory fromString(String raw) {
    return PackageCategory.values.firstWhere(
      (c) => c.code == raw || c.name == raw,
      orElse: () => PackageCategory.general,
    );
  }
}

/// System user authorization roles.
enum UserRole {
  customer('customer'),
  rider('rider'),
  merchant('merchant'),
  admin('admin'),
  superAdmin('super_admin'),
  supportAgent('support_agent');

  const UserRole(this.code);

  final String code;

  static UserRole fromString(String raw) {
    return UserRole.values.firstWhere(
      (r) => r.code == raw || r.name == raw,
      orElse: () => UserRole.customer,
    );
  }
}
