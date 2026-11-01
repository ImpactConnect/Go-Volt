import 'package:app_models/app_models.dart';
import 'package:customer_app/src/core/router/app_router.dart';
import 'package:customer_app/src/features/activity/application/activity_notifier.dart';
import 'package:customer_app/src/features/activity/domain/activity_item.dart';
import 'package:customer_app/src/features/activity/presentation/activity_hub_screen.dart';
import 'package:customer_app/src/features/errand/application/active_errand_provider.dart';
import 'package:customer_app/src/features/errand/application/package_errand_notifier.dart';
import 'package:customer_app/src/features/errand/application/shopping_errand_notifier.dart';
import 'package:customer_app/src/features/errand/data/errand_repository.dart';
import 'package:customer_app/src/features/home/application/home_notifier.dart';
import 'package:customer_app/src/features/home/presentation/home_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class MockErrandRepository implements ErrandRepository {
  @override
  Future<ErrandCatalogueDto> getCatalogue() async => const ErrandCatalogueDto(shops: []);

  @override
  Future<List<ShopDto>> getShops({String? search, String? tab, double? lat, double? lng}) async => [];

  @override
  Future<ErrandQuoteDto> requestQuote(Map<String, dynamic> quotePayload) async {
    return const ErrandQuoteDto(
      id: 'quote_test',
      errandType: ErrandType.buyItems,
      serviceFeeKobo: 80000,
      deliveryFeeKobo: 120000,
      totalKobo: 1600000,
    );
  }

  @override
  Future<ErrandDto> createErrand(Map<String, dynamic> errandPayload) async => throw UnimplementedError();

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

