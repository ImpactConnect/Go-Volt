import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/rider_earnings_notifier.dart';

/// Screen RD22: Withdraw Earnings to Bank Account (Board 4 Screen 4).
class WithdrawEarningsScreen extends ConsumerStatefulWidget {
  const WithdrawEarningsScreen({super.key});

  @override
  ConsumerState<WithdrawEarningsScreen> createState() =>
      _WithdrawEarningsScreenState();
}

class _WithdrawEarningsScreenState extends ConsumerState<WithdrawEarningsScreen> {
  final _amountController = TextEditingController(text: '20,000');
  bool _isProcessing = false;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  void _handleConfirm() async {
    setState(() => _isProcessing = true);
    await ref
        .read(riderEarningsNotifierProvider.notifier)
        .requestInstantWithdrawal(20000 * 100);
    if (mounted) {
      setState(() => _isProcessing = false);
      if (context.mounted) {
        await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: const Color(0xFF1C2420),
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: GVColors.brandGreen),
              SizedBox(width: 8),
              Text('Withdrawal Submitted', style: TextStyle(color: Colors.white)),
            ],
          ),
          content: const Text(
            'Your payout of ₦20,000 has been sent to GTBank (**** 1234). Expected within minutes.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: GVColors.brandGreen),
              onPressed: () {
                Navigator.of(ctx).pop();
                context.pushReplacement('/wallet/payouts');
              },
              child: const Text('View Payout History', style: TextStyle(color: Colors.black)),
            ),
          ],
        ),
      );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GVColors.darkBg,
      appBar: AppBar(
        backgroundColor: GVColors.darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Withdraw Earnings',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(GVSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Info Banner
              Container(
                padding: const EdgeInsets.all(GVSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xFF132A1C),
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(color: GVColors.brandGreen.withValues(alpha: 0.3)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: GVColors.brandGreen, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Withdraw to your linked bank account. Withdrawals are usually processed within a few minutes.',
                        style: GVTypography.caption.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GVSpacing.lg),

              // Linked Bank Account Section
              Text(
                'Linked Bank Account',
                style: GVTypography.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: GVSpacing.xs),
              Container(
                padding: const EdgeInsets.all(GVSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2420),
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(color: const Color(0xFF2A3630)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE65100),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Text(
                          'GT',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: GVSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'GTBank',
                            style: GVTypography.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '**** 1234',
                            style: GVTypography.caption.copyWith(color: Colors.white60),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white38),
                  ],
                ),
              ),
              const SizedBox(height: GVSpacing.xl),

              // Withdrawal Amount Input
              Text(
                'Withdrawal Amount',
                style: GVTypography.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: GVSpacing.xs),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2420),
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(color: const Color(0xFF2A3630)),
                ),
                child: Row(
                  children: [
                    Text(
                      '₦ ',
                      style: GVTypography.h2.copyWith(
                        color: GVColors.brandGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        style: GVTypography.h2.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: '0',
                          hintStyle: TextStyle(color: Colors.white38),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Available Balance: ₦22,050',
                style: GVTypography.caption.copyWith(color: Colors.white60),
              ),
              const SizedBox(height: GVSpacing.xl),

              // Withdrawal Summary
              Container(
                padding: const EdgeInsets.all(GVSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2420),
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(color: const Color(0xFF2A3630)),
                ),
                child: Column(
                  children: [
                    _buildSummaryRow('Amount', '₦20,000'),
                    const SizedBox(height: 10),
                    _buildSummaryRow('Processing Fee', '₦0'),
                    const Divider(color: Colors.white12, height: GVSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'You will receive',
                          style: GVTypography.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₦20,000',
                          style: GVTypography.h3.copyWith(
                            color: GVColors.brandGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GVSpacing.xxl),

              // Confirm Withdrawal Button
              GVPrimaryButton(
                label: _isProcessing ? 'Processing...' : 'Confirm Withdrawal',
                onPressed: _isProcessing ? () {} : _handleConfirm,
              ),
              const SizedBox(height: GVSpacing.md),

              // Security Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, color: Colors.white38, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    'Your earnings are safe and secure with Go-Volts.',
                    style: GVTypography.caption.copyWith(
                      color: Colors.white38,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: GVSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GVTypography.bodyMedium.copyWith(color: Colors.white70),
        ),
        Text(
          value,
          style: GVTypography.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
