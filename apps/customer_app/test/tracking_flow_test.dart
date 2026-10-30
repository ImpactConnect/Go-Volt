import 'package:api_client/api_client.dart';
import 'package:app_config/app_config.dart';
import 'package:app_models/app_models.dart';
import 'package:customer_app/src/core/providers/api_providers.dart';
import 'package:customer_app/src/features/tracking/application/tracking_notifier.dart';
import 'package:customer_app/src/features/tracking/data/tracking_repository.dart';
import 'package:customer_app/src/features/tracking/presentation/live_tracking_screen.dart';
import 'package:customer_app/src/features/tracking/presentation/trip_completed_screen.dart';
import 'package:customer_app/src/features/tracking/presentation/trip_dispute_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final testConfig = AppConfig.dev();
  final testApiClient = ApiClient(config: testConfig);
  final testTrackingRepo = TrackingRepository(apiClient: testApiClient);

  final testBooking = BookingDto(
    id: 'test-trk-01',
    bookingReference: 'GV-TRK-7788',
    serviceCode: ServiceCode.instantRide,
    status: BookingStatus.assigned,
    pickupLocation: const LocationDto(
      latitude: 6.5244,
      longitude: 3.3792,
      address: '14 Marina Street, Lagos Island',
      label: 'Marina Terminal',
    ),
    dropoffLocation: const LocationDto(
      latitude: 6.4474,
      longitude: 3.4723,
      address: 'Admiralty Way, Lekki Phase 1',
      label: 'Lekki Phase 1',
    ),
    priceBreakdown: const PriceBreakdownDto(
      baseFare: 500.0,
      distanceFare: 1200.0,
      timeFare: 300.0,
      totalFare: 2200.0,
    ),
    createdAt: DateTime.now(),
    riderId: 'rider-01',
    riderName: 'Babatunde Raji',
    riderPhone: '+2348039281742',
    riderRating: 4.9,
    vehicleType: VehicleType.electricBike,
    vehiclePlate: 'LAG-428-EV',
    vehicleModel: 'Volt-Bike 200 EV',
  );

  group('LiveTrackingNotifier Unit Tests', () {
    test('initializes and advances status through ride lifecycle', () {
      final notifier = LiveTrackingNotifier(
        repository: testTrackingRepo,
        initialBooking: testBooking,
      );

      expect(notifier.state, isNotNull);
      expect(notifier.state!.status, equals(BookingStatus.assigned));
      expect(notifier.state!.etaMinutes, equals(3));

      // Advance to Arrived
      notifier.advanceTripStatus(BookingStatus.arrivedAtPickup);
      expect(notifier.state!.status, equals(BookingStatus.arrivedAtPickup));
      expect(notifier.state!.etaMinutes, equals(0));

      // Advance to In Transit
      notifier.advanceTripStatus(BookingStatus.inProgress);
      expect(notifier.state!.status, equals(BookingStatus.inProgress));
      expect(notifier.state!.etaMinutes, equals(18));
      expect(notifier.state!.distanceKm, equals(7.4));

      // Advance to Completed
      notifier.advanceTripStatus(BookingStatus.completed);
      expect(notifier.state!.status, equals(BookingStatus.completed));
      expect(notifier.state!.booking.paymentStatus, equals(PaymentStatus.captured));
    });

    test('toggles audio recording and emergency alert for safety', () {
      final notifier = LiveTrackingNotifier(
        repository: testTrackingRepo,
        initialBooking: testBooking,
      );

      expect(notifier.state!.isAudioRecording, isFalse);
      notifier.toggleAudioRecording();
      expect(notifier.state!.isAudioRecording, isTrue);

      notifier.triggerEmergencyAlert();
      expect(notifier.state!.isEmergencyActive, isTrue);
      expect(notifier.state!.isAudioRecording, isTrue);

      notifier.dismissEmergencyAlert();
      expect(notifier.state!.isEmergencyActive, isFalse);
    });

    test('sets post-trip rating and driver tip', () {
      final notifier = LiveTrackingNotifier(
        repository: testTrackingRepo,
        initialBooking: testBooking,
      );

      notifier.setTripRating(5.0, tipKobo: 50000, feedback: 'Great ride!');
      expect(notifier.state!.rating, equals(5.0));
      expect(notifier.state!.tipAmountKobo, equals(50000));
      expect(notifier.state!.feedbackText, equals('Great ride!'));
    });
  });

  group('Phase 1C Tracking Widget Tests', () {
    testWidgets('LiveTrackingScreen renders driver card, EV stats, and progress timeline',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 900));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(testConfig),
            apiClientProvider.overrideWithValue(testApiClient),
            trackingRepositoryProvider.overrideWithValue(testTrackingRepo),
          ],
          child: const MaterialApp(
            home: LiveTrackingScreen(),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Check top title and driver details
      expect(find.text('Live Trip Tracking'), findsOneWidget);
      expect(find.text('Babatunde Raji'), findsWidgets);
      expect(find.textContaining('LAG-428-EV'), findsWidgets);
      expect(find.text('Trip Progress'), findsOneWidget);
      expect(find.text('Driver Assigned'), findsOneWidget);
      expect(find.text('Pickup Spot'), findsOneWidget);

      // Reset surface size
      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('TripCompletedScreen displays carbon avoided, receipt, and rating controls',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 900));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(testConfig),
            apiClientProvider.overrideWithValue(testApiClient),
            trackingRepositoryProvider.overrideWithValue(testTrackingRepo),
          ],
          child: const MaterialApp(
            home: TripCompletedScreen(),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('You Have Arrived!'), findsOneWidget);
      expect(find.textContaining('1.4 kg CO₂ Avoided'), findsOneWidget);
      expect(find.text('Total Fare Paid'), findsOneWidget);
      expect(find.text('₦2200'), findsOneWidget);
      expect(find.text('Rate Babatunde Raji'), findsOneWidget);
      expect(find.text('Add a Tip for Driver'), findsOneWidget);
      expect(find.text('Complete & Return Home'), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('TripDisputeScreen allows category selection and filing ticket',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(400, 900));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(testConfig),
            apiClientProvider.overrideWithValue(testApiClient),
            trackingRepositoryProvider.overrideWithValue(testTrackingRepo),
          ],
          child: const MaterialApp(
            home: TripDisputeScreen(),
          ),
        ),
      );

      await tester.pump();

      expect(find.text('Report Trip Issue'), findsOneWidget);
      expect(find.text('Select Issue Category'), findsOneWidget);
      expect(find.text('Fare Discrepancy'), findsWidgets);
      expect(find.text('Submit Dispute Ticket'), findsOneWidget);

      // Enter issue description
      await tester.enterText(
        find.byType(TextField),
        'Driver took a longer alternate route causing additional waiting time.',
      );
      await tester.pump();

      // Tap submit
      await tester.tap(find.text('Submit Dispute Ticket'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Ticket Submitted'), findsOneWidget);
      expect(find.textContaining('CASE-'), findsOneWidget);

      await tester.binding.setSurfaceSize(null);
    });
  });
}
