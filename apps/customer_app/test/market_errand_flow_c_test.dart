import 'package:app_models/app_models.dart';
import 'package:customer_app/src/features/errand/application/other_errand_notifier.dart';
import 'package:customer_app/src/features/errand/data/errand_repository.dart';
import 'package:customer_app/src/features/errand/presentation/flow_c_other/custom_errand_tracking_screen.dart';
import 'package:customer_app/src/features/errand/presentation/flow_c_other/describe_errand_screen.dart';
import 'package:customer_app/src/features/errand/presentation/flow_c_other/errand_completed_screen.dart';
import 'package:customer_app/src/features/errand/presentation/flow_c_other/quote_available_screen.dart';
import 'package:customer_app/src/features/errand/presentation/flow_c_other/task_details_screen.dart';
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
      id: 'quote_test_c',
      errandType: ErrandType.otherErrand,
      serviceFeeKobo: 100000, // ₦1,000
      deliveryFeeKobo: 120000, // ₦1,200
      totalKobo: 220000, // ₦2,200
      distanceKm: 3.5,
    );
  }

  @override
  Future<ErrandDto> createErrand(Map<String, dynamic> errandPayload) async {
    return ErrandDto(
      id: 'err_cust_001',
      referenceNumber: 'ERR-C-1002',
      customerId: 'cust_01',
      type: ErrandType.otherErrand,
      status: ErrandStatus.agentAssigned,
      deliveryLocation: const LocationDto(
        latitude: 10.4682,
        longitude: 7.4201,
        address: 'My Home - Kakuri, Kaduna',
      ),
      recipient: const RecipientDetailsDto(
        fullName: 'Mrs. Amina Yusuf',
        phoneNumber: '0806 765 4321',
        deliveryAddress: 'My Home - Kakuri, Kaduna',
      ),
      quote: const ErrandQuoteDto(
        id: 'quote_test_c',
        errandType: ErrandType.otherErrand,
        serviceFeeKobo: 100000,
        deliveryFeeKobo: 120000,
        totalKobo: 220000,
        distanceKm: 3.5,
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
  Future<ErrandDto> declineQuote(String id) async {
    return ErrandDto(
      id: id,
      referenceNumber: 'ERR-C-1002',
      customerId: 'cust_01',
      type: ErrandType.otherErrand,
      status: ErrandStatus.rejected,
      deliveryLocation: const LocationDto(
        latitude: 10.4682,
        longitude: 7.4201,
        address: 'My Home - Kakuri, Kaduna',
      ),
      recipient: const RecipientDetailsDto(
        fullName: 'Mrs. Amina Yusuf',
        phoneNumber: '0806 765 4321',
        deliveryAddress: 'My Home - Kakuri, Kaduna',
      ),
      quote: const ErrandQuoteDto(
        id: 'quote_test_c',
        errandType: ErrandType.otherErrand,
        serviceFeeKobo: 100000,
        deliveryFeeKobo: 120000,
        totalKobo: 220000,
      ),
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<ErrandDto> advanceStatus(String id) async {
    return ErrandDto(
      id: id,
      referenceNumber: 'ERR-C-1002',
      customerId: 'cust_01',
      type: ErrandType.otherErrand,
      status: ErrandStatus.completed,
      deliveryLocation: const LocationDto(
        latitude: 10.4682,
        longitude: 7.4201,
        address: 'My Home - Kakuri, Kaduna',
      ),
      recipient: const RecipientDetailsDto(
        fullName: 'Mrs. Amina Yusuf',
        phoneNumber: '0806 765 4321',
        deliveryAddress: 'My Home - Kakuri, Kaduna',
      ),
      quote: const ErrandQuoteDto(
        id: 'quote_test_c',
        errandType: ErrandType.otherErrand,
        serviceFeeKobo: 100000,
        deliveryFeeKobo: 120000,
        totalKobo: 220000,
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
  group('Flow C: Other Errand Notifier Unit Tests', () {
    late MockErrandRepository mockRepo;

    setUp(() {
      mockRepo = MockErrandRepository();
    });

    test('Initial state contains default description and calculates ₦2,200 quote', () async {
      final notifier = OtherErrandNotifier(repository: mockRepo);
      await pumpEventQueue();

      expect(notifier.state.category, 'Document Collection');
      expect(notifier.state.quote?.serviceFeeKobo, 100000);
      expect(notifier.state.quote?.deliveryFeeKobo, 120000);
      expect(notifier.state.quote?.totalKobo, 220000);
    });

    test('Updating task details sets state properly', () {
      final notifier = OtherErrandNotifier(repository: mockRepo);

      notifier.setDescribeDetails(
        description: 'Collect certificates from the admin office.',
        category: 'Document Collection',
        urgency: ErrandUrgency.express,
      );
      notifier.setTaskDetails(
        pickupAddress: 'Senate Building, Bayero University',
        contactPerson: 'Dr. Kabir',
        phoneNumber: '08012345678',
        deliveryAddress: 'Plot 4, Sabo Area, Kaduna',
        instructions: 'Handle with care.',
      );

      expect(notifier.state.urgency, ErrandUrgency.express);
      expect(notifier.state.pickupLocation.address, 'Senate Building, Bayero University');
      expect(notifier.state.contactPerson, 'Dr. Kabir');
      expect(notifier.state.additionalInstructions, 'Handle with care.');
    });

    test('acceptQuoteAndPay creates active errand and confirms acceptance', () async {
      final notifier = OtherErrandNotifier(repository: mockRepo);
      final errand = await notifier.acceptQuoteAndPay(PaymentMethod.wallet);

      expect(errand.id, 'err_cust_001');
      expect(notifier.state.isQuoteAccepted, true);
      expect(notifier.state.activeErrand?.assignedRider?.fullName, 'Ahmed Ibrahim');
    });

    test('declineQuote clears active errand and resets isQuoteAccepted', () async {
      final notifier = OtherErrandNotifier(repository: mockRepo);
      await notifier.acceptQuoteAndPay(PaymentMethod.wallet);
      await notifier.declineQuote();

      expect(notifier.state.isQuoteAccepted, false);
      expect(notifier.state.activeErrand, isNull);
    });
  });

  group('Flow C: Screen Widgets Rendering Tests', () {
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

    testWidgets('Screen C2: DescribeErrandScreen renders form inputs and counter',
        (tester) async {
      await tester.pumpWidget(createTestApp(const DescribeErrandScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Describe Your Errand'), findsOneWidget);
      expect(find.text('What do you need help with?'), findsOneWidget);
      expect(find.text('Category (optional)'), findsOneWidget);
      expect(find.text('Urgency'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('Screen C3: TaskDetailsScreen renders locations, contact and Submit CTA',
        (tester) async {
      await tester.pumpWidget(createTestApp(const TaskDetailsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Task Details'), findsOneWidget);
      expect(find.text('Pickup location'), findsOneWidget);
      expect(find.text('Contact person'), findsOneWidget);
      expect(find.text('Phone number'), findsOneWidget);
      expect(find.text('Delivery location'), findsOneWidget);
      expect(find.text('Submit Request'), findsOneWidget);
    });

    testWidgets('Screen C4: QuoteAvailableScreen renders fee breakdown and Accept & Decline CTAs',
        (tester) async {
      await tester.pumpWidget(createTestApp(const QuoteAvailableScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Quote Available'), findsWidgets);
      expect(find.text('Errand service fee'), findsOneWidget);
      expect(find.text('Delivery fee'), findsOneWidget);
      expect(find.text('₦1,000'), findsOneWidget);
      expect(find.text('₦1,200'), findsOneWidget);
      expect(find.text('₦2,200'), findsOneWidget);
      expect(find.text('This is a final quote for your errand.'), findsOneWidget);
      expect(find.text('Accept & Pay ₦2,200'), findsOneWidget);
      expect(find.text('Decline'), findsOneWidget);
    });

    testWidgets('Screen C5: CustomErrandTrackingScreen renders stepper and task status banner',
        (tester) async {
      final notifier = OtherErrandNotifier(repository: mockRepo);
      await notifier.acceptQuoteAndPay(PaymentMethod.wallet);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            errandRepositoryProvider.overrideWithValue(mockRepo),
            otherErrandNotifierProvider.overrideWith((ref) => notifier),
          ],
          child: const MaterialApp(
            home: CustomErrandTrackingScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Errand in Progress'), findsOneWidget);
      expect(find.text('Assigned'), findsOneWidget);
      expect(find.text('In Progress'), findsOneWidget);
      expect(find.text('Delivering'), findsOneWidget);
      expect(find.text('Ahmed Ibrahim'), findsOneWidget);
      expect(find.text('Task in progress'), findsOneWidget);
      expect(find.text('Collecting your document now.'), findsOneWidget);
    });

    testWidgets('Screen C6: ErrandCompletedScreen renders success badge, details card and actions',
        (tester) async {
      await tester.pumpWidget(createTestApp(const ErrandCompletedScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Errand Completed!'), findsOneWidget);
      expect(find.text('Your errand has been completed successfully.'), findsOneWidget);
      expect(find.text('Details'), findsOneWidget);
      expect(find.text('Document Collection'), findsOneWidget);
      expect(find.text('₦2,200'), findsOneWidget);
      expect(find.text('Rate Service'), findsOneWidget);
      expect(find.text('View Details'), findsOneWidget);
    });
  });
}

