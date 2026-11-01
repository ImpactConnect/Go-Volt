import 'package:api_client/api_client.dart';
import 'package:app_config/app_config.dart';
import 'package:app_models/app_models.dart';
import 'package:customer_app/src/core/providers/api_providers.dart';
import 'package:customer_app/src/features/scheduled/application/scheduled_notifier.dart';
import 'package:customer_app/src/features/scheduled/data/scheduled_repository.dart';
import 'package:customer_app/src/features/scheduled/presentation/scheduled_plans_screen.dart';
import 'package:customer_app/src/features/scheduled/presentation/school_run_safety_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final testConfig = AppConfig.dev();
  final testApiClient = ApiClient(config: testConfig);
  final testScheduledRepo = ScheduledRepository(apiClient: testApiClient);

  final testSchoolRunPlan = ScheduledPlanDto(
    id: 'plan-test-01',
    planReference: 'GV-SCH-2026-TEST',
    planType: 'SCHOOL_RUN_PLAN',
    purpose: TripPurpose.schoolRun,
    title: 'Corona Schools Lekki - Daily Run',
    pickupLocation: const LocationDto(
      latitude: 6.4474,
      longitude: 3.4723,
      address: 'Block 4, Admiralty Way, Lekki Phase 1',
      label: 'Home (Lekki)',
    ),
    dropoffLocation: const LocationDto(
      latitude: 6.4380,
      longitude: 3.4780,
      address: 'Corona School, Victoria Island / Lekki',
      label: 'Corona School Main Gate',
    ),
    scheduledDays: const ['MON', 'TUE', 'WED', 'THU', 'FRI'],
    pickupTime: '07:15 AM',
    returnTime: '03:00 PM',
    passengerName: 'Zainab Adeleke',
    schoolName: 'Corona Schools Victoria Island',
    totalTrips: 20,
    usedTrips: 4,
    remainingTrips: 16,
    status: PlanStatus.active,
    startDate: DateTime.now().subtract(const Duration(days: 4)),
    expiryDate: DateTime.now().add(const Duration(days: 26)),
    handoverOtp: '849201',
    authorizedContacts: const [
      AuthorizedContactDto(
        id: 'c-01',
        name: 'Dr. Aisha Adeleke',
        relationship: 'Mother',
        phone: '+2348023456789',
        isPrimary: true,
      ),
      AuthorizedContactDto(
        id: 'c-02',
        name: 'Engr. Tunde Adeleke',
        relationship: 'Father',
        phone: '+2348039876543',
      ),
    ],
  );

  group('Scheduled Plans Unit Tests', () {
    test('validates 6-hour skip cutoff baseline policy correctly', () {
      final now = DateTime(2026, 10, 24, 8, 0); // 8:00 AM

      // Trip at 3:00 PM (7 hours away -> preserves entitlement)
      final earlyTrip = DateTime(2026, 10, 24, 15, 0);
      expect(
        testSchoolRunPlan.canSkipWithoutPenalty(earlyTrip, now: now),
        isTrue,
      );

      // Trip at 12:00 PM (4 hours away -> late skip forfeits entitlement)
      final lateTrip = DateTime(2026, 10, 24, 12, 0);
      expect(
        testSchoolRunPlan.canSkipWithoutPenalty(lateTrip, now: now),
        isFalse,
      );
    });

    test('notifier skips trip and refreshes handover OTP', () async {
      final notifier = ScheduledNotifier(repository: testScheduledRepo);
      await notifier.loadPlans();

      expect(notifier.state.plans.isNotEmpty, isTrue);
      final initialPlan = notifier.state.plans.first;
      final initialRemaining = initialPlan.remainingTrips;

      // Skip next trip 18 hours in future (preserved)
      final futureTrip = DateTime.now().add(const Duration(hours: 18));
      await notifier.skipNextTrip(initialPlan.id, futureTrip);

      final updatedPlan = notifier.state.plans.firstWhere(
        (p) => p.id == initialPlan.id,
      );
      expect(updatedPlan.remainingTrips, equals(initialRemaining));

      // Refresh handover OTP
      await notifier.refreshHandoverOtp(initialPlan.id);
      final refreshedPlan = notifier.state.plans.firstWhere(
        (p) => p.id == initialPlan.id,
      );
      expect(refreshedPlan.handoverOtp, isNotNull);
    });

    test('notifier toggles pause and resume status', () async {
      final notifier = ScheduledNotifier(repository: testScheduledRepo);
      await notifier.loadPlans();

      final plan = notifier.state.plans.first;
      expect(plan.isActive, isTrue);

      await notifier.togglePlanPause(plan);
      expect(notifier.state.selectedPlan!.isPaused, isTrue);

      await notifier.togglePlanPause(notifier.state.selectedPlan!);
      expect(notifier.state.selectedPlan!.isActive, isTrue);
    });
  });

  group('Phase 1C Scheduled Plans Widget Tests', () {
    testWidgets(
      'ScheduledPlansScreen renders plans, entitlements, and upcoming trip',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 900));

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appConfigProvider.overrideWithValue(testConfig),
              apiClientProvider.overrideWithValue(testApiClient),
              scheduledRepositoryProvider.overrideWithValue(testScheduledRepo),
            ],
            child: const MaterialApp(home: ScheduledPlansScreen()),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('Scheduled Plans'), findsOneWidget);
        expect(find.text('🎒 School Run'), findsOneWidget);
        expect(find.text('Trip Entitlements'), findsOneWidget);
        expect(find.text('Next Upcoming Trip'), findsOneWidget);
        expect(find.text('Skip Trip'), findsOneWidget);
        expect(find.text('Manage Subscription'), findsOneWidget);

        await tester.binding.setSurfaceSize(null);
      },
    );

    testWidgets(
      'SchoolRunSafetyScreen renders 6-digit OTP and authorized contacts',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(400, 1400));

        await tester.pumpWidget(
          ProviderScope(
            overrides: [
              appConfigProvider.overrideWithValue(testConfig),
              apiClientProvider.overrideWithValue(testApiClient),
              scheduledRepositoryProvider.overrideWithValue(testScheduledRepo),
            ],
            child: const MaterialApp(home: SchoolRunSafetyScreen()),
          ),
        );

        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));

        expect(find.text('School Run Safety & Handover'), findsOneWidget);
        expect(find.text('School Pickup Verification OTP'), findsOneWidget);
        expect(find.textContaining('849'), findsOneWidget);
        expect(find.text('Passenger Profile'), findsOneWidget);
        expect(find.textContaining('Zainab Adeleke'), findsOneWidget);
        expect(find.text('Authorized Guardians'), findsOneWidget);
        expect(find.textContaining('Dr. Aisha Adeleke'), findsOneWidget);
        expect(find.text('Custody & Handover Policy'), findsOneWidget);
        expect(find.text('Call Operations Safety Officer'), findsOneWidget);

        await tester.binding.setSurfaceSize(null);
      },
    );
  });
}
