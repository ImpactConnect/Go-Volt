import 'package:admin_web/src/features/bookings/application/booking_management_notifier.dart';
import 'package:admin_web/src/features/bookings/presentation/booking_management_screen.dart';
import 'package:admin_web/src/features/operations/application/operations_notifier.dart';
import 'package:admin_web/src/features/operations/presentation/operations_dashboard_screen.dart';
import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Live Operations Module Tests', () {
    test('OperationsNotifier calculates KPIs and handles manual reassignment override', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final state = container.read(operationsNotifierProvider);
      final notifier = container.read(operationsNotifierProvider.notifier);

      expect(state.onlineRiders.length, greaterThanOrEqualTo(3));
      expect(state.urgentJobs.isNotEmpty, isTrue);

      final targetJob = state.urgentJobs.first;
      const newRiderId = 'RDR-001';
      const reason = 'Assigned nearest high-battery moped for urgent parcel delivery';

      // Perform manual assignment
      await notifier.assignRiderToJob(
        bookingId: targetJob.bookingId,
        riderId: newRiderId,
        reason: reason,
      );

      final updatedState = container.read(operationsNotifierProvider);
      expect(updatedState.urgentJobs.any((j) => j.bookingId == targetJob.bookingId), isFalse);
      expect(updatedState.lastActionMessage, contains(targetJob.bookingId));
      expect(updatedState.lastActionMessage, contains(newRiderId));
    });

    testWidgets('OperationsDashboardScreen displays KPIs and urgent queue', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: GVTheme.darkTheme,
            home: const Scaffold(
              body: OperationsDashboardScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Live Fleet Operations'), findsOneWidget);
      expect(find.text('ONLINE FLEET'), findsOneWidget);
      expect(find.text('UNASSIGNED QUEUE'), findsOneWidget);
      expect(find.text('Online Fleet Telemetry'), findsOneWidget);
      expect(find.text('Urgent Dispatch Queue'), findsOneWidget);
    });
  });

  group('Booking Management Module Tests', () {
    test('BookingManagementNotifier filters bookings by service, status and query', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(bookingManagementNotifierProvider.notifier);

      // Initially shows all bookings
      expect(container.read(bookingManagementNotifierProvider).filteredBookings.length, equals(4));

      // Filter by School-Run service type
      notifier.setServiceFilter('School Run');
      expect(container.read(bookingManagementNotifierProvider).filteredBookings.every(
            (b) => b.serviceType == ServiceTierEligibility.schoolRunCommute,
          ), isTrue);

      // Filter by Express Parcel
      notifier.setServiceFilter('Parcel Delivery');
      expect(container.read(bookingManagementNotifierProvider).filteredBookings.every(
            (b) => b.serviceType == ServiceTierEligibility.parcelDelivery,
          ), isTrue);

      // Reset service filter, search by reference
      notifier.setServiceFilter('All');
      notifier.setSearchQuery('GV-BK-2026-002');
      expect(container.read(bookingManagementNotifierProvider).filteredBookings.length, equals(1));
      expect(container.read(bookingManagementNotifierProvider).filteredBookings.first.reference, equals('GV-BK-2026-002'));

      // Cancel booking with refund
      await notifier.cancelBooking(
        bookingId: 'BK-001',
        reason: 'Heavy torrential flooding in Victoria Island',
        refundCustomer: true,
      );
      final cancelled = container.read(bookingManagementNotifierProvider).bookings.firstWhere((b) => b.id == 'BK-001');
      expect(cancelled.timeline.any((e) => e.status == 'CANCELLED' && e.note.contains('flooding')), isTrue);
    });

    testWidgets('BookingManagementScreen displays booking list and filter controls', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: GVTheme.darkTheme,
            home: const Scaffold(
              body: BookingManagementScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Booking & Trip Management'), findsOneWidget);
      expect(find.text('All Service Types'), findsOneWidget);
      expect(find.byKey(const Key('booking_search_field')), findsOneWidget);
    });
  });
}
