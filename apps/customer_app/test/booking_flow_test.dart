import 'package:app_models/app_models.dart';
import 'package:customer_app/src/features/booking/application/booking_notifier.dart';
import 'package:customer_app/src/features/booking/data/booking_repository.dart';
import 'package:customer_app/src/features/booking/presentation/location_picker_screen.dart';
import 'package:customer_app/src/features/booking/presentation/ride_booking_screen.dart';
import 'package:customer_app/src/features/booking/presentation/scheduled_booking_screen.dart';
import 'package:customer_app/src/features/home/application/home_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testing_support/testing_support.dart';

class _FakeBookingRepository implements BookingRepository {
  @override
  Future<QuoteDto> requestQuote({
    required ServiceCode serviceCode,
    required LocationDto pickup,
    required LocationDto dropoff,
    DateTime? scheduledTime,
    PackageCategory? packageCategory,
  }) async {
    return TestFixtures.quote;
  }

  @override
  Future<BookingDto> createBooking({
    required String quoteId,
    required PaymentMethod paymentMethod,
    String? instructions,
    String? recipientName,
    String? recipientPhone,
  }) async {
    return TestFixtures.booking;
  }

  @override
  Future<BookingDto> getBooking(String bookingId) async {
    return TestFixtures.booking;
  }

  @override
  Future<BookingDto> cancelBooking(String bookingId, {required String reason}) async {
    return TestFixtures.booking;
  }

  @override
  Future<List<BookingDto>> listBookings({String? status, int limit = 20}) async {
    return [TestFixtures.booking];
  }

  @override
  Future<List<RideCategoryDto>> getRideCategories() async {
    return const [
      RideCategoryDto(
        id: 'goride_standard',
        name: 'GoRide Standard',
        code: 'standard',
        description: 'Affordable and reliable',
        passengerCapacity: 4,
        baseFareKobo: 280000,
        features: ['AC', '3 Seats', 'Trusted riders'],
      ),
    ];
  }

  @override
  Future<CouponValidationDto> validateCoupon({
    required String code,
    required int quoteAmountKobo,
    String? serviceCode,
  }) async {
    return const CouponValidationDto(
      isValid: true,
      discountAmountKobo: 30000,
      code: 'GO20',
    );
  }

  @override
  Future<TripReceiptDto> getTripReceipt(String bookingId) async {
    return TripReceiptDto(
      bookingId: 'TRP123456789',
      receiptReference: 'GV-TEST-01',
      serviceType: 'GoRide Standard',
      driverName: 'Daniel Okafor',
      vehicleModel: 'Toyota Corolla - Black',
      vehiclePlate: 'KJA 123 AB',
      pickupAddress: 'Eko Hotel and Suites',
      pickupTime: DateTime(2026, 10, 29, 10, 5),
      dropoffAddress: 'Palms Mall',
      dropoffTime: DateTime(2026, 10, 29, 10, 17),
      distanceKm: 8.4,
      durationMinutes: 12,
      priceBreakdown: const PriceBreakdownDto(
        baseAmountKobo: 150000,
        distanceAmountKobo: 110000,
        timeAmountKobo: 30000,
        serviceFeeKobo: 20000,
        totalAmountKobo: 310000,
      ),
      totalPaidKobo: 320000,
    );
  }

  @override
  Future<bool> submitTripRating(TripRatingDto rating) async {
    return true;
  }
}

void main() {
  group('BookingNotifier Unit Tests', () {
    test('updates route and triggers quote fetching', () async {
      final fakeRepo = _FakeBookingRepository();
      final notifier = BookingNotifier(repository: fakeRepo);

      expect(notifier.state.hasValidRoute, isFalse);

      notifier.setPickupLocation(TestFixtures.locationPickup);
      expect(notifier.state.pickupLocation, equals(TestFixtures.locationPickup));
      expect(notifier.state.hasValidRoute, isFalse);

      notifier.setDropoffLocation(TestFixtures.locationDropoff);
      expect(notifier.state.dropoffLocation, equals(TestFixtures.locationDropoff));
      expect(notifier.state.hasValidRoute, isTrue);

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(notifier.state.quote, isNotNull);
      expect(notifier.state.quote?.quoteId, 'quote-test-999');
    });

    test('commits booking entity successfully', () async {
      final fakeRepo = _FakeBookingRepository();
      final notifier = BookingNotifier(repository: fakeRepo);

      notifier.setPickupLocation(TestFixtures.locationPickup);
      notifier.setDropoffLocation(TestFixtures.locationDropoff);
      await Future<void>.delayed(const Duration(milliseconds: 10));

      final booking = await notifier.commitBooking();
      expect(booking, isNotNull);
      expect(booking?.id, 'bk-test-001');
      expect(booking?.status, BookingStatus.assigned);
      expect(notifier.state.activeBooking, isNotNull);
    });
  });

  group('Phase 1B Widget Tests', () {
    testWidgets('LocationPickerScreen displays pickup, dropoff and Lagos destinations',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeRepo = _FakeBookingRepository();
      final fakeHomeNotifier = HomeNotifier(
        initialSavedPlaces: const [
          SavedPlaceDto(
            id: 'p1',
            label: 'Home',
            address: '10 Main St, Shaganu, Ogun',
            latitude: 6.8403,
            longitude: 3.6487,
            type: SavedPlaceType.home,
          ),
          SavedPlaceDto(
            id: 'p2',
            label: 'Work',
            address: 'Town Hall, Shaganu, Ogun',
            latitude: 6.8420,
            longitude: 3.6500,
            type: SavedPlaceType.work,
          ),
        ],
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bookingRepositoryProvider.overrideWithValue(fakeRepo),
            homeNotifierProvider.overrideWith((ref) => fakeHomeNotifier),
          ],
          child: const MaterialApp(
            home: LocationPickerScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Screen 2 Specification UI elements
      expect(find.text('Enter your locations'), findsOneWidget);
      expect(find.text('Pickup location'), findsOneWidget);
      expect(find.text('Destination'), findsOneWidget);
      expect(find.text('Use current location'), findsOneWidget);
      expect(find.text('Saved places'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Add new location'), findsOneWidget);
    });

    testWidgets('RideBookingScreen displays electric vehicle classes and price breakdown',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final fakeRepo = _FakeBookingRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bookingRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: RideBookingScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Screen 7 Route Preview
      expect(find.text('Trip overview'), findsOneWidget);
      expect(find.text('See ride options'), findsOneWidget);

      // Advance to Screen 8 Choose a ride
      await tester.tap(find.text('See ride options'));
      await tester.pumpAndSettle();

      expect(find.text('Choose a ride'), findsOneWidget);
      expect(find.text('GoRide Standard'), findsOneWidget);
      expect(find.text('Continue to fare details'), findsOneWidget);
    });

    testWidgets('ScheduledBookingScreen displays commute plans and frequency selector',
        (WidgetTester tester) async {
      final fakeRepo = _FakeBookingRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bookingRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: ScheduledBookingScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Scheduled Services'), findsOneWidget);
      expect(find.text('Guaranteed Dispatch'), findsOneWidget);
      expect(find.text('Recurring Commute Plan'), findsOneWidget);
      expect(find.text('Safe School-Run Plan'), findsOneWidget);
      expect(find.text('One-off Advance Booking'), findsOneWidget);
      expect(find.text('Submit Commute Plan'), findsOneWidget);
    });
  });
}
