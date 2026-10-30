import 'dart:async';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../application/booking_notifier.dart';

/// R06 — Finding Driver & Dispatch Radar Screen
class FindingDriverScreen extends ConsumerStatefulWidget {
  const FindingDriverScreen({super.key});

  @override
  ConsumerState<FindingDriverScreen> createState() => _FindingDriverScreenState();
}

class _FindingDriverScreenState extends ConsumerState<FindingDriverScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  Timer? _simulatedMatchTimer;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Simulate driver match after 4.5 seconds for interactive prototype flow
    _simulatedMatchTimer = Timer(const Duration(milliseconds: 4500), () {
      if (mounted) {
        _showDriverMatchedDialog();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _simulatedMatchTimer?.cancel();
    super.dispose();
  }

  void _showDriverMatchedDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GVBorderRadius.md),
        ),
        title: Row(
          children: [
            const Icon(Icons.check_circle_rounded,
                color: GVColors.brandGreen, size: 28),
            const SizedBox(width: GVSpacing.sm),
            Text('Driver Assigned! ⚡', style: GVTypography.h3),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Driver Emeka Adeleke is en route in a clean BYD Atto 3 (LAG-729-EV).',
              style: GVTypography.body,
            ),
            const SizedBox(height: GVSpacing.sm),
            Text(
              'ETA: 4 minutes • 4.9 ★ Rating',
              style: GVTypography.bodySmallMedium.copyWith(
                color: GVColors.brandGreen,
              ),
            ),
          ],
        ),
        actions: [
          GVPrimaryButton(
            label: 'Track Driver Live',
            onPressed: () {
              Navigator.of(ctx).pop();
              context.go(AppRoutes.liveTracking);
            },
          ),
        ],
      ),
    );
  }

  Future<void> _cancelSearch() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Request?'),
        content: const Text(
          'Are you sure you want to cancel? No cancellation fees apply while searching for an electric driver.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep Searching'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: GVColors.error),
            child: const Text('Cancel Request'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      _simulatedMatchTimer?.cancel();
      ref.read(bookingNotifierProvider.notifier).resetFlow();
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingNotifierProvider);
    final booking = bookingState.activeBooking;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Connecting to Driver',
          style: GVTypography.h3.copyWith(fontWeight: FontWeight.bold),
        ),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(GVSpacing.xl),
          child: Column(
            children: [
              const Spacer(),

              // Animated Radar / Electric Orb
              Center(
                child: ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: GVColors.brandGreen.withValues(alpha: 0.12),
                      border: Border.all(
                        color: GVColors.brandGreen.withValues(alpha: 0.4),
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: GVColors.brandGreen,
                        ),
                        child: const Icon(
                          Icons.electric_bolt_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: GVSpacing.xxl),

              Text(
                'Searching Near You',
                style: GVTypography.h2.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: GVSpacing.xs),
              Text(
                'Matching you with vetted 100% electric drivers within your Lagos corridor.',
                textAlign: TextAlign.center,
                style: GVTypography.body.copyWith(
                  color: GVColors.textSecondary,
                ),
              ),
              const SizedBox(height: GVSpacing.xl),

              // Booking Details Badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: GVSpacing.md,
                  vertical: GVSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: GVColors.softBackground,
                  borderRadius: BorderRadius.circular(GVBorderRadius.full),
                  border: Border.all(color: GVColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.confirmation_number_outlined,
                        size: 16, color: GVColors.brandGreen),
                    const SizedBox(width: 6),
                    Text(
                      booking?.bookingReference ?? 'GV-2026-0042',
                      style: GVTypography.label.copyWith(
                        fontWeight: FontWeight.bold,
                        color: GVColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),

              // Eco Offset Alert
              Container(
                padding: const EdgeInsets.all(GVSpacing.md),
                decoration: BoxDecoration(
                  color: GVColors.limeHighlight.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(
                    color: GVColors.limeHighlight.withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.energy_savings_leaf_rounded,
                        color: GVColors.deepGreen, size: 24),
                    const SizedBox(width: GVSpacing.sm),
                    Expanded(
                      child: Text(
                        'This trip will eliminate ~1.2 kg of CO₂ exhaust from Lagos air!',
                        style: GVTypography.caption.copyWith(
                          color: GVColors.deepGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GVSpacing.lg),

              // Cancel button
              GVOutlinedButton(
                label: 'Cancel Request',
                onPressed: _cancelSearch,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