void main() {
  group('Track 3: Active Errand Provider Unit Tests', () {
    test('activeErrandSummaryProvider derives Flow A active shopping summary', () {
      final container = ProviderContainer(
        overrides: [
          shoppingErrandNotifierProvider.overrideWith((ref) {
            final notifier = ShoppingErrandNotifier(repository: MockErrandRepository());
            notifier.state = notifier.state.copyWith(
              activeErrand: ErrandDto(
                id: 'err_shop_01',
                referenceNumber: 'ERR-A-1024',
                customerId: 'cust_01',
                type: ErrandType.buyItems,
                status: ErrandStatus.shoppingInProgress,
                shop: ShopDto(
                  id: 'shop_01',
                  name: 'Kakuri Main Market',
                  address: 'Kakuri, Kaduna',
                  latitude: 10.4682,
                  longitude: 7.4201,
                  category: 'Open Market',
                ),
                items: [
                  ShoppingItemDto(
                    id: 'i1',
                    name: 'Tomatoes',
                    quantity: 2,
                    unit: 'kg',
                    estimatedPriceKobo: 400000,
                  ),
                ],
                deliveryLocation: LocationDto(
                  latitude: 10.5,
                  longitude: 7.4,
                  address: 'Bayero University',
                ),
                recipient: RecipientDetailsDto(
                  fullName: 'Omotayo',
                  phoneNumber: '0800',
                  deliveryAddress: 'Bayero University',
                ),
                quote: ErrandQuoteDto(
                  id: 'q1',
                  errandType: ErrandType.buyItems,
                  serviceFeeKobo: 80000,
                  deliveryFeeKobo: 120000,
                  totalKobo: 1600000,
                ),
                assignedRider: RiderDto(
                  id: 'r1',
                  profileId: 'p1',
                  fullName: 'Ahmed Ibrahim',
                  phoneNumber: '0800',
                  vehicleModel: 'Yamaha EV',
                  vehiclePlate: 'ABC-123KY',
                  rating: 4.8,
                  totalTripsCompleted: 320,
                ),
                createdAt: DateTime.now(),
              ),
            );
            return notifier;
          }),
        ],
      );

      final summary = container.read(activeErrandSummaryProvider);
      expect(summary, isNotNull);
      expect(summary!.referenceCode, 'ERR-A-1024');
      expect(summary.title, 'Buy Items: Kakuri Main Market (1 items)');
      expect(summary.statusBadge, 'Shopping in Progress');
      expect(summary.targetRoute, AppRoutes.errandTracking);
      expect(summary.rider?.fullName, 'Ahmed Ibrahim');
    });

    test('activeErrandSummaryProvider derives Flow B package pickup summary', () {
      final container = ProviderContainer(
        overrides: [
          packageErrandNotifierProvider.overrideWith((ref) {
            final notifier = PackageErrandNotifier(repository: MockErrandRepository());
            notifier.state = notifier.state.copyWith(
              activeErrand: ErrandDto(
                id: 'err_pkg_01',
                referenceNumber: 'ERR-B-7788',
                customerId: 'cust_01',
                type: ErrandType.pickupPackage,
                status: ErrandStatus.outForDelivery,
                pickupDetails: const PackagePickupDetailsDto(
                  pickupBusinessName: 'Jumia Pickup Point, Barnawa',
                  address: 'Barnawa, Kaduna',
                  latitude: 10.4851,
                  longitude: 7.4294,
                  contactPerson: 'Sani Musa',
                  phoneNumber: '0806',
                ),
                deliveryLocation: const LocationDto(
                  latitude: 10.5,
                  longitude: 7.4,
                  address: 'Power Plant',
                ),
                recipient: const RecipientDetailsDto(
                  fullName: 'Omotayo',
                  phoneNumber: '0800',
                  deliveryAddress: 'Power Plant',
                ),
                quote: const ErrandQuoteDto(
                  id: 'q2',
                  errandType: ErrandType.pickupPackage,
                  serviceFeeKobo: 70000,
                  deliveryFeeKobo: 110000,
                  totalKobo: 180000,
                ),
                assignedRider: const RiderDto(
                  id: 'r1',
                  profileId: 'p1',
                  fullName: 'Ahmed Ibrahim',
                  phoneNumber: '0800',
                  vehicleModel: 'Yamaha EV',
                  vehiclePlate: 'ABC-123KY',
                  rating: 4.8,
                  totalTripsCompleted: 320,
                ),
                createdAt: DateTime.now(),
              ),
            );
            return notifier;
          }),
        ],
      );

      final summary = container.read(activeErrandSummaryProvider);
      expect(summary, isNotNull);
      expect(summary!.referenceCode, 'ERR-B-7788');
      expect(summary.title, 'Package Pickup: Jumia Pickup Point');
      expect(summary.targetRoute, AppRoutes.errandPackageTracking);
    });
  });

  group('Track 3: ActivityItem.fromErrand Mapping Tests', () {
    test('ActivityItem maps shopping errand to active activity entity', () {
      final errand = ErrandDto(
        id: 'err_100',
        referenceNumber: 'ERR-REF-001',
        customerId: 'cust_01',
        type: ErrandType.buyItems,
        status: ErrandStatus.shoppingInProgress,
        shop: const ShopDto(
          id: 's1',
          name: 'Kakuri Market',
          address: 'Kakuri, Kaduna',
          latitude: 10.4,
          longitude: 7.4,
          category: 'Open Market',
        ),
        deliveryLocation: const LocationDto(
          latitude: 10.5,
          longitude: 7.4,
          address: 'Kaduna South',
        ),
        recipient: const RecipientDetailsDto(
          fullName: 'Bello',
          phoneNumber: '0802',
          deliveryAddress: 'Kaduna South',
        ),
        quote: const ErrandQuoteDto(
          id: 'q1',
          errandType: ErrandType.buyItems,
          serviceFeeKobo: 80000,
          deliveryFeeKobo: 120000,
          totalKobo: 1600000,
        ),
        assignedRider: const RiderDto(
          id: 'r1',
          profileId: 'p1',
          fullName: 'Ahmed Ibrahim',
          phoneNumber: '0800',
          vehicleModel: 'Yamaha EV',
          vehiclePlate: 'ABC-123KY',
          rating: 4.8,
          totalTripsCompleted: 320,
        ),
        createdAt: DateTime.now(),
      );

      final activity = ActivityItem.fromErrand(errand);
      expect(activity.id, 'err_100');
      expect(activity.reference, 'ERR-REF-001');
      expect(activity.serviceType, ActivityServiceType.errand);
      expect(activity.status, ActivityStatus.active);
      expect(activity.title, 'Buy Items: Kakuri Market');
      expect(activity.driverName, 'Ahmed Ibrahim');
      expect(activity.fareKobo, 1600000);
      expect(activity.formattedFare, '₦16000');
    });
  });

  group('Track 3: UI Rendering Tests for Activity Hub & Home Dashboard', () {
    testWidgets('ActivityHubScreen renders Errands filter pill and filters errand items',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      final notifier = ActivityNotifier();
      notifier.addOrUpdateErrand(ErrandDto(
        id: 'act-act-003',
        referenceNumber: 'ERR-A-1024',
        customerId: 'cust_01',
        type: ErrandType.buyItems,
        status: ErrandStatus.shoppingInProgress,
        shop: const ShopDto(
          id: 'shop_01',
          name: 'Kakuri Main Market',
          address: 'Kakuri, Kaduna',
          latitude: 10.4682,
          longitude: 7.4201,
          category: 'Open Market',
        ),
        deliveryLocation: const LocationDto(
          latitude: 10.5,
          longitude: 7.4,
          address: 'Bayero University',
        ),
        recipient: const RecipientDetailsDto(
          fullName: 'Omotayo',
          phoneNumber: '0800',
          deliveryAddress: 'Bayero University',
        ),
        quote: const ErrandQuoteDto(
          id: 'q1',
          errandType: ErrandType.buyItems,
          serviceFeeKobo: 80000,
          deliveryFeeKobo: 120000,
          totalKobo: 1600000,
        ),
        assignedRider: const RiderDto(
          id: 'r1',
          profileId: 'p1',
          fullName: 'Ahmed Ibrahim',
          phoneNumber: '0800',
          vehicleModel: 'Yamaha EV',
          vehiclePlate: 'ABC-123KY',
          rating: 4.8,
          totalTripsCompleted: 320,
        ),
        createdAt: DateTime.now(),
      ));

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activityNotifierProvider.overrideWith(
              (ref) => notifier,
            ),
          ],
          child: const MaterialApp(
            home: ActivityHubScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Errands'), findsOneWidget);

      // Tap on Active tab
      await tester.tap(find.textContaining('Active'));
      await tester.pumpAndSettle();

      // Tap on Errands service pill
      await tester.ensureVisible(find.text('Errands'));
      await tester.tap(find.text('Errands'), warnIfMissed: false);
      await tester.pumpAndSettle();

      // Verify active errand card is shown
      expect(find.text('Buy Items: Kakuri Main Market'), findsOneWidget);
    });

    testWidgets('HomeDashboardScreen renders persistent errand live tracker hero card',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);

      HomeDashboardScreen.resetPromptSession();

      final summary = ActiveErrandSummary(
        errandId: 'err_live_01',
        referenceCode: 'ERR-A-1024',
        type: ErrandType.buyItems,
        title: 'Buy Items: Kakuri Main Market (3 items)',
        statusBadge: 'Shopping in Progress',
        statusMessage: 'Shopping in progress at Kakuri Main Market',
        targetRoute: AppRoutes.errandTracking,
        rider: const RiderDto(
          id: 'r1',
          profileId: 'p1',
          fullName: 'Ahmed Ibrahim',
          phoneNumber: '0800',
          vehicleModel: 'Yamaha EV',
          vehiclePlate: 'ABC-123KY',
          rating: 4.8,
          totalTripsCompleted: 320,
        ),
        etaMinutes: 15,
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            activeErrandSummaryProvider.overrideWithValue(summary),
            homeNotifierProvider.overrideWith(
              (ref) => HomeNotifier(initialSavedPlaces: HomeNotifier.defaultSavedPlaces),
            ),
          ],
          child: const MaterialApp(
            home: HomeDashboardScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Active Errand'), findsOneWidget);
      expect(find.text('Shopping in Progress'), findsOneWidget);
      expect(find.text('Buy Items: Kakuri Main Market (3 items)'), findsOneWidget);
      expect(find.text('Track Errand Live'), findsOneWidget);
      expect(find.text('Ahmed Ibrahim'), findsOneWidget);
      expect(find.text('ETA 15m'), findsOneWidget);
    });
  });
}
