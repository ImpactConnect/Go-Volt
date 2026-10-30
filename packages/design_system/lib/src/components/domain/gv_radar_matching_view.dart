import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../foundation/gv_border_radius.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_spacing.dart';
import '../../foundation/gv_typography.dart';
import '../buttons/gv_outlined_button.dart';

/// Radar matching view for Screen 11 ("Finding a rider for you...").
///
/// Features:
/// - Smooth concentric radar pulse animation with central EV icon and nearby driver pins.
/// - 4-step dynamic status checklist.
/// - Lightbulb notification banner.
/// - Outlined "Cancel ride" action.
class GVRadarMatchingView extends StatefulWidget {
  const GVRadarMatchingView({
    super.key,
    this.currentStep = 1,
    this.title = 'Finding a rider for you...',
    this.subtitle = 'This usually takes less than 1 minute.',
    this.noticeText =
        "You'll be notified as soon as a rider accepts your request.",
    this.onCancel,
    this.cancelButtonText = 'Cancel ride',
    this.steps = const [
      'Sending your request',
      'Looking for nearby riders',
      'Confirming rider',
      'Finalizing your ride',
    ],
  });

  /// Current step index (0-indexed). 0..3 are the 4 steps.
  final int currentStep;
  final String title;
  final String subtitle;
  final String noticeText;
  final VoidCallback? onCancel;
  final String cancelButtonText;
  final List<String> steps;

  @override
  State<GVRadarMatchingView> createState() => _GVRadarMatchingViewState();
}

class _GVRadarMatchingViewState extends State<GVRadarMatchingView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _radarController;

  @override
  void initState() {
    super.initState();
    _radarController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat();
  }

  @override
  void dispose() {
    _radarController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      children: [
        // Radar Ripple Map Animation Area
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Concentric Pulsing Ripples
              AnimatedBuilder(
                animation: _radarController,
                builder: (context, child) {
                  return CustomPaint(
                    size: const Size(double.infinity, double.infinity),
                    painter: _RadarWavePainter(
                      progress: _radarController.value,
                      isDark: isDark,
                    ),
                  );
                },
              ),

              // Scattered mock nearby vehicle markers on radar
              Positioned(
                top: 80,
                left: 60,
                child: _NearbyDriverIcon(isDark: isDark),
              ),
              Positioned(
                bottom: 120,
                left: 50,
                child: _NearbyDriverIcon(isDark: isDark),
              ),
              Positioned(
                top: 100,
                right: 70,
                child: _NearbyDriverIcon(isDark: isDark),
              ),
              Positioned(
                bottom: 90,
                right: 60,
                child: _NearbyDriverIcon(isDark: isDark),
              ),

              // Center EV Pulsing Core
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: GVColors.brandGreen,
                  boxShadow: [
                    BoxShadow(
                      color: GVColors.brandGreen.withValues(alpha: 0.45),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.electric_car_rounded,
                  color: GVColors.white,
                  size: 36,
                ),
              ),
            ],
          ),
        ),

        // Bottom Dispatch Status Card
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131A16) : GVColors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(
            GVSpacing.lg,
            GVSpacing.lg,
            GVSpacing.lg,
            GVSpacing.xl,
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  widget.title,
                  style: GVTypography.titleLarge.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark ? GVColors.white : GVColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.subtitle,
                  style: GVTypography.bodyMedium.copyWith(
                    color: isDark ? GVColors.neutral400 : GVColors.textSecondary,
                  ),
                ),
                const SizedBox(height: GVSpacing.lg),

                // 4-Step Progress Checklist
                ...List.generate(widget.steps.length, (index) {
                  final isDone = index < widget.currentStep;
                  final isActive = index == widget.currentStep;
                  final label = widget.steps[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isDone
                                ? GVColors.brandGreen
                                : (isActive
                                    ? GVColors.brandGreen.withValues(alpha: 0.15)
                                    : Colors.transparent),
                            border: Border.all(
                              color: (isDone || isActive)
                                  ? GVColors.brandGreen
                                  : (isDark
                                      ? GVColors.neutral600
                                      : GVColors.neutral300),
                              width: 2,
                            ),
                          ),
                          child: isDone
                              ? const Icon(
                                  Icons.check,
                                  size: 13,
                                  color: GVColors.white,
                                )
                              : (isActive
                                  ? Center(
                                      child: Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: GVColors.brandGreen,
                                        ),
                                      ),
                                    )
                                  : null),
                        ),
                        const SizedBox(width: GVSpacing.md),
                        Expanded(
                          child: Text(
                            label,
                            style: GVTypography.bodyMedium.copyWith(
                              fontWeight: (isDone || isActive)
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              color: (isDone || isActive)
                                  ? (isDark
                                      ? GVColors.white
                                      : GVColors.textPrimary)
                                  : (isDark
                                      ? GVColors.neutral500
                                      : GVColors.neutral400),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),

                const SizedBox(height: GVSpacing.sm),

                // Lightbulb Notification Banner
                Container(
                  padding: const EdgeInsets.all(GVSpacing.md),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E2619)
                        : const Color(0xFFFEF9C3),
                    borderRadius: GVBorderRadius.cardRadius,
                    border: Border.all(
                      color: isDark
                          ? const Color(0xFF3B4628)
                          : const Color(0xFFFEF08A),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.lightbulb_outline_rounded,
                        color: GVColors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: GVSpacing.sm),
                      Expanded(
                        child: Text(
                          widget.noticeText,
                          style: GVTypography.bodySmall.copyWith(
                            color: isDark
                                ? const Color(0xFFFDE68A)
                                : const Color(0xFF854D0E),
                            fontWeight: FontWeight.w500,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: GVSpacing.lg),

                // Outlined Cancel Action
                GVOutlinedButton(
                  label: widget.cancelButtonText,
                  onPressed: widget.onCancel,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NearbyDriverIcon extends StatelessWidget {
  const _NearbyDriverIcon({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF243029) : GVColors.white,
        shape: BoxShape.circle,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: GVColors.brandGreen.withValues(alpha: 0.6),
          width: 1.5,
        ),
      ),
      child: const Icon(
        Icons.directions_car,
        size: 14,
        color: GVColors.brandGreen,
      ),
    );
  }
}

class _RadarWavePainter extends CustomPainter {
  _RadarWavePainter({required this.progress, required this.isDark});

  final double progress;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final maxRadius = math.min(size.width, size.height) * 0.48;

    // Draw 3 expanding concentric rings
    for (int i = 0; i < 3; i++) {
      final ringProgress = (progress + (i / 3.0)) % 1.0;
      final radius = ringProgress * maxRadius;
      final opacity = (1.0 - ringProgress).clamp(0.0, 1.0) * 0.45;

      final fillPaint = Paint()
        ..color = GVColors.brandGreen.withValues(alpha: opacity * 0.25)
        ..style = PaintingStyle.fill;

      final strokePaint = Paint()
        ..color = GVColors.brandGreen.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawCircle(center, radius, fillPaint);
      canvas.drawCircle(center, radius, strokePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _RadarWavePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

