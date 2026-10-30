import 'dart:async';
import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../application/parcel_booking_notifier.dart';

/// Screen 10 — Finding a Rider:
/// Pulsing radar scanning animation with motorbike courier icon,
/// 4-step live progress checklist, and "Cancel delivery" action.
class ParcelFindingRiderScreen extends ConsumerStatefulWidget {
  const ParcelFindingRiderScreen({
    super.key,
    this.autoTransition = true,
    this.animateRadar = true,
  });

  final bool autoTransition;
  final bool animateRadar;

  @override
  ConsumerState<ParcelFindingRiderScreen> createState() =>
      _ParcelFindingRiderScreenState();
}

class _ParcelFindingRiderScreenState
    extends ConsumerState<ParcelFindingRiderScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _radarController;
  Timer? _matchingTimer;

  int _currentStep = 2; // Step 1 & 2 completed, 3 in progress

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    if (widget.animateRadar) {
      _radarController.repeat();
    }

    if (widget.autoTransition) {
      _matchingTimer = Timer(const Duration(milliseconds: 1200), () {
        if (!mounted) return;
        setState(() => _currentStep = 4);
        ref
            .read(parcelBookingNotifierProvider.notifier)
            .updateDeliveryStatus(BookingStatus.assigned, etaMinutes: 6);

        if (GoRouter.maybeOf(context) != null) {
          context.pushReplacement(AppRoutes.parcelLiveTracking);
        } else {
          Navigator.of(context)
              .pushReplacementNamed(AppRoutes.parcelLiveTracking);
        }
      });
    }
  }

  @override
  void dispose() {
    _radarController.dispose();
    _matchingTimer?.cancel();
    super.dispose();
  }

  void _onCancel() {
    _matchingTimer?.cancel();
    ref.read(parcelBookingNotifierProvider.notifier).cancelDelivery();
    if (GoRouter.maybeOf(context) != null) {
      context.go(AppRoutes.home);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
                child: Column(
                  children: [
                    const SizedBox(height: GVSpacing.md),

                    // 1. Radar Scanning Animation
                    Center(
                      child: SizedBox(
                        width: 220,
                        height: 220,
                        child: AnimatedBuilder(
                          animation: _radarController,
                          builder: (context, child) {
                            return Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer ripple
                                Container(
                                  width: 200 + (_radarController.value * 20),
                                  height: 200 + (_radarController.value * 20),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: GVColors.brandGreen.withValues(
                                      alpha: (1 - _radarController.value) * 0.15,
                                    ),
                                  ),
                                ),
                                // Mid ripple
                                Container(
                                  width: 150 + (_radarController.value * 15),
                                  height: 150 + (_radarController.value * 15),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: GVColors.brandGreen.withValues(
                                      alpha: (1 - _radarController.value) * 0.25,
                                    ),
                                  ),
                                ),
                                // Center Bike Icon Container
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: GVColors.brandGreen,
                                    boxShadow: [
                                      BoxShadow(
                                        color: GVColors.brandGreen
                                            .withValues(alpha: 0.35),
                                        blurRadius: 16,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.two_wheeler_rounded,
                                    color: Colors.white,
                                    size: 44,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: GVSpacing.lg),

                    // Title & Subtitle
                    Text(
                      'Finding a rider for your delivery...',
                      style: GVTypography.h3.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : GVColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: GVSpacing.xs),
                    Text(
                      'This usually takes less than 1 minute.',
                      style: GVTypography.bodySmall.copyWith(
                        color: isDark
                            ? GVColors.neutral400
                            : GVColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: GVSpacing.xl),

                    // 2. Live Matching Progress Checklist
                    _buildStepRow(
                      context,
                      isCompleted: _currentStep >= 1,
                      label: 'Sending your request',
                    ),
                    const SizedBox(height: GVSpacing.md),
                    _buildStepRow(
                      context,
                      isCompleted: _currentStep >= 2,
                      label: 'Looking for nearby riders',
                    ),
                    const SizedBox(height: GVSpacing.md),
                    _buildStepRow(
                      context,
                      isCompleted: _currentStep >= 3,
                      label: 'Confirming rider',
                    ),
                    const SizedBox(height: GVSpacing.md),
                    _buildStepRow(
                      context,
                      isCompleted: _currentStep >= 4,
                      label: 'Preparing for pickup',
                    ),
                  ],
                ),
              ),
            ),

            // Bottom CTA: Cancel delivery
            Padding(
              padding: const EdgeInsets.all(GVSpacing.lg),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  onPressed: _onCancel,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: isDark
                          ? const Color(0xFF2E3D35)
                          : GVColors.border,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(GVBorderRadius.md),
                    ),
                  ),
                  child: Text(
                    'Cancel delivery',
                    style: GVTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                      color: GVColors.error,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepRow(
    BuildContext context, {
    required bool isCompleted,
    required String label,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? GVColors.brandGreen
                : (isDark ? const Color(0xFF26322A) : const Color(0xFFE5E7EB)),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(
                    Icons.check_rounded,
                    color: Colors.white,
                    size: 16,
                  )
                : Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? const Color(0xFF3F4E44)
                          : const Color(0xFF9CA3AF),
                    ),
                  ),
          ),
        ),
        const SizedBox(width: GVSpacing.md),
        Expanded(
          child: Text(
            label,
            style: GVTypography.bodyMedium.copyWith(
              fontWeight: isCompleted ? FontWeight.bold : FontWeight.normal,
              color: isCompleted
                  ? (isDark ? Colors.white : GVColors.textPrimary)
                  : (isDark ? GVColors.neutral400 : GVColors.textSecondary),
            ),
          ),
        ),
      ],
    );
  }
}
