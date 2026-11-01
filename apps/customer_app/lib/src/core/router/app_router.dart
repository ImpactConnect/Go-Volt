import 'package:app_models/app_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../auth/auth_notifier.dart';
import '../../features/home/application/home_notifier.dart';

import '../../features/auth/presentation/complete_profile_screen.dart';
import '../../features/auth/presentation/create_account_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/google_auth_screen.dart';
import '../../features/auth/presentation/location_permission_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/new_password_screen.dart';
import '../../features/auth/presentation/otp_verification_screen.dart';
import '../../features/auth/presentation/reset_password_otp_screen.dart';
import '../../features/auth/presentation/signup_options_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/welcome_screen.dart';
import '../../features/booking/presentation/finding_driver_screen.dart';
import '../../features/booking/presentation/location_picker_screen.dart';
import '../../features/booking/presentation/map_picker_screen.dart';
import '../../features/booking/presentation/ride_booking_screen.dart';
import '../../features/booking/presentation/scheduled_booking_screen.dart';
import '../../features/parcel/presentation/parcel_delivery_type_screen.dart';
import '../../features/parcel/presentation/package_details_screen.dart';
import '../../features/parcel/presentation/parcel_pickup_location_screen.dart';
import '../../features/parcel/presentation/recipient_details_screen.dart';
import '../../features/parcel/presentation/parcel_delivery_location_screen.dart';
import '../../features/parcel/presentation/parcel_review_screen.dart';
import '../../features/parcel/presentation/parcel_payment_screen.dart';
import '../../features/parcel/presentation/parcel_confirmation_screen.dart';
import '../../features/parcel/presentation/parcel_finding_rider_screen.dart';
import '../../features/parcel/presentation/parcel_live_tracking_screen.dart';
import '../../features/parcel/presentation/parcel_delivered_screen.dart';
import '../../features/parcel/presentation/parcel_receipt_screen.dart';
import '../../features/parcel/presentation/parcel_rating_screen.dart';
import '../../features/errand/presentation/home/market_errand_home_screen.dart';
import '../../features/errand/presentation/flow_a_shopping/select_shop_screen.dart';
import '../../features/errand/presentation/flow_a_shopping/add_items_screen.dart';
import '../../features/errand/presentation/flow_a_shopping/shopping_preferences_screen.dart';
import '../../features/errand/presentation/flow_a_shopping/shopping_delivery_screen.dart';
import '../../features/errand/presentation/flow_a_shopping/shopping_review_screen.dart';
import '../../features/errand/presentation/flow_a_shopping/shopping_tracking_screen.dart';
import '../../features/errand/presentation/flow_b_package/package_pickup_screen.dart';
import '../../features/errand/presentation/flow_b_package/package_details_screen.dart';
import '../../features/errand/presentation/flow_b_package/package_delivery_screen.dart';
import '../../features/errand/presentation/flow_b_package/package_review_screen.dart';
import '../../features/errand/presentation/flow_b_package/package_tracking_screen.dart';
import '../../features/errand/presentation/flow_c_other/describe_errand_screen.dart';
import '../../features/errand/presentation/flow_c_other/task_details_screen.dart';
import '../../features/errand/presentation/flow_c_other/quote_available_screen.dart';
import '../../features/errand/presentation/flow_c_other/custom_errand_tracking_screen.dart';
import '../../features/errand/presentation/flow_c_other/errand_completed_screen.dart';
import '../../features/home/presentation/current_location_map_screen.dart';
import '../../features/home/presentation/home_dashboard_screen.dart';
import '../../features/home/presentation/location_selector_modal.dart';
import '../../features/home/presentation/main_shell_screen.dart';
import '../../features/scheduled/presentation/scheduled_plans_screen.dart';
import '../../features/scheduled/presentation/school_run_safety_screen.dart';
import '../../features/tracking/presentation/live_tracking_screen.dart';
import '../../features/tracking/presentation/trip_completed_screen.dart';
import '../../features/tracking/presentation/trip_dispute_screen.dart';
import '../../features/wallet/presentation/wallet_screen.dart';
import '../../features/wallet/presentation/top_up_screen.dart';
import '../../features/wallet/presentation/rewards_screen.dart';
import '../../features/wallet/presentation/saved_payment_methods_screen.dart';
import '../../features/wallet/presentation/coupons_screen.dart';
import '../../features/activity/presentation/activity_hub_screen.dart';
import '../../features/account/presentation/account_screen.dart';
import '../../features/account/presentation/account_verification_screen.dart';
import '../../features/account/presentation/create_support_ticket_screen.dart';
import '../../features/account/presentation/edit_profile_screen.dart';
import '../../features/account/presentation/help_centre_screen.dart';
import '../../features/account/presentation/notification_settings_screen.dart';
import '../../features/account/presentation/personal_info_screen.dart';
import '../../features/account/presentation/preferences_screen.dart';
import '../../features/account/presentation/privacy_security_screen.dart';
import '../../features/account/presentation/safety_centre_screen.dart';
import '../../features/account/presentation/saved_places_screen.dart';
import '../../features/account/presentation/settings_home_screen.dart';
import '../../features/account/presentation/support_screen.dart';
import '../../features/account/presentation/support_tickets_list_screen.dart';
import '../../features/account/presentation/ticket_details_screen.dart';
import '../../features/account/presentation/trusted_contacts_screen.dart';
import '../../features/home/presentation/notifications_screen.dart';
import '../../features/scheduled/presentation/plan_modification_screen.dart';
import '../../features/scheduled/presentation/screens/screens.dart';
import '../../features/tracking/presentation/receipt_screen.dart';
import '../../features/tracking/presentation/rate_trip_screen.dart';

