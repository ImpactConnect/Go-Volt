import 'package:flutter/material.dart';
import '../../foundation/gv_border_radius.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_typography.dart';

/// Animated or static countdown badge for time-sensitive offers (Board 2 Screen 4).
class GVCountdownBadge extends StatelessWidget {
  const GVCountdownBadge({
    super.key,
    required this.secondsRemaining,
    this.totalSeconds = 15,
  });

  final int secondsRemaining;
  final int totalSeconds;

  @override
  Widget build(BuildContext context) {
    final progress = (secondsRemaining / totalSeconds).clamp(0.0, 1.0);
    final isUrgent = secondsRemaining <= 5;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isUrgent
            ? Colors.redAccent.withValues(alpha: 0.2)
            : GVColors.brandGreen.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(GVBorderRadius.full),
        border: Border.all(
          color: isUrgent ? Colors.redAccent : GVColors.brandGreen,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 2,
              backgroundColor: Colors.white24,
              valueColor: AlwaysStoppedAnimation(
                isUrgent ? Colors.redAccent : GVColors.brandGreen,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '${secondsRemaining}s',
            style: GVTypography.caption.copyWith(
              color: isUrgent ? Colors.redAccent : Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
