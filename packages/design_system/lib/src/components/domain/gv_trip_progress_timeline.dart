import 'package:flutter/material.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_spacing.dart';
import '../../foundation/gv_typography.dart';

/// Single step model for [GVTripProgressTimeline].
class GVTripProgressStep {
  const GVTripProgressStep({
    required this.label,
    this.timeLabel,
    this.isCompleted = false,
    this.isActive = false,
  });

  final String label;
  final String? timeLabel;
  final bool isCompleted;
  final bool isActive;
}

/// Trip status timeline matching Screen 13 (horizontal driver approach)
/// and Screen 14 (vertical on-trip progress).
class GVTripProgressTimeline extends StatelessWidget {
  const GVTripProgressTimeline({
    super.key,
    required this.steps,
    this.axis = Axis.horizontal,
  });

  final List<GVTripProgressStep> steps;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    if (axis == Axis.horizontal) {
      return _buildHorizontalTimeline(isDark);
    } else {
      return _buildVerticalTimeline(isDark);
    }
  }

  Widget _buildHorizontalTimeline(bool isDark) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;

        return Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 3,
                      color: index == 0
                          ? Colors.transparent
                          : (step.isCompleted || step.isActive
                              ? GVColors.brandGreen
                              : (isDark
                                  ? GVColors.neutral700
                                  : GVColors.neutral200)),
                    ),
                  ),
                  _buildStepIndicator(step, isDark),
                  Expanded(
                    child: Container(
                      height: 3,
                      color: isLast
                          ? Colors.transparent
                          : (step.isCompleted
                              ? GVColors.brandGreen
                              : (isDark
                                  ? GVColors.neutral700
                                  : GVColors.neutral200)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: GVSpacing.xs),
              Text(
                step.label,
                style: GVTypography.caption.copyWith(
                  fontWeight: (step.isActive || step.isCompleted)
                      ? FontWeight.w700
                      : FontWeight.normal,
                  color: (step.isActive || step.isCompleted)
                      ? (isDark ? GVColors.white : GVColors.textPrimary)
                      : (isDark ? GVColors.neutral500 : GVColors.neutral400),
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if (step.timeLabel != null) ...[
                const SizedBox(height: 2),
                Text(
                  step.timeLabel!,
                  style: GVTypography.caption.copyWith(
                    fontSize: 10,
                    color: isDark ? GVColors.neutral400 : GVColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        );
      }),
    );
  }

  Widget _buildVerticalTimeline(bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(steps.length, (index) {
        final step = steps[index];
        final isLast = index == steps.length - 1;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                _buildStepIndicator(step, isDark),
                if (!isLast)
                  Container(
                    width: 2,
                    height: 36,
                    color: step.isCompleted
                        ? GVColors.brandGreen
                        : (isDark ? GVColors.neutral700 : GVColors.neutral200),
                  ),
              ],
            ),
            const SizedBox(width: GVSpacing.md),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 2, bottom: GVSpacing.sm),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      step.label,
                      style: GVTypography.bodyMedium.copyWith(
                        fontWeight: (step.isActive || step.isCompleted)
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: (step.isActive || step.isCompleted)
                            ? (isDark ? GVColors.white : GVColors.textPrimary)
                            : (isDark
                                ? GVColors.neutral500
                                : GVColors.neutral400),
                      ),
                    ),
                    if (step.timeLabel != null)
                      Text(
                        step.timeLabel!,
                        style: GVTypography.caption.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? GVColors.neutral400
                              : GVColors.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildStepIndicator(GVTripProgressStep step, bool isDark) {
    if (step.isCompleted) {
      return Container(
        width: 18,
        height: 18,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: GVColors.brandGreen,
        ),
        child: const Icon(
          Icons.check,
          size: 11,
          color: GVColors.white,
        ),
      );
    } else if (step.isActive) {
      return Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: GVColors.white,
          border: Border.all(color: GVColors.brandGreen, width: 4),
          boxShadow: [
            BoxShadow(
              color: GVColors.brandGreen.withValues(alpha: 0.35),
              blurRadius: 6,
              spreadRadius: 1,
            ),
          ],
        ),
      );
    } else {
      return Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isDark ? GVColors.neutral700 : GVColors.neutral200,
        ),
      );
    }
  }
}

