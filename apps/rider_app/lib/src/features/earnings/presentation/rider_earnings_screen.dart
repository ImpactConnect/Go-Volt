import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../application/rider_earnings_notifier.dart';
import '../domain/rider_earnings_state.dart';

/// Screen RD19 & RD20: Rider Earnings Ledger & Weekly Settlement Breakdown.
class RiderEarningsScreen extends ConsumerWidget {
  const RiderEarningsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(riderEarningsNotifierProvider);
    final currencyFormatter = NumberFormat.currency(locale: 'en_NG', symbol: '₦', decimalDigits: 2);
    final compactFormatter = NumberFormat.currency(locale: 'en_NG', symbol: '₦', decimalDigits: 0);

    return Scaffold(
      backgroundColor: GVColors.darkBg,
      appBar: AppBar(
        title: const Text('Earnings & Payouts'),
        backgroundColor: GVColors.darkBg,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Withdrawal Info',
            icon: const Icon(Icons.info_outline, color: GVColors.brandGreen),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Weekly payouts settle every Tuesday at 08:00 AM via Paystack.'),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(GVSpacing.md),
          children: [
            // Payout Summary Card
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [GVColors.deepGreen, Color(0xFF133B26)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                boxShadow: GVShadows.elevated,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'This Week\'s Payout',
                          style: GVTypography.caption.copyWith(color: Colors.white70),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const GVStatusChip(label: 'SETTLES TUESDAY', status: GVStatusType.active),
                    ],
                  ),
                  const SizedBox(height: GVSpacing.xs),
                  Text(
                    currencyFormatter.format(state.settledWeekKobo / 100),
                    style: GVTypography.h1.copyWith(
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: GVSpacing.xs),
                  Text(
                    'Direct transfer to ${state.bankName} (${state.maskedAccountNumber})',
                    style: GVTypography.caption.copyWith(color: Colors.white70),
                  ),
                  const Divider(color: Colors.white24, height: GVSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildMiniCol('Gross Fare', compactFormatter.format(state.grossWeekKobo / 100)),
                      _buildMiniCol('Platform (20%)', '-${compactFormatter.format(state.commissionWeekKobo / 100)}'),
                      _buildMiniCol('Tips (100%)', '+${compactFormatter.format(state.tipsWeekKobo / 100)}'),
                    ],
                  ),
                  const SizedBox(height: GVSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: GVColors.brandGreen,
                        side: const BorderSide(color: GVColors.brandGreen),
                        backgroundColor: const Color(0x1A00C853),
                      ),
                      icon: state.isWithdrawing
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: GVColors.brandGreen),
                            )
                          : const Icon(Icons.flash_on, size: 16),
                      label: Text(state.isWithdrawing ? 'Processing Payout...' : 'Request Instant Payout'),
                      onPressed: state.isWithdrawing || state.settledWeekKobo <= 0
                          ? null
                          : () => _showInstantPayoutDialog(context, ref, state),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF2A3630)),
                      backgroundColor: const Color(0xFF1C2420),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.analytics_outlined, color: GVColors.brandGreen, size: 18),
                    label: const Text('Breakdown', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () => context.push('/earnings/details'),
                  ),
                ),
                const SizedBox(width: GVSpacing.sm),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Color(0xFF2A3630)),
                      backgroundColor: const Color(0xFF1C2420),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.account_balance_wallet, color: GVColors.brandGreen, size: 18),
                    label: const Text('Wallet', style: TextStyle(fontWeight: FontWeight.bold)),
                    onPressed: () => context.push('/wallet'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: GVSpacing.lg),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Recent Shift Ledgers',
                    style: GVTypography.h3.copyWith(color: Colors.white),
                  ),
                ),
                Text(
                  '${state.entries.length} items',
                  style: GVTypography.caption.copyWith(color: Colors.white54),
                ),
              ],
            ),
            const SizedBox(height: GVSpacing.xs),
            for (final entry in state.entries)
              _buildLedgerCard(context, ref, entry, compactFormatter),
          ],
        ),
      ),
    );
  }

  static Widget _buildMiniCol(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildLedgerCard(
    BuildContext context,
    WidgetRef ref,
    RiderLedgerEntryDto entry,
    NumberFormat formatter,
  ) {
    return InkWell(
      onTap: () => _showLedgerDetailDialog(context, ref, entry, formatter),
      borderRadius: BorderRadius.circular(GVBorderRadius.md),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(GVSpacing.md),
        decoration: BoxDecoration(
          color: const Color(0xFF1C2420),
          borderRadius: BorderRadius.circular(GVBorderRadius.md),
          border: Border.all(color: const Color(0xFF2A3630)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: entry.isPayout ? const Color(0xFF133B26) : const Color(0xFF232D28),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                entry.isPayout ? Icons.account_balance : Icons.receipt_long,
                color: entry.isPayout ? GVColors.brandGreen : Colors.white70,
                size: 20,
              ),
            ),
            const SizedBox(width: GVSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: GVTypography.bodyMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${entry.time} · Ref: ${entry.reference}',
                    style: GVTypography.caption.copyWith(color: Colors.white54),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatter.format(entry.netKobo / 100),
                  style: GVTypography.bodyMedium.copyWith(
                    color: entry.isPayout ? GVColors.brandGreen : Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!entry.isPayout)
                  Text(
                    'Gross: ${formatter.format(entry.grossKobo / 100)}',
                    style: GVTypography.caption.copyWith(color: Colors.white54),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showInstantPayoutDialog(
    BuildContext context,
    WidgetRef ref,
    RiderEarningsState state,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1C2420),
        title: const Text('Instant Payout Request', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available to withdraw: ₦${(state.settledWeekKobo / 100).toStringAsFixed(0)}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            Text(
              'Payout will be transferred immediately to your verified ${state.bankName} account (${state.maskedAccountNumber}).',
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: GVColors.brandGreen),
            onPressed: () async {
              Navigator.of(dialogCtx).pop();
              final success = await ref
                  .read(riderEarningsNotifierProvider.notifier)
                  .requestInstantWithdrawal(2000000); // Withdraw ₦20,000 demo
              if (context.mounted && success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Instant payout of ₦20,000 sent to Access Bank.'),
                    backgroundColor: GVColors.deepGreen,
                  ),
                );
              }
            },
            child: const Text('Confirm ₦20,000', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _showLedgerDetailDialog(
    BuildContext context,
    WidgetRef ref,
    RiderLedgerEntryDto entry,
    NumberFormat formatter,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1C2420),
        title: Text(entry.title, style: const TextStyle(color: Colors.white, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Reference: ${entry.reference}', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 4),
            Text('Time: ${entry.time}', style: const TextStyle(color: Colors.white70)),
            const Divider(color: Colors.white24, height: 16),
            Text('Gross Fare: ${formatter.format(entry.grossKobo / 100)}', style: const TextStyle(color: Colors.white70)),
            Text('Platform Fee (20%): -${formatter.format(entry.platformCommissionKobo / 100)}', style: const TextStyle(color: Colors.white70)),
            Text('Customer Tip (100%): +${formatter.format(entry.tipKobo / 100)}', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 8),
            Text('Rider Net Payout: ${formatter.format(entry.netKobo / 100)}',
                style: const TextStyle(color: GVColors.brandGreen, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              ref.read(riderEarningsNotifierProvider.notifier).submitDispute(entry.reference, 'Incorrect deductions');
              Navigator.of(dialogCtx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Dispute raised for ${entry.reference}. Support will follow up.'),
                ),
              );
            },
            child: const Text('Raise Dispute', style: TextStyle(color: Colors.amber)),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Close', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}
