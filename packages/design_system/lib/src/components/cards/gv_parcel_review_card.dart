import 'package:flutter/material.dart';
import '../../foundation/gv_border_radius.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_spacing.dart';
import '../../foundation/gv_typography.dart';

/// Screen 7: Review and Quote summary card (Delivery details, Package details, Price breakdown).
class GVParcelReviewCard extends StatelessWidget {
  const GVParcelReviewCard({
    super.key,
    required this.pickupAddress,
    required this.deliveryAddress,
    required this.packageTitle,
    required this.handlingTag,
    required this.deliveryTypeTitle,
    required this.baseFareLabel,
    required this.distanceFareLabel,
    required this.distanceLabel,
    required this.handlingFareLabel,
    required this.insuranceFareLabel,
    required this.totalFareLabel,
    this.onEditDeliveryDetails,
  });

  final String pickupAddress;
  final String deliveryAddress;
  final String packageTitle;
  final String handlingTag;
  final String deliveryTypeTitle;
  final String baseFareLabel;
  final String distanceFareLabel;
  final String distanceLabel;
  final String handlingFareLabel;
  final String insuranceFareLabel;
  final String totalFareLabel;
  final VoidCallback? onEditDeliveryDetails;

  Widget _buildSectionCard({
    required BuildContext context,
    required Widget child,
    String? title,
    Widget? action,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1A221E) : GVColors.white;
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;

    return Container(
      padding: const EdgeInsets.all(GVSpacing.md),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(GVBorderRadius.lg),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GVTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? GVColors.white : GVColors.textPrimary,
                  ),
                ),
                ?action,
              ],
            ),
            const SizedBox(height: GVSpacing.sm),
          ],
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Delivery Details
        _buildSectionCard(
          context: context,
          title: 'Delivery details',
          action: InkWell(
            onTap: onEditDeliveryDetails,
            child: Text(
              'Edit',
              style: GVTypography.bodySmallMedium.copyWith(
                color: GVColors.brandGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.circle, size: 10, color: GVColors.brandGreen),
                  const SizedBox(width: GVSpacing.sm),
                  Expanded(
                    child: Text(
                      pickupAddress,
                      style: GVTypography.bodyMedium.copyWith(
                        color: isDark ? GVColors.white : GVColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: GVSpacing.sm),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: GVColors.error),
                  const SizedBox(width: GVSpacing.sm),
                  Expanded(
                    child: Text(
                      deliveryAddress,
                      style: GVTypography.bodyMedium.copyWith(
                        color: isDark ? GVColors.white : GVColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: GVSpacing.md),

        // 2. Package Details
        _buildSectionCard(
          context: context,
          title: 'Package details',
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF26332B) : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                ),
                child: const Icon(
                  Icons.inventory_2_rounded,
                  color: GVColors.deepGreen,
                  size: 24,
                ),
              ),
              const SizedBox(width: GVSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      packageTitle,
                      style: GVTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? GVColors.white : GVColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      handlingTag,
                      style: GVTypography.bodySmall.copyWith(
                        color: isDark ? GVColors.neutral400 : GVColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Delivery type\n$deliveryTypeTitle',
                      style: GVTypography.caption.copyWith(
                        color: isDark ? GVColors.neutral400 : GVColors.textSecondary,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: GVSpacing.md),

        // 3. Price Breakdown
        _buildSectionCard(
          context: context,
          title: 'Price breakdown',
          child: Column(
            children: [
              _buildPriceRow(context, 'Base fare', baseFareLabel),
              const SizedBox(height: GVSpacing.xs),
              _buildPriceRow(context, 'Distance ($distanceLabel)', distanceFareLabel),
              const SizedBox(height: GVSpacing.xs),
              _buildPriceRow(context, 'Package handling', handlingFareLabel),
              const SizedBox(height: GVSpacing.xs),
              _buildPriceRow(context, 'Insurance', insuranceFareLabel),
              const Divider(height: GVSpacing.lg),
              _buildPriceRow(context, 'Total fare', totalFareLabel, isBold: true),
              const SizedBox(height: GVSpacing.md),
              Container(
                padding: const EdgeInsets.all(GVSpacing.sm),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF13221A)
                      : GVColors.brandGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(GVBorderRadius.sm),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 16,
                      color: GVColors.deepGreen,
                    ),
                    const SizedBox(width: GVSpacing.xs),
                    Expanded(
                      child: Text(
                        'Final fare may vary slightly based on distance, traffic and package details.',
                        style: GVTypography.caption.copyWith(
                          color: isDark ? GVColors.neutral300 : GVColors.deepGreen,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceRow(
    BuildContext context,
    String label,
    String value, {
    bool isBold = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? GVColors.white : GVColors.textPrimary;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isBold
              ? GVTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: color)
              : GVTypography.bodySmall.copyWith(color: isDark ? GVColors.neutral400 : GVColors.textSecondary),
        ),
        Text(
          value,
          style: isBold
              ? GVTypography.body.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: color,
                )
              : GVTypography.bodyMedium
                  .copyWith(color: color, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
