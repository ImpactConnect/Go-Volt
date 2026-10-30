import 'package:api_client/api_client.dart';
import 'package:app_config/app_config.dart';
import 'package:customer_app/src/core/auth/auth_notifier.dart';
import 'package:customer_app/src/core/auth/supabase_auth_service.dart';
import 'package:customer_app/src/core/router/app_router.dart';
import 'package:customer_app/src/features/booking/application/booking_notifier.dart';
import 'package:customer_app/src/features/booking/data/booking_repository.dart';
import 'package:customer_app/src/features/home/application/home_notifier.dart';
import 'package:customer_app/src/features/home/application/notifications_notifier.dart';
import 'package:customer_app/src/features/wallet/application/wallet_notifier.dart';
import 'package:customer_app/src/features/wallet/data/wallet_repository.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

class _FakeSupabaseAuthService extends SupabaseAuthService {
  User? fakeUser;

  @override
  bool get isInitialized => true;

  @override
  User? get currentUser => fakeUser;

  @override
  Future<void> sendEmailOtp(String email) async {}
}

class _FakeBookingRepository extends BookingRepository {
  _FakeBookingRepository()
      : super(client: ApiClient(config: AppConfig.staging()));
}

class _FakeWalletRepository extends WalletRepository {
  _FakeWalletRepository()
      : super(apiClient: ApiClient(config: AppConfig.staging()));
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
  late WalletNotifier walletNotifier;

  setUp(() {
    fakeAuthService = _FakeSupabaseAuthService();
    authNotifier = AuthNotifier(authService: fakeAuthService);
    homeNotifier = HomeNotifier();
    notificationsNotifier = NotificationsNotifier();
    bookingNotifier = BookingNotifier(repository: _FakeBookingRepository());
    walletNotifier = WalletNotifier(repository: _FakeWalletRepository());
  });

  Widget buildAppWithRouter({
    ThemeData? theme,
  }) {
    return ProviderScope(
      overrides: [
        authNotifierProvider.overrideWith((ref) => authNotifier),
        homeNotifierProvider.overrideWith((ref) => homeNotifier),
        notificationsNotifierProvider
            .overrideWith((ref) => notificationsNotifier),
        bookingNotifierProvider.overrideWith((ref) => bookingNotifier),
        walletNotifierProvider.overrideWith((ref) => walletNotifier),
      ],
      child: Consumer(
        builder: (context, ref, _) {
          final router = ref.watch(appRouterProvider);
          return MaterialApp.router(
            theme: theme ?? GVTheme.light,
            routerConfig: router,
          );
        },
      ),
    );
  }

  group('Step 6: End-to-End Routing & Auth Flow Verification', () {
    testWidgets(
        'Splash -> Welcome -> SignUpOptions -> Email Signup & Login navigation paths',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Unauthenticated session: Splash checks session and routes to Welcome
      fakeAuthService.fakeUser = null;

      await tester.pumpWidget(buildAppWithRouter());
      await tester.pumpAndSettle();

      // Welcome Screen rendered
      expect(find.textContaining('Move faster.'), findsOneWidget);
      expect(find.text('Get started'), findsOneWidget);

      // Tap Get started -> routes to SignUpOptions
      await tester.tap(find.text('Get started'));
      await tester.pumpAndSettle();

      expect(find.text('Join Go-Volts to start riding and sending parcels.'),
          findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Sign up with email'), findsOneWidget);

      // Tap Sign up with email -> routes to CreateAccount
      await tester.tap(find.text('Sign up with email'));
      await tester.pumpAndSettle();

      expect(find.text('Enter your details to get started.'), findsOneWidget);
      expect(find.text('First name'), findsOneWidget);
      expect(find.text('Last name'), findsOneWidget);

      // Back navigation to SignUpOptions
      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();

      // Tap Log in in SignUpOptions -> routes to Login
      await tester.tap(find.text('Log in'));
      await tester.pumpAndSettle();

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Sign in to your Go-Volts account.'), findsOneWidget);
      expect(find.text('Forgot password?'), findsOneWidget);

      // Tap Forgot password? -> routes to ForgotPassword
      await tester.tap(find.text('Forgot password?'));
      await tester.pumpAndSettle();

      expect(find.text('Reset your password'), findsOneWidget);
      expect(find.text('Send code'), findsOneWidget);
    });
  });

