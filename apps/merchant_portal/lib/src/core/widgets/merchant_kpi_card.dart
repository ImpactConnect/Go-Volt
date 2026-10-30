import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

class MerchantKpiCard extends StatelessWidget {
  const MerchantKpiCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.subtitle,
    this.isPositive,
    this.badgeLabel,
    this.iconColor,
    this.accentColor,
  });

  final String title;
  final String value;
  final IconData icon;
  final String? subtitle;
  final bool? isPositive;
  final String? badgeLabel;
  final Color? iconColor;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final effectiveColor = accentColor ?? iconColor ?? GVColors.brandGreen;

    return Container(
      padding: const EdgeInsets.all(GVSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF141C18),
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        border: Border.all(color: const Color(0xFF223028), width: 1),
        boxShadow: GVShadows.elevated,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  title.toUpperCase(),
                  style: GVTypography.caption.copyWith(
                    color: Colors.white60,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.8,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: effectiveColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 18, color: effectiveColor),
              ),
            ],
          ),
          const SizedBox(height: GVSpacing.sm),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: GVTypography.h1.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (badgeLabel != null) ...[
                const SizedBox(width: GVSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: effectiveColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    badgeLabel!,
                    style: TextStyle(
                      color: effectiveColor,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (subtitle != null) ...[
            const SizedBox(height: GVSpacing.xs),
            Row(
              children: [
                if (isPositive != null) ...[
                  Icon(
                    isPositive! ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 12,
                    color: isPositive! ? GVColors.brandGreen : Colors.redAccent,
                  ),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Text(
                    subtitle!,
                    style: GVTypography.caption.copyWith(
                      color: isPositive == null
                          ? Colors.white54
                          : (isPositive! ? GVColors.brandGreen : Colors.redAccent),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
