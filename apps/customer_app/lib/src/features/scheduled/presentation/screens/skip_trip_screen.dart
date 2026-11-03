import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/scheduled_trips_notifier.dart';

/// Screen 22 (SP-23): Skip a Trip Screen
/// Enforces Section 21 6-hour policy cutoff and details whether entitlement is preserved.
class SkipTripScreen extends ConsumerWidget {
  const SkipTripScreen({super.key});

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

    final trip =
        state.selectedTrip ??
        (state.upcomingTrips.isNotEmpty ? state.upcomingTrips.first : null);

    final dateStr = trip?.scheduledDateStr ?? 'Tue, 7 Nov 2026';
    final timeStr = trip?.scheduledTimeStr ?? '8:00 AM';
    final pickupStr =
        trip?.pickupLocation.address ?? '3, Ahmadu Bello Way, Kaduna';
    final destStr =
        trip?.destinationLocation.address ?? 'Bayero University, Kaduna';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: GVSpacing.xs),
              Text(
                'Skip this trip?',
                style: GVTypography.h1.copyWith(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: GVSpacing.lg),

              // Trip Details Summary Card
              Container(
                width: double.infinity,
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
                          Icons.calendar_today_rounded,
                          size: 18,
                          color: GVColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '$dateStr, $timeStr',
                          style: GVTypography.labelLarge.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
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
                            pickupStr,
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
                            destStr,
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

              const SizedBox(height: GVSpacing.md),

              // Policy Alert Banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(GVSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E6),
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(color: const Color(0xFFFFE082)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_rounded,
                      color: Color(0xFFFFA000),
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'You can skip this trip and keep your entitlement if you do this at least 6 hours before pickup.',
                        style: GVTypography.bodySmall.copyWith(
                          color: const Color(0xFF6D4C41),
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Primary CTA: Skip trip
              GVButton(
                text: 'Skip trip',
                isLoading: state.isLoading,
                onPressed: () async {
                  if (trip != null) {
                    await notifier.skipTrip(trip.id);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(state.actionMessage ?? 'Trip skipped.'),
                          backgroundColor: GVColors.primary,
                        ),
                      );
                      context.pop();
                    }
                  }
                },
              ),

              const SizedBox(height: GVSpacing.sm),

              // Secondary CTA: Cancel
              SizedBox(
                width: double.infinity,
                height: 52,
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    'Cancel',
                    style: GVTypography.labelLarge.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: GVSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
