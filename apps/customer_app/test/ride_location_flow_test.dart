import 'package:app_models/app_models.dart';
import 'package:customer_app/src/features/booking/application/booking_notifier.dart';
import 'package:customer_app/src/features/booking/data/booking_repository.dart';
import 'package:customer_app/src/features/booking/presentation/location_picker_screen.dart';
import 'package:customer_app/src/features/booking/presentation/map_picker_screen.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testing_support/testing_support.dart';

class _MockBookingRepository implements BookingRepository {
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
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget buildTestable(Widget child, {BookingNotifier? notifier}) {
    return ProviderScope(
      overrides: [
        bookingRepositoryProvider.overrideWithValue(_MockBookingRepository()),
        if (notifier != null)
          bookingNotifierProvider.overrideWith((ref) => notifier),
      ],
      child: MaterialApp(
        theme: GVTheme.light,
        home: child,
      ),
    );
  }

  group('Ride Flow Step 3: Location Entry & Map Picker (Screens 2 to 6)', () {
    testWidgets(
        'Screen 2: Dual Entry renders pickup, destination, saved places and toggles continue',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(buildTestable(const LocationPickerScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Enter your locations'), findsOneWidget);
      expect(find.text('Pickup location'), findsOneWidget);
      expect(find.text('Eko Hotel and Suites'), findsOneWidget);
      expect(find.text('Destination'), findsOneWidget);
      expect(find.text('Where are you going?'), findsOneWidget);
      expect(find.text('Use current location'), findsOneWidget);
      expect(find.text('Saved places'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Add new location'), findsOneWidget);

      // Tap saved place "Home" to set destination
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();

      // Destination should now be updated to "Home"
      expect(find.text('Home'), findsNWidgets(2)); // in input and in saved places
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets(
        'Screen 3: Search Location (Pickup) displays suggestions and updates pickup',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestable(const LocationPickerScreen(initialMode: 'pickup')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Set location on map'), findsOneWidget);
      expect(find.text('Eko Hotel and Suites'), findsOneWidget);
      expect(find.text('Eko Hotel Roundabout'), findsOneWidget);
      expect(find.text('Eko Hotel Car Park'), findsOneWidget);

      // Select "Eko Hotel Roundabout"
      await tester.tap(find.text('Eko Hotel Roundabout'));
      await tester.pumpAndSettle();

      // Should return to Dual Entry with new pickup
      expect(find.text('Enter your locations'), findsOneWidget);
      expect(find.text('Eko Hotel Roundabout'), findsOneWidget);
    });

    testWidgets(
        'Screen 5: Destination Search displays suggestions and updates destination',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestable(const LocationPickerScreen(initialMode: 'destination')),
      );
      await tester.pumpAndSettle();

      expect(find.text('Set location on map'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Palms Mall'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Palms Mall Annex'), findsOneWidget);
      expect(find.widgetWithText(ListTile, 'Palms Mall Car Park'), findsOneWidget);

      // Select "Palms Mall Annex"
      await tester.tap(find.widgetWithText(ListTile, 'Palms Mall Annex'));
      await tester.pumpAndSettle();

      // Should return to Dual Entry with new destination
      expect(find.text('Enter your locations'), findsOneWidget);
      expect(find.text('Palms Mall Annex'), findsOneWidget);
    });

    testWidgets(
        'Screen 4: Map Location Picker (Pickup) displays map pin, callout and confirms location',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      LocationDto? confirmedLocation;

      await tester.pumpWidget(
        MaterialApp(
          theme: GVTheme.light,
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  confirmedLocation = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProviderScope(
                        overrides: [
                          bookingRepositoryProvider
                              .overrideWithValue(_MockBookingRepository()),
                        ],
                        child: const MapPickerScreen(isPickup: true),
                      ),
                    ),
                  );
                },
                child: const Text('Launch Pickup Map'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Launch Pickup Map'));
      await tester.pumpAndSettle();

      expect(find.text('Selected pickup location'), findsOneWidget);
      expect(find.text('Eko Hotel and Suites'), findsNWidgets(2)); // pin callout and card
      expect(find.text('Confirm pickup location'), findsOneWidget);

      await tester.tap(find.text('Confirm pickup location'));
      await tester.pumpAndSettle();

      expect(confirmedLocation, isNotNull);
      expect(confirmedLocation?.label, equals('Eko Hotel and Suites'));
    });

    testWidgets(
        'Screen 6: Map Location Picker (Destination) displays map pin, callout and confirms destination',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      LocationDto? confirmedLocation;

      await tester.pumpWidget(
        MaterialApp(
          theme: GVTheme.light,
          home: Builder(
            builder: (context) {
              return ElevatedButton(
                onPressed: () async {
                  confirmedLocation = await Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProviderScope(
                        overrides: [
                          bookingRepositoryProvider
                              .overrideWithValue(_MockBookingRepository()),
                        ],
                        child: const MapPickerScreen(isPickup: false),
                      ),
                    ),
                  );
                },
                child: const Text('Launch Destination Map'),
              );
            },
          ),
        ),
      );

      await tester.tap(find.text('Launch Destination Map'));
      await tester.pumpAndSettle();

      expect(find.text('Selected destination'), findsOneWidget);
      expect(find.text('Palms Mall'), findsNWidgets(2)); // pin callout and card
      expect(find.text('Confirm destination'), findsOneWidget);

      await tester.tap(find.text('Confirm destination'));
      await tester.pumpAndSettle();

      expect(confirmedLocation, isNotNull);
      expect(confirmedLocation?.label, equals('Palms Mall'));
    });
  });
}
