import 'package:flutter/material.dart';
import '../../foundation/gv_border_radius.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_spacing.dart';
import '../../foundation/gv_typography.dart';
import '../buttons/gv_primary_button.dart';

/// Screen 15: Proof of Delivery card with celebratory badge, recipient details and digital signature.
class GVProofOfDeliveryCard extends StatelessWidget {
  const GVProofOfDeliveryCard({
    super.key,
    required this.recipientName,
    required this.deliveryAddress,
    required this.deliveredAtLabel,
    this.receivedByName,
    this.signatureWidget,
    required this.onViewReceipt,
  });

  final String recipientName;
  final String deliveryAddress;
  final String deliveredAtLabel;
  final String? receivedByName;
  final Widget? signatureWidget;
  final VoidCallback onViewReceipt;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark ? const Color(0xFF1A221E) : GVColors.white;
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Festive Celebratory Badge
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: GVColors.brandGreen.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: GVColors.brandGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check,
                color: GVColors.deepGreen,
                size: 36,
              ),
            ),
          ],
        ),
        const SizedBox(height: GVSpacing.md),

        Text(
          'Delivered successfully!',
          style: GVTypography.h2.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? GVColors.white : GVColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'Your parcel has been delivered.',
          style: GVTypography.bodyMedium.copyWith(
            color: isDark ? GVColors.neutral400 : GVColors.textSecondary,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: GVSpacing.lg),

        // Handover Proof Details Container
        Container(
          padding: const EdgeInsets.all(GVSpacing.md),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(GVBorderRadius.lg),
            border: Border.all(color: borderColor),
          ),
          child: Column(
            children: [
              _buildDetailItem(
                context,
                icon: Icons.location_on,
                iconColor: GVColors.brandGreen,
                title: 'Delivered to',
                value: '$recipientName\n$deliveryAddress',
              ),
              const Divider(height: GVSpacing.lg),
              _buildDetailItem(
                context,
                icon: Icons.access_time_rounded,
                iconColor: GVColors.deepGreen,
                title: 'Delivered at',
                value: deliveredAtLabel,
              ),
              const Divider(height: GVSpacing.lg),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.person_pin_rounded,
                        color: GVColors.deepGreen,
                        size: 20,
                      ),
                      const SizedBox(width: GVSpacing.sm),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Received by',
                            style: GVTypography.caption.copyWith(
                              color: isDark
                                  ? GVColors.neutral400
                                  : GVColors.textSecondary,
                            ),
                          ),
                          Text(
                            receivedByName ?? recipientName,
                            style: GVTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color:
                                  isDark ? GVColors.white : GVColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  // Digital Signature Graphic
                  signatureWidget ??
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF26332B)
                              : const Color(0xFFF0FDF4),
                          borderRadius: BorderRadius.circular(GVBorderRadius.sm),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF2E3D35)
                                : GVColors.brandGreen.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          'J. Doe',
                          style: TextStyle(
                            fontFamily: 'serif',
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: isDark
                                ? GVColors.brandGreen
                                : GVColors.deepGreen,
                          ),
                        ),
                      ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: GVSpacing.xl),

        // Primary Action
        GVPrimaryButton(
          label: 'View receipt',
          onPressed: onViewReceipt,
        ),
      ],
    );
  }

  Widget _buildDetailItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(width: GVSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GVTypography.caption.copyWith(
                  color: isDark ? GVColors.neutral400 : GVColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GVTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? GVColors.white : GVColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

