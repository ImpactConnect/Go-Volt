import 'package:app_models/app_models.dart';
import 'package:customer_app/src/features/booking/application/booking_notifier.dart';
import 'package:customer_app/src/features/booking/data/booking_repository.dart';
import 'package:customer_app/src/features/booking/presentation/location_picker_screen.dart';
import 'package:customer_app/src/features/booking/presentation/ride_booking_screen.dart';
import 'package:customer_app/src/features/booking/presentation/scheduled_booking_screen.dart';
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
      final fakeRepo = _FakeBookingRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bookingRepositoryProvider.overrideWithValue(fakeRepo),
          ],
          child: const MaterialApp(
            home: LocationPickerScreen(),
          ),
        ),
      );

      // Verify UI elements
      expect(find.text('Where to?'), findsOneWidget);
      expect(find.text('PICKUP'), findsOneWidget);
      expect(find.text('DESTINATION'), findsOneWidget);
      expect(find.text('Search address or landmark'), findsOneWidget);
      expect(find.text('Home'), findsWidgets);
      expect(find.text('Work'), findsWidgets);
      expect(find.text('School'), findsOneWidget);
      expect(find.text('Victoria Island Financial District'), findsOneWidget);
      expect(find.text('Lekki Phase 1'), findsOneWidget);
    });

    testWidgets('RideBookingScreen displays electric vehicle classes and price breakdown',
        (WidgetTester tester) async {
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

      expect(find.text('Ride Electric'), findsOneWidget);
      expect(find.text('Select Electric Class'), findsOneWidget);
      expect(find.text('Volt Bike'), findsOneWidget);
      expect(find.text('Volt Trike (Comfort)'), findsOneWidget);
      expect(find.text('Volt Cargo / Executive'), findsOneWidget);
      expect(find.text('Payment Method'), findsOneWidget);
      expect(find.text('Confirm Electric Ride'), findsOneWidget);
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
