import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../application/shopping_errand_notifier.dart';
import '../../domain/shopping_flow_state.dart';

/// Screen A6 (ME-A06): Review Order and Pay.
/// Matches high-fidelity design template Row 1 Screen A6.
class ShoppingReviewScreen extends ConsumerWidget {
  const ShoppingReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(shoppingErrandNotifierProvider);
    final notifier = ref.read(shoppingErrandNotifierProvider.notifier);

    final quote = state.quote ??
        ErrandQuoteDto(
          id: 'quote_def',
          errandType: ErrandType.buyItems,
          estimatedItemsCostKobo: state.totalEstimatedItemsKobo,
          serviceFeeKobo: 80000,
          deliveryFeeKobo: 120000,
          totalKobo: state.totalEstimatedItemsKobo + 80000 + 120000,
        );

    final totalDisplay = quote.formattedTotal;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1512) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? GVColors.white : GVColors.textPrimary,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Review Order',
          style: GVTypography.h3.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? GVColors.white : GVColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: GVSpacing.sm),

              // Itemized Cost Summary Card
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF161F1A) : GVColors.white,
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2A3D32) : const Color(0xFFE0E0E0),
                  ),
                ),
                padding: const EdgeInsets.all(GVSpacing.md),
                child: Column(
                  children: [
                    // Shop row
                    _buildSummaryRow(
                      context,
                      isDark: isDark,
                      label: 'Shop / Market',
                      value: state.selectedShop?.name ?? 'Kakuri Main Market',
                      isBold: true,
                    ),

                    const Divider(height: 24),

                    // Items count & sum
                    _buildSummaryRow(
                      context,
                      isDark: isDark,
                      label: 'Items (${state.itemsCount})',
                      value: '${quote.formattedItemsCost} (est.)',
                      showInfoIcon: true,
                      onInfoTap: () => _showItemsDetailSheet(context, state, isDark),
                    ),

                    const SizedBox(height: GVSpacing.md),

                    // Service fee
                    _buildSummaryRow(
                      context,
                      isDark: isDark,
                      label: 'Service fee',
                      value: quote.formattedServiceFee,
                      showInfoIcon: true,
                      onInfoTap: () => _showFeeInfoDialog(
                        context,
                        title: 'Errand Service Fee',
                        message:
                            'Covers rider errand effort, market shopping, selection and inspection of requested products.',
                      ),
                    ),

                    const SizedBox(height: GVSpacing.md),

                    // Delivery fee
                    _buildSummaryRow(
                      context,
                      isDark: isDark,
                      label: 'Delivery fee',
                      value: quote.formattedDeliveryFee,
                    ),

                    const Divider(height: 24),

                    // Total amount
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Estimated total',
                          style: GVTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? GVColors.white : GVColors.textPrimary,
                          ),
                        ),
                        Text(
                          totalDisplay,
                          style: GVTypography.h3.copyWith(
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF00C853),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: GVSpacing.md),

              // Yellow Disclaimer Notice Banner (Matching Screen A6)
              Container(
                padding: const EdgeInsets.all(GVSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(color: const Color(0xFFFFE082)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: Color(0xFFF57F17),
                      size: 20,
                    ),
                    const SizedBox(width: GVSpacing.sm),
                    Expanded(
                      child: Text(
                        'Final amount may change based on actual item prices and availability.',
                        style: GVTypography.bodySmall.copyWith(
                          color: const Color(0xFFE65100),
                          height: 1.35,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: GVSpacing.lg),

              // Destination & Recipient Quick Card
              _buildSectionHeader('Deliver to', isDark),
              const SizedBox(height: GVSpacing.xs),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF161F1A) : GVColors.white,
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2A3D32) : const Color(0xFFE0E0E0),
                  ),
                ),
                padding: const EdgeInsets.all(GVSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Color(0xFF00C853),
                          size: 18,
                        ),
                        const SizedBox(width: GVSpacing.xs),
                        Expanded(
                          child: Text(
                            state.deliveryLocation.address,
                            style: GVTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Recipient: ${state.recipient.fullName} • ${state.recipient.phoneNumber}',
                      style: GVTypography.caption.copyWith(
                        color: isDark ? GVColors.neutral400 : GVColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: GVSpacing.lg),

              // Payment Channel Selector
              _buildSectionHeader('Payment Method', isDark),
              const SizedBox(height: GVSpacing.xs),
              _buildPaymentOption(
                context,
                title: 'Go-Volts Wallet',
                subtitle: 'Pay instantly from your ride & errand wallet',
                isSelected: state.paymentMethod == PaymentMethod.wallet,
                isDark: isDark,
                onTap: () => notifier.setPaymentMethod(PaymentMethod.wallet),
              ),
              const SizedBox(height: GVSpacing.xs),
              _buildPaymentOption(
                context,
                title: 'Debit / Credit Card (Paystack)',
                subtitle: 'Mastercard, Visa, Verve (256-bit encryption)',
                isSelected: state.paymentMethod == PaymentMethod.card,
                isDark: isDark,
                onTap: () => notifier.setPaymentMethod(PaymentMethod.card),
              ),

              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(GVSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161F1A) : GVColors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF2E3D35) : const Color(0xFFEEEEEE),
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C853),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                ),
              ),
              onPressed: state.isLoading
                  ? null
                  : () async {
                      final success = await notifier.submitOrder();
                      if (context.mounted && success) {
                        context.pushReplacement(AppRoutes.errandTracking);
                      }
                    },
              child: state.isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      'Pay $totalDisplay',
                      style: GVTypography.bodyLarge.copyWith(
                        color: GVColors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: GVTypography.bodyMedium.copyWith(
        fontWeight: FontWeight.bold,
        color: isDark ? GVColors.white : GVColors.textPrimary,
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context, {
    required bool isDark,
    required String label,
    required String value,
    bool isBold = false,
    bool showInfoIcon = false,
    VoidCallback? onInfoTap,
  }) {
    return Row(
      children: [
        Text(
          label,
          style: GVTypography.bodyMedium.copyWith(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isDark ? GVColors.neutral300 : GVColors.textSecondary,
          ),
        ),
        if (showInfoIcon) ...[
          const SizedBox(width: 4),
          InkWell(
            onTap: onInfoTap,
            child: const Icon(
              Icons.info_outline_rounded,
              size: 16,
              color: Color(0xFF757575),
            ),
          ),
        ],
        const Spacer(),
        Text(
          value,
          style: GVTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? GVColors.white : GVColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161F1A) : GVColors.white,
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF00C853)
              : (isDark ? const Color(0xFF2A3D32) : const Color(0xFFE0E0E0)),
          width: isSelected ? 1.8 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: ListTile(
          onTap: onTap,
          leading: Icon(
            title.contains('Wallet')
                ? Icons.account_balance_wallet_outlined
                : Icons.credit_card_rounded,
            color: isSelected ? const Color(0xFF00C853) : const Color(0xFF757575),
          ),
          title: Text(
            title,
            style: GVTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(subtitle, style: GVTypography.caption),
          trailing: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF00C853)
                    : const Color(0xFFBDBDBD),
                width: 2,
              ),
              color: isSelected ? const Color(0xFF00C853) : Colors.transparent,
            ),
            child: isSelected
                ? const Icon(Icons.check, size: 12, color: GVColors.white)
                : null,
          ),
        ),
      ),
    );
  }

  void _showItemsDetailSheet(
    BuildContext context,
    ShoppingFlowState state,
    bool isDark,
  ) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? const Color(0xFF161F1A) : GVColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(GVBorderRadius.lg)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(GVSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Itemized Shopping List',
                  style: GVTypography.h3.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: GVSpacing.md),
                for (final i in state.items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('${i.quantity} ${i.unit} ${i.name}'),
                        Text(
                          '₦${((i.estimatedPriceKobo * i.quantity) / 100).toStringAsFixed(0)}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                const Divider(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Item Budget', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      '₦${(state.totalEstimatedItemsKobo / 100).toStringAsFixed(0)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00C853),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showFeeInfoDialog(
    BuildContext context, {
    required String title,
    required String message,
  }) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK', style: TextStyle(color: Color(0xFF00C853))),
          ),
        ],
      ),
    );
  }
}
