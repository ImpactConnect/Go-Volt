import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/scheduled_trips_notifier.dart';

/// Screen 36 (SP-22): Payment and Refund Details Screen
/// Displays trip billing details, receipt view/download, and refund request entry point.
class PaymentRefundDetailsScreen extends ConsumerWidget {
  const PaymentRefundDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scheduledTripsNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF131A16) : Colors.white;
    final textColor = isDark ? Colors.white : GVColors.textPrimary;
    final subtextColor = isDark ? GVColors.neutral400 : GVColors.textSecondary;
    final cardBg = isDark ? const Color(0xFF1C2420) : GVColors.neutral50;
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;

    final trip = state.selectedTrip ??
        (state.completedTrips.isNotEmpty
            ? state.completedTrips.first
            : (state.trips.isNotEmpty ? state.trips.first : null));

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Payment and refund details',
          style: GVTypography.h2.copyWith(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: textColor,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: GVSpacing.sm),

              // Trip header tag
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: GVColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.groups_rounded,
                      color: GVColors.primary,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        trip?.planTitle ?? 'School Run',
                        style: GVTypography.bodyLarge.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Mon, 6 Nov 2026',
                        style: GVTypography.caption.copyWith(
                          color: subtextColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: GVSpacing.lg),

              // Main Payment card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(GVSpacing.md),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(GVBorderRadius.card),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total amount',
                      style: GVTypography.caption.copyWith(
                        color: subtextColor,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              '₦2,500',
                              style: GVTypography.h1.copyWith(
                                color: textColor,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(Package)',
                              style: GVTypography.bodyMedium.copyWith(
                                color: subtextColor,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius:
                                BorderRadius.circular(GVBorderRadius.full),
                          ),
                          child: const Text(
                            'Paid',
                            style: TextStyle(
                              color: Color(0xFF2E7D32),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),

                    // Payment details rows
                    _buildDetailRow(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Payment method',
                      value: 'Go-Volts Wallet',
                      textColor: textColor,
                      subtextColor: subtextColor,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.tag_rounded,
                      label: 'Transaction ID',
                      value: 'GVD12345678',
                      textColor: textColor,
                      subtextColor: subtextColor,
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      icon: Icons.calendar_today_outlined,
                      label: 'Paid on',
                      value: '5 Nov 2026, 10:32 AM',
                      textColor: textColor,
                      subtextColor: subtextColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GVSpacing.xl),

              // Action tiles
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(GVBorderRadius.card),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    _buildActionTile(
                      icon: Icons.receipt_long_outlined,
                      title: 'View receipt',
                      textColor: textColor,
                      borderColor: borderColor,
                      onTap: () => _showReceiptBottomSheet(context),
                    ),
                    _buildActionTile(
                      icon: Icons.download_outlined,
                      title: 'Download receipt',
                      textColor: textColor,
                      borderColor: borderColor,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                                'Receipt receipt_GVD12345678.pdf saved to downloads.'),
                          ),
                        );
                      },
                    ),
                    _buildActionTile(
                      icon: Icons.assignment_return_outlined,
                      title: 'Request refund',
                      textColor: const Color(0xFFEF4444),
                      iconColor: const Color(0xFFEF4444),
                      borderColor: borderColor,
                      showDivider: false,
                      onTap: () => _showRefundRequestDialog(context),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GVSpacing.xxl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color textColor,
    required Color subtextColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: subtextColor),
        const SizedBox(width: 10),
        Text(
          label,
          style: GVTypography.bodyMedium.copyWith(color: subtextColor),
        ),
        const Spacer(),
        Text(
          value,
          style: GVTypography.bodyMedium.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required Color textColor,
    Color? iconColor,
    required Color borderColor,
    bool showDivider = true,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: GVSpacing.md,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: showDivider
                ? BorderSide(color: borderColor)
                : BorderSide.none,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: iconColor ?? textColor),
            const SizedBox(width: GVSpacing.md),
            Expanded(
              child: Text(
                title,
                style: GVTypography.bodyMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: GVColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  void _showReceiptBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(GVSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Receipt #GVD12345678',
                  style: GVTypography.h3.copyWith(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ],
            ),
            const Divider(),
            const SizedBox(height: 8),
            _receiptLine('Plan:', 'School Run (Bayero University)'),
            _receiptLine('Billing Model:', 'Weekly Package (10 trips)'),
            _receiptLine('Single Trip Allocation:', '₦2,500'),
            _receiptLine('Status:', 'Settled via Go-Volts Wallet'),
            _receiptLine('Date:', '5 Nov 2026, 10:32 AM'),
            const SizedBox(height: GVSpacing.xl),
            GVButton(
              text: 'Done',
              type: GVButtonType.primary,
              onPressed: () => Navigator.of(ctx).pop(),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _receiptLine(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: GVColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  void _showRefundRequestDialog(BuildContext context) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Request Refund'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Per Section 21 invariant policy, refunds for unused package trips or service issues are credited directly back to your Go-Volts Wallet upon review.',
              style: TextStyle(fontSize: 13, color: GVColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'Reason for refund...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Refund request submitted. You will be notified within 24 hours.'),
                ),
              );
            },
            child: const Text('Submit Request'),
          ),
        ],
      ),
    );
  }
}
