import 'package:admin_web/src/core/auth/admin_auth_notifier.dart';
import 'package:admin_web/src/core/auth/admin_role.dart';
import 'package:admin_web/src/core/navigation/admin_router.dart';
import 'package:admin_web/src/features/fleet/application/battery_swap_notifier.dart';
import 'package:admin_web/src/features/fleet/presentation/battery_swap_screen.dart';
import 'package:admin_web/src/features/safety/application/safety_sos_notifier.dart';
import 'package:admin_web/src/features/safety/domain/safety_sos_models.dart';
import 'package:admin_web/src/features/safety/presentation/safety_sos_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

Widget createTestApp(Widget home, {StaffRole role = StaffRole.admin}) {
  return ProviderScope(
    overrides: [
      adminAuthNotifierProvider.overrideWith((ref) {
        final notifier = AdminAuthNotifier();
        notifier.setRole(role);
        return notifier;
      }),
    ],
    child: MaterialApp(
      home: home,
    ),
  );
}

void main() {
  group('Safety SOS Rapid Dispatch Desk Tests (§5.3)', () {
    test('SafetySosNotifier seeds, searches, filters, dispatches and resolves', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(safetySosNotifierProvider.notifier);
      var state = container.read(safetySosNotifierProvider);

      expect(state.totalAlertsCount, equals(4));
      expect(state.activeDistressCount, equals(1));
      expect(state.dispatched112Count, equals(1));
      expect(state.patrolEnRouteCount, equals(1));
      expect(state.resolvedCount, equals(1));

      // Test Search by Incident Ref
      notifier.search('SOS-2026-0041');
      state = container.read(safetySosNotifierProvider);
      expect(state.filteredAlerts.length, equals(1));
      expect(state.filteredAlerts.first.victimName, equals('Khadijah Cole'));

      // Test Search by Victim Name
      notifier.search('Omotayo');
      state = container.read(safetySosNotifierProvider);
      expect(state.filteredAlerts.length, equals(1));
      expect(state.filteredAlerts.first.incidentRef, equals('SOS-2026-0039'));

      notifier.search('');

      // Test Filter by Status
      notifier.filterByStatus(SosAlertStatus.activeDistress);
      state = container.read(safetySosNotifierProvider);
      expect(state.filteredAlerts.length, equals(1));
      expect(state.filteredAlerts.first.isActive, isTrue);

      notifier.filterByStatus(null);

      // Test Emergency Agency Dispatch (Lagos 112)
      final dispatchSuccess = await notifier.dispatchEmergencyServices(
        'SOS-001',
        agency: 'Lagos 112 / 767 Emergency Center',
        officerName: 'Agent Danjuma',
        notes: 'Dispatched 112 medical response unit to Victoria Island GPS pin',
      );
      expect(dispatchSuccess, isTrue);
      state = container.read(safetySosNotifierProvider);
      final dispatchedAlert = state.alerts.firstWhere((a) => a.id == 'SOS-001');
      expect(dispatchedAlert.status, equals(SosAlertStatus.dispatchedAuthorities));
      expect(dispatchedAlert.emergencyServicesContacted, contains('Lagos 112 / 767 Emergency Center'));
      expect(dispatchedAlert.incidentNotes.length, greaterThanOrEqualTo(2));

      // Test Deploy EV Patrol Unit
      final patrolSuccess = await notifier.dispatchPatrolUnit(
        'SOS-001',
        patrolUnitCode: 'UNIT-ALPHA-EV',
        officerName: 'Agent Danjuma',
      );
      expect(patrolSuccess, isTrue);
      state = container.read(safetySosNotifierProvider);
      final patrolAlert = state.alerts.firstWhere((a) => a.id == 'SOS-001');
      expect(patrolAlert.status, equals(SosAlertStatus.patrolEnRoute));
      expect(patrolAlert.incidentNotes.any((n) => n.note.contains('UNIT-ALPHA-EV')), isTrue);

      // Test Add Incident Note
      await notifier.addIncidentNote(
        'SOS-001',
        authorName: 'Agent Danjuma',
        authorRole: 'Safety Dispatch Officer',
        note: 'Customer confirmed safe by nearby security guard',
      );
      state = container.read(safetySosNotifierProvider);
      expect(
        state.alerts
            .firstWhere((a) => a.id == 'SOS-001')
            .incidentNotes
            .any((n) => n.note.contains('Customer confirmed safe')),
        isTrue,
      );

      // Test Resolve Alert
      final resolveSuccess = await notifier.resolveAlert(
        'SOS-001',
        isFalseAlarm: false,
        officerName: 'Agent Danjuma',
        resolutionSummary: 'Passenger safely escorted to venue; emergency resolved',
      );
      expect(resolveSuccess, isTrue);
      state = container.read(safetySosNotifierProvider);
      final resolvedAlert = state.alerts.firstWhere((a) => a.id == 'SOS-001');
      expect(resolvedAlert.status, equals(SosAlertStatus.resolvedSafe));
      expect(resolvedAlert.isActive, isFalse);
      expect(state.resolvedCount, equals(2));
      expect(state.activeDistressCount, equals(0));
    });

    testWidgets('SafetySosScreen renders header, KPI cards, table and modal dialog',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createTestApp(const SafetySosScreen()));
      await tester.pumpAndSettle();

      // Check Header & KPIs
      expect(find.text('Emergency SOS Rapid Dispatch Desk'), findsOneWidget);
      expect(find.text('ACTIVE SOS DISTRESS'), findsOneWidget);
      expect(find.text('PATROL EN ROUTE'), findsOneWidget);
      expect(find.text('ESCALATED TO 112/POLICE'), findsOneWidget);
      expect(find.text('RESOLVED TODAY'), findsOneWidget);

      // Check Active Alarm Table items
      expect(find.text('SOS-2026-0041'), findsOneWidget);
      expect(find.text('Khadijah Cole'), findsOneWidget);

      // Trigger Command Desk Modal
      final openModalBtn = find.text('DISPATCH').first;
      expect(openModalBtn, findsOneWidget);
      await tester.tap(openModalBtn);
      await tester.pumpAndSettle();

      // Verify Modal Contents
      expect(find.textContaining('Emergency SOS Command Desk'), findsOneWidget);
      expect(find.text('CURRENT SPEED'), findsOneWidget);
      expect(find.text('Deploy Go-Volts EV Patrol Unit'), findsOneWidget);

      // Close modal
      final closeBtn = find.text('Close');
      expect(closeBtn, findsOneWidget);
      await tester.tap(closeBtn);
      await tester.pumpAndSettle();
    });
  });

  group('EV Battery Swap & Telematics Station Desk Tests (§5.4)', () {
    test('BatterySwapNotifier seeds, searches, filters, quarantines, releases and unlocks',
        () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(batterySwapNotifierProvider.notifier);
      var state = container.read(batterySwapNotifierProvider);

      expect(state.totalStationsCount, equals(4));
      expect(state.totalChargedPacks, greaterThan(40));
      expect(state.totalChargingPacks, greaterThan(20));
      expect(state.totalQuarantinedPacks, equals(2));
      expect(state.totalDailySwaps, greaterThan(500));

      // Test Search
      notifier.search('Lekki Phase 1');
      state = container.read(batterySwapNotifierProvider);
      expect(state.filteredStations.length, equals(1));
      expect(state.filteredStations.first.id, equals('STN-02'));

      notifier.search('');

      // Test Filter by Status
      notifier.filterByStatus('HIGH_DEMAND');
      state = container.read(batterySwapNotifierProvider);
      expect(state.filteredStations.length, equals(1));
      expect(state.filteredStations.first.id, equals('STN-04'));

      notifier.filterByStatus(null);

      // Test Quarantine Battery Bay
      final quarantineSuccess = await notifier.quarantineBatteryBay(
        'STN-02',
        1,
        reason: 'Thermal runaway threshold exceeded (>44°C)',
        officerName: 'Fleet Tech Tunde',
      );
      expect(quarantineSuccess, isTrue);
      state = container.read(batterySwapNotifierProvider);
      final lekkiStn = state.stations.firstWhere((s) => s.id == 'STN-02');
      final bay1 = lekkiStn.bays.firstWhere((b) => b.bayNumber == 1);
      expect(bay1.isQuarantined, isTrue);
      expect(bay1.isCharging, isFalse);
      expect(bay1.quarantineReason, contains('Thermal runaway'));
      expect(state.totalQuarantinedPacks, equals(3));

      // Test Release Quarantine Battery Bay
      final releaseSuccess = await notifier.releaseQuarantineBay(
        'STN-02',
        1,
        officerName: 'Fleet Tech Tunde',
      );
      expect(releaseSuccess, isTrue);
      state = container.read(batterySwapNotifierProvider);
      final lekkiStnAfter = state.stations.firstWhere((s) => s.id == 'STN-02');
      final bay1After = lekkiStnAfter.bays.firstWhere((b) => b.bayNumber == 1);
      expect(bay1After.isQuarantined, isFalse);
      expect(bay1After.isCharging, isTrue);
      expect(state.totalQuarantinedPacks, equals(2));

      // Test Remote Unlock Bay Door
      final unlockSuccess = await notifier.remoteUnlockBay(
        'STN-01',
        2,
        officerName: 'Fleet Tech Tunde',
      );
      expect(unlockSuccess, isTrue);
      state = container.read(batterySwapNotifierProvider);
      final viStn = state.stations.firstWhere((s) => s.id == 'STN-01');
      final bay2 = viStn.bays.firstWhere((b) => b.bayNumber == 2);
      expect(bay2.isLocked, isFalse);

      // Test Station Maintenance Mode Toggle
      final toggleSuccess = await notifier.toggleStationMaintenance(
        'STN-03',
        reason: 'Transformer servicing',
        officerName: 'Fleet Tech Tunde',
      );
      expect(toggleSuccess, isTrue);
      state = container.read(batterySwapNotifierProvider);
      final ikejaStn = state.stations.firstWhere((s) => s.id == 'STN-03');
      expect(ikejaStn.status, equals('MAINTENANCE'));
    });

    testWidgets('BatterySwapScreen renders stations and opens Cabinet Bay Modal',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(1400, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(createTestApp(const BatterySwapScreen()));
      await tester.pumpAndSettle();

      // Check Header & KPIs
      expect(find.text('EV Battery Swap & Telematics Station Desk'), findsOneWidget);
      expect(find.text('ACTIVE SWAP HUBS'), findsOneWidget);
      expect(find.textContaining('CHARGED PACKS'), findsOneWidget);
      expect(find.text('ACTIVE CHARGING PACKS'), findsOneWidget);
      expect(find.text('QUARANTINED / DEGRADED'), findsOneWidget);

      // Check Station Names
      expect(find.text('Victoria Island Central Swap Hub'), findsOneWidget);
      expect(find.text('Lekki Phase 1 Solar Swap Station'), findsOneWidget);

      // Open 24-Bay Cabinet Modal
      final inspectBtns = find.text('Inspect 24-Bay Cabinet');
      expect(inspectBtns, findsWidgets);
      await tester.tap(inspectBtns.first);
      await tester.pumpAndSettle();

      // Verify Cabinet Modal
      expect(find.textContaining('Cabinet Bay Telematics Inspector'), findsOneWidget);
      expect(find.text('Bay 01'), findsOneWidget);
      expect(find.text('Remote Unlock Door'), findsOneWidget);

      // Close modal
      final closeBtn = find.text('Close');
      expect(closeBtn, findsOneWidget);
      await tester.tap(closeBtn);
      await tester.pumpAndSettle();
    });
  });

  group('RBAC & Navigation Integration Tests for Phase 3', () {
    test('StaffRole access permissions for SOS desk and Battery Swap desk', () {
      // Emergency SOS Access: safetyOfficer, opsAgent, admin, superAdmin
      expect(StaffRole.safetyOfficer.canAccessSafetySos, isTrue);
      expect(StaffRole.opsAgent.canAccessSafetySos, isTrue);
      expect(StaffRole.admin.canAccessSafetySos, isTrue);
      expect(StaffRole.superAdmin.canAccessSafetySos, isTrue);
      expect(StaffRole.finance.canAccessSafetySos, isFalse);
      expect(StaffRole.promotionsManager.canAccessSafetySos, isFalse);

      // Battery Swap Access: opsAgent, admin, superAdmin, finance
      expect(StaffRole.opsAgent.canAccessBatterySwap, isTrue);
      expect(StaffRole.admin.canAccessBatterySwap, isTrue);
      expect(StaffRole.superAdmin.canAccessBatterySwap, isTrue);
      expect(StaffRole.finance.canAccessBatterySwap, isTrue);
      expect(StaffRole.promotionsManager.canAccessBatterySwap, isFalse);
    });

    test('adminRouterProvider registers /safety/sos and /battery-swap routes', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final router = container.read(adminRouterProvider);
      final shellRoute = router.configuration.routes.first as ShellRoute;
      final paths = shellRoute.routes.map((r) => (r as GoRoute).path).toList();

      expect(paths, contains('/safety/sos'));
      expect(paths, contains('/battery-swap'));
    });
  });
}
