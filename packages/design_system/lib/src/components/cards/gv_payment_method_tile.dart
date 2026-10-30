import 'package:flutter/material.dart';
import '../../foundation/gv_border_radius.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_spacing.dart';
import '../../foundation/gv_typography.dart';

/// Selectable payment method tile matching Screens 9 & 10.
///
/// Supports Go-Volts Wallet (with balance), saved cards, bank accounts,
/// cash, and alternative payment options.
class GVPaymentMethodTile extends StatelessWidget {
  const GVPaymentMethodTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    this.isSelected = false,
    this.isSelectable = true,
    this.trailing,
    this.onTap,
    this.badge,
    this.enabled = true,
  });

  final String title;
  final String? subtitle;
  final Widget icon;
  final bool isSelected;
  final bool isSelectable;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? badge;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = isSelected
        ? (isDark ? const Color(0xFF13221A) : const Color(0xFFF0FDF4))
        : (isDark ? const Color(0xFF1A221E) : GVColors.white);

    final borderColor = isSelected
        ? GVColors.brandGreen
        : (isDark ? const Color(0xFF2E3D35) : GVColors.border);

    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: GVBorderRadius.cardRadius,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(
              horizontal: GVSpacing.md,
              vertical: GVSpacing.md - 2,
            ),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: GVBorderRadius.cardRadius,
              border: Border.all(
                color: borderColor,
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                // Icon container
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF243029)
                        : GVColors.softBackground,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: icon,
                ),
                const SizedBox(width: GVSpacing.md),

                // Title and Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              title,
                              style: GVTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? GVColors.white
                                    : GVColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (badge != null) ...[
                            const SizedBox(width: GVSpacing.xs),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: GVColors.statusActiveBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                badge!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: GVColors.statusActiveFg,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: GVTypography.bodySmall.copyWith(
                            color: isDark
                                ? GVColors.neutral400
                                : GVColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: GVSpacing.sm),

                // Trailing widget (radio checkmark or chevron)
                trailing ??
                    (isSelectable
                        ? AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            width: 22,
                            height: 22,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isSelected
                                  ? GVColors.brandGreen
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? GVColors.brandGreen
                                    : (isDark
                                        ? GVColors.neutral600
                                        : GVColors.neutral300),
                                width: 2,
                              ),
                            ),
                            child: isSelected
                                ? const Center(
                                    child: Icon(
                                      Icons.check,
                                      size: 14,
                                      color: GVColors.white,
                                    ),
                                  )
                                : null,
                          )
                        : Icon(
                            Icons.chevron_right_rounded,
                            color: isDark
                                ? GVColors.neutral400
                                : GVColors.neutral500,
                          )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

