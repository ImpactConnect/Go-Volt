import 'package:api_client/api_client.dart';
import 'package:app_config/app_config.dart';
import 'package:app_models/app_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rider_app/main.dart';
import 'package:rider_app/src/core/providers/api_providers.dart';
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

void main() {
  final testConfig = AppConfig.dev();
  final testApiClient = ApiClient(config: testConfig);
  final testRiderRepo = RiderRepository(apiClient: testApiClient);

  group('Phase 2A Unit Tests — Rider Domain & KYC Logic', () {
    test('OnboardingState checks for mandatory regulatory documents', () {
      const stateEmpty = OnboardingState();
      expect(stateEmpty.hasRequiredDocuments, isFalse);

      final stateWithDocs = OnboardingState(
        documents: [
          RiderDocumentDto(
            id: 'd1',
            type: DocumentType.nationalId,
            documentNumber: '12345678901',
            fileUrl: 'https://cdn.govolts.ng/nin.jpg',
            expiryDate: DateTime.now().add(const Duration(days: 400)),
          ),
          RiderDocumentDto(
            id: 'd2',
            type: DocumentType.driversLicense,
            documentNumber: 'DL-992-LAG',
            fileUrl: 'https://cdn.govolts.ng/dl.jpg',
            expiryDate: DateTime.now().add(const Duration(days: 300)),
          ),
          RiderDocumentDto(
            id: 'd3',
            type: DocumentType.vehicleRegistration,
            documentNumber: 'VR-882-EKY',
            fileUrl: 'https://cdn.govolts.ng/vr.jpg',
            expiryDate: DateTime.now().add(const Duration(days: 300)),
          ),
        ],
      );
      expect(stateWithDocs.hasRequiredDocuments, isTrue);
    });

    test('RiderDto blocks going online when battery is low or document expired', () {
      final validRider = testRiderRepo.getRiderProfile();
      expect(validRider, completion(predicate<RiderDto>((r) => r.canGoOnline)));

      // Expired document
      final expiredDocRider = RiderDto(
        id: 'R1',
        profileId: 'U1',
        fullName: 'Test Rider',
        phoneNumber: '+2348011223344',
        vehiclePlate: 'LA-123-AB',
        vehicleModel: 'Spiro EV',
        batteryLevelPercent: 90,
        documents: [
          RiderDocumentDto(
            id: 'D1',
            type: DocumentType.driversLicense,
            documentNumber: '123',
            fileUrl: 'http://url.com',
            expiryDate: DateTime.now().subtract(const Duration(days: 2)),
          ),
        ],
      );
      expect(expiredDocRider.canGoOnline, isFalse);

      // Low battery (< 15%)
      const lowBatteryRider = RiderDto(
        id: 'R2',
        profileId: 'U2',
        fullName: 'Test Rider',
        phoneNumber: '+2348011223344',
        vehiclePlate: 'LA-123-AB',
        vehicleModel: 'Spiro EV',
        batteryLevelPercent: 12, // Critical battery
      );
      expect(lowBatteryRider.canGoOnline, isFalse);
    });

    test('OnboardingNotifier updates details and completes assessment', () async {
      final notifier = OnboardingNotifier(repository: testRiderRepo);

      notifier.updatePersonalDetails(
        fullName: 'Babatunde Fashola',
        phoneNumber: '+2348021122334',
        email: 'tunde@govolts.ng',
        residentialAddress: '24 Marina, Lagos Island',
        lagosLga: 'Lagos Island',
        emergencyContactName: 'Bolaji Fashola',
        emergencyContactPhone: '+2348029988776',
      );

      notifier.updateVehicleDetails(
        vehicleType: VehicleType.electricBike,
        vehiclePlate: 'LA-999-IS',
        vehicleModel: 'Roam Air EV',
        chassisNumber: 'VIN-ROAM-8842',
        batteryCapacityKwh: '3.2 kWh LFP',
      );

      notifier.updateGuarantorDetails(
        fullName: 'Alhaji Gbadamosi',
        phoneNumber: '+2348033344556',
        relationship: 'Business Mentor',
        residentialAddress: 'Broad Street, Lagos',
      );

      notifier.completeTraining(100);

      expect(notifier.state.fullName, 'Babatunde Fashola');
      expect(notifier.state.lagosLga, 'Lagos Island');
      expect(notifier.state.vehiclePlate, 'LA-999-IS');
      expect(notifier.state.guarantor?.fullName, 'Alhaji Gbadamosi');
      expect(notifier.state.trainingCompleted, isTrue);

      final success = await notifier.submitApplication();
      expect(success, isTrue);
      expect(notifier.state.submittedRider, isNotNull);
      expect(notifier.state.currentStep, 5);
    });
  });

  group('Phase 2A Presentation & Widget Tests', () {
    testWidgets('RiderWelcomeScreen renders branding, value props and action buttons',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 1200));

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

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('RiderPersonalScreen renders KYC inputs, LGA selector and emergency contact',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 1400));

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

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('RiderDocumentsScreen renders mandatory documents and upload triggers',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 1400));

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

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('RiderVehicleScreen renders EV type selector and safety checklist',
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

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('RiderGuarantorScreen renders referee fields and consent checkbox',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 1400));

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

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('RiderTrainingScreen renders questions and enables submission on pass',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 2600));

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

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('RiderApplicationStatusScreen renders status checklist and service tier badges',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 2400));

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

      await tester.binding.setSurfaceSize(null);
    });

    testWidgets('RiderApp launches and boots router into Welcome Screen',
        (tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 1200));

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

      await tester.binding.setSurfaceSize(null);
    });
  });
}
