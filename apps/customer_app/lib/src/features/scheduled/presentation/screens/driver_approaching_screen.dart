import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/live_google_map_view.dart';
import '../../../../core/router/app_router.dart';
import '../../application/scheduled_trips_notifier.dart';

/// Screen 27 (SP-29): Driver Approaching Screen
/// Live ETA tracking showing approaching driver, pickup time reminder, and "I'm ready" signal.
class DriverApproachingScreen extends ConsumerWidget {
  const DriverApproachingScreen({super.key});

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
          'Driver approaching',
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
                'Your driver is on the way to pickup.',
                style: GVTypography.bodyMedium.copyWith(
                  color: subtextColor,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(height: GVSpacing.sm),

            // Map preview with moving vehicle and ETA pill
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: LiveGoogleMapView(
                      initialLatitude: trip?.pickupLocation.latitude ?? 6.8403,
                      initialLongitude: trip?.pickupLocation.longitude ?? 3.6487,
                      initialZoom: 15.5,
                      showZoomControls: true,
                      showMyLocationButton: false,
                    ),
                  ),
                  Center(
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
                              horizontal: 14, vertical: 6),
                          decoration: BoxDecoration(
                            color: GVColors.primary,
                            borderRadius:
                                BorderRadius.circular(GVBorderRadius.full),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Text(
                            '5 min away',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Card
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
                  // Driver details row
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
                              driver?.name ?? 'Ahmed Ibrahim',
                              style: GVTypography.labelLarge.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    size: 16, color: Color(0xFFFFB800)),
                                const SizedBox(width: 4),
                                Text(
                                  '${driver?.rating.toStringAsFixed(1) ?? "4.8"} • ${driver?.vehicleModel ?? "Toyota Corolla"}',
                                  style: GVTypography.bodySmall.copyWith(
                                    color: subtextColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chat_bubble_outline_rounded,
                            color: GVColors.primary),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.call_outlined,
                            color: GVColors.primary),
                        onPressed: () {},
                      ),
                    ],
                  ),

                  const Divider(height: 20),

                  // Pickup info row
                  Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 16, color: GVColors.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Pickup time: 8:00 AM',
                        style: GVTypography.bodySmall.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on_rounded,
                          size: 16, color: GVColors.primary),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          trip?.pickupLocation.address ??
                              'Central Roundabout, Shaganu, Ogun State',
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

                  const SizedBox(height: GVSpacing.lg),

                  // Primary CTA: I'm ready
                  GVButton(
                    text: 'I\'m ready',
                    onPressed: () {
                      notifier.advanceTripStatus(
                          ScheduledTripStatus.arrivedAtPickup);
                      context.push(AppRoutes.scheduledArrivedPickup);
                    },
                  ),

                  const SizedBox(height: GVSpacing.sm),

                  // Secondary CTA: Share live location
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.share_location_rounded, size: 18),
                      label: const Text('Share live location'),
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Live location link copied.'),
                            backgroundColor: GVColors.primary,
                          ),
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: borderColor),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(GVBorderRadius.md),
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
