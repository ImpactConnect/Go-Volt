import 'package:app_models/app_models.dart';
import 'package:customer_app/src/core/router/app_router.dart';
import 'package:customer_app/src/features/parcel/application/parcel_booking_notifier.dart';
import 'package:customer_app/src/features/parcel/data/parcel_repository.dart';
import 'package:customer_app/src/features/parcel/presentation/parcel_delivered_screen.dart';
import 'package:customer_app/src/features/parcel/presentation/parcel_live_tracking_screen.dart';
import 'package:customer_app/src/features/parcel/presentation/parcel_rating_screen.dart';
import 'package:customer_app/src/features/parcel/presentation/parcel_receipt_screen.dart';
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
        AppRoutes.parcelDelivered: (_) => const Scaffold(body: Text('ParcelDeliveredRoute')),
        AppRoutes.parcelReceipt: (_) => const Scaffold(body: Text('ParcelReceiptRoute')),
        AppRoutes.parcelRating: (_) => const Scaffold(body: Text('ParcelRatingRoute')),
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

  group('Screen 14: ParcelLiveTrackingScreen (In-Transit Stage)', () {
    testWidgets('renders in-transit route map, progress bar, courier card and delivered simulation',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = _createTestContainer();
      addTearDown(container.dispose);

      await container
          .read(parcelBookingNotifierProvider.notifier)
          .commitBooking(simulateDelay: false);

      container
          .read(parcelBookingNotifierProvider.notifier)
          .updateDeliveryStatus(BookingStatus.inProgress, etaMinutes: 18);

      await tester.pumpWidget(
        _buildTestApp(
          home: const ParcelLiveTrackingScreen(),
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      // In-transit ETA bubble and titles
      expect(find.text('On the way'), findsWidgets);
      expect(find.textContaining('Arriving at destination in'), findsOneWidget);
      expect(find.textContaining('18 min • 8.4 km'), findsOneWidget);

      // Rider details
      expect(find.text('Daniel Okafor'), findsOneWidget);
      expect(find.textContaining('Yamaha Bike - ABC-123XY'), findsOneWidget);

      // Advance to delivered
      expect(find.text('Simulate: Delivered'), findsOneWidget);
      await tester.tap(find.text('Simulate: Delivered'));
      await tester.pumpAndSettle();

      expect(find.text('ParcelDeliveredRoute'), findsOneWidget);
    });
  });

  group('Screen 15: ParcelDeliveredScreen (Proof of Delivery)', () {
    testWidgets('renders celebratory checkmark, recipient details, proof signature and view receipt CTA',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = _createTestContainer();
      addTearDown(container.dispose);

      await container
          .read(parcelBookingNotifierProvider.notifier)
          .commitBooking(simulateDelay: false);

      await tester.pumpWidget(
        _buildTestApp(
          home: const ParcelDeliveredScreen(),
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      // Success heading
      expect(find.text('Delivered successfully!'), findsOneWidget);
      expect(find.text('Your parcel has been delivered.'), findsOneWidget);

      // Recipient details
      expect(find.text('Delivered to'), findsOneWidget);
      expect(find.text('John Doe'), findsWidgets);
      expect(find.textContaining('Main Market, Shaganu, Ogun State'), findsOneWidget);

      // Timestamp & Digital signature
      expect(find.text('Delivered at'), findsOneWidget);
      expect(find.text('Oct 29, 2026, 10:45 AM'), findsOneWidget);
      expect(find.text('Received by'), findsOneWidget);

      // View receipt CTA
      expect(find.text('View receipt'), findsOneWidget);
      await tester.tap(find.text('View receipt'));
      await tester.pumpAndSettle();

      expect(find.text('ParcelReceiptRoute'), findsOneWidget);
    });
  });

  group('Screen 16: ParcelReceiptScreen (Delivery Receipt)', () {
    testWidgets('renders receipt details, fare breakdown, payment method and rate CTA',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = _createTestContainer();
      addTearDown(container.dispose);

      await container
          .read(parcelBookingNotifierProvider.notifier)
          .commitBooking(simulateDelay: false);

      await tester.pumpWidget(
        _buildTestApp(
          home: const ParcelReceiptScreen(),
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      // Screen title and receipt reference
      expect(find.text('Delivery receipt'), findsOneWidget);
      expect(find.text('GO-VOLTS'), findsOneWidget);
      expect(find.text('DVL12345678'), findsOneWidget);

      // Locations & Package summary
      expect(find.textContaining('Central Roundabout, Shaganu'), findsOneWidget);
      expect(find.textContaining('Main Market, Shaganu'), findsOneWidget);
      expect(find.textContaining('Fragile item • 1.5 kg'), findsOneWidget);

      // Fare Breakdown
      expect(find.text('Fare breakdown'), findsOneWidget);
      expect(find.text('Base fare'), findsOneWidget);
      expect(find.text('₦2,000'), findsOneWidget);
      expect(find.text('Total paid'), findsOneWidget);
      expect(find.text('₦2,500'), findsWidgets);

      // Payment Method
      expect(find.text('Payment method'), findsOneWidget);
      expect(find.text('Go-Volts Wallet'), findsOneWidget);

      // Secondary action buttons
      expect(find.text('Download receipt'), findsOneWidget);
      expect(find.text('Share'), findsOneWidget);

      // Primary bottom CTA: Rate your experience
      expect(find.text('Rate your experience'), findsOneWidget);
      await tester.tap(find.text('Rate your experience'));
      await tester.pumpAndSettle();

      expect(find.text('ParcelRatingRoute'), findsOneWidget);
    });
  });

  group('Screen 17: ParcelRatingScreen (Rate Your Experience)', () {
    testWidgets('renders courier info, star rating, compliments, comment box and submits',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = _createTestContainer();
      addTearDown(container.dispose);

      await container
          .read(parcelBookingNotifierProvider.notifier)
          .commitBooking(simulateDelay: false);

      await tester.pumpWidget(
        _buildTestApp(
          home: const ParcelRatingScreen(),
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      // Screen title and courier details
      expect(find.text('Rate your experience'), findsOneWidget);
      expect(find.text('Daniel Okafor'), findsOneWidget);
      expect(find.text('Yamaha Bike - ABC-123XY'), findsOneWidget);

      // Interactive 5 stars (5 stars rendered)
      expect(find.byIcon(Icons.star_rounded), findsNWidgets(5));

      // Tap 4th star -> updates rating to 4
      await tester.tap(find.byIcon(Icons.star_rounded).at(3));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.star_rounded), findsNWidgets(4));
      expect(find.byIcon(Icons.star_outline_rounded), findsOneWidget);

      // Available compliment tags
      expect(find.text('Excellent'), findsOneWidget);
      expect(find.text('Good'), findsOneWidget);
      expect(find.text('On time'), findsOneWidget);
      expect(find.text('Handled with care'), findsOneWidget);
      expect(find.text('Great communication'), findsOneWidget);
      expect(find.text('Others'), findsOneWidget);

      // Tap compliments to select
      await tester.tap(find.text('On time'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Handled with care'));
      await tester.pumpAndSettle();

      // Comment input
      expect(find.text('Add a comment (optional)'), findsOneWidget);
      expect(find.text('0/200'), findsOneWidget);

      await tester.enterText(
        find.byType(TextField),
        'Super fast and safe delivery!',
      );
      await tester.pumpAndSettle();

      expect(find.text('29/200'), findsOneWidget);

      // Submit rating
      expect(find.text('Submit'), findsOneWidget);
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      // Verifies navigation back to Home
      expect(find.text('HomeRoute'), findsOneWidget);

      // Verifies submitted rating in state
      final submitted = container.read(parcelBookingNotifierProvider).submittedRating;
      expect(submitted, isNotNull);
      expect(submitted!.ratingStars, 4);
      expect(submitted.compliments, containsAll(['On time', 'Handled with care']));
      expect(submitted.comment, 'Super fast and safe delivery!');
      expect(submitted.riderName, 'Daniel Okafor');
    });

    testWidgets('Done button resets flow and returns to Home', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = _createTestContainer();
      addTearDown(container.dispose);

      await container
          .read(parcelBookingNotifierProvider.notifier)
          .commitBooking(simulateDelay: false);

      await tester.pumpWidget(
        _buildTestApp(
          home: const ParcelRatingScreen(),
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Done'), findsOneWidget);
      await tester.tap(find.text('Done'));
      await tester.pumpAndSettle();

      expect(find.text('HomeRoute'), findsOneWidget);
    });
  });
}
