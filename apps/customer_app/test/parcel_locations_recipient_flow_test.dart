import 'package:customer_app/src/core/router/app_router.dart';
import 'package:customer_app/src/features/parcel/application/parcel_booking_notifier.dart';
import 'package:customer_app/src/features/parcel/presentation/parcel_delivery_location_screen.dart';
import 'package:customer_app/src/features/parcel/presentation/parcel_pickup_location_screen.dart';
import 'package:customer_app/src/features/parcel/presentation/recipient_details_screen.dart';
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
        AppRoutes.recipientDetails: (_) => const Scaffold(body: Text('RecipientDetailsRoute')),
        AppRoutes.parcelDeliveryLocation: (_) => const Scaffold(body: Text('ParcelDeliveryLocationRoute')),
        AppRoutes.parcelReviewQuote: (_) => const Scaffold(body: Text('ParcelReviewQuoteRoute')),
      },
    ),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Screen 4: ParcelPickupLocationScreen Tests', () {
    testWidgets('renders map pin, confirmed pickup address, saved places and handles selection',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _buildTestApp(
          home: const ParcelPickupLocationScreen(),
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      // Top bar title
      expect(find.text('Pickup location'), findsWidgets);

      // Central pin bubble and confirmed pickup card
      expect(find.text('Eko Hotel and Suites'), findsWidgets);
      expect(
        find.text('Adetokunbo Ademola St, Victoria Island, Lagos'),
        findsOneWidget,
      );

      // Saved places
      expect(find.text('Saved places'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Choose on map'), findsOneWidget);

      // Tap Work to change pickup location
      await tester.tap(find.text('Work'));
      await tester.pumpAndSettle();

      final state = container.read(parcelBookingNotifierProvider);
      expect(state.pickupLocation?.label, 'Work');
      expect(state.pickupLocation?.address, 'Lekki Phase 1, Lagos');

      // Continue button
      expect(find.text('Continue'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('RecipientDetailsRoute'), findsOneWidget);
    });

    testWidgets('edit pickup address dialog updates location', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _buildTestApp(
          home: const ParcelPickupLocationScreen(),
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      // Tap edit pencil icon
      await tester.tap(find.byIcon(Icons.edit_outlined));
      await tester.pumpAndSettle();

      expect(find.text('Edit Pickup Address'), findsOneWidget);
      await tester.enterText(
        find.byType(TextField),
        'Adeola Odeku St, Victoria Island, Lagos',
      );
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();

      expect(
        find.text('Adeola Odeku St, Victoria Island, Lagos'),
        findsOneWidget,
      );
    });
  });

  group('Screen 5: RecipientDetailsScreen Tests', () {
    testWidgets('renders all recipient form inputs and recent recipients',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _buildTestApp(
          home: const RecipientDetailsScreen(),
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      // Top bar title
      expect(find.text('Recipient details'), findsOneWidget);

      // Form inputs
      expect(find.text('Full name'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);

      expect(find.text('Phone number'), findsOneWidget);
      expect(find.text('+234'), findsOneWidget);
      expect(find.text('0803 123 4567'), findsWidgets);

      expect(find.text('Delivery address'), findsOneWidget);
      expect(find.text('Palms Mall, Lekki, Lagos'), findsWidgets);

      expect(find.text('Additional address info (optional)'), findsOneWidget);
      expect(find.text('Shop B12, Second floor'), findsWidgets);

      expect(find.text('Save as recipient'), findsOneWidget);
      expect(find.byType(Switch), findsOneWidget);

      // Recent recipients
      expect(find.text('Recent recipients'), findsOneWidget);
      expect(find.text('Sarah Ahmed'), findsOneWidget);
      expect(find.text('Michael Brown'), findsOneWidget);

      // Continue CTA
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('tapping recent recipient auto-populates form fields',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _buildTestApp(
          home: const RecipientDetailsScreen(),
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      // Tap on Sarah Ahmed
      await tester.tap(find.text('Sarah Ahmed'));
      await tester.pumpAndSettle();

      // Check form fields are updated
      expect(find.text('Sarah Ahmed'), findsWidgets);
      expect(find.text('0802 345 6789'), findsWidgets);
      expect(find.text('Lekki Phase 1, Lagos'), findsWidgets);

      final state = container.read(parcelBookingNotifierProvider);
      expect(state.recipient?.fullName, 'Sarah Ahmed');
      expect(state.recipient?.phoneNumber, '0802 345 6789');
    });

    testWidgets('tapping Continue persists recipient details and navigates',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _buildTestApp(
          home: const RecipientDetailsScreen(),
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      // Edit name
      final nameFinder = find.widgetWithText(TextFormField, 'John Doe');
      await tester.enterText(nameFinder, 'Alexander Hamilton');
      await tester.pumpAndSettle();

      // Tap Continue
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      final state = container.read(parcelBookingNotifierProvider);
      expect(state.recipient?.fullName, 'Alexander Hamilton');
      expect(find.text('ParcelDeliveryLocationRoute'), findsOneWidget);
    });
  });

  group('Screen 6: ParcelDeliveryLocationScreen Tests', () {
    testWidgets('renders map pin, destination address, saved places and updates state',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _buildTestApp(
          home: const ParcelDeliveryLocationScreen(),
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      // Top bar title
      expect(find.text('Delivery location'), findsOneWidget);

      // Pin and confirmed address
      expect(find.text('Destination location'), findsOneWidget);
      expect(find.text('Palms Mall'), findsWidgets);
      expect(find.text('Palms Mall, Lekki, Lagos'), findsWidgets);

      // Saved places
      expect(find.text('Saved places'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);

      // Tap Work to change destination
      await tester.tap(find.text('Work'));
      await tester.pumpAndSettle();

      final state = container.read(parcelBookingNotifierProvider);
      expect(state.destinationLocation?.label, 'Work');
      expect(state.destinationLocation?.address, 'Lekki Phase 1, Lagos');

      // Continue CTA
      expect(find.text('Continue'), findsOneWidget);
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(find.text('ParcelReviewQuoteRoute'), findsOneWidget);
    });

    testWidgets('recenter GPS button resets to default destination',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _buildTestApp(
          home: const ParcelDeliveryLocationScreen(),
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      // Change destination to Home
      await tester.tap(find.text('Home'));
      await tester.pumpAndSettle();
      expect(
        container.read(parcelBookingNotifierProvider).destinationLocation?.label,
        'Home',
      );

      // Tap Recenter GPS button
      await tester.tap(find.byIcon(Icons.my_location_rounded));
      await tester.pumpAndSettle();

      expect(
        container.read(parcelBookingNotifierProvider).destinationLocation?.label,
        'Palms Mall',
      );
    });
  });
}
