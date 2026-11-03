import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../features/audit/presentation/audit_screen.dart';
import '../../features/bookings/presentation/booking_management_screen.dart';
import '../../features/customers/presentation/customer_verification_screen.dart';
import '../../features/errands/presentation/errand_operations_screen.dart';
import '../../features/finance/presentation/finance_management_screen.dart';
import '../../features/finance/presentation/paystack_provisioning_screen.dart';
import '../../features/fleet/presentation/battery_swap_screen.dart';
import '../../features/integrations/presentation/integrations_screen.dart';
import '../../features/locations/presentation/operating_locations_screen.dart';
import '../../features/merchants/presentation/merchants_screen.dart';
import '../../features/operations/presentation/operations_dashboard_screen.dart';
import '../../features/pricing/presentation/pricing_management_screen.dart';
import '../../features/promotions/presentation/promotions_management_screen.dart';
import '../../features/riders/presentation/rider_management_screen.dart';
import '../../features/safety/presentation/safety_sos_screen.dart';
import '../../features/scheduled/presentation/scheduled_operations_screen.dart';
import '../../features/support/presentation/support_safety_screen.dart';
import '../layout/admin_shell_scaffold.dart';

final adminRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/overview',
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return AdminShellScaffold(
            state: state,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/overview',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: OperationsDashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/bookings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BookingManagementScreen(),
            ),
          ),
          GoRoute(
            path: '/errands',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ErrandOperationsScreen(),
            ),
          ),
          GoRoute(
            path: '/scheduled',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ScheduledOperationsScreen(),
            ),
          ),
          GoRoute(
            path: '/safety/sos',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SafetySosScreen(),
            ),
          ),
          GoRoute(
            path: '/battery-swap',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BatterySwapScreen(),
            ),
          ),
          GoRoute(
            path: '/riders',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: RiderManagementScreen(),
            ),
          ),
          GoRoute(
            path: '/customers',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CustomerVerificationScreen(),
            ),
          ),
          GoRoute(
            path: '/merchants',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MerchantsScreen(),
            ),
          ),
          GoRoute(
            path: '/locations',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: OperatingLocationsScreen(),
            ),
          ),
          GoRoute(
            path: '/pricing',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PricingManagementScreen(),
            ),
          ),
          GoRoute(
            path: '/promotions',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PromotionsManagementScreen(),
            ),
          ),
          GoRoute(
            path: '/finance',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FinanceManagementScreen(),
            ),
          ),
          GoRoute(
            path: '/paystack',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: PaystackProvisioningScreen(),
            ),
          ),
          GoRoute(
            path: '/support',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: SupportSafetyScreen(),
            ),
          ),
          GoRoute(
            path: '/audit',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: AuditScreen(),
            ),
          ),
          GoRoute(
            path: '/integrations',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: IntegrationsScreen(),
            ),
          ),
        ],
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri.path}'),
      ),
    ),
  );
});
