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
import 'package:customer_app/src/features/home/presentation/create_destinations_pop_sheet.dart';
import 'package:customer_app/src/features/home/presentation/home_dashboard_screen.dart';
import 'package:customer_app/src/features/wallet/data/wallet_repository.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

class _MockAuthService extends SupabaseAuthService {
  @override
  bool get isInitialized => true;
}

class _MockBookingRepo extends BookingRepository {
  _MockBookingRepo() : super(client: ApiClient(config: AppConfig.staging()));
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  late _MockAuthService authService;
  late AuthNotifier authNotifier;
  late HomeNotifier homeNotifier;
  late NotificationsNotifier notificationsNotifier;
  late BookingNotifier bookingNotifier;

  setUp(() {
    HomeDashboardScreen.resetPromptSession();
    authService = _MockAuthService();
    authNotifier = AuthNotifier(authService: authService);
    // Brand new user who just signed up
    authNotifier.state = const AuthState(
      status: AuthStatus.authenticated,
      profile: ProfileDto(
        id: 'usr_new_999',
        fullName: 'Chidi Obi',
        phoneNumber: '+2348099887766',
        email: 'chidi.obi@example.com',
        // New user has 0 points and 0 avoided emissions
        ecoPointsBalance: 0,
        carbonAvoidedKg: 0.0,
      ),
    );

    homeNotifier = HomeNotifier(
      initialSavedPlaces: const [],
    ); // Starts with empty saved places
    notificationsNotifier = NotificationsNotifier(
      initialNotifications: const [],
    ); // Starts with empty notifications
    bookingNotifier = BookingNotifier(repository: _MockBookingRepo());
  });

  Widget buildApp() {
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
        theme: GVTheme.light,
        home: const HomeDashboardScreen(),
      ),
    );
  }

  group('New User Zero-Data Baseline Tests', () {
    test(
      'a newly signed up user has 0 saved places, 0 eco points, and 0 activity notifications',
      () async {
        final freshProfile = authNotifier.state.profile!;
        expect(freshProfile.ecoPointsBalance, equals(0));
        expect(freshProfile.carbonAvoidedKg, equals(0.0));

        expect(homeNotifier.state.savedPlaces.isEmpty, isTrue);
        expect(notificationsNotifier.state.notifications.isEmpty, isTrue);

        final walletRepo = WalletRepository(
          apiClient: ApiClient(config: AppConfig.dev()),
        );
        final wallet = await walletRepo.getWallet();
        final txs = await walletRepo.getTransactions();
        final loyalty = await walletRepo.getLoyaltyRewards();

        expect(wallet.balance, equals(0.0));
        expect(txs.isEmpty, isTrue);
        expect(loyalty.pointsBalance, equals(0));
      },
    );

    testWidgets(
      'HomeDashboardScreen displays zero state and setup prompt for fresh user',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildApp());
        await tester.pump(); // initial frame before 2s timer

        // Greeting with user first name
        expect(find.textContaining('Chidi!'), findsOneWidget);

        // Notification badge is 0
        expect(find.text('0'), findsNothing); // Badge hidden when 0 unread

        // Saved places section displays prompt to set up destinations
        expect(find.text('Set up your frequent destinations'), findsOneWidget);
        expect(
          find.text('Save Home, Work or favorite spots for 1-tap bookings'),
          findsOneWidget,
        );

        // Rewards displays 0 pts
        expect(find.text('0 pts'), findsOneWidget);

        // Flush pending timers
        await tester.pumpAndSettle(const Duration(seconds: 3));
      },
    );
  });

  group('Destination Prompt Pop Screen (after 2 seconds)', () {
    testWidgets(
      'pops up after 2 seconds on app open and allows saving destination',
      (tester) async {
        tester.view.physicalSize = const Size(1080, 2400);
        tester.view.devicePixelRatio = 2.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildApp());
        await tester.pump();

        // At t=0s, bottom sheet is NOT open yet
        expect(find.byType(CreateDestinationsPopSheet), findsNothing);
        expect(find.text('Save Frequent Destinations'), findsNothing);

        // Advance by 1 second: still not shown
        await tester.pump(const Duration(seconds: 1));
        expect(find.byType(CreateDestinationsPopSheet), findsNothing);

        // Advance by another 1.5 seconds (total > 2s): pop sheet appears!
        await tester.pump(const Duration(milliseconds: 1500));
        await tester.pumpAndSettle();

        expect(find.byType(CreateDestinationsPopSheet), findsOneWidget);
        expect(find.text('Save Frequent Destinations'), findsOneWidget);
        expect(
          find.text('Quick 1-tap bookings for your regular trips'),
          findsOneWidget,
        );

        // Type options: Home, Work, Custom
        expect(find.text('Home'), findsWidgets);
        expect(find.text('Work'), findsWidgets);
        expect(find.text('Custom'), findsOneWidget);

        // Fill address in the street address text field
        await tester.enterText(
          find.widgetWithText(
            TextField,
            'Enter street address, building or area',
          ),
          '10 Main St, Shaganu, Ogun',
        );
        await tester.pump();

        // Tap "Save Destination"
        await tester.tap(find.text('Save Destination'));
        await tester.pumpAndSettle();

        // Sheet is closed
        expect(find.byType(CreateDestinationsPopSheet), findsNothing);

        // Destination is now present in homeNotifier saved places!
        expect(homeNotifier.state.savedPlaces.isNotEmpty, isTrue);
        expect(homeNotifier.state.savedPlaces.first.label, equals('Home'));
        expect(
          homeNotifier.state.savedPlaces.first.address,
          contains('Shaganu'),
        );

        // Dashboard now reflects the newly saved place
        expect(find.text('Your saved places'), findsOneWidget);
        expect(find.text('Home'), findsOneWidget);
      },
    );
  });
}
