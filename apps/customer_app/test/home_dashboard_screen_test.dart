import 'package:api_client/api_client.dart';
import 'package:app_config/app_config.dart';
import 'package:app_models/app_models.dart';
import 'package:customer_app/src/core/auth/auth_notifier.dart';
import 'package:customer_app/src/core/auth/auth_state.dart';
import 'package:customer_app/src/core/auth/supabase_auth_service.dart';
import 'package:customer_app/src/features/booking/application/booking_notifier.dart';
import 'package:customer_app/src/features/booking/data/booking_repository.dart';
import 'package:customer_app/src/features/home/application/home_notifier.dart';
import 'package:customer_app/src/features/home/application/notifications_notifier.dart';
import 'package:customer_app/src/features/home/presentation/home_dashboard_screen.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

class _FakeSupabaseAuthService extends SupabaseAuthService {
  @override
  bool get isInitialized => true;
}

class _FakeBookingRepository extends BookingRepository {
  _FakeBookingRepository()
    : super(client: ApiClient(config: AppConfig.staging()));
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  late _FakeSupabaseAuthService fakeAuthService;
  late AuthNotifier authNotifier;
  late HomeNotifier homeNotifier;
  late NotificationsNotifier notificationsNotifier;
  late BookingNotifier bookingNotifier;

  setUp(() {
    fakeAuthService = _FakeSupabaseAuthService();
    authNotifier = AuthNotifier(authService: fakeAuthService);
    authNotifier.state = const AuthState(
      status: AuthStatus.authenticated,
      profile: ProfileDto(
        id: 'usr_alex_123',
        fullName: 'Alex Johnson',
        phoneNumber: '+2348012345678',
        email: 'alex@example.com',
        ecoPointsBalance: 1250,
      ),
    );

    HomeDashboardScreen.resetPromptSession();
    homeNotifier = HomeNotifier(
      initialSavedPlaces: HomeNotifier.defaultSavedPlaces,
    );
    notificationsNotifier = NotificationsNotifier(
      initialNotifications: NotificationsNotifier.defaultNotifications,
    );
    bookingNotifier = BookingNotifier(repository: _FakeBookingRepository());
  });

  Widget createWidget({ThemeData? theme}) {
    return ProviderScope(
      overrides: [
        authNotifierProvider.overrideWith((ref) => authNotifier),
        homeNotifierProvider.overrideWith((ref) => homeNotifier),
        notificationsNotifierProvider.overrideWith(
          (ref) => notificationsNotifier,
        ),
        bookingNotifierProvider.overrideWith((ref) => bookingNotifier),
      ],
      child: MaterialApp(
        theme: theme ?? GVTheme.light,
        home: const HomeDashboardScreen(),
      ),
    );
  }

