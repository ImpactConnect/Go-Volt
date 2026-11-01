import 'package:app_models/app_models.dart';
import 'package:customer_app/src/features/home/application/home_notifier.dart';
import 'package:customer_app/src/features/home/application/notifications_notifier.dart';
import 'package:customer_app/src/features/home/presentation/location_selector_modal.dart';
import 'package:customer_app/src/features/home/presentation/notifications_screen.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  late HomeNotifier homeNotifier;
  late NotificationsNotifier notificationsNotifier;

  setUp(() {
    homeNotifier = HomeNotifier(
      initialSavedPlaces: const [
        SavedPlaceDto(
          id: 'place_home',
          label: 'Home',
          address: 'Shaganu, Ogun',
          type: SavedPlaceType.home,
          latitude: 6.8403,
          longitude: 3.6487,
        ),
        SavedPlaceDto(
          id: 'place_work',
          label: 'Work',
          address: 'Market Road, Shaganu, Ogun',
          type: SavedPlaceType.work,
          latitude: 6.8435,
          longitude: 3.6510,
        ),
      ],
    );
    notificationsNotifier = NotificationsNotifier(
        initialNotifications: NotificationsNotifier.defaultNotifications);
  });

  Widget buildTestWidget({
    required Widget child,
    ThemeData? theme,
  }) {
    return ProviderScope(
      overrides: [
        homeNotifierProvider.overrideWith((ref) => homeNotifier),
        notificationsNotifierProvider
            .overrideWith((ref) => notificationsNotifier),
      ],
      child: MaterialApp(
        theme: theme ?? GVTheme.light,
        home: Scaffold(body: child),
      ),
    );
  }

  group('Screen 14: HOME-06-LOCATION-SELECTOR (LocationSelectorModal)', () {
    testWidgets('renders all modal components matching Screen 14 design',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestWidget(child: const LocationSelectorModal()),
      );
      await tester.pumpAndSettle();

      // Heading and close icon
      expect(find.text('Select your location'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsOneWidget);

      // Segmented Tabs: [Current location] | [Search address]
      expect(find.text('Current location'), findsOneWidget);
      expect(find.text('Search address'), findsOneWidget);

      // Address Search bar
      expect(find.text('Search for an address'), findsOneWidget);

      // GPS option tile
      expect(find.text('Use current location'), findsOneWidget);
      expect(find.text('Detected via GPS'), findsOneWidget);

      // Saved locations
      expect(find.text('Saved locations'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Add new address'), findsOneWidget);

      // Service areas with live status badges
      expect(find.text('Service areas'), findsOneWidget);
      expect(find.text('Shaganu, Ogun'), findsWidgets);

      // Status badges
      expect(find.text('Fully supported'), findsWidgets);

      // Confirm button
      expect(find.text('Confirm location'), findsOneWidget);
    });

    testWidgets('search filters saved places and service areas in real time',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestWidget(child: const LocationSelectorModal()),
      );
      await tester.pumpAndSettle();

      // Enter search query "Shaganu"
      await tester.enterText(
        find.widgetWithText(TextField, 'Search for an address'),
        'Shaganu',
      );
      await tester.pumpAndSettle();

      // Shaganu should match
      expect(find.text('Shaganu, Ogun'), findsWidgets);
    });

    testWidgets('selecting a service area and confirming updates homeNotifier',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestWidget(child: const LocationSelectorModal()),
      );
      await tester.pumpAndSettle();

      // Tap on Shaganu area tile
      await tester.tap(find.text('Shaganu, Ogun').first);
      await tester.pumpAndSettle();

      // Tap Confirm location
      await tester.tap(find.text('Confirm location'));
      await tester.pumpAndSettle();

      // Verify HomeNotifier state updated
      expect(homeNotifier.state.currentLocation.id, 'ogun-shaganu');
      expect(homeNotifier.state.currentLocation.name, 'Shaganu');
    });

    testWidgets('renders cleanly in dark theme without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestWidget(
          theme: GVTheme.dark,
          child: const LocationSelectorModal(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Select your location'), findsOneWidget);
      expect(find.text('Confirm location'), findsOneWidget);
    });
  });

  group('Screen 15: HOME-07-NOTIFICATIONS (NotificationsScreen)', () {
    testWidgets('renders all initial notifications and unread badge status',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestWidget(child: const NotificationsScreen()),
      );
      await tester.pumpAndSettle();

      // AppBar Title & Action
      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Mark all read'), findsOneWidget);

      // Filter Chips
      expect(find.text('All'), findsOneWidget);
      expect(find.text('Bookings'), findsOneWidget);
      expect(find.text('Promotions'), findsOneWidget);
      expect(find.text('Account'), findsOneWidget);

      // All 5 initial notification items
      expect(find.text('Rider approaching'), findsOneWidget);
      expect(find.text('Delivery completed'), findsOneWidget);
      expect(find.text('Special offer'), findsOneWidget);
      expect(find.text('Reward points earned'), findsOneWidget);
      expect(find.text('Account verified'), findsOneWidget);

      // Initial unread count is 3
      expect(notificationsNotifier.state.unreadCount, 3);
    });

    testWidgets('filters notifications by category tab correctly',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestWidget(child: const NotificationsScreen()),
      );
      await tester.pumpAndSettle();

      // Tap "Bookings" category
      await tester.tap(find.text('Bookings'));
      await tester.pumpAndSettle();

      expect(find.text('Rider approaching'), findsOneWidget);
      expect(find.text('Delivery completed'), findsOneWidget);
      expect(find.text('Special offer'), findsNothing);
      expect(find.text('Account verified'), findsNothing);

      // Tap "Promotions" category
      await tester.tap(find.text('Promotions'));
      await tester.pumpAndSettle();

      expect(find.text('Special offer'), findsOneWidget);
      expect(find.text('Rider approaching'), findsNothing);

      // Tap "Account" category
      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle();

      expect(find.text('Reward points earned'), findsOneWidget);
      expect(find.text('Account verified'), findsOneWidget);
      expect(find.text('Special offer'), findsNothing);

      // Tap "All" to restore
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      expect(find.text('Rider approaching'), findsOneWidget);
      expect(find.text('Special offer'), findsOneWidget);
    });

    testWidgets('tapping an unread notification marks it as read',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestWidget(child: const NotificationsScreen()),
      );
      await tester.pumpAndSettle();

      expect(notificationsNotifier.state.unreadCount, 3);

      // Tap unread notification 'Rider approaching'
      await tester.tap(find.text('Rider approaching'));
      await tester.pumpAndSettle();

      // Unread count should decrease to 2
      expect(notificationsNotifier.state.unreadCount, 2);
    });

    testWidgets('tapping "Mark all read" marks all notifications as read',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestWidget(child: const NotificationsScreen()),
      );
      await tester.pumpAndSettle();

      expect(notificationsNotifier.state.unreadCount, 3);

      // Tap Mark all read
      await tester.tap(find.text('Mark all read'));
      await tester.pumpAndSettle();

      // All should now be read
      expect(notificationsNotifier.state.unreadCount, 0);
    });

    testWidgets('renders cleanly in dark theme without overflow',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        buildTestWidget(
          theme: GVTheme.dark,
          child: const NotificationsScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('All'), findsOneWidget);
    });
  });
}
