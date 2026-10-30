import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Screen for Detailed Earnings Breakdown (Board 4 Screen 2).
class EarningsDetailsScreen extends ConsumerStatefulWidget {
  const EarningsDetailsScreen({super.key});

  @override
  ConsumerState<EarningsDetailsScreen> createState() =>
      _EarningsDetailsScreenState();
}

class _EarningsDetailsScreenState extends ConsumerState<EarningsDetailsScreen> {
  String _selectedPeriod = 'Today';
  final List<String> _periods = ['Today', 'This Week', 'This Month'];

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
          'Earnings Details',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(GVSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Period Filter Tabs
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2420),
                  borderRadius: BorderRadius.circular(GVBorderRadius.full),
                ),
                child: Row(
                  children: _periods.map((period) {
                    final isSelected = period == _selectedPeriod;
                    return Expanded(
                      child: InkWell(
                        onTap: () => setState(() => _selectedPeriod = period),
                        borderRadius: BorderRadius.circular(GVBorderRadius.full),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? GVColors.brandGreen : Colors.transparent,
                            borderRadius: BorderRadius.circular(GVBorderRadius.full),
                          ),
                          child: Text(
                            period,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: isSelected ? Colors.black : Colors.white70,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: GVSpacing.md),

              // Date Picker Banner
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2420),
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(color: const Color(0xFF2A3630)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, color: GVColors.brandGreen, size: 18),
                        const SizedBox(width: 10),
                        Text(
                          'Tue, 24 Oct 2026',
                          style: GVTypography.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Icon(Icons.event, color: Colors.white60, size: 20),
                  ],
                ),
              ),
              const SizedBox(height: GVSpacing.md),

              // Total Earnings Card
              Container(
                padding: const EdgeInsets.all(GVSpacing.lg),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [GVColors.deepGreen, Color(0xFF133B26)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  boxShadow: GVShadows.elevated,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Earnings',
                      style: GVTypography.caption.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₦24,500',
                      style: GVTypography.h1.copyWith(
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '12 trips completed',
                      style: GVTypography.caption.copyWith(color: GVColors.limeHighlight),
                    ),
                    const Divider(color: Colors.white24, height: GVSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildQuickStat('Trip Earnings', '₦21,500'),
                        _buildQuickStat('Bonuses', '₦2,000'),
                        _buildQuickStat('Tips', '₦1,000'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GVSpacing.lg),

              // Earnings Breakdown Section
              Text(
                'Earnings Breakdown',
                style: GVTypography.h3.copyWith(color: Colors.white),
              ),
              const SizedBox(height: GVSpacing.sm),
              Container(
                padding: const EdgeInsets.all(GVSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2420),
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(color: const Color(0xFF2A3630)),
                ),
                child: Column(
                  children: [
                    _buildBreakdownRow(
                      icon: Icons.two_wheeler,
                      label: 'Ride Fare',
                      amount: '₦21,500',
                      amountColor: Colors.white,
                    ),
                    const Divider(color: Colors.white12, height: GVSpacing.md),
                    _buildBreakdownRow(
                      icon: Icons.card_giftcard,
                      label: 'Bonuses (Promo)',
                      amount: '₦2,000',
                      amountColor: Colors.white,
                    ),
                    const Divider(color: Colors.white12, height: GVSpacing.md),
                    _buildBreakdownRow(
                      icon: Icons.volunteer_activism,
                      label: 'Tips from Riders',
                      amount: '₦1,000',
                      amountColor: Colors.white,
                    ),
                    const Divider(color: Colors.white12, height: GVSpacing.md),
                    _buildBreakdownRow(
                      icon: Icons.pie_chart_outline,
                      label: 'Platform Fee (10%)',
                      amount: '- ₦2,450',
                      amountColor: Colors.redAccent,
                    ),
                    const Divider(color: Colors.white24, height: GVSpacing.lg),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Net Earnings',
                          style: GVTypography.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '₦22,050',
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
              const SizedBox(height: GVSpacing.xl),

              // Download Statement Action
              GVOutlinedButton(
                label: 'Download Statement',
                icon: Icons.download,
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Statement for 24 Oct 2026 downloaded (PDF)'),
                    ),
                  );
                },
              ),
              const SizedBox(height: GVSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GVTypography.caption.copyWith(color: Colors.white60, fontSize: 11),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: GVTypography.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBreakdownRow({
    required IconData icon,
    required String label,
    required String amount,
    required Color amountColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(icon, color: GVColors.brandGreen, size: 18),
            const SizedBox(width: 10),
            Text(
              label,
              style: GVTypography.bodyMedium.copyWith(color: Colors.white),
            ),
          ],
        ),
        Text(
          amount,
          style: GVTypography.bodyMedium.copyWith(
            color: amountColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
