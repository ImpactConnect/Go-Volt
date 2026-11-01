import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_notifier.dart';
import '../../../core/router/app_router.dart';
import '../application/wallet_notifier.dart';

/// Screen W01: Go-Volts Customer Wallet Home.
/// Complies with Master Tech Spec v1.5 §8.2, §8.3 & Screen W01-W04.
class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key});

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen> {
  String _selectedTxFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profile = ref.read(authNotifierProvider).profile;
      ref.read(walletNotifierProvider.notifier).loadWallet(
            userId: profile?.id,
            userName: profile?.fullName,
          );
    });
  }

  void _showTransactionDetails(WalletTransactionDto tx) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(GVSpacing.lg),
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
                      CircleAvatar(
                        backgroundColor: tx.isCredit
                            ? GVColors.statusActiveBg
                            : GVColors.softBackground,
                        child: Icon(
                          tx.isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                          color: tx.isCredit
                              ? GVColors.brandGreen
                              : GVColors.deepGreen,
                        ),
                      ),
                      const SizedBox(width: GVSpacing.sm),
                      Expanded(
                        child: Text(
                          'Transaction Details',
                          style: GVTypography.h3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const SizedBox(height: GVSpacing.md),
            Center(
              child: Column(
                children: [
                  Text(
                    '${tx.isCredit ? '+' : '-'}₦${tx.amount.toStringAsFixed(2)}',
                    style: GVTypography.h1.copyWith(
                      color: tx.isCredit ? GVColors.brandGreen : GVColors.deepGreen,
                      fontSize: 32,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: GVColors.statusActiveBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tx.status,
                      style: GVTypography.caption.copyWith(
                        color: GVColors.brandGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.lg),
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: GVColors.softBackground,
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                border: Border.all(color: GVColors.border),
              ),
              child: Column(
                children: [
                  _buildDetailRow('Description', tx.description),
                  const Divider(height: GVSpacing.md),
                  _buildDetailRow('Reference', tx.reference),
                  const Divider(height: GVSpacing.md),
                  _buildDetailRow(
                    'Date & Time',
                    '${tx.createdAt.day}/${tx.createdAt.month}/${tx.createdAt.year} • ${tx.createdAt.hour.toString().padLeft(2, '0')}:${tx.createdAt.minute.toString().padLeft(2, '0')}',
                  ),
                  const Divider(height: GVSpacing.md),
                  _buildDetailRow(
                    'Transaction Type',
                    tx.isCredit ? 'Credit / Top-Up' : 'Debit / Fare Payment',
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.lg),
            GVPrimaryButton(
              label: 'Close',
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: GVTypography.caption),
        Flexible(
          child: Text(
            value,
            style: GVTypography.bodySmallMedium
                .copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(walletNotifierProvider);
    final wallet = state.wallet;
    final loyalty = state.loyalty;

    final filteredTransactions = state.transactions.where((tx) {
      if (_selectedTxFilter == 'Top-Up') return tx.isCredit;
      if (_selectedTxFilter == 'Rides & Delivery') return !tx.isCredit;
      if (_selectedTxFilter == 'Redemptions') {
        return tx.description.toLowerCase().contains('eco-point') ||
            tx.description.toLowerCase().contains('reward');
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: GVColors.softBackground,
      appBar: const GVTopBar(title: 'My Wallet'),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            final profile = ref.read(authNotifierProvider).profile;
            await ref.read(walletNotifierProvider.notifier).loadWallet(
                  userId: profile?.id,
                  userName: profile?.fullName,
                );
          },
          color: GVColors.brandGreen,
          child: ListView(
            padding: const EdgeInsets.all(GVSpacing.md),
            children: [
              // W01 Hero Balance Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(GVSpacing.lg),
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
                            'Available Balance',
                            style: GVTypography.bodySmallMedium
                                .copyWith(color: Colors.white70),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'NGN (₦)',
                            style: GVTypography.caption
                                .copyWith(color: GVColors.accentGreen),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: GVSpacing.xs),
                    Text(
                      '₦${wallet.availableBalance.toStringAsFixed(2)}',
                      style: GVTypography.h1.copyWith(
                        fontSize: 32,
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: GVSpacing.md),

                    // Eco-Points & Quick Actions Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.eco,
                                  color: GVColors.brandGreen, size: 20),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  '${loyalty?.pointsBalance ?? 0} Eco-Points',
                                  style: GVTypography.bodySmallMedium
                                      .copyWith(color: GVColors.accentGreen),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: GVColors.brandGreen,
                            foregroundColor: GVColors.deepGreen,
                            elevation: 0,
                            minimumSize: const Size(80, 36),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          onPressed: () => context.push(AppRoutes.walletTopUp),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text(
                            'Top Up',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GVSpacing.md),

              // Policy Disclaimer Banner
              Container(
                padding: const EdgeInsets.all(GVSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.blueGrey.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(GVBorderRadius.sm),
                  border: Border.all(
                      color: Colors.blueGrey.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: GVColors.deepGreen, size: 20),
                    const SizedBox(width: GVSpacing.xs),
                    Expanded(
                      child: Text(
                        'Ride-wallet credit only — not withdrawable cash. Used for zero-emission rides, parcel delivery and scheduled commute plans.',
                        style: GVTypography.caption
                            .copyWith(color: GVColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GVSpacing.md),

              // 4 Quick Feature Tiles Grid
              Row(
                children: [
                  Expanded(
                    child: _buildActionTile(
                      icon: Icons.add_card,
                      iconColor: GVColors.brandGreen,
                      title: 'Top Up',
                      subtitle: 'Cards & Transfer',
                      onTap: () => context.push(AppRoutes.walletTopUp),
                    ),
                  ),
                  const SizedBox(width: GVSpacing.sm),
                  Expanded(
                    child: _buildActionTile(
                      icon: Icons.credit_card,
                      iconColor: GVColors.deepGreen,
                      title: 'Payment Cards',
                      subtitle: 'Saved Methods',
                      onTap: () => context.push(AppRoutes.walletPaymentMethods),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: GVSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _buildActionTile(
                      icon: Icons.card_giftcard,
                      iconColor: GVColors.brandGreen,
                      title: 'Eco-Rewards',
                      subtitle: 'Convert to credit',
                      onTap: () => context.push(AppRoutes.walletRewards),
                    ),
                  ),
                  const SizedBox(width: GVSpacing.sm),
                  Expanded(
                    child: _buildActionTile(
                      icon: Icons.local_offer_outlined,
                      iconColor: GVColors.deepGreen,
                      title: 'Coupons & Promos',
                      subtitle: '${state.coupons.length} Active vouchers',
                      onTap: () => context.push(AppRoutes.walletCoupons),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: GVSpacing.lg),

              // Transaction History Section Header & Filter Chips
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Recent Transactions',
                      style: GVTypography.h3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${filteredTransactions.length} records',
                    style: GVTypography.caption,
                  ),
                ],
              ),
              const SizedBox(height: GVSpacing.xs),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('All'),
                    const SizedBox(width: 6),
                    _buildFilterChip('Top-Up'),
                    const SizedBox(width: 6),
                    _buildFilterChip('Rides & Delivery'),
                    const SizedBox(width: 6),
                    _buildFilterChip('Redemptions'),
                  ],
                ),
              ),

              const SizedBox(height: GVSpacing.sm),

              if (filteredTransactions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(GVSpacing.xl),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      const Icon(Icons.receipt_long_outlined,
                          size: 48, color: GVColors.textSecondary),
                      const SizedBox(height: GVSpacing.sm),
                      Text('No transactions found',
                          style: GVTypography.bodyMedium),
                      Text('Your top-ups and ride payments will appear here.',
                          style: GVTypography.caption),
                    ],
                  ),
                )
              else
                ...filteredTransactions.map(
                  (tx) => InkWell(
                    borderRadius: BorderRadius.circular(GVBorderRadius.md),
                    onTap: () => _showTransactionDetails(tx),
                    child: Container(
                      margin: const EdgeInsets.only(bottom: GVSpacing.sm),
                      padding: const EdgeInsets.all(GVSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(GVBorderRadius.md),
                        boxShadow: GVShadows.card,
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: tx.isCredit
                                ? GVColors.statusActiveBg
                                : GVColors.softBackground,
                            child: Icon(
                              tx.isCredit
                                  ? Icons.arrow_downward
                                  : Icons.arrow_upward,
                              color: tx.isCredit
                                  ? GVColors.brandGreen
                                  : GVColors.deepGreen,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: GVSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(tx.description,
                                    style: GVTypography.bodySmallMedium,
                                    overflow: TextOverflow.ellipsis),
                                const SizedBox(height: 2),
                                Text(
                                  '${tx.createdAt.day}/${tx.createdAt.month}/${tx.createdAt.year} • Ref: ${tx.reference}',
                                  style: GVTypography.caption,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: GVSpacing.sm),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                '${tx.isCredit ? '+' : '-'}₦${tx.amount.toStringAsFixed(0)}',
                                style: GVTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: tx.isCredit
                                      ? GVColors.brandGreen
                                      : GVColors.nearBlack,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: GVColors.statusActiveBg,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  tx.status,
                                  style: GVTypography.caption.copyWith(
                                    color: GVColors.brandGreen,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(GVBorderRadius.md),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(GVSpacing.md),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(GVBorderRadius.md),
          boxShadow: GVShadows.card,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 26),
            const SizedBox(height: GVSpacing.xs),
            Text(title,
                style: GVTypography.bodyMedium
                    .copyWith(fontWeight: FontWeight.bold)),
            Text(subtitle, style: GVTypography.caption),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedTxFilter == label;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : GVColors.textPrimary,
        ),
      ),
      selected: isSelected,
      selectedColor: GVColors.deepGreen,
      backgroundColor: Colors.white,
      onSelected: (_) => setState(() => _selectedTxFilter = label),
    );
  }
}
