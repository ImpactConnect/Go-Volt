import 'package:app_models/app_models.dart';
import 'package:customer_app/src/features/parcel/application/parcel_booking_notifier.dart';
import 'package:customer_app/src/features/parcel/presentation/package_details_screen.dart';
import 'package:customer_app/src/features/parcel/presentation/parcel_delivery_type_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('ParcelBookingNotifier Unit Tests', () {
    late ParcelBookingNotifier notifier;

    setUp(() {
      notifier = ParcelBookingNotifier();
    });

    test('initial state matches baseline defaults', () {
      final state = notifier.state;
      expect(state.selectedDeliveryOption.code, 'STANDARD');
      expect(state.selectedCategory.code, 'FRAGILE');
      expect(state.weightKg, 1.5);
      expect(state.selectedSizeBand.code, 'SMALL');
      expect(state.isFragile, isTrue);
      expect(state.pickupLocation?.label, 'Eko Hotel and Suites');
      expect(state.recipient?.fullName, 'John Doe');
      expect(state.destinationLocation?.label, 'Palms Mall');
      expect(state.quote?.totalAmountKobo, 250000); // ₦2,500
      expect(state.quote?.formattedTotalFare, '₦2,500');
    });

    test('selectDeliveryOption updates delivery option and recalculates quote', () {
      notifier.selectDeliveryOption(DeliveryOptionDto.express);
      expect(notifier.state.selectedDeliveryOption.code, 'EXPRESS');
      // Express base fare is 350,000 + 30,000 + 20,000 = 400,000 kobo (₦4,000)
      expect(notifier.state.quote?.baseFareKobo, 350000);
      expect(notifier.state.quote?.totalAmountKobo, 400000);
    });

    test('selectCategory updates category and activates relevant handling options', () {
      notifier.selectCategory(ParcelCategoryDto.food);
      expect(notifier.state.selectedCategory.code, 'FOOD');
      final perishableOpt = notifier.state.handlingOptions
          .firstWhere((opt) => opt.code == 'PERISHABLE');
      expect(perishableOpt.isEnabled, isTrue);
    });

    test('setWeight adjusts weight and auto-upgrades size band', () {
      notifier.setWeight(3.0);
      expect(notifier.state.weightKg, 3.0);
      expect(notifier.state.selectedSizeBand.code, 'MEDIUM');

      notifier.setWeight(6.0);
      expect(notifier.state.weightKg, 6.0);
      expect(notifier.state.selectedSizeBand.code, 'LARGE');
    });

    test('selectSizeBand updates size band and recalculates quote', () {
      notifier.selectSizeBand(ParcelSizeBandDto.large);
      expect(notifier.state.selectedSizeBand.code, 'LARGE');
    });

    test('toggleHandlingOption updates surcharge and total quote', () {
      // Initially Fragile is enabled (+20,000 kobo surcharge)
      expect(notifier.state.totalHandlingSurchargeKobo, 20000);

      // Disable fragile
      notifier.toggleHandlingOption('FRAGILE', false);
      expect(notifier.state.totalHandlingSurchargeKobo, 0);
      expect(notifier.state.quote?.handlingFareKobo, 0);
      expect(notifier.state.quote?.totalAmountKobo, 230000); // 200k + 30k = 230k

      // Enable perishable (+10,000 kobo)
      notifier.toggleHandlingOption('PERISHABLE', true);
      expect(notifier.state.totalHandlingSurchargeKobo, 10000);
      expect(notifier.state.quote?.handlingFareKobo, 10000);
      expect(notifier.state.quote?.totalAmountKobo, 240000);
    });

    test('applyPromoCode with DELIVER20 applies 20% discount on base fare', () {
      final success = notifier.applyPromoCode('deliver20');
      expect(success, isTrue);
      expect(notifier.state.appliedPromoCode, 'DELIVER20');
      // 20% of 200,000 base fare = 40,000 kobo discount
      expect(notifier.state.discountKobo, 40000);
      expect(notifier.state.quote?.discountKobo, 40000);
      expect(notifier.state.quote?.totalAmountKobo, 210000); // ₦2,100
    });

    test('invalid promo code is rejected', () {
      final success = notifier.applyPromoCode('INVALID');
      expect(success, isFalse);
      expect(notifier.state.appliedPromoCode, isNull);
    });

    test('removePromoCode removes discount and restores original quote', () {
      notifier.applyPromoCode('DELIVER20');
      expect(notifier.state.quote?.totalAmountKobo, 210000);

      notifier.removePromoCode();
      expect(notifier.state.appliedPromoCode, isNull);
      expect(notifier.state.discountKobo, 0);
      expect(notifier.state.quote?.totalAmountKobo, 250000);
    });
  });

  group('Screen 2: ParcelDeliveryTypeScreen Widget Tests', () {
    testWidgets('renders all delivery types, value propositions and continue button',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: ParcelDeliveryTypeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Header and title
      expect(find.text('Send a Parcel'), findsOneWidget);
      expect(find.text('Choose a delivery type'), findsOneWidget);

      // 3 Delivery Option cards
      expect(find.text('Standard Delivery'), findsOneWidget);
      expect(find.text('Delivery within 2 - 4 hours'), findsOneWidget);

      expect(find.text('Express Delivery'), findsOneWidget);
      expect(find.text('Faster delivery within 1 hour'), findsOneWidget);

      expect(find.text('Scheduled Delivery'), findsOneWidget);
      expect(find.text('Choose a date and time'), findsOneWidget);

      // Value proposition items
      expect(find.text('Real-time tracking'), findsOneWidget);
      expect(find.text('Track your parcel live'), findsOneWidget);
      expect(find.text('Safe and reliable'), findsOneWidget);
      expect(find.text('Trusted riders'), findsOneWidget);
      expect(find.text('Affordable rates'), findsOneWidget);
      expect(find.text('Transparent pricing'), findsOneWidget);

      // Sticky button
      expect(find.text('Continue'), findsOneWidget);

      // Tap on Express Delivery
      await tester.tap(find.text('Express Delivery'));
      await tester.pumpAndSettle();

      final state = container.read(parcelBookingNotifierProvider);
      expect(state.selectedDeliveryOption.code, 'EXPRESS');
    });
  });

  group('Screen 3: PackageDetailsScreen Widget Tests', () {
    testWidgets('renders category grid, weight stepper, size band, and handling toggles',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: PackageDetailsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Title & Illustration
      expect(find.text('Package details'), findsOneWidget);
      expect(find.byIcon(Icons.inventory_2_rounded), findsWidgets);

      // Categories
      expect(find.text('Package category'), findsOneWidget);
      expect(find.text('Documents'), findsOneWidget);
      expect(find.text('Electronics'), findsOneWidget);
      expect(find.text('Clothing'), findsOneWidget);
      expect(find.text('Food'), findsOneWidget);
      expect(find.text('Fragile'), findsOneWidget);
      expect(find.text('Other'), findsOneWidget);

      // Weight stepper
      expect(find.text('Weight (approx.)'), findsOneWidget);
      expect(find.text('1.5 kg'), findsOneWidget);

      // Package size dropdown
      expect(find.text('Package size (approx.)'), findsOneWidget);
      expect(find.text('Small (Up to 2 kg)'), findsOneWidget);

      // Special handling toggles
      expect(find.text('Special handling (optional)'), findsOneWidget);
      expect(find.text('Fragile (Handle with care)'), findsOneWidget);
      expect(find.text('Keep upright'), findsOneWidget);
      expect(find.text('Perishable (e.g. food)'), findsOneWidget);

      // Sticky button
      expect(find.text('Continue'), findsOneWidget);

      // Test tapping a category
      await tester.tap(find.text('Electronics'));
      await tester.pumpAndSettle();
      expect(
        container.read(parcelBookingNotifierProvider).selectedCategory.code,
        'ELECTRONICS',
      );

      // Test stepping weight
      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();
      expect(find.text('2.0 kg'), findsOneWidget);
      expect(container.read(parcelBookingNotifierProvider).weightKg, 2.0);
    });
  });
}
