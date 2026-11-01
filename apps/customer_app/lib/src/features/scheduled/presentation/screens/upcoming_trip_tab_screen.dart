import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../application/scheduled_trips_notifier.dart';

/// Screen 25 (SP-21): Upcoming Trip Tab Screen
/// Main scheduled bottom-tab view displaying upcoming trips, driver status, and contact actions.
class UpcomingTripTabScreen extends ConsumerWidget {
  const UpcomingTripTabScreen({super.key});

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

    final tripList = switch (state.activeTabIndex) {
      1 => state.completedTrips,
      2 => state.cancelledTrips,
      _ => state.upcomingTrips,
    };

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Upcoming Trip',
          style: GVTypography.h2.copyWith(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Tabs: [Upcoming (3)] [Completed (12)] [Cancelled (2)]
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: GVSpacing.lg,
                vertical: GVSpacing.xs,
              ),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTabButton(
                        title: 'Upcoming (${state.upcomingTrips.length})',
                        isSelected: state.activeTabIndex == 0,
                        onTap: () => notifier.setActiveTab(0),
                      ),
                    ),
                    Expanded(
                      child: _buildTabButton(
                        title:
                            'Completed (${state.completedTrips.length + 12})',
                        isSelected: state.activeTabIndex == 1,
                        onTap: () => notifier.setActiveTab(1),
                      ),
                    ),
                    Expanded(
                      child: _buildTabButton(
                        title: 'Cancelled (${state.cancelledTrips.length + 2})',
                        isSelected: state.activeTabIndex == 2,
                        onTap: () => notifier.setActiveTab(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: GVSpacing.sm),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
                itemCount: tripList.length,
                itemBuilder: (context, index) {
                  final trip = tripList[index];
                  return _buildTripDetailCard(
                    context: context,
                    trip: trip,
                    cardBg: cardBg,
                    borderColor: borderColor,
                    textColor: textColor,
                    subtextColor: subtextColor,
                    onViewDetails: () {
                      notifier.selectTrip(trip);
                      context.push(AppRoutes.scheduledDriverAssigned);
                    },
                    onContactDriver: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Calling ${trip.assignedDriver?.name ?? "driver"}...',
                          ),
                          backgroundColor: GVColors.primary,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripDetailCard({
    required BuildContext context,
    required ScheduledTripDto trip,
    required Color cardBg,
    required Color borderColor,
    required Color textColor,
    required Color subtextColor,
    required VoidCallback onViewDetails,
    required VoidCallback onContactDriver,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: GVSpacing.md),
      padding: const EdgeInsets.all(GVSpacing.md),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        border: Border.all(color: borderColor),
      ),
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
          const SizedBox(height: 8),

          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: GVColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  trip.isSchoolRun
                      ? Icons.school_rounded
                      : Icons.business_center_rounded,
                  color: GVColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.isSchoolRun ? 'School Run' : 'Work Commute',
                      style: GVTypography.labelLarge.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      trip.scheduledTimeStr,
                      style: GVTypography.bodySmall.copyWith(
                        color: subtextColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: GVColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(GVBorderRadius.full),
                ),
                child: const Text(
                  'Driver assigned',
                  style: TextStyle(
                    color: GVColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const Divider(height: 20),

          // Route
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

          if (trip.assignedDriver != null) ...[
            const Divider(height: 20),
            // Driver Card Preview
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: GVColors.primary.withValues(alpha: 0.2),
                  child: Text(
                    trip.assignedDriver!.name.isNotEmpty
                        ? trip.assignedDriver!.name[0]
                        : 'A',
                    style: GVTypography.labelMedium.copyWith(
                      color: GVColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip.assignedDriver!.name,
                        style: GVTypography.labelMedium.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${trip.assignedDriver!.vehicleModel} • ★ ${trip.assignedDriver!.rating.toStringAsFixed(1)}',
                        style: GVTypography.bodySmall.copyWith(
                          color: subtextColor,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: GVSpacing.md),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    onPressed: onViewDetails,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(GVBorderRadius.sm),
                      ),
                    ),
                    child: Text(
                      'View details',
                      style: GVTypography.labelSmall.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: onContactDriver,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cardBg,
                      elevation: 0,
                      side: BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(GVBorderRadius.sm),
                      ),
                    ),
                    child: Text(
                      'Contact driver',
                      style: GVTypography.labelSmall.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GVBorderRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? GVColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(GVBorderRadius.sm),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : GVColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}
