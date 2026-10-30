import 'package:api_client/api_client.dart';
import 'package:app_config/app_config.dart';
import 'package:app_models/app_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rider_app/main.dart';
import 'package:rider_app/src/core/providers/api_providers.dart';
import 'package:rider_app/src/features/earnings/application/rider_earnings_notifier.dart';
import 'package:rider_app/src/features/earnings/presentation/rider_earnings_screen.dart';
import 'package:rider_app/src/features/onboarding/application/onboarding_notifier.dart';
import 'package:rider_app/src/features/onboarding/data/rider_repository.dart';
import 'package:rider_app/src/features/onboarding/domain/onboarding_state.dart';
import 'package:rider_app/src/features/onboarding/presentation/rider_application_status_screen.dart';
import 'package:rider_app/src/features/onboarding/presentation/rider_documents_screen.dart';
import 'package:rider_app/src/features/onboarding/presentation/rider_guarantor_screen.dart';
import 'package:rider_app/src/features/onboarding/presentation/rider_personal_screen.dart';
import 'package:rider_app/src/features/onboarding/presentation/rider_training_screen.dart';
import 'package:rider_app/src/features/onboarding/presentation/rider_vehicle_screen.dart';
import 'package:rider_app/src/features/onboarding/presentation/rider_welcome_screen.dart';
import 'package:rider_app/src/features/profile/presentation/rider_profile_screen.dart';
import 'package:rider_app/src/features/shift/application/shift_notifier.dart';
import 'package:rider_app/src/features/shift/presentation/rider_home_screen.dart';
import 'package:rider_app/src/features/shift/presentation/widgets/decline_reason_dialog.dart';
import 'package:rider_app/src/features/shift/presentation/widgets/dispatch_offer_modal.dart';
import 'package:rider_app/src/features/swaps/application/battery_swap_notifier.dart';
import 'package:rider_app/src/features/swaps/presentation/battery_swap_screen.dart';
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
  final testRiderRepo = RiderRepository(apiClient: testApiClient);
  final testTripRepo = TripRepository(apiClient: testApiClient);

  final sampleParcelJob = DispatchOfferDto(
    id: 'OFFER-SIM-PARCEL-01',
    jobId: 'JOB-SIM-PARCEL-01',
    serviceType: ServiceTierEligibility.parcelDelivery,
    customerName: 'Chidinma Okafor',
    grossFareKobo: 300000, // ₦3,000 gross
    netEarningsKobo: 240000, // ₦2,400 net (80%)
    pickupAddress: 'Plot 14 Admiralty Way, Lekki',
    pickupDistanceKm: 1.2,
    pickupEtaMinutes: 4,
    dropoffAddress: 'Ahmadu Bello Way, Victoria Island',
    tripDistanceKm: 6.8,
    estimatedTripMinutes: 18,
    paymentMethod: 'Wallet',
    expiresAt: DateTime.now().add(const Duration(seconds: 30)),
    parcelDescription: 'Express Legal Contract',
    packageWeightKg: 1.0,
    isFragile: true,
  );

  final sampleSchoolRunJob = DispatchOfferDto(
    id: 'OFFER-SIM-SCH-02',
    jobId: 'JOB-SIM-SCH-02',
    serviceType: ServiceTierEligibility.schoolRunCommute,
    customerName: 'Mrs. Folake Adeleke',
    grossFareKobo: 400000, // ₦4,000 gross
    netEarningsKobo: 320000, // ₦3,200 net (80%)
    pickupAddress: 'Corona School, VI',
    pickupDistanceKm: 0.8,
    pickupEtaMinutes: 3,
    dropoffAddress: 'Parkview Estate, Ikoyi',
    tripDistanceKm: 5.5,
    estimatedTripMinutes: 16,
    paymentMethod: 'Wallet',
    expiresAt: DateTime.now().add(const Duration(seconds: 30)),
    childName: 'Amina Adeleke',
    schoolName: 'Corona School VI',
    requiresOtp: true,
  );

  final samplePassengerJob = DispatchOfferDto(
    id: 'OFFER-SIM-RIDE-03',
    jobId: 'JOB-SIM-RIDE-03',
    serviceType: ServiceTierEligibility.passengerRide,
    customerName: 'Babatunde Fashola',
    grossFareKobo: 250000, // ₦2,500 gross
    netEarningsKobo: 200000, // ₦2,000 net (80%)
    pickupAddress: '12 Marina, Lagos Island',
    pickupDistanceKm: 1.5,
    pickupEtaMinutes: 5,
    dropoffAddress: 'Ozumba Mbadiwe, VI',
    tripDistanceKm: 4.2,
    estimatedTripMinutes: 12,
    paymentMethod: 'Wallet',
    expiresAt: DateTime.now().add(const Duration(seconds: 30)),
    requiresOtp: true,
  );

  // ==========================================================================
  // SIMULATION 1: RIDER ONBOARDING & REGULATORY KYC LIFECYCLE (RD01 - RD07)
  // ==========================================================================
  group('Simulation 1: Rider Onboarding & Regulatory KYC Lifecycle (RD01 - RD07)', () {
    test('verifies KYC document rules, expiration constraints, and vehicle state requirements', () {
      const stateEmpty = OnboardingState();
      expect(stateEmpty.hasRequiredDocuments, isFalse);

      // Verify regulatory document completeness
      final stateWithDocs = OnboardingState(
        documents: [
          RiderDocumentDto(
            id: 'doc-nin',
            type: DocumentType.nationalId,
            documentNumber: '10928374651',
            fileUrl: 'https://cdn.govolts.ng/docs/nin.jpg',
            expiryDate: DateTime.now().add(const Duration(days: 730)),
            status: DocumentVerificationStatus.approved,
          ),
          RiderDocumentDto(
            id: 'doc-dl',
            type: DocumentType.driversLicense,
            documentNumber: 'DL-882-LAG',
            fileUrl: 'https://cdn.govolts.ng/docs/dl.jpg',
            expiryDate: DateTime.now().add(const Duration(days: 365)),
            status: DocumentVerificationStatus.approved,
          ),
          RiderDocumentDto(
            id: 'doc-vr',
            type: DocumentType.vehicleRegistration,
            documentNumber: 'VR-LAG-2901-EV',
            fileUrl: 'https://cdn.govolts.ng/docs/lasrra.jpg',
            expiryDate: DateTime.now().add(const Duration(days: 300)),
            status: DocumentVerificationStatus.approved,
          ),
        ],
      );
      expect(stateWithDocs.hasRequiredDocuments, isTrue);

      // Expired document blocks readiness
      final expiredRider = RiderDto(
        id: 'RIDER-EXP-01',
        profileId: 'USR-01',
        fullName: 'Test Rider',
        phoneNumber: '+2348011223344',
        vehiclePlate: 'LAG-428-EV',
        vehicleModel: 'Roam Air EV',
        batteryLevelPercent: 90,
        documents: [
          RiderDocumentDto(
            id: 'doc-expired',
            type: DocumentType.driversLicense,
            documentNumber: 'DL-OLD-999',
            fileUrl: 'http://cdn.govolts.ng/expired.jpg',
            expiryDate: DateTime.now().subtract(const Duration(days: 5)),
            status: DocumentVerificationStatus.approved,
          ),
        ],
      );
      expect(expiredRider.canGoOnline, isFalse);

      // Low battery (< 15%) blocks readiness
      const lowBatteryRider = RiderDto(
        id: 'RIDER-LOW-02',
        profileId: 'USR-02',
        fullName: 'Test Rider',
        phoneNumber: '+2348011223344',
        vehiclePlate: 'LAG-428-EV',
        vehicleModel: 'Roam Air EV',
        batteryLevelPercent: 12,
      );
      expect(lowBatteryRider.canGoOnline, isFalse);
    });

    test('simulates complete multi-step OnboardingNotifier application submission', () async {
      final notifier = OnboardingNotifier(repository: testRiderRepo);

      // Step 1: Personal Details
      notifier.updatePersonalDetails(
        fullName: 'Babajide Ogundipe',
        phoneNumber: '+2348031122334',
        email: 'babajide.ogundipe@govolts.ng',
        residentialAddress: '18 Admiralty Way, Lekki Phase 1',
        lagosLga: 'Eti-Osa (VI / Lekki)',
        emergencyContactName: 'Funke Ogundipe',
        emergencyContactPhone: '+2348029988776',
      );
      expect(notifier.state.fullName, 'Babajide Ogundipe');
      expect(notifier.state.lagosLga, 'Eti-Osa (VI / Lekki)');

      // Step 2: Vehicle Specifications
      notifier.updateVehicleDetails(
        vehicleType: VehicleType.electricBike,
        vehiclePlate: 'LAG-428-EV',
        vehicleModel: 'Roam Air EV',
        chassisNumber: 'VIN-ROAM-8842',
        batteryCapacityKwh: '3.2 kWh LFP',
      );
      expect(notifier.state.vehiclePlate, 'LAG-428-EV');
      expect(notifier.state.vehicleType, VehicleType.electricBike);

      // Step 3: Add documents
      notifier.addDocument(
        RiderDocumentDto(
          id: 'D1',
          type: DocumentType.nationalId,
          documentNumber: '10928374651',
          fileUrl: 'https://cdn.govolts.ng/docs/nin.jpg',
          expiryDate: DateTime.now().add(const Duration(days: 700)),
        ),
      );
      notifier.addDocument(
        RiderDocumentDto(
          id: 'D2',
          type: DocumentType.driversLicense,
          documentNumber: 'DL-882-LAG',
          fileUrl: 'https://cdn.govolts.ng/docs/dl.jpg',
          expiryDate: DateTime.now().add(const Duration(days: 365)),
        ),
      );
      notifier.addDocument(
        RiderDocumentDto(
          id: 'D3',
          type: DocumentType.vehicleRegistration,
          documentNumber: 'VR-LAG-2901-EV',
          fileUrl: 'https://cdn.govolts.ng/docs/vr.jpg',
          expiryDate: DateTime.now().add(const Duration(days: 365)),
        ),
      );
      expect(notifier.state.documents.length, 3);
      expect(notifier.state.hasRequiredDocuments, isTrue);

      // Step 4: Guarantor details
      notifier.updateGuarantorDetails(
        fullName: 'Alhaji Gbadamosi',
        phoneNumber: '+2348033344556',
        relationship: 'Business Mentor',
        residentialAddress: 'Broad Street, Lagos Island',
      );
      expect(notifier.state.guarantor?.fullName, 'Alhaji Gbadamosi');

      // Step 5: Training completion & quiz score
      notifier.completeTraining(100);
      expect(notifier.state.trainingCompleted, isTrue);
      expect(notifier.state.assessmentScore, 100);

      // Commit application
      final success = await notifier.submitApplication();
      expect(success, isTrue);
      expect(notifier.state.submittedRider, isNotNull);
      expect(notifier.state.submittedRider?.fullName, 'Babajide Ogundipe');
    });

    testWidgets('simulates RiderWelcomeScreen branding, value propositions, and CTA', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(testConfig),
            apiClientProvider.overrideWithValue(testApiClient),
            riderRepositoryProvider.overrideWithValue(testRiderRepo),
          ],
          child: const MaterialApp(
            home: RiderWelcomeScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Ride Green. Earn Fair. Power Lagos.'), findsOneWidget);
      expect(find.text('Guaranteed Weekly Settlement'), findsOneWidget);
      expect(find.text('Free EV Battery Swapping'), findsOneWidget);
      expect(find.text('Insurance & Safety Coverage'), findsOneWidget);
      expect(find.text('Transparent 20% Platform Fee'), findsOneWidget);
      expect(find.text('Apply to Ride with Go-Volts'), findsOneWidget);
      expect(find.text('Rider Sign In'), findsOneWidget);
    });

    testWidgets('simulates RiderPersonalScreen KYC form, Lagos LGA selector, and emergency contact', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(testConfig),
            apiClientProvider.overrideWithValue(testApiClient),
            riderRepositoryProvider.overrideWithValue(testRiderRepo),
          ],
          child: const MaterialApp(
            home: RiderPersonalScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Applicant Personal Profile'), findsOneWidget);
      expect(find.text('Step 1 of 5: Personal KYC'), findsOneWidget);
      expect(find.text('Full Legal Name *'), findsOneWidget);
      expect(find.text('Mobile Phone Number (+234...) *'), findsOneWidget);
      expect(find.text('Emergency Contact'), findsOneWidget);
      expect(find.text('Save & Continue to Documents'), findsOneWidget);
    });

    testWidgets('simulates RiderDocumentsScreen regulatory document uploads and verification badges', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(testConfig),
            apiClientProvider.overrideWithValue(testApiClient),
            riderRepositoryProvider.overrideWithValue(testRiderRepo),
          ],
          child: const MaterialApp(
            home: RiderDocumentsScreen(),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Identity & Regulatory Credentials'), findsOneWidget);
      expect(find.text('Step 2 of 5: Document Uploads'), findsOneWidget);
      expect(find.textContaining('National Identity Card'), findsOneWidget);
      expect(find.textContaining("Driver's / Rider's License"), findsOneWidget);
      expect(find.textContaining('Vehicle Registration'), findsOneWidget);
      expect(find.text('Save & Continue to Vehicle Details'), findsOneWidget);
    });

    testWidgets('simulates RiderVehicleScreen EV selection and 5-point physical safety checklist', (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(testConfig),
            apiClientProvider.overrideWithValue(testApiClient),
            riderRepositoryProvider.overrideWithValue(testRiderRepo),
          ],
          child: const MaterialApp(
            home: RiderVehicleScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Electric Vehicle & Roadworthiness'), findsOneWidget);
      expect(find.text('Step 3 of 5: Vehicle Details'), findsOneWidget);
      expect(find.text('EV Bike'), findsOneWidget);
      expect(find.text('EV Trike'), findsOneWidget);
      expect(find.text('Swappable Battery System'), findsOneWidget);
      expect(find.text('Physical Safety Inspection Checklist'), findsOneWidget);
      expect(find.text('Save & Continue to Guarantor'), findsOneWidget);
    });

    testWidgets('simulates RiderGuarantorScreen referee inputs and statutory telephone consent', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(testConfig),
            apiClientProvider.overrideWithValue(testApiClient),
            riderRepositoryProvider.overrideWithValue(testRiderRepo),
          ],
          child: const MaterialApp(
            home: RiderGuarantorScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Guarantor & Referee Verification'), findsOneWidget);
      expect(find.text('Step 4 of 5: Guarantor Details'), findsOneWidget);
      expect(find.text('Guarantor Full Legal Name *'), findsOneWidget);
      expect(find.textContaining('guarantor has consented to phone'), findsOneWidget);
      expect(find.text('Save & Continue to Safety Training'), findsOneWidget);
    });

    testWidgets('simulates RiderTrainingScreen safety assessment quiz and 100% score validation', (tester) async {
      tester.view.physicalSize = const Size(800, 2600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(testConfig),
            apiClientProvider.overrideWithValue(testApiClient),
            riderRepositoryProvider.overrideWithValue(testRiderRepo),
          ],
          child: const MaterialApp(
            home: RiderTrainingScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('EV Safety & Standard Protocols'), findsOneWidget);
      expect(find.text('Step 5 of 5: Safety Assessment'), findsOneWidget);
      expect(find.textContaining('regenerative braking'), findsOneWidget);
      expect(find.textContaining('battery swap station'), findsOneWidget);
      expect(find.textContaining('School-Run'), findsOneWidget);
      expect(find.text('Assessment Passed (4/4 100%)'), findsOneWidget);
      expect(find.text('Submit Application for Certification'), findsOneWidget);
    });

    testWidgets('simulates RiderApplicationStatusScreen verification checklist and service badges', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(testConfig),
            apiClientProvider.overrideWithValue(testApiClient),
            riderRepositoryProvider.overrideWithValue(testRiderRepo),
          ],
          child: const MaterialApp(
            home: RiderApplicationStatusScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Application Status'), findsOneWidget);
      expect(find.text('Verification Checklist'), findsOneWidget);
      expect(find.text('Service Tier Eligibility & Certifications'), findsOneWidget);
      expect(find.text('Parcel & Cargo Delivery'), findsOneWidget);
      expect(find.text('Passenger EV Commute'), findsOneWidget);
      expect(find.text('School-Run Dedicated Chaperone'), findsOneWidget);
      expect(find.text('Access Shift Dashboard (Demo Preview)'), findsOneWidget);
    });
  });

  // ==========================================================================
  // SIMULATION 2: SHIFT AVAILABILITY, GEOFENCE SURGE & DISPATCH OFFERS (RD08 - RD11)
  // ==========================================================================
  group('Simulation 2: Shift Availability, Geofence Surge & Dispatch Offers (RD08 - RD11)', () {
    test('verifies battery guard threshold enforcement and critical auto-cutoff rules', () async {
      final notifier = ShiftNotifier(riderRepository: testRiderRepo);

      // Low battery (< 15%) blocks toggle to online
      notifier.updateBatteryLevel(12);
      final onlineSuccess = await notifier.toggleAvailability();
      expect(onlineSuccess, isFalse);
      expect(notifier.state.isOnline, isFalse);
      expect(notifier.state.errorMessage, contains('Battery critically low (12%)'));

      // Charged battery (> 15%) allows toggle to online
      notifier.updateBatteryLevel(85);
      final chargeSuccess = await notifier.toggleAvailability();
      expect(chargeSuccess, isTrue);
      expect(notifier.state.isOnline, isTrue);

      // Dropping below 10% automatically forces rider offline
      notifier.updateBatteryLevel(9);
      expect(notifier.state.isOnline, isFalse);
      expect(notifier.state.errorMessage, contains('critical threshold (9%)'));
    });

    test('verifies service mode filtering, active dispatch mode, and offer triggers', () async {
      final notifier = ShiftNotifier(riderRepository: testRiderRepo);
      notifier.updateBatteryLevel(90);

      // Switch to school run chaperone mode
      notifier.setServiceTier(ServiceTierEligibility.schoolRunCommute);
      expect(notifier.state.activeTier, ServiceTierEligibility.schoolRunCommute);

      // Trigger incoming offer
      await notifier.triggerIncomingOffer(customOffer: sampleSchoolRunJob);
      expect(notifier.state.currentOffer, isNotNull);
      expect(notifier.state.currentOffer?.jobId, 'JOB-SIM-SCH-02');
      expect(notifier.state.currentOffer?.requiresOtp, isTrue);

      // Decline offer with reason
      await notifier.declineOffer(
        DispatchDeclineReason.distanceTooFar,
        note: 'High Lekki expressway gridlock',
      );
      expect(notifier.state.currentOffer, isNull);
      expect(notifier.state.activeJob, isNull);
    });

    testWidgets('simulates RiderHomeScreen shift dashboard, battery gauge, and Lagos heatmap', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

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
    });

    testWidgets('simulates DispatchOfferModal for Parcel Job with 80% net take-home and 20% platform fee', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      var accepted = false;
      var declined = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DispatchOfferModal(
              offer: sampleParcelJob,
              onAccept: () => accepted = true,
              onDecline: () => declined = true,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('PARCEL & CARGO DELIVERY'), findsOneWidget);
      expect(find.text('YOUR TAKE-HOME (80%)'), findsOneWidget);
      expect(find.text('₦2400 net'), findsOneWidget);
      expect(find.text('Gross: ₦3000'), findsOneWidget);
      expect(find.text('Fee: ₦600 (20%)'), findsOneWidget);
      expect(find.textContaining('Plot 14 Admiralty Way, Lekki'), findsOneWidget);
      expect(find.textContaining('Ahmadu Bello Way, Victoria Island'), findsOneWidget);
      expect(find.textContaining('Express Legal Contract'), findsOneWidget);
      expect(find.textContaining('(FRAGILE)'), findsOneWidget);
      expect(find.text('Accept Offer'), findsOneWidget);
      expect(find.text('Decline'), findsOneWidget);

      await tester.tap(find.text('Accept Offer'));
      expect(accepted, isTrue);

      await tester.tap(find.text('Decline'));
      expect(declined, isTrue);
    });

    testWidgets('simulates DispatchOfferModal for School-Run Job with guardian safeguarding badges', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DispatchOfferModal(
              offer: sampleSchoolRunJob,
              onAccept: () {},
              onDecline: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('SCHOOL-RUN DEDICATED CHAPERONE'), findsOneWidget);
      expect(find.text('YOUR TAKE-HOME (80%)'), findsOneWidget);
      expect(find.text('₦3200 net'), findsOneWidget);
      expect(find.text('Gross: ₦4000'), findsOneWidget);
      expect(find.text('Fee: ₦800 (20%)'), findsOneWidget);
      expect(find.textContaining('Student: Amina Adeleke'), findsOneWidget);
      expect(find.textContaining('OTP Verification Required'), findsOneWidget);
    });

    testWidgets('simulates DispatchOfferModal for Passenger Ride Job with customer name and route', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DispatchOfferModal(
              offer: samplePassengerJob,
              onAccept: () {},
              onDecline: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('PASSENGER EV COMMUTE'), findsOneWidget);
      expect(find.text('YOUR TAKE-HOME (80%)'), findsOneWidget);
      expect(find.text('₦2000 net'), findsOneWidget);
      expect(find.text('Gross: ₦2500'), findsOneWidget);
      expect(find.text('Fee: ₦500 (20%)'), findsOneWidget);
      expect(find.textContaining('12 Marina, Lagos Island'), findsOneWidget);
      expect(find.textContaining('Ozumba Mbadiwe, VI'), findsOneWidget);
    });

    testWidgets('simulates DeclineReasonDialog structured reason selection and confirmation', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      DispatchDeclineReason? chosenReason;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DeclineReasonDialog(
              onConfirm: (reason, note) => chosenReason = reason,
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Decline Dispatch Offer'), findsOneWidget);
      expect(find.text(DispatchDeclineReason.batteryLow.label), findsOneWidget);
      expect(find.text(DispatchDeclineReason.distanceTooFar.label), findsOneWidget);
      expect(find.text(DispatchDeclineReason.trafficCongestion.label), findsOneWidget);

      await tester.tap(find.text(DispatchDeclineReason.distanceTooFar.label));
      await tester.pump();

      await tester.tap(find.text('Confirm'));
      await tester.pump();

      expect(chosenReason, DispatchDeclineReason.distanceTooFar);
    });
  });

  // ==========================================================================
  // SIMULATION 3: ACTIVE TRIP TELEMATICS, SPEED LIMITER, OTP & POD (RD12 - RD18)
  // ==========================================================================
  group('Simulation 3: Active Trip Telematics, Speed Limiter, OTP & POD (RD12 - RD18)', () {
    test('verifies geofenced speed limiter logic and financial commission calculations', () {
      final safeTrip = ActiveTripState(
        job: sampleParcelJob,
        speedKmh: 42.0,
        speedLimitKmh: 45.0,
      );
      expect(safeTrip.isSpeeding, isFalse);

      final speedingTrip = ActiveTripState(
        job: sampleParcelJob,
        speedKmh: 54.0,
        speedLimitKmh: 45.0,
      );
      expect(speedingTrip.isSpeeding, isTrue);

      // 80% Net and 100% Tips calculation
      final settlement = FareSettlementDto.fromGrossAndTip(
        grossKobo: 300000, // ₦3,000
        tipKobo: 50000, // ₦500 tip
        paymentMethod: 'Wallet',
      );
      expect(settlement.grossFareNaira, 3000.0);
      expect(settlement.commissionNaira, 600.0); // 20% Go-Volts platform fee
      expect(settlement.netEarningsNaira, 2400.0); // 80% Rider base take-home
      expect(settlement.tipNaira, 500.0); // 100% tip pass-through
      expect(settlement.totalCreditNaira, 2900.0); // 2400 + 500
    });

    test('simulates complete trip milestone lifecycle and delivery settlement', () async {
      final notifier = ActiveTripNotifier(
        job: sampleParcelJob,
        tripRepository: testTripRepo,
      );

      // Milestone 0: Heading to Pickup
      expect(notifier.state.milestone, TripMilestone.approachingPickup);

      // Milestone 1: Arrived at Pickup
      await notifier.markArrivedAtPickup();
      expect(notifier.state.milestone, TripMilestone.arrivedAtPickup);
      expect(notifier.state.distanceRemainingKm, 0.0);

      // Milestone 2: Handover OTP Verification
      final otpValid = await notifier.verifyOtp('1234');
      expect(otpValid, isTrue);
      expect(notifier.state.milestone, TripMilestone.otpVerified);

      // Milestone 3: In Transit to Destination
      await notifier.startTransit();
      expect(notifier.state.milestone, TripMilestone.inTransit);
      expect(notifier.state.distanceRemainingKm, 6.8);

      // Milestone 4: Arrived at Destination
      await notifier.markArrivedAtDestination();
      expect(notifier.state.milestone, TripMilestone.arrivedAtDestination);

      // Milestone 5: Submit Proof of Delivery
      final podSuccess = await notifier.submitProofOfDelivery(
        photoUrl: 'https://cdn.govolts.ng/pod/pkg_01.jpg',
        recipientName: 'Chidinma Okafor',
        signature: 'SIG-CHIDINMA',
      );
      expect(podSuccess, isTrue);
      expect(notifier.state.milestone, TripMilestone.proofSubmitted);

      // Milestone 6: Complete Trip & Settle Fare
      await notifier.completeTrip(tipKobo: 50000);
      expect(notifier.state.milestone, TripMilestone.completed);
      expect(notifier.state.settlement, isNotNull);
      expect(notifier.state.settlement?.totalCreditNaira, 2900.0);
    });

    test('verifies OTP security lockout after 3 consecutive failed attempts', () async {
      final notifier = ActiveTripNotifier(
        job: sampleSchoolRunJob,
        tripRepository: testTripRepo,
      );

      // Attempt 1 fails
      var verified = await notifier.verifyOtp('999999');
      expect(verified, isFalse);
      expect(notifier.state.otpAttemptsRemaining, 2);
      expect(notifier.state.otpError, contains('2 attempts remaining'));

      // Attempt 2 fails
      verified = await notifier.verifyOtp('888888');
      expect(verified, isFalse);
      expect(notifier.state.otpAttemptsRemaining, 1);
      expect(notifier.state.otpError, contains('1 attempt remaining'));

      // Attempt 3 fails -> Lockout
      verified = await notifier.verifyOtp('777777');
      expect(verified, isFalse);
      expect(notifier.state.otpAttemptsRemaining, 0);
      expect(notifier.state.otpError, contains('Maximum OTP attempts exceeded'));

      // 4th attempt is locked out even with valid PIN
      verified = await notifier.verifyOtp('123456');
      expect(verified, isFalse);
    });

    testWidgets('simulates ActiveTripScreen telematics HUD, speed indicator, and waypoint banner', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

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
      expect(find.text('Plot 14 Admiralty Way, Lekki'), findsOneWidget);
    });

    testWidgets('simulates OtpVerificationScreen 6-digit School-Run parental handover verification', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

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
      expect(find.textContaining('Corona School VI'), findsOneWidget);
      expect(find.text('Verify & Confirm Handover'), findsOneWidget);

      await tester.enterText(find.byType(TextField), '123456');
      await tester.pump();

      await tester.tap(find.text('Verify & Confirm Handover'));
      await tester.pumpAndSettle();
    });

    testWidgets('simulates DeliveryExceptionDialog issue reporting and telemetry capture', (tester) async {
      tester.view.physicalSize = const Size(800, 1200);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

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
    });

    testWidgets('simulates ProofOfDeliveryScreen photo evidence, legal name, and signature submission', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

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
    });

    testWidgets('simulates TripCompletionScreen 80/20 financial breakdown and customer rating', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      final settlement = FareSettlementDto.fromGrossAndTip(
        grossKobo: 320000, // ₦3,200
        tipKobo: 50000, // ₦500
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
    });
  });

  // ==========================================================================
  // SIMULATION 4: FINANCIAL LEDGER, PAYSTACK PAYOUT & BATTERY SWAPS (RD19 - RD23)
  // ==========================================================================
  group('Simulation 4: Financial Ledger, Paystack Payout & Battery Swaps (RD19 - RD23)', () {
    test('verifies RiderEarningsNotifier ledger calculations, balance, and dispute references', () {
      final notifier = RiderEarningsNotifier();
      final state = notifier.state;

      expect(state.grossWeekKobo, 10800000);
      expect(state.commissionWeekKobo, 2160000); // 20% platform commission
      expect(state.tipsWeekKobo, 450000);
      expect(state.settledWeekKobo, 8640000);
      expect(state.bankName, 'Access Bank');
      expect(state.entries.length, 4);

      notifier.submitDispute('TRP-LAG-8921', 'Incorrect commission deducted');
      expect(notifier.state.lastDisputeSubmittedReference, 'TRP-LAG-8921');
    });

    test('simulates Paystack instant payout withdrawal and ledger balance decrement', () async {
      final notifier = RiderEarningsNotifier();

      // Overdrawn attempt rejected
      final overdrawn = await notifier.requestInstantWithdrawal(99999999);
      expect(overdrawn, isFalse);

      // Valid withdrawal of ₦20,000 (2,000,000 kobo)
      final success = await notifier.requestInstantWithdrawal(2000000);
      expect(success, isTrue);
      expect(notifier.state.settledWeekKobo, 6640000); // 86,400 - 20,000 = 66,400
      expect(notifier.state.entries.first.isPayout, isTrue);
      expect(notifier.state.entries.first.title, contains('Instant Payout Requested'));
    });

    test('verifies BatterySwapNotifier station inventory, reservation lifecycle, and QR unlock', () async {
      final notifier = BatterySwapNotifier();

      expect(notifier.state.stations.length, 4);
      expect(notifier.state.batteryHealthPercent, 94);
      expect(notifier.state.hasActiveReservation, isFalse);

      final initialIkejaPacks = notifier.state.stations.firstWhere((s) => s.id == 'st_ikeja').availablePacks;

      // Reserve slot
      final reserved = notifier.reserveSlot('st_ikeja');
      expect(reserved, isTrue);
      expect(notifier.state.hasActiveReservation, isTrue);
      expect(notifier.state.reservedStationId, 'st_ikeja');

      final reservedIkejaPacks = notifier.state.stations.firstWhere((s) => s.id == 'st_ikeja').availablePacks;
      expect(reservedIkejaPacks, initialIkejaPacks - 1);

      // Cancel reservation
      notifier.cancelReservation();
      expect(notifier.state.hasActiveReservation, isFalse);
      expect(notifier.state.reservedStationId, isNull);

      final restoredIkejaPacks = notifier.state.stations.firstWhere((s) => s.id == 'st_ikeja').availablePacks;
      expect(restoredIkejaPacks, initialIkejaPacks);

      // QR unlock locker door #4
      final locker = await notifier.unlockLockerWithQr('SWAP-QR-001');
      expect(locker, 4);
      expect(notifier.state.batteryHealthPercent, 100);
      expect(notifier.state.estimatedRangeKm, 85);
    });

    testWidgets('simulates RiderEarningsScreen weekly payout card, ledger, and instant payout execution', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
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

      await tester.tap(find.text('Request Instant Payout'));
      await tester.pumpAndSettle();

      expect(find.text('Instant Payout Request'), findsOneWidget);
      expect(find.text('Confirm ₦20,000'), findsOneWidget);

      await tester.tap(find.text('Confirm ₦20,000'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Instant payout of ₦20,000 sent'), findsOneWidget);
      expect(find.textContaining('66,400'), findsOneWidget);
    });

    testWidgets('simulates BatterySwapScreen stations, slot reservation, and QR locker unlock', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
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

      // Reserve slot
      final reserveButtons = find.text('Reserve Slot (15 min)');
      expect(reserveButtons, findsWidgets);

      await tester.tap(reserveButtons.first);
      await tester.pumpAndSettle();

      expect(find.textContaining('Active Reservation: Ikeja Central Kiosk'), findsOneWidget);

      // Unlock via QR
      await tester.tap(find.text('Unlock'));
      await tester.pumpAndSettle();

      expect(find.text('Scan Kiosk Station QR Code'), findsOneWidget);
      expect(find.text('Simulate Kiosk Scan & Unlock Door'), findsOneWidget);

      await tester.tap(find.text('Simulate Kiosk Scan & Unlock Door'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Locker #4 Unlocked!'), findsOneWidget);
      expect(find.textContaining('100% (Good Health)'), findsOneWidget);
    });
  });

  // ==========================================================================
  // SIMULATION 5: RIDER PROFILE, EMERGENCY SOS & SYSTEM BOOT (RD24 - RD26)
  // ==========================================================================
  group('Simulation 5: Rider Profile, Emergency SOS & System Boot (RD24 - RD26)', () {
    testWidgets('simulates RiderProfileScreen certifications, ratings, and Emergency SOS broadcast', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
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

      // Emergency SOS broadcast trigger
      await tester.tap(find.text('Emergency SOS & Incident Response'));
      await tester.pumpAndSettle();

      expect(find.text('EMERGENCY SOS'), findsOneWidget);
      expect(find.textContaining('Lagos Police & Ambulance: 112'), findsOneWidget);
      expect(find.text('BROADCAST SOS'), findsOneWidget);

      await tester.tap(find.text('BROADCAST SOS'));
      await tester.pumpAndSettle();

      expect(find.textContaining('SOS Alert Broadcast!'), findsOneWidget);
    });

    testWidgets('simulates complete RiderApp cold boot into router and Welcome Screen', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appConfigProvider.overrideWithValue(testConfig),
            apiClientProvider.overrideWithValue(testApiClient),
            riderRepositoryProvider.overrideWithValue(testRiderRepo),
          ],
          child: const RiderApp(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Ride Green. Earn Fair. Power Lagos.'), findsOneWidget);
      expect(find.text('Apply to Ride with Go-Volts'), findsOneWidget);
    });
  });
}
