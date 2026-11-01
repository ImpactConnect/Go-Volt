import 'package:customer_app/src/features/activity/application/activity_notifier.dart';
import 'package:customer_app/src/features/activity/domain/activity_item.dart';
import 'package:customer_app/src/features/activity/presentation/activity_hub_screen.dart';
import 'package:customer_app/src/features/activity/presentation/widgets/cancellation_details_bottom_sheet.dart';
import 'package:customer_app/src/features/activity/presentation/widgets/digital_receipt_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Unified Activity Hub Unit Tests (Master Tech Spec §1.5 & Screen H07)', () {
    late ActivityNotifier notifier;

    setUp(() {
      notifier = ActivityNotifier();
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
        const ProviderScope(
          child: MaterialApp(
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
        const ProviderScope(
          child: MaterialApp(
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
        const ProviderScope(
          child: MaterialApp(
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
