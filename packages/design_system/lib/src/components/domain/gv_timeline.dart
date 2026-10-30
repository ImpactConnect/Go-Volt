import 'package:flutter/material.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_typography.dart';
import '../../foundation/gv_spacing.dart';

enum GVTimelineStepState { completed, current, pending }

class GVTimelineStep {
  const GVTimelineStep({required this.label, required this.state, this.subtitle});
  final String label;
  final GVTimelineStepState state;
  final String? subtitle;
}

/// Vertical milestone timeline — used on D08 delivery tracking, SP21 school-run status.
class GVTimeline extends StatelessWidget {
  const GVTimeline({super.key, required this.steps});
  final List<GVTimelineStep> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: steps.asMap().entries.map((entry) {
        final i = entry.key;
        final step = entry.value;
        final isLast = i == steps.length - 1;
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                child: Column(
                  children: [
                    Container(
                      width: 16, height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: switch (step.state) {
                          GVTimelineStepState.completed => GVColors.brandGreen,
                          GVTimelineStepState.current => GVColors.white,
                          GVTimelineStepState.pending => GVColors.border,
                        },
                        border: step.state == GVTimelineStepState.current
                            ? Border.all(color: GVColors.brandGreen, width: 2)
                            : null,
                      ),
                      child: step.state == GVTimelineStepState.completed
                          ? const Icon(Icons.check, size: 10, color: GVColors.white)
                          : null,
                    ),
                    if (!isLast) Expanded(
                      child: Container(width: 2, color: GVColors.border, margin: const EdgeInsets.symmetric(vertical: 2)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: GVSpacing.sm),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : GVSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(step.label, style: GVTypography.bodySmallMedium.copyWith(
                        color: step.state == GVTimelineStepState.pending ? GVColors.textDisabled : GVColors.nearBlack,
                      )),
                      if (step.subtitle != null) Text(step.subtitle!, style: GVTypography.caption.copyWith(color: GVColors.textSecondary)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
