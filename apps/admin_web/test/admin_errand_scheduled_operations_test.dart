import 'helpers/test_seeds.dart';
import 'package:admin_web/src/core/auth/admin_auth_notifier.dart';
import 'package:admin_web/src/core/auth/admin_role.dart';
import 'package:admin_web/src/features/errands/application/errand_operations_notifier.dart';
import 'package:admin_web/src/features/errands/presentation/errand_operations_screen.dart';
import 'package:admin_web/src/features/errands/presentation/widgets/errand_detail_modal.dart';
import 'package:admin_web/src/features/errands/presentation/widgets/errand_receipt_dispute_modal.dart';
import 'package:admin_web/src/features/scheduled/application/scheduled_operations_notifier.dart';
import 'package:admin_web/src/features/scheduled/domain/scheduled_operations_models.dart';
import 'package:admin_web/src/features/scheduled/presentation/scheduled_operations_screen.dart';
import 'package:admin_web/src/features/scheduled/presentation/widgets/calendar_exception_modal.dart';
import 'package:admin_web/src/features/scheduled/presentation/widgets/chaperone_reassignment_modal.dart';
import 'package:admin_web/src/features/scheduled/presentation/widgets/handover_verification_modal.dart';
import 'package:app_models/app_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget createTestApp(Widget home, {StaffRole role = StaffRole.admin}) {
  return ProviderScope(
    overrides: [
      adminAuthNotifierProvider.overrideWith((ref) {
        final notifier = AdminAuthNotifier();
        notifier.setRole(role);
        return notifier;
      }),
      errandOperationsNotifierProvider.overrideWith((ref) {
        final notifier = ErrandOperationsNotifier();
        notifier.seedForTest();
        return notifier;
      }),
      scheduledOperationsNotifierProvider.overrideWith((ref) {
        final notifier = ScheduledOperationsNotifier();
        notifier.seedForTest();
        return notifier;
      }),
    ],
    child: MaterialApp(
      home: home,
    ),
  );
}

