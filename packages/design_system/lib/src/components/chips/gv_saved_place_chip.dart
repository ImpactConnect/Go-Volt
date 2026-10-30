import 'package:flutter/material.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_typography.dart';
import '../../foundation/gv_spacing.dart';
import '../../foundation/gv_border_radius.dart';

/// Quick-access chip for Home, Work, and saved destinations.
/// Matches Screen 11 (HOME-01-DEFAULT) and Specification §13.7.
class GVSavedPlaceChip extends StatelessWidget {
  const GVSavedPlaceChip({
    super.key,
    required this.label,
    required this.address,
    this.icon,
    this.onTap,
  });

  final String label;
  final String address;
  final IconData? icon;
  final VoidCallback? onTap;

  IconData get defaultIcon {
    final lower = label.toLowerCase();
    if (lower.contains('home')) return Icons.home_rounded;
    if (lower.contains('work')) return Icons.work_rounded;
    return Icons.location_on_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1C2420) : GVColors.white;
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;

    return Material(
      color: cardBg,
      borderRadius: GVBorderRadius.cardRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: GVBorderRadius.cardRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: GVSpacing.md,
            vertical: GVSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: GVBorderRadius.cardRadius,
            border: Border.all(color: borderColor),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF131A16) : GVColors.softBackground,
                  borderRadius: BorderRadius.circular(GVBorderRadius.sm),
                ),
                child: Icon(
                  icon ?? defaultIcon,
                  size: 18,
                  color: GVColors.brandGreen,
                ),
              ),
              const SizedBox(width: GVSpacing.sm),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: GVTypography.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : GVColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      address,
                      style: GVTypography.caption.copyWith(
                        color: isDark ? GVColors.neutral400 : GVColors.textSecondary,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

