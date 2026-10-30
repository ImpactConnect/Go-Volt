import 'package:api_client/api_client.dart';
import 'package:app_config/app_config.dart';
import 'package:app_models/app_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rider_app/src/core/providers/api_providers.dart';
import 'package:rider_app/src/features/onboarding/data/rider_repository.dart';
import 'package:rider_app/src/features/shift/application/shift_notifier.dart';
import 'package:rider_app/src/features/shift/domain/shift_state.dart';
import 'package:rider_app/src/features/shift/presentation/rider_home_screen.dart';
import 'package:rider_app/src/features/shift/presentation/widgets/decline_reason_dialog.dart';
import 'package:rider_app/src/features/shift/presentation/widgets/dispatch_offer_modal.dart';

void main() {
  final testConfig = AppConfig.dev();
  final testApiClient = ApiClient(config: testConfig);
  final testRiderRepo = RiderRepository(apiClient: testApiClient);

  group('Phase 2B Unit & State Tests: Shift & Dispatch Offer', () {
    test('ShiftState enforces battery guard and document validity', () {
      // Normal state with 94% battery
      const normalState = ShiftState(
        batteryLevel: 94,
        isOnline: false,
      );
      expect(normalState.canGoOnline, isTrue);

      // Low battery state (< 15%)
      const lowBatteryState = ShiftState(
        batteryLevel: 12,
        isOnline: false,
      );
      expect(lowBatteryState.canGoOnline, isFalse);

      // Rider with expired document
      final expiredDocRider = RiderDto(
        id: 'R1',
        profileId: 'U1',
        fullName: 'Test Rider',
        phoneNumber: '+2348011223344',
        vehiclePlate: 'LA-123-AB',
        vehicleModel: 'Spiro EV',
        batteryLevelPercent: 88,
        documents: [
          RiderDocumentDto(
            id: 'D1',
            type: DocumentType.driversLicense,
            documentNumber: 'DL-999',
            fileUrl: 'http://test.com/dl.jpg',
            expiryDate: DateTime.now().subtract(const Duration(days: 10)),
            status: DocumentVerificationStatus.approved,
          ),
        ],
      );
      final invalidDocState = ShiftState(
        rider: expiredDocRider,
        batteryLevel: 88,
      );
      expect(invalidDocState.canGoOnline, isFalse);
    });

    test('ShiftNotifier blocks going online when battery is below threshold', () async {
      final notifier = ShiftNotifier(riderRepository: testRiderRepo);
      notifier.updateBatteryLevel(10);

      final success = await notifier.toggleAvailability();
      expect(success, isFalse);
      expect(notifier.state.isOnline, isFalse);
      expect(notifier.state.errorMessage, contains('Battery critically low'));
    });

    test('ShiftNotifier updates service tier and forces offline on battery drop', () async {
      final notifier = ShiftNotifier(riderRepository: testRiderRepo);
      notifier.updateBatteryLevel(80);

      notifier.setServiceTier(ServiceTierEligibility.schoolRunCommute);
      expect(notifier.state.activeTier, ServiceTierEligibility.schoolRunCommute);

      // Simulate being online then battery dropping to 8%
      notifier.state = notifier.state.copyWith(isOnline: true);
      notifier.updateBatteryLevel(8);

      expect(notifier.state.isOnline, isFalse);
      expect(notifier.state.errorMessage, contains('critical threshold (8%)'));
    });

    test('ShiftNotifier handles dispatch offer acceptance and active job assignment', () async {
      final notifier = ShiftNotifier(riderRepository: testRiderRepo);
      notifier.updateBatteryLevel(90);

      final sampleOffer = DispatchOfferDto(
        id: 'OFFER-TST-01',
        jobId: 'JOB-TST-01',
        serviceType: ServiceTierEligibility.parcelDelivery,
        customerName: 'Amina Bello',
        grossFareKobo: 250000,
        netEarningsKobo: 200000,
        pickupAddress: 'Admiralty Way, Lekki',
        pickupDistanceKm: 1.5,
        pickupEtaMinutes: 5,
        dropoffAddress: 'Adeola Odeku, VI',
        tripDistanceKm: 5.0,
        estimatedTripMinutes: 15,
        expiresAt: DateTime.now().add(const Duration(seconds: 15)),
      );

      await notifier.triggerIncomingOffer(customOffer: sampleOffer);
      expect(notifier.state.currentOffer, isNotNull);
      expect(notifier.state.currentOffer!.id, 'OFFER-TST-01');

      final accepted = await notifier.acceptOffer();
      expect(accepted, isTrue);
      expect(notifier.state.currentOffer, isNull);
      expect(notifier.state.activeJob, isNotNull);
      expect(notifier.state.activeJob!.id, 'OFFER-TST-01');
      expect(notifier.state.activeJob!.status, DispatchOfferStatus.accepted);
    });

    test('ShiftNotifier handles decline with structured telemetry reason', () async {
      final notifier = ShiftNotifier(riderRepository: testRiderRepo);

      final sampleOffer = DispatchOfferDto(
        id: 'OFFER-DEC-01',
        jobId: 'JOB-DEC-01',
        serviceType: ServiceTierEligibility.passengerRide,
        customerName: 'Emeka Eze',
        grossFareKobo: 200000,
        netEarningsKobo: 160000,
        pickupAddress: 'Obalende Bus Stop',
        pickupDistanceKm: 3.2,
        pickupEtaMinutes: 10,
        dropoffAddress: 'Marina, Lagos Island',
        tripDistanceKm: 4.0,
        estimatedTripMinutes: 12,
        expiresAt: DateTime.now().add(const Duration(seconds: 15)),
      );

      await notifier.triggerIncomingOffer(customOffer: sampleOffer);
      expect(notifier.state.currentOffer, isNotNull);

      await notifier.declineOffer(
        DispatchDeclineReason.distanceTooFar,
        note: 'Too far during peak rain',
      );

      expect(notifier.state.currentOffer, isNull);
      expect(notifier.state.activeJob, isNull);
    });
  });

  group('Phase 2B Widget & Presentation Tests', () {
    testWidgets('RiderHomeScreen renders master switch, battery, metrics and heatmap',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 1600));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(testConfig),
            apiClientProvider.overrideWithValue(testApiClient),
            riderRepositoryProvider.overrideWithValue(testRiderRepo),
          ],
          child: const MaterialApp(
            home: RiderHomeScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Rider Dashboard'), findsOneWidget);
      expect(find.textContaining('YOU ARE'), findsOneWidget);
      expect(find.text('Active Dispatch Mode'), findsOneWidget);
      expect(find.text('Parcel & Cargo Delivery'), findsOneWidget);
      expect(find.text('Passenger EV Commute'), findsOneWidget);
      expect(find.text('School-Run Dedicated Chaperone'), findsOneWidget);
      expect(find.text('Lagos Fleet Demand Heatmap'), findsOneWidget);
      expect(find.text('1.3x High Surge'), findsOneWidget);
      expect(find.text("Today's Shift Performance"), findsOneWidget);
      expect(find.text('Net Earnings'), findsOneWidget);
      expect(find.text('Completed Trips'), findsOneWidget);
      expect(find.text('Locate Nearest Battery Swap Station'), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('DispatchOfferModal renders net earnings, waypoints, countdown and actions',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 1200));

      final testOffer = DispatchOfferDto(
        id: 'OFFER-TEST-88',
        jobId: 'JOB-88',
        serviceType: ServiceTierEligibility.parcelDelivery,
        customerName: 'Folake Kuti',
        grossFareKobo: 300000, // ₦3,000
        netEarningsKobo: 240000, // ₦2,400 net
        pickupAddress: '15 Admiralty Way, Lekki',
        pickupDistanceKm: 1.2,
        pickupEtaMinutes: 4,
        dropoffAddress: 'Ahmadu Bello Way, VI',
        tripDistanceKm: 6.5,
        estimatedTripMinutes: 18,
        expiresAt: DateTime.now().add(const Duration(seconds: 15)),
        timeoutSeconds: 15,
        surgeMultiplier: 1.2,
        parcelDescription: 'Important Business Documents',
        packageWeightKg: 1.2,
        isFragile: true,
      );

      var accepted = false;
      var declined = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DispatchOfferModal(
              offer: testOffer,
              onAccept: () => accepted = true,
              onDecline: () => declined = true,
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('PARCEL & CARGO DELIVERY'), findsOneWidget);
      expect(find.text('⚡ 1.2x Surge'), findsOneWidget);
      expect(find.text('YOUR TAKE-HOME (80%)'), findsOneWidget);
      expect(find.text('₦2400 net'), findsOneWidget);
      expect(find.text('Gross: ₦3000'), findsOneWidget);
      expect(find.text('Fee: ₦600 (20%)'), findsOneWidget);
      expect(find.textContaining('Admiralty Way, Lekki'), findsOneWidget);
      expect(find.textContaining('Ahmadu Bello Way, VI'), findsOneWidget);
      expect(find.text('Accept Offer'), findsOneWidget);
      expect(find.text('Decline'), findsOneWidget);

      await tester.tap(find.text('Accept Offer'));
      expect(accepted, isTrue);

      await tester.tap(find.text('Decline'));
      expect(declined, isTrue);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('DeclineReasonDialog selects reason and triggers confirm callback',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 1000));

      DispatchDeclineReason? confirmedReason;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeclineReasonDialog(
              onConfirm: (reason, note) => confirmedReason = reason,
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Decline Dispatch Offer'), findsOneWidget);
      expect(find.text(DispatchDeclineReason.batteryLow.label), findsOneWidget);
      expect(find.text(DispatchDeclineReason.distanceTooFar.label), findsOneWidget);
      expect(find.text(DispatchDeclineReason.trafficCongestion.label), findsOneWidget);

      // Select battery low option
      await tester.tap(find.text(DispatchDeclineReason.batteryLow.label));
      await tester.pump();

      await tester.tap(find.text('Confirm'));
      await tester.pump();

      expect(confirmedReason, DispatchDeclineReason.batteryLow);

      await tester.binding.setSurfaceSize(null);
    });
  });
}
