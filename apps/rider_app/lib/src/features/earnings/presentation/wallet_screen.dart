import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Screen RD21: Driver Wallet Hub (Board 4 Screen 3).
class WalletScreen extends ConsumerWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          'Wallet',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () => context.push('/account/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(GVSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Available Balance Card
              Container(
                padding: const EdgeInsets.all(GVSpacing.lg),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [GVColors.deepGreen, Color(0xFF133B26)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(GVBorderRadius.lg),
                  boxShadow: GVShadows.elevated,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Available Balance',
                          style: GVTypography.caption.copyWith(color: Colors.white70),
                        ),
                        const Icon(
                          Icons.account_balance_wallet,
                          color: GVColors.brandGreen,
                          size: 24,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₦22,050',
                      style: GVTypography.h1.copyWith(
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: GVSpacing.md),
                    Row(
                      children: [
                        ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: GVColors.brandGreen,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(GVBorderRadius.full),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                          icon: const Icon(Icons.arrow_upward, size: 16),
                          label: const Text('Withdraw', style: TextStyle(fontWeight: FontWeight.bold)),
                          onPressed: () => context.push('/wallet/withdraw'),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white38),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(GVBorderRadius.full),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          ),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Add Bank'),
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Link a new NUBAN bank account')),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GVSpacing.lg),

              // Quick Actions Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildQuickAction(
                    icon: Icons.arrow_upward,
                    label: 'Withdraw',
                    onTap: () => context.push('/wallet/withdraw'),
                  ),
                  _buildQuickAction(
                    icon: Icons.account_balance,
                    label: 'Bank Account',
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Manage linked bank accounts')),
                      );
                    },
                  ),
                  _buildQuickAction(
                    icon: Icons.history,
                    label: 'Transaction\nHistory',
                    onTap: () => context.push('/wallet/payouts'),
                  ),
                  _buildQuickAction(
                    icon: Icons.bar_chart,
                    label: 'Earnings\nReport',
                    onTap: () => context.push('/earnings/details'),
                  ),
                ],
              ),
              const SizedBox(height: GVSpacing.xl),

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

              // Wallet Summary Section
              Text(
                'Wallet Summary',
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
                child: Column(
                  children: [
                    _buildSummaryRow('Available Balance', '₦22,050', GVColors.brandGreen),
                    const Divider(color: Colors.white12, height: GVSpacing.md),
                    _buildSummaryRow('Pending Balance', '₦5,200', Colors.amber),
                    const Divider(color: Colors.white12, height: GVSpacing.md),
                    _buildSummaryRow('Total Earned (This Month)', '₦186,400', Colors.white),
                  ],
                ),
              ),
              const SizedBox(height: GVSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GVBorderRadius.md),
      child: SizedBox(
        width: 76,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2420),
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                border: Border.all(color: const Color(0xFF2A3630)),
              ),
              child: Icon(icon, color: GVColors.brandGreen, size: 24),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              textAlign: TextAlign.center,
              style: GVTypography.caption.copyWith(
                color: Colors.white70,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color valueColor) {
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
            color: valueColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
