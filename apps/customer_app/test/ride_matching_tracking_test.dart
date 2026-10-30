import 'package:api_client/api_client.dart';
import 'package:app_config/app_config.dart';
import 'package:app_models/app_models.dart';
import 'package:customer_app/src/core/providers/api_providers.dart';
import 'package:customer_app/src/features/booking/presentation/finding_driver_screen.dart';
import 'package:customer_app/src/features/tracking/application/tracking_notifier.dart';
import 'package:customer_app/src/features/tracking/data/tracking_repository.dart';
import 'package:customer_app/src/features/tracking/presentation/live_tracking_screen.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  final testConfig = AppConfig.dev();
  final testApiClient = ApiClient(config: testConfig);
  final testTrackingRepo = TrackingRepository(apiClient: testApiClient);

  final testBooking = BookingDto(
    id: 'demo-live-01',
    bookingReference: 'GV-TRK-8392',
    serviceCode: ServiceCode.instantRide,
    status: BookingStatus.assigned,
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
      totalAmountKobo: 320000,
    ),
    createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
    riderId: 'rider-daniel-01',
    riderName: 'Daniel Okafor',
    riderPhone: '+2348039281742',
    riderRating: 4.8,
    driverTripsCount: 320,
    vehicleType: VehicleType.electricCar,
    vehiclePlate: 'KJA 123 AB',
    vehicleModel: 'Toyota Corolla - Black',
    distanceKm: 8.4,
    durationMinutes: 12,
  );

  Widget buildTestableWidget({
    required Widget child,
    LiveTrackingNotifier? notifierOverride,
  }) {
    return ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(testConfig),
        apiClientProvider.overrideWithValue(testApiClient),
        trackingRepositoryProvider.overrideWithValue(testTrackingRepo),
        if (notifierOverride != null)
          liveTrackingNotifierProvider.overrideWith((ref) => notifierOverride),
      ],
      child: MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: GVColors.brandGreen),
        ),
        home: child,
      ),
    );
  }

  group('Ride Flow Step 5: Matching Radar & Live Tracking (Screens 11 to 14)', () {
    testWidgets('Screen 11: Finding Driver renders radar, 4-step checklist, notice and cancel button', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        buildTestableWidget(
          child: const FindingDriverScreen(autoAdvance: false),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Check Title & Subtitle
      expect(find.text('Finding a rider for you...'), findsOneWidget);
      expect(find.text('This usually takes less than 1 minute.'), findsOneWidget);

      // Check 4 status steps
      expect(find.text('Sending your request'), findsOneWidget);
      expect(find.text('Looking for nearby riders'), findsOneWidget);
      expect(find.text('Confirming rider'), findsOneWidget);
      expect(find.text('Finalizing your ride'), findsOneWidget);

      // Check notification banner
      expect(
        find.text("You'll be notified as soon as a rider accepts your request."),
        findsOneWidget,
      );

      // Check Cancel ride button
      final cancelBtn = find.text('Cancel ride');
      expect(cancelBtn, findsOneWidget);

      // Tap Cancel ride to verify confirmation sheet opens
      await tester.tap(cancelBtn);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Cancel ride request?'), findsOneWidget);
      expect(find.text('Keep searching'), findsOneWidget);
    });

    testWidgets('Screen 12: Rider Assigned renders driver card, ETA callout, and visual vehicle banner', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final notifier = LiveTrackingNotifier(
        repository: testTrackingRepo,
        initialBooking: testBooking,
      );

      await tester.pumpWidget(
        buildTestableWidget(
          notifierOverride: notifier,
          child: const LiveTrackingScreen(initialStatus: BookingStatus.assigned),
        ),
      );

      await tester.pumpAndSettle();

      // Screen 12 Header
      expect(find.text('Rider assigned!'), findsOneWidget);
      expect(find.text('Your rider is on the way to pick you up.'), findsOneWidget);

      // Driver info
      expect(find.text('Daniel Okafor'), findsWidgets);
      expect(find.textContaining('KJA 123 AB'), findsWidgets);

      // Arrival ETA RichText
      expect(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('6 min'),
        ),
        findsWidgets,
      );

      // Visual identifier banner
      expect(
        find.textContaining('Look for a black Toyota Corolla with plate number KJA 123 AB'),
        findsOneWidget,
      );

      // Action pills
      expect(find.text('Share trip'), findsOneWidget);
      expect(find.text('Safety'), findsWidgets);
    });

    testWidgets('Screen 13: Driver Approaching renders arrival banner, horizontal progress and message/call actions', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final approachingBooking = testBooking.copyWith(
        status: BookingStatus.arrivedAtPickup,
      );
      final notifier = LiveTrackingNotifier(
        repository: testTrackingRepo,
        initialBooking: approachingBooking,
      );

      await tester.pumpWidget(
        buildTestableWidget(
          notifierOverride: notifier,
          child: const LiveTrackingScreen(initialStatus: BookingStatus.arrivedAtPickup),
        ),
      );

      await tester.pumpAndSettle();

      // Screen 13 Header
      expect(find.text('Driver approaching'), findsOneWidget);
      expect(find.text('Your rider is almost here.'), findsOneWidget);

      // Alert notification
      expect(find.text('Driver is 2 minutes away'), findsOneWidget);
      expect(find.text('Please be ready at your pickup location.'), findsOneWidget);

      // Horizontal progress stepper
      expect(find.text('Driver on the way'), findsOneWidget);
      expect(find.text('Arriving soon'), findsOneWidget);
      expect(find.text('Arrived'), findsOneWidget);

      // Contact action buttons
      expect(find.text('Message'), findsOneWidget);
      expect(find.text('Call'), findsOneWidget);
    });

    testWidgets('Screen 14: On Trip renders metrics, vertical timeline and End trip CTA', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final inProgressBooking = testBooking.copyWith(
        status: BookingStatus.inProgress,
      );
      final notifier = LiveTrackingNotifier(
        repository: testTrackingRepo,
        initialBooking: inProgressBooking,
      );

      await tester.pumpWidget(
        buildTestableWidget(
          notifierOverride: notifier,
          child: const LiveTrackingScreen(initialStatus: BookingStatus.inProgress),
        ),
      );

      await tester.pumpAndSettle();

      // Screen 14 Header & Metrics
      expect(find.text('Trip in progress'), findsOneWidget);
      expect(find.text('12 min • 8.4 km'), findsOneWidget);

      // Vertical progress timeline
      expect(find.text('Picked up'), findsOneWidget);
      expect(find.text('10:05 AM'), findsOneWidget);
      expect(find.text('On trip'), findsOneWidget);
      expect(find.text('Arriving at destination'), findsOneWidget);
      expect(find.text('10:17 AM'), findsOneWidget);

      // End Trip CTA
      final endTripBtn = find.text('End trip');
      expect(endTripBtn, findsOneWidget);
    });
  });
}
