import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rider_app/src/features/earnings/application/rider_earnings_notifier.dart';
import 'package:rider_app/src/features/earnings/presentation/rider_earnings_screen.dart';
import 'package:rider_app/src/features/profile/presentation/rider_profile_screen.dart';
import 'package:rider_app/src/features/swaps/application/battery_swap_notifier.dart';
import 'package:rider_app/src/features/swaps/presentation/battery_swap_screen.dart';

void main() {
  group('Phase 2D Unit Tests — Rider Earnings & Battery Hub State', () {
    test('RiderEarningsNotifier initializes with verified ledger and calculations', () {
      final notifier = RiderEarningsNotifier();
      final state = notifier.state;

      expect(state.grossWeekKobo, 10800000);
      expect(state.commissionWeekKobo, 2160000); // 20%
      expect(state.tipsWeekKobo, 450000);
      expect(state.settledWeekKobo, 8640000);
      expect(state.bankName, 'Access Bank');
      expect(state.entries.length, 4);
    });

    test('RiderEarningsNotifier handles instant payout withdrawal and updates balance', () async {
      final notifier = RiderEarningsNotifier();

      // Attempt withdrawal greater than balance
      final overdrawn = await notifier.requestInstantWithdrawal(99999999);
      expect(overdrawn, isFalse);

      // Attempt valid withdrawal: ₦20,000 (2,000,000 kobo)
      final success = await notifier.requestInstantWithdrawal(2000000);
      expect(success, isTrue);
      expect(notifier.state.settledWeekKobo, 6640000); // 86,400 - 20,000 = 66,400
      expect(notifier.state.entries.first.isPayout, isTrue);
      expect(notifier.state.entries.first.title, contains('Instant Payout Requested'));
    });

    test('RiderEarningsNotifier records dispute reference', () {
      final notifier = RiderEarningsNotifier();
      notifier.submitDispute('TRP-LAG-8921', 'Incorrect commission deduction');
      expect(notifier.state.lastDisputeSubmittedReference, 'TRP-LAG-8921');
    });

    test('BatterySwapNotifier manages reservation lifecycle and slot inventory', () {
      final notifier = BatterySwapNotifier();
      expect(notifier.state.stations.length, 4);
      expect(notifier.state.batteryHealthPercent, 94);
      expect(notifier.state.hasActiveReservation, isFalse);

      final ikejaBefore = notifier.state.stations.firstWhere((s) => s.id == 'st_ikeja').availablePacks;

      // Reserve slot
      final reserved = notifier.reserveSlot('st_ikeja');
      expect(reserved, isTrue);
      expect(notifier.state.hasActiveReservation, isTrue);
      expect(notifier.state.reservedStationId, 'st_ikeja');

      final ikejaAfter = notifier.state.stations.firstWhere((s) => s.id == 'st_ikeja').availablePacks;
      expect(ikejaAfter, ikejaBefore - 1);

      // Cancel reservation
      notifier.cancelReservation();
      expect(notifier.state.hasActiveReservation, isFalse);
      expect(notifier.state.reservedStationId, isNull);

      final ikejaRestored = notifier.state.stations.firstWhere((s) => s.id == 'st_ikeja').availablePacks;
      expect(ikejaRestored, ikejaBefore);
    });

    test('BatterySwapNotifier simulates QR locker unlock and battery replenishment', () async {
      final notifier = BatterySwapNotifier();

      final lockerNumber = await notifier.unlockLockerWithQr('SWAP-QR-001');
      expect(lockerNumber, 4);
      expect(notifier.state.batteryHealthPercent, 100);
      expect(notifier.state.estimatedRangeKm, 85);
      expect(notifier.state.unlockedLockerNumber, 4);
    });
  });

  group('Phase 2D Widget & Presentation Tests — RD19, RD22, RD25', () {
    testWidgets('RiderEarningsScreen renders weekly payout card and ledger items', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RiderEarningsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Earnings & Payouts'), findsOneWidget);
      expect(find.textContaining('86,400'), findsOneWidget);
      expect(find.text('SETTLES TUESDAY'), findsOneWidget);
      expect(find.textContaining('Access Bank'), findsWidgets);
      expect(find.textContaining('Gross Fare'), findsOneWidget);
      expect(find.textContaining('Platform (20%)'), findsOneWidget);
      expect(find.textContaining('Tips (100%)'), findsOneWidget);
      expect(find.text('Request Instant Payout'), findsOneWidget);
      expect(find.textContaining('Express Parcel Delivery'), findsOneWidget);
    });

    testWidgets('RiderEarningsScreen triggers instant payout dialog and execution', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: RiderEarningsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Request Instant Payout'));
      await tester.pumpAndSettle();

      expect(find.text('Instant Payout Request'), findsOneWidget);
      expect(find.text('Confirm ₦20,000'), findsOneWidget);

      await tester.tap(find.text('Confirm ₦20,000'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Instant payout of ₦20,000 sent'), findsOneWidget);
      expect(find.textContaining('66,400'), findsOneWidget); // Balance reduced
    });

    testWidgets('BatterySwapScreen renders stations and supports slot reservation', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: BatterySwapScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('EV Battery Swapping Stations'), findsOneWidget);
      expect(find.textContaining('94% (Good Health)'), findsOneWidget);
      expect(find.text('Ikeja Central Kiosk'), findsOneWidget);
      expect(find.text('Victoria Island Solar Hub'), findsOneWidget);

      // Tap Reserve Slot on the first station
      final reserveButtons = find.text('Reserve Slot (15 min)');
      expect(reserveButtons, findsWidgets);

      await tester.tap(reserveButtons.first);
      await tester.pumpAndSettle();

      expect(find.textContaining('Active Reservation: Ikeja Central Kiosk'), findsOneWidget);
      expect(find.text('Reserved (15 min)'), findsOneWidget);
    });

    testWidgets('BatterySwapScreen opens QR unlock sheet and triggers locker release', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: BatterySwapScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Open QR scanner sheet
      await tester.tap(find.text('Unlock'));
      await tester.pumpAndSettle();

      expect(find.text('Scan Kiosk Station QR Code'), findsOneWidget);
      expect(find.text('Simulate Kiosk Scan & Unlock Door'), findsOneWidget);

      await tester.tap(find.text('Simulate Kiosk Scan & Unlock Door'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Locker #4 Unlocked!'), findsOneWidget);
      expect(find.textContaining('100% (Good Health)'), findsOneWidget);
    });

    testWidgets('RiderProfileScreen renders bio, certifications, and Emergency SOS dialog', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: RiderProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Rider Profile'), findsOneWidget);
      expect(find.text('Babajide Ogundipe'), findsOneWidget);
      expect(find.text('4.96 Rating'), findsOneWidget);
      expect(find.text('Parcel Delivery Certification'), findsOneWidget);
      expect(find.text('Passenger EV Commute License'), findsOneWidget);
      expect(find.text('School-Run Chaperone Security Badge'), findsOneWidget);
      expect(find.text('Emergency SOS & Incident Response'), findsOneWidget);
      expect(find.text('Sign Out of Rider Account'), findsOneWidget);

      // Trigger Emergency SOS Dialog
      await tester.tap(find.text('Emergency SOS & Incident Response'));
      await tester.pumpAndSettle();

      expect(find.text('EMERGENCY SOS'), findsOneWidget);
      expect(find.textContaining('Lagos Police & Ambulance: 112'), findsOneWidget);
      expect(find.text('BROADCAST SOS'), findsOneWidget);

      await tester.tap(find.text('BROADCAST SOS'));
      await tester.pumpAndSettle();

      expect(find.textContaining('SOS Alert Broadcast!'), findsOneWidget);
    });
  });
}
