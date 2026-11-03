import 'helpers/test_seeds.dart';
import 'package:admin_web/src/features/pricing/application/pricing_notifier.dart';
import 'package:admin_web/src/features/pricing/domain/pricing_models.dart';
import 'package:admin_web/src/features/pricing/presentation/pricing_management_screen.dart';
import 'package:admin_web/src/features/riders/application/rider_management_notifier.dart';
import 'package:admin_web/src/features/riders/domain/rider_management_state.dart';
import 'package:admin_web/src/features/riders/presentation/rider_management_screen.dart';
import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Rider Compliance & KYC Review Module Tests', () {
    test('RiderManagementNotifier approves, certifies tiers, and suspends riders', () async {
      final container = ProviderContainer();
      container.read(riderManagementNotifierProvider.notifier).seedForTest();
      addTearDown(container.dispose);

      final notifier = container.read(riderManagementNotifierProvider.notifier);
      notifier.seedForTest();
      final state = container.read(riderManagementNotifierProvider);

      final pendingApplicants = state.riders.where((r) => r.status == RiderComplianceStatus.pendingReview).toList();
      expect(pendingApplicants.length, greaterThanOrEqualTo(1));
      final pendingApplicant = pendingApplicants.first;

      // Certify rider for School-Run Chaperone tier
      expect(pendingApplicant.isSchoolRunCertified, isFalse);
      notifier.toggleServiceTierCertification(
        riderId: pendingApplicant.id,
        tier: ServiceTierEligibility.schoolRunCommute,
      );

      final updatedApplicant = container.read(riderManagementNotifierProvider)
          .riders.firstWhere((a) => a.id == pendingApplicant.id);
      expect(updatedApplicant.isSchoolRunCertified, isTrue);

      // Approve rider onboarding
      await notifier.approveRider(
        riderId: pendingApplicant.id,
        certifiedTiers: [
          ...pendingApplicant.certifiedTiers,
          ServiceTierEligibility.schoolRunCommute,
        ],
        auditNote: 'Verified NIN and LASDRI compliance credentials',
      );
      final approvedApplicant = container.read(riderManagementNotifierProvider)
          .riders.firstWhere((a) => a.id == pendingApplicant.id);
      expect(approvedApplicant.status, equals(RiderComplianceStatus.approved));

      // Suspend rider
      await notifier.suspendRider(
        riderId: pendingApplicant.id,
        mandatoryReason: 'Routine periodic background re-verification',
      );
      final suspendedApplicant = container.read(riderManagementNotifierProvider)
          .riders.firstWhere((a) => a.id == pendingApplicant.id);
      expect(suspendedApplicant.status, equals(RiderComplianceStatus.suspended));
    });

    testWidgets('RiderManagementScreen renders compliance table and filters', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer();
      container.read(riderManagementNotifierProvider.notifier).seedForTest();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: GVTheme.darkTheme,
            home: const Scaffold(
              body: RiderManagementScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Rider Compliance & Fleet Review'), findsOneWidget);
      expect(find.text('PENDING REVIEW'), findsWidgets);
      expect(find.text('CERTIFIED ACTIVE'), findsWidgets);
      expect(find.text('SUSPENDED RIDERS'), findsWidgets);
    });
  });

  group('Pricing & Service Areas Module Tests', () {
    test('PricingNotifier creates draft, publishes immutable version, and toggles zone tiers', () {
      final container = ProviderContainer();
      container.read(pricingNotifierProvider.notifier).seedForTest();
      addTearDown(container.dispose);

      final notifier = container.read(pricingNotifierProvider.notifier);
      final initialActive = container.read(pricingNotifierProvider).activeRule!;
      expect(initialActive.status, equals(PricingRuleStatus.active));

      // 1. Create a draft version
      notifier.createDraftRule(
        tier: ServiceTier.commute,
        baseFareKobo: BigInt.from(75000), // ₦750
        perKmKobo: BigInt.from(14000), // ₦140/km
        perMinuteKobo: BigInt.from(3000), // ₦30/min
        minimumFareKobo: BigInt.from(100000), // ₦1,000
        surgeMultiplierCap: 2.2,
        createdBy: 'admin_test',
        notes: 'End of year traffic surcharge adjustment',
      );

      final draftState = container.read(pricingNotifierProvider);
      expect(draftState.draftRules.length, equals(1));
      final draft = draftState.draftRules.first;
      expect(draft.status, equals(PricingRuleStatus.draft));
      expect(draft.baseFareKobo, equals(BigInt.from(75000)));

      // 2. Publish draft: old active becomes archived; draft becomes new active
      notifier.publishDraftRule(draft.id);

      final publishedState = container.read(pricingNotifierProvider);
      final newActive = publishedState.activeRule!;
      expect(newActive.status, equals(PricingRuleStatus.active));
      expect(newActive.baseFareKobo, equals(BigInt.from(75000)));

      // Verify old active is archived (immutable snapshot preserved)
      final archived = publishedState.archivedRules.firstWhere((r) => r.id == initialActive.id);
      expect(archived.status, equals(PricingRuleStatus.archived));
      expect(archived.baseFareKobo, equals(initialActive.baseFareKobo));

      // 3. Zone Service Tier Gating
      final initialZone = publishedState.currentZone!;
      expect(initialZone.isTierEnabled(ServiceTier.schoolRun), isTrue);

      // Disable School-Run for this zone
      notifier.toggleZoneServiceTier(initialZone.zoneId, ServiceTier.schoolRun, false);
      expect(container.read(pricingNotifierProvider).currentZone!.isTierEnabled(ServiceTier.schoolRun), isFalse);

      // Re-enable School-Run for this zone
      notifier.toggleZoneServiceTier(initialZone.zoneId, ServiceTier.schoolRun, true);
      expect(container.read(pricingNotifierProvider).currentZone!.isTierEnabled(ServiceTier.schoolRun), isTrue);

      // 4. Surge override within cap
      notifier.updateZoneSurge(initialZone.zoneId, 1.8);
      expect(container.read(pricingNotifierProvider).currentZone!.currentSurgeMultiplier, equals(1.8));

      // Attempt surge above cap: automatically clamped to maxSurgeCap
      notifier.updateZoneSurge(initialZone.zoneId, 5.0);
      expect(container.read(pricingNotifierProvider).currentZone!.currentSurgeMultiplier, equals(initialZone.maxSurgeCap));
    });

    testWidgets('PricingManagementScreen renders tariff versions and zone matrix', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer();
      container.read(pricingNotifierProvider.notifier).seedForTest();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: GVTheme.darkTheme,
            home: const Scaffold(
              body: PricingManagementScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pricing Engine & Service Areas'), findsOneWidget);
      expect(find.byKey(const Key('create_draft_pricing_btn')), findsOneWidget);
      expect(find.text('Service Area Gating & Dynamic Surge Override'), findsOneWidget);
    });

    test('PricingNotifier manages 5 seeded ride options (2 bikes, 3 cars) and allows toggle and addition', () {
      final container = ProviderContainer();
      container.read(pricingNotifierProvider.notifier).seedForTest();
      addTearDown(container.dispose);

      final state = container.read(pricingNotifierProvider);
      final notifier = container.read(pricingNotifierProvider.notifier);

      // Verify 5 seeded options: 2 bikes and 3 cars
      expect(state.rideCategories.length, equals(5));
      final bikeCategories = state.rideCategories.where((c) => c.iconKey == 'electric_bike').toList();
      final carCategories = state.rideCategories.where((c) => c.iconKey != 'electric_bike').toList();
      expect(bikeCategories.length, equals(2));
      expect(carCategories.length, equals(3));

      expect(bikeCategories.any((b) => b.name == 'GoRide Moto'), isTrue);
      expect(bikeCategories.any((b) => b.name == 'GoRide Moto Plus'), isTrue);
      expect(carCategories.any((c) => c.name == 'GoRide Standard'), isTrue);
      expect(carCategories.any((c) => c.name == 'GoRide Plus'), isTrue);
      expect(carCategories.any((c) => c.name == 'GoRide XL'), isTrue);

      // Toggle category availability
      final moto = bikeCategories.first;
      expect(moto.isAvailable, isTrue);
      notifier.toggleRideCategory(moto.id, false);

      final updatedMoto = container.read(pricingNotifierProvider)
          .rideCategories.firstWhere((c) => c.id == moto.id);
      expect(updatedMoto.isAvailable, isFalse);

      // Add a 6th ride option
      const newOption = RideCategoryDto(
        id: 'cat_car_lux',
        code: 'luxury',
        name: 'GoRide Luxury',
        description: 'VIP luxury electric sedan service',
        passengerCapacity: 3,
        baseFareKobo: 600000,
        etaMinutes: 5,
        iconKey: 'electric_car',
        isAvailable: true,
      );
      notifier.addRideCategory(newOption);
      expect(container.read(pricingNotifierProvider).rideCategories.length, equals(6));
    });

    testWidgets('PricingManagementScreen renders ride options catalogue and handles availability toggle', (tester) async {
      tester.view.physicalSize = const Size(1440, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer();
      container.read(pricingNotifierProvider.notifier).seedForTest();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: GVTheme.darkTheme,
            home: const Scaffold(
              body: PricingManagementScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check section header and 5 seeded ride options
      expect(find.text('Published Ride Options Catalogue (Customer App)'), findsOneWidget);
      expect(find.byKey(const Key('add_ride_option_top_btn')), findsOneWidget);
      expect(find.byKey(const Key('add_ride_option_section_btn')), findsOneWidget);

      expect(find.text('GoRide Moto'), findsOneWidget);
      expect(find.text('GoRide Moto Plus'), findsOneWidget);
      expect(find.text('GoRide Standard'), findsOneWidget);
      expect(find.text('GoRide Plus'), findsOneWidget);
      expect(find.text('GoRide XL'), findsOneWidget);

      // Toggle first category
      final toggleKey = find.byKey(const Key('toggle_ride_cat_cat_bike_std'));
      expect(toggleKey, findsOneWidget);
      await tester.tap(toggleKey);
      await tester.pumpAndSettle();

      expect(find.text('GoRide Moto is now disabled for customers.'), findsOneWidget);
    });
  });
}
