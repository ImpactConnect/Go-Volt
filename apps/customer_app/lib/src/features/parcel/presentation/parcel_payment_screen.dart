import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../application/parcel_booking_notifier.dart';

/// Screen 8 — Payment Method:
/// Selectable payment channels (Go-Volts Wallet, Debit/Credit Card, Bank Account, Cash, Other),
/// promo code field with DELIVER20 validation (20% discount), fare summary, and booking confirmation.
class ParcelPaymentScreen extends ConsumerStatefulWidget {
  const ParcelPaymentScreen({super.key});

  @override
  ConsumerState<ParcelPaymentScreen> createState() => _ParcelPaymentScreenState();
}

class _ParcelPaymentScreenState extends ConsumerState<ParcelPaymentScreen> {
  final _promoController = TextEditingController();
  String? _promoError;
  String? _promoSuccess;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _applyPromo() {
    final code = _promoController.text.trim();
    if (code.isEmpty) return;

    final success =
        ref.read(parcelBookingNotifierProvider.notifier).applyPromoCode(code);

    setState(() {
      if (success) {
        _promoError = null;
        _promoSuccess = 'Promo code applied! 20% discount on base fare.';
      } else {
        _promoSuccess = null;
        _promoError = 'Invalid promo code. Try DELIVER20';
      }
    });
  }

  void _removePromo() {
    ref.read(parcelBookingNotifierProvider.notifier).removePromoCode();
    setState(() {
      _promoController.clear();
      _promoError = null;
      _promoSuccess = null;
    });
  }

