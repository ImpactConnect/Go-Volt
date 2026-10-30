import 'package:app_models/app_models.dart';

/// Pre-populated test fixtures for unit and widget testing.
abstract class TestFixtures {
  static const customerProfile = ProfileDto(
    id: 'usr-customer-001',
    fullName: 'Folake Adeleke',
    phoneNumber: '+2348012345678',
    email: 'folake@example.com',
    avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
    roles: [UserRole.customer],
  );

  static const riderProfile = ProfileDto(
    id: 'usr-rider-001',
    fullName: 'Babatunde Alao',
    phoneNumber: '+2348098765432',
    email: 'babatunde@govolts.ng',
    avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d',
    roles: [UserRole.rider],
  );

  static const locationPickup = LocationDto(
    latitude: 6.5244,
    longitude: 3.3792,
    address: '14 Marina Street, Lagos Island',
    label: 'Marina Marina',
    landmark: 'Opposite Cathedral',
    contactName: 'Folake Adeleke',
    contactPhone: '+2348012345678',
  );

  static const locationDropoff = LocationDto(
    latitude: 6.4500,
    longitude: 3.4200,
    address: '25 Adeola Odeku, Victoria Island',
    label: 'VI Office',
    landmark: 'Near Silverbird Galleria',
    contactName: 'Chidi Okonkwo',
    contactPhone: '+2348033221100',
  );

  static const priceBreakdown = PriceBreakdownDto(
    baseFare: 500,
    distanceFare: 1200,
    timeFare: 300,
    platformFee: 50,
    discountAmount: 0,
    totalFare: 2050,
    currency: 'NGN',
  );

  static final quote = QuoteDto(
    quoteId: 'quote-test-999',
    serviceCode: ServiceCode.instantRide,
    priceBreakdown: priceBreakdown,
    estimatedDurationMinutes: 24,
    estimatedDistanceKm: 7.8,
    expiresAt: DateTime.now().add(const Duration(minutes: 10)),
  );

  static final booking = BookingDto(
    id: 'bk-test-001',
    bookingReference: 'GV-2026-8812',
    serviceCode: ServiceCode.instantRide,
    status: BookingStatus.assigned,
    pickupLocation: locationPickup,
    dropoffLocation: locationDropoff,
    priceBreakdown: priceBreakdown,
    createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    riderId: riderProfile.id,
    riderName: riderProfile.fullName,
    riderPhone: riderProfile.phoneNumber,
    riderRating: 4.9,
    vehicleType: VehicleType.electricBike,
    vehiclePlate: 'EKY-782-EV',
    vehicleModel: 'Volts Sprint EV-200',
    paymentMethod: PaymentMethod.wallet,
    paymentStatus: PaymentStatus.authorized,
  );

  static const wallet = WalletDto(
    userId: 'usr-customer-001',
    balance: 25000,
    lockedBalance: 2050,
    currency: 'NGN',
  );
}
