import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../application/package_errand_notifier.dart';

/// Screen B5: Review Request & Pay (Pick Up a Package Flow).
/// Transparent summary of pickup, delivery, package specs, and itemized fees.
class PackageReviewScreen extends ConsumerStatefulWidget {
  const PackageReviewScreen({super.key});

  @override
  ConsumerState<PackageReviewScreen> createState() => _PackageReviewScreenState();
}

class _PackageReviewScreenState extends ConsumerState<PackageReviewScreen> {
  PaymentMethod _paymentMethod = PaymentMethod.wallet;
  bool _isProcessing = false;

  void _onPay(int totalKobo) async {
    setState(() => _isProcessing = true);
    try {
      await ref
          .read(packageErrandNotifierProvider.notifier)
          .confirmAndPay(_paymentMethod);
      if (mounted) {
        setState(() => _isProcessing = false);
        context.pushReplacement(AppRoutes.errandPackageTracking);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: Colors.red.shade700,
          ),
        );
      }
    }
  }

  void _openPaymentSheet(BuildContext context, int totalKobo) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Select Payment Method',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildPaymentRadioTile(
                    title: 'Go-Volt Wallet (Recommended)',
                    subtitle: 'Fast, zero-fee debit from your ride wallet',
                    icon: Icons.account_balance_wallet_outlined,
                    method: PaymentMethod.wallet,
                    current: _paymentMethod,
                    onSelected: (m) {
                      setSheetState(() => _paymentMethod = m);
                      setState(() => _paymentMethod = m);
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildPaymentRadioTile(
                    title: 'Paystack (Card / USSD / Transfer)',
                    subtitle: 'Secure checkout via Paystack gateway',
                    icon: Icons.credit_card_outlined,
                    method: PaymentMethod.card,
                    current: _paymentMethod,
                    onSelected: (m) {
                      setSheetState(() => _paymentMethod = m);
                      setState(() => _paymentMethod = m);
                    },
                  ),
                  const SizedBox(height: 24),
                  GVButton(
                    text: 'Confirm & Pay ${ErrandQuoteDto.formatNgn(totalKobo)}',
                    onPressed: () {
                      Navigator.pop(ctx);
                      _onPay(totalKobo);
                    },
                    expanded: true,
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPaymentRadioTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required PaymentMethod method,
    required PaymentMethod current,
    required ValueChanged<PaymentMethod> onSelected,
  }) {
    final isSelected = method == current;
    return InkWell(
      onTap: () => onSelected(method),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? GVColors.primary : Colors.grey.shade300,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: isSelected ? GVColors.primary : Colors.grey.shade600),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: isSelected ? GVColors.primary : Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(packageErrandNotifierProvider);

    final serviceFeeKobo = state.quote?.serviceFeeKobo ?? 70000;
    final deliveryFeeKobo = state.quote?.deliveryFeeKobo ?? 110000;
    final totalKobo = state.quote?.totalKobo ?? (serviceFeeKobo + deliveryFeeKobo);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Review Request',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Pickup Card
                    _buildSummaryCard(
                      icon: Icons.storefront_outlined,
                      title: 'Pickup',
                      primaryText: state.pickupDetails.pickupBusinessName,
                      secondaryText:
                          '${state.pickupDetails.address} • Contact: ${state.pickupDetails.contactPerson}',
                      badgeText: state.pickupDetails.referenceOrderNumber != null
                          ? 'Ref: ${state.pickupDetails.referenceOrderNumber}'
                          : null,
                    ),
                    const SizedBox(height: 12),

                    // Delivery Card
                    _buildSummaryCard(
                      icon: Icons.place_outlined,
                      title: 'Deliver to',
                      primaryText: state.deliveryLocation.address,
                      secondaryText:
                          '${state.recipient.fullName} • ${state.recipient.phoneNumber}',
                    ),
                    const SizedBox(height: 12),

                    // Package Card
                    _buildSummaryCard(
                      icon: Icons.inventory_2_outlined,
                      title: 'Package',
                      primaryText:
                          '${state.packageDescription} - ${state.weightBand}',
                      secondaryText:
                          'Category: ${state.category} • Size: ${state.sizeBand}',
                      badgeText: state.isFragile ? 'Fragile' : null,
                    ),
                    const SizedBox(height: 18),

                    // Price Breakdown Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildFeeRow(
                            label: 'Service fee',
                            value: ErrandQuoteDto.formatNgn(serviceFeeKobo),
                            showInfo: true,
                          ),
                          const SizedBox(height: 12),
                          _buildFeeRow(
                            label: 'Delivery fee',
                            value: ErrandQuoteDto.formatNgn(deliveryFeeKobo),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12),
                            child: Divider(height: 1),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                ErrandQuoteDto.formatNgn(totalKobo),
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: GVColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: GVButton(
                text: 'Pay ${ErrandQuoteDto.formatNgn(totalKobo)}',
                isLoading: _isProcessing,
                onPressed: () => _openPaymentSheet(context, totalKobo),
                expanded: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required IconData icon,
    required String title,
    required String primaryText,
    required String secondaryText,
    String? badgeText,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: GVColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: GVColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (badgeText != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: GVColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          badgeText,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: GVColors.primary,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  primaryText,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  secondaryText,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeRow({
    required String label,
    required String value,
    bool showInfo = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
            if (showInfo) ...[
              const SizedBox(width: 6),
              Icon(
                Icons.info_outline,
                size: 14,
                color: Colors.grey.shade500,
              ),
            ],
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