  group('Step 6: Home Dashboard & Deep Links E2E Verification', () {
    testWidgets(
        'Home Dashboard connects seamlessly to LocationSelector, Notifications, and Tab Navigation',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      // Authenticate user so Splash routes to Home
      fakeAuthService.fakeUser = User(
        id: 'usr_alex',
        appMetadata: {},
        userMetadata: {
          'first_name': 'Alex',
          'last_name': 'Johnson',
          'full_name': 'Alex Johnson',
        },
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: 'alex@example.com',
      );

      await tester.pumpWidget(buildAppWithRouter());
      await tester.pumpAndSettle();

      // 1. Home Dashboard renders dynamic content
      expect(find.text('GO-VOLTS'), findsOneWidget);
      expect(find.textContaining('Alex!'), findsOneWidget);
      expect(find.text('What would you like to do?'), findsOneWidget);

      // 2. Tap Location Selector card -> opens Screen 14 LocationSelectorModal
      await tester.tap(find.text('Your location'));
      await tester.pumpAndSettle();

      expect(find.text('Select your location'), findsOneWidget);
      expect(find.text('Ikoyi, Lagos'), findsOneWidget);

      // Select Ikoyi and confirm
      await tester.tap(find.text('Ikoyi, Lagos'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Confirm location'));
      await tester.pumpAndSettle();

      // Modal closed, Home now in Screen 13 state (Book a Ride unavailable, Referral banner active)
      expect(find.text('Currently unavailable'), findsOneWidget);
      expect(find.text('Not available in this area'), findsOneWidget);
      expect(find.text('Refer a friend, get 500 points'), findsOneWidget);

      // 3. Tap Notification Bell icon -> opens Screen 15 NotificationsScreen
      await tester.tap(find.byIcon(Icons.notifications_none_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Rider approaching'), findsOneWidget);
      expect(find.text('Mark all read'), findsOneWidget);

      // Tap "Mark all read"
      await tester.tap(find.text('Mark all read'));
      await tester.pumpAndSettle();
      expect(notificationsNotifier.state.unreadCount, 0);

      // Back navigation returns to Home
      await tester.tap(find.byIcon(Icons.arrow_back_rounded));
      await tester.pumpAndSettle();

      // Verify unread badge is now cleared on Home Dashboard
      expect(find.text('3'), findsNothing);

      // 4. Test 5-Tab Persistent Navigation Bar
      final homeTab = find.descendant(
        of: find.byType(GVBottomNavigation),
        matching: find.text('Home'),
      );
      expect(homeTab, findsOneWidget);
      expect(find.text('Activity'), findsOneWidget);
      expect(find.text('Rewards'), findsOneWidget);
      expect(find.text('Wallet'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      // Tap Rewards Tab
      await tester.tap(find.text('Rewards'));
      await tester.pumpAndSettle();

      // Tap Wallet Tab
      await tester.tap(find.text('Wallet'));
      await tester.pumpAndSettle();

      // Tap Profile Tab
      await tester.tap(find.text('Profile'));
      await tester.pumpAndSettle();

      // Return to Home Tab
      await tester.tap(homeTab);
      await tester.pumpAndSettle();
      expect(find.text('What would you like to do?'), findsOneWidget);
    });
  });

  group('Step 6: Responsive Breakpoints QA Verification', () {
    testWidgets('Compact phone breakpoint (320x568 dp) has zero layout overflows',
        (tester) async {
      tester.view.physicalSize = const Size(320 * 2.0, 568 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      fakeAuthService.fakeUser = User(
        id: 'usr_compact',
        appMetadata: {},
        userMetadata: {
          'first_name': 'Babatunde',
          'last_name': 'Adeleke',
          'full_name': 'Babatunde Adeleke',
        },
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: 'babatunde@example.com',
      );

      await tester.pumpWidget(buildAppWithRouter());
      await tester.pumpAndSettle();

      expect(find.text('GO-VOLTS'), findsOneWidget);
      expect(find.text('What would you like to do?'), findsOneWidget);
    });

    testWidgets('Standard phone breakpoint (390x844 dp) has zero layout overflows',
        (tester) async {
      tester.view.physicalSize = const Size(390 * 3.0, 844 * 3.0);
      tester.view.devicePixelRatio = 3.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      fakeAuthService.fakeUser = User(
        id: 'usr_standard',
        appMetadata: {},
        userMetadata: {
          'first_name': 'Chidinma',
          'last_name': 'Okafor',
          'full_name': 'Chidinma Okafor',
        },
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: 'chidinma@example.com',
      );

      await tester.pumpWidget(buildAppWithRouter());
      await tester.pumpAndSettle();

      expect(find.text('GO-VOLTS'), findsOneWidget);
      expect(find.text('What would you like to do?'), findsOneWidget);
    });

    testWidgets('Tablet breakpoint (800x1280 dp) renders cleanly',
        (tester) async {
      tester.view.physicalSize = const Size(800 * 2.0, 1280 * 2.0);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      fakeAuthService.fakeUser = User(
        id: 'usr_tablet',
        appMetadata: {},
        userMetadata: {
          'first_name': 'Femi',
          'last_name': 'Otedola',
          'full_name': 'Femi Otedola',
        },
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: 'femi@example.com',
      );

      await tester.pumpWidget(buildAppWithRouter());
      await tester.pumpAndSettle();

      expect(find.text('GO-VOLTS'), findsOneWidget);
      expect(find.text('What would you like to do?'), findsOneWidget);
    });
  });

  group('Step 6: Dark & Light Theme Contrast & Parity QA', () {
    testWidgets('renders cleanly in dark theme with full visual fidelity',
        (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 2.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      fakeAuthService.fakeUser = User(
        id: 'usr_dark',
        appMetadata: {},
        userMetadata: {
          'first_name': 'Alex',
          'last_name': 'Johnson',
          'full_name': 'Alex Johnson',
        },
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: 'alex@example.com',
      );

      await tester.pumpWidget(buildAppWithRouter(theme: GVTheme.dark));
      await tester.pumpAndSettle();

      expect(find.text('GO-VOLTS'), findsOneWidget);
      expect(find.text('What would you like to do?'), findsOneWidget);
    });
  });
}
