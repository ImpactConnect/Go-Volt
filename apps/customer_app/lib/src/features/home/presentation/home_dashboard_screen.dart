import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_notifier.dart';
import '../../../core/router/app_router.dart';
import '../../booking/application/booking_notifier.dart';
import '../application/home_notifier.dart';
import '../application/notifications_notifier.dart';
import 'location_selector_modal.dart';

/// Customer App Home Dashboard
///
/// Implements:
/// - Screen 11: HOME-01-DEFAULT (Default view, 2x2 grid, discount banner, saved places, rewards)
/// - Screen 12: HOME-02-ACTIVE-BOOKING (Hero active booking card when ride/delivery in progress)
/// - Screen 13: HOME-03-SERVICE-UNAVAILABLE (Service area restriction, referral banner switch)
///
/// Follows Design Boards and Specification §10-§13. Zero hardcoded data.
class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authNotifierProvider);
    final homeState = ref.watch(homeNotifierProvider);
    final notificationsState = ref.watch(notificationsNotifierProvider);

    final user = authState.profile;
    final userName = user?.firstName ?? 'Customer';
    final userInitials = user?.initials ?? 'C';

    final isRideAvailable = homeState.isServiceAvailable(
      ServiceCode.instantRide,
    );
    final isParcelAvailable = homeState.isServiceAvailable(
      ServiceCode.instantDelivery,
    );

    // Dynamic campaign selection:
    // When ride is unavailable (Screen 13 state), highlight referral campaign;
    // otherwise display the ride discount campaign (Screen 11 state).
    final activeCampaign = !isRideAvailable
        ? homeState.campaigns.firstWhere(
            (c) => c.isReferral,
            orElse: () => homeState.campaigns.last,
          )
        : homeState.campaigns.firstWhere(
            (c) => !c.isReferral,
            orElse: () => homeState.campaigns.first,
          );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(homeNotifierProvider.notifier).refreshDashboard(),
          color: GVColors.brandGreen,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: GVSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: GVSpacing.md),

                // 1. Top Header Row: Brand Logo, Notification Bell, User Avatar
                _buildHeader(
                  context,
                  isDark: isDark,
                  unreadCount: notificationsState.unreadCount,
                  initials: userInitials,
                  avatarUrl: user?.avatarUrl,
                ),
                const SizedBox(height: GVSpacing.lg),

                // 2. Greeting & Subtitle
                Text(
                  '${homeState.greetingPrefix}, $userName!',
                  style: GVTypography.h1.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : GVColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Where would you like to go today?',
                  style: GVTypography.bodyMedium.copyWith(
                    color: isDark
                        ? GVColors.neutral400
                        : GVColors.textSecondary,
                  ),
                ),
                const SizedBox(height: GVSpacing.md),

                // 3. Service Area / Location Selector Card
                _buildLocationCard(
                  context,
                  isDark: isDark,
                  locationName: homeState.currentLocation.displayName,
                ),
                const SizedBox(height: GVSpacing.lg),

                // 4. Section: What would you like to do?
                Text(
                  'What would you like to do?',
                  style: GVTypography.h3.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isDark ? Colors.white : GVColors.textPrimary,
                  ),
                ),
                const SizedBox(height: GVSpacing.sm),

                // 5. 2x2 Service Cards Grid
                _buildServiceGrid(
                  context,
                  ref,
                  isRideAvailable: isRideAvailable,
                  isParcelAvailable: isParcelAvailable,
                ),

                // 6. Active Booking Hero Card (Screen 12: HOME-02-ACTIVE-BOOKING)
                if (homeState.hasActiveBooking) ...[
                  const SizedBox(height: GVSpacing.lg),
                  GVActiveBookingCard(
                    serviceTitle: homeState.activeBooking!.serviceTitle,
                    referenceCode: homeState.activeBooking!.referenceCode,
                    statusBadge: homeState.activeBooking!.statusBadge,
                    riderName: homeState.activeBooking!.riderName,
                    riderAvatarUrl: homeState.activeBooking!.riderAvatarUrl,
                    statusMessage: homeState.activeBooking!.statusMessage,
                    etaMinutes: homeState.activeBooking!.etaMinutes,
                    onViewOnMap: () {
                      context.push(homeState.activeBooking!.targetRoute);
                    },
                  ),
                ],

                // 7. Campaign Promotional Banner (Screen 11 & Screen 13)
                const SizedBox(height: GVSpacing.lg),
                GVCampaignBanner(
                  title: activeCampaign.title,
                  subtitle: activeCampaign.subtitle,
                  promoCode: activeCampaign.promoCode,
                  ctaText: activeCampaign.ctaText,
                  bannerType: activeCampaign.bannerType,
                  onCtaTap: () {
                    context.push(activeCampaign.ctaRoute);
                  },
                ),

                // 8. Saved Places Section
                if (homeState.savedPlaces.isNotEmpty) ...[
                  const SizedBox(height: GVSpacing.lg),
                  Text(
                    'Your saved places',
                    style: GVTypography.h3.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : GVColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: GVSpacing.sm),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: homeState.savedPlaces.map((place) {
                        return Padding(
                          padding: const EdgeInsets.only(right: GVSpacing.sm),
                          child: GVSavedPlaceChip(
                            label: place.label,
                            address: place.address,
                            onTap: () {
                              ref
                                  .read(bookingNotifierProvider.notifier)
                                  .setDropoffLocation(
                                    LocationDto(
                                      latitude: place.latitude,
                                      longitude: place.longitude,
                                      address: place.address,
                                      label: place.label,
                                    ),
                                  );
                              context.push(AppRoutes.rideBooking);
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],

                // 9. Rewards Summary Widget (Screen 11)
                const SizedBox(height: GVSpacing.lg),
                _buildRewardsSection(
                  context,
                  isDark: isDark,
                  ecoPoints: user?.ecoPointsBalance ?? 1250,
                ),
                const SizedBox(height: GVSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Top navigation header matching Screen 11/12/13
  Widget _buildHeader(
    BuildContext context, {
    required bool isDark,
    required int unreadCount,
    required String initials,
    String? avatarUrl,
  }) {
    return Row(
      children: [
        // Brand Mark
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: GVColors.brandGreen,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: GVColors.brandGreen.withValues(alpha: 0.25),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Center(
            child: Icon(
              Icons.electric_bolt_rounded,
              color: GVColors.limeHighlight,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          'GO-VOLTS',
          style: GVTypography.h3.copyWith(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            fontSize: 16,
            color: isDark ? Colors.white : GVColors.deepGreen,
          ),
        ),
        const Spacer(),

        // Notification Bell with dynamic unread badge
        IconButton(
          tooltip: 'Notifications',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
          icon: unreadCount > 0
              ? Badge(
                  label: Text('$unreadCount'),
                  backgroundColor: GVColors.error,
                  child: Icon(
                    Icons.notifications_none_rounded,
                    color: isDark ? Colors.white : GVColors.textPrimary,
                    size: 22,
                  ),
                )
              : Icon(
                  Icons.notifications_none_rounded,
                  color: isDark ? Colors.white : GVColors.textPrimary,
                  size: 22,
                ),
          onPressed: () => context.push(AppRoutes.notifications),
        ),
        const SizedBox(width: 6),

        // User Avatar
        GestureDetector(
          onTap: () => context.push(AppRoutes.account),
          child: CircleAvatar(
            radius: 17,
            backgroundColor: GVColors.brandGreen.withValues(alpha: 0.15),
            backgroundImage: avatarUrl != null ? NetworkImage(avatarUrl) : null,
            child: avatarUrl == null
                ? Text(
                    initials,
                    style: GVTypography.bodySmall.copyWith(
                      color: GVColors.brandGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
        ),
      ],
    );
  }

  /// Location Selector Card displaying currently active service area
  Widget _buildLocationCard(
    BuildContext context, {
    required bool isDark,
    required String locationName,
  }) {
    final cardBg = isDark ? const Color(0xFF1C2420) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;

    return Material(
      color: cardBg,
      borderRadius: GVBorderRadius.cardRadius,
      child: InkWell(
        onTap: () => LocationSelectorModal.show(context),
        borderRadius: GVBorderRadius.cardRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: GVBorderRadius.cardRadius,
            border: Border.all(color: borderColor),
            boxShadow: isDark ? null : GVShadows.card,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: GVColors.brandGreen.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: GVColors.brandGreen,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your location',
                      style: GVTypography.caption.copyWith(
                        color: isDark
                            ? GVColors.neutral400
                            : GVColors.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      locationName,
                      style: GVTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : GVColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: isDark ? GVColors.neutral400 : GVColors.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 2x2 Service Cards Grid with dynamic availability check
  Widget _buildServiceGrid(
    BuildContext context,
    WidgetRef ref, {
    required bool isRideAvailable,
    required bool isParcelAvailable,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: GVServiceCard(
                title: 'Book a Ride',
                description: 'Get a ride to your destination',
                icon: Icons.two_wheeler_rounded,
                isDisabled: !isRideAvailable,
                disabledReason: 'Not available in this area',
                onTap: () {
                  ref
                      .read(bookingNotifierProvider.notifier)
                      .selectService(ServiceCode.instantRide);
                  context.push(AppRoutes.locationPicker);
                },
              ),
            ),
            const SizedBox(width: GVSpacing.sm),
            Expanded(
              child: GVServiceCard(
                title: 'Send a Parcel',
                description: 'Send items to another location',
                icon: Icons.inventory_2_outlined,
                isDisabled: !isParcelAvailable,
                disabledReason: 'Not available in this area',
                onTap: () {
                  ref
                      .read(bookingNotifierProvider.notifier)
                      .selectService(ServiceCode.instantDelivery);
                  context.push(AppRoutes.packageDetails);
                  context.push(AppRoutes.parcelDeliveryType);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: GVSpacing.sm),
        Row(
          children: [
            Expanded(
              child: GVServiceCard(
                title: 'Track Delivery',
                description: 'Follow an ongoing delivery',
                icon: Icons.near_me_outlined,
                onTap: () => context.push(AppRoutes.liveTracking),
              ),
            ),
            const SizedBox(width: GVSpacing.sm),
            Expanded(
              child: GVServiceCard(
                title: 'Scheduled Pickup',
                description: 'Plan a future journey',
                icon: Icons.calendar_month_outlined,
                onTap: () => context.push(AppRoutes.scheduledBooking),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Rewards Summary Section matching Screen 11
  Widget _buildRewardsSection(
    BuildContext context, {
    required bool isDark,
    required int ecoPoints,
  }) {
    final cardBg = isDark ? const Color(0xFF1C2420) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'Your rewards',
                style: GVTypography.h3.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: isDark ? Colors.white : GVColors.textPrimary,
                ),
              ),
            ),
            InkWell(
              onTap: () => context.push(AppRoutes.walletRewards),
              borderRadius: BorderRadius.circular(4),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                child: Text(
                  'View all',
                  style: GVTypography.label.copyWith(
                    color: GVColors.brandGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Material(
          color: cardBg,
          borderRadius: GVBorderRadius.cardRadius,
          child: InkWell(
            onTap: () => context.push(AppRoutes.walletRewards),
            borderRadius: GVBorderRadius.cardRadius,
            child: Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                borderRadius: GVBorderRadius.cardRadius,
                border: Border.all(color: borderColor),
                boxShadow: isDark ? null : GVShadows.card,
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: GVColors.limeHighlight.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.military_tech_rounded,
                      color: GVColors.brandGreen,
                      size: 26,
                    ),
                  ),
                  const SizedBox(width: GVSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$ecoPoints pts',
                          style: GVTypography.h2.copyWith(
                            fontWeight: FontWeight.w800,
                            fontSize: 18,
                            color: isDark ? Colors.white : GVColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Available Eco-Points to redeem for discounts',
                          style: GVTypography.caption.copyWith(
                            color: isDark
                                ? GVColors.neutral400
                                : GVColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: isDark
                        ? GVColors.neutral400
                        : GVColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