abstract final class AppRoutes {
  static const splash = '/';
  static const welcome = '/welcome';
  static const signupOptions = '/signup-options';
  static const login = '/login';
  static const createAccount = '/create-account';
  static const otpVerify = '/otp-verify';
  static const googleAuth = '/google-auth';
  static const completeProfile = '/complete-profile';
  static const forgotPassword = '/forgot-password';
  static const resetPasswordOtp = '/reset-password-otp';
  static const newPassword = '/new-password';
  static const locationPermission = '/location-permission';

  // Booking Flows
  static const currentLocationMap = '/current-location-map';
  static const locationSelect = '/location-select';
  static const locationPicker = '/location-picker';
  static const mapPicker = '/map-picker';
  static const rideBooking = '/ride-booking';
  static const packageDetails = '/package-details';
  static const scheduledBooking = '/scheduled-booking';
  static const findingDriver = '/finding-driver';

  // Parcel Delivery Flow (Screens 1 to 17)
  static const parcelDeliveryType = '/parcel-delivery-type';
  static const parcelPickupLocation = '/parcel-pickup-location';
  static const recipientDetails = '/recipient-details';
  static const parcelDeliveryLocation = '/parcel-delivery-location';
  static const parcelReviewQuote = '/parcel-review-quote';
  static const parcelPayment = '/parcel-payment';
  static const parcelConfirmation = '/parcel-confirmation';
  static const parcelFindingRider = '/parcel-finding-rider';
  static const parcelLiveTracking = '/parcel-live-tracking';
  static const parcelDelivered = '/parcel-delivered';
  static const parcelReceipt = '/parcel-receipt';
  static const parcelRating = '/parcel-rating';

  // Market Errand Subsystem (v1.6)
  static const errandHome = '/errand';
  static const errandSelectShop = '/errand/select-shop';
  static const errandAddItems = '/errand/add-items';
  static const errandPreferences = '/errand/preferences';
  static const errandDelivery = '/errand/delivery';
  static const errandReview = '/errand/review';
  static const errandTracking = '/errand/tracking';
  static const errandPackagePickup = '/errand/package-pickup';
  static const errandPackageDetails = '/errand/package-details';
  static const errandPackageDelivery = '/errand/package-delivery';
  static const errandPackageReview = '/errand/package-review';
  static const errandPackageTracking = '/errand/package-tracking';
  static const errandDescribeTask = '/errand/describe-task';
  static const errandTaskDetails = '/errand/task-details';
  static const errandQuoteAvailable = '/errand/quote-available';
  static const errandCustomTracking = '/errand/custom-tracking';
  static const errandCompleted = '/errand/completed';

