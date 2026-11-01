import 'package:app_models/app_models.dart';
import 'package:customer_app/src/features/errand/application/package_errand_notifier.dart';
import 'package:customer_app/src/features/errand/data/errand_repository.dart';
import 'package:customer_app/src/features/errand/presentation/flow_b_package/package_delivery_screen.dart';
import 'package:customer_app/src/features/errand/presentation/flow_b_package/package_details_screen.dart';
import 'package:customer_app/src/features/errand/presentation/flow_b_package/package_pickup_screen.dart';
import 'package:customer_app/src/features/errand/presentation/flow_b_package/package_review_screen.dart';
import 'package:customer_app/src/features/errand/presentation/flow_b_package/package_tracking_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class MockErrandRepository implements ErrandRepository {
  @override
  Future<ErrandCatalogueDto> getCatalogue() async {
    return const ErrandCatalogueDto(shops: []);
  }

  @override
  Future<List<ShopDto>> getShops({String? search, String? tab, double? lat, double? lng}) async {
    return const [];
  }

  @override
  Future<ErrandQuoteDto> requestQuote(Map<String, dynamic> quotePayload) async {
    return const ErrandQuoteDto(
      id: 'quote_test_b',
      errandType: ErrandType.pickupPackage,
      serviceFeeKobo: 70000, // ₦700
      deliveryFeeKobo: 110000, // ₦1,100
      totalKobo: 180000, // ₦1,800
      distanceKm: 4.2,
    );
  }

  @override
  Future<ErrandDto> createErrand(Map<String, dynamic> errandPayload) async {
    return ErrandDto(
      id: 'err_pkg_001',
      referenceNumber: 'ERR-B-9988',
      customerId: 'cust_01',
      type: ErrandType.pickupPackage,
      status: ErrandStatus.agentAssigned,
      deliveryLocation: const LocationDto(
        latitude: 10.4921,
        longitude: 7.4112,
        address: '3, De-West Plaza, Power Plant',
      ),
      recipient: const RecipientDetailsDto(
        fullName: 'Omotayo Kehinde',
        phoneNumber: '0803 456 7890',
        deliveryAddress: '3, De-West Plaza, Power Plant',
      ),
      quote: const ErrandQuoteDto(
        id: 'quote_test_b',
        errandType: ErrandType.pickupPackage,
        serviceFeeKobo: 70000,
        deliveryFeeKobo: 110000,
        totalKobo: 180000,
        distanceKm: 4.2,
      ),
      assignedRider: const RiderDto(
        id: 'rider_01',
        profileId: 'prof_ahmed',
        fullName: 'Ahmed Ibrahim',
        phoneNumber: '+234 803 456 7890',
        vehicleModel: 'Yamaha EV',
        vehiclePlate: 'ABC-123KY',
        rating: 4.8,
        totalTripsCompleted: 320,
      ),
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<ErrandDto> getErrand(String id) async => throw UnimplementedError();

  @override
  Future<List<ErrandDto>> listErrands({String? status}) async => [];

  @override
  Future<ErrandDto> acceptQuote(String id) async => throw UnimplementedError();

  @override
  Future<ErrandDto> declineQuote(String id) async => throw UnimplementedError();

  @override
  Future<ErrandDto> advanceStatus(String id) async {
    return ErrandDto(
      id: id,
      referenceNumber: 'ERR-B-9988',
      customerId: 'cust_01',
      type: ErrandType.pickupPackage,
      status: ErrandStatus.completed,
      deliveryLocation: const LocationDto(
        latitude: 10.4921,
        longitude: 7.4112,
        address: '3, De-West Plaza, Power Plant',
      ),
      recipient: const RecipientDetailsDto(
        fullName: 'Omotayo Kehinde',
        phoneNumber: '0803 456 7890',
        deliveryAddress: '3, De-West Plaza, Power Plant',
      ),
      quote: const ErrandQuoteDto(
        id: 'quote_test_b',
        errandType: ErrandType.pickupPackage,
        serviceFeeKobo: 70000,
        deliveryFeeKobo: 110000,
        totalKobo: 180000,
      ),
      assignedRider: const RiderDto(
        id: 'rider_01',
        profileId: 'prof_ahmed',
        fullName: 'Ahmed Ibrahim',
        phoneNumber: '+234 803 456 7890',
        vehicleModel: 'Yamaha EV',
        vehiclePlate: 'ABC-123KY',
        rating: 4.8,
        totalTripsCompleted: 320,
      ),
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<ErrandDto> cancelErrand(String id) async => throw UnimplementedError();

  @override
  Future<bool> rateErrand(String id, double rating) async => true;
}

void main() {
  group('Flow B: Package Errands Notifier Unit Tests', () {
    late MockErrandRepository mockRepo;

    setUp(() {
      mockRepo = MockErrandRepository();
    });

    test('Initial state contains default pickup and calculates ₦1,800 quote', () async {
      final notifier = PackageErrandNotifier(repository: mockRepo);
      await pumpEventQueue();

      expect(notifier.state.pickupDetails.pickupBusinessName,
          'Jumia Pickup Point, Barnawa');
      expect(notifier.state.quote?.serviceFeeKobo, 70000);
      expect(notifier.state.quote?.deliveryFeeKobo, 110000);
      expect(notifier.state.quote?.totalKobo, 180000);
    });

    test('Updating pickup and package specs sets state correctly', () async {
      final notifier = PackageErrandNotifier(repository: mockRepo);

      notifier.setPickupDetails(
        businessName: 'DHL Express Kaduna',
        address: 'Ahmadu Bello Way, Kaduna',
        contactPerson: 'Musa Bello',
        phoneNumber: '08022223333',
        referenceOrderNumber: 'DHL-991',
      );
      notifier.setPackageSpecs(
        description: 'Important Legal Documents',
        category: 'Documents & Books',
        sizeBand: 'Small (under 20 cm)',
        weightBand: 'Under 1 kg',
        isFragile: false,
        keepUpright: false,
      );

      expect(notifier.state.pickupDetails.pickupBusinessName, 'DHL Express Kaduna');
      expect(notifier.state.pickupDetails.referenceOrderNumber, 'DHL-991');
      expect(notifier.state.packageDescription, 'Important Legal Documents');
      expect(notifier.state.isFragile, false);
    });

    test('confirmAndPay creates errand with assigned rider and total quote', () async {
      final notifier = PackageErrandNotifier(repository: mockRepo);
      final errand = await notifier.confirmAndPay(PaymentMethod.wallet);

      expect(errand.id, 'err_pkg_001');
      expect(errand.assignedRider?.fullName, 'Ahmed Ibrahim');
      expect(notifier.state.activeErrand?.status, ErrandStatus.agentAssigned);
    });

    test('advanceMilestone transitions status', () async {
      final notifier = PackageErrandNotifier(repository: mockRepo);
      await notifier.confirmAndPay(PaymentMethod.wallet);
      await notifier.advanceMilestone();

      expect(notifier.state.activeErrand?.status, ErrandStatus.completed);
    });
  });

  group('Flow B: Screen Widgets Rendering Tests', () {
    late MockErrandRepository mockRepo;

    setUp(() {
      mockRepo = MockErrandRepository();
    });

    Widget createTestApp(Widget child) {
      return ProviderScope(
        overrides: [
          errandRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: MaterialApp(
          home: child,
        ),
      );
    }

    testWidgets('Screen B2: PackagePickupScreen renders pickup fields and Continue CTA',
        (tester) async {
      await tester.pumpWidget(createTestApp(const PackagePickupScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Pickup Details'), findsOneWidget);
      expect(find.text('Pick up from'), findsOneWidget);
      expect(find.text('Address'), findsOneWidget);
      expect(find.text('Contact person'), findsOneWidget);
      expect(find.text('Phone number'), findsOneWidget);
      expect(find.text('Reference / Order No. (optional)'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('Screen B3: ErrandPackageDetailsScreen renders inputs, dropdowns and checkboxes',
        (tester) async {
      await tester.pumpWidget(createTestApp(const ErrandPackageDetailsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Package Details'), findsOneWidget);
      expect(find.text('Package description'), findsOneWidget);
      expect(find.text('Category'), findsOneWidget);
      expect(find.text('Size (approx.)'), findsOneWidget);
      expect(find.text('Weight (approx.)'), findsOneWidget);
      expect(find.text('Fragile / Handle with care'), findsOneWidget);
      expect(find.text('Keep upright'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('Screen B4: PackageDeliveryScreen renders destination and recipient fields',
        (tester) async {
      await tester.pumpWidget(createTestApp(const PackageDeliveryScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Delivery Details'), findsOneWidget);
      expect(find.text('Deliver to'), findsOneWidget);
      expect(find.text('Recipient'), findsOneWidget);
      expect(find.text('Phone number'), findsOneWidget);
      expect(find.text('Delivery instructions'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('Screen B5: PackageReviewScreen renders summary cards and ₦1,800 pricing breakdown',
        (tester) async {
      await tester.pumpWidget(createTestApp(const PackageReviewScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Review Request'), findsOneWidget);
      expect(find.text('Pickup'), findsOneWidget);
      expect(find.text('Deliver to'), findsOneWidget);
      expect(find.text('Package'), findsOneWidget);
      expect(find.text('Service fee'), findsOneWidget);
      expect(find.text('Delivery fee'), findsOneWidget);
      expect(find.text('₦700'), findsOneWidget);
      expect(find.text('₦1,100'), findsOneWidget);
      expect(find.text('₦1,800'), findsOneWidget);
      expect(find.text('Pay ₦1,800'), findsOneWidget);
    });

    testWidgets('Screen B6: PackageTrackingScreen renders stepper, rider card and ETA banner',
        (tester) async {
      final notifier = PackageErrandNotifier(repository: mockRepo);
      await notifier.confirmAndPay(PaymentMethod.wallet);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            errandRepositoryProvider.overrideWithValue(mockRepo),
            packageErrandNotifierProvider.overrideWith((ref) => notifier),
          ],
          child: const MaterialApp(
            home: PackageTrackingScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Package in Transit'), findsOneWidget);
      expect(find.text('Picked Up'), findsOneWidget);
      expect(find.text('In Transit'), findsOneWidget);
      expect(find.text('Delivered'), findsOneWidget);
      expect(find.text('Ahmed Ibrahim'), findsOneWidget);
      expect(find.text('On the way to you'), findsOneWidget);
      expect(find.text('ETA: 12 mins (4.2 km)'), findsOneWidget);
    });
  });
}
