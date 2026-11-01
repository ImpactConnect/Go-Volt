import 'package:app_models/app_models.dart';
import 'package:customer_app/src/features/activity/application/activity_notifier.dart';
import 'package:customer_app/src/features/activity/domain/activity_item.dart';
import 'package:customer_app/src/features/activity/presentation/activity_hub_screen.dart';
import 'package:customer_app/src/features/activity/presentation/widgets/cancellation_details_bottom_sheet.dart';
import 'package:customer_app/src/features/activity/presentation/widgets/digital_receipt_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

List<ActivityItem> _buildTestActivities() {
  final now = DateTime.now();
  return [
    // 1. ACTIVE: Ride
    ActivityItem(
      id: 'act-act-001',
      reference: 'GV-TRP-20261031-01',
      serviceType: ActivityServiceType.ride,
      status: ActivityStatus.active,
      title: 'GoRide Standard: Babcock University',
      pickupAddress: 'Central Roundabout, Shaganu, Ogun',
      dropoffAddress: 'Babcock University, Ilishan-Remo, Ogun',
      timestamp: now.subtract(const Duration(minutes: 8)),
      fareKobo: 250000,
      driverName: 'Ahmed Ibrahim',
      driverRating: 4.8,
      driverTripsCount: 320,
      vehicleModel: 'Toyota Corolla - OGN-123XY',
      vehiclePlate: 'OGN-123XY',
    ),
    // 2. ACTIVE: Parcel Delivery
    ActivityItem(
      id: 'act-act-002',
      reference: 'GV-DEL-20261031-44',
      serviceType: ActivityServiceType.delivery,
      status: ActivityStatus.active,
      title: 'Parcel Delivery: Confidential Documents',
      pickupAddress: 'Remo High Street, Shaganu, Ogun',
      dropoffAddress: 'Shaganu Community Market, Ogun',
      timestamp: now.subtract(const Duration(minutes: 20)),
      fareKobo: 120000,
      driverName: 'Musa Bello',
      driverRating: 4.7,
      driverTripsCount: 198,
      vehicleModel: 'Go-Volts Electric Bike - OGN-456YZ',
      vehiclePlate: 'OGN-456YZ',
      recipientName: 'Fatima Abdullahi',
      recipientPhone: '+234 803 123 4567',
    ),
    // 3. UPCOMING: School Run Scheduled Plan
    ActivityItem(
      id: 'act-up-001',
      reference: 'SP-20261105-001',
      serviceType: ActivityServiceType.scheduled,
      status: ActivityStatus.upcoming,
      title: 'School Run: Remo International School',
      pickupAddress: 'Central Roundabout, Shaganu, Ogun',
      dropoffAddress: 'Remo International School, Ilishan-Remo, Ogun',
      timestamp: now.add(const Duration(days: 1, hours: 2)),
      fareKobo: 250000,
      driverName: 'Ahmed Ibrahim',
      driverRating: 4.8,
      driverTripsCount: 320,
      vehicleModel: 'Toyota Corolla - OGN-123XY',
      schoolPassengerName: 'Fatima Okafor (JSS 1)',
    ),
    // 4. UPCOMING: Work Commute Scheduled Plan
    ActivityItem(
      id: 'act-up-002',
      reference: 'SP-20261105-002',
      serviceType: ActivityServiceType.scheduled,
      status: ActivityStatus.upcoming,
      title: 'Work Commute: Shaganu Energy Hub',
      pickupAddress: 'Remo High Street, Shaganu, Ogun',
      dropoffAddress: 'Shaganu Energy Hub, Ogun',
      timestamp: now.add(const Duration(days: 2, hours: 1)),
      fareKobo: 300000,
      driverName: 'Grace Johnson',
      driverRating: 4.9,
      driverTripsCount: 450,
      vehicleModel: 'Nissan Leaf Electric - OGN-901EF',
    ),
    // 5. UPCOMING: Scheduled Parcel Dispatch
    ActivityItem(
      id: 'act-up-003',
      reference: 'GV-DEL-20261101-12',
      serviceType: ActivityServiceType.delivery,
      status: ActivityStatus.upcoming,
      title: 'Scheduled Delivery: Medical Supplies',
      pickupAddress: 'Remo Specialist Hospital, Ogun',
      dropoffAddress: 'Shaganu General Hospital, Ogun',
      timestamp: now.add(const Duration(days: 1, hours: 5)),
      fareKobo: 280000,
      recipientName: 'Dr. Aliyu Shehu',
      recipientPhone: '+234 802 998 7766',
    ),
    // 6. COMPLETED: Ride
    ActivityItem(
      id: 'act-comp-001',
      reference: 'GV-TRP-20261029-88',
      serviceType: ActivityServiceType.ride,
      status: ActivityStatus.completed,
      title: 'GoRide Plus to Remo High Street',
      pickupAddress: 'Central Roundabout, Shaganu, Ogun',
      dropoffAddress: 'Remo High Street, Shaganu, Ogun',
      timestamp: now.subtract(const Duration(days: 2, hours: 3)),
      fareKobo: 350000,
      driverName: 'Grace Johnson',
      driverRating: 4.9,
      driverTripsCount: 450,
      vehicleModel: 'Nissan Leaf Electric',
      vehiclePlate: 'OGN-901EF',
      receipt: TripReceiptDto(
        receiptReference: 'RCP-20261029-88',
        bookingId: 'GV-TRP-20261029-88',
        serviceType: 'GoRide Plus',
        driverName: 'Grace Johnson',
        driverRating: 4.9,
        driverTripsCount: 450,
        vehicleModel: 'Nissan Leaf Electric',
        vehiclePlate: 'OGN-901EF',
        pickupAddress: 'Central Roundabout, Shaganu, Ogun',
        pickupTime: now.subtract(const Duration(days: 2, hours: 3, minutes: 22)),
        dropoffAddress: 'Remo High Street, Shaganu, Ogun',
        dropoffTime: now.subtract(const Duration(days: 2, hours: 3)),
        distanceKm: 8.4,
        durationMinutes: 22,
        priceBreakdown: const PriceBreakdownDto(
          baseAmountKobo: 200000,
          distanceAmountKobo: 120000,
          timeAmountKobo: 0,
          serviceFeeKobo: 30000,
          totalAmountKobo: 350000,
        ),
        totalPaidKobo: 350000,
        paymentMethod: PaymentMethod.wallet,
        paymentReference: 'PAY-WALLET-8819',
        carbonSavedGrams: 1450,
      ),
    ),
    // 7. COMPLETED: Parcel Delivery
    ActivityItem(
      id: 'act-comp-002',
      reference: 'GV-DEL-20261028-19',
      serviceType: ActivityServiceType.delivery,
      status: ActivityStatus.completed,
      title: 'Parcel Delivery: Electronics & Accessories',
      pickupAddress: 'Remo Tech Hub, Shaganu, Ogun',
      dropoffAddress: 'GRA Phase 1, Shaganu, Ogun',
      timestamp: now.subtract(const Duration(days: 3, hours: 4)),
      fareKobo: 220000,
      driverName: 'Musa Bello',
      driverRating: 4.7,
      driverTripsCount: 198,
      vehicleModel: 'Go-Volts Electric Bike',
      vehiclePlate: 'OGN-456YZ',
      recipientName: 'Kalu Chukwu',
      receipt: TripReceiptDto(
        receiptReference: 'RCP-20261028-19',
        bookingId: 'GV-DEL-20261028-19',
        serviceType: 'Go-Volts Send Express',
        driverName: 'Musa Bello',
        driverRating: 4.7,
        driverTripsCount: 198,
        vehicleModel: 'Go-Volts Electric Bike',
        vehiclePlate: 'OGN-456YZ',
        pickupAddress: 'Remo Tech Hub, Shaganu, Ogun',
        pickupTime: now.subtract(const Duration(days: 3, hours: 4, minutes: 18)),
        dropoffAddress: 'GRA Phase 1, Shaganu, Ogun',
        dropoffTime: now.subtract(const Duration(days: 3, hours: 4)),
        distanceKm: 5.2,
        durationMinutes: 18,
        priceBreakdown: const PriceBreakdownDto(
          baseAmountKobo: 150000,
          distanceAmountKobo: 50000,
          timeAmountKobo: 0,
          serviceFeeKobo: 20000,
          totalAmountKobo: 220000,
        ),
        totalPaidKobo: 220000,
        paymentMethod: PaymentMethod.wallet,
        paymentReference: 'PAY-WALLET-7712',
        carbonSavedGrams: 890,
      ),
    ),
    // 8. COMPLETED: Scheduled Trip
    ActivityItem(
      id: 'act-comp-003',
      reference: 'SP-20261027-005',
      serviceType: ActivityServiceType.scheduled,
      status: ActivityStatus.completed,
      title: 'School Run: Remo International School',
      pickupAddress: 'Central Roundabout, Shaganu, Ogun',
      dropoffAddress: 'Remo International School, Ilishan-Remo, Ogun',
      timestamp: now.subtract(const Duration(days: 4, hours: 8)),
      fareKobo: 250000,
      driverName: 'Ahmed Ibrahim',
      driverRating: 4.8,
      driverTripsCount: 320,
      vehicleModel: 'Toyota Corolla - OGN-123XY',
      schoolPassengerName: 'Fatima Okafor (JSS 1)',
      receipt: TripReceiptDto(
        receiptReference: 'RCP-20261027-005',
        bookingId: 'SP-20261027-005',
        serviceType: 'School Run Package',
        driverName: 'Ahmed Ibrahim',
        driverRating: 4.8,
        driverTripsCount: 320,
        vehicleModel: 'Toyota Corolla',
        vehiclePlate: 'OGN-123XY',
        pickupAddress: 'Central Roundabout, Shaganu, Ogun',
        pickupTime: now.subtract(const Duration(days: 4, hours: 8, minutes: 25)),
        dropoffAddress: 'Remo International School, Ilishan-Remo, Ogun',
        dropoffTime: now.subtract(const Duration(days: 4, hours: 8)),
        distanceKm: 7.1,
        durationMinutes: 25,
        priceBreakdown: const PriceBreakdownDto(
          baseAmountKobo: 200000,
          distanceAmountKobo: 40000,
          timeAmountKobo: 0,
          serviceFeeKobo: 10000,
          totalAmountKobo: 250000,
        ),
        totalPaidKobo: 250000,
        paymentMethod: PaymentMethod.wallet,
        paymentReference: 'PAY-SCHED-5521',
        carbonSavedGrams: 1100,
      ),
    ),
    // 9. CANCELLED: Ride
    ActivityItem(
      id: 'act-canc-001',
      reference: 'GV-TRP-20261024-91',
      serviceType: ActivityServiceType.ride,
      status: ActivityStatus.cancelled,
      title: 'GoRide Comfort: Ogun Cargo Airport Commute',
      pickupAddress: 'Remo High Street, Shaganu, Ogun',
      dropoffAddress: 'Gateway International Airport, Ogun',
      timestamp: now.subtract(const Duration(days: 7)),
      fareKobo: 650000,
      cancellationReason:
          'Flight rescheduled by airline. Cancelled by rider before dispatch.',
      refundStatus: 'Full refund ₦6,500 automatically credited to Go-Volts Wallet',
    ),
    // 10. CANCELLED: Parcel Delivery
    ActivityItem(
      id: 'act-canc-002',
      reference: 'GV-DEL-20261022-30',
      serviceType: ActivityServiceType.delivery,
      status: ActivityStatus.cancelled,
      title: 'Parcel Delivery: Bulk Box Goods',
      pickupAddress: 'Shaganu Central Market, Ogun',
      dropoffAddress: 'Iperu Modern Market, Ogun',
      timestamp: now.subtract(const Duration(days: 9)),
      fareKobo: 200000,
      cancellationReason:
          'Sender unavailable at pickup point after driver arrival grace period.',
      refundStatus: 'Partial refund ₦1,500 credited to Wallet (₦500 rider dispatch fee retained)',
    ),
  ];
}

