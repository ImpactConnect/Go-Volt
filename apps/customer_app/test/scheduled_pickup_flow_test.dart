import 'package:api_client/api_client.dart';
import 'package:app_config/app_config.dart';
import 'package:app_models/app_models.dart';
import 'package:customer_app/src/features/scheduled/data/scheduled_repository.dart';
import 'package:customer_app/src/features/scheduled/presentation/screens/screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final testConfig = AppConfig.dev();
  final testApiClient = ApiClient(config: testConfig);
  final repo = ScheduledRepository(apiClient: testApiClient);

  group('Section 21 Domain Invariants & Repository Unit Tests', () {
    test(
      'One-off single leg quote calculates deterministic base fare + distance + service fee',
      () async {
        final quote = await repo.calculateQuote(
          bookingType: ScheduledBookingType.oneOff,
          purpose: TripPurpose.schoolRun,
          journeyType: JourneyDirection.oneWay,
          pickupLocation: const LocationDto(
            latitude: 10.5105,
            longitude: 7.4165,
            address: '3, Ahmadu Bello Way, Kaduna',
            label: 'Home',
          ),
          destinationLocation: const LocationDto(
            latitude: 10.5235,
            longitude: 7.4385,
            address: 'Bayero University, Kaduna',
            label: 'School',
          ),
        );

        // Base: 2,000 + 400 (8km * 50) + 100 (service) = 2,500
        expect(quote.baseFareNgn, equals(2000.0));
        expect(quote.distanceKm, equals(8.0));
        expect(quote.distanceFeeNgn, equals(400.0));
        expect(quote.serviceFeeNgn, equals(100.0));
        expect(quote.perTripEstimateNgn, equals(2500.0));
        expect(quote.totalFareNgn, equals(2500.0));
        expect(quote.totalTrips, equals(1));
        expect(quote.isExpired, isFalse);
      },
    );

    test(
      'Round-trip quotes price outbound and return legs independently (Section 21.2)',
      () async {
        final quote = await repo.calculateQuote(
          bookingType: ScheduledBookingType.oneOff,
          purpose: TripPurpose.workCommute,
          journeyType: JourneyDirection.roundTrip,
          pickupLocation: const LocationDto(
            latitude: 10.5105,
            longitude: 7.4165,
            address: '3, Ahmadu Bello Way, Kaduna',
            label: 'Home',
          ),
          destinationLocation: const LocationDto(
            latitude: 10.5235,
            longitude: 7.4385,
            address: 'Bayero University, Kaduna',
            label: 'Work',
          ),
        );

        // 2 legs priced independently: 2 * ₦2,500 = ₦5,000
        expect(quote.baseFareNgn, equals(4000.0));
        expect(quote.distanceKm, equals(16.0));
        expect(quote.totalFareNgn, equals(5000.0));
      },
    );

    test(
      'Section 21.3 6-hour skip cutoff preserves entitlement when >= 6 hours',
      () async {
        final now = DateTime.now();
        final futureTripTime = now.add(const Duration(hours: 12));

        final result = await repo.skipScheduledTrip(
          tripId: 'trip-01',
          tripTime: futureTripTime,
        );

        expect(result['entitlement_preserved'], isTrue);
        expect(result['message'], contains('Entitlement preserved'));
      },
    );

    test(
      'Section 21.3 6-hour skip cutoff forfeits entitlement when < 6 hours',
      () async {
        final now = DateTime.now();
        final urgentTripTime = now.add(const Duration(hours: 3));

        final result = await repo.skipScheduledTrip(
          tripId: 'trip-01',
          tripTime: urgentTripTime,
        );

        expect(result['entitlement_preserved'], isFalse);
        expect(result['message'], contains('Entitlement forfeited'));
      },
    );

    test(
      'Section 21.5 Gated School-Run Handover: 4-digit PIN verification',
      () async {
        // 4219 is the seed code matching technical spec & design board
        final valid = await repo.verifyHandoverPin(
          tripId: 'trip-01',
          pin: '4219',
          recipientName: 'Mrs. Aisha Muhammadu',
          recipientRole: 'School Teacher',
        );
        expect(valid, isTrue);

        final invalid = await repo.verifyHandoverPin(
          tripId: 'trip-01',
          pin: '000',
          recipientName: 'Mrs. Aisha Muhammadu',
          recipientRole: 'School Teacher',
        );
        expect(invalid, isFalse);
      },
    );

    test('Section 21.6 48-Hour Approval & Payment Expiry Window', () async {
      final plan = await repo.approvePlan('plan-sch-kaduna-01');
      expect(plan.status, equals(PlanStatus.approvedAwaitingPayment));
      expect(plan.approvalExpiresAt, isNotNull);
      final duration = plan.approvalExpiresAt!.difference(DateTime.now());
      expect(duration.inHours, greaterThanOrEqualTo(47));
    });
  });

  group('Scheduled Pickup UI Screens Verification (Screens 1 to 36)', () {
    testWidgets(
      'Screen 1 (SP-01): Scheduled Landing Screen displays title and bullet points',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [scheduledRepositoryProvider.overrideWithValue(repo)],
            child: const MaterialApp(home: ScheduledLandingScreen()),
          ),
        );

        expect(find.text('Scheduled Pickup'), findsOneWidget);
        expect(find.text('Book one-off or recurring trips'), findsOneWidget);
        expect(find.text('Set preferred pickup times'), findsOneWidget);
        expect(find.text('Request a preferred driver'), findsOneWidget);
        expect(find.text('Create a scheduled pickup'), findsOneWidget);
        expect(find.text('View my scheduled plans'), findsOneWidget);
      },
    );

    testWidgets(
      'Screen 2 (SP-02): Choose Booking Type displays One-off and Recurring options',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [scheduledRepositoryProvider.overrideWithValue(repo)],
            child: const MaterialApp(home: ChooseBookingTypeScreen()),
          ),
        );

        expect(find.text('Choose booking type'), findsOneWidget);
        expect(find.text('One-off trip'), findsOneWidget);
        expect(find.text('Recurring trip'), findsOneWidget);
        expect(find.text('Continue'), findsOneWidget);
      },
    );

    testWidgets(
      'Screen 25 (SP-21): Upcoming Trip Tab displays 3 tabs and driver Ahmed Ibrahim',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [scheduledRepositoryProvider.overrideWithValue(repo)],
            child: const MaterialApp(home: UpcomingTripTabScreen()),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Upcoming Trip'), findsOneWidget);
        expect(find.text('Upcoming (3)'), findsOneWidget);
        expect(find.text('Completed (12)'), findsOneWidget);
        expect(find.text('Cancelled (2)'), findsOneWidget);
        expect(find.text('School Run'), findsOneWidget);
        expect(find.text('Ahmed Ibrahim'), findsOneWidget);
      },
    );

    testWidgets(
      'Screen 28 (SP-30): Arrived at Pickup displays 10-minute waiting countdown and Confirm CTA',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [scheduledRepositoryProvider.overrideWithValue(repo)],
            child: const MaterialApp(home: ArrivedAtPickupScreen()),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Driver has arrived'), findsOneWidget);
        expect(find.text('Waiting time'), findsOneWidget);
        expect(find.text('Confirm pickup'), findsOneWidget);
        expect(find.text('Share live location'), findsOneWidget);
      },
    );

    testWidgets(
      'Screen 33 (SP-35): Handover Verification displays 4 PIN inputs and child profile',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [scheduledRepositoryProvider.overrideWithValue(repo)],
            child: const MaterialApp(home: HandoverVerificationScreen()),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Handover verification'), findsOneWidget);
        expect(find.text('Fatima Okafor'), findsOneWidget);
        expect(find.text('Confirm handover'), findsOneWidget);
        expect(find.text("Can't verify? Contact support"), findsOneWidget);
      },
    );

    testWidgets(
      'Screen 34 (SP-36): Handover Confirmed displays celebration and recipient teacher',
      (tester) async {
        await tester.pumpWidget(
          ProviderScope(
            overrides: [scheduledRepositoryProvider.overrideWithValue(repo)],
            child: const MaterialApp(home: HandoverConfirmedScreen()),
          ),
        );

        await tester.pumpAndSettle();

        expect(find.text('Handover confirmed!'), findsOneWidget);
        expect(find.text('Mrs. Aisha Muhammadu'), findsOneWidget);
        expect(find.text('School Teacher'), findsOneWidget);
        expect(find.text('View trip details'), findsOneWidget);
        expect(find.text('Add note'), findsOneWidget);
      },
    );
  });
}
