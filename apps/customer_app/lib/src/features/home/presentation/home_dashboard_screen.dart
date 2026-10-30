import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_notifier.dart';
import '../../../core/router/app_router.dart';
import '../../booking/application/booking_notifier.dart';

/// B01 — Customer App Home Dashboard
/// Follows Design Board Row 2 & Screen Specifications §4-B.
class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.profile;
    final userName = user?.fullName.split(' ').first ?? 'Folake';

    return Scaffold(
      backgroundColor: GVColors.softBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: GVSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: GVSpacing.md),

              // 1. Header Row (User avatar, location, wallet balance)
              Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: GVColors.brandGreen.withValues(alpha: 0.2),
                    child: Text(
                      userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                      style: GVTypography.h3.copyWith(
                        color: GVColors.brandGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: GVSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hello, $userName 👋',
                          style: GVTypography.h3.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 14,
                              color: GVColors.brandGreen,
                            ),
                            const SizedBox(width: 2),
                            Flexible(
                              child: Text(
                                'Marina, Lagos Island',
                                style: GVTypography.bodySmall.copyWith(
                                  color: GVColors.textSecondary,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Wallet mini chip
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.wallet),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: GVSpacing.sm,
                        vertical: GVSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(GVBorderRadius.full),
                        boxShadow: GVShadows.card,
                        border: Border.all(color: GVColors.border),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.account_balance_wallet_rounded,
                            size: 16,
                            color: GVColors.brandGreen,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '₦15,000',
                            style: GVTypography.label.copyWith(
                              fontWeight: FontWeight.bold,
                              color: GVColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // Notification bell
                  IconButton(
                    tooltip: 'Notifications',
                    icon: const Badge(
                      label: Text('2'),
                      backgroundColor: Colors.redAccent,
                      child: Icon(Icons.notifications_none, color: GVColors.brandGreen),
                    ),
                    onPressed: () => context.push(AppRoutes.notifications),
                  ),
                ],
              ),
              const SizedBox(height: GVSpacing.lg),

              // 2. Eco Impact Banner
              Container(
                padding: const EdgeInsets.all(GVSpacing.md),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [GVColors.deepGreen, Color(0xFF0F3E2F)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  boxShadow: GVShadows.elevated,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(GVSpacing.sm),
                      decoration: BoxDecoration(
                        color: GVColors.limeHighlight.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.energy_savings_leaf_rounded,
                        color: GVColors.limeHighlight,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: GVSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '14.2 kg CO₂ Offset',
                            style: GVTypography.h3.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'You’ve completed 8 zero-emission electric trips!',
                            style: GVTypography.bodySmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GVSpacing.xl),

              // 3. Core Services Headline
              Text(
                'Our Services',
                style: GVTypography.h2.copyWith(
                  fontWeight: FontWeight.bold,
                  color: GVColors.textPrimary,
                ),
              ),
              const SizedBox(height: GVSpacing.sm),

              // Service Cards Grid (4 Core Services)
              GVServiceCard(
                title: 'Ride Electric',
                description: 'Fast, silent, on-demand electric commutes.',
                icon: Icons.electric_scooter_rounded,
                onTap: () => _onSelectService(context, ref, ServiceCode.instantRide),
              ),
              const SizedBox(height: GVSpacing.sm),

              GVServiceCard(
                title: 'Send Package',
                description: 'Swift doorstep parcel delivery with live tracking.',
                icon: Icons.local_shipping_rounded,
                onTap: () =>
                    _onSelectService(context, ref, ServiceCode.instantDelivery),
              ),
              const SizedBox(height: GVSpacing.sm),

              GVServiceCard(
                title: 'Scheduled Ride',
                description: 'Plan your commute in advance with guaranteed dispatch.',
                icon: Icons.access_time_filled_rounded,
                onTap: () =>
                    _onSelectService(context, ref, ServiceCode.scheduledRide),
              ),
              const SizedBox(height: GVSpacing.sm),

              GVServiceCard(
                title: 'Scheduled Pickup',
                description: 'Recurring or planned parcel collections.',
                icon: Icons.calendar_month_rounded,
                onTap: () =>
                    _onSelectService(context, ref, ServiceCode.scheduledPickup),
              ),
              const SizedBox(height: GVSpacing.xl),

              // 4. Saved / Recent Destinations
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quick Destinations',
                    style: GVTypography.h3.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.push(AppRoutes.locationPicker),
                    child: Text(
                      'View All',
                      style: GVTypography.label.copyWith(
                        color: GVColors.brandGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: GVSpacing.xs),

              _buildDestinationRow(
                context: context,
                ref: ref,
                icon: Icons.home_rounded,
                title: 'Home',
                address: '14 Marina Street, Lagos Island',
                lat: 6.5244,
                lng: 3.3792,
              ),
              const SizedBox(height: GVSpacing.xs),
              _buildDestinationRow(
                context: context,
                ref: ref,
                icon: Icons.work_rounded,
                title: 'Work',
                address: '25 Adeola Odeku, Victoria Island',
                lat: 6.4281,
                lng: 3.4219,
              ),
              const SizedBox(height: GVSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  void _onSelectService(BuildContext context, WidgetRef ref, ServiceCode code) {
    ref.read(bookingNotifierProvider.notifier).selectService(code);
    context.push(AppRoutes.locationPicker);
  }

  Widget _buildDestinationRow({
    required BuildContext context,
    required WidgetRef ref,
    required IconData icon,
    required String title,
    required String address,
    required double lat,
    required double lng,
  }) {
    return InkWell(
      onTap: () {
        ref.read(bookingNotifierProvider.notifier).setDropoffLocation(
              LocationDto(latitude: lat, longitude: lng, address: address, label: title),
            );
        context.push(AppRoutes.rideBooking);
      },
      borderRadius: BorderRadius.circular(GVBorderRadius.md),
      child: Container(
        padding: const EdgeInsets.all(GVSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(GVBorderRadius.md),
          border: Border.all(color: GVColors.border),
          boxShadow: GVShadows.card,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(GVSpacing.sm),
              decoration: BoxDecoration(
                color: GVColors.softBackground,
                borderRadius: BorderRadius.circular(GVBorderRadius.sm),
              ),
              child: const Icon(Icons.location_on_rounded,
                  color: GVColors.brandGreen, size: 20),
            ),
            const SizedBox(width: GVSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GVTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    address,
                    style: GVTypography.bodySmall.copyWith(
                      color: GVColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: GVColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}