void main() {
  group('Market Errand Operations Hub Tests (v1.6 §1975-2004)', () {
    test('ErrandOperationsNotifier seeds, searches, filters, reassigns and reconciles', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(errandOperationsNotifierProvider.notifier);
      notifier.seedForTest();
      var state = container.read(errandOperationsNotifierProvider);

      expect(state.totalErrands, equals(5));
      expect(state.activeShoppingCount, equals(3));
      expect(state.pendingReconciliationsCount, equals(3));
      expect(state.disputeCount, equals(1));
      expect(state.completedTodayCount, equals(1));

      // Test Search by Order Ref
      notifier.search('ERR-2026-0019');
      state = container.read(errandOperationsNotifierProvider);
      expect(state.filteredErrands.length, equals(1));
      expect(state.filteredErrands.first.shop?.name, equals('Kakuri Main Market'));

      // Test Search by Customer
      notifier.search('Omotayo');
      state = container.read(errandOperationsNotifierProvider);
      expect(state.filteredErrands.length, equals(2));

      notifier.search('');

      // Test Filter by Errand Type (Flow B: Pickup Package)
      notifier.filterByType(ErrandType.pickupPackage);
      state = container.read(errandOperationsNotifierProvider);
      expect(state.filteredErrands.length, equals(1));
      expect(state.filteredErrands.first.pickupDetails?.pickupBusinessName,
          contains('Jumia'));

      notifier.filterByType(null);

      // Test Filter by Status (completed)
      notifier.filterByStatus(ErrandStatus.completed);
      state = container.read(errandOperationsNotifierProvider);
      expect(state.filteredErrands.length, equals(1));
      expect(state.filteredErrands.first.shop?.name, equals('Murtala Supermarket'));

      notifier.filterByStatus(null);

      // Test Reassign Shopper
      const newShopper = RiderDto(
        id: 'RIDER-004',
        profileId: 'PROF-004',
        fullName: 'Zainab Danjuma',
        phoneNumber: '+2348039871122',
        rating: 4.95,
        status: RiderStatus.online,
        vehiclePlate: 'KD-882-AB',
        vehicleModel: 'Roam Commuter EV',
      );
      final successReassign = await notifier.reassignShopper(
        'ERRAND-001',
        newShopper,
        reason: 'Standby EV replacement for faster market transit',
      );
      expect(successReassign, isTrue);
      state = container.read(errandOperationsNotifierProvider);
      expect(state.errands.firstWhere((e) => e.id == 'ERRAND-001').assignedRider?.fullName,
          equals('Zainab Danjuma'));

      // Test Item Substitution Approval
      final successSub = await notifier.approveItemSubstitution(
        'ERRAND-001',
        'ITEM-03',
        880000,
        approverName: 'Admin Adeola',
      );
      expect(successSub, isTrue);
      state = container.read(errandOperationsNotifierProvider);
      final rice = state.errands
          .firstWhere((e) => e.id == 'ERRAND-001')
          .items
          .firstWhere((i) => i.id == 'ITEM-03');
      expect(rice.isPurchased, isTrue);
      expect(rice.actualPriceKobo, equals(880000));

      // Test Low-Value Reconciliation (<= ₦10,000) Single-Approval Settlement
      final successLowRec = await notifier.approveReconciliation(
        'REC-001',
        staffName: 'Ops Agent Tunde',
        staffRole: StaffRole.opsAgent,
      );
      expect(successLowRec, isTrue);
      state = container.read(errandOperationsNotifierProvider);
      final rec1 = state.reconciliations.firstWhere((r) => r.id == 'REC-001');
      expect(rec1.status, equals('CHECKER_APPROVED'));
      expect(rec1.isApproved, isTrue);

      // Test High-Value Reconciliation (> ₦10,000 / 1,000,000 kobo) Dual Maker-Checker
      // REC-003 is already MAKER_APPROVED, needs Checker with Finance or Admin/SuperAdmin role
      // Unauthorized role attempt fails
      final failCheck = await notifier.approveReconciliation(
        'REC-003',
        staffName: 'Promotions Officer',
        staffRole: StaffRole.promotionsManager,
      );
      expect(failCheck, isFalse);
      state = container.read(errandOperationsNotifierProvider);
      expect(state.actionMessage, contains('requires Finance Officer or Super Admin'));

      // Authorized Finance role succeeds
      final successCheck = await notifier.approveReconciliation(
        'REC-003',
        staffName: 'Finance Officer Hadiza',
        staffRole: StaffRole.finance,
      );
      expect(successCheck, isTrue);
      state = container.read(errandOperationsNotifierProvider);
      final rec3 = state.reconciliations.firstWhere((r) => r.id == 'REC-003');
      expect(rec3.status, equals('CHECKER_APPROVED'));
      expect(rec3.checkerStaffName, equals('Finance Officer Hadiza'));

      // Test Resolve Dispute with Customer Refund
      final successDispute = await notifier.resolveDispute(
        'DISP-001',
        refundCustomer: true,
        refundAmountKobo: 300000,
        resolutionNotes: 'Customer preference honored. Extra charge refunded.',
        staffName: 'Admin Adeola',
      );
      expect(successDispute, isTrue);
      state = container.read(errandOperationsNotifierProvider);
      final disp = state.disputes.firstWhere((d) => d.id == 'DISP-001');
      expect(disp.status, equals('RESOLVED_REFUND'));
      expect(disp.isResolved, isTrue);
    });

    testWidgets('ErrandOperationsScreen renders KPI cards, table, and details modal', (tester) async {
      tester.view.physicalSize = const Size(2400, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(const ErrandOperationsScreen()));
      await tester.pumpAndSettle();

      // Check header and uppercase KPI titles
      expect(find.text('Market Errand Supervision Hub'), findsOneWidget);
      expect(find.text('ACTIVE ERRANDS'), findsOneWidget);
      expect(find.text('PENDING RECONCILIATIONS'), findsOneWidget);
      expect(find.text('SUBSTITUTION DISPUTES'), findsOneWidget);
      expect(find.text('COMPLETED TODAY'), findsOneWidget);

      // Check Quick-Action Audit Desk
      expect(find.text('AUDIT DESK: STORE RECEIPTS & CUSTOMER DISPUTES'), findsOneWidget);
      expect(find.byKey(const Key('reconcile_btn_REC-001')), findsOneWidget);
      expect(find.byKey(const Key('dispute_btn_DISP-001')), findsOneWidget);

      // Check Table Orders
      expect(find.text('ERR-2026-0019'), findsOneWidget);
      expect(find.text('Kakuri Main Market'), findsOneWidget);
      expect(find.text('Flow A: Buy Items'), findsAtLeastNWidgets(1));

      // Inspect First Errand Modal
      await tester.tap(find.byKey(const Key('inspect_errand_ERRAND-001')));
      await tester.pumpAndSettle();

      expect(find.byType(ErrandDetailModal), findsOneWidget);
      expect(find.text('Errand Details — ERR-2026-0019'), findsOneWidget);
      expect(find.text('CUSTOMER & DESTINATION'), findsOneWidget);
      expect(find.text('Tomatoes (2 kg)'), findsOneWidget);
      expect(find.text('Reassign Standby Shopper'), findsOneWidget);

      // Close modal
      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.byType(ErrandDetailModal), findsNothing);

      // Open Dispute Review Modal
      await tester.tap(find.byKey(const Key('dispute_btn_DISP-001')));
      await tester.pumpAndSettle();

      expect(find.byType(ErrandReceiptDisputeModal), findsOneWidget);
      expect(find.text('Dispute Review — ERR-2026-0015'), findsOneWidget);
      expect(find.textContaining('CUSTOMER COMPLAINT'), findsOneWidget);
      expect(find.textContaining('Refund Customer'), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.byType(ErrandReceiptDisputeModal), findsNothing);
    });
  });

  group('Scheduled Commute & School-Run Operations Desk Tests (§21.2 & §21.6)', () {
    test('ScheduledOperationsNotifier seeds, manifests, verifies OTP, and manages exceptions', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(scheduledOperationsNotifierProvider.notifier);
      notifier.seedForTest();
      var state = container.read(scheduledOperationsNotifierProvider);

      expect(state.todayManifestCount, equals(4));
      expect(state.activeSchoolRunsCount, equals(2));
      expect(state.pendingHandoverCount, equals(1));
      expect(state.activeExceptionsCount, equals(2));

      // Test Manifest Window Filter: Morning vs Afternoon
      notifier.setManifestFilter('MORNING');
      state = container.read(scheduledOperationsNotifierProvider);
      expect(state.filteredTrips.length, equals(2));
      expect(state.filteredTrips.every((t) => t.scheduledPickupAt.hour < 12), isTrue);

      notifier.setManifestFilter('AFTERNOON');
      state = container.read(scheduledOperationsNotifierProvider);
      expect(state.filteredTrips.length, equals(2));
      expect(state.filteredTrips.every((t) => t.scheduledPickupAt.hour >= 12), isTrue);

      notifier.setManifestFilter('ALL');

      // Test Single-Use Handover OTP Verification
      // Invalid OTP fails
      final failOtp = await notifier.verifyHandoverOtp(
        'STU-001',
        '000000',
        officerName: 'Gate Marshal John',
      );
      expect(failOtp, isFalse);
      state = container.read(scheduledOperationsNotifierProvider);
      expect(state.actionMessage, contains('Invalid OTP code'));

      // Valid OTP succeeds
      final successOtp = await notifier.verifyHandoverOtp(
        'STU-001',
        '482910',
        officerName: 'Gate Marshal John',
      );
      expect(successOtp, isTrue);
      state = container.read(scheduledOperationsNotifierProvider);
      final zayd = state.safekeepingRoster.firstWhere((s) => s.passengerId == 'STU-001');
      expect(zayd.otpStatus, equals(HandoverStatus.verified));
      expect(zayd.isVerified, isTrue);
      expect(state.actionMessage, contains('Handover verified'));

      // Test Emergency OTP Bypass
      final successBypass = await notifier.emergencyBypassOtp(
        'STU-001',
        officerName: 'Supervisor Adeola',
        reason: 'Parent presented physical NIN card and student identified mother in person',
      );
      expect(successBypass, isTrue);
      state = container.read(scheduledOperationsNotifierProvider);
      expect(state.safekeepingRoster.firstWhere((s) => s.passengerId == 'STU-001').verifiedByStaffOrDriver,
          contains('EMERGENCY OVERRIDE'));

      // Test Reassign Driver
      const standbyChaperone = RiderDto(
        id: 'RIDER-005',
        profileId: 'PROF-005',
        fullName: 'Bala Mohammed',
        phoneNumber: '+2348052219988',
        rating: 4.88,
        status: RiderStatus.online,
        vehiclePlate: 'KD-331-ZX',
        vehicleModel: 'Spiro EV Sedan',
        batteryLevelPercent: 85,
      );
      final successReassign = await notifier.reassignDriver(
        'TRIP-SCH-003',
        standbyChaperone,
        reason: 'Chaperone shift rotation',
      );
      expect(successReassign, isTrue);
      state = container.read(scheduledOperationsNotifierProvider);
      expect(state.trips.firstWhere((t) => t.id == 'TRIP-SCH-003').assignedDriver?.fullName,
          equals('Bala Mohammed'));

      // Test Calendar Exception Management
      final newException = SchoolCalendarExceptionModel(
        id: 'EXC-TEST-01',
        title: 'Kaduna Heavy Flooding Closure',
        reason: 'River Kaduna overflowed banks. State declared civil safety holiday.',
        startDate: DateTime.now(),
        endDate: DateTime.now().add(const Duration(days: 1)),
        affectedSchools: const ['All Kaduna Schools'],
        createdBy: 'Admin Adeola',
        createdAt: DateTime.now(),
      );
      final successAddExc = await notifier.addCalendarException(newException);
      expect(successAddExc, isTrue);
      state = container.read(scheduledOperationsNotifierProvider);
      expect(state.calendarExceptions.any((e) => e.title == 'Kaduna Heavy Flooding Closure'), isTrue);

      // Toggle exception status
      final successToggle = await notifier.toggleCalendarExceptionStatus(newException.id);
      expect(successToggle, isTrue);
      state = container.read(scheduledOperationsNotifierProvider);
      expect(state.calendarExceptions.firstWhere((e) => e.id == newException.id).status,
          equals('CANCELLED'));
    });

    testWidgets('ScheduledOperationsScreen renders KPI cards, tabs, and modals', (tester) async {
      tester.view.physicalSize = const Size(2400, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestApp(const ScheduledOperationsScreen()));
      await tester.pumpAndSettle();

      // Check header and uppercase KPI titles
      expect(find.text('Scheduled Commute & School-Run Command Desk'), findsOneWidget);
      expect(find.text('TODAY\'S MANIFEST'), findsOneWidget);
      expect(find.text('ACTIVE SCHOOL RUNS'), findsOneWidget);
      expect(find.text('HANDOVER OTP PENDING'), findsOneWidget);
      expect(find.text('CALENDAR EXCEPTIONS'), findsOneWidget);

      // Check Tabs
      expect(find.textContaining('Daily Run Manifests'), findsOneWidget);
      expect(find.textContaining('Guardian Safekeeping & Handover OTP Desk'), findsOneWidget);
      expect(find.textContaining('School Calendar Exceptions'), findsOneWidget);

      // Check Manifest Table
      expect(find.text('SCH-2026-0801'), findsOneWidget);
      expect(find.text('Zayd Cole'), findsAtLeastNWidgets(1));
      expect(find.text('Kaduna Capital School, Malali, Kaduna'), findsAtLeastNWidgets(1));

      // Open Reassign Chaperone Modal
      await tester.tap(find.byKey(const Key('reassign_trip_TRIP-SCH-001')));
      await tester.pumpAndSettle();

      expect(find.byType(ChaperoneReassignmentModal), findsOneWidget);
      expect(find.text('Reassign Vetted Chaperone — SCH-2026-0801'), findsOneWidget);
      expect(find.text('SELECT VETTED STANDBY CHAPERONE'), findsOneWidget);
      expect(find.text('Confirm Chaperone Reassignment'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(ChaperoneReassignmentModal), findsNothing);

      // Switch to Safekeeping Tab
      await tester.tap(find.textContaining('Guardian Safekeeping & Handover OTP Desk'));
      await tester.pumpAndSettle();

      expect(find.text('AUTHORIZED GUARDIANS'), findsOneWidget);
      expect(find.byKey(const Key('verify_handover_STU-001')), findsOneWidget);

      // Open Handover OTP Modal
      await tester.tap(find.byKey(const Key('verify_handover_STU-001')));
      await tester.pumpAndSettle();

      expect(find.byType(HandoverVerificationModal), findsOneWidget);
      expect(find.text('School-Run Safekeeping & Handover — Zayd Cole'), findsOneWidget);
      expect(find.text('SINGLE-USE HANDOVER OTP AUTHENTICATION'), findsOneWidget);
      expect(find.byKey(const Key('verify_otp_btn')), findsOneWidget);

      await tester.tap(find.text('Close'));
      await tester.pumpAndSettle();
      expect(find.byType(HandoverVerificationModal), findsNothing);

      // Switch to Exceptions Tab
      await tester.tap(find.textContaining('School Calendar Exceptions'));
      await tester.pumpAndSettle();

      expect(find.text('Democracy Day Public Holiday'), findsOneWidget);
      expect(find.byKey(const Key('add_calendar_exception_btn')), findsOneWidget);

      // Open Calendar Exception Modal
      await tester.tap(find.byKey(const Key('add_calendar_exception_btn')));
      await tester.pumpAndSettle();

      expect(find.byType(CalendarExceptionModal), findsOneWidget);
      expect(find.text('Add School Calendar Exception'), findsOneWidget);
      expect(find.byKey(const Key('submit_exception_btn')), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(CalendarExceptionModal), findsNothing);
    });

    test('StaffRole permissions enforce RBAC for errands and scheduled operations', () {
      // Market Errands access
      expect(StaffRole.opsAgent.canAccessErrands, isTrue);
      expect(StaffRole.admin.canAccessErrands, isTrue);
      expect(StaffRole.superAdmin.canAccessErrands, isTrue);
      expect(StaffRole.finance.canAccessErrands, isTrue);

      // Scheduled School-Run access
      expect(StaffRole.opsAgent.canAccessScheduled, isTrue);
      expect(StaffRole.safetyOfficer.canAccessScheduled, isTrue);
      expect(StaffRole.admin.canAccessScheduled, isTrue);
      expect(StaffRole.superAdmin.canAccessScheduled, isTrue);
      expect(StaffRole.finance.canAccessScheduled, isFalse);
      expect(StaffRole.promotionsManager.canAccessScheduled, isFalse);
    });
  });
}