  Future<void> _confirmDelivery() async {
    final notifier = ref.read(parcelBookingNotifierProvider.notifier);
    await notifier.commitBooking();

    if (mounted) {
      if (GoRouter.maybeOf(context) != null) {
        context.push(AppRoutes.parcelConfirmation);
      } else {
        Navigator.of(context).pushNamed(AppRoutes.parcelConfirmation);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(parcelBookingNotifierProvider);
    final notifier = ref.read(parcelBookingNotifierProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final quote = state.quote;
    final totalFare = quote?.formattedTotalFare ?? '₦2,500';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1512) : GVColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? GVColors.white : GVColors.textPrimary,
            size: 20,
          ),
          onPressed: () {
            if (GoRouter.maybeOf(context) != null) {
              context.pop();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
        title: Text(
          'Payment method',
          style: GVTypography.h3.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? GVColors.white : GVColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: GVSpacing.sm),

                    // 1. Go-Volts Wallet
                    GVPaymentMethodTile(
                      title: 'Go-Volts Wallet',
                      subtitle: 'Balance: ₦5,200.00',
                      icon: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Color(0xFFDCFCE7),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'gb',
                            style: TextStyle(
                              color: GVColors.deepGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                      isSelected: state.paymentMethod == PaymentMethod.wallet,
                      onTap: () =>
                          notifier.selectPaymentMethod(PaymentMethod.wallet),
                    ),
                    const SizedBox(height: GVSpacing.sm),

                    // 2. Add New Card
                    GVPaymentMethodTile(
                      title: 'Add new card',
                      subtitle: 'Debit or credit card',
                      icon: const Icon(
                        Icons.credit_card_rounded,
                        color: GVColors.neutral600,
                        size: 22,
                      ),
                      isSelected: state.paymentMethod == PaymentMethod.card,
                      onTap: () =>
                          notifier.selectPaymentMethod(PaymentMethod.card),
                    ),
                    const SizedBox(height: GVSpacing.sm),

                    // 3. Bank Account
                    GVPaymentMethodTile(
                      title: 'Bank account',
                      subtitle: 'Pay directly from your bank',
                      icon: const Icon(
                        Icons.account_balance_rounded,
                        color: GVColors.neutral600,
                        size: 22,
                      ),
                      isSelected:
                          state.paymentMethod == PaymentMethod.bankTransfer,
                      onTap: () => notifier
                          .selectPaymentMethod(PaymentMethod.bankTransfer),
                    ),
                    const SizedBox(height: GVSpacing.sm),

                    // 4. Cash on Delivery
                    GVPaymentMethodTile(
                      title: 'Cash',
                      subtitle: 'Pay with cash',
                      icon: const Icon(
                        Icons.payments_outlined,
                        color: GVColors.warning,
                        size: 22,
                      ),
                      isSelected: state.paymentMethod == PaymentMethod.cash,
                      onTap: () =>
                          notifier.selectPaymentMethod(PaymentMethod.cash),
                    ),
                    const SizedBox(height: GVSpacing.sm),

                    // 5. Other Payment Options
                    GVPaymentMethodTile(
                      title: 'Other payment options',
                      subtitle: 'e.g. USSD, mobile money',
                      icon: const Icon(
                        Icons.phonelink_rounded,
                        color: GVColors.deepPurple,
                        size: 22,
                      ),
                      isSelectable: false,
                      onTap: () {},
                    ),

                    const SizedBox(height: GVSpacing.lg),
                    const Divider(height: 1),
                    const SizedBox(height: GVSpacing.md),

                    // Promo Code Section
                    Text(
                      'Apply promo code',
                      style: GVTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? GVColors.white : GVColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: GVSpacing.xs),

                    if (state.appliedPromoCode != null) ...[
                      // Applied Promo Code Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: GVSpacing.md,
                          vertical: GVSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF16201B)
                              : const Color(0xFFF0FDF4),
                          borderRadius:
                              BorderRadius.circular(GVBorderRadius.md),
                          border: Border.all(color: GVColors.brandGreen),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: GVColors.brandGreen,
                              size: 18,
                            ),
                            const SizedBox(width: GVSpacing.sm),
                            Expanded(
                              child: Text(
                                '${state.appliedPromoCode} (20% OFF: -${quote?.formattedDiscount ?? '₦400'})',
                                style: GVTypography.bodySmallMedium.copyWith(
                                  color: GVColors.brandGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              color: GVColors.neutral500,
                              onPressed: _removePromo,
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ),
                    ] else ...[
                      // Promo Code Input Row
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _promoController,
                              textCapitalization: TextCapitalization.characters,
                              decoration: InputDecoration(
                                hintText: 'Enter promo code',
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 12,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(GVBorderRadius.md),
                                  borderSide: BorderSide(
                                    color: isDark
                                        ? const Color(0xFF2E3D35)
                                        : GVColors.border,
                                  ),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(GVBorderRadius.md),
                                  borderSide: BorderSide(
                                    color: isDark
                                        ? const Color(0xFF2E3D35)
                                        : GVColors.border,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: GVSpacing.sm),
                          ElevatedButton(
                            onPressed: _applyPromo,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isDark
                                  ? const Color(0xFF26322A)
                                  : const Color(0xFFE5E7EB),
                              foregroundColor: isDark
                                  ? GVColors.white
                                  : GVColors.textPrimary,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 18,
                                vertical: 14,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.circular(GVBorderRadius.md),
                              ),
                            ),
                            child: const Text('Apply'),
                          ),
                        ],
                      ),
                      if (_promoError != null) ...[
                        const SizedBox(height: GVSpacing.xs),
                        Text(
                          _promoError!,
                          style: GVTypography.caption.copyWith(
                            color: GVColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                      if (_promoSuccess != null) ...[
                        const SizedBox(height: GVSpacing.xs),
                        Text(
                          _promoSuccess!,
                          style: GVTypography.caption.copyWith(
                            color: GVColors.brandGreen,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],

                    const SizedBox(height: GVSpacing.lg),

                    // Total Fare Summary Card
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total fare',
                          style: GVTypography.h3.copyWith(
                            fontWeight: FontWeight.bold,
                            color:
                                isDark ? GVColors.white : GVColors.textPrimary,
                          ),
                        ),
                        Text(
                          totalFare,
                          style: GVTypography.h3.copyWith(
                            fontWeight: FontWeight.bold,
                            color: GVColors.brandGreen,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: GVSpacing.sm),

                    // Terms Notice
                    Text(
                      'By proceeding, you agree to our Terms of Service and Privacy Policy.',
                      style: GVTypography.caption.copyWith(
                        color: isDark
                            ? GVColors.neutral400
                            : GVColors.textSecondary,
                        height: 1.3,
                      ),
                    ),

                    const SizedBox(height: GVSpacing.xl),
                  ],
                ),
              ),
            ),

            // Sticky Bottom CTA: Confirm delivery
            Container(
              padding: const EdgeInsets.all(GVSpacing.lg),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131A16) : GVColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: GVPrimaryButton(
                label: 'Confirm delivery',
                isLoading: state.isLoading,
                onPressed: _confirmDelivery,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
