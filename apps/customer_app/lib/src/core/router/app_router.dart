import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/complete_profile_screen.dart';
import '../../features/auth/presentation/create_account_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/location_permission_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/otp_verification_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/booking/presentation/finding_driver_screen.dart';
import '../../features/booking/presentation/location_picker_screen.dart';
import '../../features/booking/presentation/package_details_screen.dart';
import '../../features/booking/presentation/ride_booking_screen.dart';
import '../../features/booking/presentation/scheduled_booking_screen.dart';
import '../../features/home/presentation/home_dashboard_screen.dart';
import '../../features/home/presentation/main_shell_screen.dart';
import '../../features/scheduled/presentation/scheduled_plans_screen.dart';
import '../../features/scheduled/presentation/school_run_safety_screen.dart';
import '../../features/tracking/presentation/live_tracking_screen.dart';
import '../../features/tracking/presentation/trip_completed_screen.dart';
import '../../features/tracking/presentation/trip_dispute_screen.dart';
import '../../features/wallet/presentation/wallet_screen.dart';
import '../../features/wallet/presentation/top_up_screen.dart';
import '../../features/wallet/presentation/rewards_screen.dart';
import '../../features/account/presentation/account_screen.dart';
import '../../features/account/presentation/edit_profile_screen.dart';
import '../../features/account/presentation/preferences_screen.dart';
import '../../features/account/presentation/saved_places_screen.dart';
import '../../features/account/presentation/support_screen.dart';
import '../../features/home/presentation/notifications_screen.dart';
import '../../features/scheduled/presentation/plan_modification_screen.dart';
import '../../features/tracking/presentation/receipt_screen.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const login = '/login';
  static const createAccount = '/create-account';
  static const otpVerify = '/otp-verify';
  static const completeProfile = '/complete-profile';
  static const forgotPassword = '/forgot-password';
  static const locationPermission = '/location-permission';

  // Booking Flows
  static const locationPicker = '/location-picker';
  static const rideBooking = '/ride-booking';
  static const packageDetails = '/package-details';
  static const scheduledBooking = '/scheduled-booking';
  static const findingDriver = '/finding-driver';

  // Phase 1C: Tracking & Scheduled Subscriptions
  static const liveTracking = '/live-tracking';
  static const tripCompleted = '/trip-completed';
  static const tripDispute = '/trip-dispute';
  static const scheduledPlans = '/scheduled-plans';
  static const schoolRunSafety = '/school-run-safety';

  // Phase 1D: Wallet, Rewards, Support
  static const walletTopUp = '/wallet-top-up';
  static const walletRewards = '/wallet-rewards';
  static const support = '/support';

  // Secondary & Settings Screens
  static const notifications = '/notifications';
  static const savedPlaces = '/saved-places';
  static const editProfile = '/edit-profile';
  static const receipt = '/receipt';
  static const preferences = '/preferences';
  static const planModify = '/plan-modify';

  // Bottom Nav Branches
  static const home = '/home';
  static const trips = '/trips';
  static const plans = '/plans';
  static const wallet = '/wallet';
  static const account = '/account';
}

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: false,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.welcome,
        builder: (context, state) => const WelcomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.createAccount,
        builder: (context, state) => const CreateAccountScreen(),
      ),
      GoRoute(
        path: AppRoutes.otpVerify,
        builder: (context, state) => const OtpVerificationScreen(),
      ),
      GoRoute(
        path: AppRoutes.completeProfile,
        builder: (context, state) => const CompleteProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.locationPermission,
        builder: (context, state) => const LocationPermissionScreen(),
      ),
      GoRoute(
        path: AppRoutes.locationPicker,
        builder: (context, state) => const LocationPickerScreen(),
      ),
      GoRoute(
        path: AppRoutes.rideBooking,
        builder: (context, state) => const RideBookingScreen(),
      ),
      GoRoute(
        path: AppRoutes.packageDetails,
        builder: (context, state) => const PackageDetailsScreen(),
      ),
      GoRoute(
        path: AppRoutes.scheduledBooking,
        builder: (context, state) => const ScheduledBookingScreen(),
      ),
      GoRoute(
        path: AppRoutes.findingDriver,
        builder: (context, state) => const FindingDriverScreen(),
      ),
      GoRoute(
        path: AppRoutes.liveTracking,
        builder: (context, state) => const LiveTrackingScreen(),
      ),
      GoRoute(
        path: AppRoutes.tripCompleted,
        builder: (context, state) => const TripCompletedScreen(),
      ),
      GoRoute(
        path: AppRoutes.tripDispute,
        builder: (context, state) => const TripDisputeScreen(),
      ),
      GoRoute(
        path: AppRoutes.scheduledPlans,
        builder: (context, state) => const ScheduledPlansScreen(),
      ),
      GoRoute(
        path: AppRoutes.schoolRunSafety,
        builder: (context, state) => const SchoolRunSafetyScreen(),
      ),
      GoRoute(
        path: AppRoutes.walletTopUp,
        builder: (context, state) => const TopUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.walletRewards,
        builder: (context, state) => const RewardsScreen(),
      ),
      GoRoute(
        path: AppRoutes.support,
        builder: (context, state) => const SupportScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.savedPlaces,
        builder: (context, state) => const SavedPlacesScreen(),
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) => const EditProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.receipt,
        builder: (context, state) => const ReceiptScreen(),
      ),
      GoRoute(
        path: AppRoutes.preferences,
        builder: (context, state) => const PreferencesScreen(),
      ),
      GoRoute(
        path: AppRoutes.planModify,
        builder: (context, state) => const PlanModificationScreen(),
      ),

      // Persistent 5-Tab Shell Navigation
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return MainShellScreen(navigationShell: navigationShell);
        },
        branches: [
          // Branch 0: Home
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.home,
                builder: (context, state) => const HomeDashboardScreen(),
              ),
            ],
          ),

          // Branch 1: Trips
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.trips,
                builder: (context, state) => const _SimpleScreen(
                  title: 'Trips & Activity',
                  icon: Icons.route_rounded,
                  description: 'Track ongoing rides, delivery receipts, and history.',
                ),
              ),
            ],
          ),

          // Branch 2: Plans (Scheduled Rides & Pickups)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.plans,
                builder: (context, state) => const ScheduledPlansScreen(),
              ),
            ],
          ),

          // Branch 3: Wallet
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.wallet,
                builder: (context, state) => const WalletScreen(),
              ),
            ],
          ),

          // Branch 4: Account & Settings
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.account,
                builder: (context, state) => const AccountScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});

class _SimpleScreen extends StatelessWidget {
  const _SimpleScreen({
    required this.title,
    required this.icon,
    required this.description,
  });

  final String title;
  final IconData icon;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: GVTopBar(title: title),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(GVSpacing.xl),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(GVSpacing.lg),
                  decoration: BoxDecoration(
                    color: GVColors.brandGreen.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, size: 48, color: GVColors.brandGreen),
                ),
                const SizedBox(height: GVSpacing.lg),
                Text(
                  title,
                  style: GVTypography.h2.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: GVSpacing.sm),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: GVTypography.bodyMedium.copyWith(
                    color: GVColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
