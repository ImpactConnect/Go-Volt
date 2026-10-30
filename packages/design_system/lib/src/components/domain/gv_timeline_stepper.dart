import 'package:flutter/material.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_spacing.dart';
import '../../foundation/gv_typography.dart';

/// Status of an individual step in [GVTimelineStepper].
enum GVStepState {
  completed,
  inProgress,
  pending,
}

/// Item configuration for [GVTimelineStepper].
class GVTimelineStepItem {
  const GVTimelineStepItem({
    required this.title,
    this.subtitle,
    required this.state,
  });

  final String title;
  final String? subtitle;
  final GVStepState state;
}

/// 5-stage vertical timeline stepper matching Board 1 Screen 5.
class GVTimelineStepper extends StatelessWidget {
  const GVTimelineStepper({
    super.key,
    required this.steps,
  });

  final List<GVTimelineStepItem> steps;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < steps.length; i++) ...[
          _buildStepRow(steps[i], isLast: i == steps.length - 1),
        ],
      ],
    );
  }

  Widget _buildStepRow(GVTimelineStepItem step, {required bool isLast}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon and connecting line
          Column(
            children: [
              _buildStepIcon(step.state),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: step.state == GVStepState.completed
                        ? GVColors.brandGreen
                        : const Color(0xFF2A3630),
                  ),
                ),
            ],
          ),
          const SizedBox(width: GVSpacing.md),
          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : GVSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.title,
                    style: GVTypography.bodyMedium.copyWith(
                      color: step.state == GVStepState.pending
                          ? Colors.white54
                          : Colors.white,
                      fontWeight: step.state != GVStepState.pending
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
                  ),
                  if (step.subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      step.subtitle!,
                      style: GVTypography.caption.copyWith(
                        color: step.state == GVStepState.inProgress
                            ? GVColors.limeHighlight
                            : Colors.white54,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIcon(GVStepState state) {
    switch (state) {
      case GVStepState.completed:
        return Container(
          width: 24,
          height: 24,
          decoration: const BoxDecoration(
            color: GVColors.brandGreen,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check, color: Colors.black, size: 16),
        );
      case GVStepState.inProgress:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF141917),
            shape: BoxShape.circle,
            border: Border.all(color: GVColors.brandGreen, width: 2),
          ),
          child: const Center(
            child: SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: GVColors.brandGreen,
              ),
            ),
          ),
        );
      case GVStepState.pending:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF1C2420),
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF2A3630), width: 1.5),
          ),
        );
    }
  }
}
