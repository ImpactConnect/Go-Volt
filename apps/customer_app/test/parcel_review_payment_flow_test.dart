import 'package:app_models/app_models.dart';
import 'package:customer_app/src/core/router/app_router.dart';
import 'package:customer_app/src/features/parcel/application/parcel_booking_notifier.dart';
import 'package:customer_app/src/features/parcel/presentation/parcel_payment_screen.dart';
import 'package:customer_app/src/features/parcel/presentation/parcel_review_screen.dart';
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
        AppRoutes.parcelPickupLocation: (_) =>
            const Scaffold(body: Text('ParcelPickupLocationRoute')),
        AppRoutes.parcelPayment: (_) =>
            const Scaffold(body: Text('ParcelPaymentRoute')),
        AppRoutes.parcelConfirmation: (_) =>
            const Scaffold(body: Text('ParcelConfirmationRoute')),
      },
    ),
  );
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Screen 7: ParcelReviewScreen Tests', () {
    testWidgets(
        'renders delivery details, package details, itemized breakdown and disclaimer',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _buildTestApp(
          home: const ParcelReviewScreen(),
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      // Top bar title
      expect(find.text('Review and Quote'), findsOneWidget);

      // 1. Delivery Details
      expect(find.text('Delivery details'), findsOneWidget);
      expect(find.text('Edit'), findsOneWidget);
      expect(
        find.text('Central Roundabout, Shaganu, Ogun State'),
        findsOneWidget,
      );
      expect(find.text('Main Market, Shaganu, Ogun State'), findsWidgets);

      // 2. Package Details
      expect(find.text('Package details'), findsOneWidget);
      expect(find.text('Fragile item'), findsOneWidget);
      expect(find.textContaining('1.5 kg • Small'), findsOneWidget);
      expect(find.textContaining('Standard Delivery'), findsOneWidget);

      // 3. Price Breakdown
      expect(find.text('Price breakdown'), findsOneWidget);
      expect(find.text('Base fare'), findsOneWidget);
      expect(find.text('₦2,000'), findsOneWidget);

      expect(find.textContaining('Distance (12.4 km)'), findsOneWidget);
      expect(find.text('₦300'), findsOneWidget);

      expect(find.text('Package handling'), findsOneWidget);
      expect(find.text('₦200'), findsOneWidget);

      expect(find.text('Insurance'), findsOneWidget);
      expect(find.text('₦0'), findsOneWidget);

      expect(find.text('Total fare'), findsOneWidget);
      expect(find.text('₦2,500'), findsOneWidget);

      // Disclaimer
      expect(
        find.textContaining(
            'Final fare may vary slightly based on distance, traffic and package details.'),
        findsOneWidget,
      );

      // CTA
      expect(find.text('Continue to payment'), findsOneWidget);

      // Tap Continue to payment
      await tester.tap(find.text('Continue to payment'));
      await tester.pumpAndSettle();

      expect(find.text('ParcelPaymentRoute'), findsOneWidget);
    });

    testWidgets('tapping Edit in delivery details navigates to pickup screen',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _buildTestApp(
          home: const ParcelReviewScreen(),
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      expect(find.text('ParcelPickupLocationRoute'), findsOneWidget);
    });
  });

  group('Screen 8: ParcelPaymentScreen Tests', () {
    testWidgets('renders all payment methods and switches selection',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _buildTestApp(
          home: const ParcelPaymentScreen(),
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      // Top bar title
      expect(find.text('Payment method'), findsOneWidget);

      // Payment methods
      expect(find.text('Go-Volts Wallet'), findsOneWidget);
      expect(find.text('Balance: ₦5,200.00'), findsOneWidget);

      expect(find.text('Add new card'), findsOneWidget);
      expect(find.text('Debit or credit card'), findsOneWidget);

      expect(find.text('Bank account'), findsOneWidget);
      expect(find.text('Pay directly from your bank'), findsOneWidget);

      expect(find.text('Cash'), findsOneWidget);
      expect(find.text('Pay with cash'), findsOneWidget);

      expect(find.text('Other payment options'), findsOneWidget);

      // Initially wallet is selected
      expect(
        container.read(parcelBookingNotifierProvider).paymentMethod,
        PaymentMethod.wallet,
      );

      // Switch to Card
      await tester.tap(find.text('Add new card'));
      await tester.pumpAndSettle();

      expect(
        container.read(parcelBookingNotifierProvider).paymentMethod,
        PaymentMethod.card,
      );

      // Switch to Cash
      await tester.tap(find.text('Cash'));
      await tester.pumpAndSettle();

      expect(
        container.read(parcelBookingNotifierProvider).paymentMethod,
        PaymentMethod.cash,
      );
    });

    testWidgets('promo code validation, application and removal', (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _buildTestApp(
          home: const ParcelPaymentScreen(),
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      // Enter invalid code
      await tester.enterText(
        find.widgetWithText(TextField, 'Enter promo code'),
        'INVALID',
      );
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(find.text('Invalid promo code. Try DELIVER20'), findsOneWidget);
      expect(find.text('₦2,500'), findsOneWidget);

      // Enter valid code
      await tester.enterText(
        find.widgetWithText(TextField, 'Enter promo code'),
        'DELIVER20',
      );
      await tester.tap(find.text('Apply'));
      await tester.pumpAndSettle();

      expect(find.textContaining('DELIVER20 (20% OFF: -₦400)'), findsOneWidget);
      expect(find.text('₦2,100'), findsOneWidget);

      // Remove promo code
      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pumpAndSettle();

      expect(find.text('₦2,500'), findsOneWidget);
    });

    testWidgets('confirm delivery triggers booking and navigates to confirmation',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        _buildTestApp(
          home: const ParcelPaymentScreen(),
          container: container,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Confirm delivery'), findsOneWidget);
      expect(
        find.textContaining('By proceeding, you agree to our Terms of Service'),
        findsOneWidget,
      );

      // Tap Confirm delivery
      await tester.tap(find.text('Confirm delivery'));
      await tester.pump(); // Start loading
      await tester.pump(const Duration(milliseconds: 350)); // Finish delay
      await tester.pumpAndSettle();

      final state = container.read(parcelBookingNotifierProvider);
      expect(state.activeDelivery, isNotNull);
      expect(state.activeDelivery?.trackingNumber, 'DVL12345678');
      expect(find.text('ParcelConfirmationRoute'), findsOneWidget);
    });
  });
}
