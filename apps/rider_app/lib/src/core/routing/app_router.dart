import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/earnings/presentation/earnings_details_screen.dart';
import '../../features/earnings/presentation/payout_history_screen.dart';
import '../../features/earnings/presentation/rider_earnings_screen.dart';
import '../../features/earnings/presentation/wallet_screen.dart';
import '../../features/earnings/presentation/withdraw_earnings_screen.dart';
import '../../features/onboarding/presentation/rider_application_review_screen.dart';
import '../../features/onboarding/presentation/rider_application_status_screen.dart';
import '../../features/onboarding/presentation/rider_documents_screen.dart';
import '../../features/onboarding/presentation/rider_guarantor_screen.dart';
import '../../features/onboarding/presentation/rider_identity_screen.dart';
import '../../features/onboarding/presentation/rider_personal_screen.dart';
import '../../features/onboarding/presentation/rider_register_screen.dart';
import '../../features/onboarding/presentation/rider_training_screen.dart';
import '../../features/onboarding/presentation/rider_vehicle_info_screen.dart';
import '../../features/onboarding/presentation/rider_vehicle_screen.dart';
import '../../features/onboarding/presentation/rider_welcome_screen.dart';
import '../../features/profile/presentation/driver_documents_screen.dart';
import '../../features/profile/presentation/help_support_screen.dart';
import '../../features/profile/presentation/more_features_screen.dart';
import '../../features/profile/presentation/rider_profile_screen.dart';
import '../../features/profile/presentation/rider_settings_screen.dart';
import '../../features/shift/presentation/rider_home_screen.dart';
import '../../features/shift/presentation/rider_inbox_screen.dart';
import '../../features/shift/presentation/rider_trip_history_screen.dart';
import '../../features/swaps/presentation/battery_swap_screen.dart';
import '../../features/trip/domain/active_trip_state.dart';
import '../../features/trip/presentation/active_trip_screen.dart';
import '../../features/trip/presentation/otp_verification_screen.dart';
import '../../features/trip/presentation/proof_of_delivery_screen.dart';
import '../../features/trip/presentation/trip_completion_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/welcome',
    routes: [
      GoRoute(
        path: '/welcome',
        builder: (context, state) => const RiderWelcomeScreen(),
      ),
      GoRoute(
        path: '/onboarding/register',
        builder: (context, state) => const RiderRegisterScreen(),
      ),
      GoRoute(
        path: '/onboarding/personal',
        builder: (context, state) => const RiderPersonalScreen(),
      ),
      GoRoute(
        path: '/onboarding/identity',
        builder: (context, state) => const RiderIdentityScreen(),
      ),
      GoRoute(
        path: '/onboarding/documents',
        builder: (context, state) => const RiderDocumentsScreen(),
      ),
      GoRoute(
        path: '/onboarding/vehicle',
        builder: (context, state) => const RiderVehicleInfoScreen(),
      ),
      GoRoute(
        path: '/onboarding/vehicle_legacy',
        builder: (context, state) => const RiderVehicleScreen(),
      ),
      GoRoute(
        path: '/onboarding/guarantor',
        builder: (context, state) => const RiderGuarantorScreen(),
      ),
      GoRoute(
        path: '/onboarding/training',
        builder: (context, state) => const RiderTrainingScreen(),
      ),
      GoRoute(
        path: '/onboarding/review',
        builder: (context, state) => const RiderApplicationReviewScreen(),
      ),
      GoRoute(
        path: '/onboarding/status',
        builder: (context, state) => const RiderApplicationStatusScreen(),
      ),
      GoRoute(
        path: '/trip/active',
        builder: (context, state) =>
            ActiveTripScreen(job: state.extra as DispatchOfferDto),
      ),
      GoRoute(
        path: '/trip/otp',
        builder: (context, state) =>
            OtpVerificationScreen(job: state.extra as DispatchOfferDto),
      ),
      GoRoute(
        path: '/trip/proof',
        builder: (context, state) =>
            ProofOfDeliveryScreen(job: state.extra as DispatchOfferDto),
      ),
      GoRoute(
        path: '/trip/settlement',
        builder: (context, state) =>
            TripCompletionScreen(settlement: state.extra as FareSettlementDto),
      ),

      // Flow D Routes
      GoRoute(
        path: '/earnings/details',
        builder: (context, state) => const EarningsDetailsScreen(),
      ),
      GoRoute(
        path: '/wallet',
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        path: '/wallet/withdraw',
        builder: (context, state) => const WithdrawEarningsScreen(),
      ),
      GoRoute(
        path: '/wallet/payouts',
        builder: (context, state) => const PayoutHistoryScreen(),
      ),

      // Flow E Routes
      GoRoute(
        path: '/account/documents',
        builder: (context, state) => const DriverDocumentsScreen(),
      ),
      GoRoute(
        path: '/account/settings',
        builder: (context, state) => const RiderSettingsScreen(),
      ),
      GoRoute(
        path: '/account/support',
        builder: (context, state) => const HelpSupportScreen(),
      ),
      GoRoute(
        path: '/account/more',
        builder: (context, state) => const MoreFeaturesScreen(),
      ),

      // Battery Swapping Dedicated Route
      GoRoute(
        path: '/swaps',
        builder: (context, state) => const BatterySwapScreen(),
      ),

      // Shell Route for 5 Driver Tabs
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          final tabIndex = navigationShell.currentIndex.clamp(0, GVDriverNavTab.values.length - 1);
          return Scaffold(
            body: navigationShell,
            bottomNavigationBar: GVDriverBottomNavigation(
              currentTab: GVDriverNavTab.values[tabIndex],
              onTabSelected: (tab) => navigationShell.goBranch(
                tab.index,
                initialLocation: tab.index == navigationShell.currentIndex,
              ),
              inboxBadgeCount: 2,
            ),
          );
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/jobs',
                builder: (context, state) => const RiderHomeScreen(),
              ),
              GoRoute(
                path: '/home',
                builder: (context, state) => const RiderHomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/earnings',
                builder: (context, state) => const RiderEarningsScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/trips',
                builder: (context, state) => const RiderTripHistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/inbox',
                builder: (context, state) => const RiderInboxScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const RiderProfileScreen(),
              ),
              GoRoute(
                path: '/account',
                builder: (context, state) => const RiderProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
