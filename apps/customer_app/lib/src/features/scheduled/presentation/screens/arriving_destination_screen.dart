import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/live_google_map_view.dart';
import '../../../../core/router/app_router.dart';
import '../../application/scheduled_trips_notifier.dart';

/// Screen 30 (SP-32): Arriving at Destination Screen
/// Approaching destination indicator (e.g. 2 min away), driver info, and arrival confirmation.
class ArrivingDestinationScreen extends ConsumerWidget {
  const ArrivingDestinationScreen({super.key});

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
    final isSchoolRun = trip?.purpose == TripPurpose.schoolRun;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Arriving at destination',
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
                  'Your driver is almost there.',
                  style: GVTypography.bodyMedium.copyWith(
                    color: subtextColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: GVSpacing.sm),

            // Map preview with red destination pin and ETA pill
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: LiveGoogleMapView(
                      initialLatitude: trip?.destinationLocation.latitude ?? 6.8403,
                      initialLongitude: trip?.destinationLocation.longitude ?? 3.6487,
                      initialZoom: 15.5,
                      showZoomControls: true,
                      showMyLocationButton: false,
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1F2937),
                            borderRadius:
                                BorderRadius.circular(GVBorderRadius.full),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.near_me_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 6),
                              Text(
                                '2 min away',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Icon(
                          Icons.location_on_rounded,
                          size: 48,
                          color: Color(0xFFEF4444),
                        ),
                      ],
                    ),
                  ),

                  // Bottom card overlay
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
                          // Driver Profile Row
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

                          // Estimated arrival info
                          Row(
                            children: [
                              const Icon(
                                Icons.calendar_today_outlined,
                                size: 16,
                                color: GVColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Estimated arrival: 2 min',
                                style: GVTypography.bodyMedium.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                size: 16,
                                color: Color(0xFFEF4444),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Destination: ${trip?.destinationAddress ?? "Remo High Street, Shaganu, Ogun State"}',
                                  style: GVTypography.bodySmall.copyWith(
                                    color: subtextColor,
                                  ),
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
                    text: 'Confirm arrival',
                    type: GVButtonType.primary,
                    onPressed: () {
                      if (isSchoolRun) {
                        // School run requires vertical milestone view & gated PIN verification
                        notifier.advanceTripStatus(
                            ScheduledTripStatus.handoverPending);
                        context.push(AppRoutes.scheduledSchoolRunStatus);
                      } else {
                        // Standard trip completes upon arrival
                        notifier.advanceTripStatus(
                            ScheduledTripStatus.completed);
                        context.push(AppRoutes.scheduledTripCompleted);
                      }
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
                          content: Text(
                              'Live location link copied to clipboard.'),
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
