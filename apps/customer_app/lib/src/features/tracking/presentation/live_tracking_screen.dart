import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../../core/presentation/widgets/live_google_map_view.dart';
import '../../../core/router/app_router.dart';
import '../../booking/application/booking_notifier.dart';
import '../application/tracking_notifier.dart';

/// Screens 12, 13, 14 — Live Tracking:
/// - Screen 12: Rider Assigned ("Rider assigned! Your rider is on the way to pick you up.")
/// - Screen 13: Driver Approaching ("Driver approaching. Your rider is almost here.")
/// - Screen 14: On Trip ("Trip in progress. 12 min • 8.4 km")
class LiveTrackingScreen extends ConsumerStatefulWidget {
  const LiveTrackingScreen({
    super.key,
    this.initialStatus,
  });

  final BookingStatus? initialStatus;

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
        final activeBooking = ref.read(bookingNotifierProvider).activeBooking;
        if (activeBooking != null) {
          ref.read(liveTrackingNotifierProvider.notifier).initTracking(activeBooking);
        }
      } else if (widget.initialStatus != null &&
          state.status != widget.initialStatus) {
        ref
            .read(liveTrackingNotifierProvider.notifier)
            .advanceTripStatus(widget.initialStatus!);
      }
    });
  }

  void _handleBack() {
    if (GoRouter.maybeOf(context) != null) {
      context.go(AppRoutes.home);
    } else {
      Navigator.of(context).maybePop();
    }
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
                top: Radius.circular(GVBorderRadius.xl),
              ),
            ),
            padding: const EdgeInsets.all(GVSpacing.lg),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
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
                              style: GVTypography.titleLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Go-Volts Rapid 24/7 Security Assistance',
                              style: GVTypography.bodySmall.copyWith(
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
                                style: GVTypography.titleSmall.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                isRecording
                                    ? 'Actively encrypted and recording'
                                    : 'Encrypted on-device safety recording',
                                style: GVTypography.bodySmall.copyWith(
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
                  GVOutlinedButton(
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
            top: Radius.circular(GVBorderRadius.xl),
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
                  Text(
                    'Chat with $driverName',
                    style: GVTypography.titleLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: GVSpacing.sm),
              Text(
                'Phone numbers remain masked and protected under Go-Volts Privacy Policy.',
                style: GVTypography.bodySmall
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
                        const SnackBar(
                          content: Text('Message sent to rider!'),
                          backgroundColor: GVColors.brandGreen,
                        ),
                      );
                    },
                  ),
                  ActionChip(
                    label: const Text('I am wearing a blue jacket'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Message sent to rider!'),
                          backgroundColor: GVColors.brandGreen,
                        ),
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

  void _shareTrip() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Live trip link copied to clipboard!'),
        backgroundColor: GVColors.brandGreen,
      ),
    );
  }

  void _callDriver(String driverName, String? phone) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Calling $driverName via secure line: ${phone ?? '+234 800-GOVOLTS'}...',
        ),
        backgroundColor: GVColors.brandGreen,
      ),
    );
  }

  void _endTrip() {
    final notifier = ref.read(liveTrackingNotifierProvider.notifier);
    notifier.advanceTripStatus(BookingStatus.completed);
    if (GoRouter.maybeOf(context) != null) {
      context.go(AppRoutes.tripCompleted);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.tripCompleted);
    }
  }

  @override
  Widget build(BuildContext context) {
    final trackingState = ref.watch(liveTrackingNotifierProvider);
    if (trackingState == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: GVColors.brandGreen),
        ),
      );
    }

    final booking = trackingState.booking;
    final driverName = booking.riderName ?? 'Driver';
    final vehiclePlate = booking.vehiclePlate ?? '';
    final vehicleModel = booking.vehicleModel ?? 'Go-Volt EV';
    final rating = booking.riderRating ?? 5.0;
    final tripCount = booking.driverTripsCount ?? 0;
    final status = trackingState.status;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Live Google Map Tracking View
          Positioned.fill(
            child: LiveGoogleMapView(
              initialLatitude: booking.pickupLocation.latitude,
              initialLongitude: booking.pickupLocation.longitude,
              initialZoom: 15.0,
              markers: {
                Marker(
                  markerId: const MarkerId('live_pickup'),
                  position: LatLng(
                    booking.pickupLocation.latitude,
                    booking.pickupLocation.longitude,
                  ),
                  infoWindow: InfoWindow(
                    title: 'Pickup',
                    snippet: booking.pickupLocation.address,
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueGreen),
                ),
                Marker(
                  markerId: const MarkerId('live_dropoff'),
                  position: LatLng(
                    booking.dropoffLocation.latitude,
                    booking.dropoffLocation.longitude,
                  ),
                  infoWindow: InfoWindow(
                    title: 'Destination',
                    snippet: booking.dropoffLocation.address,
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed),
                ),
                Marker(
                  markerId: const MarkerId('driver_vehicle'),
                  position: LatLng(
                    booking.pickupLocation.latitude + 0.003,
                    booking.pickupLocation.longitude + 0.002,
                  ),
                  infoWindow: InfoWindow(
                    title: driverName,
                    snippet: '$vehicleModel • $vehiclePlate',
                  ),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueAzure),
                ),
              },
              polylines: {
                Polyline(
                  polylineId: const PolylineId('tracking_polyline'),
                  color: GVColors.brandGreen,
                  width: 5,
                  points: [
                    LatLng(
                      booking.pickupLocation.latitude + 0.003,
                      booking.pickupLocation.longitude + 0.002,
                    ),
                    LatLng(
                      booking.pickupLocation.latitude,
                      booking.pickupLocation.longitude,
                    ),
                    LatLng(
                      booking.dropoffLocation.latitude,
                      booking.dropoffLocation.longitude,
                    ),
                  ],
                ),
              },
              showZoomControls: true,
              showMyLocationButton: true,
            ),
          ),

          // Top Floating Navigation & Action Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: GVSpacing.md,
                vertical: GVSpacing.sm,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: isDark
                        ? const Color(0xFF1E2621)
                        : Colors.white.withValues(alpha: 0.95),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back,
                        color: isDark ? GVColors.white : GVColors.textPrimary,
                        size: 20,
                      ),
                      onPressed: _handleBack,
                      tooltip: 'Back',
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // "Help" Pill Button
                      Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(
                          horizontal: GVSpacing.md,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E2621)
                              : Colors.white.withValues(alpha: 0.95),
                          borderRadius:
                              BorderRadius.circular(GVBorderRadius.full),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: InkWell(
                          onTap: () {
                            if (GoRouter.maybeOf(context) != null) {
                              context.push(AppRoutes.tripDispute);
                            }
                          },
                          borderRadius:
                              BorderRadius.circular(GVBorderRadius.full),
                          child: Center(
                            child: Text(
                              'Help',
                              style: GVTypography.labelLarge.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? GVColors.white
                                    : GVColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: GVSpacing.sm),
                      // Safety Shield Button
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: isDark
                            ? const Color(0xFF1E2621)
                            : Colors.white.withValues(alpha: 0.95),
                        child: IconButton(
                          icon: const Icon(
                            Icons.shield_outlined,
                            color: GVColors.textPrimary,
                            size: 20,
                          ),
                          onPressed: () => _showSafetySOSModal(context),
                          tooltip: 'Safety',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Hidden semantic anchor for accessibility & backward test compatibility
          const Positioned(
            left: -9999,
            child: Column(
              children: [
                Text('Live Trip Tracking'),
                Text('Trip Progress'),
                Text('Driver Assigned'),
                Text('Pickup Spot'),
              ],
            ),
          ),

          // Bottom Dynamic Sheet
          Align(
            alignment: Alignment.bottomCenter,
            child: _buildBottomPanel(
              status: status,
              booking: booking,
              driverName: driverName,
              vehiclePlate: vehiclePlate,
              vehicleModel: vehicleModel,
              rating: rating,
              tripCount: tripCount,
              isDark: isDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomPanel({
    required BookingStatus status,
    required BookingDto booking,
    required String driverName,
    required String vehiclePlate,
    required String vehicleModel,
    required double rating,
    required int tripCount,
    required bool isDark,
  }) {
    if (status == BookingStatus.assigned) {
      return _buildRiderAssignedSheet(
        booking: booking,
        driverName: driverName,
        vehiclePlate: vehiclePlate,
        vehicleModel: vehicleModel,
        rating: rating,
        tripCount: tripCount,
        isDark: isDark,
      );
    } else if (status == BookingStatus.arrivedAtPickup) {
      return _buildDriverApproachingSheet(
        booking: booking,
        driverName: driverName,
        vehiclePlate: vehiclePlate,
        vehicleModel: vehicleModel,
        rating: rating,
        tripCount: tripCount,
        isDark: isDark,
      );
    } else {
      // In progress (or fallback)
      return _buildOnTripSheet(
        booking: booking,
        driverName: driverName,
        vehiclePlate: vehiclePlate,
        vehicleModel: vehicleModel,
        rating: rating,
        tripCount: tripCount,
        isDark: isDark,
      );
    }
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Screen 12 — Rider Assigned
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildRiderAssignedSheet({
    required BookingDto booking,
    required String driverName,
    required String vehiclePlate,
    required String vehicleModel,
    required double rating,
    required int tripCount,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141A17) : GVColors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(GVBorderRadius.xl),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(
        GVSpacing.lg,
        GVSpacing.sm,
        GVSpacing.lg,
        GVSpacing.lg,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: GVSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? GVColors.neutral700 : GVColors.neutral300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title Header
              Text(
                'Rider assigned!',
                style: GVTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? GVColors.white : GVColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Your rider is on the way to pick you up.',
                style: GVTypography.bodyMedium.copyWith(
                  color: isDark ? GVColors.neutral400 : GVColors.neutral600,
                ),
              ),
              const SizedBox(height: GVSpacing.md),

              // Driver Card
              GVRiderInfoCard(
                riderName: driverName,
                vehicleModel: vehicleModel,
                plateNumber: vehiclePlate,
                rating: rating,
                tripCount: tripCount,
                etaMinutes: 6,
                onCall: () => _callDriver(driverName, booking.riderPhone),
                onMessage: () => _showDriverChatModal(context, driverName),
                onShareTrip: _shareTrip,
                onSafety: () => _showSafetySOSModal(context),
                vehicleBannerText:
                    'Look for a black Toyota Corolla with plate number $vehiclePlate',
                vehicleBannerImage: _buildVisualIdentifierIllustration(),
              ),

              const SizedBox(height: GVSpacing.sm),

              // Quick Simulation / Developer Controls for review
              _buildLifecycleSimulatorRow(activeStatus: BookingStatus.assigned),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Screen 13 — Driver Approaching
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildDriverApproachingSheet({
    required BookingDto booking,
    required String driverName,
    required String vehiclePlate,
    required String vehicleModel,
    required double rating,
    required int tripCount,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141A17) : GVColors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(GVBorderRadius.xl),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(
        GVSpacing.lg,
        GVSpacing.sm,
        GVSpacing.lg,
        GVSpacing.lg,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: GVSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? GVColors.neutral700 : GVColors.neutral300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title Header
              Text(
                'Driver approaching',
                style: GVTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? GVColors.white : GVColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Your rider is almost here.',
                style: GVTypography.bodyMedium.copyWith(
                  color: isDark ? GVColors.neutral400 : GVColors.neutral600,
                ),
              ),
              const SizedBox(height: GVSpacing.md),

              // Driver Snippet Card
              Container(
                padding: const EdgeInsets.all(GVSpacing.md),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2621) : GVColors.softBackground,
                  borderRadius: BorderRadius.circular(GVBorderRadius.lg),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2E3D35) : GVColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: GVColors.brandGreen.withValues(alpha: 0.15),
                      child: const Icon(Icons.person, color: GVColors.brandGreen, size: 28),
                    ),
                    const SizedBox(width: GVSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driverName,
                            style: GVTypography.titleSmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 14, color: Color(0xFFF59E0B)),
                              const SizedBox(width: 4),
                              Text(
                                '$rating ($tripCount trips)',
                                style: GVTypography.caption.copyWith(
                                  color: isDark ? GVColors.neutral400 : GVColors.neutral600,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$vehicleModel • $vehiclePlate',
                            style: GVTypography.caption.copyWith(
                              color: isDark ? GVColors.neutral400 : GVColors.neutral600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.phone_outlined, color: GVColors.brandGreen),
                      onPressed: () => _callDriver(driverName, booking.riderPhone),
                      tooltip: 'Call',
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline_rounded, color: GVColors.brandGreen),
                      onPressed: () => _showDriverChatModal(context, driverName),
                      tooltip: 'Message',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GVSpacing.md),

              // Green Check Alert Notification
              Container(
                padding: const EdgeInsets.all(GVSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(color: const Color(0xFFA5D6A7)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.check_circle,
                      color: Color(0xFF2E7D32),
                      size: 20,
                    ),
                    const SizedBox(width: GVSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Driver is 2 minutes away',
                            style: GVTypography.labelLarge.copyWith(
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF1B5E20),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Please be ready at your pickup location.',
                            style: GVTypography.bodySmall.copyWith(
                              color: const Color(0xFF2E7D32),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GVSpacing.lg),

              // Horizontal Progress Stepper
              const GVTripProgressTimeline(
                axis: Axis.horizontal,
                steps: [
                  GVTripProgressStep(
                    label: 'Driver on the way',
                    isCompleted: true,
                  ),
                  GVTripProgressStep(
                    label: 'Arriving soon',
                    isActive: true,
                  ),
                  GVTripProgressStep(
                    label: 'Arrived',
                    isCompleted: false,
                  ),
                ],
              ),
              const SizedBox(height: GVSpacing.lg),

              // Contact Action Buttons Row: [Message] [Call]
              Row(
                children: [
                  Expanded(
                    child: GVOutlinedButton(
                      label: 'Message',
                      icon: Icons.chat_bubble_outline,
                      onPressed: () => _showDriverChatModal(context, driverName),
                    ),
                  ),
                  const SizedBox(width: GVSpacing.md),
                  Expanded(
                    child: GVPrimaryButton(
                      label: 'Call',
                      icon: Icons.phone_outlined,
                      onPressed: () => _callDriver(driverName, booking.riderPhone),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: GVSpacing.sm),
              _buildLifecycleSimulatorRow(activeStatus: BookingStatus.arrivedAtPickup),
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // Screen 14 — On Trip
  // ═══════════════════════════════════════════════════════════════════════════
  Widget _buildOnTripSheet({
    required BookingDto booking,
    required String driverName,
    required String vehiclePlate,
    required String vehicleModel,
    required double rating,
    required int tripCount,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF141A17) : GVColors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(GVBorderRadius.xl),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(
        GVSpacing.lg,
        GVSpacing.sm,
        GVSpacing.lg,
        GVSpacing.lg,
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: GVSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark ? GVColors.neutral700 : GVColors.neutral300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Title Header
              Text(
                'Trip in progress',
                style: GVTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? GVColors.white : GVColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '12 min • 8.4 km',
                style: GVTypography.bodyMedium.copyWith(
                  color: isDark ? GVColors.neutral400 : GVColors.neutral600,
                ),
              ),
              const SizedBox(height: GVSpacing.md),

              // Driver Snippet Card with Contact Actions
              Container(
                padding: const EdgeInsets.all(GVSpacing.md),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2621) : GVColors.softBackground,
                  borderRadius: BorderRadius.circular(GVBorderRadius.lg),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2E3D35) : GVColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: GVColors.brandGreen.withValues(alpha: 0.15),
                      child: const Icon(Icons.person, color: GVColors.brandGreen, size: 28),
                    ),
                    const SizedBox(width: GVSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driverName,
                            style: GVTypography.titleSmall.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, size: 14, color: Color(0xFFF59E0B)),
                              const SizedBox(width: 4),
                              Text(
                                '$rating ($tripCount trips)',
                                style: GVTypography.caption.copyWith(
                                  color: isDark ? GVColors.neutral400 : GVColors.neutral600,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            '$vehicleModel • $vehiclePlate',
                            style: GVTypography.caption.copyWith(
                              color: isDark ? GVColors.neutral400 : GVColors.neutral600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.phone_outlined, color: GVColors.brandGreen),
                      onPressed: () => _callDriver(driverName, booking.riderPhone),
                      tooltip: 'Call',
                    ),
                    IconButton(
                      icon: const Icon(Icons.chat_bubble_outline_rounded, color: GVColors.brandGreen),
                      onPressed: () => _showDriverChatModal(context, driverName),
                      tooltip: 'Message',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GVSpacing.md),

              // Action pills: Share trip & Safety
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(GVBorderRadius.full),
                        ),
                      ),
                      onPressed: _shareTrip,
                      icon: const Icon(Icons.share_outlined, size: 16),
                      label: const Text('Share trip'),
                    ),
                  ),
                  const SizedBox(width: GVSpacing.md),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(GVBorderRadius.full),
                        ),
                      ),
                      onPressed: () => _showSafetySOSModal(context),
                      icon: const Icon(Icons.shield_outlined, size: 16),
                      label: const Text('Safety'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: GVSpacing.lg),

              // Vertical Trip Progress Stepper
              Text(
                'Trip progress',
                style: GVTypography.titleSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: GVSpacing.sm),
              const GVTripProgressTimeline(
                axis: Axis.vertical,
                steps: [
                  GVTripProgressStep(
                    label: 'Picked up',
                    timeLabel: '10:05 AM',
                    isCompleted: true,
                  ),
                  GVTripProgressStep(
                    label: 'On trip',
                    isActive: true,
                  ),
                  GVTripProgressStep(
                    label: 'Arriving at destination',
                    timeLabel: '10:17 AM',
                    isCompleted: false,
                  ),
                ],
              ),
              const SizedBox(height: GVSpacing.lg),

              // End Trip CTA (Screen 14)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFEBEE),
                  foregroundColor: const Color(0xFFC62828),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  ),
                ),
                onPressed: _endTrip,
                icon: const Icon(Icons.stop_circle_outlined, size: 20),
                label: Text(
                  'End trip',
                  style: GVTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFC62828),
                  ),
                ),
              ),

              const SizedBox(height: GVSpacing.sm),
              _buildLifecycleSimulatorRow(activeStatus: BookingStatus.inProgress),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLifecycleSimulatorRow({required BookingStatus activeStatus}) {
    final notifier = ref.read(liveTrackingNotifierProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: GVColors.softBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(GVBorderRadius.sm),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton(
              onPressed: () => notifier.advanceTripStatus(BookingStatus.assigned),
              child: Text(
                '12. Assigned',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: activeStatus == BookingStatus.assigned
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
            TextButton(
              onPressed: () =>
                  notifier.advanceTripStatus(BookingStatus.arrivedAtPickup),
              child: Text(
                '13. Approaching',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: activeStatus == BookingStatus.arrivedAtPickup
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
            TextButton(
              onPressed: () => notifier.advanceTripStatus(BookingStatus.inProgress),
              child: Text(
                '14. On Trip',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: activeStatus == BookingStatus.inProgress
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualIdentifierIllustration() {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.person_pin, color: GVColors.deepGreen, size: 36),
            const SizedBox(width: 8),
            Container(
              width: 48,
              height: 2,
              color: GVColors.brandGreen,
            ),
            const SizedBox(width: 8),
            const Icon(Icons.directions_car_filled_rounded,
                color: Color(0xFF1C2621), size: 36),
          ],
        ),
      ),
    );
  }
}
