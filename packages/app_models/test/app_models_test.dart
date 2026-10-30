import 'package:app_models/app_models.dart';
import 'package:test/test.dart';

void main() {
  group('ServiceCode', () {
    test('identifies ride vs delivery vs scheduled accurately', () {
      expect(ServiceCode.instantRide.isRide, isTrue);
      expect(ServiceCode.instantRide.isDelivery, isFalse);
      expect(ServiceCode.instantRide.isScheduled, isFalse);

      expect(ServiceCode.scheduledPickup.isDelivery, isTrue);
      expect(ServiceCode.scheduledPickup.isScheduled, isTrue);
      expect(ServiceCode.scheduledPickup.isRide, isFalse);
    });

    test('parses from code and string name', () {
      expect(ServiceCode.fromString('RIDE_INSTANT'), ServiceCode.instantRide);
      expect(ServiceCode.fromString('PICKUP_SCHEDULED'), ServiceCode.scheduledPickup);
      expect(ServiceCode.fromString('scheduledRide'), ServiceCode.scheduledRide);
    });
  });

  group('BookingStatus', () {
    test('identifies terminal vs active statuses correctly', () {
      expect(BookingStatus.completed.isTerminal, isTrue);
      expect(BookingStatus.cancelled.isTerminal, isTrue);
      expect(BookingStatus.failed.isTerminal, isTrue);
      expect(BookingStatus.inProgress.isTerminal, isFalse);
      expect(BookingStatus.inProgress.isActive, isTrue);
      expect(BookingStatus.draft.isActive, isFalse);
    });
  });

  group('LocationDto & PriceQuoteDto & BookingDto round-trip', () {
    test('LocationDto serializes and deserializes cleanly', () {
      const loc = LocationDto(
        latitude: 6.5244,
        longitude: 3.3792,
        address: '14 Marina St, Lagos Island',
        label: 'Marina HQ',
        landmark: 'Opposite Cathedral',
      );

      final json = loc.toJson();
      final parsed = LocationDto.fromJson(json);

      expect(parsed, equals(loc));
      expect(parsed.latitude, 6.5244);
      expect(parsed.city, 'Lagos');
    });

    test('BookingDto parses complete JSON payload', () {
      final now = DateTime.now();
      final booking = BookingDto(
        id: 'bk-123',
        bookingReference: 'GV-2026-0001',
        serviceCode: ServiceCode.instantRide,
        status: BookingStatus.assigned,
        pickupLocation: const LocationDto(
          latitude: 6.5000,
          longitude: 3.3500,
          address: 'Yaba Tech, Lagos',
        ),
        dropoffLocation: const LocationDto(
          latitude: 6.4500,
          longitude: 3.4200,
          address: 'Victoria Island, Lagos',
        ),
        priceBreakdown: const PriceBreakdownDto(
          baseFare: 500,
          distanceFare: 1200,
          timeFare: 300,
          totalFare: 2050,
          platformFee: 50,
        ),
        createdAt: now,
        riderId: 'rd-99',
        riderName: 'Babatunde Alao',
        riderPhone: '+2348012345678',
        vehicleType: VehicleType.electricBike,
        vehiclePlate: 'EKY-782-EV',
      );

      final json = booking.toJson();
      final restored = BookingDto.fromJson(json);

      expect(restored.id, 'bk-123');
      expect(restored.bookingReference, 'GV-2026-0001');
      expect(restored.serviceCode, ServiceCode.instantRide);
      expect(restored.hasAssignedRider, isTrue);
      expect(restored.riderName, 'Babatunde Alao');
      expect(restored.priceBreakdown.totalFare, 2050);
    });
  });

  group('WalletDto', () {
    test('computes available balance correctly accounting for locked amounts', () {
      const wallet = WalletDto(
        userId: 'usr-1',
        balance: 15000,
        lockedBalance: 2500,
      );

      expect(wallet.availableBalance, 12500);
      expect(wallet.currency, 'NGN');
    });
  });

  group('ProfileDto', () {
    test('identifies user roles and permissions', () {
      const customer = ProfileDto(
        id: 'u-1',
        fullName: 'Folake Adeleke',
        phoneNumber: '+2348099887766',
        roles: [UserRole.customer],
      );

      expect(customer.isCustomer, isTrue);
      expect(customer.isRider, isFalse);
      expect(customer.isAdmin, isFalse);

      const admin = ProfileDto(
        id: 'u-2',
        fullName: 'Admin User',
        phoneNumber: '+2348000000000',
        roles: [UserRole.admin, UserRole.superAdmin],
      );

      expect(admin.isAdmin, isTrue);
    });
  });
}
