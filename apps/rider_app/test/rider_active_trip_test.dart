import 'package:api_client/api_client.dart';
import 'package:app_config/app_config.dart';
import 'package:app_models/app_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rider_app/src/core/providers/api_providers.dart';
import 'package:rider_app/src/features/trip/application/active_trip_notifier.dart';
import 'package:rider_app/src/features/trip/data/trip_repository.dart';
import 'package:rider_app/src/features/trip/domain/active_trip_state.dart';
import 'package:rider_app/src/features/trip/presentation/active_trip_screen.dart';
import 'package:rider_app/src/features/trip/presentation/otp_verification_screen.dart';
import 'package:rider_app/src/features/trip/presentation/proof_of_delivery_screen.dart';
import 'package:rider_app/src/features/trip/presentation/trip_completion_screen.dart';
import 'package:rider_app/src/features/trip/presentation/widgets/delivery_exception_dialog.dart';

void main() {
  final testConfig = AppConfig.dev();
  final testApiClient = ApiClient(config: testConfig);
  final testTripRepo = TripRepository(apiClient: testApiClient);

  final sampleParcelJob = DispatchOfferDto(
    id: 'OFFER-TRP-01',
    jobId: 'JOB-TRP-01',
    serviceType: ServiceTierEligibility.parcelDelivery,
    customerName: 'Chidinma Okafor',
    grossFareKobo: 300000, // ₦3,000
    netEarningsKobo: 240000, // ₦2,400 net
    pickupAddress: 'Plot 14 Admiralty Way, Lekki',
    pickupDistanceKm: 1.2,
    pickupEtaMinutes: 4,
    dropoffAddress: 'Ahmadu Bello Way, Victoria Island',
    tripDistanceKm: 6.8,
    estimatedTripMinutes: 18,
    paymentMethod: 'Wallet',
    expiresAt: DateTime.now().add(const Duration(seconds: 15)),
    parcelDescription: 'Express Legal Contract',
    packageWeightKg: 1.0,
    isFragile: true,
  );

  final sampleSchoolRunJob = DispatchOfferDto(
    id: 'OFFER-SCH-02',
    jobId: 'JOB-SCH-02',
    serviceType: ServiceTierEligibility.schoolRunCommute,
    customerName: 'Mrs. Folake Adeleke',
    grossFareKobo: 400000,
    netEarningsKobo: 320000,
    pickupAddress: 'Corona School, VI',
    pickupDistanceKm: 0.8,
    pickupEtaMinutes: 3,
    dropoffAddress: 'Parkview Estate, Ikoyi',
    tripDistanceKm: 5.5,
    estimatedTripMinutes: 16,
    expiresAt: DateTime.now().add(const Duration(seconds: 15)),
    childName: 'Amina Adeleke',
    schoolName: 'Corona School VI',
    requiresOtp: true,
  );

  group('Phase 2C Unit & Domain Tests: Active Trip & Verification', () {
    test('ActiveTripState detects speeding against geofenced speed limit', () {
      final safeState = ActiveTripState(
        job: sampleParcelJob,
        speedKmh: 38.0,
        speedLimitKmh: 45.0,
      );
      expect(safeState.isSpeeding, isFalse);

      final speedingState = ActiveTripState(
        job: sampleParcelJob,
        speedKmh: 52.0,
        speedLimitKmh: 45.0,
      );
      expect(speedingState.isSpeeding, isTrue);
    });

    test('FareSettlementDto calculates 80% net and 100% tip pass-through correctly', () {
      final settlement = FareSettlementDto.fromGrossAndTip(
        grossKobo: 300000, // ₦3,000 gross
        tipKobo: 50000, // ₦500 tip
        paymentMethod: 'Wallet',
      );

      expect(settlement.grossFareNaira, 3000.0);
      expect(settlement.commissionNaira, 600.0); // 20%
      expect(settlement.netEarningsNaira, 2400.0); // 80%
      expect(settlement.tipNaira, 500.0);
      expect(settlement.totalCreditNaira, 2900.0); // 2400 + 500
    });

    test('ActiveTripNotifier progresses through complete milestone lifecycle', () async {
      final notifier = ActiveTripNotifier(
        job: sampleParcelJob,
        tripRepository: testTripRepo,
      );

      expect(notifier.state.milestone, TripMilestone.approachingPickup);

      // Milestone 1: Arrive at Pickup
      await notifier.markArrivedAtPickup();
      expect(notifier.state.milestone, TripMilestone.arrivedAtPickup);
      expect(notifier.state.distanceRemainingKm, 0.0);

      // Milestone 2: Verify Handover OTP
      final otpPassed = await notifier.verifyOtp('1234');
      expect(otpPassed, isTrue);
      expect(notifier.state.milestone, TripMilestone.otpVerified);

      // Milestone 3: Start In-Transit
      await notifier.startTransit();
      expect(notifier.state.milestone, TripMilestone.inTransit);
      expect(notifier.state.distanceRemainingKm, 6.8);

      // Milestone 4: Arrive at Dropoff Destination
      await notifier.markArrivedAtDestination();
      expect(notifier.state.milestone, TripMilestone.arrivedAtDestination);

      // Milestone 5: Submit Proof of Delivery
      final podSuccess = await notifier.submitProofOfDelivery(
        photoUrl: 'https://test.com/photo.jpg',
        recipientName: 'Chidinma Okafor',
        signature: 'SIG-CHIDINMA',
      );
      expect(podSuccess, isTrue);
      expect(notifier.state.milestone, TripMilestone.proofSubmitted);

      // Milestone 6: Complete Trip & Settle
      await notifier.completeTrip(tipKobo: 50000);
      expect(notifier.state.milestone, TripMilestone.completed);
      expect(notifier.state.settlement, isNotNull);
      expect(notifier.state.settlement!.totalCreditNaira, 2900.0);
    });

    test('ActiveTripNotifier enforces 3-attempt OTP limit and locks out', () async {
      final notifier = ActiveTripNotifier(
        job: sampleParcelJob,
        tripRepository: testTripRepo,
      );

      // Fail 1
      var ok = await notifier.verifyOtp('9999');
      expect(ok, isFalse);
      expect(notifier.state.otpAttemptsRemaining, 2);
      expect(notifier.state.otpError, contains('2 attempts remaining'));

      // Fail 2
      ok = await notifier.verifyOtp('8888');
      expect(ok, isFalse);
      expect(notifier.state.otpAttemptsRemaining, 1);
      expect(notifier.state.otpError, contains('1 attempt remaining'));

      // Fail 3 -> Lock out
      ok = await notifier.verifyOtp('7777');
      expect(ok, isFalse);
      expect(notifier.state.otpAttemptsRemaining, 0);
      expect(notifier.state.otpError, contains('Maximum OTP attempts exceeded'));

      // Subsequent attempt blocked
      ok = await notifier.verifyOtp('1234');
      expect(ok, isFalse);
    });

    test('ActiveTripNotifier reports delivery exception', () async {
      final notifier = ActiveTripNotifier(
        job: sampleParcelJob,
        tripRepository: testTripRepo,
      );

      await notifier.reportException('Severe Traffic Gridlock', notes: 'Expressway blocked');
      expect(notifier.state.exceptionReported, 'Severe Traffic Gridlock');
    });
  });

  group('Phase 2C Widget & Presentation Tests', () {
    testWidgets('ActiveTripScreen renders telematics HUD, map canvas, and waypoint action',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 1200));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(testConfig),
            apiClientProvider.overrideWithValue(testApiClient),
            tripRepositoryProvider.overrideWithValue(testTripRepo),
          ],
          child: MaterialApp(
            home: ActiveTripScreen(job: sampleParcelJob),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Heading to Pickup'), findsOneWidget);
      expect(find.textContaining('km/h'), findsOneWidget);
      expect(find.textContaining('92% EV Battery'), findsOneWidget);
      expect(find.text('GPS TURN-BY-TURN ACTIVE'), findsOneWidget);
      expect(find.text('I Have Arrived at Pickup'), findsOneWidget);
      expect(find.text('Pickup Location'), findsOneWidget);
      expect(find.text('Plot 14 Admiralty Way, Lekki'), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('OtpVerificationScreen renders 6-digit School-Run parental security',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 1200));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(testConfig),
            apiClientProvider.overrideWithValue(testApiClient),
            tripRepositoryProvider.overrideWithValue(testTripRepo),
          ],
          child: MaterialApp(
            home: OtpVerificationScreen(job: sampleSchoolRunJob),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Verify Handover OTP'), findsOneWidget);
      expect(find.text('Guardian Handover OTP'), findsOneWidget);
      expect(find.textContaining('Amina Adeleke'), findsOneWidget);
      expect(find.text('Verify & Confirm Handover'), findsOneWidget);

      // Enter valid 6-digit PIN
      await tester.enterText(find.byType(TextField), '123456');
      await tester.pump();

      await tester.tap(find.text('Verify & Confirm Handover'));
      await tester.pumpAndSettle();

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('ProofOfDeliveryScreen renders photo capture and signature acknowledgment',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 1200));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(testConfig),
            apiClientProvider.overrideWithValue(testApiClient),
            tripRepositoryProvider.overrideWithValue(testTripRepo),
          ],
          child: MaterialApp(
            home: ProofOfDeliveryScreen(job: sampleParcelJob),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Proof of Delivery'), findsOneWidget);
      expect(find.text('Capture Delivery Evidence'), findsOneWidget);
      expect(find.text('Recipient Full Legal Name *'), findsOneWidget);
      expect(find.text('Digital Handover Confirmation'), findsOneWidget);
      expect(find.text('Confirm Delivery & Proceed'), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('TripCompletionScreen renders itemized financial ledger and rating',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 1400));

      final settlement = FareSettlementDto.fromGrossAndTip(
        grossKobo: 320000,
        tipKobo: 50000,
        paymentMethod: 'Wallet',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: TripCompletionScreen(settlement: settlement),
        ),
      );

      await tester.pump();

      expect(find.text('Trip Completed & Settled!'), findsOneWidget);
      expect(find.text('TOTAL EARNINGS CREDITED'), findsOneWidget);
      expect(find.text('₦3060'), findsOneWidget);
      expect(find.text('Customer Gross Fare'), findsOneWidget);
      expect(find.text('₦3200'), findsOneWidget);
      expect(find.text('Platform Commission (20%)'), findsOneWidget);
      expect(find.text('- ₦640'), findsOneWidget);
      expect(find.text('Rider Base Take-Home (80%)'), findsOneWidget);
      expect(find.text('₦2560'), findsOneWidget);
      expect(find.text('Customer Tip (100% to you)'), findsOneWidget);
      expect(find.text('+ ₦500'), findsOneWidget);
      expect(find.text('Rate Customer Experience'), findsOneWidget);
      expect(find.text('Return to Shift Dashboard'), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('DeliveryExceptionDialog selects exception and submits callback',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 1000));

      String? submittedReason;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeliveryExceptionDialog(
              onReport: (reason, notes) => submittedReason = reason,
            ),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Report Delivery Exception'), findsOneWidget);
      expect(find.text('Recipient Unreachable / Phone Switched Off'), findsOneWidget);
      expect(find.text('Severe Traffic Gridlock / Road Blockade'), findsOneWidget);

      await tester.tap(find.text('Severe Traffic Gridlock / Road Blockade'));
      await tester.pump();

      await tester.tap(find.text('Submit Report'));
      await tester.pump();

      expect(submittedReason, 'Severe Traffic Gridlock / Road Blockade');

      await tester.binding.setSurfaceSize(null);
    });
  });
}
