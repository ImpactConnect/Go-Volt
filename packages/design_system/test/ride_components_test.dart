import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  Widget buildTestable(Widget child, {ThemeData? theme}) {
    return MaterialApp(
      theme: theme ?? GVTheme.light,
      home: Scaffold(body: SingleChildScrollView(child: child)),
    );
  }

  group('Ride Flow Design System Components (Step 2)', () {
    testWidgets('GVRideCategoryCard renders all dynamic props and reacts to taps',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool tapped = false;

      await tester.pumpWidget(
        buildTestable(
          GVRideCategoryCard(
            name: 'GoRide Standard',
            priceLabel: '₦2,800',
            etaLabel: '2 min away',
            description: 'Affordable and reliable',
            isSelected: true,
            features: const [
              GVRideFeatureBadge(label: 'AC', icon: Icons.ac_unit),
              GVRideFeatureBadge(label: '3 Seats', icon: Icons.event_seat),
            ],
            onTap: () => tapped = true,
          ),
        ),
      );

      expect(find.text('GoRide Standard'), findsOneWidget);
      expect(find.text('₦2,800'), findsOneWidget);
      expect(find.text('2 min away'), findsOneWidget);
      expect(find.text('Affordable and reliable'), findsOneWidget);
      expect(find.text('AC'), findsOneWidget);
      expect(find.text('3 Seats'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);

      await tester.tap(find.text('GoRide Standard'));
      await tester.pump();
      expect(tapped, isTrue);
    });

    testWidgets('GVFareBreakdownCard renders itemized lines, notice and promo logic',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      String? appliedPromo;
      bool removedPromo = false;
      final promoController = TextEditingController();

      await tester.pumpWidget(
        buildTestable(
          GVFareBreakdownCard(
            items: const [
              GVFareItem(label: 'Base fare', amountLabel: '₦1,500'),
              GVFareItem(label: 'Distance (8.4 km)', amountLabel: '₦1,100'),
              GVFareItem(label: 'Time (12 min)', amountLabel: '₦300'),
              GVFareItem(label: 'Service fee', amountLabel: '₦200'),
            ],
            totalLabel: '₦3,200',
            rangeLabel: '(₦2,800 - ₦3,500)',
            promoController: promoController,
            onApplyPromo: (code) => appliedPromo = code,
            onRemovePromo: () => removedPromo = true,
          ),
        ),
      );

      expect(find.text('Fare breakdown'), findsOneWidget);
      expect(find.text('Base fare'), findsOneWidget);
      expect(find.text('₦1,500'), findsOneWidget);
      expect(find.text('Distance (8.4 km)'), findsOneWidget);
      expect(find.text('₦1,100'), findsOneWidget);
      expect(find.text('Estimated fare'), findsOneWidget);
      expect(find.text('₦3,200'), findsOneWidget);
      expect(find.text('(₦2,800 - ₦3,500)'), findsOneWidget);
      expect(find.textContaining('Final fare may vary slightly'), findsOneWidget);

      // Enter promo and tap Apply
      await tester.enterText(find.byType(TextField), 'GO20');
      await tester.tap(find.text('Apply'));
      await tester.pump();
      expect(appliedPromo, equals('GO20'));

      // Test applied promo chip
      await tester.pumpWidget(
        buildTestable(
          GVFareBreakdownCard(
            items: const [],
            totalLabel: '₦2,900',
            promoCode: 'GO20',
            promoDiscountLabel: '-₦300',
            onApplyPromo: (code) {},
            onRemovePromo: () => removedPromo = true,
          ),
        ),
      );

      expect(find.text('GO20'), findsOneWidget);
      expect(find.text('(-₦300 applied)'), findsOneWidget);
      await tester.tap(find.byTooltip('Remove promo'));
      await tester.pump();
      expect(removedPromo, isTrue);
    });

    testWidgets('GVPaymentMethodTile renders method details and handles selection',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool tileTapped = false;

      await tester.pumpWidget(
        buildTestable(
          GVPaymentMethodTile(
            title: 'Go-Volts Wallet',
            subtitle: 'Balance: ₦5,200.00',
            icon: const Icon(Icons.wallet),
            isSelected: true,
            onTap: () => tileTapped = true,
          ),
        ),
      );

      expect(find.text('Go-Volts Wallet'), findsOneWidget);
      expect(find.text('Balance: ₦5,200.00'), findsOneWidget);
      expect(find.byIcon(Icons.check), findsOneWidget);

      await tester.tap(find.text('Go-Volts Wallet'));
      await tester.pump();
      expect(tileTapped, isTrue);
    });

    testWidgets('GVRadarMatchingView displays 4-step checklist and triggers cancel',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool cancelled = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: GVTheme.light,
          home: Scaffold(
            body: GVRadarMatchingView(
              currentStep: 2,
              onCancel: () => cancelled = true,
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Finding a rider for you...'), findsOneWidget);
      expect(find.text('Sending your request'), findsOneWidget);
      expect(find.text('Looking for nearby riders'), findsOneWidget);
      expect(find.text('Confirming rider'), findsOneWidget);
      expect(find.text('Finalizing your ride'), findsOneWidget);
      expect(find.textContaining('notified as soon as a rider accepts'), findsOneWidget);

      await tester.tap(find.text('Cancel ride'));
      await tester.pump(const Duration(milliseconds: 50));
      expect(cancelled, isTrue);
    });

    testWidgets('GVRiderInfoCard renders full driver info, actions and vehicle banner',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool called = false;
      bool messaged = false;
      bool shared = false;
      bool safetyTapped = false;

      await tester.pumpWidget(
        buildTestable(
          GVRiderInfoCard(
            riderName: 'Daniel Okafor',
            vehicleModel: 'Toyota Corolla',
            vehicleColor: 'Black',
            plateNumber: 'KJA 123 AB',
            rating: 4.8,
            tripCount: 320,
            etaMinutes: 6,
            vehicleBannerText:
                'Look for a black Toyota Corolla with plate number KJA 123 AB',
            onCall: () => called = true,
            onMessage: () => messaged = true,
            onShareTrip: () => shared = true,
            onSafety: () => safetyTapped = true,
          ),
        ),
      );

      expect(find.text('Daniel Okafor'), findsOneWidget);
      expect(find.text('4.8'), findsOneWidget);
      expect(find.text('(320 trips)'), findsOneWidget);
      expect(find.text('Toyota Corolla • Black • KJA 123 AB'), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (w) => w is RichText && w.text.toPlainText().contains('6 min'),
        ),
        findsOneWidget,
      );
      expect(find.textContaining('Look for a black Toyota Corolla'), findsOneWidget);

      await tester.tap(find.byTooltip('Call driver'));
      await tester.pump();
      expect(called, isTrue);

      await tester.tap(find.byTooltip('Message driver'));
      await tester.pump();
      expect(messaged, isTrue);

      await tester.tap(find.text('Share trip'));
      await tester.pump();
      expect(shared, isTrue);

      await tester.tap(find.text('Safety'));
      await tester.pump();
      expect(safetyTapped, isTrue);
    });

    testWidgets('GVTripProgressTimeline renders both horizontal and vertical steps',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      // Horizontal mode
      await tester.pumpWidget(
        buildTestable(
          const GVTripProgressTimeline(
            axis: Axis.horizontal,
            steps: [
              GVTripProgressStep(label: 'Driver on the way', isCompleted: true),
              GVTripProgressStep(label: 'Arriving soon', isActive: true),
              GVTripProgressStep(label: 'Arrived'),
            ],
          ),
        ),
      );

      expect(find.text('Driver on the way'), findsOneWidget);
      expect(find.text('Arriving soon'), findsOneWidget);
      expect(find.text('Arrived'), findsOneWidget);

      // Vertical mode with timestamps
      await tester.pumpWidget(
        buildTestable(
          const GVTripProgressTimeline(
            axis: Axis.vertical,
            steps: [
              GVTripProgressStep(
                label: 'Picked up',
                timeLabel: '10:05 AM',
                isCompleted: true,
              ),
              GVTripProgressStep(label: 'On trip', isActive: true),
              GVTripProgressStep(
                label: 'Arriving at destination',
                timeLabel: '10:17 AM',
              ),
            ],
          ),
        ),
      );

      expect(find.text('Picked up'), findsOneWidget);
      expect(find.text('10:05 AM'), findsOneWidget);
      expect(find.text('On trip'), findsOneWidget);
      expect(find.text('Arriving at destination'), findsOneWidget);
      expect(find.text('10:17 AM'), findsOneWidget);
    });

    testWidgets('GVTripReceiptCard renders complete itemized digital receipt',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool downloaded = false;
      bool shared = false;
      bool reported = false;

      await tester.pumpWidget(
        buildTestable(
          GVTripReceiptCard(
            tripReference: 'TRP123456789',
            formattedDate: 'Oct 29, 2026, 10:17 AM',
            driverName: 'Daniel Okafor',
            driverVehicle: 'Toyota Corolla • Black KJA 123 AB',
            driverRating: 4.8,
            driverTrips: 320,
            pickupAddress: 'Eko Hotel and Suites, Victoria Island, Lagos',
            pickupTime: '10:05 AM',
            destinationAddress: 'Palms Mall, Lekki, Lagos',
            destinationTime: '10:17 AM',
            fareItems: const [
              GVFareItem(label: 'Base fare', amountLabel: '₦1,500'),
              GVFareItem(label: 'Distance (8.4 km)', amountLabel: '₦1,100'),
              GVFareItem(label: 'Time (12 min)', amountLabel: '₦300'),
              GVFareItem(label: 'Service fee', amountLabel: '₦200'),
              GVFareItem(label: 'Subtotal', amountLabel: '₦3,100', isBold: true),
              GVFareItem(label: 'Promo discount', amountLabel: '-₦300', isDiscount: true),
            ],
            totalPaidLabel: '₦3,200',
            paymentMethodName: 'Go-Volts Wallet',
            paymentMethodAmount: '₦3,200',
            onDownloadReceipt: () => downloaded = true,
            onShareReceipt: () => shared = true,
            onReportIssue: () => reported = true,
          ),
        ),
      );

      expect(find.text('GO-VOLTS'), findsOneWidget);
      expect(find.textContaining('TRP123456789'), findsOneWidget);
      expect(find.text('Daniel Okafor'), findsOneWidget);
      expect(find.text('Total paid'), findsOneWidget);
      expect(find.text('₦3,200'), findsNWidgets(2)); // Total and payment method
      expect(find.text('Download receipt'), findsOneWidget);

      await tester.tap(find.text('Download receipt'));
      await tester.pump();
      expect(downloaded, isTrue);

      await tester.tap(find.text('Share receipt'));
      await tester.pump();
      expect(shared, isTrue);

      await tester.tap(find.text('Report an issue'));
      await tester.pump();
      expect(reported, isTrue);
    });

    testWidgets('GVTripRatingCard handles star selection, tag toggling and submission',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      int? submittedRating;
      List<String>? submittedTags;
      String? submittedComment;
      bool? submittedWouldRideAgain;

      await tester.pumpWidget(
        buildTestable(
          GVTripRatingCard(
            driverName: 'Daniel Okafor',
            driverVehicle: 'Toyota Corolla • KJA 123 AB',
            initialRating: 4,
            onSubmit: ({
              required int rating,
              required List<String> tags,
              required String comment,
              required bool wouldRideAgain,
            }) {
              submittedRating = rating;
              submittedTags = tags;
              submittedComment = comment;
              submittedWouldRideAgain = wouldRideAgain;
            },
          ),
        ),
      );

      expect(find.text('Rate your trip'), findsOneWidget);
      expect(find.text('Daniel Okafor'), findsOneWidget);
      expect(find.text('Great driver'), findsOneWidget);

      // Select 5th star
      await tester.tap(find.byIcon(Icons.star_outline_rounded));
      await tester.pump();

      // Toggle compliment chip
      await tester.tap(find.text('Great driver'));
      await tester.pump();

      // Type comment
      await tester.enterText(find.byType(TextField), 'Exceptional smooth ride!');
      await tester.pump();

      // Submit
      await tester.tap(find.text('Submit'));
      await tester.pump();

      expect(submittedRating, equals(5));
      expect(submittedTags, contains('Great driver'));
      expect(submittedComment, equals('Exceptional smooth ride!'));
      expect(submittedWouldRideAgain, isTrue);
    });

    testWidgets('GVTripOverviewCard and GVTripCompletionCard render correctly',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      bool changed = false;
      bool viewedReceipt = false;

      await tester.pumpWidget(
        buildTestable(
          Column(
            children: [
              GVTripOverviewCard(
                pickupAddress: 'Eko Hotel and Suites',
                destinationAddress: 'Palms Mall',
                distanceLabel: '8.4 km',
                durationLabel: '12 min',
                onChange: () => changed = true,
              ),
              GVTripCompletionCard(
                totalFareLabel: '₦3,200',
                promoSavingsLabel: 'You saved ₦300 with promo',
                driverName: 'Daniel Okafor',
                driverVehicle: 'Toyota Corolla • Black KJA 123 AB',
                pickupAddress: 'Eko Hotel and Suites',
                pickupTime: '10:05 AM',
                destinationAddress: 'Palms Mall',
                destinationTime: '10:17 AM',
                distanceLabel: '8.4 km',
                durationLabel: '12 min',
                rideTypeName: 'GoRide Standard',
                onViewReceipt: () => viewedReceipt = true,
              ),
            ],
          ),
        ),
      );

      expect(find.text('Trip overview'), findsOneWidget);
      expect(find.text('Trip completed!'), findsOneWidget);
      expect(find.text('You saved ₦300 with promo'), findsOneWidget);

      await tester.tap(find.text('Change'));
      await tester.pump();
      expect(changed, isTrue);

      await tester.tap(find.text('View receipt'));
      await tester.pump();
      expect(viewedReceipt, isTrue);
    });
  });
}
