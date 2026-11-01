import 'package:app_models/app_models.dart';
import 'package:customer_app/src/features/errand/application/shopping_errand_notifier.dart';
import 'package:customer_app/src/features/errand/data/errand_repository.dart';
import 'package:customer_app/src/features/errand/presentation/home/market_errand_home_screen.dart';
import 'package:customer_app/src/features/errand/presentation/flow_a_shopping/select_shop_screen.dart';
import 'package:customer_app/src/features/errand/presentation/flow_a_shopping/add_items_screen.dart';
import 'package:customer_app/src/features/errand/presentation/flow_a_shopping/shopping_preferences_screen.dart';
import 'package:customer_app/src/features/errand/presentation/flow_a_shopping/shopping_delivery_screen.dart';
import 'package:customer_app/src/features/errand/presentation/flow_a_shopping/shopping_review_screen.dart';
import 'package:customer_app/src/features/errand/presentation/flow_a_shopping/shopping_tracking_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class MockErrandRepository implements ErrandRepository {
  @override
  Future<ErrandCatalogueDto> getCatalogue() async {
    return const ErrandCatalogueDto(
      shops: [
        ShopDto(
          id: 'shop_01',
          name: 'Kakuri Main Market',
          address: 'Kakuri, Kaduna',
          latitude: 10.4682,
          longitude: 7.4201,
          category: 'Open Market',
          distanceKm: 1.2,
          isPopular: true,
          isSaved: true,
        ),
      ],
    );
  }

  @override
  Future<List<ShopDto>> getShops({String? search, String? tab, double? lat, double? lng}) async {
    return const [
      ShopDto(
        id: 'shop_01',
        name: 'Kakuri Main Market',
        address: 'Kakuri, Kaduna',
        latitude: 10.4682,
        longitude: 7.4201,
        category: 'Open Market',
        distanceKm: 1.2,
        isPopular: true,
        isSaved: true,
      ),
      ShopDto(
        id: 'shop_02',
        name: 'Murtala Supermarket',
        address: 'Murtala Square, Kaduna',
        latitude: 10.5185,
        longitude: 7.4382,
        category: 'Supermarket',
        distanceKm: 2.4,
        isPopular: true,
        isSaved: false,
      ),
    ];
  }

  @override
  Future<ErrandQuoteDto> requestQuote(Map<String, dynamic> quotePayload) async {
    return const ErrandQuoteDto(
      id: 'quote_mock',
      errandType: ErrandType.buyItems,
      estimatedItemsCostKobo: 1400000, // ₦14,000
      serviceFeeKobo: 80000,           // ₦800
      deliveryFeeKobo: 120000,         // ₦1,200
      totalKobo: 1600000,              // ₦16,000
      distanceKm: 2.5,
    );
  }

  @override
  Future<ErrandDto> createErrand(Map<String, dynamic> errandPayload) async {
    return ErrandDto(
      id: 'err_test_01',
      referenceNumber: 'ERR-82910',
      customerId: 'cust_01',
      type: ErrandType.buyItems,
      status: ErrandStatus.agentAssigned,
      deliveryLocation: const LocationDto(
        latitude: 10.5185,
        longitude: 7.4382,
        address: '3, Ahmadu Bello Way, Bayero University, Kaduna',
      ),
      recipient: const RecipientDetailsDto(
        fullName: 'Omotayo Kehinde',
        phoneNumber: '0803 456 7890',
        deliveryAddress: '3, Ahmadu Bello Way, Bayero University, Kaduna',
      ),
      quote: const ErrandQuoteDto(
        id: 'quote_test',
        errandType: ErrandType.buyItems,
        estimatedItemsCostKobo: 1400000,
        serviceFeeKobo: 80000,
        deliveryFeeKobo: 120000,
        totalKobo: 1600000,
      ),
      assignedRider: const RiderDto(
        id: 'rider_01',
        profileId: 'prof_01',
        fullName: 'Ahmed Ibrahim',
        phoneNumber: '0803 456 7890',
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
  Future<ErrandDto> advanceStatus(String id) async => throw UnimplementedError();
  @override
  Future<ErrandDto> cancelErrand(String id) async => throw UnimplementedError();
  @override
  Future<bool> rateErrand(String id, double rating) async => true;
}

Widget _wrap(Widget child, [List<Override> overrides = const []]) {
  return ProviderScope(
    overrides: [
      errandRepositoryProvider.overrideWithValue(MockErrandRepository()),
      ...overrides,
    ],
    child: MaterialApp(
      home: child,
    ),
  );
}

void main() {
  group('Flow A: ShoppingErrandNotifier Unit Tests', () {
    late MockErrandRepository mockRepo;
    late ShoppingErrandNotifier notifier;

    setUp(() {
      mockRepo = MockErrandRepository();
      notifier = ShoppingErrandNotifier(repository: mockRepo);
    });

    test('initial state has default shopping items and budget', () {
      expect(notifier.state.items, isNotEmpty);
      expect(notifier.state.items.first.name, 'Tomatoes');
      expect(notifier.state.totalEstimatedItemsKobo, 1400000); // ₦14,000
    });

    test('selectShop updates selected shop and calculates quote', () {
      const shop = ShopDto(
        id: 'shop_02',
        name: 'Murtala Supermarket',
        address: 'Murtala Square, Kaduna',
        latitude: 10.5185,
        longitude: 7.4382,
        distanceKm: 2.4,
      );
      notifier.selectShop(shop);
      expect(notifier.state.selectedShop?.id, 'shop_02');
      expect(notifier.state.canProceedFromShop, isTrue);
    });

    test('addItem, removeItem, incrementQuantity, decrementQuantity', () {
      const newItem = ShoppingItemDto(
        id: 'item_new',
        name: 'Fresh Fish',
        quantity: 1,
        unit: 'kg',
        estimatedPriceKobo: 300000,
      );

      notifier.addItem(newItem);
      expect(notifier.state.items.any((i) => i.id == 'item_new'), isTrue);

      notifier.incrementQuantity('item_new');
      expect(
        notifier.state.items.firstWhere((i) => i.id == 'item_new').quantity,
        2,
      );

      notifier.decrementQuantity('item_new');
      expect(
        notifier.state.items.firstWhere((i) => i.id == 'item_new').quantity,
        1,
      );

      notifier.removeItem('item_new');
      expect(notifier.state.items.any((i) => i.id == 'item_new'), isFalse);
    });

    test('setSubstitutionPolicy and setAdditionalInstructions update preferences', () {
      notifier.setSubstitutionPolicy(SubstitutionPolicy.doNotSubstitute);
      expect(
        notifier.state.preferences.substitutionPolicy,
        SubstitutionPolicy.doNotSubstitute,
      );

      notifier.setAdditionalInstructions('Check freshness carefully');
      expect(
        notifier.state.preferences.additionalInstructions,
        'Check freshness carefully',
      );
    });

    test('submitOrder creates errand and sets active errand', () async {
      final success = await notifier.submitOrder();
      expect(success, isTrue);
      expect(notifier.state.activeErrand, isNotNull);
      expect(notifier.state.activeErrand?.status, ErrandStatus.agentAssigned);
      expect(notifier.state.activeErrand?.assignedRider?.fullName, 'Ahmed Ibrahim');
    });

    test('advanceStatusForTesting transitions status', () async {
      await notifier.submitOrder();
      await notifier.advanceStatusForTesting();
      expect(
        notifier.state.activeErrand?.status,
        ErrandStatus.shoppingInProgress,
      );
    });
  });

  group('Flow A: Widget Tests (Screens A1 to A7)', () {
    testWidgets('Screen A1 (MarketErrandHomeScreen) renders options and hero banner', (tester) async {
      await tester.pumpWidget(_wrap(const MarketErrandHomeScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Market Errand'), findsOneWidget);
      expect(find.text('Get things done easily'), findsOneWidget);
      expect(find.text('Buy Items From a Shop'), findsOneWidget);
      expect(find.text('Pick Up a Package'), findsOneWidget);
      expect(find.text('Other Errand'), findsOneWidget);
    });

    testWidgets('Screen A2 (SelectShopScreen) renders shops, tabs and custom shop option', (tester) async {
      await tester.pumpWidget(_wrap(const SelectShopScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Select Shop / Market'), findsOneWidget);
      expect(find.text('Nearby'), findsOneWidget);
      expect(find.text('Popular'), findsOneWidget);
      expect(find.text('Saved'), findsOneWidget);
      expect(find.text('Kakuri Main Market'), findsOneWidget);
      expect(find.text('Use a custom shop'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('Screen A3 (AddItemsScreen) renders item list and Add another item button', (tester) async {
      await tester.pumpWidget(_wrap(const AddItemsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Add Items'), findsOneWidget);
      expect(find.text('Tomatoes'), findsOneWidget);
      expect(find.text('Onions'), findsOneWidget);
      expect(find.text('Rice (Mama\'s Pride)'), findsOneWidget);
      expect(find.text('Add another item'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('Screen A4 (ShoppingPreferencesScreen) renders substitution options', (tester) async {
      await tester.pumpWidget(_wrap(const ShoppingPreferencesScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Shopping Preferences'), findsOneWidget);
      expect(find.text('Substitution preference'), findsOneWidget);
      expect(find.text('Do not substitute'), findsOneWidget);
      expect(find.text('Contact me first'), findsOneWidget);
      expect(find.text('Choose a similar alternative'), findsOneWidget);
      expect(find.text('Additional instructions (optional)'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('Screen A5 (ShoppingDeliveryScreen) renders recipient, address and time fields', (tester) async {
      await tester.pumpWidget(_wrap(const ShoppingDeliveryScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Delivery Details'), findsOneWidget);
      expect(find.text('Delivery address'), findsOneWidget);
      expect(find.text('Recipient'), findsOneWidget);
      expect(find.text('Phone number'), findsOneWidget);
      expect(find.text('Delivery time'), findsOneWidget);
      expect(find.text('As soon as possible'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('Screen A6 (ShoppingReviewScreen) renders breakdown and disclaimer banner', (tester) async {
      await tester.pumpWidget(_wrap(const ShoppingReviewScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Review Order'), findsOneWidget);
      expect(find.text('Shop / Market'), findsOneWidget);
      expect(find.text('Items (3)'), findsOneWidget);
      expect(find.text('Service fee'), findsOneWidget);
      expect(find.text('Delivery fee'), findsOneWidget);
      expect(find.text('Estimated total'), findsOneWidget);
      expect(
        find.text('Final amount may change based on actual item prices and availability.'),
        findsOneWidget,
      );
      expect(find.text('Go-Volts Wallet'), findsOneWidget);
      expect(find.text('Debit / Credit Card (Paystack)'), findsOneWidget);
    });

    testWidgets('Screen A7 (ShoppingTrackingScreen) renders timeline, rider card and shopping in progress', (tester) async {
      await tester.pumpWidget(_wrap(const ShoppingTrackingScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Errand in Progress'), findsOneWidget);
      expect(find.text('Assigned'), findsOneWidget);
      expect(find.text('Shopping'), findsOneWidget);
      expect(find.text('Delivering'), findsOneWidget);
      expect(find.text('Ahmed Ibrahim'), findsOneWidget);
      expect(find.text('Shopping in progress'), findsOneWidget);
    });
  });
}

