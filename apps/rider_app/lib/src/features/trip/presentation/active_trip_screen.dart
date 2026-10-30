import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/active_trip_notifier.dart';
import '../domain/active_trip_state.dart';
import 'widgets/delivery_exception_dialog.dart';

/// Screen RD13 & RD14: Turn-by-Turn Route Navigation, Waypoints & EV Telematics.
class ActiveTripScreen extends ConsumerWidget {
  const ActiveTripScreen({
    super.key,
    required this.job,
  });

  final DispatchOfferDto job;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(activeTripNotifierProvider(job));
    final notifier = ref.read(activeTripNotifierProvider(job).notifier);

    // Auto-navigate to settlement when milestone is completed
    if (state.milestone == TripMilestone.completed && state.settlement != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/trip/settlement', extra: state.settlement);
      });
    }

    return Scaffold(
      backgroundColor: GVColors.darkBg,
      appBar: AppBar(
        title: Text(
          state.milestone == TripMilestone.inTransit ||
                  state.milestone == TripMilestone.arrivedAtDestination
              ? 'In Transit to Destination'
              : 'Heading to Pickup',
        ),
        backgroundColor: GVColors.darkBg,
        elevation: 0,
        actions: [
          // Emergency SOS Action
          IconButton(
            icon: const Icon(Icons.emergency_outlined, color: Colors.redAccent),
            tooltip: 'Emergency SOS Hotline',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  backgroundColor: Colors.redAccent,
                  content: Text('Go-Volts Emergency SOS Hotline: 112 / +234 1 800 9999'),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // EV Telematics & Geofenced Speed Limiter HUD
            Container(
              padding: const EdgeInsets.symmetric(horizontal: GVSpacing.md, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFF141917),
                border: Border(
                  bottom: BorderSide(color: Color(0xFF232D28), width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Speed & Speed Limit
                  Row(
                    children: [
                      Icon(
                        Icons.speed,
                        size: 20,
                        color: state.isSpeeding ? Colors.redAccent : GVColors.brandGreen,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${state.speedKmh.toInt()} km/h',
                        style: GVTypography.bodyMedium.copyWith(
                          color: state.isSpeeding ? Colors.redAccent : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(${state.speedLimitKmh.toInt()} limit)',
                        style: GVTypography.caption.copyWith(color: Colors.white54),
                      ),
                    ],
                  ),

                  // Battery Telematics
                  Row(
                    children: [
                      const Icon(Icons.battery_charging_full, color: GVColors.brandGreen, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '92% EV Battery',
                        style: GVTypography.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Active Route Map Simulation Canvas
            Expanded(
              child: Stack(
                children: [
                  Container(
                    color: const Color(0xFF101713),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            decoration: const BoxDecoration(
                              color: GVColors.deepGreen,
                              shape: BoxShape.circle,
                              boxShadow: GVShadows.glow,
                            ),
                            child: const Icon(
                              Icons.navigation,
                              color: GVColors.brandGreen,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: GVSpacing.sm),
                          Text(
                            'GPS TURN-BY-TURN ACTIVE',
                            style: GVTypography.caption.copyWith(
                              color: GVColors.brandGreen,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Follow Admiralty Way toward Victoria Island Expressway',
                            style: GVTypography.bodyMedium.copyWith(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Route Distance & ETA Overlay Badge
                  Positioned(
                    top: GVSpacing.md,
                    left: GVSpacing.md,
                    right: GVSpacing.md,
                    child: Container(
                      padding: const EdgeInsets.all(GVSpacing.md),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141917).withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(GVBorderRadius.md),
                        border: Border.all(color: const Color(0xFF2A3630)),
                        boxShadow: GVShadows.elevated,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                state.milestone == TripMilestone.inTransit ||
                                        state.milestone == TripMilestone.arrivedAtDestination
                                    ? 'TO DROPOFF'
                                    : 'TO PICKUP',
                                style: GVTypography.caption.copyWith(
                                  color: GVColors.brandGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${state.distanceRemainingKm} km',
                                style: GVTypography.h2.copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'ESTIMATED ARRIVAL',
                                style: GVTypography.caption.copyWith(color: Colors.white60),
                              ),
                              Text(
                                '${state.etaMinutes} mins',
                                style: GVTypography.h3.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Customer Contact Quick Actions
                  Positioned(
                    bottom: GVSpacing.md,
                    left: GVSpacing.md,
                    right: GVSpacing.md,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        FloatingActionButton.small(
                          heroTag: 'chat_btn',
                          backgroundColor: const Color(0xFF1C2420),
                          foregroundColor: GVColors.brandGreen,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Messaging ${job.customerName}...'),
                              ),
                            );
                          },
                          child: const Icon(Icons.chat_bubble_outline),
                        ),
                        const SizedBox(width: 8),
                        FloatingActionButton.small(
                          heroTag: 'call_btn',
                          backgroundColor: GVColors.deepGreen,
                          foregroundColor: GVColors.brandGreen,
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Dialing ${job.recipientPhone ?? "+2348039988776"} via Masked Relay',
                                ),
                              ),
                            );
                          },
                          child: const Icon(Icons.phone),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Waypoint Card & Bottom Milestone CTA Sheet
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: const BoxDecoration(
                color: Color(0xFF141917),
                border: Border(
                  top: BorderSide(color: Color(0xFF232D28), width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Address details
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        state.milestone == TripMilestone.inTransit ||
                                state.milestone == TripMilestone.arrivedAtDestination
                            ? Icons.location_on
                            : Icons.radio_button_checked,
                        color: state.milestone == TripMilestone.inTransit ||
                                state.milestone == TripMilestone.arrivedAtDestination
                            ? Colors.amber
                            : GVColors.brandGreen,
                        size: 20,
                      ),
                      const SizedBox(width: GVSpacing.xs),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.milestone == TripMilestone.inTransit ||
                                      state.milestone == TripMilestone.arrivedAtDestination
                                  ? 'Drop-off Destination'
                                  : 'Pickup Location',
                              style: GVTypography.caption.copyWith(color: Colors.white60),
                            ),
                            Text(
                              state.milestone == TripMilestone.inTransit ||
                                      state.milestone == TripMilestone.arrivedAtDestination
                                  ? job.dropoffAddress
                                  : job.pickupAddress,
                              style: GVTypography.bodyMedium.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          showDialog<void>(
                            context: context,
                            builder: (dCtx) => DeliveryExceptionDialog(
                              onReport: (reason, notes) {
                                notifier.reportException(reason, notes: notes);
                              },
                            ),
                          );
                        },
                        child: Text(
                          'Issue?',
                          style: GVTypography.caption.copyWith(color: Colors.amber),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: GVSpacing.md),

                  // Milestone Trigger Buttons
                  _buildMilestoneButton(context, state, notifier),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMilestoneButton(
    BuildContext context,
    ActiveTripState state,
    ActiveTripNotifier notifier,
  ) {
    switch (state.milestone) {
      case TripMilestone.approachingPickup:
        return GVPrimaryButton(
          label: state.isLoading ? 'Updating...' : 'I Have Arrived at Pickup',
          onPressed: state.isLoading ? null : () => notifier.markArrivedAtPickup(),
        );

      case TripMilestone.arrivedAtPickup:
        return GVPrimaryButton(
          label: 'Verify Handover OTP',
          onPressed: () => context.push('/trip/otp', extra: job),
        );

      case TripMilestone.otpVerified:
        return GVPrimaryButton(
          label: state.isLoading ? 'Starting...' : 'Start Transit to Destination',
          onPressed: state.isLoading ? null : () => notifier.startTransit(),
        );

      case TripMilestone.inTransit:
        return GVPrimaryButton(
          label: state.isLoading ? 'Updating...' : 'I Have Arrived at Destination',
          onPressed: state.isLoading ? null : () => notifier.markArrivedAtDestination(),
        );

      case TripMilestone.arrivedAtDestination:
        if (state.isDelivery) {
          return GVPrimaryButton(
            label: 'Capture Proof of Delivery',
            onPressed: () => context.push('/trip/proof', extra: job),
          );
        } else {
          return GVPrimaryButton(
            label: state.isLoading ? 'Settling...' : 'Complete Trip & Settle Fare',
            onPressed: state.isLoading ? null : () => notifier.completeTrip(),
          );
        }

      case TripMilestone.proofSubmitted:
        return GVPrimaryButton(
          label: state.isLoading ? 'Settling...' : 'Complete Trip & Settle Fare',
          onPressed: state.isLoading ? null : () => notifier.completeTrip(),
        );

      case TripMilestone.completed:
        return GVPrimaryButton(
          label: 'View Settlement Receipt',
          onPressed: () => context.go('/trip/settlement', extra: state.settlement),
        );
    }
  }
}
