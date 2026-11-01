import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../application/scheduled_booking_notifier.dart';

/// Screen 10 (SP-11 / SP-12): Package & Pricing Screen
/// Selects commercial arrangement: Pay per trip vs. Weekly vs. Monthly entitlement package.
class PackagePricingScreen extends ConsumerWidget {
  const PackagePricingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scheduledBookingNotifierProvider);
    final notifier = ref.read(scheduledBookingNotifierProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF131A16) : Colors.white;
    final textColor = isDark ? Colors.white : GVColors.textPrimary;
    final subtextColor = isDark ? GVColors.neutral400 : GVColors.textSecondary;
    final cardBg = isDark ? const Color(0xFF1C2420) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: textColor,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: GVSpacing.xs),
              Text(
                'Choose a package',
                style: GVTypography.h1.copyWith(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: GVSpacing.xl),

              // Option 1: Pay per trip
              _buildPackageCard(
                title: 'Pay per trip',
                subtitle: 'Pay for each scheduled trip',
                isSelected:
                    state.billingModel == PackageBillingModel.payPerTrip,
                icon: Icons.payments_outlined,
                onTap: () {
                  notifier.setBillingModel(PackageBillingModel.payPerTrip);
                },
                cardBg: cardBg,
                borderColor: borderColor,
                textColor: textColor,
                subtextColor: subtextColor,
              ),

              const SizedBox(height: GVSpacing.md),

              // Option 2: Weekly package
              _buildPackageCard(
                title: 'Weekly package',
                subtitle: 'Fixed price for weekly trips',
                isSelected:
                    state.billingModel == PackageBillingModel.weeklyPackage,
                icon: Icons.calendar_view_week_rounded,
                onTap: () {
                  notifier.setBillingModel(PackageBillingModel.weeklyPackage);
                },
                cardBg: cardBg,
                borderColor: borderColor,
                textColor: textColor,
                subtextColor: subtextColor,
              ),

              const SizedBox(height: GVSpacing.md),

              // Option 3: Monthly package
              _buildPackageCard(
                title: 'Monthly package',
                subtitle: 'Fixed price for monthly trips',
                isSelected:
                    state.billingModel == PackageBillingModel.monthlyPackage,
                icon: Icons.calendar_view_month_rounded,
                onTap: () {
                  notifier.setBillingModel(PackageBillingModel.monthlyPackage);
                },
                cardBg: cardBg,
                borderColor: borderColor,
                textColor: textColor,
                subtextColor: subtextColor,
              ),

              const SizedBox(height: GVSpacing.xl),

              // Estimated Price Banner Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(GVSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E6),
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(color: const Color(0xFFFFE082)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estimated price per trip',
                      style: GVTypography.labelSmall.copyWith(
                        color: const Color(0xFF8D6E18),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '₦2,500',
                      style: GVTypography.h2.copyWith(
                        color: const Color(0xFF3E2723),
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Final price will be shown in the review.',
                      style: GVTypography.bodySmall.copyWith(
                        color: const Color(0xFF6D4C41),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // CTA: Continue
              GVButton(
                text: 'Continue',
                onPressed: () {
                  context.push(AppRoutes.scheduledReviewQuote);
                },
              ),
              const SizedBox(height: GVSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPackageCard({
    required String title,
    required String subtitle,
    required bool isSelected,
    required IconData icon,
    required VoidCallback onTap,
    required Color cardBg,
    required Color borderColor,
    required Color textColor,
    required Color subtextColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GVBorderRadius.md),
      child: Container(
        padding: const EdgeInsets.all(GVSpacing.md),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(GVBorderRadius.md),
          border: Border.all(
            color: isSelected ? GVColors.primary : borderColor,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? GVColors.primary.withValues(alpha: 0.12)
                    : Colors.grey.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 20,
                color: isSelected ? GVColors.primary : textColor,
              ),
            ),
            const SizedBox(width: GVSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GVTypography.labelMedium.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GVTypography.bodySmall.copyWith(
                      color: subtextColor,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_off_rounded,
              color: isSelected ? GVColors.primary : Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
