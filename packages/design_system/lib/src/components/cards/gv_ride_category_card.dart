import 'package:flutter/material.dart';
import '../../foundation/gv_border_radius.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_spacing.dart';
import '../../foundation/gv_typography.dart';

/// Feature badge for a ride category (e.g., "AC", "3 Seats", "Trusted riders").
class GVRideFeatureBadge {
  const GVRideFeatureBadge({
    required this.label,
    this.icon,
  });

  final String label;
  final IconData? icon;
}

/// Ride option selection card shown on Screen 8 ("Choose a ride").
///
/// Fully dynamic — takes category details, dynamic ETA, price label,
/// feature badges, and selection callback.
class GVRideCategoryCard extends StatelessWidget {
  const GVRideCategoryCard({
    super.key,
    required this.name,
    required this.priceLabel,
    this.etaLabel,
    this.description,
    this.isSelected = false,
    this.onTap,
    this.features = const [],
    this.leadingWidget,
    this.vehicleIcon = Icons.directions_car_rounded,
    this.badgeText,
  });

  final String name;
  final String priceLabel;
  final String? etaLabel;
  final String? description;
  final bool isSelected;
  final VoidCallback? onTap;
  final List<GVRideFeatureBadge> features;
  final Widget? leadingWidget;
  final IconData vehicleIcon;
  final String? badgeText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isSelected
        ? (isDark ? const Color(0xFF13221A) : const Color(0xFFF0FDF4))
        : (isDark ? const Color(0xFF1A221E) : GVColors.white);

    final borderColor = isSelected
        ? GVColors.brandGreen
        : (isDark ? const Color(0xFF2E3D35) : GVColors.border);

    return InkWell(
      onTap: onTap,
      borderRadius: GVBorderRadius.cardRadius,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(GVSpacing.md),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: GVBorderRadius.cardRadius,
          border: Border.all(
            color: borderColor,
            width: isSelected ? 1.8 : 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: GVColors.brandGreen.withValues(alpha: 0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Vehicle Thumbnail / Icon
                leadingWidget ??
                    Container(
                      width: 52,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF243029)
                            : GVColors.softBackground,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Icon(
                        vehicleIcon,
                        size: 28,
                        color: isSelected
                            ? GVColors.brandGreen
                            : (isDark
                                ? GVColors.neutral300
                                : GVColors.textPrimary),
                      ),
                    ),
                const SizedBox(width: GVSpacing.md),

                // Name, ETA pill, and Description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              style: GVTypography.labelLarge.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isDark
                                    ? GVColors.white
                                    : GVColors.textPrimary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (badgeText != null) ...[
                            const SizedBox(width: GVSpacing.xs),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: GVColors.limeHighlight,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                badgeText!,
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: GVColors.deepGreen,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 3),
                      if (etaLabel != null) ...[
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF064E3B)
                                    : GVColors.statusActiveBg,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                etaLabel!,
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: GVColors.statusActiveFg,
                                ),
                              ),
                            ),
                            if (description != null) ...[
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  description!,
                                  style: GVTypography.caption.copyWith(
                                    color: isDark
                                        ? GVColors.neutral400
                                        : GVColors.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ] else if (description != null) ...[
                        Text(
                          description!,
                          style: GVTypography.caption.copyWith(
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

                // Price and Radio Selection Circle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      priceLabel,
                      style: GVTypography.labelLarge.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isDark ? GVColors.white : GVColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? GVColors.brandGreen : Colors.transparent,
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
                    ),
                  ],
                ),
              ],
            ),

            // Optional Feature Badges (e.g. AC, 3 Seats, Trusted riders)
            if (features.isNotEmpty) ...[
              const SizedBox(height: GVSpacing.sm),
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: features.map((feature) {
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (feature.icon != null) ...[
                          Icon(
                            feature.icon,
                            size: 14,
                            color: isDark
                                ? GVColors.neutral400
                                : GVColors.textSecondary,
                          ),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          feature.label,
                          style: GVTypography.caption.copyWith(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: isDark
                                ? GVColors.neutral300
                                : GVColors.textSecondary,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

