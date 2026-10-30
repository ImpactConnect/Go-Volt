import 'package:flutter/material.dart';
import '../../foundation/gv_border_radius.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_spacing.dart';
import '../../foundation/gv_typography.dart';

/// Single item in a fare breakdown.
class GVFareItem {
  const GVFareItem({
    required this.label,
    required this.amountLabel,
    this.isDiscount = false,
    this.isSubtotal = false,
    this.isBold = false,
  });

  final String label;
  final String amountLabel;
  final bool isDiscount;
  final bool isSubtotal;
  final bool isBold;
}

/// Fare details & breakdown card matching Screen 9 ("Fare details") & Screen 16.
///
/// Fully dynamic — takes itemized lines, total label, estimated range,
/// traffic variability disclaimer, and promo code controller/actions.
class GVFareBreakdownCard extends StatelessWidget {
  const GVFareBreakdownCard({
    super.key,
    this.title = 'Fare breakdown',
    required this.items,
    required this.totalLabel,
    this.totalTitle = 'Estimated fare',
    this.rangeLabel,
    this.noticeText =
        'Final fare may vary slightly\nDue to traffic, route changes or waiting time.',
    this.promoCode,
    this.promoDiscountLabel,
    this.promoController,
    this.onApplyPromo,
    this.onRemovePromo,
    this.isApplyingPromo = false,
    this.promoError,
  });

  final String title;
  final List<GVFareItem> items;
  final String totalLabel;
  final String totalTitle;
  final String? rangeLabel;
  final String? noticeText;
  final String? promoCode;
  final String? promoDiscountLabel;
  final TextEditingController? promoController;
  final ValueChanged<String>? onApplyPromo;
  final VoidCallback? onRemovePromo;
  final bool isApplyingPromo;
  final String? promoError;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Main Itemized Breakdown Card
        Container(
          padding: const EdgeInsets.all(GVSpacing.md),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A221E) : GVColors.white,
            borderRadius: GVBorderRadius.cardRadius,
            border: Border.all(
              color: isDark ? const Color(0xFF2E3D35) : GVColors.border,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GVTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? GVColors.white : GVColors.textPrimary,
                ),
              ),
              const SizedBox(height: GVSpacing.md),

              // Item lines
              ...items.map((item) {
                final textCol = item.isDiscount
                    ? GVColors.brandGreen
                    : (isDark ? GVColors.neutral300 : GVColors.textPrimary);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        item.label,
                        style: (item.isBold
                                ? GVTypography.bodyMedium
                                : GVTypography.bodySmall)
                            .copyWith(
                          fontWeight:
                              item.isBold ? FontWeight.w600 : FontWeight.normal,
                          color: isDark
                              ? GVColors.neutral400
                              : GVColors.textSecondary,
                        ),
                      ),
                      Text(
                        item.amountLabel,
                        style: (item.isBold
                                ? GVTypography.bodyMedium
                                : GVTypography.bodySmall)
                            .copyWith(
                          fontWeight:
                              item.isBold ? FontWeight.w700 : FontWeight.w500,
                          color: textCol,
                        ),
                      ),
                    ],
                  ),
                );
              }),

              const Padding(
                padding: EdgeInsets.symmetric(vertical: GVSpacing.sm),
                child: Divider(color: GVColors.divider),
              ),

              // Total / Estimated Fare
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    totalTitle,
                    style: GVTypography.labelLarge.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? GVColors.white : GVColors.textPrimary,
                    ),
                  ),
                  Text(
                    totalLabel,
                    style: GVTypography.headlineSmall.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isDark ? GVColors.white : GVColors.textPrimary,
                    ),
                  ),
                ],
              ),
              if (rangeLabel != null) ...[
                const SizedBox(height: 2),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    rangeLabel!,
                    style: GVTypography.caption.copyWith(
                      color: isDark
                          ? GVColors.neutral400
                          : GVColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Notice container if provided
        if (noticeText != null) ...[
          const SizedBox(height: GVSpacing.md),
          Container(
            padding: const EdgeInsets.all(GVSpacing.md),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF0F291E)
                  : const Color(0xFFE8F5E9),
              borderRadius: GVBorderRadius.cardRadius,
              border: Border.all(
                color: isDark
                    ? const Color(0xFF1E4632)
                    : const Color(0xFFC8E6C9),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  color: GVColors.brandGreen,
                  size: 20,
                ),
                const SizedBox(width: GVSpacing.sm),
                Expanded(
                  child: Text(
                    noticeText!,
                    style: GVTypography.bodySmall.copyWith(
                      color: isDark
                          ? const Color(0xFFA7F432)
                          : const Color(0xFF1B5E20),
                      height: 1.35,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],

        // Promo Code Section
        if (onApplyPromo != null) ...[
          const SizedBox(height: GVSpacing.lg),
          Text(
            'Apply promo code',
            style: GVTypography.labelLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? GVColors.white : GVColors.textPrimary,
            ),
          ),
          const SizedBox(height: GVSpacing.xs),
          if (promoCode != null && promoCode!.isNotEmpty) ...[
            // Active Promo Display
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: GVSpacing.md,
                vertical: GVSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF132A1C)
                    : const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: GVColors.brandGreen),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.local_offer_rounded,
                    color: GVColors.brandGreen,
                    size: 18,
                  ),
                  const SizedBox(width: GVSpacing.sm),
                  Text(
                    promoCode!,
                    style: GVTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isDark ? GVColors.white : GVColors.textPrimary,
                    ),
                  ),
                  if (promoDiscountLabel != null) ...[
                    const SizedBox(width: GVSpacing.xs),
                    Text(
                      '($promoDiscountLabel applied)',
                      style: GVTypography.caption.copyWith(
                        color: GVColors.brandGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (onRemovePromo != null)
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      color: isDark ? GVColors.neutral400 : GVColors.neutral600,
                      onPressed: onRemovePromo,
                      tooltip: 'Remove promo',
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                ],
              ),
            ),
          ] else ...[
            // Input Row
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48,
                    child: TextField(
                      controller: promoController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        hintText: 'Enter promo code',
                        hintStyle: GVTypography.bodyMedium.copyWith(
                          color: isDark
                              ? GVColors.neutral500
                              : GVColors.textDisabled,
                        ),
                        filled: true,
                        fillColor: isDark
                            ? const Color(0xFF1A221E)
                            : GVColors.softBackground,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: GVSpacing.md,
                          vertical: GVSpacing.sm,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isDark
                                ? const Color(0xFF2E3D35)
                                : GVColors.border,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide(
                            color: isDark
                                ? const Color(0xFF2E3D35)
                                : GVColors.border,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: const BorderSide(
                            color: GVColors.brandGreen,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: GVSpacing.sm),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: isApplyingPromo
                        ? null
                        : () {
                            final code = promoController?.text.trim() ?? '';
                            if (code.isNotEmpty) {
                              onApplyPromo!(code);
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark
                          ? const Color(0xFF243029)
                          : const Color(0xFFE8F5E9),
                      foregroundColor: GVColors.brandGreen,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: GVSpacing.lg,
                      ),
                    ),
                    child: isApplyingPromo
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                GVColors.brandGreen,
                              ),
                            ),
                          )
                        : const Text(
                            'Apply',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            if (promoError != null) ...[
              const SizedBox(height: 4),
              Text(
                promoError!,
                style: GVTypography.caption.copyWith(color: GVColors.error),
              ),
            ],
          ],
        ],
      ],
    );
  }
}

