import 'package:flutter/material.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_typography.dart';
import '../../foundation/gv_spacing.dart';
import '../../foundation/gv_border_radius.dart';

/// Rich promotional campaign banner used on the Home Dashboard.
/// Matches Screen 11 (Discount) and Screen 13 (Referral/Points).
class GVCampaignBanner extends StatelessWidget {
  const GVCampaignBanner({
    super.key,
    required this.title,
    this.subtitle,
    this.promoCode,
    this.ctaText = 'Learn more',
    this.onCtaTap,
    this.bannerType = 'discount',
    this.illustration,
  });

  final String title;
  final String? subtitle;
  final String? promoCode;
  final String ctaText;
  final VoidCallback? onCtaTap;
  final String bannerType;
  final Widget? illustration;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isReferral = bannerType == 'referral';

    // Gradients matching Screens 11 and 13
    final gradient = isReferral
        ? (isDark
            ? const LinearGradient(
                colors: [Color(0xFF1E3A2B), Color(0xFF162E22)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ))
        : (isDark
            ? const LinearGradient(
                colors: [Color(0xFF3E2D1E), Color(0xFF281E15)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : const LinearGradient(
                colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ));

    final titleColor = isDark
        ? Colors.white
        : (isReferral ? const Color(0xFF1B5E20) : const Color(0xFFE65100));

    final subColor = isDark
        ? GVColors.neutral300
        : (isReferral ? const Color(0xFF2E7D32) : const Color(0xFFBF360C));

    return Container(
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: GVBorderRadius.cardRadius,
        border: Border.all(
          color: isDark ? const Color(0xFF2E3D35) : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: GVSpacing.md,
        vertical: GVSpacing.md,
      ),
      child: Row(
        children: [
          // Left Content: Title, subtitle/promo code, CTA button
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: GVTypography.h3.copyWith(
                    color: titleColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                if (promoCode != null && promoCode!.isNotEmpty)
                  Text(
                    'Use code $promoCode',
                    style: GVTypography.caption.copyWith(
                      color: subColor,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else if (subtitle != null && subtitle!.isNotEmpty)
                  Text(
                    subtitle!,
                    style: GVTypography.caption.copyWith(
                      color: subColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                const SizedBox(height: GVSpacing.sm),
                InkWell(
                  onTap: onCtaTap,
                  borderRadius: BorderRadius.circular(GVBorderRadius.full),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white : GVColors.nearBlack,
                      borderRadius: BorderRadius.circular(GVBorderRadius.full),
                    ),
                    child: Text(
                      ctaText,
                      style: GVTypography.caption.copyWith(
                        color: isDark ? GVColors.nearBlack : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Right Illustration Graphic
          Expanded(
            flex: 2,
            child: illustration ??
                Icon(
                  isReferral ? Icons.card_giftcard_rounded : Icons.two_wheeler_rounded,
                  size: 58,
                  color: isDark
                      ? GVColors.brandGreen.withValues(alpha: 0.8)
                      : (isReferral ? const Color(0xFF2E7D32) : const Color(0xFFE65100)),
                ),
          ),
        ],
      ),
    );
  }
}

