import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/wallet_notifier.dart';

/// Screen W07: Coupons, Promos & Discount Vouchers Manager.
class CouponsScreen extends ConsumerStatefulWidget {
  const CouponsScreen({super.key});

  @override
  ConsumerState<CouponsScreen> createState() => _CouponsScreenState();
}

class _CouponsScreenState extends ConsumerState<CouponsScreen> {
  final _codeController = TextEditingController();
  bool _isValidating = false;

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _handleApplyCode() async {
    final code = _codeController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    setState(() => _isValidating = true);

    try {
      final res = await ref.read(walletNotifierProvider.notifier).validateCoupon(code);
      if (!mounted) return;
      setState(() => _isValidating = false);

      final data = res['data'] as Map<String, dynamic>? ?? {};
      final discount = (data['discount_amount'] as num?)?.toDouble() ?? 0.0;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Voucher "$code" applied! Save ₦${discount.toStringAsFixed(0)} on your ride.'),
          backgroundColor: GVColors.brandGreen,
        ),
      );
      _codeController.clear();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isValidating = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Promo code "$code" is invalid or expired.'),
          backgroundColor: GVColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(walletNotifierProvider);
    final coupons = state.coupons;

    return Scaffold(
      backgroundColor: GVColors.softBackground,
      appBar: const GVTopBar(title: 'Coupons & Promos'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(GVSpacing.md),
          children: [
            // Promo Code Input Box
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
                  Text('Have a Promo Code?', style: GVTypography.h3),
                  const SizedBox(height: GVSpacing.xs),
                  Text(
                    'Enter your referral or campaign voucher code to unlock discounts.',
                    style: GVTypography.caption.copyWith(color: GVColors.textSecondary),
                  ),
                  const SizedBox(height: GVSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _codeController,
                          textCapitalization: TextCapitalization.characters,
                          decoration: InputDecoration(
                            hintText: 'e.g. VOLT500',
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 12),
                            border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.circular(GVBorderRadius.sm),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: GVSpacing.sm),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GVColors.deepGreen,
                          foregroundColor: Colors.white,
                          minimumSize: const Size(80, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(GVBorderRadius.sm),
                          ),
                        ),
                        onPressed: _isValidating ? null : _handleApplyCode,
                        child: _isValidating
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Apply'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: GVSpacing.lg),

            Text('Active Vouchers (${coupons.length})', style: GVTypography.h3),
            const SizedBox(height: GVSpacing.xs),

            if (coupons.isEmpty)
              Container(
                margin: const EdgeInsets.only(top: GVSpacing.sm),
                padding: const EdgeInsets.all(GVSpacing.xl),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(color: GVColors.border),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.confirmation_number_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No Active Vouchers',
                      style: GVTypography.h3.copyWith(color: GVColors.textPrimary),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Promotional vouchers and discounts created by Go-Volts administrators will appear here.',
                      textAlign: TextAlign.center,
                      style: GVTypography.caption.copyWith(color: GVColors.textSecondary),
                    ),
                  ],
                ),
              )
            else
              ...coupons.map(
              (c) => Container(
                margin: const EdgeInsets.only(bottom: GVSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  boxShadow: GVShadows.card,
                  border: Border.all(color: GVColors.border),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: GVSpacing.md, vertical: GVSpacing.sm),
                      decoration: const BoxDecoration(
                        color: GVColors.statusActiveBg,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(GVBorderRadius.md),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.confirmation_number_outlined,
                                  color: GVColors.brandGreen, size: 20),
                              const SizedBox(width: 6),
                              Text(
                                c.code,
                                style: GVTypography.h3.copyWith(
                                  color: GVColors.deepGreen,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                          InkWell(
                            onTap: () {
                              Clipboard.setData(ClipboardData(text: c.code));
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Code ${c.code} copied!'),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                const Icon(Icons.copy,
                                    size: 16, color: GVColors.brandGreen),
                                const SizedBox(width: 4),
                                Text(
                                  'Copy',
                                  style: GVTypography.caption.copyWith(
                                    color: GVColors.brandGreen,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(GVSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(c.title,
                              style: GVTypography.bodyMedium
                                  .copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          Text(
                            'Save ₦${c.discountAmountNaira.toStringAsFixed(0)} on orders above ₦${c.minOrderAmountNaira.toStringAsFixed(0)}',
                            style: GVTypography.bodySmall
                                .copyWith(color: GVColors.textSecondary),
                          ),
                          const Divider(height: GVSpacing.md),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Row(
                                  children: [
                                    const Icon(Icons.access_time,
                                        size: 14, color: GVColors.neutral400),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        'Expires: ${c.expiryDate.day}/${c.expiryDate.month}/${c.expiryDate.year}',
                                        style: GVTypography.caption,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: GVColors.softBackground,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  'Auto-Applies',
                                  style: GVTypography.caption.copyWith(
                                    color: GVColors.deepGreen,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
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
    );
  }
}
