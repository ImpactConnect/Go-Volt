import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/wallet_notifier.dart';

/// Screen W05/W06/W07: Go-Volts Eco-Points, Loyalty Redemption, Referrals & Coupons.
class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen> {
  final int _selectedPointsToRedeem = 1000;

  void _handleRedeem(int maxPoints) async {
    if (maxPoints < 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Minimum points for wallet redemption is 500 Eco-Points.'),
        ),
      );
      return;
    }

    final points = _selectedPointsToRedeem.clamp(500, maxPoints);
    final ok = await ref
        .read(walletNotifierProvider.notifier)
        .redeemLoyaltyPoints(points);

    if (mounted) {
      if (ok) {
        final creditNaira = points / 10;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Successfully converted $points Eco-Points into ₦${creditNaira.toStringAsFixed(0)} wallet credit!'),
            backgroundColor: GVColors.brandGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to redeem points. Please try again later.'),
            backgroundColor: GVColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(walletNotifierProvider);
    final loyalty = state.loyalty;
    final points = loyalty?.pointsBalance ?? 0;
    final conversionRate = loyalty?.conversionRatePointsPerNaira ?? 10;
    final referralCode = loyalty?.referralCode ?? 'VOLT-LAGOS';

    return Scaffold(
      backgroundColor: GVColors.softBackground,
      appBar: const GVTopBar(title: 'Rewards & Eco-Points'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(GVSpacing.md),
          children: [
            // Eco-Points Balance Card (W05)
            Container(
              padding: const EdgeInsets.all(GVSpacing.lg),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [GVColors.deepGreen, Color(0xFF1B4D3E)],
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
                          loyalty?.tierName ?? 'Green Pioneer',
                          style: GVTypography.bodySmallMedium
                              .copyWith(color: GVColors.accentGreen),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Level 2',
                          style: GVTypography.caption
                              .copyWith(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: GVSpacing.xs),
                  Row(
                    children: [
                      const Icon(Icons.eco, color: GVColors.brandGreen, size: 36),
                      const SizedBox(width: GVSpacing.xs),
                      Text(
                        '$points',
                        style: GVTypography.h1.copyWith(
                          fontSize: 36,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'pts',
                        style: GVTypography.h3.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                  const SizedBox(height: GVSpacing.sm),
                  Text(
                    'Earn 15 Eco-Points for every zero-emission EV ride completed.',
                    style: GVTypography.caption.copyWith(color: Colors.white70),
                  ),
                  const Divider(color: Colors.white24, height: GVSpacing.lg),

                  // Conversion calculation
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: GVSpacing.sm,
                    runSpacing: GVSpacing.sm,
                    children: [
                      Text(
                        'Wallet Value: ₦${(points / conversionRate).toStringAsFixed(0)}',
                        style: GVTypography.bodyMedium
                            .copyWith(color: Colors.white),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GVColors.brandGreen,
                          foregroundColor: GVColors.deepGreen,
                        ),
                        onPressed: points >= 500
                            ? () => _handleRedeem(points)
                            : null,
                        child: const Text('Redeem 1,000 pts (₦100)'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.lg),

            // Referral Card (W06)
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                boxShadow: GVShadows.card,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.people_alt, color: GVColors.deepGreen),
                      const SizedBox(width: GVSpacing.xs),
                      Flexible(
                        child: Text('Invite Friends & Earn',
                            style: GVTypography.h3,
                            overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: GVSpacing.xs),
                  Text(
                    'Share your invite code with friends in Lagos. They get ₦500 off their first EV trip, and you earn ₦500 wallet credit.',
                    style: GVTypography.bodySmall
                        .copyWith(color: GVColors.textSecondary),
                  ),
                  const SizedBox(height: GVSpacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: GVSpacing.md, vertical: GVSpacing.sm),
                    decoration: BoxDecoration(
                      color: GVColors.softBackground,
                      borderRadius: BorderRadius.circular(GVBorderRadius.sm),
                      border: Border.all(color: GVColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          referralCode,
                          style: GVTypography.h3.copyWith(
                            letterSpacing: 2,
                            color: GVColors.deepGreen,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.copy,
                              color: GVColors.brandGreen, size: 20),
                          onPressed: () {
                            Clipboard.setData(ClipboardData(text: referralCode));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Referral code copied to clipboard!'),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: GVSpacing.xs),
                  Text(
                    '${loyalty?.referralCount ?? 0} friends joined • ₦${loyalty?.referralEarningsNaira.toStringAsFixed(0) ?? '0'} earned so far',
                    style: GVTypography.caption
                        .copyWith(color: GVColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.lg),

            // Promotional Coupons (W07)
            Text('Available Vouchers & Coupons', style: GVTypography.h3),
            const SizedBox(height: GVSpacing.sm),

            if (state.coupons.isEmpty)
              Container(
                padding: const EdgeInsets.all(GVSpacing.md),
                alignment: Alignment.center,
                child: Text('No active coupons right now.',
                    style: GVTypography.bodySmall),
              )
            else
              ...state.coupons.map(
                (coupon) => Container(
                  margin: const EdgeInsets.only(bottom: GVSpacing.sm),
                  padding: const EdgeInsets.all(GVSpacing.md),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(GVBorderRadius.md),
                    border: Border.all(
                      color: GVColors.brandGreen.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: GVShadows.card,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: GVColors.statusActiveBg,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.confirmation_number,
                            color: GVColors.brandGreen),
                      ),
                      const SizedBox(width: GVSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(coupon.title,
                                style: GVTypography.bodySmallMedium),
                            const SizedBox(height: 2),
                            Text(
                              'Code: ${coupon.code} • Min order ₦${coupon.minOrderAmountNaira.toStringAsFixed(0)}',
                              style: GVTypography.caption,
                            ),
                            Text(
                              'Valid until ${coupon.expiryDate.day}/${coupon.expiryDate.month}/${coupon.expiryDate.year}',
                              style: GVTypography.caption.copyWith(
                                color: GVColors.textSecondary,
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GVColors.deepGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: coupon.code));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Coupon ${coupon.code} copied! Applied automatically at checkout.'),
                            ),
                          );
                        },
                        child: const Text('Apply'),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
