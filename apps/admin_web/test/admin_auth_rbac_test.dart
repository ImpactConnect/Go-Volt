import 'package:admin_web/src/core/auth/admin_auth_notifier.dart';
import 'package:admin_web/src/core/auth/admin_role.dart';
import 'package:admin_web/src/core/layout/admin_top_bar.dart';
import 'package:admin_web/src/core/navigation/admin_sidebar.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Admin RBAC & Auth Notifier Tests', () {
    test('StaffRole permissions align with specifications (§5.1)', () {
      // opsAgent
      const ops = StaffRole.opsAgent;
      expect(ops.canAccessOperations, isTrue);
      expect(ops.canAccessRiders, isTrue);
      expect(ops.canAccessPricing, isFalse);
      expect(ops.canAccessPromotions, isFalse);
      expect(ops.canAccessFinance, isFalse);
      expect(ops.canAccessSafety, isFalse);
      expect(ops.canAccessAudit, isFalse);
      expect(ops.canAccessIntegrations, isFalse);

      // safetyOfficer
      const safety = StaffRole.safetyOfficer;
      expect(safety.canAccessOperations, isTrue);
      expect(safety.canAccessRiders, isTrue);
      expect(safety.canAccessPricing, isFalse);
      expect(safety.canAccessPromotions, isFalse);
      expect(safety.canAccessFinance, isFalse);
      expect(safety.canAccessSafety, isTrue);
      expect(safety.canAccessAudit, isFalse);

      // finance
      const fin = StaffRole.finance;
      expect(fin.canAccessOperations, isTrue);
      expect(fin.canAccessRiders, isFalse);
      expect(fin.canAccessPricing, isFalse);
      expect(fin.canAccessPromotions, isFalse);
      expect(fin.canAccessFinance, isTrue);
      expect(fin.canAccessSafety, isFalse);

      // promotionsManager
      const promo = StaffRole.promotionsManager;
      expect(promo.canAccessOperations, isTrue);
      expect(promo.canAccessPromotions, isTrue);
      expect(promo.canAccessFinance, isFalse);
      expect(promo.canAccessPricing, isFalse);

      // admin
      const admin = StaffRole.admin;
      expect(admin.canAccessOperations, isTrue);
      expect(admin.canAccessRiders, isTrue);
      expect(admin.canAccessPricing, isTrue);
      expect(admin.canAccessPromotions, isTrue);
      expect(admin.canAccessFinance, isFalse); // Strict maker-checker separation: Ops Admin is not Finance
      expect(admin.canAccessSafety, isTrue);
      expect(admin.canAccessAudit, isTrue);
      expect(admin.canAccessIntegrations, isTrue);

      // superAdmin
      const superAdmin = StaffRole.superAdmin;
      expect(superAdmin.canAccessOperations, isTrue);
      expect(superAdmin.canAccessRiders, isTrue);
      expect(superAdmin.canAccessPricing, isTrue);
      expect(superAdmin.canAccessPromotions, isTrue);
      expect(superAdmin.canAccessFinance, isTrue);
      expect(superAdmin.canAccessSafety, isTrue);
      expect(superAdmin.canAccessAudit, isTrue);
      expect(superAdmin.canAccessIntegrations, isTrue);
    });

    test('AdminAuthNotifier switches role and service areas', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      final notifier = container.read(adminAuthNotifierProvider.notifier);
      expect(container.read(adminAuthNotifierProvider).role, equals(StaffRole.superAdmin));
      expect(container.read(adminAuthNotifierProvider).selectedServiceArea, equals('Lekki / Victoria Island'));

      // Switch to Ops Agent
      notifier.setRole(StaffRole.opsAgent);
      expect(container.read(adminAuthNotifierProvider).role, equals(StaffRole.opsAgent));

      // Switch Service Area to Ikeja Mainland
      notifier.setServiceArea('Ikeja / Mainland Hub');
      expect(container.read(adminAuthNotifierProvider).selectedServiceArea, equals('Ikeja / Mainland Hub'));

      // Sign out and sign in
      notifier.signOut();
      expect(container.read(adminAuthNotifierProvider).isAuthenticated, isFalse);

      notifier.signIn(email: 'finance@govolts.ng', role: StaffRole.finance);
      expect(container.read(adminAuthNotifierProvider).isAuthenticated, isTrue);
      expect(container.read(adminAuthNotifierProvider).role, equals(StaffRole.finance));
      expect(container.read(adminAuthNotifierProvider).email, equals('finance@govolts.ng'));
    });
  });

  group('Admin Shell UI Tests', () {
    testWidgets('Sidebar filters modules dynamically based on active role', (tester) async {
      tester.view.physicalSize = const Size(1440, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      // Start as Ops Agent: should see Live Operations, Bookings, Riders, Merchants; should NOT see Pricing, Finance, Audit, Integrations
      container.read(adminAuthNotifierProvider.notifier).setRole(StaffRole.opsAgent);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: GVTheme.darkTheme,
            home: const Scaffold(
              body: AdminSidebar(currentRoute: '/overview'),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('GO-VOLTS'), findsOneWidget);
      expect(find.text('Live Operations'), findsOneWidget);
      expect(find.text('Bookings & Trips'), findsOneWidget);
      expect(find.text('Riders & KYC'), findsOneWidget);
      expect(find.text('Merchants & Hubs'), findsOneWidget);

      // Should be hidden for Ops Agent
      expect(find.text('Pricing & Zones'), findsNothing);
      expect(find.text('Promotions & Loyalty'), findsNothing);
      expect(find.text('Finance & Refunds'), findsNothing);
      expect(find.text('Audit Logs'), findsNothing);
      expect(find.text('Integrations (Retail Ai)'), findsNothing);

      // Now switch role to Finance Officer
      container.read(adminAuthNotifierProvider.notifier).setRole(StaffRole.finance);
      await tester.pumpAndSettle();

      expect(find.text('Finance & Refunds'), findsOneWidget);
      expect(find.text('Riders & KYC'), findsNothing); // Hidden for Finance
      expect(find.text('Pricing & Zones'), findsNothing); // Hidden for Finance

      // Now switch role to Super Admin: all items should appear
      container.read(adminAuthNotifierProvider.notifier).setRole(StaffRole.superAdmin);
      await tester.pumpAndSettle();

      expect(find.text('Live Operations'), findsOneWidget);
      expect(find.text('Pricing & Zones'), findsOneWidget);
      expect(find.text('Promotions & Loyalty'), findsOneWidget);
      expect(find.text('Finance & Refunds'), findsOneWidget);
      expect(find.text('Audit Logs'), findsOneWidget);
      expect(find.text('Integrations (Retail Ai)'), findsOneWidget);
    });

    testWidgets('TopBar renders service area and role simulator controls', (tester) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      final container = ProviderContainer();
      addTearDown(container.dispose);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: GVTheme.darkTheme,
            home: const Scaffold(
              body: Column(
                children: [
                  AdminTopBar(),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Check for Service Area selector and Lagos local status
      expect(find.text('Fleet Live · Lagos WAT'), findsOneWidget);
      expect(find.text('Lekki / Victoria Island'), findsOneWidget);
      expect(find.text('Role View:'), findsOneWidget);
      expect(find.text('Super Admin'), findsOneWidget);
    });
  });
}
