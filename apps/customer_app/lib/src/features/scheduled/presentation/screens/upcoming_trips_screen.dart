import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../application/scheduled_trips_notifier.dart';

/// Screen 20 (SP-21): Upcoming Trips Screen
/// Displays chronological trip legs generated from active plans with live status badges.
class UpcomingTripsScreen extends ConsumerWidget {
  const UpcomingTripsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scheduledTripsNotifierProvider);
    final notifier = ref.read(scheduledTripsNotifierProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF131A16) : Colors.white;
    final textColor = isDark ? Colors.white : GVColors.textPrimary;
    final subtextColor = isDark ? GVColors.neutral400 : GVColors.textSecondary;
    final cardBg = isDark ? const Color(0xFF1C2420) : const Color(0xFFF6F8F7);
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Upcoming trips',
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
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: GVSpacing.lg,
            vertical: GVSpacing.sm,
          ),
          children: [
            ...state.upcomingTrips.map((trip) {
              return Padding(
                padding: const EdgeInsets.only(bottom: GVSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.scheduledDateStr,
                      style: GVTypography.labelMedium.copyWith(
                        color: subtextColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildTripCard(
                      context: context,
                      trip: trip,
                      cardBg: cardBg,
                      borderColor: borderColor,
                      textColor: textColor,
                      subtextColor: subtextColor,
                      onTap: () {
                        notifier.selectTrip(trip);
                        if (trip.status == ScheduledTripStatus.driverAssigned) {
                          context.push(AppRoutes.scheduledDriverAssigned);
                        } else {
                          context.push(AppRoutes.scheduledSkipTrip);
                        }
                      },
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTripCard({
    required BuildContext context,
    required ScheduledTripDto trip,
    required Color cardBg,
    required Color borderColor,
    required Color textColor,
    required Color subtextColor,
    required VoidCallback onTap,
  }) {
    final isDriverAssigned = trip.status == ScheduledTripStatus.driverAssigned;
    final badgeBg = isDriverAssigned
        ? GVColors.primary.withValues(alpha: 0.12)
        : const Color(0xFFE3F2FD);
    final badgeTextColor = isDriverAssigned
        ? GVColors.primary
        : const Color(0xFF1976D2);
    final badgeText = isDriverAssigned ? 'Driver assigned' : 'Scheduled';

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GVBorderRadius.md),
      child: Container(
        padding: const EdgeInsets.all(GVSpacing.md),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(GVBorderRadius.md),
          border: Border.all(color: borderColor),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 18,
                  color: GVColors.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  trip.scheduledTimeStr,
                  style: GVTypography.labelLarge.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(GVBorderRadius.full),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: badgeTextColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: subtextColor,
                ),
              ],
            ),
            const Divider(height: 18),
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
                    trip.pickupLocation.address,
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
            const SizedBox(height: 6),
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
                    trip.destinationLocation.address,
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
          ],
        ),
      ),
    );
  }
}
