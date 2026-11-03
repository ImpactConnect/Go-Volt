import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
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

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(scheduledBookingNotifierProvider);
    final plansNotifier = ref.read(scheduledPlansNotifierProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF131A16) : Colors.white;
    final textColor = isDark ? Colors.white : GVColors.textPrimary;
    final subtextColor = isDark ? GVColors.neutral400 : GVColors.textSecondary;
    final cardBg = isDark ? const Color(0xFF1C2420) : const Color(0xFFF6F8F7);
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;

    final amountStr =
        bookingState.createdPlan != null &&
            bookingState.createdPlan!.totalAmountNgn > 0
        ? '₦${bookingState.createdPlan!.totalAmountNgn.toStringAsFixed(0)}'
        : '₦150,000';

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
              const SizedBox(height: GVSpacing.xl),

              // 1. Go-Volts Wallet
              _buildPaymentOption(
                title: 'Go-Volts Wallet',
                subtitle: 'Balance: ₦5,200',
                icon: Icons.account_balance_wallet_rounded,
                isBrandLogo: true,
                methodKey: 'Go-Volts Wallet',
                cardBg: cardBg,
                borderColor: borderColor,
                textColor: textColor,
                subtextColor: subtextColor,
              ),

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

              const Spacer(),

              // Amount banner
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total amount',
                    style: GVTypography.bodyMedium.copyWith(
                      color: subtextColor,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    amountStr,
                    style: GVTypography.h2.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 22,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: GVSpacing.md),

              // Primary CTA: Pay now
              GVButton(
                text: 'Pay now',
                onPressed: () async {
                  final planId = bookingState.createdPlan?.id ?? 'plan-001';
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
