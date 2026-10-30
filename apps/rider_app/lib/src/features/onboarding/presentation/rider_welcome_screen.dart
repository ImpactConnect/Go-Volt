import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Screen RD01: Rider Welcome & Value Proposition Landing.
class RiderWelcomeScreen extends StatelessWidget {
  const RiderWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GVColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: GVSpacing.xl),
                    // Header Brand & Icon
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: GVColors.deepGreen,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: GVColors.brandGreen,
                            width: 2,
                          ),
                          boxShadow: GVShadows.glow,
                        ),
                        child: const Icon(
                          Icons.two_wheeler,
                          color: GVColors.brandGreen,
                          size: 38,
                        ),
                      ),
                    ),
                    const SizedBox(height: GVSpacing.md),
                    const Center(
                      child: GVStatusChip(
                        label: 'ZERO PETROL · WEEKLY PAYOUTS',
                        status: GVStatusType.active,
                      ),
                    ),
                    const SizedBox(height: GVSpacing.md),
                    Text(
                      'Ride Green. Earn Fair. Power Lagos.',
                      textAlign: TextAlign.center,
                      style: GVTypography.h1.copyWith(
                        color: Colors.white,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: GVSpacing.sm),
                    Text(
                      'Join Lagos’ premier electric motorcycle fleet. Keep 80% of your earnings with zero petrol expenses and fast battery swapping.',
                      textAlign: TextAlign.center,
                      style: GVTypography.bodyMedium.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: GVSpacing.xl),

                    // Value Propositions Cards
                    _buildBenefitCard(
                      icon: Icons.account_balance_wallet,
                      title: 'Guaranteed Weekly Settlement',
                      subtitle:
                          'Direct bank transfers every Tuesday morning. Full transparency with no hidden deductions.',
                    ),
                    const SizedBox(height: GVSpacing.sm),
                    _buildBenefitCard(
                      icon: Icons.electric_bolt,
                      title: 'Free EV Battery Swapping',
                      subtitle:
                          'Swap empty batteries in under 90 seconds at over 25 swapping stations across Lagos Island & Mainland.',
                    ),
                    const SizedBox(height: GVSpacing.sm),
                    _buildBenefitCard(
                      icon: Icons.verified_user,
                      title: 'Insurance & Safety Coverage',
                      subtitle:
                          'Comprehensive personal accident and third-party liability insurance for all certified Go-Volts riders.',
                    ),
                    const SizedBox(height: GVSpacing.sm),
                    _buildBenefitCard(
                      icon: Icons.pie_chart,
                      title: 'Transparent 20% Platform Fee',
                      subtitle:
                          'You take home 80% of every ride and delivery fare. 100% of tips belong entirely to you.',
                    ),
                    const SizedBox(height: GVSpacing.xl),
                  ],
                ),
              ),
            ),

            // Bottom CTA Actions
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: const BoxDecoration(
                color: Color(0xFF141917),
                border: Border(
                  top: BorderSide(color: Color(0xFF232D28), width: 1),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  GVPrimaryButton(
                    label: 'Apply to Ride with Go-Volts',
                    onPressed: () => context.push('/onboarding/personal'),
                  ),
                  const SizedBox(height: GVSpacing.xs),
                  GVSecondaryButton(
                    label: 'Rider Sign In',
                    onPressed: () => context.push('/onboarding/status'),
                  ),
                  const SizedBox(height: GVSpacing.xs),
                  Text(
                    'Regulated & compliant with Lagos State Ministry of Transportation (MOT)',
                    textAlign: TextAlign.center,
                    style: GVTypography.caption.copyWith(color: Colors.white38),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(GVSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2420),
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        border: Border.all(color: const Color(0xFF2A3630)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: GVColors.deepGreen,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: GVColors.brandGreen, size: 22),
          ),
          const SizedBox(width: GVSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GVTypography.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GVTypography.caption.copyWith(color: Colors.white60),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