  // Phase 1C: Tracking & Scheduled Subscriptions
  static const liveTracking = '/live-tracking';
  static const tripCompleted = '/trip-completed';
  static const tripDispute = '/trip-dispute';
  static const scheduledPlans = '/scheduled-plans';
  static const schoolRunSafety = '/school-run-safety';

  // Go-Volts Scheduled Pickup Flow (Screens 1 to 36)
  static const scheduledLanding = '/scheduled';
  static const scheduledBookingType = '/scheduled/booking-type';
  static const scheduledChooseBookingType = scheduledBookingType;
  static const scheduledTripPurpose = '/scheduled/purpose';
  static const scheduledPickupLocation = '/scheduled/pickup-location';
  static const scheduledDestination = '/scheduled/destination';
  static const scheduledTripDetails = '/scheduled/trip-details';
  static const scheduledCalendar = '/scheduled/calendar';
  static const scheduledPassengerDetails = '/scheduled/passenger-details';
  static const scheduledPreferredDriver = '/scheduled/preferred-driver';
  static const scheduledPackagePricing = '/scheduled/package-pricing';
  static const scheduledReviewQuote = '/scheduled/review-quote';
  static const scheduledQuoteResult = '/scheduled/quote-result';
  static const scheduledRequestSubmitted = '/scheduled/request-submitted';
  static const scheduledApprovalStatus = '/scheduled/approval-status';
  static const scheduledRequestApproved = '/scheduled/request-approved';
  static const scheduledPayment = '/scheduled/payment';
  static const scheduledPaymentSuccess = '/scheduled/payment-success';
  static const scheduledMyPlans = '/scheduled/my-plans';
  static const scheduledPlanDetails = '/scheduled/plan-details';
  static const scheduledUpcomingTrips = '/scheduled/upcoming-trips';
  static const scheduledManagePlan = '/scheduled/manage-plan';
  static const scheduledSkipTrip = '/scheduled/skip-trip';
  static const scheduledPausePlan = '/scheduled/pause-plan';
  static const scheduledRenewPlan = '/scheduled/renew-plan';
  static const scheduledUpcomingTab = '/scheduled/upcoming-tab';
  static const scheduledDriverAssigned = '/scheduled/driver-assigned';
  static const scheduledDriverApproaching = '/scheduled/driver-approaching';
  static const scheduledArrivedPickup = '/scheduled/arrived-pickup';
  static const scheduledArrivedAtPickup = scheduledArrivedPickup;
  static const scheduledTripInProgress = '/scheduled/trip-in-progress';
  static const scheduledArrivingDestination = '/scheduled/arriving-destination';
  static const scheduledTripCompleted = '/scheduled/trip-completed-view';
  static const scheduledSchoolRunStatus = '/scheduled/school-run-status';
  static const scheduledHandoverVerification = '/scheduled/handover-verification';
  static const scheduledHandoverConfirmed = '/scheduled/handover-confirmed';
  static const scheduledReportIssue = '/scheduled/report-issue';
  static const scheduledPaymentRefundDetails = '/scheduled/payment-refund-details';

  // Phase 1D: Wallet, Rewards, Support
  static const walletTopUp = '/wallet-top-up';
  static const walletRewards = '/rewards';
  static const walletPaymentMethods = '/wallet-payment-methods';
  static const walletCoupons = '/wallet-coupons';
  static const support = '/support';
  static const helpCentre = '/help-centre';
  static const createSupportTicket = '/support/create-ticket';
  static const supportTicketsList = '/support/tickets';
  static const supportTicketDetails = '/support/tickets/:id';

