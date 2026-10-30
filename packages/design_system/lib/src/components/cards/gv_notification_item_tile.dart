import 'package:flutter/material.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_typography.dart';
import '../../foundation/gv_spacing.dart';
import '../../foundation/gv_border_radius.dart';

/// Notification row tile used in the Customer Notifications Center.
/// Matches Screen 15 (HOME-07-NOTIFICATIONS).
class GVNotificationItemTile extends StatelessWidget {
  const GVNotificationItemTile({
    super.key,
    required this.title,
    required this.message,
    required this.timeAgo,
    this.isRead = false,
    this.icon,
    this.iconColor,
    this.onTap,
  });

  final String title;
  final String message;
  final String timeAgo;
  final bool isRead;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onTap;

  IconData get defaultIcon {
    final lower = title.toLowerCase();
    if (lower.contains('rider') || lower.contains('trip')) return Icons.two_wheeler_rounded;
    if (lower.contains('deliver') || lower.contains('parcel')) return Icons.inventory_2_outlined;
    if (lower.contains('offer') || lower.contains('promo')) return Icons.local_offer_outlined;
    if (lower.contains('reward') || lower.contains('point')) return Icons.star_rounded;
    if (lower.contains('verified') || lower.contains('account')) return Icons.verified_user_outlined;
    return Icons.notifications_none_rounded;
  }

  Color get defaultColor {
    final lower = title.toLowerCase();
    if (lower.contains('rider')) return Colors.orange;
    if (lower.contains('deliver') || lower.contains('verified')) return GVColors.brandGreen;
    if (lower.contains('offer')) return Colors.pinkAccent;
    if (lower.contains('reward')) return Colors.amber;
    return GVColors.brandGreen;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1C2420) : GVColors.white;
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;
    final effectiveColor = iconColor ?? defaultColor;

    return Material(
      color: cardBg,
      borderRadius: GVBorderRadius.cardRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: GVBorderRadius.cardRadius,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: GVSpacing.md,
            vertical: GVSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: GVBorderRadius.cardRadius,
            border: Border.all(
              color: isRead
                  ? borderColor
                  : GVColors.brandGreen.withValues(alpha: 0.35),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Circular Icon Badge
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: effectiveColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon ?? defaultIcon,
                  size: 20,
                  color: effectiveColor,
                ),
              ),
              const SizedBox(width: GVSpacing.sm),

              // Title, Message, TimeAgo
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: GVTypography.bodyMedium.copyWith(
                              fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                              color: isDark ? Colors.white : GVColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: GVColors.brandGreen,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      message,
                      style: GVTypography.bodySmall.copyWith(
                        color: isDark ? GVColors.neutral300 : GVColors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeAgo,
                      style: GVTypography.caption.copyWith(
                        color: isDark ? GVColors.neutral500 : GVColors.neutral400,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: GVSpacing.xs),

              // Trailing arrow
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: isDark ? GVColors.neutral500 : GVColors.neutral400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

