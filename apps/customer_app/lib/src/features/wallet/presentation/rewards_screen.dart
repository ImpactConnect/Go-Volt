import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/auth_notifier.dart';
import '../application/wallet_notifier.dart';

/// Screen W05/W06/W07: Go-Volts Eco-Points, Loyalty Redemption, Referrals & Coupons.
/// Aligned with Master Tech Spec v1.5 §5.9, §8.6 and Phase 4.
class RewardsScreen extends ConsumerStatefulWidget {
  const RewardsScreen({super.key});

  @override
  ConsumerState<RewardsScreen> createState() => _RewardsScreenState();
}

class _RewardsScreenState extends ConsumerState<RewardsScreen> {
  int? _selectedPointsToRedeem;

  void _handleRedeem(int maxPoints, LoyaltyRewardDto? loyalty) async {
    final minPoints = loyalty?.minRedemptionPoints ?? 200;
    final maxThreshold = loyalty?.maxRedemptionPoints ?? 10000;

    if (maxPoints < minPoints) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Minimum points for wallet redemption is $minPoints Eco-Points.'),
        ),
      );
      return;
    }

    final targetCap = maxPoints > maxThreshold ? maxThreshold : maxPoints;
    final selected = _selectedPointsToRedeem ?? minPoints;
    final points = selected.clamp(minPoints, targetCap);
    final ok = await ref
        .read(walletNotifierProvider.notifier)
        .redeemLoyaltyPoints(points);

    if (mounted) {
      if (ok) {
        final creditNaira = loyalty?.conversionRule.calculateCreditNaira(points) ?? (points / (loyalty?.conversionRatePointsPerNaira ?? 10));
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

  void _shareInvite(String referralCode) {
    final message =
        'Join me on Go-Volts for zero-emission electric rides in Lagos! Use my invite code "$referralCode" for ₦500 off your first trip: https://govolts.ng/invite/$referralCode';
    Clipboard.setData(ClipboardData(text: message));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Invite link copied! Share with friends on WhatsApp or SMS.'),
        backgroundColor: GVColors.brandGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(walletNotifierProvider);
    final profile = ref.watch(authNotifierProvider).profile;
    final loyalty = state.loyalty;
    final points = loyalty?.pointsBalance ?? 0;
    final conversionRate = loyalty?.conversionRatePointsPerNaira ?? 10;

    // Unique user referral code (falls back to deterministic user code, never generic static string)
    final referralCode = loyalty?.referralCode.isNotEmpty == true && loyalty?.referralCode != 'VOLT-LAGOS'
        ? loyalty!.referralCode
        : (profile != null
            ? 'VOLT-${profile.fullName.replaceAll(RegExp(r'[^a-zA-Z]'), '').toUpperCase().padRight(3, 'X').substring(0, 3)}${(profile.id.hashCode.abs() % 9000 + 1000)}'
            : (loyalty?.referralCode ?? 'VOLT-USER01'));
    final referredFriends = loyalty?.referredFriends ?? const [];
    final minRedemptionThreshold = loyalty?.minRedemptionPoints ?? 200;

    final configuredPresets = loyalty?.redemptionPresets ?? const [200, 500, 1000, 2500];
    final redemptionPresets = [
      ...configuredPresets,
      if (points > (configuredPresets.isNotEmpty ? configuredPresets.last : 2500)) points,
    ];
    final selectedPoints = _selectedPointsToRedeem ??
        (redemptionPresets.contains(1000)
            ? 1000
            : (redemptionPresets.isNotEmpty ? redemptionPresets.first : 200));

    return Scaffold(
      backgroundColor: GVColors.softBackground,
      appBar: const GVTopBar(title: 'Rewards & Eco-Points'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(GVSpacing.md),
          children: [
            // Compact & Modern Eco-Points Card (W05)
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F3120), Color(0xFF091C13)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(GVBorderRadius.lg),
                border: Border.all(color: const Color(0xFF1E4D34), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Top Row: Tier Tag & Level Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: GVColors.brandGreen.withValues(alpha: 0.15),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.eco_rounded,
                                  color: GVColors.brandGreen, size: 16),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                loyalty?.tierName ?? 'Starter (Level 1)',
                                style: GVTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                        ),
                        child: Text(
                          points >= 2500 ? 'Level 3' : (points >= 500 ? 'Level 2' : 'Level 1'),
                          style: GVTypography.caption.copyWith(
                            color: GVColors.brandGreen,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: GVSpacing.sm),

                  // Points & Wallet Value Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$points',
                            style: const TextStyle(
                              fontSize: 34,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1.0,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'pts',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white.withValues(alpha: 0.6),
                            ),
                          ),
                        ],
                      ),
                      Flexible(
                        child: Text(
                          '≈ ₦${(loyalty?.conversionRule.calculateCreditNaira(selectedPoints) ?? (selectedPoints / conversionRate)).toStringAsFixed(0)} value',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: GVColors.brandGreen,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Slim Tier Progress
                  ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: points == 0 ? 0.0 : (loyalty?.tierProgressFraction ?? 0.0),
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(GVColors.brandGreen),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          points == 0
                              ? '500 pts to Eco Cruiser (Level 2)'
                              : '${loyalty?.pointsToNextTier ?? 500} pts to ${loyalty?.nextTierName ?? "Next Tier"}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withValues(alpha: 0.6),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${((points == 0 ? 0.0 : (loyalty?.tierProgressFraction ?? 0.0)) * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 11,
                          color: GVColors.brandGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: GVSpacing.sm),

                  // Preset Selection Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'Select Redemption Amount:',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Wallet Value: ₦${(loyalty?.conversionRule.calculateCreditNaira(selectedPoints) ?? (selectedPoints / conversionRate)).toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: GVColors.brandGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Compact High-Contrast Preset Segmented Buttons (Wrap avoids overflow)
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: redemptionPresets.map((preset) {
                      final isSelected = selectedPoints == preset;
                      final nairaVal = (loyalty?.conversionRule.calculateCreditNaira(preset) ?? (preset / conversionRate)).toStringAsFixed(0);

                      return InkWell(
                        onTap: () {
                          setState(() => _selectedPointsToRedeem = preset);
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? GVColors.brandGreen
                                : const Color(0xFF142E20),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? GVColors.brandGreen
                                  : const Color(0xFF234B35),
                              width: 1.2,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$preset pts',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                  color: isSelected
                                      ? const Color(0xFF092415)
                                      : Colors.white,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '(₦$nairaVal)',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected
                                      ? const Color(0xFF0F3B22)
                                      : GVColors.brandGreen,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: GVSpacing.md),

                  // Full-Width Clean Conversion Action
                  SizedBox(
                    height: 42,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: points >= minRedemptionThreshold
                            ? GVColors.brandGreen
                            : Colors.white.withValues(alpha: 0.1),
                        foregroundColor: points >= minRedemptionThreshold
                            ? const Color(0xFF092415)
                            : Colors.white38,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: points >= minRedemptionThreshold
                          ? () => _handleRedeem(points, loyalty)
                          : null,
                      child: Text(
                        points >= minRedemptionThreshold
                            ? 'Redeem ${selectedPoints > points ? points : selectedPoints} pts'
                            : 'Min. $minRedemptionThreshold pts required to convert',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                          color: points >= minRedemptionThreshold
                              ? const Color(0xFF092415)
                              : Colors.white38,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.lg),

            // How to Earn Eco-Points Guide
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
                      const Icon(Icons.bolt, color: GVColors.deepGreen),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'How to Earn Eco-Points',
                          style: GVTypography.h3,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: GVSpacing.sm),
                  _buildEarningItem(
                    icon: Icons.electric_bike,
                    title: 'Zero-Emission EV Ride',
                    pointsLabel: '+15 pts',
                    description: 'Every completed electric bike or car ride across Lagos.',
                  ),
                  const Divider(height: 16),
                  _buildEarningItem(
                    icon: Icons.schedule,
                    title: 'Off-Peak Green Travel (11am-3pm)',
                    pointsLabel: '+25 pts',
                    description: 'Travel during low grid demand hours for bonus rewards.',
                  ),
                  const Divider(height: 16),
                  _buildEarningItem(
                    icon: Icons.school,
                    title: 'Weekly Scheduled Commute',
                    pointsLabel: '+100 pts',
                    description: 'Complete 5 scheduled trips within a weekly billing period.',
                  ),
                  const Divider(height: 16),
                  _buildEarningItem(
                    icon: Icons.battery_charging_full,
                    title: 'Solar Battery Swap Kiosk Visit',
                    pointsLabel: '+20 pts',
                    description: 'Bonus points when your rider swaps at an authorized kiosk.',
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.lg),

            // Referral Card & Multi-Platform Sharing (W06)
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

                  // 3-Step Milestone Graphic
                  Container(
                    padding: const EdgeInsets.all(GVSpacing.sm),
                    decoration: BoxDecoration(
                      color: GVColors.softBackground,
                      borderRadius: BorderRadius.circular(GVBorderRadius.sm),
                    ),
                    child: Row(
                      children: [
                        _buildStepItem('1', 'Share Code'),
                        const Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
                        _buildStepItem('2', 'Friend Rides'),
                        const Icon(Icons.arrow_forward, size: 14, color: Colors.grey),
                        _buildStepItem('3', 'Both Earn ₦500'),
                      ],
                    ),
                  ),
                  const SizedBox(height: GVSpacing.md),

                  // Referral Code & Copy Box
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: GVSpacing.md, vertical: GVSpacing.sm),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(GVBorderRadius.sm),
                      border: Border.all(color: GVColors.border),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            referralCode,
                            style: GVTypography.h3.copyWith(
                              letterSpacing: 2,
                              color: GVColors.deepGreen,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(),
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
                            const SizedBox(width: 8),
                            IconButton(
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(),
                              icon: const Icon(Icons.share,
                                  color: GVColors.deepGreen, size: 20),
                              onPressed: () => _shareInvite(referralCode),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(),
                              icon: const Icon(Icons.autorenew,
                                  color: GVColors.textSecondary, size: 20),
                              tooltip: 'Generate new unique code',
                              onPressed: () async {
                                final profile = ref.read(authNotifierProvider).profile;
                                if (profile != null) {
                                  final newCode = await ref
                                      .read(walletNotifierProvider.notifier)
                                      .generateUniqueReferralCode(
                                        userId: profile.id,
                                        userName: profile.fullName,
                                      );
                                  if (context.mounted && newCode != null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Generated unique referral code: $newCode'),
                                        backgroundColor: GVColors.brandGreen,
                                      ),
                                    );
                                  }
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: GVSpacing.sm),

                  // Share Action Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GVColors.brandGreen,
                        foregroundColor: GVColors.deepGreen,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => _shareInvite(referralCode),
                      icon: const Icon(Icons.send_rounded, size: 18),
                      label: const Text('Share Invite Link', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ),

                  const SizedBox(height: GVSpacing.md),
                  Text(
                    '${loyalty?.referralCount ?? 0} friends joined • ₦${loyalty?.referralEarningsNaira.toStringAsFixed(0) ?? '0'} earned so far',
                    style: GVTypography.caption
                        .copyWith(color: GVColors.textSecondary, fontWeight: FontWeight.bold),
                  ),

                  if (referredFriends.isNotEmpty) ...[
                    const Divider(height: 24),
                    Text('Referred Friends Activity', style: GVTypography.bodySmallMedium),
                    const SizedBox(height: 8),
                    ...referredFriends.map((friend) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      friend.name,
                                      style: GVTypography.bodySmall.copyWith(fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    Text(
                                      friend.status,
                                      style: GVTypography.caption.copyWith(color: GVColors.textSecondary, fontSize: 11),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: friend.status.contains('Completed')
                                      ? GVColors.statusActiveBg
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  friend.status.contains('Completed') ? '+₦${friend.rewardAmountNaira.toStringAsFixed(0)}' : 'Pending',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: friend.status.contains('Completed') ? GVColors.brandGreen : Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.lg),

            // Promotional Coupons (W07)
            Text('Available Vouchers & Coupons', style: GVTypography.h3),
            const SizedBox(height: GVSpacing.sm),

            if (state.coupons.isEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: GVSpacing.sm),
                padding: const EdgeInsets.all(GVSpacing.lg),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  boxShadow: GVShadows.card,
                ),
                alignment: Alignment.center,
                child: Column(
                  children: [
                    const Icon(Icons.confirmation_number_outlined, size: 36, color: Colors.grey),
                    const SizedBox(height: 8),
                    Text('No Active Vouchers', style: GVTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      'Promotional vouchers created by Go-Volts administrators will appear here.',
                      textAlign: TextAlign.center,
                      style: GVTypography.caption.copyWith(color: GVColors.textSecondary),
                    ),
                  ],
                ),
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

  Widget _buildStepItem(String number, String label) {
    return Expanded(
      child: Column(
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: GVColors.brandGreen,
            child: Text(number, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: GVColors.deepGreen)),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildEarningItem({
    required IconData icon,
    required String title,
    required String pointsLabel,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: GVColors.statusActiveBg,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, color: GVColors.brandGreen, size: 18),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(title, style: GVTypography.bodySmall.copyWith(fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                  ),
                  Text(pointsLabel, style: const TextStyle(color: GVColors.brandGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 2),
              Text(description, style: GVTypography.caption.copyWith(color: GVColors.textSecondary, fontSize: 11)),
            ],
          ),
        ),
      ],
    );
  }
}
