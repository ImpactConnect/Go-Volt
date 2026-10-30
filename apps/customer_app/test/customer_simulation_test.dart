import 'package:api_client/api_client.dart';
import 'package:app_config/app_config.dart';
import 'package:app_models/app_models.dart';
import 'package:customer_app/src/core/providers/api_providers.dart';
import 'package:customer_app/src/features/account/presentation/edit_profile_screen.dart';
import 'package:customer_app/src/features/account/presentation/saved_places_screen.dart';
import 'package:customer_app/src/features/account/presentation/support_screen.dart';
import 'package:customer_app/src/features/booking/application/booking_notifier.dart';
import 'package:customer_app/src/features/booking/data/booking_repository.dart';
import 'package:customer_app/src/features/booking/presentation/finding_driver_screen.dart';
import 'package:customer_app/src/features/booking/presentation/package_details_screen.dart';
import 'package:customer_app/src/features/booking/presentation/ride_booking_screen.dart';
import 'package:customer_app/src/features/booking/presentation/scheduled_booking_screen.dart';
import 'package:customer_app/src/features/home/presentation/notifications_screen.dart';
import 'package:customer_app/src/features/scheduled/application/scheduled_notifier.dart';
import 'package:customer_app/src/features/scheduled/data/scheduled_repository.dart';
import 'package:customer_app/src/features/scheduled/presentation/plan_modification_screen.dart';
import 'package:customer_app/src/features/scheduled/presentation/scheduled_plans_screen.dart';
import 'package:customer_app/src/features/scheduled/presentation/school_run_safety_screen.dart';
import 'package:customer_app/src/features/tracking/application/tracking_notifier.dart';
import 'package:customer_app/src/features/tracking/data/tracking_repository.dart';
import 'package:customer_app/src/features/tracking/presentation/live_tracking_screen.dart';
import 'package:customer_app/src/features/tracking/presentation/receipt_screen.dart';
import 'package:customer_app/src/features/tracking/presentation/trip_completed_screen.dart';
import 'package:customer_app/src/features/wallet/application/wallet_notifier.dart';
import 'package:customer_app/src/features/wallet/data/wallet_repository.dart';
import 'package:customer_app/src/features/wallet/presentation/rewards_screen.dart';
import 'package:customer_app/src/features/wallet/presentation/top_up_screen.dart';
import 'package:customer_app/src/features/wallet/presentation/wallet_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testing_support/testing_support.dart';

class _SimulatedBookingRepository implements BookingRepository {
  _SimulatedBookingRepository({
    this.quoteToReturn,
    this.bookingToReturn,
  });

  final QuoteDto? quoteToReturn;
  final BookingDto? bookingToReturn;

  ServiceCode? lastRequestedServiceCode;
  PackageCategory? lastPackageCategory;
  String? lastRecipientName;
  String? lastRecipientPhone;
  String? lastInstructions;
  PaymentMethod? lastPaymentMethod;

  @override
  Future<QuoteDto> requestQuote({
    required ServiceCode serviceCode,
    required LocationDto pickup,
    required LocationDto dropoff,
    DateTime? scheduledTime,
    PackageCategory? packageCategory,
  }) async {
    lastRequestedServiceCode = serviceCode;
    lastPackageCategory = packageCategory;
    return quoteToReturn ?? TestFixtures.quote;
  }

  @override
  Future<BookingDto> createBooking({
    required String quoteId,
    required PaymentMethod paymentMethod,
    String? instructions,
    String? recipientName,
    String? recipientPhone,
  }) async {
    lastPaymentMethod = paymentMethod;
    lastInstructions = instructions;
    lastRecipientName = recipientName;
    lastRecipientPhone = recipientPhone;
    return bookingToReturn ?? TestFixtures.booking;
  }

  @override
  Future<BookingDto> getBooking(String bookingId) async {
    return bookingToReturn ?? TestFixtures.booking;
  }

