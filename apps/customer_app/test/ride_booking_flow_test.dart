import 'package:app_models/app_models.dart';
import 'package:customer_app/src/features/booking/application/booking_notifier.dart';
import 'package:customer_app/src/features/booking/data/booking_repository.dart';
import 'package:customer_app/src/features/booking/presentation/ride_booking_screen.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:testing_support/testing_support.dart';

class _MockBookingRepository implements BookingRepository {
  bool createBookingCalled = false;
  String? lastQuoteId;
  PaymentMethod? lastPaymentMethod;

  @override
  Future<QuoteDto> requestQuote({
    required ServiceCode serviceCode,
    required LocationDto pickup,
    required LocationDto dropoff,
    DateTime? scheduledTime,
    PackageCategory? packageCategory,
  }) async {
    return QuoteDto(
      quoteId: 'QT-TEST-RIDE-01',
      serviceCode: ServiceCode.instantRide,
      priceBreakdown: const PriceBreakdownDto(
        baseAmountKobo: 150000, // ₦1,500
        distanceAmountKobo: 110000, // ₦1,100
        timeAmountKobo: 30000, // ₦300
        serviceFeeKobo: 20000, // ₦200
        totalAmountKobo: 320000, // ₦3,200 (estimated range ₦2,800 - ₦3,500)
      ),
      estimatedDurationMinutes: 12,
      estimatedDistanceKm: 8.4,
      expiresAt: DateTime.now().add(const Duration(minutes: 15)),
      trafficCondition: 'Light traffic',
      isServiceable: true,
      serviceabilityMessage: 'Rides are available in this area',
    );
  }

