import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../layout/merchant_shell_scaffold.dart';
import '../../features/dashboard/presentation/merchant_dashboard_screen.dart';
import '../../features/bookings/presentation/merchant_bookings_screen.dart';
import '../../features/create_delivery/presentation/create_delivery_screen.dart';
import '../../features/branches/presentation/branches_staff_screen.dart';
import '../../features/billing/presentation/merchant_billing_screen.dart';
import '../../features/developer/presentation/developer_api_screen.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');
final GlobalKey<NavigatorState> _shellNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'shell');

GoRouter createMerchantRouter({String initialLocation = '/dashboard'}) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: initialLocation,
    routes: [
      GoRoute(
        path: '/',
        redirect: (context, state) => '/dashboard',
      ),
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return MerchantShellScaffold(
            currentRoute: state.uri.path,
            child: child,
          );
        },
        routes: [
          GoRoute(
            path: '/dashboard',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MerchantDashboardScreen(),
            ),
          ),
          GoRoute(
            path: '/bookings',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MerchantBookingsScreen(),
            ),
          ),
          GoRoute(
            path: '/create-delivery',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: CreateDeliveryScreen(),
            ),
          ),
          GoRoute(
            path: '/branches',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BranchesStaffScreen(),
            ),
          ),
          GoRoute(
            path: '/billing',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MerchantBillingScreen(),
            ),
          ),
          GoRoute(
            path: '/developer',
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DeveloperApiScreen(),
            ),
          ),
        ],
      ),
    ],
  );
}
