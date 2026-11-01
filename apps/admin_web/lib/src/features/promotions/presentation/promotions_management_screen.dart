import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/admin_kpi_card.dart';
import '../../../core/widgets/admin_modal_dialog.dart';
import '../application/promotions_notifier.dart';
import '../domain/promotion_models.dart';

class PromotionsManagementScreen extends ConsumerStatefulWidget {
  const PromotionsManagementScreen({super.key});

  @override
  ConsumerState<PromotionsManagementScreen> createState() =>
      _PromotionsManagementScreenState();
}

class _PromotionsManagementScreenState
    extends ConsumerState<PromotionsManagementScreen> {
  final _dateFormat = DateFormat('yyyy-MM-dd');

  void _showCreateCouponModal(BuildContext context) {
    final codeController = TextEditingController();
    final discountValController = TextEditingController(text: '15');
    final minOrderController = TextEditingController(text: '1000');
    final maxDiscountController = TextEditingController(text: '2000');
    final usageLimitController = TextEditingController(text: '500');
    final descController = TextEditingController(text: 'Special customer reward');
    DiscountType selectedType = DiscountType.percentage;

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AdminModalDialog(
              title: 'Create Promo Voucher',
              icon: Icons.card_giftcard_outlined,
              primaryActionLabel: 'Create Voucher',
              onPrimaryAction: () {
                if (codeController.text.trim().isEmpty) return;
                final discountVal = double.tryParse(discountValController.text) ?? 15.0;
                final minOrderKobo = BigInt.from((double.tryParse(minOrderController.text) ?? 1000) * 100);
                final maxDiscount = maxDiscountController.text.isNotEmpty
                    ? BigInt.from((double.tryParse(maxDiscountController.text) ?? 2000) * 100)
                    : null;
                final usageLimit = int.tryParse(usageLimitController.text) ?? 500;

                ref.read(promotionsNotifierProvider.notifier).createCoupon(
                      code: codeController.text,
                      discountType: selectedType,
                      discountValue: selectedType == DiscountType.percentage
                          ? discountVal
                          : discountVal * 100, // convert fixed Naira to kobo
                      minOrderKobo: minOrderKobo,
                      maxDiscountKobo: maxDiscount,
                      usageLimit: usageLimit,
                      expiresAt: DateTime.now().add(const Duration(days: 30)),
                      description: descController.text,
                    );
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Voucher ${codeController.text.toUpperCase()} created successfully.')),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: codeController,
                    textCapitalization: TextCapitalization.characters,
                    decoration: const InputDecoration(
                      labelText: 'Coupon Code (e.g. VOLT50)',
                      filled: true,
                      fillColor: Color(0xFF14241B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<DiscountType>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(
                      labelText: 'Discount Calculation',
                      filled: true,
                      fillColor: Color(0xFF14241B),
                    ),
                    dropdownColor: const Color(0xFF14241B),
                    items: const [
                      DropdownMenuItem(
                        value: DiscountType.percentage,
                        child: Text('Percentage Discount (%)', style: TextStyle(color: Colors.white)),
                      ),
                      DropdownMenuItem(
                        value: DiscountType.fixedAmount,
                        child: Text('Fixed Naira Discount (₦)', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => selectedType = val);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: discountValController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            labelText: selectedType == DiscountType.percentage ? 'Percent (%)' : 'Amount (₦)',
                            filled: true,
                            fillColor: const Color(0xFF14241B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: minOrderController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Min Order (₦)',
                            filled: true,
                            fillColor: Color(0xFF14241B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: maxDiscountController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Max Cap (₦)',
                            filled: true,
                            fillColor: Color(0xFF14241B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: usageLimitController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Max Usage Limit',
                            filled: true,
                            fillColor: Color(0xFF14241B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Public Campaign Description',
                      filled: true,
                      fillColor: Color(0xFF14241B),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showEditLoyaltyModal(BuildContext context) {
    final current = ref.read(promotionsNotifierProvider).loyaltyConfig;
    final earnRateController = TextEditingController(text: current.pointsPerHundredNairaSpent.toString());
    final pointsReqController = TextEditingController(text: current.pointsRequired.toString());
    final creditNairaController = TextEditingController(text: (current.creditAmountKobo / 100).toStringAsFixed(0));
    final minThresholdController = TextEditingController(text: current.minRedemptionPoints.toString());
    final maxCapController = TextEditingController(text: current.maxRedemptionPoints.toString());
    final presetsController = TextEditingController(text: current.presetPoints.join(', '));

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AdminModalDialog(
          title: 'Configure Loyalty Economics & Thresholds',
          icon: Icons.tune,
          primaryActionLabel: 'Save Loyalty Rules',
          onPrimaryAction: () {
            final earnRate = int.tryParse(earnRateController.text) ?? 5;
            final pointsReq = int.tryParse(pointsReqController.text) ?? 10;
            final creditNaira = double.tryParse(creditNairaController.text) ?? 1.0;
            final creditKobo = (creditNaira * 100).round();
            final minPoints = int.tryParse(minThresholdController.text) ?? 200;
            final maxPoints = int.tryParse(maxCapController.text) ?? 10000;
            final parsedPresets = presetsController.text
                .split(',')
                .map((s) => int.tryParse(s.trim()))
                .whereType<int>()
                .toList();

            ref.read(promotionsNotifierProvider.notifier).updateLoyaltyConfig(
                  pointsPerHundredNairaSpent: earnRate,
                  pointsRequired: pointsReq,
                  creditAmountKobo: creditKobo,
                  minRedemptionPoints: minPoints,
                  maxRedemptionPoints: maxPoints,
                  presetPoints: parsedPresets.isNotEmpty ? parsedPresets : [200, 500, 1000, 2500],
                );

            Navigator.pop(dialogCtx);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Loyalty point valuation & thresholds updated successfully.'),
                backgroundColor: GVColors.brandGreen,
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: earnRateController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Points Earned per ₦100 Spent (pts)',
                  filled: true,
                  fillColor: Color(0xFF14241B),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: pointsReqController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Points Required (pts)',
                        filled: true,
                        fillColor: Color(0xFF14241B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: creditNairaController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Naira Credit Value (₦)',
                        filled: true,
                        fillColor: Color(0xFF14241B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: minThresholdController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Min Redemption Threshold (pts)',
                        filled: true,
                        fillColor: Color(0xFF14241B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: maxCapController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Max Redemption Cap (pts)',
                        filled: true,
                        fillColor: Color(0xFF14241B),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: presetsController,
                decoration: const InputDecoration(
                  labelText: 'Redemption Preset Options (comma separated)',
                  hintText: 'e.g. 200, 500, 1000, 2500',
                  filled: true,
                  fillColor: Color(0xFF14241B),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final promoState = ref.watch(promotionsNotifierProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(GVSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Promotions & Loyalty Engine',
                      style: GVTypography.h2.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Voucher lifecycle, percentage/fixed discounts, caps, and referral attribution (§5.4)',
                      style: GVTypography.bodySmall.copyWith(color: Colors.white60),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: GVSpacing.md),
              ElevatedButton.icon(
                key: const Key('create_voucher_btn'),
                onPressed: () => _showCreateCouponModal(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Create Promo Voucher'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GVColors.brandGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: GVSpacing.lg),

          // KPIs
          Row(
            children: [
              Expanded(
                child: AdminKpiCard(
                  title: 'Active Promo Vouchers',
                  value: '${promoState.activeCouponsCount}',
                  subtitle: 'Live across customer app',
                  icon: Icons.local_offer_outlined,
                  accentColor: GVColors.brandGreen,
                ),
              ),
              const SizedBox(width: GVSpacing.md),
              Expanded(
                child: AdminKpiCard(
                  title: 'Total Redemptions',
                  value: '${promoState.totalRedemptionsCount}',
                  subtitle: 'Trips completed with discount',
                  icon: Icons.redeem_outlined,
                  accentColor: Colors.blueAccent,
                ),
              ),
              const SizedBox(width: GVSpacing.md),
              Expanded(
                child: AdminKpiCard(
                  title: 'Circulating Loyalty Points',
                  value: NumberFormat('#,###').format(promoState.loyaltyConfig.totalCirculatingPoints),
                  subtitle: '₦${promoState.loyaltyConfig.totalCirculatingPoints ~/ 100} wallet liability',
                  icon: Icons.stars_outlined,
                  accentColor: Colors.amberAccent,
                ),
              ),
              const SizedBox(width: GVSpacing.md),
              Expanded(
                child: AdminKpiCard(
                  title: 'Referral Conversions',
                  value: '${promoState.referralCampaign.totalConversions}',
                  subtitle: 'Organic customer growth',
                  icon: Icons.group_add_outlined,
                  accentColor: Colors.purpleAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: GVSpacing.xl),

          // Coupons Registry Table
          Container(
            padding: const EdgeInsets.all(GVSpacing.md),
            decoration: BoxDecoration(
              color: const Color(0xFF101713),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1F2B25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Promotional Vouchers Registry',
                      style: GVTypography.h3.copyWith(color: Colors.white),
                    ),
                    Text(
                      '${promoState.coupons.length} vouchers configured',
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: GVSpacing.md),
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1.2),
                    1: FlexColumnWidth(1.2),
                    2: FlexColumnWidth(1.6),
                    3: FlexColumnWidth(1.8),
                    4: FlexColumnWidth(1.2),
                    5: FlexColumnWidth(1.0),
                  },
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0xFF1F2B25))),
                      ),
                      children: [
                        _headerCell('VOUCHER CODE'),
                        _headerCell('DISCOUNT'),
                        _headerCell('THRESHOLDS'),
                        _headerCell('USAGE / LIMIT'),
                        _headerCell('EXPIRES'),
                        _headerCell('STATUS'),
                      ],
                    ),
                    ...promoState.coupons.map((coupon) {
                      final usagePercent = coupon.usageLimit > 0
                          ? (coupon.usageCount / coupon.usageLimit).clamp(0.0, 1.0)
                          : 0.0;

                      return TableRow(
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xFF18221D))),
                        ),
                        children: [
                          _dataCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  coupon.code,
                                  style: const TextStyle(
                                    color: GVColors.brandGreen,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  coupon.description,
                                  style: const TextStyle(color: Colors.white60, fontSize: 10),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          _dataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: GVColors.brandGreen.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                coupon.formattedDiscount,
                                style: const TextStyle(
                                  color: GVColors.brandGreen,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                          ),
                          _dataCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Min: ${coupon.formattedMinOrder}', style: const TextStyle(color: Colors.white, fontSize: 11)),
                                if (coupon.maxDiscountKobo != null)
                                  Text(
                                    'Cap: ₦${(coupon.maxDiscountKobo! / BigInt.from(100)).toStringAsFixed(0)}',
                                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                                  ),
                              ],
                            ),
                          ),
                          _dataCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('${coupon.usageCount} / ${coupon.usageLimit}',
                                    style: const TextStyle(color: Colors.white, fontSize: 11)),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: usagePercent,
                                  backgroundColor: const Color(0xFF1F2B25),
                                  valueColor: const AlwaysStoppedAnimation(GVColors.brandGreen),
                                  minHeight: 4,
                                ),
                              ],
                            ),
                          ),
                          _dataCell(
                            Text(
                              _dateFormat.format(coupon.expiresAt),
                              style: TextStyle(
                                color: coupon.isExpired ? Colors.redAccent : Colors.white70,
                                fontSize: 11,
                              ),
                            ),
                          ),
                          _dataCell(
                            Switch(
                              key: Key('toggle_coupon_${coupon.code}'),
                              value: coupon.isActive && !coupon.isExpired,
                              activeThumbColor: GVColors.brandGreen,
                              onChanged: coupon.isExpired
                                  ? null
                                  : (val) {
                                      ref.read(promotionsNotifierProvider.notifier).toggleCouponStatus(coupon.code);
                                    },
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: GVSpacing.xl),

          // Split Panels: Loyalty Points & Referral Drive
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Panel 1: Loyalty Points Rules
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(GVSpacing.md),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101713),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1F2B25)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.stars, color: Colors.amberAccent, size: 20),
                              const SizedBox(width: 8),
                              Text('Go-Volts Eco-Points Loyalty Program', style: GVTypography.h3.copyWith(color: Colors.white)),
                            ],
                          ),
                          IconButton(
                            key: const Key('edit_loyalty_config_button'),
                            icon: const Icon(Icons.edit_note, color: GVColors.brandGreen),
                            tooltip: 'Configure Loyalty Economics & Thresholds',
                            onPressed: () => _showEditLoyaltyModal(context),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _ruleRow('Points Earned per ₦100 Spent', '${promoState.loyaltyConfig.pointsPerHundredNairaSpent} pts'),
                      _ruleRow('Redemption Conversion Rate', promoState.loyaltyConfig.formattedRate),
                      _ruleRow('Minimum Redemption Threshold', '${promoState.loyaltyConfig.minRedemptionPoints} pts'),
                      _ruleRow('Maximum Redemption Cap', '${promoState.loyaltyConfig.maxRedemptionPoints} pts'),
                      _ruleRow('Redemption Presets', promoState.loyaltyConfig.formattedPresetChips),
                      _ruleRow('Eco-Miles Carbon Offset Equivalence', '1 pt ≈ 15g CO2 saved'),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: GVSpacing.lg),

              // Panel 2: Referral Campaign
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(GVSpacing.md),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101713),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1F2B25)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.group_add, color: GVColors.brandGreen, size: 20),
                              const SizedBox(width: 8),
                              Text('Customer Referral Campaign', style: GVTypography.h3.copyWith(color: Colors.white)),
                            ],
                          ),
                          Switch(
                            key: const Key('toggle_referral_campaign_switch'),
                            value: promoState.referralCampaign.isActive,
                            activeThumbColor: GVColors.brandGreen,
                            onChanged: (val) {
                              ref.read(promotionsNotifierProvider.notifier).toggleReferralCampaign();
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _ruleRow('Campaign Name', promoState.referralCampaign.campaignName),
                      _ruleRow('Referrer Wallet Reward', promoState.referralCampaign.formattedReferrerReward),
                      _ruleRow('Referee First Trip Discount', '${promoState.referralCampaign.refereeDiscountPercent.toStringAsFixed(0)}% OFF'),
                      _ruleRow('Verified Conversions to Date', '${promoState.referralCampaign.totalConversions} successful first trips'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _ruleRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.white70, fontSize: 12)),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _headerCell(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Text(
        title,
        style: GVTypography.caption.copyWith(
          color: Colors.white38,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _dataCell(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: child,
    );
  }
}