  group('Screen 11: HOME-01-DEFAULT (Default Home Dashboard)', () {
    testWidgets(
      'renders header, dynamic greeting, location, 2x2 grid, discount banner, saved places and rewards',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        // Brand wordmark
        expect(find.text('GO-VOLTS'), findsOneWidget);

        // Notification bell icon & unread badge
        expect(find.byIcon(Icons.notifications_none_rounded), findsOneWidget);
        expect(
          find.text('3'),
          findsOneWidget,
        ); // 3 unread default notifications

        // Avatar initials for "Alex Johnson"
        expect(find.text('AJ'), findsOneWidget);

        // Time-aware dynamic greeting & subhead
        expect(find.textContaining('Alex!'), findsOneWidget);
        expect(find.text('Where would you like to go today?'), findsOneWidget);

        // Current location card
        expect(find.text('Your location'), findsOneWidget);
        expect(find.text('Shaganu, Ogun'), findsWidgets);

        // Headline
        expect(find.text('What would you like to do?'), findsOneWidget);

        // 4 Service cards in 2x2 grid
        expect(find.text('Book a Ride'), findsOneWidget);
        expect(find.text('Send a Parcel'), findsOneWidget);
        expect(find.text('Track Delivery'), findsOneWidget);
        expect(find.text('Scheduled Pickup'), findsOneWidget);

        // Book a Ride should be fully available in Victoria Island
        expect(find.text('Currently unavailable'), findsNothing);

        // Active booking should NOT be rendered in default view
        expect(find.text('Your active booking'), findsNothing);

        // Discount campaign banner
        expect(find.text('Save 20% on your next ride'), findsOneWidget);
        expect(find.text('Use code GO20'), findsOneWidget);
        expect(find.text('Learn more'), findsOneWidget);

        // Saved places row
        expect(find.text('Your saved places'), findsOneWidget);
        expect(find.text('Home'), findsOneWidget);
        expect(find.text('Work'), findsOneWidget);

        // Rewards summary widget
        expect(find.text('Your rewards'), findsOneWidget);
        expect(find.text('1250 pts'), findsOneWidget);
        expect(find.text('View all'), findsOneWidget);
      },
    );
  });

  group('Screen 12: HOME-02-ACTIVE-BOOKING (Active Booking State)', () {
    testWidgets(
      'renders hero GVActiveBookingCard when active booking is in progress',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        homeNotifier.setSampleActiveBooking();

        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        // Active booking hero card elements
        expect(find.text('Your active booking'), findsOneWidget);
        expect(find.text('In progress'), findsOneWidget);
        expect(find.text('Ride booking'), findsOneWidget);
        expect(find.text('GV-824755'), findsOneWidget);
        expect(find.text('Babajide S.'), findsOneWidget);
        expect(find.text('Rider approaching'), findsOneWidget);
        expect(find.text('ETA 3 mins'), findsOneWidget);
        expect(find.text('View on map'), findsOneWidget);
      },
    );
  });

  group('Screen 13: HOME-03-SERVICE-UNAVAILABLE (Service Restriction State)', () {
    testWidgets(
      'disables Book a Ride with unavailable pill and switches banner to referral',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        // Switch to a limited area (where instant rides are unavailable)
        const limitedArea = ServiceAreaDto(
          id: 'test-limited',
          name: 'Limited Zone',
          state: 'Ogun',
          status: ServiceAreaStatus.limited,
          statusDescription: 'Limited services',
          availableServices: [
            ServiceCode.instantDelivery,
            ServiceCode.scheduledPickup,
          ],
        );
        homeNotifier.selectLocation(limitedArea);

        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        // Current location is now Limited Zone, Ogun
        expect(find.text('Limited Zone, Ogun'), findsOneWidget);

        // Book a Ride is disabled with red unavailable pill and reason
        expect(find.text('Currently unavailable'), findsOneWidget);
        expect(find.text('Not available in this area'), findsOneWidget);

        // Other services remain available
        expect(find.text('Send a Parcel'), findsOneWidget);
        expect(find.text('Track Delivery'), findsOneWidget);
        expect(find.text('Scheduled Pickup'), findsOneWidget);

        // Campaign banner dynamically switched to referral reward banner
        expect(find.text('Refer a friend, get 500 points'), findsOneWidget);
        expect(find.text('Invite friends and earn rewards'), findsOneWidget);
        expect(find.text('Refer now'), findsOneWidget);

        // Discount banner is no longer active
        expect(find.text('Save 20% on your next ride'), findsNothing);
      },
    );
  });

  group('Interactive Location Selector Bottom Sheet', () {
    testWidgets(
      'opens bottom sheet and switches location to Shaganu dynamically',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(createWidget());
        await tester.pumpAndSettle();

        // Tap location selector card
        await tester.tap(find.text('Your location'));
        await tester.pumpAndSettle();

        // Verify modal sheet opened
        expect(find.text('Select your location'), findsOneWidget);
        expect(find.text('Shaganu, Ogun'), findsWidgets);
        expect(find.text('Fully supported'), findsWidgets);

        // Tap on Shaganu in the sheet
        await tester.tap(find.text('Shaganu, Ogun').last);
        await tester.pumpAndSettle();

        // Tap Confirm location CTA
        await tester.tap(find.text('Confirm location'));
        await tester.pumpAndSettle();

        // Sheet should be dismissed and Dashboard now active
        expect(find.text('Select your location'), findsNothing);
        expect(find.text('Ikoyi, Lagos'), findsOneWidget);
        expect(find.text('Currently unavailable'), findsOneWidget);
      },
    );
  });

  group('Theme Parity (Light vs Dark)', () {
    testWidgets('renders cleanly in dark theme without overflow or errors', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(createWidget(theme: GVTheme.dark));
      await tester.pumpAndSettle();

      expect(find.text('GO-VOLTS'), findsOneWidget);
      expect(find.text('What would you like to do?'), findsOneWidget);
    });
  });
}
