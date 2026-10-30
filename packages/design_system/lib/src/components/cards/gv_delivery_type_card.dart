import 'package:flutter/material.dart';
import '../../foundation/gv_border_radius.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_spacing.dart';
import '../../foundation/gv_typography.dart';

/// Screen 2: Delivery Type card (Standard, Express, Scheduled).
class GVDeliveryTypeCard extends StatelessWidget {
  const GVDeliveryTypeCard({
    super.key,
    required this.title,
    required this.description,
    this.icon = Icons.inventory_2_rounded,
    this.isSelected = false,
    this.onTap,
  });

  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isSelected
        ? (isDark ? const Color(0xFF13221A) : const Color(0xFFF0FDF4))
        : (isDark ? const Color(0xFF1A221E) : GVColors.white);

    final borderColor = isSelected
        ? GVColors.brandGreen
        : (isDark ? const Color(0xFF2E3D35) : GVColors.border);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(GVBorderRadius.lg),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(GVSpacing.md),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(GVBorderRadius.lg),
            border: Border.all(
              color: borderColor,
              width: isSelected ? 2.0 : 1.0,
            ),
          ),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isSelected
                      ? GVColors.brandGreen.withValues(alpha: 0.15)
                      : (isDark ? const Color(0xFF26332B) : const Color(0xFFF5F6F8)),
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? GVColors.deepGreen
                      : (isDark ? GVColors.white : GVColors.textPrimary),
                  size: 22,
                ),
              ),
              const SizedBox(width: GVSpacing.md),

              // Title and Description
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
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
                      description,
                      style: GVTypography.bodySmall.copyWith(
                        color: isDark ? GVColors.neutral400 : GVColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              // Radio indicator
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? GVColors.brandGreen : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? GVColors.brandGreen
                        : (isDark ? GVColors.neutral500 : GVColors.neutral300),
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        size: 14,
                        color: GVColors.deepGreen,
                      )
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

