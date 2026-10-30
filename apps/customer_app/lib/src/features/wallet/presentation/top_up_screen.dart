import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/wallet_notifier.dart';

/// Screen W02: Go-Volts Wallet Top-Up via Paystack checkout.
class TopUpScreen extends ConsumerStatefulWidget {
  const TopUpScreen({super.key});

  @override
  ConsumerState<TopUpScreen> createState() => _TopUpScreenState();
}

class _TopUpScreenState extends ConsumerState<TopUpScreen> {
  final _amountController = TextEditingController(text: '2000');
  double _selectedAmount = 2000;
  String _selectedPaymentMethod = 'Debit / Credit Card (Paystack)';
  bool _isSuccess = false;
  double? _creditedAmount;

  final List<double> _presetAmounts = [1000, 2000, 5000, 10000];

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _onSelectPreset(double amount) {
    setState(() {
      _selectedAmount = amount;
      _amountController.text = amount.toStringAsFixed(0);
    });
  }

  Future<void> _handleInitiateTopUp() async {
    final amount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (amount < 500) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Minimum top-up amount is ₦500.')),
      );
      return;
    }

    final notifier = ref.read(walletNotifierProvider.notifier);
    final redirectUrl = await notifier.initiateTopUp(amount);

    if (!mounted) return;

    if (redirectUrl != null) {
      _showPaystackCheckoutModal(amount, redirectUrl);
    }
  }

  void _showPaystackCheckoutModal(double amount, String authUrl) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                Row(
                  children: [
                    const Icon(Icons.lock, color: GVColors.brandGreen, size: 20),
                    const SizedBox(width: GVSpacing.xs),
                    Text('Paystack Secure Checkout', style: GVTypography.h3),
                  ],
                ),
                IconButton(
                  onPressed: () => Navigator.pop(ctx),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: GVSpacing.sm),
            Text(
              'Amount to pay: ₦${amount.toStringAsFixed(2)}',
              style: GVTypography.h2.copyWith(color: GVColors.deepGreen),
            ),
            const SizedBox(height: GVSpacing.xs),
            Text(
              'Redirecting to Paystack payment gateway... Cards, USSD, and Bank Transfers are processed with 256-bit encryption.',
              style: GVTypography.caption.copyWith(color: GVColors.textSecondary),
            ),
            const SizedBox(height: GVSpacing.lg),

            // Simulated Gateway verification trigger
            GVPrimaryButton(
              label: 'Simulate Successful Payment',
              onPressed: () async {
                Navigator.pop(ctx);
                final refCode = 'PSTK-TXN-${DateTime.now().millisecondsSinceEpoch}';
                final ok = await ref
                    .read(walletNotifierProvider.notifier)
                    .completeTopUp(refCode, amount);

                if (ok && mounted) {
                  setState(() {
                    _isSuccess = true;
                    _creditedAmount = amount;
                  });
                }
              },
            ),
            const SizedBox(height: GVSpacing.sm),
            GVSecondaryButton(
              label: 'Cancel Payment',
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(walletNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const GVTopBar(title: 'Top Up Wallet'),
      body: SafeArea(
        child: _isSuccess
            ? _buildSuccessView()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(GVSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Select or Enter Amount', style: GVTypography.h3),
                    const SizedBox(height: GVSpacing.sm),

                    // Amount input field with Naira sign
                    TextField(
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: GVTypography.h1.copyWith(
                        color: GVColors.deepGreen,
                        fontSize: 28,
                      ),
                      decoration: const InputDecoration(
                        prefixText: '₦ ',
                        prefixStyle: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: GVColors.deepGreen,
                        ),
                        border: OutlineInputBorder(),
                        labelText: 'Top-up Amount',
                        helperText: 'Minimum top-up: ₦500 • Maximum: ₦500,000',
                      ),
                      onChanged: (val) {
                        final parsed = double.tryParse(val) ?? 0;
                        setState(() => _selectedAmount = parsed);
                      },
                    ),
                    const SizedBox(height: GVSpacing.md),

                    // Preset Chips
                    Row(
                      children: _presetAmounts.map((amt) {
                        final isSelected = _selectedAmount == amt;
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: ChoiceChip(
                              label: Text(
                                '₦${amt >= 1000 ? '${(amt / 1000).toStringAsFixed(0)}k' : amt.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : GVColors.nearBlack,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: GVColors.deepGreen,
                              backgroundColor: GVColors.softBackground,
                              onSelected: (_) => _onSelectPreset(amt),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: GVSpacing.lg),

                    // Payment Method Channel
                    Text('Payment Channel', style: GVTypography.h3),
                    const SizedBox(height: GVSpacing.sm),

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: GVColors.border),
                        borderRadius: BorderRadius.circular(GVBorderRadius.md),
                      ),
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () => setState(() =>
                                _selectedPaymentMethod =
                                    'Debit / Credit Card (Paystack)'),
                            child: Padding(
                              padding: const EdgeInsets.all(GVSpacing.md),
                              child: Row(
                                children: [
                                  Icon(
                                    _selectedPaymentMethod ==
                                            'Debit / Credit Card (Paystack)'
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                    color: _selectedPaymentMethod ==
                                            'Debit / Credit Card (Paystack)'
                                        ? GVColors.brandGreen
                                        : GVColors.textSecondary,
                                  ),
                                  const SizedBox(width: GVSpacing.sm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Debit / Credit Card (Paystack)',
                                            style: GVTypography.bodyMedium),
                                        Text('Mastercard, Visa, Verve',
                                            style: GVTypography.caption),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const Divider(height: 1),
                          InkWell(
                            onTap: () => setState(() =>
                                _selectedPaymentMethod =
                                    'Bank Transfer (Virtual NUBAN)'),
                            child: Padding(
                              padding: const EdgeInsets.all(GVSpacing.md),
                              child: Row(
                                children: [
                                  Icon(
                                    _selectedPaymentMethod ==
                                            'Bank Transfer (Virtual NUBAN)'
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                    color: _selectedPaymentMethod ==
                                            'Bank Transfer (Virtual NUBAN)'
                                        ? GVColors.brandGreen
                                        : GVColors.textSecondary,
                                  ),
                                  const SizedBox(width: GVSpacing.sm),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Bank Transfer (Virtual NUBAN)',
                                            style: GVTypography.bodyMedium),
                                        Text('Instant confirmation via Paystack',
                                            style: GVTypography.caption),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: GVSpacing.lg),

                    // Notice
                    Container(
                      padding: const EdgeInsets.all(GVSpacing.sm),
                      decoration: BoxDecoration(
                        color: GVColors.statusActiveBg,
                        borderRadius: BorderRadius.circular(GVBorderRadius.sm),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.security,
                              color: GVColors.brandGreen, size: 20),
                          const SizedBox(width: GVSpacing.xs),
                          Expanded(
                            child: Text(
                              'All payments are authenticated securely by Paystack. Go-Volts never stores raw card details.',
                              style: GVTypography.caption
                                  .copyWith(color: GVColors.deepGreen),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: GVSpacing.xl),

                    GVPrimaryButton(
                      label:
                          'Proceed to Pay ₦${_selectedAmount.toStringAsFixed(0)}',
                      isLoading: state.isProcessingTopUp,
                      onPressed: _handleInitiateTopUp,
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(GVSpacing.lg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: const BoxDecoration(
                color: GVColors.statusActiveBg,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check,
                  color: GVColors.brandGreen, size: 48),
            ),
            const SizedBox(height: GVSpacing.md),
            Text('Top-Up Successful!', style: GVTypography.h1),
            const SizedBox(height: GVSpacing.xs),
            Text(
              '₦${_creditedAmount?.toStringAsFixed(2) ?? '0.00'} has been credited to your Go-Volts wallet.',
              textAlign: TextAlign.center,
              style: GVTypography.bodyMedium,
            ),
            const SizedBox(height: GVSpacing.xl),
            GVPrimaryButton(
              label: 'Return to Wallet',
              onPressed: () => context.pop(),
            ),
          ],
        ),
      ),
    );
  }
}
