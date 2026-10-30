import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../application/wallet_notifier.dart';

/// Screen W01: Go-Volts Customer Wallet Home.
class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(walletNotifierProvider);
    final wallet = state.wallet;
    final loyalty = state.loyalty;

    return Scaffold(
      backgroundColor: GVColors.softBackground,
      appBar: const GVTopBar(title: 'My Wallet'),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () =>
              ref.read(walletNotifierProvider.notifier).loadWallet(),
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

              // Quick feature tabs (Rewards & Coupons)
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(GVBorderRadius.md),
                      onTap: () => context.push(AppRoutes.walletRewards),
                      child: Container(
                        padding: const EdgeInsets.all(GVSpacing.md),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(GVBorderRadius.md),
                          boxShadow: GVShadows.card,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.card_giftcard,
                                color: GVColors.brandGreen, size: 28),
                            const SizedBox(height: GVSpacing.xs),
                            Text('Eco-Rewards', style: GVTypography.h3),
                            Text('Convert points to credit',
                                style: GVTypography.caption),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: GVSpacing.md),
                  Expanded(
                    child: InkWell(
                      borderRadius: BorderRadius.circular(GVBorderRadius.md),
                      onTap: () => context.push(AppRoutes.walletRewards),
                      child: Container(
                        padding: const EdgeInsets.all(GVSpacing.md),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              BorderRadius.circular(GVBorderRadius.md),
                          boxShadow: GVShadows.card,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.local_offer_outlined,
                                color: GVColors.deepGreen, size: 28),
                            const SizedBox(height: GVSpacing.xs),
                            Text('Coupons & Promos', style: GVTypography.h3),
                            Text('${state.coupons.length} Active vouchers',
                                style: GVTypography.caption),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: GVSpacing.lg),

              // Transaction History Section
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text('Recent Transactions', style: GVTypography.h3),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text('View All'),
                  ),
                ],
              ),
              const SizedBox(height: GVSpacing.xs),

              if (state.transactions.isEmpty)
                Container(
                  padding: const EdgeInsets.all(GVSpacing.xl),
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      const Icon(Icons.receipt_long_outlined,
                          size: 48, color: GVColors.textSecondary),
                      const SizedBox(height: GVSpacing.sm),
                      Text('No transactions yet',
                          style: GVTypography.bodyMedium),
                      Text('Your top-ups and ride payments will appear here.',
                          style: GVTypography.caption),
                    ],
                  ),
                )
              else
                ...state.transactions.map(
                  (tx) => Container(
                    margin: const EdgeInsets.only(bottom: GVSpacing.sm),
                    padding: const EdgeInsets.all(GVSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(GVBorderRadius.md),
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
            ],
          ),
        ),
      ),
    );
  }
}