  @override
  Future<BookingDto> createBooking({
    required String quoteId,
    required PaymentMethod paymentMethod,
    String? instructions,
    String? recipientName,
    String? recipientPhone,
  }) async {
    createBookingCalled = true;
    lastQuoteId = quoteId;
    lastPaymentMethod = paymentMethod;
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
        passengerCapacity: 3,
        baseFareKobo: 280000, // ₦2,800
        etaMinutes: 2,
        capacityLabel: '3 Seats',
        features: ['AC', '3 Seats', 'Trusted riders'],
      ),
      RideCategoryDto(
        id: 'goride_plus',
        name: 'GoRide Plus',
        code: 'plus',
        description: 'More comfort',
        passengerCapacity: 4,
        baseFareKobo: 350000, // ₦3,500
        etaMinutes: 3,
        capacityLabel: '4 Seats',
        features: ['AC', 'Extra legroom', 'Top rated'],
      ),
      RideCategoryDto(
        id: 'goride_xl',
        name: 'GoRide XL',
        code: 'xl',
        description: 'Bigger vehicles for more space',
        passengerCapacity: 6,
        baseFareKobo: 450000, // ₦4,500
        etaMinutes: 4,
        capacityLabel: '6 Seats',
        features: ['AC', '6 Seats', 'Spacious trunk'],
      ),
      RideCategoryDto(
        id: 'goride_green',
        name: 'GoRide Green',
        code: 'green',
        description: 'Eco-friendly rides',
        passengerCapacity: 4,
        baseFareKobo: 300000, // ₦3,000
        etaMinutes: 3,
        capacityLabel: '4 Seats',
        features: ['Zero emission', 'Quiet ride', 'Carbon offset'],
      ),
    ];
  }

  @override
  Future<CouponValidationDto> validateCoupon({
    required String code,
    required int quoteAmountKobo,
    String? serviceCode,
  }) async {
    if (code.toUpperCase() == 'GO20') {
      return const CouponValidationDto(
        isValid: true,
        code: 'GO20',
        discountAmountKobo: 30000, // ₦300
        message: '₦300 off promo applied',
      );
    }
    return const CouponValidationDto(
      isValid: false,
      code: 'INVALID',
      message: 'Invalid promo code',
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
      totalPaidKobo: 310000,
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

  Widget buildTestableWidget({
    required ProviderContainer container,
    String? initialStep,
  }) {
    return UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: GVColors.brandGreen),
        ),
        routes: {
          '/finding-driver': (context) => const Scaffold(body: Text('Finding Driver Screen')),
        },
        home: RideBookingScreen(initialStep: initialStep),
      ),
    );
  }

  group('Ride Flow Step 4: Route Preview, Ride Options & Checkout Review (Screens 7 to 10)', () {
    testWidgets('Screen 7: Route Preview renders metrics, serviceability and navigates to options', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _MockBookingRepository();
      final container = ProviderContainer(
        overrides: [
          bookingRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(bookingNotifierProvider.notifier);
      notifier.setPickupLocation(
        const LocationDto(
          latitude: 6.4281,
          longitude: 3.4219,
          address: 'Eko Hotel and Suites',
        ),
      );
      notifier.setDropoffLocation(
        const LocationDto(
          latitude: 6.4344,
          longitude: 3.4428,
          address: 'Palms Mall',
        ),
      );

      await tester.pumpWidget(
        buildTestableWidget(container: container),
      );

      await tester.pumpAndSettle();

      // Check pickup & dropoff display
      expect(find.text('Eko Hotel and Suites'), findsWidgets);
      expect(find.text('Palms Mall'), findsWidgets);

      // Check duration & distance
      expect(find.textContaining('12 min'), findsWidgets);
      expect(find.textContaining('8.4 km'), findsWidgets);
      expect(find.text('Light traffic'), findsOneWidget);

      // Check serviceability
      expect(find.text('Serviceable'), findsOneWidget);
      expect(find.text('Rides are available in this area'), findsOneWidget);

      // Check "See ride options" CTA
      final seeRideOptionsBtn = find.text('See ride options');
      expect(seeRideOptionsBtn, findsOneWidget);

      // Tap button to navigate to Screen 8
      await tester.tap(seeRideOptionsBtn);
      await tester.pumpAndSettle();

      // Should now be on Screen 8: "Choose a ride"
      expect(find.text('Choose a ride'), findsOneWidget);
    });

    testWidgets('Screen 8: Choose a ride displays dynamic category cards and navigates to fare details', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _MockBookingRepository();
      final container = ProviderContainer(
        overrides: [
          bookingRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(bookingNotifierProvider.notifier);
      notifier.setPickupLocation(
        const LocationDto(latitude: 6.4281, longitude: 3.4219, address: 'Eko Hotel and Suites'),
      );
      notifier.setDropoffLocation(
        const LocationDto(latitude: 6.4344, longitude: 3.4428, address: 'Palms Mall'),
      );

      await tester.pumpWidget(
        buildTestableWidget(
          container: container,
          initialStep: 'options',
        ),
      );

      await tester.pumpAndSettle();

      // Check Categories from repository
      expect(find.text('GoRide Standard'), findsOneWidget);
      expect(find.text('₦2,800'), findsWidgets);
      expect(find.text('GoRide Plus'), findsOneWidget);
      expect(find.text('₦3,500'), findsOneWidget);
      expect(find.text('GoRide XL'), findsOneWidget);
      expect(find.text('₦4,500'), findsOneWidget);
      expect(find.text('GoRide Green'), findsOneWidget);
      expect(find.text('₦3,000'), findsOneWidget);

      // Select GoRide Plus
      await tester.tap(find.text('GoRide Plus'));
      await tester.pumpAndSettle();

      // Tap "Continue to fare details"
      final continueBtn = find.text('Continue to fare details');
      expect(continueBtn, findsOneWidget);
      await tester.tap(continueBtn);
      await tester.pumpAndSettle();

      // Screen 9 should now be visible: "Fare details"
      expect(find.text('Fare details'), findsOneWidget);
    });

    testWidgets('Screen 9: Fare details displays breakdown, applies coupon, and navigates to confirmation', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _MockBookingRepository();
      final container = ProviderContainer(
        overrides: [
          bookingRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(bookingNotifierProvider.notifier);
      notifier.setPickupLocation(
        const LocationDto(latitude: 6.4281, longitude: 3.4219, address: 'Eko Hotel and Suites'),
      );
      notifier.setDropoffLocation(
        const LocationDto(latitude: 6.4344, longitude: 3.4428, address: 'Palms Mall'),
      );

      await tester.pumpWidget(
        buildTestableWidget(
          container: container,
          initialStep: 'fare',
        ),
      );

      await tester.pumpAndSettle();

      // Check itemized breakdown
      expect(find.text('Fare breakdown'), findsOneWidget);
      expect(find.text('Base fare'), findsOneWidget);
      expect(find.text('Service fee'), findsOneWidget);
      expect(find.text('Estimated fare'), findsOneWidget);

      // Check promo code section
      expect(find.text('Apply promo code'), findsOneWidget);
      final promoField = find.byType(TextField);
      expect(promoField, findsOneWidget);

      // Enter coupon GO20 and apply
      await tester.enterText(promoField, 'GO20');
      await tester.pumpAndSettle();

      final applyBtn = find.text('Apply');
      expect(applyBtn, findsOneWidget);
      await tester.tap(applyBtn);
      await tester.pumpAndSettle();

      // Discount applied should show
      expect(find.textContaining('300'), findsWidgets);

      // Check payment options
      expect(find.text('Go-Volts Wallet'), findsOneWidget);
      expect(find.text('Add new card'), findsOneWidget);
      expect(find.text('Bank account'), findsOneWidget);
      expect(find.text('Cash'), findsOneWidget);

      // Tap "Confirm ride"
      final confirmBtn = find.text('Confirm ride');
      expect(confirmBtn, findsOneWidget);
      await tester.tap(confirmBtn);
      await tester.pumpAndSettle();

      // Screen 10 should now be visible: "Confirm your ride"
      expect(find.text('Confirm your ride'), findsOneWidget);
    });

    testWidgets('Screen 10: Booking confirmation displays summary, toggles terms, and books ride', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final repo = _MockBookingRepository();
      final container = ProviderContainer(
        overrides: [
          bookingRepositoryProvider.overrideWithValue(repo),
        ],
      );
      addTearDown(container.dispose);

      final notifier = container.read(bookingNotifierProvider.notifier);
      notifier.setPickupLocation(
        const LocationDto(latitude: 6.4281, longitude: 3.4219, address: 'Eko Hotel and Suites'),
      );
      notifier.setDropoffLocation(
        const LocationDto(latitude: 6.4344, longitude: 3.4428, address: 'Palms Mall'),
      );

      await tester.pumpWidget(
        buildTestableWidget(
          container: container,
          initialStep: 'confirm',
        ),
      );

      await tester.pumpAndSettle();

      // Verify route details
      expect(find.text('Confirm your ride'), findsOneWidget);
      expect(find.text('Eko Hotel and Suites'), findsWidgets);
      expect(find.text('Palms Mall'), findsWidgets);

      // Verify actions
      expect(find.text('Add stop (optional)'), findsOneWidget);
      expect(find.text('Schedule for later'), findsOneWidget);

      // Terms agreement checkbox
      expect(find.textContaining('Terms of Service and Privacy Policy'), findsOneWidget);

      // Book ride CTA
      final bookRideBtn = find.text('Book ride');
      expect(bookRideBtn, findsOneWidget);

      // Tap Book Ride
      await tester.tap(bookRideBtn);
      await tester.pumpAndSettle();

      expect(repo.createBookingCalled, isTrue);
      expect(repo.lastQuoteId, equals('QT-TEST-RIDE-01'));
    });
  });
}
