import 'package:flutter/material.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_typography.dart';
import '../../foundation/gv_spacing.dart';
import '../../foundation/gv_border_radius.dart';

/// Price line item model.
class GVPriceLine {
  const GVPriceLine({
    required this.label,
    required this.amountLabel,
    this.isDiscount = false,
    this.isBold = false,
    this.semanticLabel,
  });

  final String label;
  final String amountLabel;
  final bool isDiscount;
  final bool isBold;
  final String? semanticLabel;
}

/// Fare breakdown widget shown on R03, D04, SP05, checkout screens.
///
/// Always labels estimates clearly — never implies a final confirmed fare.
class GVPriceBreakdown extends StatelessWidget {
  const GVPriceBreakdown({
    super.key,
    required this.lines,
    required this.totalLabel,
    this.isEstimate = false,
    this.estimateDisclaimer,
  });

  final List<GVPriceLine> lines;
  final String totalLabel;
  final bool isEstimate;
  final String? estimateDisclaimer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(GVSpacing.md),
      decoration: BoxDecoration(
        color: GVColors.white,
        borderRadius: GVBorderRadius.cardRadius,
        border: Border.all(color: GVColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Price breakdown', style: GVTypography.bodyMedium),
              if (isEstimate) ...[
                const SizedBox(width: GVSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: GVSpacing.sm, vertical: 2),
                  decoration: const BoxDecoration(
                    color: GVColors.statusPendingBg,
                    borderRadius: GVBorderRadius.chipRadius,
                  ),
                  child: Text('Estimate',
                      style: GVTypography.caption
                          .copyWith(color: GVColors.statusPendingFg)),
                ),
              ],
            ],
          ),
          const SizedBox(height: GVSpacing.md),
          ...lines.map(
            (line) => Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: GVSpacing.xs),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      line.label,
                      style: line.isBold
                          ? GVTypography.bodyMedium
                          : GVTypography.body.copyWith(
                              color: GVColors.textSecondary),
                    ),
                  ),
                  Text(
                    line.amountLabel,
                    style: (line.isBold
                            ? GVTypography.bodyMedium
                            : GVTypography.body)
                        .copyWith(
                      color: line.isDiscount
                          ? GVColors.accentGreen
                          : GVColors.nearBlack,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Divider(height: GVSpacing.md),
          Row(
            children: [
              Expanded(child: Text('Total', style: GVTypography.h3)),
              Text(totalLabel, style: GVTypography.h3),
            ],
          ),
          if (estimateDisclaimer != null) ...[
            const SizedBox(height: GVSpacing.sm),
            Text(
              estimateDisclaimer!,
              style: GVTypography.caption
                  .copyWith(color: GVColors.textSecondary),
            ),
          ],
        ],
      ),
    );
  }
}
