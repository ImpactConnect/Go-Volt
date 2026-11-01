import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/presentation/widgets/live_google_map_view.dart';
import '../../../../core/router/app_router.dart';
import '../../application/scheduled_trips_notifier.dart';

/// Screen 29 (SP-31): Trip In Progress Screen
/// Shows live vehicle tracking along the route, destination ETA, Emergency assistance, and location sharing.
class TripInProgressScreen extends ConsumerWidget {
  const TripInProgressScreen({super.key});

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
          'Trip in progress',
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
                  "You're on your way to destination.",
                  style: GVTypography.bodyMedium.copyWith(
                    color: subtextColor,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(height: GVSpacing.sm),

            // Live Map tracking route
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: LiveGoogleMapView(
                      initialLatitude: trip?.pickupLocation.latitude ?? 6.8403,
                      initialLongitude: trip?.pickupLocation.longitude ?? 3.6487,
                      initialZoom: 15.0,
                      showZoomControls: true,
                      showMyLocationButton: false,
                    ),
                  ),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.route_rounded,
                          size: 56,
                          color: GVColors.primary,
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: GVColors.primary,
                            borderRadius:
                                BorderRadius.circular(GVBorderRadius.full),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.12),
                                blurRadius: 8,
                              ),
                            ],
                          ),
                          child: const Text(
                            '10 min (4.2 km)',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Bottom details card overlay
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

                          // Route details
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                size: 18,
                                color: Color(0xFFE53935),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Destination',
                                      style: GVTypography.caption.copyWith(
                                        color: subtextColor,
                                      ),
                                    ),
                                    Text(
                                      trip?.destinationAddress ??
                                          'Remo High Street, Shaganu, Ogun State',
                                      style: GVTypography.bodyMedium.copyWith(
                                        color: textColor,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.near_me_rounded,
                                size: 18,
                                color: GVColors.primary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Estimated arrival: 10 min (4.2 km)',
                                  style: GVTypography.bodySmall.copyWith(
                                    color: subtextColor,
                                    fontWeight: FontWeight.w500,
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

            // Bottom Buttons: Share live location and Emergency
            Padding(
              padding: const EdgeInsets.all(GVSpacing.lg),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: BorderSide(color: borderColor),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(GVBorderRadius.button),
                            ),
                          ),
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
                      ),
                      const SizedBox(width: GVSpacing.sm),
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            side: const BorderSide(color: Color(0xFFEF4444)),
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(GVBorderRadius.button),
                            ),
                          ),
                          icon: const Icon(
                            Icons.warning_amber_rounded,
                            size: 18,
                            color: Color(0xFFEF4444),
                          ),
                          label: Text(
                            'Emergency',
                            style: GVTypography.bodyMedium.copyWith(
                              color: const Color(0xFFEF4444),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            _showEmergencyDialog(context);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: GVSpacing.sm),
                  GVButton(
                    text: 'View arrival status',
                    type: GVButtonType.primary,
                    onPressed: () {
                      notifier.advanceTripStatus(
                          ScheduledTripStatus.arrivedAtDestination);
                      context.push(AppRoutes.scheduledArrivingDestination);
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

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444)),
            SizedBox(width: 8),
            Text('Emergency Assistance'),
          ],
        ),
        content: const Text(
          'Do you need immediate emergency response or Go-Volts 24/7 security dispatch for this scheduled trip?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Emergency team alerted. Go-Volts dispatch is calling your phone now.'),
                  backgroundColor: Color(0xFFEF4444),
                ),
              );
            },
            child: const Text('Call Dispatch'),
          ),
        ],
      ),
    );
  }
}
