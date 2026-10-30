import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../application/tracking_notifier.dart';

/// R07 - R10 & D08: Live Trip and Parcel Delivery Tracking Screen.
class LiveTrackingScreen extends ConsumerStatefulWidget {
  const LiveTrackingScreen({super.key});

  @override
  ConsumerState<LiveTrackingScreen> createState() => _LiveTrackingScreenState();
}

class _LiveTrackingScreenState extends ConsumerState<LiveTrackingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final state = ref.read(liveTrackingNotifierProvider);
      if (state == null) {
        // Fallback default mock for direct navigation preview
        ref.read(liveTrackingNotifierProvider.notifier).initTracking(
              BookingDto(
                id: 'demo-live-01',
                bookingReference: 'GV-TRK-8392',
                serviceCode: ServiceCode.instantRide,
                status: BookingStatus.assigned,
                pickupLocation: const LocationDto(
                  latitude: 6.5244,
                  longitude: 3.3792,
                  address: '14 Marina Street, Lagos Island',
                  label: 'Marina Terminal',
                ),
                dropoffLocation: const LocationDto(
                  latitude: 6.4474,
                  longitude: 3.4723,
                  address: 'Admiralty Way, Lekki Phase 1',
                  label: 'Lekki Phase 1',
                ),
                priceBreakdown: const PriceBreakdownDto(
                  baseFare: 500.0,
                  distanceFare: 1200.0,
                  timeFare: 300.0,
                  totalFare: 2200.0,
                ),
                createdAt: DateTime.now(),
                riderId: 'rider-001',
                riderName: 'Babatunde Raji',
                riderPhone: '+2348039281742',
                riderRating: 4.9,
                vehicleType: VehicleType.electricBike,
                vehiclePlate: 'LAG-428-EV',
                vehicleModel: 'Volt-Bike 200 EV',
              ),
            );
      }
    });
  }

  void _showSafetySOSModal(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Consumer(
        builder: (ctx, ref, _) {
          final trackingState = ref.watch(liveTrackingNotifierProvider);
          final isRecording = trackingState?.isAudioRecording ?? false;

          return Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(GVBorderRadius.lg),
              ),
            ),
            padding: const EdgeInsets.all(GVSpacing.lg),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(GVSpacing.sm),
                        decoration: BoxDecoration(
                          color: GVColors.error.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.shield,
                          color: GVColors.error,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: GVSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Safety & Emergency Toolkit',
                              style: GVTypography.h3,
                            ),
                            Text(
                              'Go-Volts Rapid 24/7 Security Assistance',
                              style: GVTypography.caption.copyWith(
                                color: GVColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: GVSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(GVSpacing.md),
                    decoration: BoxDecoration(
                      color: GVColors.softBackground,
                      borderRadius: BorderRadius.circular(GVBorderRadius.md),
                      border: Border.all(color: GVColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.mic, color: GVColors.deepGreen),
                        const SizedBox(width: GVSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'In-Trip Audio Recording',
                                style: GVTypography.bodySmallMedium,
                              ),
                              Text(
                                isRecording
                                    ? 'Actively encrypted and recording'
                                    : 'Encrypted on-device safety recording',
                                style: GVTypography.caption.copyWith(
                                  color: isRecording
                                      ? GVColors.error
                                      : GVColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch(
                          value: isRecording,
                          activeThumbColor: GVColors.error,
                          onChanged: (_) {
                            ref
                                .read(liveTrackingNotifierProvider.notifier)
                                .toggleAudioRecording();
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: GVSpacing.md),
                  // Emergency Call CTAs
                  GVDestructiveButton(
                    label: 'Call Lagos Emergency (112 / 767)',
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Dialing Lagos Emergency Response 112...'),
                          backgroundColor: GVColors.error,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: GVSpacing.sm),
                  GVSecondaryButton(
                    label: 'Alert Trusted Guardians & Contacts',
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Trip tracking link & live GPS shared with emergency contacts.',
                          ),
                          backgroundColor: GVColors.brandGreen,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDriverChatModal(BuildContext context, String driverName) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(GVBorderRadius.lg),
          ),
        ),
        padding: const EdgeInsets.all(GVSpacing.lg),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Chat with $driverName', style: GVTypography.h3),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: GVSpacing.sm),
              Text(
                'Phone numbers remain masked and protected under Go-Volts Privacy Policy.',
                style: GVTypography.caption
                    .copyWith(color: GVColors.textSecondary),
              ),
              const SizedBox(height: GVSpacing.md),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    label: const Text("I'm waiting at the entrance"),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Message sent to driver')),
                      );
                    },
                  ),
                  ActionChip(
                    label: const Text('I am wearing a black jacket'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Message sent to driver')),
                      );
                    },
                  ),
                  ActionChip(
                    label: const Text('Take the Marina service lane'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Message sent to driver')),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showCancellationDialog(BuildContext context) {
    String selectedReason = 'Driver is taking too long';
    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text('Cancel Trip?', style: GVTypography.h3),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cancellation Policy: Free cancellation within 3 minutes of assignment. A ₦500 driver dispatch fee applies after 3 minutes.',
                style: GVTypography.bodySmall
                    .copyWith(color: GVColors.textSecondary),
              ),
              const SizedBox(height: GVSpacing.md),
              DropdownButtonFormField<String>(
                initialValue: selectedReason,
                decoration:
                    const InputDecoration(labelText: 'Reason for cancellation'),
                items: const [
                  DropdownMenuItem(
                    value: 'Driver is taking too long',
                    child: Text('Driver is taking too long'),
                  ),
                  DropdownMenuItem(
                    value: 'Driver asked me to cancel',
                    child: Text('Driver asked to cancel'),
                  ),
                  DropdownMenuItem(
                    value: 'Changed my pickup spot',
                    child: Text('Changed my pickup spot'),
                  ),
                  DropdownMenuItem(
                    value: 'Changed travel plans',
                    child: Text('Changed travel plans'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedReason = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Keep Trip'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: GVColors.error),
              onPressed: () async {
                Navigator.pop(ctx);
                await ref
                    .read(liveTrackingNotifierProvider.notifier)
                    .cancelTrip(selectedReason);
                if (context.mounted) {
                  context.go(AppRoutes.home);
                }
              },
              child: const Text('Confirm Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final trackingState = ref.watch(liveTrackingNotifierProvider);
    if (trackingState == null) {
      return const Scaffold(
        body:
            Center(child: CircularProgressIndicator(color: GVColors.brandGreen)),
      );
    }

    final booking = trackingState.booking;
    final driverName = booking.riderName ?? 'Babatunde Raji';
    final vehiclePlate = booking.vehiclePlate ?? 'LAG-428-EV';
    final vehicleModel = booking.vehicleModel ?? 'Volt-Bike 200 EV';
    final rating = booking.riderRating ?? 4.9;
    final status = trackingState.status;

    // Status banner text
    String statusTitle;
    String statusSubtitle;
    if (status == BookingStatus.assigned) {
      statusTitle = 'Driver is on the way';
      statusSubtitle =
          '${trackingState.etaMinutes} mins away • ${trackingState.distanceKm} km';
    } else if (status == BookingStatus.arrivedAtPickup) {
      statusTitle = 'Driver has arrived at pickup';
      statusSubtitle = 'Driver is waiting at ${booking.pickupLocation.label}';
    } else if (status == BookingStatus.inProgress) {
      statusTitle = 'Trip in progress';
      statusSubtitle =
          'Heading to ${booking.dropoffLocation.label} • ${trackingState.etaMinutes} mins left';
    } else {
      statusTitle = 'Trip Completed';
      statusSubtitle = 'Thank you for riding zero-emission with Go-Volts!';
    }

    // Milestones for vertical timeline
    final timelineSteps = [
      GVTimelineStep(
        label: 'Driver Assigned',
        state: GVTimelineStepState.completed,
        subtitle: driverName,
      ),
      GVTimelineStep(
        label: 'Pickup Spot',
        state: status == BookingStatus.assigned
            ? GVTimelineStepState.current
            : GVTimelineStepState.completed,
        subtitle: booking.pickupLocation.label,
      ),
      GVTimelineStep(
        label: 'In Transit',
        state: status == BookingStatus.inProgress
            ? GVTimelineStepState.current
            : (status == BookingStatus.completed
                ? GVTimelineStepState.completed
                : GVTimelineStepState.pending),
        subtitle: '${booking.dropoffLocation.label} (Zero Emission)',
      ),
      GVTimelineStep(
        label: 'Destination',
        state: status == BookingStatus.completed
            ? GVTimelineStepState.completed
            : GVTimelineStepState.pending,
      ),
    ];

    return Scaffold(
      backgroundColor: GVColors.softBackground,
      appBar: GVTopBar(
        title: 'Live Trip Tracking',
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.white),
            tooltip: 'Share Trip',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content:
                      Text('Secure live tracking link copied to clipboard!'),
                  backgroundColor: GVColors.brandGreen,
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.report_problem_outlined,
                color: Colors.white),
            tooltip: 'Dispute / Support',
            onPressed: () => context.push(AppRoutes.tripDispute),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Map preview & simulation panel
            Expanded(
              flex: 5,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: const Color(0xFFE2E8F0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Electric vehicle marker avatar
                        Container(
                          padding: const EdgeInsets.all(GVSpacing.md),
                          decoration: BoxDecoration(
                            color: GVColors.deepGreen,
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: GVColors.brandGreen, width: 3),
                            boxShadow: GVShadows.elevated,
                          ),
                          child: const Icon(
                            Icons.electric_moped,
                            color: GVColors.brandGreen,
                            size: 36,
                          ),
                        ),
                        const SizedBox(height: GVSpacing.sm),
                        // EV Battery chip & Plate
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: GVShadows.card,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.battery_charging_full,
                                  color: GVColors.brandGreen, size: 16),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  '${trackingState.batteryPercentage}% EV Battery • $vehiclePlate',
                                  style: GVTypography.bodySmallMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Top Status Float Banner
                  Positioned(
                    top: GVSpacing.md,
                    left: GVSpacing.md,
                    right: GVSpacing.md,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: GVSpacing.md, vertical: GVSpacing.sm),
                      decoration: BoxDecoration(
                        color: GVColors.deepGreen,
                        borderRadius:
                            BorderRadius.circular(GVBorderRadius.md),
                        boxShadow: GVShadows.elevated,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: GVColors.brandGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: GVSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  statusTitle,
                                  style: GVTypography.bodySmallMedium
                                      .copyWith(color: Colors.white),
                                ),
                                Text(
                                  statusSubtitle,
                                  style: GVTypography.caption
                                      .copyWith(color: GVColors.accentGreen),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            booking.bookingReference,
                            style: GVTypography.bodySmallMedium
                                .copyWith(color: GVColors.brandGreen),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom drawer details: Driver Card, Timeline & Actions
            Expanded(
              flex: 6,
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(GVBorderRadius.lg)),
                  boxShadow: GVShadows.card,
                ),
                child: ListView(
                  padding: const EdgeInsets.all(GVSpacing.md),
                  children: [
                    // Driver Card
                    GVDriverCard(
                      displayName: driverName,
                      vehicleDescription: vehicleModel,
                      plateNumber: vehiclePlate,
                      rating: rating,
                      etaLabel: '${trackingState.etaMinutes}m',
                      onCall: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                'Calling $driverName via masked line: +234 800-GOVOLTS...'),
                            backgroundColor: GVColors.brandGreen,
                          ),
                        );
                      },
                      onMessage: () =>
                          _showDriverChatModal(context, driverName),
                      onSafety: () => _showSafetySOSModal(context),
                    ),
                    const SizedBox(height: GVSpacing.md),

                    // Simulation controller row for testing / preview demo
                    Container(
                      padding: const EdgeInsets.all(GVSpacing.sm),
                      decoration: BoxDecoration(
                        color: GVColors.softBackground,
                        borderRadius:
                            BorderRadius.circular(GVBorderRadius.sm),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                ref
                                    .read(liveTrackingNotifierProvider.notifier)
                                    .advanceTripStatus(
                                        BookingStatus.arrivedAtPickup);
                              },
                              child: const Text('Arrived',
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                ref
                                    .read(liveTrackingNotifierProvider.notifier)
                                    .advanceTripStatus(
                                        BookingStatus.inProgress);
                              },
                              child: const Text('En Route',
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: GVColors.brandGreen,
                                foregroundColor: GVColors.deepGreen,
                              ),
                              onPressed: () {
                                ref
                                    .read(liveTrackingNotifierProvider.notifier)
                                    .advanceTripStatus(
                                        BookingStatus.completed);
                                context.go(AppRoutes.tripCompleted);
                              },
                              child: const Text('Complete',
                                  style: TextStyle(fontSize: 12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: GVSpacing.md),

                    // Progress timeline
                    Text('Trip Progress', style: GVTypography.h3),
                    const SizedBox(height: GVSpacing.sm),
                    GVTimeline(steps: timelineSteps),
                    const SizedBox(height: GVSpacing.md),

                    // Cancel ride action button
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: GVColors.error,
                        side: const BorderSide(color: GVColors.error),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => _showCancellationDialog(context),
                      icon: const Icon(Icons.cancel_outlined, size: 18),
                      label: const Text('Cancel Booking'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
