import 'package:app_models/app_models.dart';
import 'package:customer_app/src/core/router/app_router.dart';
import 'package:customer_app/src/features/parcel/application/parcel_booking_notifier.dart';
import 'package:customer_app/src/features/parcel/data/parcel_repository.dart';
import 'package:customer_app/src/features/parcel/presentation/parcel_confirmation_screen.dart';
import 'package:customer_app/src/features/parcel/presentation/parcel_finding_rider_screen.dart';
import 'package:customer_app/src/features/parcel/presentation/parcel_live_tracking_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

Widget _buildTestApp({
  required Widget home,
  required ProviderContainer container,
}) {
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      home: home,
      routes: {
        AppRoutes.parcelFindingRider: (_) =>
            const Scaffold(body: Text('ParcelFindingRiderRoute')),
        AppRoutes.parcelReviewQuote: (_) =>
            const Scaffold(body: Text('ParcelReviewQuoteRoute')),
        AppRoutes.parcelLiveTracking: (_) =>
            const Scaffold(body: Text('ParcelLiveTrackingRoute')),
        AppRoutes.home: (_) => const Scaffold(body: Text('HomeRoute')),
      },
    ),
  );
}

ProviderContainer _createTestContainer() {
  return ProviderContainer(
    overrides: [
      parcelRepositoryProvider.overrideWithValue(FakeParcelRepository()),
    ],
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Screen 9: ParcelConfirmationScreen Tests', () {
    testWidgets('renders confirmation header, tracking number, route specs and CTAs',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = _createTestContainer();
      addTearDown(container.dispose);

      // Pre-commit booking to have active delivery
      await container
          .read(parcelBookingNotifierProvider.notifier)
          .commitBooking(simulateDelay: false);

      await tester.pumpWidget(
        _buildTestApp(
          home: const ParcelConfirmationScreen(),
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      // Celebratory header
      expect(find.text('Delivery request sent!'), findsOneWidget);
      expect(
        find.textContaining('We are looking for a rider to deliver'),
        findsOneWidget,
      );

      // Tracking number
      expect(find.text('Tracking number'), findsOneWidget);
      expect(find.text('DVL12345678'), findsOneWidget);
      expect(find.byIcon(Icons.copy_rounded), findsOneWidget);

      // Route summary
      expect(find.text('Shaganu Central'), findsOneWidget);
      expect(find.text('Shaganu Main Market'), findsOneWidget);
      expect(find.textContaining('Fragile item • 1.5 kg'), findsOneWidget);

      // CTAs
      expect(find.text('Track delivery'), findsOneWidget);
      expect(find.text('View details'), findsOneWidget);

      // Tap Track delivery -> navigates to finding rider
      await tester.tap(find.text('Track delivery'));
      await tester.pumpAndSettle();

      expect(find.text('ParcelFindingRiderRoute'), findsOneWidget);
    });

    testWidgets('copy tracking number triggers snackbar', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = _createTestContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _buildTestApp(
          home: const ParcelConfirmationScreen(),
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.copy_rounded));
      await tester.pump();

      expect(find.text('Tracking number copied to clipboard'), findsOneWidget);
    });
  });

  group('Screen 10: ParcelFindingRiderScreen Tests', () {
    testWidgets('renders motorbike radar, 4-step checklist and cancel action',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = _createTestContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _buildTestApp(
          home: const ParcelFindingRiderScreen(
            autoTransition: false,
            animateRadar: false,
          ),
          container: container,
        ),
      );
      await tester.pump(); // Render initial frame

      // Radar bike icon
      expect(find.byIcon(Icons.two_wheeler_rounded), findsOneWidget);

      // Title & Subtitle
      expect(find.text('Finding a rider for your delivery...'), findsOneWidget);
      expect(
        find.text('This usually takes less than 1 minute.'),
        findsOneWidget,
      );

      // 4-step checklist
      expect(find.text('Sending your request'), findsOneWidget);
      expect(find.text('Looking for nearby riders'), findsOneWidget);
      expect(find.text('Confirming rider'), findsOneWidget);
      expect(find.text('Preparing for pickup'), findsOneWidget);

      // Cancel button
      expect(find.text('Cancel delivery'), findsOneWidget);

      // Tap cancel
      await tester.tap(find.text('Cancel delivery'));
      await tester.pumpAndSettle();

      expect(find.text('HomeRoute'), findsOneWidget);
    });
  });

  group('Screens 11, 12, 13: ParcelLiveTrackingScreen Tests', () {
    testWidgets('Screen 11: renders Rider Assigned with Daniel Okafor and 6 min ETA',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = _createTestContainer();
      addTearDown(container.dispose);

      await container
          .read(parcelBookingNotifierProvider.notifier)
          .commitBooking(simulateDelay: false);
      container.read(parcelBookingNotifierProvider.notifier).updateDeliveryStatus(
            BookingStatus.assigned,
            etaMinutes: 6,
          );

      await tester.pumpWidget(
        _buildTestApp(
          home: const ParcelLiveTrackingScreen(
            initialStatus: BookingStatus.assigned,
          ),
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      // Top bar title & subtitle
      expect(find.text('Rider assigned'), findsOneWidget);
      expect(
        find.text('Your rider is on the way to pick up your parcel.'),
        findsOneWidget,
      );

      // ETA bubble
      expect(find.text('6 min away'), findsOneWidget);

      // Driver info
      expect(find.text('Daniel Okafor'), findsOneWidget);
      expect(find.textContaining('4.9 (320 deliveries)'), findsOneWidget);
      expect(find.textContaining('Yamaha Bike - ABC-123XY'), findsOneWidget);

      // Readiness banner
      expect(
        find.text('Rider will arrive in 6 min. Please be at the pickup location.'),
        findsOneWidget,
      );

      // Actions
      expect(find.text('Share delivery'), findsOneWidget);
      expect(find.text('Call rider'), findsOneWidget);
    });

    testWidgets('Screen 12: renders Rider Approaching with 2 min ETA',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = _createTestContainer();
      addTearDown(container.dispose);

      await container
          .read(parcelBookingNotifierProvider.notifier)
          .commitBooking(simulateDelay: false);
      container.read(parcelBookingNotifierProvider.notifier).updateDeliveryStatus(
            BookingStatus.arrivedAtPickup,
            etaMinutes: 2,
          );

      await tester.pumpWidget(
        _buildTestApp(
          home: const ParcelLiveTrackingScreen(
            initialStatus: BookingStatus.arrivedAtPickup,
          ),
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      // Top bar title & subtitle
      expect(find.text('Rider approaching'), findsOneWidget);
      expect(
        find.text('Your rider is almost at the pickup location.'),
        findsOneWidget,
      );

      // ETA bubble
      expect(find.text('2 min away'), findsOneWidget);

      // Readiness banner
      expect(
        find.text('Please be ready at the pickup location.'),
        findsOneWidget,
      );

      // Action buttons
      expect(find.text('Share location'), findsOneWidget);
      expect(find.text('Call rider'), findsOneWidget);
    });

    testWidgets('Screen 13: renders Pickup Completed with handover card and timeline',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = _createTestContainer();
      addTearDown(container.dispose);

      await container
          .read(parcelBookingNotifierProvider.notifier)
          .commitBooking(simulateDelay: false);
      container.read(parcelBookingNotifierProvider.notifier).updateDeliveryStatus(
            BookingStatus.parcelCollected,
          );

      await tester.pumpWidget(
        _buildTestApp(
          home: const ParcelLiveTrackingScreen(
            initialStatus: BookingStatus.parcelCollected,
          ),
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      // AppBar title
      expect(find.text('Pickup completed'), findsOneWidget);

      // Handover card content
      expect(find.text('Parcel picked up!'), findsOneWidget);
      expect(
        find.text('Your parcel is on its way to the destination.'),
        findsOneWidget,
      );

      // Timeline entries
      expect(find.text('Picked up'), findsOneWidget);
      expect(find.textContaining('10:05 AM'), findsOneWidget);
      expect(find.text('On the way'), findsOneWidget);
      expect(find.text('Arriving at destination'), findsOneWidget);

      // CTA
      expect(find.text('Track delivery'), findsOneWidget);
    });
  });
}
