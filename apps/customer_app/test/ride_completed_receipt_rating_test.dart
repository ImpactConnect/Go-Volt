import 'package:api_client/api_client.dart';
import 'package:app_config/app_config.dart';
import 'package:app_models/app_models.dart';
import 'package:customer_app/src/core/providers/api_providers.dart';
import 'package:customer_app/src/core/router/app_router.dart';
import 'package:customer_app/src/features/booking/data/booking_repository.dart';
import 'package:customer_app/src/features/tracking/application/tracking_notifier.dart';
import 'package:customer_app/src/features/tracking/data/tracking_repository.dart';
import 'package:customer_app/src/features/tracking/presentation/rate_trip_screen.dart';
import 'package:customer_app/src/features/tracking/presentation/receipt_screen.dart';
import 'package:customer_app/src/features/tracking/presentation/trip_completed_screen.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

class _FakeBookingRepository implements BookingRepository {
  bool submitTripRatingCalled = false;
  TripRatingDto? lastRating;

  @override
  Future<QuoteDto> requestQuote({
    required ServiceCode serviceCode,
    required LocationDto pickup,
    required LocationDto dropoff,
    DateTime? scheduledTime,
    PackageCategory? packageCategory,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<BookingDto> createBooking({
    required String quoteId,
    required PaymentMethod paymentMethod,
    String? instructions,
    String? recipientName,
    String? recipientPhone,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<BookingDto> getBooking(String bookingId) async => throw UnimplementedError();

  @override
  Future<BookingDto> cancelBooking(String bookingId, {required String reason}) async => throw UnimplementedError();

  @override
  Future<List<BookingDto>> listBookings({String? status, int limit = 20}) async => [];

  @override
  Future<List<RideCategoryDto>> getRideCategories() async => [];

  @override
  Future<CouponValidationDto> validateCoupon({
    required String code,
    required int quoteAmountKobo,
    String? serviceCode,
  }) async => const CouponValidationDto(isValid: true, code: 'GO20');

  @override
  Future<TripReceiptDto> getTripReceipt(String bookingId) async {
    return TripReceiptDto(
      bookingId: bookingId,
      receiptReference: 'TRP123456789',
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
        totalAmountKobo: 320000,
      ),
      totalPaidKobo: 320000,
    );
  }

  @override
  Future<bool> submitTripRating(TripRatingDto rating) async {
    submitTripRatingCalled = true;
    lastRating = rating;
    return true;
  }
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  final testConfig = AppConfig.dev();
  final testApiClient = ApiClient(config: testConfig);
  final testTrackingRepo = TrackingRepository(apiClient: testApiClient);
  final fakeBookingRepo = _FakeBookingRepository();

  final completedBooking = BookingDto(
    id: 'demo-live-01',
    bookingReference: 'GV-TRK-8392',
    serviceCode: ServiceCode.instantRide,
    status: BookingStatus.completed,
    pickupLocation: const LocationDto(
      latitude: 6.4281,
      longitude: 3.4219,
      address: 'Eko Hotel and Suites',
      label: 'Eko Hotel and Suites',
    ),
    dropoffLocation: const LocationDto(
      latitude: 6.4344,
      longitude: 3.4428,
      address: 'Palms Mall',
      label: 'Palms Mall',
    ),
    priceBreakdown: const PriceBreakdownDto(
      baseAmountKobo: 150000,
      distanceAmountKobo: 110000,
      timeAmountKobo: 30000,
      serviceFeeKobo: 20000,
      discountAmountKobo: 30000,
      totalAmountKobo: 320000,
    ),
    createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
    riderId: 'rider-daniel-01',
    riderName: 'Daniel Okafor',
    riderPhone: '+2348039281742',
    riderRating: 4.8,
    driverTripsCount: 320,
    vehicleType: VehicleType.electricCar,
    vehiclePlate: 'KJA 123 AB',
    vehicleModel: 'Toyota Corolla - Black',
    rideCategoryName: 'GoRide Standard',
    distanceKm: 8.4,
    durationMinutes: 12,
  );

  Widget buildTestableWidget({
    required Widget child,
  }) {
    return ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(testConfig),
        apiClientProvider.overrideWithValue(testApiClient),
        trackingRepositoryProvider.overrideWithValue(testTrackingRepo),
        bookingRepositoryProvider.overrideWithValue(fakeBookingRepo),
        liveTrackingNotifierProvider.overrideWith(
          (ref) => LiveTrackingNotifier(
            repository: testTrackingRepo,
            initialBooking: completedBooking,
          ),
        ),
      ],
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: GVColors.brandGreen),
        ),
        routes: {
          AppRoutes.receipt: (ctx) => const Scaffold(body: Text('Receipt Route')),
          AppRoutes.rateTrip: (ctx) => const Scaffold(body: Text('Rate Trip Route')),
          AppRoutes.home: (ctx) => const Scaffold(body: Text('Home Route')),
        },
        home: child,
      ),
    );
  }

  group('Ride Flow Step 6: Trip Completed, Digital Receipt & Rating (Screens 15 to 17)', () {
    testWidgets('Screen 15: Trip Completed renders summary, savings pill and actions', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestableWidget(
          child: const TripCompletedScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Title & Subtitle
      expect(find.text('Trip completed!'), findsOneWidget);
      expect(find.text('Thanks for riding with Go-Volts.'), findsOneWidget);

      // Fare & Promo Savings
      expect(find.text('₦3,200'), findsOneWidget);
      expect(find.text('You saved ₦300 with promo'), findsOneWidget);

      // Driver info
      expect(find.text('Daniel Okafor'), findsWidgets);
      expect(find.textContaining('Toyota Corolla - Black'), findsWidgets);

      // Trip attributes
      expect(find.text('Eko Hotel and Suites'), findsWidgets);
      expect(find.text('Palms Mall'), findsWidgets);
      expect(find.text('8.4 km'), findsOneWidget);
      expect(find.text('12 min'), findsOneWidget);
      expect(find.text('GoRide Standard'), findsOneWidget);

      // Buttons
      final viewReceiptBtn = find.text('View receipt');
      expect(viewReceiptBtn, findsOneWidget);
      final rateRiderBtn = find.text('Rate your rider');
      expect(rateRiderBtn, findsOneWidget);

      // Tap View receipt to test navigation
      await tester.tap(viewReceiptBtn);
      await tester.pumpAndSettle();
      expect(find.text('Receipt Route'), findsOneWidget);
    });

    testWidgets('Screen 16: Receipt Screen displays itemized invoice and action tiles', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestableWidget(
          child: const ReceiptScreen(),
        ),
      );

      await tester.pumpAndSettle();

      // Title & Subtitle
      expect(find.text('Trip receipt'), findsOneWidget);
      expect(find.text('Here are the details of your trip.'), findsOneWidget);

      // Reference
      expect(find.textContaining('TRP123456789'), findsWidgets);

      // Driver
      expect(find.text('Daniel Okafor'), findsWidgets);

      // Itemized breakdown lines
      expect(find.text('Base fare'), findsOneWidget);
      expect(find.text('₦1,500'), findsOneWidget);
      expect(find.textContaining('Distance (8.4 km)'), findsOneWidget);
      expect(find.text('₦1,100'), findsOneWidget);
      expect(find.textContaining('Time (12 min)'), findsOneWidget);
      expect(find.text('₦300'), findsOneWidget);
      expect(find.text('Service fee'), findsOneWidget);
      expect(find.text('₦200'), findsOneWidget);
      expect(find.text('Subtotal'), findsOneWidget);
      expect(find.text('₦3,100'), findsOneWidget);
      expect(find.text('Promo discount'), findsOneWidget);
      expect(find.text('- ₦300'), findsOneWidget);
      expect(find.text('Total paid'), findsOneWidget);
      expect(find.text('₦3,200'), findsWidgets);

      // Payment method
      expect(find.text('Go-Volts Wallet'), findsOneWidget);

      // Actions
      expect(find.text('Download receipt'), findsOneWidget);
      expect(find.text('Share receipt'), findsOneWidget);
      expect(find.text('Report an issue'), findsOneWidget);
    });

    testWidgets('Screen 17: Rate Trip submits compliments, rating and feedback', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestableWidget(
          child: const RateTripScreen(
            driverName: 'Daniel Okafor',
            vehicleInfo: 'Toyota Corolla - KJA 123 AB',
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Title & Subtitle
      expect(find.text('Rate your trip'), findsOneWidget);
      expect(find.text('How was your experience?'), findsOneWidget);

      // Driver info
      expect(find.text('Daniel Okafor'), findsOneWidget);
      expect(find.text('Toyota Corolla - KJA 123 AB'), findsOneWidget);

      // Compliment pills
      expect(find.text('Great driver'), findsOneWidget);
      expect(find.text('Safe ride'), findsOneWidget);
      expect(find.text('Clean car'), findsOneWidget);
      expect(find.text('On time'), findsOneWidget);
      expect(find.text('Friendly'), findsOneWidget);

      // Tap 'Great driver' compliment
      await tester.tap(find.text('Great driver'));
      await tester.pumpAndSettle();

      // Enter comment
      final commentField = find.byType(TextField);
      expect(commentField, findsOneWidget);
      await tester.enterText(commentField, 'Smooth ride and polite driver!');
      await tester.pumpAndSettle();

      // Would ride again toggle
      expect(find.text('Would you ride with Daniel again?'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);

      // Submit CTA
      final submitBtn = find.text('Submit');
      expect(submitBtn, findsOneWidget);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();

      expect(fakeBookingRepo.submitTripRatingCalled, isTrue);
      expect(fakeBookingRepo.lastRating?.rating, equals(5));
      expect(fakeBookingRepo.lastRating?.compliments, contains('Great driver'));
      expect(fakeBookingRepo.lastRating?.comment, equals('Smooth ride and polite driver!'));
      expect(fakeBookingRepo.lastRating?.wouldRideAgain, isTrue);
    });
  });
}

