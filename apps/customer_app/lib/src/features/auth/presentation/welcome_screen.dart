import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';

/// A02 — Welcome / Value Proposition Screen
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GVColors.nearBlack,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: GVSpacing.xl),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: GVSpacing.sm,
                            vertical: GVSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: GVColors.deepGreen,
                            borderRadius: BorderRadius.circular(GVBorderRadius.full),
                            border: Border.all(
                              color: GVColors.brandGreen.withValues(alpha: 0.4),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.bolt_rounded,
                                size: 16,
                                color: GVColors.limeHighlight,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'GO-VOLTS NIGERIA',
                                style: GVTypography.caption.copyWith(
                                  color: GVColors.white,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: GVSpacing.lg),
                    Text(
                      'Zero-Emission\nMobility &\nFast Logistics.',
                      style: GVTypography.h1.copyWith(
                        color: GVColors.white,
                        height: 1.15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: GVSpacing.md),
                    Text(
                      'Experience clean, affordable electric rides, same-day delivery, and scheduled pickups across your city.',
                      style: GVTypography.body.copyWith(
                        color: GVColors.white.withValues(alpha: 0.75),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: GVSpacing.xl),
                    _buildFeatureCard(
                      icon: Icons.electric_scooter_rounded,
                      title: 'Instant Electric Rides',
                      subtitle: 'Silent, eco-friendly commutes with verified drivers.',
                    ),
                    const SizedBox(height: GVSpacing.sm),
                    _buildFeatureCard(
                      icon: Icons.local_shipping_rounded,
                      title: 'Same-Day Parcel Delivery',
                      subtitle: 'Swift doorstep logistics with digital proof of delivery.',
                    ),
                    const SizedBox(height: GVSpacing.sm),
                    _buildFeatureCard(
                      icon: Icons.calendar_month_rounded,
                      title: 'Scheduled Pickups',
                      subtitle: 'Book one-off or recurring collections at your convenience.',
                    ),
                    const SizedBox(height: GVSpacing.lg),
                  ],
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(GVSpacing.lg),
              decoration: BoxDecoration(
                color: GVColors.deepGreen.withValues(alpha: 0.4),
                border: Border(
                  top: BorderSide(
                    color: GVColors.white.withValues(alpha: 0.08),
                  ),
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GVPrimaryButton(
                    label: 'Get Started',
                    onPressed: () => context.push(AppRoutes.createAccount),
                  ),
                  const SizedBox(height: GVSpacing.sm),
                  GVOutlinedButton(
                    label: 'I Already Have an Account',
                    onPressed: () => context.push(AppRoutes.login),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(GVSpacing.md),
      decoration: BoxDecoration(
        color: GVColors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        border: Border.all(
          color: GVColors.white.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(GVSpacing.sm),
            decoration: BoxDecoration(
              color: GVColors.brandGreen.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(GVBorderRadius.sm),
            ),
            child: Icon(icon, color: GVColors.limeHighlight, size: 24),
          ),
          const SizedBox(width: GVSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GVTypography.h3.copyWith(
                    color: GVColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: GVTypography.bodySmall.copyWith(
                    color: GVColors.white.withValues(alpha: 0.65),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
