import 'package:flutter/material.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_typography.dart';
import '../../foundation/gv_border_radius.dart';

/// Booking/delivery status values.
enum GVStatusType {
  pending,
  active,
  assigned,
  delayed,
  completed,
  cancelled,
  failed,
}

/// Status chip that communicates via text + icon + background — never color alone.
///
/// Spec: "Status chips: text plus icon or shape; do not rely on color alone."
class GVStatusChip extends StatelessWidget {
  const GVStatusChip({
    super.key,
    required this.status,
    this.label,
    this.compact = false,
  });

  final GVStatusType status;
  final String? label;
  final bool compact;

  _ChipConfig get _config => switch (status) {
        GVStatusType.pending => const _ChipConfig(
            label: 'Pending',
            icon: Icons.schedule_outlined,
            bg: GVColors.statusPendingBg,
            fg: GVColors.statusPendingFg,
          ),
        GVStatusType.active => const _ChipConfig(
            label: 'Active',
            icon: Icons.radio_button_on,
            bg: GVColors.statusActiveBg,
            fg: GVColors.statusActiveFg,
          ),
        GVStatusType.assigned => const _ChipConfig(
            label: 'Assigned',
            icon: Icons.person_outline,
            bg: GVColors.statusAssignedBg,
            fg: GVColors.statusAssignedFg,
          ),
        GVStatusType.delayed => const _ChipConfig(
            label: 'Delayed',
            icon: Icons.warning_amber_outlined,
            bg: GVColors.statusDelayedBg,
            fg: GVColors.statusDelayedFg,
          ),
        GVStatusType.completed => const _ChipConfig(
            label: 'Completed',
            icon: Icons.check_circle_outline,
            bg: GVColors.statusCompletedBg,
            fg: GVColors.statusCompletedFg,
          ),
        GVStatusType.cancelled => const _ChipConfig(
            label: 'Cancelled',
            icon: Icons.cancel_outlined,
            bg: GVColors.statusCancelledBg,
            fg: GVColors.statusCancelledFg,
          ),
        GVStatusType.failed => const _ChipConfig(
            label: 'Failed',
            icon: Icons.error_outline,
            bg: GVColors.statusDelayedBg,
            fg: GVColors.statusDelayedFg,
          ),
      };

  @override
  Widget build(BuildContext context) {
    final cfg = _config;
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: cfg.bg,
        borderRadius: GVBorderRadius.chipRadius,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(cfg.icon, size: compact ? 12 : 14, color: cfg.fg),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label ?? cfg.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: (compact ? GVTypography.caption : GVTypography.label)
                  .copyWith(color: cfg.fg, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipConfig {
  const _ChipConfig({
    required this.label,
    required this.icon,
    required this.bg,
    required this.fg,
  });
  final String label;
  final IconData icon;
  final Color bg;
  final Color fg;
}