  @override
  Future<BookingDto> cancelBooking(String bookingId, {required String reason}) async {
    final base = bookingToReturn ?? TestFixtures.booking;
    return BookingDto(
      id: base.id,
      bookingReference: base.bookingReference,
      serviceCode: base.serviceCode,
      status: BookingStatus.cancelled,
      pickupLocation: base.pickupLocation,
      dropoffLocation: base.dropoffLocation,
      priceBreakdown: base.priceBreakdown,
      createdAt: base.createdAt,
      cancellationReason: reason,
      paymentMethod: base.paymentMethod,
    );
  }

  @override
  Future<List<BookingDto>> listBookings({String? status, int limit = 20}) async {
    return [bookingToReturn ?? TestFixtures.booking];
  }
}

void main() {
  final testConfig = AppConfig.dev();
  final testApiClient = ApiClient(config: testConfig);
  final testScheduledRepo = ScheduledRepository(apiClient: testApiClient);
  final testTrackingRepo = TrackingRepository(apiClient: testApiClient);
  final testWalletRepo = WalletRepository(apiClient: testApiClient);

  final testSchoolRunPlan = ScheduledPlanDto(
    id: 'plan-sim-01',
    planReference: 'GV-SCH-SIM-2026',
    planType: 'SCHOOL_RUN_PLAN',
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
    status: 'ACTIVE',
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

  group('Simulation 1: Ride Order Full Lifecycle (R01 - R11)', () {
    test('verifies ride quote, vehicle selection, and booking creation logic', () async {
      final simRepo = _SimulatedBookingRepository(
        quoteToReturn: TestFixtures.quote,
        bookingToReturn: TestFixtures.booking,
      );
      final notifier = BookingNotifier(repository: simRepo);

      expect(notifier.state.hasValidRoute, isFalse);

      // Step 1: Set pickup and dropoff
      notifier.setPickupLocation(TestFixtures.locationPickup);
      notifier.setDropoffLocation(TestFixtures.locationDropoff);
      expect(notifier.state.hasValidRoute, isTrue);

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(notifier.state.quote, isNotNull);
      expect(notifier.state.quote?.quoteId, 'quote-test-999');
      expect(notifier.state.quote?.priceBreakdown.totalFare, 2050);

      // Step 2: Vehicle & payment selection
      notifier.selectVehicleType(VehicleType.electricTricycle);
      expect(notifier.state.selectedVehicleType, VehicleType.electricTricycle);

      notifier.setPaymentMethod(PaymentMethod.wallet);
      expect(notifier.state.selectedPaymentMethod, PaymentMethod.wallet);

      // Step 3: Commit ride booking
      final booking = await notifier.commitBooking();
      expect(booking, isNotNull);
      expect(booking?.id, 'bk-test-001');
      expect(booking?.serviceCode, ServiceCode.instantRide);
      expect(notifier.state.activeBooking?.status, BookingStatus.assigned);
    });

    testWidgets('simulates RideBookingScreen upfront pricing & commitment UI', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final simRepo = _SimulatedBookingRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bookingRepositoryProvider.overrideWithValue(simRepo),
          ],
          child: const MaterialApp(
            home: RideBookingScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Ride Electric'), findsOneWidget);
      expect(find.text('Select Electric Class'), findsOneWidget);
      expect(find.text('Volt Bike'), findsOneWidget);
      expect(find.text('Volt Trike (Comfort)'), findsOneWidget);
      expect(find.text('Payment Method'), findsOneWidget);
      expect(find.text('Confirm Electric Ride'), findsOneWidget);

      // Tap confirm button
      await tester.tap(find.text('Confirm Electric Ride'));
      await tester.pumpAndSettle();
    });

    testWidgets('simulates FindingDriverScreen radar matching dialog', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: FindingDriverScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Connecting to Driver'), findsOneWidget);
      expect(find.text('Searching Near You'), findsOneWidget);
      expect(find.text('Cancel Request'), findsOneWidget);

      // Verify cancellation prompt
      await tester.tap(find.text('Cancel Request'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      expect(find.text('Cancel Request?'), findsOneWidget);
      expect(find.text('Keep Searching'), findsOneWidget);

      await tester.tap(find.text('Keep Searching'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 200));

      // Fast-forward simulated matching timer (4.5s)
      await tester.pump(const Duration(milliseconds: 5000));
      await tester.pump();

      expect(find.text('Driver Assigned! ⚡'), findsOneWidget);
      expect(find.text('Track Driver Live'), findsOneWidget);
    });

    testWidgets('simulates LiveTrackingScreen telematics and safety triggers', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

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
      await tester.pumpAndSettle();

      expect(find.text('Live Trip Tracking'), findsOneWidget);
      expect(find.text('Babatunde Raji'), findsWidgets);
      expect(find.textContaining('LAG-428-EV'), findsWidgets);

      // Trigger Safety SOS modal
      final safetyIcon = find.byIcon(Icons.shield_outlined);
      expect(safetyIcon, findsOneWidget);
      await tester.tap(safetyIcon);
      await tester.pumpAndSettle();

      expect(find.text('Safety & Emergency Toolkit'), findsOneWidget);
      expect(find.text('Go-Volts Rapid 24/7 Security Assistance'), findsOneWidget);

      // Close safety sheet
      final closeIcon = find.byIcon(Icons.close);
      if (closeIcon.evaluate().isNotEmpty) {
        await tester.tap(closeIcon.first);
        await tester.pumpAndSettle();
      }

      // Open driver messaging modal
      final chatBtn = find.text('Chat');
      expect(chatBtn, findsOneWidget);
      await tester.tap(chatBtn);
      await tester.pumpAndSettle();

      expect(find.textContaining('Chat with Babatunde Raji'), findsOneWidget);
      expect(find.text("I'm waiting at the entrance"), findsOneWidget);

      // Tap quick reply chip
      await tester.tap(find.text("I'm waiting at the entrance"));
      await tester.pumpAndSettle();
      expect(find.text('Message sent to driver'), findsOneWidget);

      // Advance trip status through interactive simulation buttons: Arrived -> En Route
      final arrivedBtn = find.text('Arrived');
      expect(arrivedBtn, findsOneWidget);
      await tester.tap(arrivedBtn);
      await tester.pumpAndSettle();

      final enRouteBtn = find.text('En Route');
      expect(enRouteBtn, findsOneWidget);
      await tester.tap(enRouteBtn);
      await tester.pumpAndSettle();
    });

    testWidgets('simulates TripCompletedScreen rating, tip, and carbon avoidance', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

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
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('You Have Arrived!'), findsOneWidget);
      expect(find.textContaining('1.4 kg CO₂ Avoided'), findsOneWidget);
      expect(find.text('Total Fare Paid'), findsOneWidget);
      expect(find.text('₦2200'), findsOneWidget);
      expect(find.text('Rate Babatunde Raji'), findsOneWidget);
      expect(find.text('Add a Tip for Driver'), findsOneWidget);
      expect(find.text('Complete & Return Home'), findsOneWidget);
    });

    testWidgets('simulates ReceiptScreen itemized fare breakdown and eco offset', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: ReceiptScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Trip Receipt & Tax Invoice'), findsOneWidget);
      expect(find.text('GO-VOLTS NIGERIA'), findsOneWidget);
      expect(find.text('PAID & SETTLED'), findsOneWidget);
      expect(find.text('TRP-LAG-8921'), findsOneWidget);
      expect(find.textContaining('1.84 kg CO2 Offset'), findsOneWidget);
      expect(find.text('Download PDF Invoice'), findsOneWidget);

      await tester.tap(find.text('Download PDF Invoice'));
      await tester.pumpAndSettle();

      expect(find.text('Invoice PDF saved to device downloads.'), findsOneWidget);
    });
  });

  group('Simulation 2: Errand / Parcel Delivery Lifecycle (D01 - D10)', () {
    test('verifies parcel delivery categories, weight, and recipient information logic', () async {
      final simRepo = _SimulatedBookingRepository();
      final notifier = BookingNotifier(repository: simRepo);

      notifier.selectService(ServiceCode.instantDelivery);
      expect(notifier.state.serviceCode, ServiceCode.instantDelivery);

      notifier.setPickupLocation(TestFixtures.locationPickup);
      notifier.setDropoffLocation(TestFixtures.locationDropoff);

      notifier.setPackageDetails(
        category: PackageCategory.fragile,
        weightKg: 3.5,
        recipientName: 'Ngozi Eze',
        recipientPhone: '+2348011223344',
        instructions: 'Handle with care: Contains laptop & accessories. Call upon arrival.',
      );

      expect(notifier.state.packageCategory, PackageCategory.fragile);
      expect(notifier.state.packageWeightKg, 3.5);
      expect(notifier.state.recipientName, 'Ngozi Eze');
      expect(notifier.state.recipientPhone, '+2348011223344');
      expect(notifier.state.instructions, contains('laptop'));

      await Future<void>.delayed(const Duration(milliseconds: 10));
      expect(notifier.state.quote, isNotNull);

      final booking = await notifier.commitBooking();
      expect(booking, isNotNull);
      expect(simRepo.lastRecipientName, 'Ngozi Eze');
      expect(simRepo.lastRecipientPhone, '+2348011223344');
      expect(simRepo.lastInstructions, contains('laptop'));
    });

    testWidgets('simulates PackageDetailsScreen form entry, validation & submission UI', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final simRepo = _SimulatedBookingRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bookingRepositoryProvider.overrideWithValue(simRepo),
          ],
          child: const MaterialApp(
            home: PackageDetailsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Send Package'), findsOneWidget);
      expect(find.text('Package Category'), findsOneWidget);
      expect(find.text('Approximate Weight'), findsOneWidget);
      expect(find.text('Recipient Information'), findsOneWidget);

      // Select Documents category chip
      final documentsChip = find.text('Documents');
      expect(documentsChip, findsOneWidget);
      await tester.tap(documentsChip);
      await tester.pumpAndSettle();

      // Select 2 - 5 kg weight option
      final weightRadio = find.text('2 – 5 kg');
      expect(weightRadio, findsOneWidget);
      await tester.tap(weightRadio);
      await tester.pumpAndSettle();

      // Enter Recipient Details
      final recipientNameField = find.widgetWithText(TextFormField, 'e.g. Babatunde Raji');
      expect(recipientNameField, findsOneWidget);
      await tester.enterText(recipientNameField, 'Ngozi Eze');
      await tester.pumpAndSettle();

      final recipientPhoneField = find.widgetWithText(TextFormField, '802 345 6789');
      expect(recipientPhoneField, findsOneWidget);
      await tester.enterText(recipientPhoneField, '8011223344');
      await tester.pumpAndSettle();

      // Submit electric delivery
      final submitBtn = find.text('Confirm Electric Delivery');
      expect(submitBtn, findsOneWidget);
      await tester.tap(submitBtn);
      await tester.pumpAndSettle();
    });
  });

  group('Simulation 3: School Runs & Scheduled Commute Lifecycle (SP01 - SP24)', () {
    test('enforces 6-hour advance skip cutoff baseline policy', () {
      final now = DateTime(2026, 10, 24, 7, 0); // 7:00 AM

      // Trip at 2:00 PM (7 hours away) -> Preserves entitlement
      final validTrip = DateTime(2026, 10, 24, 14, 0);
      expect(testSchoolRunPlan.canSkipWithoutPenalty(validTrip, now: now), isTrue);

      // Trip at 10:00 AM (3 hours away) -> Forfeits entitlement
      final lateTrip = DateTime(2026, 10, 24, 10, 0);
      expect(testSchoolRunPlan.canSkipWithoutPenalty(lateTrip, now: now), isFalse);
    });

    test('verifies skip logic, OTP refresh, and pause/resume subscription state transitions', () async {
      final notifier = ScheduledNotifier(repository: testScheduledRepo);
      await notifier.loadPlans();

      expect(notifier.state.plans.isNotEmpty, isTrue);
      final activePlan = notifier.state.plans.first;
      final initialRemaining = activePlan.remainingTrips;

      // 1. Skip next trip with preservation (>6h in future)
      final futureTrip = DateTime.now().add(const Duration(hours: 12));
      final skipResult = await notifier.skipNextTrip(activePlan.id, futureTrip);
      expect(skipResult['entitlement_preserved'], isTrue);

      final postSkipPlan = notifier.state.plans.firstWhere((p) => p.id == activePlan.id);
      expect(postSkipPlan.remainingTrips, equals(initialRemaining));

      // 2. Refresh Handover OTP
      await notifier.refreshHandoverOtp(activePlan.id);
      final refreshedPlan = notifier.state.plans.firstWhere((p) => p.id == activePlan.id);
      expect(refreshedPlan.handoverOtp, isNotNull);
      expect(refreshedPlan.handoverOtp!.length, 6);

      // 3. Pause & Resume Subscription
      await notifier.togglePlanPause(refreshedPlan);
      expect(notifier.state.selectedPlan?.isPaused, isTrue);

      await notifier.togglePlanPause(notifier.state.selectedPlan!);
      expect(notifier.state.selectedPlan?.isPaused, isFalse);
    });

    testWidgets('simulates ScheduledBookingScreen date, time, and frequency selection', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final simRepo = _SimulatedBookingRepository();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            bookingRepositoryProvider.overrideWithValue(simRepo),
          ],
          child: const MaterialApp(
            home: ScheduledBookingScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Scheduled Services'), findsOneWidget);
      expect(find.text('Guaranteed Dispatch'), findsOneWidget);
      expect(find.text('Recurring Commute Plan'), findsOneWidget);
      expect(find.text('Safe School-Run Plan'), findsOneWidget);
      expect(find.text('One-off Advance Booking'), findsOneWidget);
      expect(find.text('Submit Commute Plan'), findsOneWidget);

      await tester.tap(find.text('Submit Commute Plan'));
      await tester.pumpAndSettle();
    });

    testWidgets('simulates ScheduledPlansScreen active school run plan and handover OTP', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(testConfig),
            apiClientProvider.overrideWithValue(testApiClient),
            scheduledRepositoryProvider.overrideWithValue(testScheduledRepo),
          ],
          child: const MaterialApp(
            home: ScheduledPlansScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('Scheduled Plans'), findsOneWidget);
      expect(find.text('🎒 School Run'), findsOneWidget);
      expect(find.text('Trip Entitlements'), findsOneWidget);
      expect(find.text('Next Upcoming Trip'), findsOneWidget);
      expect(find.text('Skip Trip'), findsOneWidget);
      expect(find.text('Manage Subscription'), findsOneWidget);
    });

    testWidgets('simulates SchoolRunSafetyScreen authorized guardians and handover protocol', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(testConfig),
            apiClientProvider.overrideWithValue(testApiClient),
            scheduledRepositoryProvider.overrideWithValue(testScheduledRepo),
          ],
          child: const MaterialApp(
            home: SchoolRunSafetyScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('School Run Safety & Handover'), findsOneWidget);
      expect(find.text('School Pickup Verification OTP'), findsOneWidget);
      expect(find.textContaining('849'), findsOneWidget);
      expect(find.text('Passenger Profile'), findsOneWidget);
      expect(find.textContaining('Zainab Adeleke'), findsOneWidget);
      expect(find.text('Authorized Guardians'), findsOneWidget);
      expect(find.textContaining('Dr. Aisha Adeleke'), findsOneWidget);
      expect(find.text('Custody & Handover Policy'), findsOneWidget);
      expect(find.text('Call Operations Safety Officer'), findsOneWidget);
    });

    testWidgets('simulates PlanModificationScreen schedule and address change requests', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: PlanModificationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Modify Subscription Plan'), findsOneWidget);
      expect(find.text('ACTIVE PLAN'), findsOneWidget);
      expect(find.text('Pickup Location'), findsOneWidget);
      expect(find.text('Drop-off Destination'), findsOneWidget);
      expect(find.text('Submit Schedule Adjustment'), findsOneWidget);

      await tester.tap(find.text('Submit Schedule Adjustment'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.text('Plan modification request submitted for operations review.'), findsOneWidget);
    });
  });

  group('Simulation 4: Wallet, Paystack Top-Up & Rewards Lifecycle (W01 - W08)', () {
    test('verifies wallet balance, top-up credit, and loyalty point conversion', () async {
      final notifier = WalletNotifier(repository: testWalletRepo);
      await notifier.loadWallet();

      final initialBalance = notifier.state.wallet.balance;
      expect(initialBalance, greaterThanOrEqualTo(14000.0));

      // 1. Atomic top-up simulation of ₦5,000
      const topUpAmount = 5000.0;
      final topUpSuccess = await notifier.completeTopUp('SIM-PAYSTACK-REF-99', topUpAmount);
      expect(topUpSuccess, isTrue);
      expect(notifier.state.wallet.balance, equals(initialBalance + topUpAmount));
      expect(notifier.state.transactions.first.amount, equals(topUpAmount));
      expect(notifier.state.transactions.first.isCredit, isTrue);

      // 2. Eco-points conversion (1000 points = ₦100)
      final preRedeemBalance = notifier.state.wallet.balance;
      final initialPoints = notifier.state.loyalty!.pointsBalance;
      const pointsToRedeem = 1000;
      final redeemSuccess = await notifier.redeemLoyaltyPoints(pointsToRedeem);
      expect(redeemSuccess, isTrue);
      expect(notifier.state.wallet.balance, equals(preRedeemBalance + 100.0));
      expect(notifier.state.loyalty!.pointsBalance, equals(initialPoints - pointsToRedeem));
    });

    testWidgets('simulates WalletScreen balance display, transactions, and policy', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(testConfig),
            apiClientProvider.overrideWithValue(testApiClient),
            walletRepositoryProvider.overrideWithValue(testWalletRepo),
          ],
          child: const MaterialApp(
            home: WalletScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('My Wallet'), findsOneWidget);
      expect(find.text('Available Balance'), findsOneWidget);
      expect(find.textContaining('14500'), findsWidgets);
      expect(find.textContaining('Ride-wallet credit only'), findsOneWidget);
      expect(find.text('Eco-Rewards'), findsOneWidget);
      expect(find.text('Recent Transactions'), findsOneWidget);
    });

    testWidgets('simulates TopUpScreen Paystack checkout modal and simulated payment', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(testConfig),
            apiClientProvider.overrideWithValue(testApiClient),
            walletRepositoryProvider.overrideWithValue(testWalletRepo),
          ],
          child: const MaterialApp(
            home: TopUpScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('Top Up Wallet'), findsOneWidget);
      expect(find.text('Select or Enter Amount'), findsOneWidget);
      expect(find.text('₦1k'), findsOneWidget);
      expect(find.text('₦2k'), findsOneWidget);
      expect(find.text('₦5k'), findsOneWidget);
      expect(find.text('₦10k'), findsOneWidget);
      expect(find.text('Debit / Credit Card (Paystack)'), findsOneWidget);
      expect(find.text('Proceed to Pay ₦2000'), findsOneWidget);

      // Tap Proceed to Pay ₦2000
      await tester.tap(find.text('Proceed to Pay ₦2000'));
      await tester.pumpAndSettle();

      // Paystack modal opens
      expect(find.text('Paystack Secure Checkout'), findsOneWidget);
      expect(find.text('Simulate Successful Payment'), findsOneWidget);

      // Tap Simulate Successful Payment
      await tester.tap(find.text('Simulate Successful Payment'));
      await tester.pumpAndSettle();

      // Verifies success confirmation screen
      expect(find.text('Top-Up Successful!'), findsOneWidget);
      expect(find.text('Return to Wallet'), findsOneWidget);
    });

    testWidgets('simulates RewardsScreen loyalty points balance, coupons, and referral code', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(testConfig),
            apiClientProvider.overrideWithValue(testApiClient),
            walletRepositoryProvider.overrideWithValue(testWalletRepo),
          ],
          child: const MaterialApp(
            home: RewardsScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      expect(find.text('Rewards & Eco-Points'), findsOneWidget);
      expect(find.text('4200'), findsOneWidget);
      expect(find.text('Invite Friends & Earn'), findsOneWidget);
      expect(find.text('VOLT-ALEX99'), findsOneWidget);
      expect(find.text('Available Vouchers & Coupons'), findsOneWidget);
      expect(find.textContaining('VOLTFIRST'), findsWidgets);
    });
  });

  group('Simulation 5: Profile, Saved Places & Safety Hotline (A01 - A15, H05, H06)', () {
    testWidgets('simulates EditProfileScreen verified badge and phone change alert', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: EditProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Verified Parent / Guardian'), findsOneWidget);
      expect(find.text('VETTED'), findsOneWidget);

      final phoneField = find.widgetWithText(TextField, '+234 801 234 5678');
      await tester.enterText(phoneField, '+234 809 999 8888');
      await tester.pumpAndSettle();

      expect(find.textContaining('Changing your phone number requires SMS OTP verification'), findsOneWidget);
    });

    testWidgets('simulates SavedPlacesScreen dependent plan safeguard against accidental deletion', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: SavedPlacesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Saved Places'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Corona School Victoria Island'), findsOneWidget);
      expect(find.text('ACTIVE PLAN'), findsWidgets);

      // Attempt to delete Home which is linked to active plan
      final deleteButtons = find.byIcon(Icons.delete_outline);
      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      expect(find.text('Delete Home?'), findsOneWidget);
      expect(find.textContaining('WARNING: An active School-Run or Recurring Commute plan depends on this address!'), findsOneWidget);

      await tester.tap(find.text('Keep Place'));
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('simulates NotificationsScreen category filters and mark all read', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: NotificationsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Driver Approaching Pickup'), findsOneWidget);
      expect(find.text('School-Run Handover Security Code'), findsOneWidget);

      // Filter by "Trips"
      await tester.tap(find.text('Trips'));
      await tester.pumpAndSettle();
      expect(find.text('Driver Approaching Pickup'), findsOneWidget);
      expect(find.text('School-Run Handover Security Code'), findsNothing);

      // Filter by "All" and mark all as read
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mark all read'));
      await tester.pumpAndSettle();
      expect(find.text('All notifications marked as read.'), findsOneWidget);
    });

    testWidgets('simulates SupportScreen 24/7 hotline and inquiry submission', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(testConfig),
            apiClientProvider.overrideWithValue(testApiClient),
          ],
          child: const MaterialApp(
            home: SupportScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pumpAndSettle();

      expect(find.text('Help & Support Center'), findsOneWidget);
      expect(find.text('24/7 Operations Support'), findsOneWidget);
      expect(find.text('Call +234 1 800 4686'), findsOneWidget);
      expect(find.text('Frequently Asked Questions'), findsOneWidget);
      expect(find.text('Send a Message to Support'), findsOneWidget);
      expect(find.text('Submit Support Ticket'), findsOneWidget);

      // Enter message and submit
      await tester.enterText(
        find.byType(TextField),
        'Question regarding morning pickup window at Lekki Phase 1',
      );
      await tester.pump();

      await tester.tap(find.text('Submit Support Ticket'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.text('Inquiry Logged Successfully'), findsOneWidget);
      expect(find.textContaining('CASE-SUP-'), findsOneWidget);
    });
  });
}
