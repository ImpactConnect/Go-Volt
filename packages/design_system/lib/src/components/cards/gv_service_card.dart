import 'package:flutter/material.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_typography.dart';
import '../../foundation/gv_spacing.dart';
import '../../foundation/gv_border_radius.dart';
import '../../foundation/gv_shadows.dart';

enum GVServiceCardLayout { grid, list }

/// Service action card supporting 2x2 grid layout (Home Dashboard) and list layout.
/// Handles enabled, disabled/unavailable states per Product Principle 6.
class GVServiceCard extends StatelessWidget {
  const GVServiceCard({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.onTap,
    this.isDisabled = false,
    this.disabledReason,
    this.badge,
    this.iconColor,
    this.layout = GVServiceCardLayout.grid,
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDisabled;
  final String? disabledReason;
  final Widget? badge;
  final Color? iconColor;
  final GVServiceCardLayout layout;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1C2420) : GVColors.white;
    final borderColor = isDisabled
        ? (isDark ? GVColors.error.withValues(alpha: 0.3) : GVColors.error.withValues(alpha: 0.2))
        : (isDark ? const Color(0xFF2E3D35) : GVColors.border);

    return Opacity(
      opacity: isDisabled ? 0.85 : 1.0,
      child: Material(
        color: cardBg,
        borderRadius: GVBorderRadius.cardRadius,
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: GVBorderRadius.cardRadius,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: GVBorderRadius.cardRadius,
              border: Border.all(color: borderColor),
              boxShadow: isDark ? null : GVShadows.card,
            ),
            padding: const EdgeInsets.all(GVSpacing.md),
            child: layout == GVServiceCardLayout.grid
                ? _buildGridLayout(context, isDark)
                : _buildListLayout(context, isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildGridLayout(BuildContext context, bool isDark) {
    final iconBg = isDisabled
        ? GVColors.error.withValues(alpha: 0.12)
        : (isDark ? const Color(0xFF131A16) : GVColors.brandGreen.withValues(alpha: 0.1));
    final effectiveIconColor = isDisabled
        ? GVColors.error
        : (iconColor ?? GVColors.brandGreen);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
              ),
              child: Icon(
                icon,
                color: effectiveIconColor,
                size: 24,
              ),
            ),
            ?badge,
          ],
        ),
        const SizedBox(height: GVSpacing.sm),
        if (isDisabled) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: GVColors.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              'Currently unavailable',
              style: GVTypography.caption.copyWith(
                color: GVColors.error,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
        Text(
          title,
          style: GVTypography.h3.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : GVColors.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          isDisabled && disabledReason != null ? disabledReason! : description,
          style: GVTypography.caption.copyWith(
            color: isDisabled
                ? GVColors.error.withValues(alpha: 0.9)
                : (isDark ? GVColors.neutral400 : GVColors.textSecondary),
            fontSize: 11,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildListLayout(BuildContext context, bool isDark) {
    return Row(
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131A16) : GVColors.softBackground,
            borderRadius: BorderRadius.circular(GVBorderRadius.sm),
          ),
          child: Icon(
            icon,
            color: isDisabled ? GVColors.neutral400 : (iconColor ?? GVColors.brandGreen),
            size: 26,
          ),
        ),
        const SizedBox(width: GVSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: GVTypography.bodyMedium.copyWith(
                      color: isDark ? Colors.white : GVColors.textPrimary,
                    ),
                  ),
                  if (badge != null) ...[
                    const SizedBox(width: GVSpacing.sm),
                    badge!,
                  ],
                ],
              ),
              const SizedBox(height: 2),
              Text(
                isDisabled && disabledReason != null ? disabledReason! : description,
                style: GVTypography.bodySmall.copyWith(
                  color: isDisabled
                      ? GVColors.error
                      : (isDark ? GVColors.neutral400 : GVColors.textSecondary),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: GVSpacing.sm),
        Icon(
          Icons.chevron_right,
          color: isDisabled ? GVColors.textDisabled : (isDark ? GVColors.neutral400 : GVColors.textSecondary),
          size: 20,
        ),
      ],
    );
  }
}
