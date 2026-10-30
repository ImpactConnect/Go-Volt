import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../application/parcel_booking_notifier.dart';

/// Screen 11, 12, 13 — Parcel Live Tracking:
/// - Screen 11 (Rider Assigned): Courier profile, vehicle info, 6-min ETA, map route to pickup, Call & Share actions.
/// - Screen 12 (Rider Approaching): 2-min ETA callout, readiness alert pill, live tracking map.
/// - Screen 13 (Pickup Completed): Handover illustration, milestone timeline (10:05 AM pickup), "Track delivery" CTA.
class ParcelLiveTrackingScreen extends ConsumerStatefulWidget {
  const ParcelLiveTrackingScreen({
    super.key,
    this.initialStatus,
  });

  final BookingStatus? initialStatus;

  @override
  ConsumerState<ParcelLiveTrackingScreen> createState() =>
      _ParcelLiveTrackingScreenState();
}

class _ParcelLiveTrackingScreenState
    extends ConsumerState<ParcelLiveTrackingScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.initialStatus != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(parcelBookingNotifierProvider.notifier)
            .updateDeliveryStatus(widget.initialStatus!);
      });
    }
  }

  void _nextStage() {
    final state = ref.read(parcelBookingNotifierProvider);
    final status = state.activeDelivery?.status ?? BookingStatus.assigned;
    final notifier = ref.read(parcelBookingNotifierProvider.notifier);

    if (status == BookingStatus.assigned) {
      notifier.updateDeliveryStatus(BookingStatus.arrivedAtPickup,
          etaMinutes: 2);
    } else if (status == BookingStatus.arrivedAtPickup) {
      notifier.updateDeliveryStatus(BookingStatus.parcelCollected,
          etaMinutes: 18);
    } else if (status == BookingStatus.parcelCollected) {
      notifier.updateDeliveryStatus(BookingStatus.inProgress, etaMinutes: 18);
      if (GoRouter.maybeOf(context) != null) {
        context.push(AppRoutes.parcelLiveTracking);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(parcelBookingNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final delivery = state.activeDelivery;
    final status = delivery?.status ?? BookingStatus.assigned;
    final pickupLabel =
        state.pickupLocation?.label ?? 'Eko Hotel and Suites';
    final pickupAddress = state.pickupLocation?.address ??
        'Adetokunbo Ademola St, Victoria Island, Lagos';

    final riderName = delivery?.riderName ?? 'Daniel Okafor';
    final riderVehicle = delivery?.riderVehicle ?? 'Yamaha Bike - ABC-123XY';
    final riderRating = delivery?.riderRating ?? 4.9;
    final riderTrips = delivery?.riderTotalTrips ?? 320;
    final etaMinutes = delivery?.etaMinutes ?? 6;

    // Screen 14: In-Transit Live Tracking (On the way)
    if (status == BookingStatus.inProgress) {
      return Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            // Full Route Vector Map
            Positioned.fill(
              child: _LiveTrackingMapCanvas(
                isDark: isDark,
                isApproaching: false,
                isInTransit: true,
              ),
            ),

            // Top Action Header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: GVSpacing.md,
                    vertical: GVSpacing.sm,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CircularIconButton(
                        icon: Icons.arrow_back_ios_new_rounded,
                        isDark: isDark,
                        onTap: () {
                          if (GoRouter.maybeOf(context) != null) {
                            context.pop();
                          } else {
                            Navigator.of(context).maybePop();
                          }
                        },
                      ),
                      _CircularIconButton(
                        icon: Icons.help_outline_rounded,
                        isDark: isDark,
                        onTap: () {},
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Bottom In-Transit Card
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: const EdgeInsets.fromLTRB(
                  GVSpacing.lg,
                  GVSpacing.md,
                  GVSpacing.lg,
                  GVSpacing.xl,
                ),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF131A16) : Colors.white,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 16,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header & ETA Metrics
                      Text(
                        'On the way',
                        style: GVTypography.h3.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : GVColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Arriving at destination in',
                              style: GVTypography.caption.copyWith(
                                color: isDark
                                    ? GVColors.neutral400
                                    : GVColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: GVSpacing.sm),
                          Text(
                            '18 min • 8.4 km',
                            style: GVTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: GVColors.brandGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: GVSpacing.md),

                      // Horizontal 3-Step Progress Bar
                      _buildHorizontalProgress(isDark),

                      const SizedBox(height: GVSpacing.md),
                      const Divider(height: 1),
                      const SizedBox(height: GVSpacing.md),

                      // Courier Profile Row
                      Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Color(0xFFE5E7EB),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.person_rounded,
                                size: 28,
                                color: GVColors.neutral600,
                              ),
                            ),
                          ),
                          const SizedBox(width: GVSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  riderName,
                                  style: GVTypography.bodyMedium.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : GVColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '$riderVehicle • ★ $riderRating',
                                  style: GVTypography.caption.copyWith(
                                    color: isDark
                                        ? GVColors.neutral400
                                        : GVColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: GVSpacing.md),

                      // Action Buttons: Call & Help
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.call_outlined, size: 18),
                              label: const Text('Call rider'),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                side: BorderSide(
                                  color: isDark
                                      ? const Color(0xFF2E3D35)
                                      : GVColors.border,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(GVBorderRadius.md),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: GVSpacing.md),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.shield_outlined, size: 18),
                              label: const Text('Help'),
                              style: OutlinedButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                side: BorderSide(
                                  color: isDark
                                      ? const Color(0xFF2E3D35)
                                      : GVColors.border,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(GVBorderRadius.md),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: GVSpacing.sm),

                      // Quick action to advance to Delivered
                      Center(
                        child: TextButton(
                          onPressed: () {
                            ref
                                .read(parcelBookingNotifierProvider.notifier)
                                .updateDeliveryStatus(BookingStatus.delivered);
                            if (GoRouter.maybeOf(context) != null) {
                              context.push(AppRoutes.parcelDelivered);
                            } else {
                              Navigator.of(context)
                                  .pushNamed(AppRoutes.parcelDelivered);
                            }
                          },
                          child: Text(
                            'Simulate: Delivered',
                            style: GVTypography.caption.copyWith(
                              color: GVColors.brandGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Screen 13: Pickup Completed (Handover Card)
    if (status == BookingStatus.parcelCollected) {
      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF0F1512) : GVColors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? GVColors.white : GVColors.textPrimary,
              size: 20,
            ),
            onPressed: () {
              if (GoRouter.maybeOf(context) != null) {
                context.pop();
              } else {
                Navigator.of(context).maybePop();
              }
            },
          ),
          title: Text(
            'Pickup completed',
            style: GVTypography.h3.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? GVColors.white : GVColors.textPrimary,
            ),
          ),
          centerTitle: false,
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
                  child: Column(
                    children: [
                      const SizedBox(height: GVSpacing.sm),

                      // Reusable Handover Card from Design System
                      GVParcelHandoverCard(
                        pickupAddress: '$pickupLabel\n$pickupAddress',
                        pickupTime: '10:05 AM',
                        title: 'Parcel picked up!',
                        subtitle:
                            'Your parcel is on its way to the destination.',
                      ),

                      const SizedBox(height: GVSpacing.xl),
                    ],
                  ),
                ),
              ),

              // Sticky Bottom CTA: Track delivery
              Container(
                padding: const EdgeInsets.all(GVSpacing.lg),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF131A16) : GVColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      offset: const Offset(0, -4),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: GVPrimaryButton(
                  label: 'Track delivery',
                  onPressed: () {
                    ref
                        .read(parcelBookingNotifierProvider.notifier)
                        .updateDeliveryStatus(BookingStatus.inProgress,
                            etaMinutes: 18);
                    // Pushes forward to in-transit tracking (Screen 14)
                    _nextStage();
                  },
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Screen 11 & Screen 12: Live Map Tracking Views
    final isApproaching = status == BookingStatus.arrivedAtPickup || etaMinutes <= 2;
    final screenTitle =
        isApproaching ? 'Rider approaching' : 'Rider assigned';
    final screenSubtitle = isApproaching
        ? 'Your rider is almost at the pickup location.'
        : 'Your rider is on the way to pick up your parcel.';

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Live Vector Route Map
          Positioned.fill(
            child: _LiveTrackingMapCanvas(
              isDark: isDark,
              isApproaching: isApproaching,
            ),
          ),

          // 2. Motorbike Pin & Floating ETA Bubble
          Positioned(
            left: isApproaching
                ? MediaQuery.of(context).size.width * 0.46
                : MediaQuery.of(context).size.width * 0.38,
            top: isApproaching
                ? MediaQuery.of(context).size.height * 0.40
                : MediaQuery.of(context).size.height * 0.30,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Floating ETA Pill on Map
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E2822) : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Text(
                    isApproaching ? '2 min away' : '6 min away',
                    style: GVTypography.caption.copyWith(
                      fontWeight: FontWeight.bold,
                      color: GVColors.brandGreen,
                    ),
                  ),
                ),
                const SizedBox(height: 4),

                // Bike Pin
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: GVColors.brandGreen,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.two_wheeler_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ],
            ),
          ),

          // 3. Pickup Destination Pin on Map
          Positioned(
            left: MediaQuery.of(context).size.width * 0.50,
            top: MediaQuery.of(context).size.height * 0.50,
            child: const Icon(
              Icons.location_on_rounded,
              color: GVColors.brandGreen,
              size: 38,
            ),
          ),

          // 4. Top Action Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: GVSpacing.md,
                  vertical: GVSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _CircularIconButton(
                          icon: Icons.arrow_back_ios_new_rounded,
                          isDark: isDark,
                          onTap: () {
                            if (GoRouter.maybeOf(context) != null) {
                              context.pop();
                            } else {
                              Navigator.of(context).maybePop();
                            }
                          },
                        ),
                        Row(
                          children: [
                            _CircularIconButton(
                              icon: Icons.help_outline_rounded,
                              isDark: isDark,
                              onTap: () {},
                            ),
                            const SizedBox(width: GVSpacing.xs),
                            _CircularIconButton(
                              icon: Icons.security_rounded,
                              isDark: isDark,
                              onTap: () {},
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: GVSpacing.sm),

                    // Title & Subtitle Card Overlay
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: GVSpacing.md,
                        vertical: GVSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: (isDark
                                ? const Color(0xFF131A16)
                                : Colors.white)
                            .withValues(alpha: 0.94),
                        borderRadius:
                            BorderRadius.circular(GVBorderRadius.md),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            screenTitle,
                            style: GVTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color:
                                  isDark ? Colors.white : GVColors.textPrimary,
                            ),
                          ),
                          Text(
                            screenSubtitle,
                            style: GVTypography.caption.copyWith(
                              color: isDark
                                  ? GVColors.neutral400
                                  : GVColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 5. Bottom Courier Profile & Actions Card
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                GVSpacing.lg,
                GVSpacing.md,
                GVSpacing.lg,
                GVSpacing.xl,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131A16) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 16,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Courier Profile Header Row
                    Row(
                      children: [
                        // Avatar
                        Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFFE5E7EB),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.person_rounded,
                              size: 30,
                              color: GVColors.neutral600,
                            ),
                          ),
                        ),
                        const SizedBox(width: GVSpacing.md),

                        // Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                riderName,
                                style: GVTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : GVColors.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.star_rounded,
                                    size: 16,
                                    color: Color(0xFFFBBF24),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '$riderRating ($riderTrips deliveries)',
                                    style: GVTypography.caption.copyWith(
                                      color: isDark
                                          ? GVColors.neutral400
                                          : GVColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$riderVehicle • Go-Volts Partner',
                                style: GVTypography.caption.copyWith(
                                  color: isDark
                                      ? GVColors.neutral400
                                      : GVColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: GVSpacing.md),

                    // Readiness Notice Banner (Screen 11 & Screen 12)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: GVSpacing.md,
                        vertical: GVSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF16201B)
                            : const Color(0xFFF0FDF4),
                        borderRadius:
                            BorderRadius.circular(GVBorderRadius.md),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF23352A)
                              : const Color(0xFFDCFCE7),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isApproaching
                                ? Icons.timer_outlined
                                : Icons.info_outline_rounded,
                            size: 18,
                            color: GVColors.brandGreen,
                          ),
                          const SizedBox(width: GVSpacing.sm),
                          Expanded(
                            child: Text(
                              isApproaching
                                  ? 'Please be ready at the pickup location.'
                                  : 'Rider will arrive in $etaMinutes min. Please be at the pickup location.',
                              style: GVTypography.caption.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? Colors.white
                                    : GVColors.deepGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: GVSpacing.md),

                    // Action buttons row: Share & Call
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.share_outlined, size: 18),
                            label: Text(
                              isApproaching
                                  ? 'Share location'
                                  : 'Share delivery',
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(
                                color: isDark
                                    ? const Color(0xFF2E3D35)
                                    : GVColors.border,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(GVBorderRadius.md),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: GVSpacing.md),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {},
                            icon: const Icon(Icons.call_outlined, size: 18),
                            label: const Text('Call rider'),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(
                                color: isDark
                                    ? const Color(0xFF2E3D35)
                                    : GVColors.border,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(GVBorderRadius.md),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: GVSpacing.sm),

                    // Quick stage transition button for development/testing
                    TextButton(
                      onPressed: _nextStage,
                      child: Text(
                        isApproaching
                            ? 'Simulate: Pickup Completed'
                            : 'Simulate: Driver Approaching',
                        style: GVTypography.caption.copyWith(
                          color: GVColors.brandGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildHorizontalProgress(bool isDark) {
    return Row(
      children: [
        _buildProgressStep(
          label: 'Picked up',
          isDone: true,
          isActive: false,
          isDark: isDark,
        ),
        Expanded(
          child: Container(
            height: 2,
            color: GVColors.brandGreen,
          ),
        ),
        _buildProgressStep(
          label: 'On the way',
          isDone: false,
          isActive: true,
          isDark: isDark,
        ),
        Expanded(
          child: Container(
            height: 2,
            color: isDark ? const Color(0xFF2E3D35) : GVColors.border,
          ),
        ),
        _buildProgressStep(
          label: 'Arriving',
          isDone: false,
          isActive: false,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildProgressStep({
    required String label,
    required bool isDone,
    required bool isActive,
    required bool isDark,
  }) {
    Color dotColor;
    if (isDone || isActive) {
      dotColor = GVColors.brandGreen;
    } else {
      dotColor = isDark ? const Color(0xFF3F4E44) : GVColors.neutral400;
    }

    return Column(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dotColor,
            border: isActive
                ? Border.all(
                    color: dotColor.withValues(alpha: 0.3),
                    width: 4,
                  )
                : null,
          ),
          child: isDone
              ? const Center(
                  child: Icon(Icons.check, size: 8, color: Colors.white),
                )
              : null,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GVTypography.caption.copyWith(
            fontWeight:
                (isDone || isActive) ? FontWeight.bold : FontWeight.normal,
            color: (isDone || isActive)
                ? (isDark ? Colors.white : GVColors.textPrimary)
                : (isDark ? GVColors.neutral400 : GVColors.textSecondary),
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}

class _CircularIconButton extends StatelessWidget {
  const _CircularIconButton({
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E2822) : Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, size: 18),
        color: isDark ? Colors.white : GVColors.textPrimary,
        onPressed: onTap,
      ),
    );
  }
}

class _LiveTrackingMapCanvas extends StatelessWidget {
  const _LiveTrackingMapCanvas({
    required this.isDark,
    required this.isApproaching,
    this.isInTransit = false,
  });

  final bool isDark;
  final bool isApproaching;
  final bool isInTransit;

  @override
  Widget build(BuildContext context) {
    final bgColor =
        isDark ? const Color(0xFF111814) : const Color(0xFFE8ECE9);
    final streetColor =
        isDark ? const Color(0xFF1E2822) : const Color(0xFFFCFDFD);
    final waterColor =
        isDark ? const Color(0xFF0D1D22) : const Color(0xFFD0E3EA);

    return CustomPaint(
      painter: _LiveTrackingMapPainter(
        bgColor: bgColor,
        streetColor: streetColor,
        waterColor: waterColor,
        isApproaching: isApproaching,
        isInTransit: isInTransit,
      ),
    );
  }
}

class _LiveTrackingMapPainter extends CustomPainter {
  _LiveTrackingMapPainter({
    required this.bgColor,
    required this.streetColor,
    required this.waterColor,
    required this.isApproaching,
    this.isInTransit = false,
  });

  final Color bgColor;
  final Color streetColor;
  final Color waterColor;
  final bool isApproaching;
  final bool isInTransit;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = bgColor,
    );

    // Lagoon line
    final waterPaint = Paint()..color = waterColor;
    final waterPath = Path()
      ..moveTo(0, size.height * 0.14)
      ..quadraticBezierTo(
        size.width * 0.5,
        size.height * 0.22,
        size.width,
        size.height * 0.10,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(waterPath, waterPaint);

    final streetPaint = Paint()
      ..color = streetColor
      ..strokeWidth = 14
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(0, size.height * 0.45),
      Offset(size.width, size.height * 0.42),
      streetPaint,
    );
    canvas.drawLine(
      Offset(size.width * 0.35, size.height * 0.15),
      Offset(size.width * 0.35, size.height),
      streetPaint,
    );

    // Green dynamic navigation polyline
    final routePaint = Paint()
      ..color = GVColors.brandGreen
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final startPoint = isApproaching
        ? Offset(size.width * 0.46, size.height * 0.44)
        : Offset(size.width * 0.38, size.height * 0.34);
    final endPoint = Offset(size.width * 0.50, size.height * 0.52);

    final routePath = Path()
      ..moveTo(startPoint.dx, startPoint.dy)
      ..quadraticBezierTo(
        size.width * 0.44,
        size.height * 0.46,
        endPoint.dx,
        endPoint.dy,
      );

    canvas.drawPath(routePath, routePaint);
  }

  @override
  bool shouldRepaint(covariant _LiveTrackingMapPainter oldDelegate) =>
      oldDelegate.isApproaching != isApproaching;
}
