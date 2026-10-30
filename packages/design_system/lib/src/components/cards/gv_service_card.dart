import 'package:flutter/material.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_typography.dart';
import '../../foundation/gv_spacing.dart';
import '../../foundation/gv_border_radius.dart';
import '../../foundation/gv_shadows.dart';

/// Service selection card — used on Home and Scheduled Pickup landing screens.
///
/// Shows icon/illustration, title, description, and trailing chevron.
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
  });

  final String title;
  final String description;
  final IconData icon;
  final VoidCallback? onTap;
  final bool isDisabled;
  final String? disabledReason;
  final Widget? badge;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isDisabled ? 0.5 : 1.0,
      child: Material(
        color: GVColors.white,
        borderRadius: GVBorderRadius.cardRadius,
        child: InkWell(
          onTap: isDisabled ? null : onTap,
          borderRadius: GVBorderRadius.cardRadius,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: GVBorderRadius.cardRadius,
              border: Border.all(color: GVColors.border),
              boxShadow: GVShadows.card,
            ),
            padding: const EdgeInsets.all(GVSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: GVColors.softBackground,
                    borderRadius: BorderRadius.circular(GVBorderRadius.sm),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor ?? GVColors.brandGreen,
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
                          Text(title, style: GVTypography.bodyMedium),
                          if (badge != null) ...[
                            const SizedBox(width: GVSpacing.sm),
                            badge!,
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isDisabled && disabledReason != null
                            ? disabledReason!
                            : description,
                        style: GVTypography.bodySmall
                            .copyWith(color: GVColors.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: GVSpacing.sm),
                Icon(Icons.chevron_right,
                    color: isDisabled
                        ? GVColors.textDisabled
                        : GVColors.textSecondary,
                    size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
