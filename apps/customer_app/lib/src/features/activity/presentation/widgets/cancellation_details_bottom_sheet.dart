import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import '../../domain/activity_item.dart';

/// Modal bottom sheet showing cancellation reason and refund policy details.
class CancellationDetailsBottomSheet extends StatelessWidget {
  const CancellationDetailsBottomSheet({
    super.key,
    required this.item,
  });

  final ActivityItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(GVSpacing.lg),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.cancel_outlined, color: GVColors.error, size: 24),
                      const SizedBox(width: GVSpacing.xs),
                      Expanded(
                        child: Text(
                          'Trip Cancellation Details',
                          style: GVTypography.h3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          const SizedBox(height: GVSpacing.sm),
          Container(
            padding: const EdgeInsets.all(GVSpacing.md),
            decoration: BoxDecoration(
              color: GVColors.softBackground,
              borderRadius: BorderRadius.circular(GVBorderRadius.md),
              border: Border.all(color: GVColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Booking Ref: ${item.reference}',
                        style: GVTypography.bodySmallMedium
                            .copyWith(color: GVColors.textSecondary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      item.formattedFare,
                      style: GVTypography.h3.copyWith(color: GVColors.deepGreen),
                    ),
                  ],
                ),
                const SizedBox(height: GVSpacing.xs),
                Text(
                  item.title,
                  style: GVTypography.bodyMedium
                      .copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '${item.pickupAddress} → ${item.dropoffAddress}',
                  style: GVTypography.caption
                      .copyWith(color: GVColors.textSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(height: GVSpacing.md),
          Text('Reason for Cancellation', style: GVTypography.bodySmallMedium),
          const SizedBox(height: 4),
          Text(
            item.cancellationReason ?? 'Booking cancelled by user request.',
            style: GVTypography.bodyMedium,
          ),
          const SizedBox(height: GVSpacing.md),
          Text('Refund & Credit Status', style: GVTypography.bodySmallMedium),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.all(GVSpacing.sm),
            decoration: BoxDecoration(
              color: GVColors.statusActiveBg,
              borderRadius: BorderRadius.circular(GVBorderRadius.sm),
            ),
            child: Row(
              children: [
                const Icon(Icons.account_balance_wallet,
                    color: GVColors.brandGreen, size: 20),
                const SizedBox(width: GVSpacing.xs),
                Expanded(
                  child: Text(
                    item.refundStatus ??
                        'Full fare credited back to your Go-Volts Wallet.',
                    style: GVTypography.bodySmallMedium
                        .copyWith(color: GVColors.deepGreen),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: GVSpacing.lg),
          GVPrimaryButton(
            label: 'Close',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      ),
    );
  }
}
