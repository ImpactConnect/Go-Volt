import 'package:flutter/material.dart';
import '../../foundation/gv_border_radius.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_spacing.dart';
import '../../foundation/gv_typography.dart';
import 'gv_fare_breakdown_card.dart';

/// Itemized digital trip receipt matching Screen 16.
///
/// Fully dynamic — takes driver details, route timestamps, fare breakdown lines,
/// payment method label, and action handlers (download, share, report issue).
class GVTripReceiptCard extends StatelessWidget {
  const GVTripReceiptCard({
    super.key,
    required this.tripReference,
    required this.formattedDate,
    required this.driverName,
    required this.driverVehicle,
    this.driverRating,
    this.driverTrips,
    this.driverAvatarUrl,
    required this.pickupAddress,
    required this.pickupTime,
    required this.destinationAddress,
    required this.destinationTime,
    required this.fareItems,
    required this.totalPaidLabel,
    required this.paymentMethodName,
    required this.paymentMethodAmount,
    this.onDownloadReceipt,
    this.onShareReceipt,
    this.onReportIssue,
  });

  final String tripReference;
  final String formattedDate;
  final String driverName;
  final String driverVehicle;
  final double? driverRating;
  final int? driverTrips;
  final String? driverAvatarUrl;
  final String pickupAddress;
  final String pickupTime;
  final String destinationAddress;
  final String destinationTime;
  final List<GVFareItem> fareItems;
  final String totalPaidLabel;
  final String paymentMethodName;
  final String paymentMethodAmount;
  final VoidCallback? onDownloadReceipt;
  final VoidCallback? onShareReceipt;
  final VoidCallback? onReportIssue;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A221E) : GVColors.white,
        borderRadius: GVBorderRadius.cardRadius,
        border: Border.all(
          color: isDark ? const Color(0xFF2E3D35) : GVColors.border,
        ),
      ),
      padding: const EdgeInsets.all(GVSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Logo & Receipt Meta
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: const BoxDecoration(
                      color: GVColors.brandGreen,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'gv',
                      style: TextStyle(
                        color: GVColors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'GO-VOLTS',
                    style: GVTypography.titleMedium.copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.8,
                      color: isDark ? GVColors.white : GVColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: GVSpacing.xs),
          Text(
            '$formattedDate | $tripReference',
            style: GVTypography.caption.copyWith(
              color: isDark ? GVColors.neutral400 : GVColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: GVSpacing.lg),

          // Driver Snippet
          Container(
            padding: const EdgeInsets.all(GVSpacing.md),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF131A16) : GVColors.softBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: GVColors.brandGreen.withValues(alpha: 0.2),
                  backgroundImage: driverAvatarUrl != null
                      ? NetworkImage(driverAvatarUrl!)
                      : null,
                  child: driverAvatarUrl == null
                      ? const Icon(Icons.person,
                          color: GVColors.brandGreen, size: 24)
                      : null,
                ),
                const SizedBox(width: GVSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        driverName,
                        style: GVTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: isDark ? GVColors.white : GVColors.textPrimary,
                        ),
                      ),
                      if (driverRating != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                size: 14, color: GVColors.warning),
                            const SizedBox(width: 2),
                            Text(
                              driverRating!.toStringAsFixed(1),
                              style: GVTypography.caption.copyWith(
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? GVColors.white
                                    : GVColors.textPrimary,
                              ),
                            ),
                            if (driverTrips != null) ...[
                              const SizedBox(width: 4),
                              Text(
                                '($driverTrips trips)',
                                style: GVTypography.caption.copyWith(
                                  color: isDark
                                      ? GVColors.neutral400
                                      : GVColors.textSecondary,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                      const SizedBox(height: 2),
                      Text(
                        driverVehicle,
                        style: GVTypography.caption.copyWith(
                          color: isDark
                              ? GVColors.neutral400
                              : GVColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: GVSpacing.lg),

          // Route Timestamps
          Text(
            'Trip details',
            style: GVTypography.labelLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? GVColors.white : GVColors.textPrimary,
            ),
          ),
          const SizedBox(height: GVSpacing.sm),
          _RoutePointRow(
            iconColor: GVColors.brandGreen,
            address: pickupAddress,
            time: pickupTime,
            isDark: isDark,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 7),
            child: Container(
              width: 2,
              height: 20,
              color: isDark ? GVColors.neutral700 : GVColors.neutral300,
            ),
          ),
          _RoutePointRow(
            iconColor: GVColors.error,
            address: destinationAddress,
            time: destinationTime,
            isDark: isDark,
          ),

          const SizedBox(height: GVSpacing.lg),
          const Divider(color: GVColors.divider),
          const SizedBox(height: GVSpacing.sm),

          // Itemized Fare Table
          Text(
            'Fare breakdown',
            style: GVTypography.labelLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? GVColors.white : GVColors.textPrimary,
            ),
          ),
          const SizedBox(height: GVSpacing.sm),
          ...fareItems.map((item) {
            final isDiscount = item.isDiscount;
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
                          item.isBold ? FontWeight.w700 : FontWeight.normal,
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
                      color: isDiscount
                          ? GVColors.brandGreen
                          : (isDark
                              ? GVColors.white
                              : GVColors.textPrimary),
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

          // Total Paid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total paid',
                style: GVTypography.labelLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? GVColors.white : GVColors.textPrimary,
                ),
              ),
              Text(
                totalPaidLabel,
                style: GVTypography.titleMedium.copyWith(
                  fontWeight: FontWeight.w900,
                  color: isDark ? GVColors.white : GVColors.textPrimary,
                ),
              ),
            ],
          ),

          const SizedBox(height: GVSpacing.lg),
          const Divider(color: GVColors.divider),
          const SizedBox(height: GVSpacing.sm),

          // Payment Method Summary
          Text(
            'Payment method',
            style: GVTypography.labelLarge.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? GVColors.white : GVColors.textPrimary,
            ),
          ),
          const SizedBox(height: GVSpacing.xs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.account_balance_wallet_rounded,
                    color: GVColors.brandGreen,
                    size: 20,
                  ),
                  const SizedBox(width: GVSpacing.sm),
                  Text(
                    paymentMethodName,
                    style: GVTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? GVColors.white : GVColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                paymentMethodAmount,
                style: GVTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? GVColors.white : GVColors.textPrimary,
                ),
              ),
            ],
          ),

          // Action Items (Download, Share, Report an Issue)
          if (onDownloadReceipt != null ||
              onShareReceipt != null ||
              onReportIssue != null) ...[
            const SizedBox(height: GVSpacing.lg),
            const Divider(color: GVColors.divider),
            if (onDownloadReceipt != null)
              _ReceiptActionTile(
                icon: Icons.file_download_outlined,
                title: 'Download receipt',
                onTap: onDownloadReceipt!,
                isDark: isDark,
              ),
            if (onShareReceipt != null)
              _ReceiptActionTile(
                icon: Icons.share_outlined,
                title: 'Share receipt',
                onTap: onShareReceipt!,
                isDark: isDark,
              ),
            if (onReportIssue != null)
              _ReceiptActionTile(
                icon: Icons.support_agent_rounded,
                title: 'Report an issue',
                onTap: onReportIssue!,
                isDark: isDark,
              ),
          ],
        ],
      ),
    );
  }
}

class _RoutePointRow extends StatelessWidget {
  const _RoutePointRow({
    required this.iconColor,
    required this.address,
    required this.time,
    required this.isDark,
  });

  final Color iconColor;
  final String address;
  final String time;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: iconColor,
          ),
        ),
        const SizedBox(width: GVSpacing.md),
        Expanded(
          child: Text(
            address,
            style: GVTypography.bodyMedium.copyWith(
              color: isDark ? GVColors.white : GVColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(width: GVSpacing.sm),
        Text(
          time,
          style: GVTypography.caption.copyWith(
            fontWeight: FontWeight.w600,
            color: isDark ? GVColors.neutral400 : GVColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ReceiptActionTile extends StatelessWidget {
  const _ReceiptActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.isDark,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: isDark ? GVColors.neutral300 : GVColors.neutral700,
            ),
            const SizedBox(width: GVSpacing.md),
            Expanded(
              child: Text(
                title,
                style: GVTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? GVColors.white : GVColors.textPrimary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark ? GVColors.neutral500 : GVColors.neutral400,
            ),
          ],
        ),
      ),
    );
  }
}