void main() {
  group('Unified Activity Hub Unit Tests (Master Tech Spec §1.5 & Screen H07)', () {
    late ActivityNotifier notifier;

    setUp(() {
      notifier = ActivityNotifier(initialItems: _buildTestActivities());
    });

    test('initializes with seed activities across active, upcoming, completed and cancelled', () {
      final state = notifier.state;
      expect(state.activeCount, 2);
      expect(state.upcomingCount, 3);
      expect(state.completedCount, 3);
      expect(state.cancelledCount, 2);
    });

    test('filters items accurately by status', () {
      notifier.setStatusFilter(ActivityStatus.completed);
      expect(notifier.state.filteredItems.length, 3);
      expect(
        notifier.state.filteredItems.every((i) => i.status == ActivityStatus.completed),
        isTrue,
      );

      notifier.setStatusFilter(ActivityStatus.cancelled);
      expect(notifier.state.filteredItems.length, 2);
      expect(
        notifier.state.filteredItems.every((i) => i.status == ActivityStatus.cancelled),
        isTrue,
      );
    });

    test('filters items accurately by service category', () {
      notifier.setStatusFilter(ActivityStatus.completed);

      // Filter by Ride
      notifier.setServiceFilter(ActivityServiceType.ride);
      expect(notifier.state.filteredItems.length, 1);
      expect(notifier.state.filteredItems.first.serviceType, ActivityServiceType.ride);

      // Filter by Delivery
      notifier.setServiceFilter(ActivityServiceType.delivery);
      expect(notifier.state.filteredItems.length, 1);
      expect(notifier.state.filteredItems.first.serviceType, ActivityServiceType.delivery);

      // Filter by Scheduled
      notifier.setServiceFilter(ActivityServiceType.scheduled);
      expect(notifier.state.filteredItems.length, 1);
      expect(notifier.state.filteredItems.first.serviceType, ActivityServiceType.scheduled);

      // Reset to All
      notifier.setServiceFilter(null);
      expect(notifier.state.filteredItems.length, 3);
    });

    test('filters items dynamically by search query', () {
      notifier.setStatusFilter(ActivityStatus.upcoming);
      notifier.setSearchQuery('Energy Hub');

      expect(notifier.state.filteredItems.length, 1);
      expect(notifier.state.filteredItems.first.title.contains('Energy Hub'), isTrue);

      notifier.setSearchQuery('NonExistentPlace');
      expect(notifier.state.filteredItems.isEmpty, isTrue);
    });
  });

  group('Unified Activity Hub Presentation & Widget Tests', () {
    testWidgets('ActivityHubScreen renders header, category pills, status tabs and card items',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 900));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activityNotifierProvider.overrideWith(
              (ref) => ActivityNotifier(initialItems: _buildTestActivities()),
            ),
          ],
          child: const MaterialApp(
            home: ActivityHubScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify Header & Service Filter Pills
      expect(find.text('Activity'), findsOneWidget);
      expect(find.text('All Services'), findsOneWidget);
      expect(find.text('Rides'), findsOneWidget);
      expect(find.text('Deliveries'), findsOneWidget);
      expect(find.text('Scheduled'), findsOneWidget);

      // Verify Status tabs
      expect(find.textContaining('Upcoming (3)'), findsOneWidget);
      expect(find.textContaining('Active (2)'), findsOneWidget);
      expect(find.textContaining('Completed (3)'), findsOneWidget);
      expect(find.textContaining('Cancelled (2)'), findsOneWidget);

      // Verify Default tab (Upcoming) items
      expect(find.textContaining('School Run: Remo International School'), findsOneWidget);
      expect(find.textContaining('Work Commute: Shaganu Energy Hub'), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Switches to Completed tab and opens DigitalReceiptBottomSheet',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 900));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activityNotifierProvider.overrideWith(
              (ref) => ActivityNotifier(initialItems: _buildTestActivities()),
            ),
          ],
          child: const MaterialApp(
            home: ActivityHubScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap "Completed (3)"
      await tester.tap(find.textContaining('Completed (3)'));
      await tester.pumpAndSettle();

      // Verify completed cards
      expect(find.textContaining('GoRide Plus to Remo High Street'), findsOneWidget);
      expect(find.textContaining('Electronics & Accessories'), findsOneWidget);

      // Tap "Receipt" on the first completed trip
      final receiptButtons = find.widgetWithText(ElevatedButton, 'Receipt');
      expect(receiptButtons, findsWidgets);
      await tester.tap(receiptButtons.first);
      await tester.pumpAndSettle();

      // Verify Digital Receipt Bottom Sheet opens
      expect(find.byType(DigitalReceiptBottomSheet), findsOneWidget);
      expect(find.text('Digital Receipt'), findsOneWidget);
      expect(find.text('Base Fare'), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('Switches to Cancelled tab and opens CancellationDetailsBottomSheet',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 900));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activityNotifierProvider.overrideWith(
              (ref) => ActivityNotifier(initialItems: _buildTestActivities()),
            ),
          ],
          child: const MaterialApp(
            home: ActivityHubScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Tap "Cancelled (2)"
      await tester.tap(find.textContaining('Cancelled (2)'));
      await tester.pumpAndSettle();

      // Verify cancelled cards
      expect(find.textContaining('GoRide Comfort: Ogun Cargo Airport Commute'), findsOneWidget);

      // Tap "Refund Details"
      final refundButtons = find.widgetWithText(ElevatedButton, 'Refund Details');
      expect(refundButtons, findsWidgets);
      await tester.tap(refundButtons.first);
      await tester.pumpAndSettle();

      // Verify Cancellation Details Bottom Sheet opens
      expect(find.byType(CancellationDetailsBottomSheet), findsOneWidget);
      expect(find.text('Trip Cancellation Details'), findsOneWidget);
      expect(find.text('Reason for Cancellation'), findsOneWidget);
      expect(find.text('Refund & Credit Status'), findsOneWidget);
      expect(find.textContaining('Full refund ₦6,500 automatically credited'), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });
  });
}
