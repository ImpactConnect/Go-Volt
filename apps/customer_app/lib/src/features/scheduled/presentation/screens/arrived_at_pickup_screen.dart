import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../application/scheduled_trips_notifier.dart';

/// Screen 28 (SP-30): Arrived at Pickup Screen
/// Displays driver arrival notification, 10-minute waiting countdown timer, and pickup confirmation.
class ArrivedAtPickupScreen extends ConsumerWidget {
  const ArrivedAtPickupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scheduledTripsNotifierProvider);
    final notifier = ref.read(scheduledTripsNotifierProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF131A16) : Colors.white;
    final textColor = isDark ? Colors.white : GVColors.textPrimary;
    final subtextColor = isDark ? GVColors.neutral400 : GVColors.textSecondary;
    final cardBg = isDark ? const Color(0xFF1C2420) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;

    final trip = state.selectedTrip ??
        (state.upcomingTrips.isNotEmpty ? state.upcomingTrips.first : null);
    final driver = trip?.assignedDriver;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Driver has arrived',
          style: GVTypography.h2.copyWith(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: textColor,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Your driver is at the pickup location.',
                  style: GVTypography.bodyMedium.copyWith(
                    color: subtextColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: GVSpacing.sm),

            // Map area with green pin and vehicle ripple
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: double.infinity,
                    color: isDark
                        ? const Color(0xFF1E2822)
                        : const Color(0xFFE5EDE8),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 68,
                            height: 68,
                            decoration: BoxDecoration(
                              color: GVColors.primary.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  color: GVColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.electric_car_rounded,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: GVColors.primary,
                              borderRadius:
                                  BorderRadius.circular(GVBorderRadius.full),
                            ),
                            child: const Text(
                              'At pickup',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Position bottom overlay
                  Positioned(
                    left: GVSpacing.lg,
                    right: GVSpacing.lg,
                    bottom: GVSpacing.md,
                    child: Container(
                      padding: const EdgeInsets.all(GVSpacing.md),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius:
                            BorderRadius.circular(GVBorderRadius.card),
                        border: Border.all(color: borderColor),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Driver profile row
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 24,
                                backgroundColor: GVColors.primary.withValues(alpha: 0.2),
                                child: Text(
                                  driver != null && driver.name.isNotEmpty
                                      ? driver.name[0]
                                      : 'A',
                                  style: GVTypography.h3.copyWith(
                                    color: GVColors.primary,
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
                                      driver?.name ?? 'Ahmed Ibrahim',
                                      style: GVTypography.bodyLarge.copyWith(
                                        color: textColor,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.star_rounded,
                                          color: Color(0xFFF59E0B),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 2),
                                        Text(
                                          driver != null
                                              ? driver.rating.toStringAsFixed(1)
                                              : '4.8',
                                          style: GVTypography.caption.copyWith(
                                            color: subtextColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            driver != null
                                                ? '${driver.vehicleModel} • ${driver.vehiclePlate}'
                                                : 'Toyota Corolla • ABC-123XY',
                                            style: GVTypography.caption.copyWith(
                                              color: subtextColor,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  IconButton.filledTonal(
                                    style: IconButton.styleFrom(
                                      backgroundColor: isDark
                                          ? const Color(0xFF2E3D35)
                                          : GVColors.neutral100,
                                    ),
                                    icon: Icon(
                                      Icons.chat_bubble_outline_rounded,
                                      size: 18,
                                      color: textColor,
                                    ),
                                    onPressed: () {},
                                  ),
                                  const SizedBox(width: 6),
                                  IconButton.filledTonal(
                                    style: IconButton.styleFrom(
                                      backgroundColor: isDark
                                          ? const Color(0xFF2E3D35)
                                          : GVColors.neutral100,
                                    ),
                                    icon: Icon(
                                      Icons.phone_outlined,
                                      size: 18,
                                      color: textColor,
                                    ),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Divider(height: 20),

                          // Driver arrived green alert
                          Container(
                            padding: const EdgeInsets.all(GVSpacing.sm),
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(GVBorderRadius.md),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF2E7D32),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Driver has arrived at your pickup location. Please come out or confirm pickup.',
                                    style: GVTypography.caption.copyWith(
                                      color: const Color(0xFF1B5E20),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: GVSpacing.sm),

                          // 10-minute waiting countdown timer
                          Row(
                            children: [
                              const Icon(
                                Icons.access_time_rounded,
                                size: 18,
                                color: GVColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Waiting time',
                                style: GVTypography.bodySmall.copyWith(
                                  color: subtextColor,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                state.formattedWaitingTime,
                                style: GVTypography.bodyMedium.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Buttons
            Padding(
              padding: const EdgeInsets.all(GVSpacing.lg),
              child: Column(
                children: [
                  GVButton(
                    text: 'Confirm pickup',
                    type: GVButtonType.primary,
                    onPressed: () {
                      notifier.advanceTripStatus(ScheduledTripStatus.inProgress);
                      context.push(AppRoutes.scheduledTripInProgress);
                    },
                  ),
                  const SizedBox(height: GVSpacing.xs),
                  TextButton.icon(
                    icon: const Icon(
                      Icons.share_location_rounded,
                      size: 18,
                      color: GVColors.primary,
                    ),
                    label: Text(
                      'Share live location',
                      style: GVTypography.bodyMedium.copyWith(
                        color: GVColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Live location link copied to clipboard.'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
