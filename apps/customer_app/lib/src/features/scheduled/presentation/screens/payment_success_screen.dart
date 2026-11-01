import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../application/scheduled_booking_notifier.dart';

/// Screen 17 (SP-18): Payment Success Screen
/// Displays transaction confirmation, payment receipt details, and plan activation.
class PaymentSuccessScreen extends ConsumerWidget {
  const PaymentSuccessScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookingState = ref.watch(scheduledBookingNotifierProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF131A16) : Colors.white;
    final textColor = isDark ? Colors.white : GVColors.textPrimary;
    final subtextColor = isDark ? GVColors.neutral400 : GVColors.textSecondary;
    final cardBg = isDark ? const Color(0xFF1C2420) : const Color(0xFFF6F8F7);
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;

    final amountStr =
        bookingState.createdPlan != null &&
            bookingState.createdPlan!.totalAmountNgn > 0
        ? '₦${bookingState.createdPlan!.totalAmountNgn.toStringAsFixed(0)}'
        : '₦150,000';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded, size: 24, color: textColor),
          onPressed: () => context.go(AppRoutes.scheduledMyPlans),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: GVSpacing.md),

              // Confetti Green Check Badge
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: GVColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.check_circle_rounded,
                    size: 48,
                    color: GVColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: GVSpacing.md),

              Text(
                'Payment successful!',
                style: GVTypography.h1.copyWith(
                  color: textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: GVSpacing.xs),
              Text(
                'Your scheduled plan is now active.',
                textAlign: TextAlign.center,
                style: GVTypography.bodyMedium.copyWith(
                  color: subtextColor,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: GVSpacing.xl),

              // Payment Receipt Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(GVSpacing.md),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transaction ID',
                      style: GVTypography.bodySmall.copyWith(
                        color: subtextColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'GVD12345678',
                      style: GVTypography.labelLarge.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const Divider(height: 20),
                    Text(
                      'Paid on',
                      style: GVTypography.bodySmall.copyWith(
                        color: subtextColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tue, 5 Nov 2026, 10:32 AM',
                      style: GVTypography.bodyMedium.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const Divider(height: 20),
                    Text(
                      'Amount',
                      style: GVTypography.bodySmall.copyWith(
                        color: subtextColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      amountStr,
                      style: GVTypography.h2.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Primary CTA: View plan details
              GVButton(
                text: 'View plan details',
                onPressed: () {
                  context.push(AppRoutes.scheduledPlanDetails);
                },
              ),

              const SizedBox(height: GVSpacing.sm),

              // Secondary CTA: Download receipt
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Receipt downloaded successfully.'),
                        backgroundColor: GVColors.primary,
                      ),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(GVBorderRadius.md),
                    ),
                  ),
                  child: Text(
                    'Download receipt',
                    style: GVTypography.labelLarge.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: GVSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
