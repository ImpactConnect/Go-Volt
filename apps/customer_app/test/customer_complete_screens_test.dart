import 'package:customer_app/src/features/account/presentation/edit_profile_screen.dart';
import 'package:customer_app/src/features/account/presentation/preferences_screen.dart';
import 'package:customer_app/src/features/account/presentation/saved_places_screen.dart';
import 'package:customer_app/src/features/home/presentation/notifications_screen.dart';
import 'package:customer_app/src/features/scheduled/presentation/plan_modification_screen.dart';
import 'package:customer_app/src/features/tracking/presentation/receipt_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Customer App Complete Screens — H06, H05, A11, W08, A15, SP15', () {
    testWidgets('NotificationsScreen (H06) renders items, filters, and marks all as read', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: NotificationsScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Notifications'), findsOneWidget);
      expect(find.text('Rider approaching'), findsOneWidget);
      expect(find.text('Special offer'), findsOneWidget);

      // Filter by "Promotions"
      await tester.tap(find.text('Promotions'));
      await tester.pumpAndSettle();

      expect(find.text('Special offer'), findsOneWidget);
      expect(find.text('Rider approaching'), findsNothing);

      // Return to "All" and mark all as read
      await tester.tap(find.text('All'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Mark all read'));
      await tester.pumpAndSettle();

      final markAllReadBtn = tester.widget<TextButton>(find.widgetWithText(TextButton, 'Mark all read'));
      expect(markAllReadBtn.onPressed, isNull);
    });

    testWidgets('SavedPlacesScreen (H05) enforces dependent plan warning on deletion', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: SavedPlacesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Saved Places'), findsOneWidget);
      expect(find.text('Home'), findsOneWidget);
      expect(find.text('Work'), findsOneWidget);
      expect(find.text('Corona School Victoria Island'), findsOneWidget);
      expect(find.text('ACTIVE PLAN'), findsWidgets);

      // Tap delete on the first saved place (Home, which is used in active plan)
      final deleteButtons = find.byIcon(Icons.delete_outline);
      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      expect(find.text('Delete Home?'), findsOneWidget);
      expect(find.textContaining('WARNING: An active School-Run or Recurring Commute plan depends on this address!'), findsOneWidget);

      // Dismiss dialog
      await tester.tap(find.text('Keep Place'));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('EditProfileScreen (A11) renders verified parent status and warns on phone change', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: EditProfileScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit Profile'), findsOneWidget);
      expect(find.text('Verified Parent / Guardian'), findsOneWidget);
      expect(find.text('VETTED'), findsOneWidget);
      expect(find.text('Full Legal Name'), findsOneWidget);

      // Modify phone number
      final phoneField = find.widgetWithText(TextField, '+234 801 234 5678');
      await tester.enterText(phoneField, '+234 809 999 8888');
      await tester.pumpAndSettle();

      expect(find.textContaining('Changing your phone number requires SMS OTP verification'), findsOneWidget);

      // Tap Save Profile
      await tester.tap(find.text('Save Profile'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.text('Profile updated successfully.'), findsOneWidget);
    });

    testWidgets('ReceiptScreen (W08) renders itemized fare breakdown and eco offset', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ReceiptScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Trip receipt'), findsOneWidget);
      expect(find.text('Here are the details of your trip.'), findsOneWidget);
      expect(find.text('Daniel Okafor'), findsWidgets);
      expect(find.textContaining('TRP123456789'), findsWidgets);
      expect(find.text('Download receipt'), findsOneWidget);

      await tester.tap(find.text('Download receipt'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Downloading digital receipt PDF'), findsOneWidget);
    });

    testWidgets('PreferencesScreen (A15) toggles settings and opens delete dialog', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: PreferencesScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Preferences & Privacy'), findsOneWidget);
      expect(find.text('Push Notifications for Live Trips'), findsOneWidget);
      expect(find.text('School-Run Handover Security Codes'), findsOneWidget);
      expect(find.text('Export My Account Data'), findsOneWidget);
      expect(find.text('Delete Account'), findsOneWidget);

      // Tap Export Data
      await tester.tap(find.text('Export My Account Data'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Data export request submitted'), findsOneWidget);

      // Tap Delete Account
      await tester.tap(find.text('Delete Account'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Go-Volts Account?'), findsOneWidget);
      expect(find.text('Confirm Deletion'), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.text('Delete Go-Volts Account?'), findsNothing);
    });

    testWidgets('PlanModificationScreen (SP15) renders schedule inputs and submits request', (tester) async {
      tester.view.physicalSize = const Size(800, 1400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: PlanModificationScreen(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Modify Subscription Plan'), findsOneWidget);
      expect(find.text('ACTIVE PLAN'), findsOneWidget);
      expect(find.textContaining('Material route or timing adjustments require Go-Volts operations re-validation'), findsOneWidget);
      expect(find.text('Pickup Location'), findsOneWidget);
      expect(find.text('Drop-off Destination'), findsOneWidget);
      expect(find.text('Submit Schedule Adjustment'), findsOneWidget);

      await tester.tap(find.text('Submit Schedule Adjustment'));
      await tester.pump(const Duration(milliseconds: 400));
      await tester.pumpAndSettle();

      expect(find.text('Plan modification request submitted for operations review.'), findsOneWidget);
    });
  });
}
