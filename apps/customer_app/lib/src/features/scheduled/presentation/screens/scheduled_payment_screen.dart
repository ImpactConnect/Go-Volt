import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../wallet/application/wallet_notifier.dart';
import '../../application/scheduled_booking_notifier.dart';
import '../../application/scheduled_plans_notifier.dart';

/// Screen 16 (SP-17): Scheduled Payment Screen
/// Selects payment instrument (Wallet, Card, Direct Bank, USSD) and initiates checkout.
class ScheduledPaymentScreen extends ConsumerStatefulWidget {
  const ScheduledPaymentScreen({super.key});

  @override
  ConsumerState<ScheduledPaymentScreen> createState() =>
      _ScheduledPaymentScreenState();
}

class _ScheduledPaymentScreenState
    extends ConsumerState<ScheduledPaymentScreen> {
  String _selectedMethod = 'Go-Volts Wallet';
  final TextEditingController _promoController = TextEditingController();
  CouponDto? _appliedCoupon;
  String? _promoError;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _applyCoupon(List<CouponDto> availableCoupons, double baseAmount) {
    final code = _promoController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    final match = availableCoupons.cast<CouponDto?>().firstWhere(
      (c) => c?.code == code,
      orElse: () => null,
    );

    if (match != null) {
      if (baseAmount < match.minOrderAmountNaira) {
        setState(() {
          _promoError =
              'Minimum order of ₦${match.minOrderAmountNaira.toStringAsFixed(0)} required.';
          _appliedCoupon = null;
        });
        return;
      }
      setState(() {
        _appliedCoupon = match;
        _promoError = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Voucher "$code" applied! ₦${match.discountAmountNaira.toStringAsFixed(0)} off.'),
          backgroundColor: GVColors.brandGreen,
        ),
      );
    } else if (code == 'SCHOOLDROP' || code == 'VOLTFIRST' || code == 'CLEANLEKKI') {
      final discount = code == 'SCHOOLDROP' ? 2500.0 : (code == 'CLEANLEKKI' ? 1000.0 : 500.0);
      setState(() {
        _appliedCoupon = CouponDto(
          code: code,
          title: 'Special Promotional Discount',
          discountAmountNaira: discount,
          minOrderAmountNaira: 1000.0,
          expiryDate: DateTime.now().add(const Duration(days: 30)),
        );
        _promoError = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Voucher "$code" applied! ₦${discount.toStringAsFixed(0)} off.'),
          backgroundColor: GVColors.brandGreen,
        ),
      );
    } else {
      setState(() {
        _promoError = 'Invalid or expired promo code.';
        _appliedCoupon = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(scheduledBookingNotifierProvider);
    final plansNotifier = ref.read(scheduledPlansNotifierProvider.notifier);
    final walletState = ref.watch(walletNotifierProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF131A16) : Colors.white;
    final textColor = isDark ? Colors.white : GVColors.textPrimary;
    final subtextColor = isDark ? GVColors.neutral400 : GVColors.textSecondary;
    final cardBg = isDark ? const Color(0xFF1C2420) : const Color(0xFFF6F8F7);
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;

    final baseAmount = bookingState.createdPlan != null &&
            bookingState.createdPlan!.totalAmountNgn > 0
        ? bookingState.createdPlan!.totalAmountNgn
        : 150000.0;

    final discount = _appliedCoupon?.discountAmountNaira ?? 0.0;
    final finalPayableAmount = (baseAmount - discount).clamp(0.0, double.infinity);
    final walletBalance = walletState.wallet.availableBalance;
    final hasInsufficientWallet = walletBalance < finalPayableAmount;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
          children: [
            const SizedBox(height: GVSpacing.xs),
            Text(
              'Payment method',
              style: GVTypography.h1.copyWith(
                color: textColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: GVSpacing.lg),

            // 1. Go-Volts Wallet (Dynamic balance from walletNotifier)
            _buildPaymentOption(
              title: 'Go-Volts Wallet',
              subtitle: 'Balance: ₦${walletBalance.toStringAsFixed(0)}',
              icon: Icons.account_balance_wallet_rounded,
              isBrandLogo: true,
              methodKey: 'Go-Volts Wallet',
              cardBg: cardBg,
              borderColor: borderColor,
              textColor: textColor,
              subtextColor: subtextColor,
            ),

            if (_selectedMethod == 'Go-Volts Wallet' && hasInsufficientWallet) ...[
              const SizedBox(height: GVSpacing.xs),
              Container(
                padding: const EdgeInsets.all(GVSpacing.sm),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(GVBorderRadius.sm),
                  border: Border.all(color: Colors.amber.shade300),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.orange, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Insufficient balance (₦${walletBalance.toStringAsFixed(0)}). Needed: ₦${finalPayableAmount.toStringAsFixed(0)}.',
                        style: GVTypography.caption.copyWith(color: Colors.brown.shade800),
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(50, 30),
                      ),
                      onPressed: () => context.push(AppRoutes.walletTopUp),
                      child: const Text('Top Up', style: TextStyle(fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: GVSpacing.md),

            // 2. Debit or credit card
            _buildPaymentOption(
              title: 'Debit or credit card',
              subtitle: null,
              icon: Icons.credit_card_rounded,
              methodKey: 'Debit or credit card',
              cardBg: cardBg,
              borderColor: borderColor,
              textColor: textColor,
              subtextColor: subtextColor,
            ),

            const SizedBox(height: GVSpacing.md),

            // 3. Bank account
            _buildPaymentOption(
              title: 'Bank account',
              subtitle: 'Pay directly from bank',
              icon: Icons.account_balance_rounded,
              methodKey: 'Bank account',
              cardBg: cardBg,
              borderColor: borderColor,
              textColor: textColor,
              subtextColor: subtextColor,
            ),

            const SizedBox(height: GVSpacing.md),

            // 4. USSD / Mobile money
            _buildPaymentOption(
              title: 'USSD / Mobile money',
              subtitle: 'e.g. 9mobile, Airtel',
              icon: Icons.phone_android_rounded,
              methodKey: 'USSD / Mobile money',
              cardBg: cardBg,
              borderColor: borderColor,
              textColor: textColor,
              subtextColor: subtextColor,
            ),

            const SizedBox(height: GVSpacing.md),

            // 5. Other payment options
            _buildPaymentOption(
              title: 'Other payment options',
              subtitle: null,
              icon: Icons.more_horiz_rounded,
              methodKey: 'Other',
              cardBg: cardBg,
              borderColor: borderColor,
              textColor: textColor,
              subtextColor: subtextColor,
            ),

            const SizedBox(height: GVSpacing.lg),

            // Promo Code & Voucher Section
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.confirmation_number_outlined,
                          color: GVColors.brandGreen, size: 20),
                      const SizedBox(width: 8),
                      Text('Have a Promo Voucher?', style: GVTypography.labelLarge.copyWith(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: GVSpacing.xs),
                  if (_appliedCoupon != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: GVColors.statusActiveBg,
                        borderRadius: BorderRadius.circular(GVBorderRadius.sm),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Text(
                              '${_appliedCoupon!.code} applied (-₦${_appliedCoupon!.discountAmountNaira.toStringAsFixed(0)})',
                              style: GVTypography.bodySmallMedium.copyWith(color: GVColors.brandGreen),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            icon: const Icon(Icons.close, size: 18, color: GVColors.brandGreen),
                            onPressed: () {
                              setState(() {
                                _appliedCoupon = null;
                                _promoController.clear();
                              });
                            },
                          ),
                        ],
                      ),
                    )
                  else ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _promoController,
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                              hintText: 'e.g. SCHOOLDROP',
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(GVBorderRadius.sm)),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: GVColors.brandGreen,
                            foregroundColor: GVColors.deepGreen,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                          ),
                          onPressed: () => _applyCoupon(walletState.coupons, baseAmount),
                          child: const Text('Apply'),
                        ),
                      ],
                    ),
                    if (_promoError != null) ...[
                      const SizedBox(height: 4),
                      Text(_promoError!, style: GVTypography.caption.copyWith(color: GVColors.error)),
                    ],
                  ],
                ],
              ),
            ),

            const SizedBox(height: GVSpacing.xl),

            // Amount breakdown & total
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Plan Price', style: GVTypography.bodySmall.copyWith(color: subtextColor)),
                      Text('₦${baseAmount.toStringAsFixed(0)}', style: GVTypography.bodySmall.copyWith(color: textColor)),
                    ],
                  ),
                  if (discount > 0) ...[
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Promo Discount', style: GVTypography.bodySmall.copyWith(color: GVColors.brandGreen)),
                        Text('-₦${discount.toStringAsFixed(0)}', style: GVTypography.bodySmall.copyWith(color: GVColors.brandGreen, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                  const Divider(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total amount',
                        style: GVTypography.bodyMedium.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '₦${finalPayableAmount.toStringAsFixed(0)}',
                        style: GVTypography.h2.copyWith(
                          color: GVColors.deepGreen,
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: GVSpacing.lg),

            // Primary CTA: Pay now
            GVButton(
              text: 'Pay now',
              onPressed: () async {
                if (_selectedMethod == 'Go-Volts Wallet' && hasInsufficientWallet) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Insufficient wallet balance. Please top up or choose card/bank transfer.'),
                      backgroundColor: GVColors.error,
                    ),
                  );
                  return;
                }

                final planId =
                    bookingState.createdPlan?.id ?? 'plan-001';
                await plansNotifier.payForPlan(
                  planId: planId,
                  paymentMethod: _selectedMethod,
                );
                if (context.mounted) {
                  context.push(AppRoutes.scheduledPaymentSuccess);
                }
              },
            ),
            const SizedBox(height: GVSpacing.lg),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption({
    required String title,
    String? subtitle,
    required IconData icon,
    bool isBrandLogo = false,
    required String methodKey,
    required Color cardBg,
    required Color borderColor,
    required Color textColor,
    required Color subtextColor,
  }) {
    final isSelected = _selectedMethod == methodKey;
    return InkWell(
      onTap: () => setState(() => _selectedMethod = methodKey),
      borderRadius: BorderRadius.circular(GVBorderRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(GVBorderRadius.md),
          border: Border.all(
            color: isSelected ? GVColors.primary : borderColor,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isBrandLogo
                    ? GVColors.primary
                    : Colors.grey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: isBrandLogo
                  ? const Center(
                      child: Text(
                        'gb',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    )
                  : Icon(icon, color: textColor, size: 20),
            ),
            const SizedBox(width: GVSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GVTypography.labelMedium.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GVTypography.bodySmall.copyWith(
                        color: subtextColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected ? GVColors.primary : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