  // Secondary & Settings Screens
  static const notifications = '/notifications';
  static const savedPlaces = '/saved-places';
  static const editProfile = '/edit-profile';
  static const receipt = '/receipt';
  static const rateTrip = '/rate-trip';
  static const preferences = '/preferences';
  static const planModify = '/plan-modify';
  static const personalInfo = '/profile/personal-info';
  static const settings = '/settings';
  static const notificationSettings = '/settings/notifications';
  static const privacySecurity = '/settings/privacy-security';
  static const safetyCentre = '/safety-centre';
  static const trustedContacts = '/safety/trusted-contacts';
  static const accountVerification = '/profile/verification';

  // Bottom Nav Branches
  static const home = '/home';
  static const send = '/send';
  static const scheduled = '/scheduled';
  static const trips = '/trips';
  static const activity = '/trips';
  static const plans = '/plans';
  static const rewards = '/rewards';
  static const wallet = '/wallet';
  static const account = '/account';
  static const profile = '/account';
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
        path: AppRoutes.signupOptions,
        builder: (context, state) => const SignUpOptionsScreen(),
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
        path: AppRoutes.googleAuth,
        builder: (context, state) => const GoogleAuthConfirmationScreen(),
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
        path: AppRoutes.resetPasswordOtp,
        builder: (context, state) => const ResetPasswordOtpScreen(),
      ),
      GoRoute(
        path: AppRoutes.newPassword,
        builder: (context, state) => const NewPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.locationPermission,
        builder: (context, state) => const LocationPermissionScreen(),
      ),
      GoRoute(
        path: AppRoutes.locationSelect,
        builder: (context, state) => const Scaffold(
          body: LocationSelectorModal(),
        ),
      ),
      GoRoute(
        path: AppRoutes.locationPicker,
        builder: (context, state) {
          final mode = state.uri.queryParameters['mode'];
          return LocationPickerScreen(initialMode: mode);
        },
      ),
      GoRoute(
        path: AppRoutes.currentLocationMap,
        builder: (context, state) {
          final initialLocation = state.extra as LocationDto?;
          return CurrentLocationMapScreen(initialLocation: initialLocation);
        },
      ),
      GoRoute(
        path: AppRoutes.mapPicker,
        builder: (context, state) {
          final isPickup = state.uri.queryParameters['isPickup'] != 'false';
          final initialLocation = state.extra as LocationDto?;
          return MapPickerScreen(
            isPickup: isPickup,
            initialLocation: initialLocation,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.rideBooking,
        builder: (context, state) => const RideBookingScreen(),
      ),
      GoRoute(
        path: AppRoutes.parcelDeliveryType,
        builder: (context, state) => const ParcelDeliveryTypeScreen(),
      ),
      GoRoute(
        path: AppRoutes.packageDetails,
        builder: (context, state) => const PackageDetailsScreen(),
      ),
      GoRoute(
        path: AppRoutes.parcelPickupLocation,
        builder: (context, state) => const ParcelPickupLocationScreen(),
      ),
      GoRoute(
        path: AppRoutes.recipientDetails,
        builder: (context, state) => const RecipientDetailsScreen(),
      ),
      GoRoute(
        path: AppRoutes.parcelDeliveryLocation,
        builder: (context, state) => const ParcelDeliveryLocationScreen(),
      ),
      GoRoute(
        path: AppRoutes.parcelReviewQuote,
        builder: (context, state) => const ParcelReviewScreen(),
      ),
      GoRoute(
        path: AppRoutes.parcelPayment,
        builder: (context, state) => const ParcelPaymentScreen(),
      ),
      GoRoute(
        path: AppRoutes.parcelConfirmation,
        builder: (context, state) => const ParcelConfirmationScreen(),
      ),
      GoRoute(
        path: AppRoutes.parcelFindingRider,
        builder: (context, state) => const ParcelFindingRiderScreen(),
      ),
      GoRoute(
        path: AppRoutes.parcelLiveTracking,
        builder: (context, state) => const ParcelLiveTrackingScreen(),
      ),
      GoRoute(
        path: AppRoutes.parcelDelivered,
        builder: (context, state) => const ParcelDeliveredScreen(),
      ),
      GoRoute(
        path: AppRoutes.parcelReceipt,
        builder: (context, state) => const ParcelReceiptScreen(),
      ),
      GoRoute(
        path: AppRoutes.parcelRating,
        builder: (context, state) => const ParcelRatingScreen(),
      ),

      // Market Errand (v1.6)
      GoRoute(
        path: AppRoutes.errandHome,
        builder: (context, state) => const MarketErrandHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.errandSelectShop,
        builder: (context, state) => const SelectShopScreen(),
      ),
      GoRoute(
        path: AppRoutes.errandAddItems,
        builder: (context, state) => const AddItemsScreen(),
      ),
      GoRoute(
        path: AppRoutes.errandPreferences,
        builder: (context, state) => const ShoppingPreferencesScreen(),
      ),
      GoRoute(
        path: AppRoutes.errandDelivery,
        builder: (context, state) => const ShoppingDeliveryScreen(),
      ),
      GoRoute(
        path: AppRoutes.errandReview,
        builder: (context, state) => const ShoppingReviewScreen(),
      ),
      GoRoute(
        path: AppRoutes.errandTracking,
        builder: (context, state) => const ShoppingTrackingScreen(),
      ),

      // Flow B: Pick Up a Package (Screens B2 to B6)
      GoRoute(
        path: AppRoutes.errandPackagePickup,
        builder: (context, state) => const PackagePickupScreen(),
      ),
      GoRoute(
        path: AppRoutes.errandPackageDetails,
        builder: (context, state) => const ErrandPackageDetailsScreen(),
      ),
      GoRoute(
        path: AppRoutes.errandPackageDelivery,
        builder: (context, state) => const PackageDeliveryScreen(),
      ),
      GoRoute(
        path: AppRoutes.errandPackageReview,
        builder: (context, state) => const PackageReviewScreen(),
      ),
      GoRoute(
        path: AppRoutes.errandPackageTracking,
        builder: (context, state) => const PackageTrackingScreen(),
      ),

      // Flow C: Other Errand (Screens C2 to C6)
      GoRoute(
        path: AppRoutes.errandDescribeTask,
        builder: (context, state) => const DescribeErrandScreen(),
      ),
      GoRoute(
        path: AppRoutes.errandTaskDetails,
        builder: (context, state) => const TaskDetailsScreen(),
      ),
      GoRoute(
        path: AppRoutes.errandQuoteAvailable,
        builder: (context, state) => const QuoteAvailableScreen(),
      ),
      GoRoute(
        path: AppRoutes.errandCustomTracking,
        builder: (context, state) => const CustomErrandTrackingScreen(),
      ),
      GoRoute(
        path: AppRoutes.errandCompleted,
        builder: (context, state) => const ErrandCompletedScreen(),
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
        path: AppRoutes.support,
        builder: (context, state) => const SupportScreen(),
      ),
      GoRoute(
        path: AppRoutes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: AppRoutes.savedPlaces,
        builder: (context, state) {
          final savedPlaces = ProviderScope.containerOf(context, listen: false)
              .read(homeNotifierProvider)
              .savedPlaces;
          final items = savedPlaces
              .map((p) => SavedPlaceItem(
                    id: p.id,
                    name: p.label,
                    address: p.address,
                    type: p.isHome
                        ? PlaceType.home
                        : (p.isWork ? PlaceType.work : PlaceType.custom),
                    isUsedInActivePlan: false,
                  ))
              .toList();
          return SavedPlacesScreen(initialPlaces: items);
        },
      ),
      GoRoute(
        path: AppRoutes.editProfile,
        builder: (context, state) {
          final profile = ProviderScope.containerOf(context, listen: false)
              .read(authNotifierProvider)
              .profile;
          return EditProfileScreen(
            initialName: profile?.fullName,
            initialEmail: profile?.email,
            initialPhone: profile?.phoneNumber,
          );
        },
      ),
      GoRoute(
        path: AppRoutes.receipt,
        builder: (context, state) => const ReceiptScreen(),
      ),
      GoRoute(
        path: AppRoutes.rateTrip,
        builder: (context, state) => const RateTripScreen(),
      ),
      GoRoute(
        path: AppRoutes.preferences,
        builder: (context, state) => const PreferencesScreen(),
      ),
      GoRoute(
        path: AppRoutes.personalInfo,
        builder: (context, state) => const PersonalInfoScreen(),
      ),
      GoRoute(
        path: AppRoutes.accountVerification,
        builder: (context, state) => const AccountVerificationScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (context, state) => const SettingsHomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.notificationSettings,
        builder: (context, state) => const NotificationSettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.privacySecurity,
        builder: (context, state) => const PrivacySecurityScreen(),
      ),
      GoRoute(
        path: AppRoutes.safetyCentre,
        builder: (context, state) => const SafetyCentreScreen(),
      ),
      GoRoute(
        path: AppRoutes.trustedContacts,
        builder: (context, state) => const TrustedContactsScreen(),
      ),
      GoRoute(
        path: AppRoutes.helpCentre,
        builder: (context, state) => const HelpCentreScreen(),
      ),
      GoRoute(
        path: AppRoutes.createSupportTicket,
        builder: (context, state) => const CreateSupportTicketScreen(),
      ),
      GoRoute(
        path: AppRoutes.supportTicketsList,
        builder: (context, state) => const SupportTicketsListScreen(),
      ),
      GoRoute(
        path: AppRoutes.supportTicketDetails,
        builder: (context, state) {
          final id = state.pathParameters['id'] ?? 'tkt_001';
          return TicketDetailsScreen(ticketId: id);
        },
      ),
      GoRoute(
        path: AppRoutes.planModify,
        builder: (context, state) => const PlanModificationScreen(),
      ),

      // Go-Volts Scheduled Pickup (Screens 1 to 36)
      GoRoute(
        path: AppRoutes.scheduledBookingType,
        builder: (context, state) => const ChooseBookingTypeScreen(),
      ),
      GoRoute(
        path: AppRoutes.scheduledTripPurpose,
        builder: (context, state) => const SelectTripPurposeScreen(),
      ),
      GoRoute(
        path: AppRoutes.scheduledPickupLocation,
        builder: (context, state) => const ScheduledPickupLocationScreen(),
      ),
      GoRoute(
        path: AppRoutes.scheduledDestination,
        builder: (context, state) => const ScheduledDestinationScreen(),
      ),
      GoRoute(
        path: AppRoutes.scheduledTripDetails,
        builder: (context, state) => const ScheduledTripDetailsScreen(),
      ),
      GoRoute(
        path: AppRoutes.scheduledCalendar,
        builder: (context, state) => const ScheduleCalendarScreen(),
      ),
      GoRoute(
        path: AppRoutes.scheduledPassengerDetails,
        builder: (context, state) => const PassengerDetailsScreen(),
      ),
      GoRoute(
        path: AppRoutes.scheduledPreferredDriver,
        builder: (context, state) => const PreferredDriverScreen(),
      ),
      GoRoute(
        path: AppRoutes.scheduledPackagePricing,
        builder: (context, state) => const PackagePricingScreen(),
      ),
      GoRoute(
        path: AppRoutes.scheduledReviewQuote,
        builder: (context, state) => const ReviewQuoteScreen(),
      ),
      GoRoute(
        path: AppRoutes.scheduledQuoteResult,
        builder: (context, state) => const QuoteResultScreen(),
      ),
      GoRoute(
        path: AppRoutes.scheduledRequestSubmitted,
        builder: (context, state) => const RequestSubmittedScreen(),
      ),
      GoRoute(
        path: AppRoutes.scheduledApprovalStatus,
        builder: (context, state) => const ApprovalStatusScreen(),
      ),
      GoRoute(
        path: AppRoutes.scheduledRequestApproved,
        builder: (context, state) => const RequestApprovedScreen(),
      ),
      GoRoute(
        path: AppRoutes.scheduledPayment,
        builder: (context, state) => const ScheduledPaymentScreen(),
      ),
      GoRoute(
        path: AppRoutes.scheduledPaymentSuccess,
        builder: (context, state) => const PaymentSuccessScreen(),
      ),
      GoRoute(
        path: AppRoutes.scheduledMyPlans,
        builder: (context, state) => const MyScheduledPlansScreen(),
      ),
      GoRoute(
        path: AppRoutes.scheduledPlanDetails,
        builder: (context, state) => const PlanDetailsScreen(),
      ),
      GoRoute(
        path: AppRoutes.scheduledUpcomingTrips,
        builder: (context, state) => const UpcomingTripsScreen(),
      ),
      GoRoute(
        path: AppRoutes.scheduledManagePlan,
        builder: (context, state) => const ManagePlanScreen(),
      ),
      GoRoute(
        path: AppRoutes.scheduledSkipTrip,
        builder: (context, state) => const SkipTripScreen(),
      ),
      GoRoute(
        path: AppRoutes.scheduledPausePlan,
        builder: (context, state) => const PausePlanScreen(),
      ),
      GoRoute(
        path: AppRoutes.scheduledRenewPlan,
        builder: (context, state) => const RenewPlanScreen(),
      ),
      GoRoute(
        path: AppRoutes.scheduledUpcomingTab,
        builder: (context, state) => const UpcomingTripTabScreen(),
      ),
      GoRoute(
        path: AppRoutes.scheduledDriverAssigned,
        builder: (context, state) => const DriverAssignedScreen(),
      ),
      GoRoute(
        path: AppRoutes.scheduledDriverApproaching,
        builder: (context, state) => const DriverApproachingScreen(),
      ),
      GoRoute(
        path: AppRoutes.scheduledArrivedPickup,
        builder: (context, state) => const ArrivedAtPickupScreen(),
      ),
      GoRoute(
        path: AppRoutes.scheduledTripInProgress,
        builder: (context, state) => const TripInProgressScreen(),
      ),
      GoRoute(
        path: AppRoutes.scheduledArrivingDestination,
        builder: (context, state) => const ArrivingDestinationScreen(),
      ),
      GoRoute(
        path: AppRoutes.scheduledTripCompleted,
        builder: (context, state) => const ScheduledTripCompletedScreen(),
      ),
      GoRoute(
        path: AppRoutes.scheduledSchoolRunStatus,
        builder: (context, state) => const SchoolRunStatusScreen(),
      ),
      GoRoute(
        path: AppRoutes.scheduledHandoverVerification,
        builder: (context, state) => const HandoverVerificationScreen(),
      ),
      GoRoute(
        path: AppRoutes.scheduledHandoverConfirmed,
        builder: (context, state) => const HandoverConfirmedScreen(),
      ),
      GoRoute(
        path: AppRoutes.scheduledReportIssue,
        builder: (context, state) => const ReportIssueScreen(),
      ),
      GoRoute(
        path: AppRoutes.scheduledPaymentRefundDetails,
        builder: (context, state) => const PaymentRefundDetailsScreen(),
      ),
      GoRoute(
        path: AppRoutes.wallet,
        builder: (context, state) => const WalletScreen(),
      ),
      GoRoute(
        path: AppRoutes.rewards,
        builder: (context, state) => const RewardsScreen(),
      ),
      GoRoute(
        path: AppRoutes.walletPaymentMethods,
        builder: (context, state) => const SavedPaymentMethodsScreen(),
      ),
      GoRoute(
        path: AppRoutes.walletCoupons,
        builder: (context, state) => const CouponsScreen(),
      ),

      // Persistent 5-Tab Shell Navigation (Home, Send, Scheduled, Activity, Profile)
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

          // Branch 1: Send / Market Errand
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.send,
                builder: (context, state) => const MarketErrandHomeScreen(),
              ),
            ],
          ),

          // Branch 2: Scheduled (Scheduled Pickup Landing)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.scheduledLanding,
                builder: (context, state) => const ScheduledLandingScreen(),
              ),
            ],
          ),

          // Branch 3: Activity / Trips (Unified Activity Hub)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.trips,
                builder: (context, state) => const ActivityHubScreen(),
              ),
            ],
          ),

          // Branch 4: Profile / Account & Settings
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
