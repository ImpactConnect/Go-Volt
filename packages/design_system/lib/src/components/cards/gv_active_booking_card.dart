import 'package:flutter/material.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_typography.dart';
import '../../foundation/gv_spacing.dart';
import '../../foundation/gv_border_radius.dart';
import '../../foundation/gv_shadows.dart';

/// Dynamic hero card displayed on the Home Dashboard when the customer has an active booking.
/// Matches Screen 12 (HOME-02-ACTIVE-BOOKING) and Specification §13.5.
class GVActiveBookingCard extends StatelessWidget {
  const GVActiveBookingCard({
    super.key,
    required this.serviceTitle,
    required this.referenceCode,
    this.statusBadge = 'In progress',
    this.riderName = 'Babajide S.',
    this.riderAvatarUrl,
    this.statusMessage = 'Rider approaching',
    this.etaMinutes = 3,
    this.onViewOnMap,
  });

  final String serviceTitle;
  final String referenceCode;
  final String statusBadge;
  final String? riderName;
  final String? riderAvatarUrl;
  final String statusMessage;
  final int? etaMinutes;
  final VoidCallback? onViewOnMap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1C2420) : GVColors.white;
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: GVBorderRadius.cardRadius,
        border: Border.all(color: borderColor),
        boxShadow: isDark ? null : GVShadows.card,
      ),
      padding: const EdgeInsets.all(GVSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row: "Your active booking" + "In progress" badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Your active booking',
                style: GVTypography.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : GVColors.textPrimary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: GVColors.brandGreen.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(GVBorderRadius.full),
                  border: Border.all(
                    color: GVColors.brandGreen.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  statusBadge,
                  style: GVTypography.caption.copyWith(
                    color: GVColors.brandGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: GVSpacing.sm),
          Divider(
            color: isDark ? const Color(0xFF2E3D35) : GVColors.divider,
            height: 1,
          ),
          const SizedBox(height: GVSpacing.sm),

          // Booking & Rider Info Row
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: GVColors.brandGreen.withValues(alpha: 0.2),
                backgroundImage: riderAvatarUrl != null ? NetworkImage(riderAvatarUrl!) : null,
                child: riderAvatarUrl == null
                    ? Text(
                        (riderName?.isNotEmpty == true) ? riderName![0].toUpperCase() : 'R',
                        style: GVTypography.bodyMedium.copyWith(
                          color: GVColors.brandGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: GVSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            serviceTitle,
                            style: GVTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : GVColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          referenceCode,
                          style: GVTypography.caption.copyWith(
                            color: isDark ? GVColors.neutral400 : GVColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    if (riderName != null && riderName!.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        riderName!,
                        style: GVTypography.caption.copyWith(
                          color: isDark ? Colors.white70 : GVColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: GVSpacing.sm),

          // Status & Map CTA Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Text(
                        statusMessage,
                        style: GVTypography.caption.copyWith(
                          color: isDark ? GVColors.neutral300 : GVColors.textSecondary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (etaMinutes != null) ...[
                      Text(
                        ' • ',
                        style: GVTypography.caption.copyWith(
                          color: isDark ? GVColors.neutral500 : GVColors.neutral400,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF131A16) : GVColors.softBackground,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'ETA $etaMinutes mins',
                          style: GVTypography.caption.copyWith(
                            color: GVColors.brandGreen,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: GVSpacing.sm),
              OutlinedButton(
                onPressed: onViewOnMap,
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(0, 34),
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  side: const BorderSide(color: GVColors.brandGreen, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(GVBorderRadius.sm),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.map_outlined, size: 14, color: GVColors.brandGreen),
                    const SizedBox(width: 4),
                    Text(
                      'View on map',
                      style: GVTypography.caption.copyWith(
                        color: GVColors.brandGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
