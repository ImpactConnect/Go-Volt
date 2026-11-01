import 'package:api_client/api_client.dart';
import 'package:app_config/app_config.dart';
import 'package:app_models/app_models.dart';
import 'package:customer_app/src/core/auth/auth_notifier.dart';
import 'package:customer_app/src/core/auth/auth_state.dart';
import 'package:customer_app/src/core/providers/api_providers.dart';
import 'package:customer_app/src/features/account/presentation/account_verification_screen.dart';
import 'package:customer_app/src/features/account/presentation/create_support_ticket_screen.dart';
import 'package:customer_app/src/features/account/presentation/help_centre_screen.dart';
import 'package:customer_app/src/features/account/presentation/notification_settings_screen.dart';
import 'package:customer_app/src/features/account/presentation/personal_info_screen.dart';
import 'package:customer_app/src/features/account/presentation/privacy_security_screen.dart';
import 'package:customer_app/src/features/account/presentation/safety_centre_screen.dart';
import 'package:customer_app/src/features/account/presentation/settings_home_screen.dart';
import 'package:customer_app/src/features/account/presentation/support_tickets_list_screen.dart';
import 'package:customer_app/src/features/account/presentation/ticket_details_screen.dart';
import 'package:customer_app/src/features/account/presentation/trusted_contacts_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final testConfig = AppConfig.dev();
  final testApiClient = ApiClient(config: testConfig);

  final testProfile = const ProfileDto(
    id: 'usr_test_flow',
    fullName: 'Damilola Adeleke',
    phoneNumber: '+234 801 234 5678',
    email: 'damilola.adeleke@example.com',
    carbonAvoidedKg: 34.8,
  );

  Widget createTestWidget(Widget child) {
    return ProviderScope(
      overrides: [
        appConfigProvider.overrideWithValue(testConfig),
        apiClientProvider.overrideWithValue(testApiClient),
        authNotifierProvider.overrideWith((ref) {
          final notifier = AuthNotifier();
          notifier.state = AuthState(
            status: AuthStatus.authenticated,
            profile: testProfile,
          );
          return notifier;
        }),
      ],
      child: MaterialApp(
        home: child,
      ),
    );
  }

  group('Flow A: Profile & Account Screens Tests', () {
    testWidgets('PersonalInfoScreen renders masked sensitive information and verification', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(const PersonalInfoScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Personal Information'), findsOneWidget);
      expect(find.text('Damilola Adeleke'), findsOneWidget);
      expect(find.textContaining('*** 5678'), findsOneWidget);
      expect(find.textContaining('da***@example.com'), findsOneWidget);
      expect(find.text('Edit Profile Information'), findsOneWidget);
    });

    testWidgets('AccountVerificationScreen renders verification status and checklist', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(const AccountVerificationScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Account Verification'), findsOneWidget);
      expect(find.text('Account Tier & Privileges'), findsOneWidget);
      expect(find.textContaining('Verification'), findsWidgets);
    });
  });

  group('Flow B: Settings & Preferences Screens Tests', () {
    testWidgets('SettingsHomeScreen renders preferences, language modal and cache clearing', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(const SettingsHomeScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Settings & Preferences'), findsOneWidget);
      expect(find.text('Language'), findsOneWidget);
      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Clear Local Cache'), findsOneWidget);

      // Open Language Picker
      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();
      expect(find.text('Select App Language'), findsOneWidget);
      expect(find.text('English (Nigeria)'), findsWidgets);
      await tester.tap(find.text('English (Nigeria)').last);
      await tester.pumpAndSettle();
    });

    testWidgets('NotificationSettingsScreen renders service-grouped alerts and toggles', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(const NotificationSettingsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Notification Settings'), findsOneWidget);
      expect(find.text('Ride Notifications'), findsOneWidget);
      expect(find.text('Parcel Logistics'), findsOneWidget);
      expect(find.text('Market Errand Shopping'), findsOneWidget);
      expect(find.text('General & Security'), findsOneWidget);
      expect(find.text('Green Volt Points & Rewards'), findsOneWidget);

      final switches = find.byType(Switch);
      expect(switches, findsWidgets);
    });

    testWidgets('PrivacySecurityScreen renders password change dialog and privacy toggles', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(const PrivacySecurityScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Privacy & Security'), findsOneWidget);
      expect(find.text('Change Password'), findsOneWidget);
      expect(find.text('Google Authentication'), findsOneWidget);
      expect(find.text('Active Sessions & Devices'), findsOneWidget);
      expect(find.text('Precise GPS Dispatching'), findsOneWidget);
      expect(find.text('Anonymous Fleet Telematics'), findsOneWidget);

      // Trigger change password dialog
      await tester.tap(find.text('Change Password'));
      await tester.pumpAndSettle();
      expect(find.text('Current Password'), findsOneWidget);
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
    });
  });

  group('Flow D: Safety, Help & Support Screens Tests', () {
    testWidgets('SafetyCentreScreen renders Lagos 112/767 calling, hotline and share tracking', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(const SafetyCentreScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Safety Centre & Emergency SOS'), findsOneWidget);
      expect(find.text('Lagos Emergency Services'), findsOneWidget);
      expect(find.text('Call 112'), findsOneWidget);
      expect(find.text('Call 767'), findsOneWidget);
      expect(find.text('Go-Volts Rapid Dispatch Hotline'), findsOneWidget);
      expect(find.text('Share Live Trip Details'), findsOneWidget);
      expect(find.text('Trusted Contacts'), findsOneWidget);
      expect(find.text('Report a Safety Issue'), findsOneWidget);

      // Trigger Live Trip Share sheet
      await tester.tap(find.text('Share Live Trip Details'));
      await tester.pumpAndSettle();
      expect(find.text('Share Live Ride Tracking'), findsOneWidget);
      expect(find.text('Copy & Share Live Link'), findsOneWidget);
      await tester.tap(find.text('Copy & Share Live Link'));
      await tester.pumpAndSettle();
    });

    testWidgets('TrustedContactsScreen displays contact list and add contact modal', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(const TrustedContactsScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Trusted Contacts'), findsOneWidget);
      expect(find.text('Add New Trusted Contact'), findsOneWidget);

      // Open Add Contact modal
      await tester.tap(find.text('Add New Trusted Contact'));
      await tester.pumpAndSettle();
      expect(find.text('Contact Full Name'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
      expect(find.text('Auto-share Live Trips'), findsOneWidget);
    });

    testWidgets('HelpCentreScreen renders searchable FAQs and category chips', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(const HelpCentreScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Help & Support Centre'), findsOneWidget);
      expect(find.text('Create Ticket'), findsOneWidget);
      expect(find.text('My Tickets'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Rides'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Delivery'), findsOneWidget);
      expect(find.widgetWithText(ChoiceChip, 'Market Errand'), findsOneWidget);

      // Filter category
      await tester.tap(find.widgetWithText(ChoiceChip, 'Delivery'));
      await tester.pumpAndSettle();

      // Enter search query
      await tester.enterText(find.byType(TextField).first, 'parcel');
      await tester.pumpAndSettle();
    });

    testWidgets('CreateSupportTicketScreen validates fields and submits support ticket', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(const CreateSupportTicketScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Submit Support Ticket'), findsWidgets);
      expect(find.text('Related Service'), findsOneWidget);
      expect(find.text('Issue Category'), findsOneWidget);
      expect(find.text('Subject'), findsOneWidget);
      expect(find.text('Detailed Description'), findsOneWidget);

      // Tap submit to trigger validation
      final submitFinder = find.widgetWithText(ElevatedButton, 'Submit Support Ticket');
      await tester.ensureVisible(submitFinder);
      await tester.tap(submitFinder);
      await tester.pumpAndSettle();
      expect(find.text('Please enter a subject line'), findsOneWidget);
    });

    testWidgets('SupportTicketsListScreen & TicketDetailsScreen render lifecycle timeline and chat', (tester) async {
      tester.view.physicalSize = const Size(800, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(createTestWidget(const SupportTicketsListScreen()));
      await tester.pumpAndSettle();

      expect(find.text('Support Tickets'), findsOneWidget);
      expect(find.text('New Ticket'), findsOneWidget);

      // Check TicketDetailsScreen
      await tester.pumpWidget(createTestWidget(const TicketDetailsScreen(ticketId: 'tkt_001')));
      await tester.pumpAndSettle();

      expect(find.text('Ticket Lifecycle'), findsOneWidget);
      expect(find.text('Submitted'), findsOneWidget);
      expect(find.text('In Progress'), findsOneWidget);
      expect(find.text('Conversation History'), findsOneWidget);
    });
  });
}
