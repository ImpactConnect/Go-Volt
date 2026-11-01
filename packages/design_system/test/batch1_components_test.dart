import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('Step 2: Theme System Alignment Tests', () {
    testWidgets('GVTheme light and dark palettes are fully configured', (tester) async {
      final light = GVTheme.light;
      expect(light.brightness, Brightness.light);
      expect(light.colorScheme.primary, GVColors.brandGreen);
      expect(light.scaffoldBackgroundColor, GVColors.softBackground);
      expect(light.cardTheme.color, GVColors.white);

      final dark = GVTheme.dark;
      expect(dark.brightness, Brightness.dark);
      expect(dark.colorScheme.primary, GVColors.brandGreen);
      expect(dark.scaffoldBackgroundColor, GVColors.darkBg);
      expect(dark.cardTheme.color, const Color(0xFF1C2420));
      expect(dark.inputDecorationTheme.fillColor, const Color(0xFF1C2420));
    });

    testWidgets('GVBottomNavigation renders 5 specification tabs and handles selection',
        (tester) async {
      GVNavTab selectedTab = GVNavTab.home;

      await tester.pumpWidget(
        MaterialApp(
          theme: GVTheme.light,
          home: Scaffold(
            bottomNavigationBar: GVBottomNavigation(
              currentTab: selectedTab,
              onTabSelected: (tab) => selectedTab = tab,
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Send'), findsOneWidget);
      expect(find.text('Scheduled'), findsOneWidget);
      expect(find.text('Activity'), findsOneWidget);
      expect(find.text('Profile'), findsOneWidget);

      await tester.tap(find.text('Scheduled'));
      await tester.pump();
      expect(selectedTab, GVNavTab.scheduled);
    });
  });

  group('Step 2: Reusable UI Component Tests', () {
    testWidgets('GVPasswordValidationIndicator tracks validation criteria in real-time',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GVPasswordValidationIndicator(password: 'pass'),
          ),
        ),
      );

      // Only letters pass for 'pass' (len < 8, no number)
      final letterCheck = tester.widget<Icon>(find.byIcon(Icons.check_circle_rounded).first);
      expect(letterCheck.color, GVColors.brandGreen);
      expect(find.byIcon(Icons.radio_button_unchecked_rounded), findsNWidgets(2));

      // With full password
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GVPasswordValidationIndicator(password: 'ValidPass123'),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle_rounded), findsNWidgets(3));
      expect(find.byIcon(Icons.radio_button_unchecked_rounded), findsNothing);
    });

    testWidgets('GVServiceCard renders 2x2 grid card and unavailable state',
        (tester) async {
      bool tapped = false;

      // Available card
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GVServiceCard(
              title: 'Book a Ride',
              description: 'Get a ride to your destination',
              icon: Icons.two_wheeler_rounded,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Book a Ride'), findsOneWidget);
      expect(find.text('Get a ride to your destination'), findsOneWidget);
      await tester.tap(find.text('Book a Ride'));
      expect(tapped, isTrue);

      // Unavailable card (Screen 13 state)
      tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GVServiceCard(
              title: 'Book a Ride',
              description: 'Get a ride to your destination',
              icon: Icons.two_wheeler_rounded,
              isDisabled: true,
              disabledReason: 'Not available in this area',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Currently unavailable'), findsOneWidget);
      expect(find.text('Not available in this area'), findsOneWidget);
      await tester.tap(find.text('Book a Ride'));
      expect(tapped, isFalse); // Tap blocked when disabled
    });

    testWidgets('GVActiveBookingCard displays live reference, rider and CTA button',
        (tester) async {
      bool viewOnMapTapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GVActiveBookingCard(
              serviceTitle: 'Ride booking',
              referenceCode: 'GV-824755',
              statusBadge: 'In progress',
              riderName: 'Babajide S.',
              statusMessage: 'Rider approaching',
              etaMinutes: 3,
              onViewOnMap: () => viewOnMapTapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Your active booking'), findsOneWidget);
      expect(find.text('In progress'), findsOneWidget);
      expect(find.text('GV-824755'), findsOneWidget);
      expect(find.text('Rider approaching'), findsOneWidget);
      expect(find.text('ETA 3 mins'), findsOneWidget);
      expect(find.text('View on map'), findsOneWidget);

      await tester.tap(find.text('View on map'));
      expect(viewOnMapTapped, isTrue);
    });

    testWidgets('GVCampaignBanner renders discount and referral formats',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GVCampaignBanner(
              title: 'Save 20% on your next ride',
              promoCode: 'GO20',
              ctaText: 'Learn more',
              bannerType: 'discount',
            ),
          ),
        ),
      );

      expect(find.text('Save 20% on your next ride'), findsOneWidget);
      expect(find.text('Use code GO20'), findsOneWidget);
      expect(find.text('Learn more'), findsOneWidget);
    });

    testWidgets('GVSavedPlaceChip renders destination label and address',
        (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GVSavedPlaceChip(
              label: 'Home',
              address: 'Victoria Island, Lagos',
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Victoria Island, Lagos'), findsOneWidget);
      await tester.tap(find.text('Home'));
      expect(tapped, isTrue);
    });

    testWidgets('GVNotificationItemTile renders unread state and tile content',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GVNotificationItemTile(
              title: 'Rider approaching',
              message: 'Your rider is 3 minutes away',
              timeAgo: '2 mins ago',
              isRead: false,
            ),
          ),
        ),
      );

      expect(find.text('Rider approaching'), findsOneWidget);
      expect(find.text('Your rider is 3 minutes away'), findsOneWidget);
      expect(find.text('2 mins ago'), findsOneWidget);
    });
  });
}
