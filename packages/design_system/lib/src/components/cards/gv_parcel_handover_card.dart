import 'package:flutter/material.dart';
import '../../foundation/gv_border_radius.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_spacing.dart';
import '../../foundation/gv_typography.dart';

/// Screen 13: Parcel Handover and Pickup Completed card with timeline.
class GVParcelHandoverCard extends StatelessWidget {
  const GVParcelHandoverCard({
    super.key,
    required this.pickupAddress,
    this.pickupTime = '10:05 AM',
    this.title = 'Parcel picked up!',
    this.subtitle = 'Your parcel is on its way to the destination.',
  });

  final String pickupAddress;
  final String pickupTime;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1A221E) : GVColors.white;
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;

    return Container(
      padding: const EdgeInsets.all(GVSpacing.lg),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(GVBorderRadius.xl),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handover Illustration container
          Container(
            height: 140,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF13221A) : const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(GVBorderRadius.lg),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: GVColors.brandGreen.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.mark_email_read_rounded,
                      color: GVColors.deepGreen,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: GVSpacing.xs),
                  Text(
                    'Handover Confirmed',
                    style: GVTypography.caption.copyWith(
                      color: GVColors.deepGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: GVSpacing.lg),

          Text(
            title,
            style: GVTypography.h3.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? GVColors.white : GVColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: GVTypography.bodySmall.copyWith(
              color: isDark ? GVColors.neutral400 : GVColors.textSecondary,
            ),
          ),
          const SizedBox(height: GVSpacing.lg),

          // Vertical Milestone Timeline
          _buildTimelineStep(
            context,
            isCompleted: true,
            title: 'Picked up',
            subtitle: '$pickupTime • $pickupAddress',
            isFirst: true,
          ),
          _buildTimelineStep(
            context,
            isCompleted: false,
            title: 'On the way',
            subtitle: 'En route to delivery address',
          ),
          _buildTimelineStep(
            context,
            isCompleted: false,
            title: 'Arriving at destination',
            subtitle: 'Recipient verification pending',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineStep(
    BuildContext context, {
    required bool isCompleted,
    required String title,
    required String subtitle,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted ? GVColors.brandGreen : Colors.transparent,
                border: Border.all(
                  color: isCompleted
                      ? GVColors.brandGreen
                      : (isDark ? GVColors.neutral600 : GVColors.neutral300),
                  width: 2,
                ),
              ),
              child: isCompleted
                  ? const Icon(Icons.check, size: 12, color: GVColors.deepGreen)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: isCompleted
                    ? GVColors.brandGreen.withValues(alpha: 0.5)
                    : (isDark ? const Color(0xFF2E3D35) : GVColors.neutral200),
              ),
          ],
        ),
        const SizedBox(width: GVSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GVTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? GVColors.white : GVColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GVTypography.bodySmall.copyWith(
                  color: isDark ? GVColors.neutral400 : GVColors.textSecondary,
                ),
              ),
              const SizedBox(height: GVSpacing.sm),
            ],
          ),
        ),
      ],
    );
  }
}

