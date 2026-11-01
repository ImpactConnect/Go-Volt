import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../application/scheduled_trips_notifier.dart';

/// Screen 26 (SP-28): Driver Assigned Screen
/// Confirms driver matching and shows vehicle details, route map, and direct communication channels.
class DriverAssignedScreen extends ConsumerWidget {
  const DriverAssignedScreen({super.key});

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

    final trip =
        state.selectedTrip ??
        (state.upcomingTrips.isNotEmpty ? state.upcomingTrips.first : null);
    final driver = trip?.assignedDriver;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Driver assigned',
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
              child: Text(
                'Your driver has been assigned for this trip.',
                style: GVTypography.bodyMedium.copyWith(
                  color: subtextColor,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: GVSpacing.sm),

            // Map preview with route and vehicle
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
                          Icon(
                            Icons.electric_car_rounded,
                            size: 48,
                            color: GVColors.primary,
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.black87 : Colors.white,
                              borderRadius: BorderRadius.circular(
                                GVBorderRadius.full,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                ),
                              ],
                            ),
                            child: Text(
                              'Tomorrow, 8:00 AM',
                              style: TextStyle(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Floating Card
            Container(
              padding: const EdgeInsets.all(GVSpacing.lg),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(GVBorderRadius.lg),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Driver details card
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundImage: NetworkImage(
                          driver?.avatarUrl ??
                              'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100',
                        ),
                      ),
                      const SizedBox(width: GVSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              driver?.name ?? 'Assigned Captain',
                              style: GVTypography.labelLarge.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            if (driver != null) ...[
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 16,
                                    color: Color(0xFFFFB800),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${driver.rating.toStringAsFixed(1)} (${driver.completedTrips} trips)',
                                    style: GVTypography.bodySmall.copyWith(
                                      color: subtextColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                '${driver.vehicleModel} • ${driver.vehiclePlate}',
                                style: GVTypography.bodySmall.copyWith(
                                  color: subtextColor,
                                  fontSize: 12,
                                ),
                              ),
                            ] else
                              Text(
                                'Awaiting vehicle assignment',
                                style: GVTypography.bodySmall.copyWith(
                                  color: subtextColor,
                                  fontSize: 12,
                                ),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.chat_bubble_outline_rounded,
                          color: GVColors.primary,
                        ),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.call_outlined,
                          color: GVColors.primary,
                        ),
                        onPressed: () {},
                      ),
                    ],
                  ),

                  const Divider(height: 20),

                  // Trip route preview
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 16,
                        color: GVColors.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          trip?.pickupLocation.address ??
                              '3, Ahmadu Bello Way, Kaduna',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GVTypography.bodySmall.copyWith(
                            color: subtextColor,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 16,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          trip?.destinationLocation.address ??
                              'Bayero University, Kaduna',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GVTypography.bodySmall.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: GVSpacing.lg),

                  // Primary CTA: View trip details (Advances to Driver Approaching)
                  GVButton(
                    text: 'View trip details',
                    onPressed: () {
                      notifier.advanceTripStatus(
                        ScheduledTripStatus.driverApproaching,
                      );
                      context.push(AppRoutes.scheduledDriverApproaching);
                    },
                  ),

                  const SizedBox(height: GVSpacing.sm),

                  // Secondary CTA: Manage trip
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () =>
                          context.push(AppRoutes.scheduledSkipTrip),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            GVBorderRadius.md,
                          ),
                        ),
                      ),
                      child: Text(
                        'Manage trip',
                        style: GVTypography.labelMedium.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
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
