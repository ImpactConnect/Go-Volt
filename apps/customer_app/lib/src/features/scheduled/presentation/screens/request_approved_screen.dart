import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../application/scheduled_booking_notifier.dart';

/// Screen 15 (SP-16): Request Approved Screen
/// Informs customer of operational quote approval and displays the 48-hour payment deadline.
class RequestApprovedScreen extends ConsumerWidget {
  const RequestApprovedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scheduledBookingNotifierProvider);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF131A16) : Colors.white;
    final textColor = isDark ? Colors.white : GVColors.textPrimary;
    final subtextColor = isDark ? GVColors.neutral400 : GVColors.textSecondary;
    final cardBg = isDark ? const Color(0xFF1C2420) : const Color(0xFFF6F8F7);
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;

    final planRef = state.createdPlan?.planReference ?? 'SP-20261105-001';
    final amountStr =
        state.createdPlan != null && state.createdPlan!.totalAmountNgn > 0
        ? '₦${state.createdPlan!.totalAmountNgn.toStringAsFixed(0)}'
        : '₦150,000';

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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: GVSpacing.md),

              // Celebration Check Badge with Confetti
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
                'Request approved!',
                style: GVTypography.h1.copyWith(
                  color: textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: GVSpacing.xs),
              Text(
                'You can now complete payment to activate your scheduled plan.',
                textAlign: TextAlign.center,
                style: GVTypography.bodyMedium.copyWith(
                  color: subtextColor,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: GVSpacing.xl),

              // Approval Details Card
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
                      'Plan ID',
                      style: GVTypography.bodySmall.copyWith(
                        color: subtextColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      planRef,
                      style: GVTypography.labelLarge.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const Divider(height: 20),
                    Text(
                      'Valid until',
                      style: GVTypography.bodySmall.copyWith(
                        color: subtextColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Sat, 7 Nov 2026, 10:25 AM',
                      style: GVTypography.bodyMedium.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '(48 hours payment window per policy)',
                      style: GVTypography.bodySmall.copyWith(
                        color: subtextColor,
                        fontSize: 12,
                      ),
                    ),
                    const Divider(height: 20),
                    Text(
                      'Total amount',
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

              // Primary CTA: Proceed to payment
              GVButton(
                text: 'Proceed to payment',
                onPressed: () {
                  context.push(AppRoutes.scheduledPayment);
                },
              ),

              const SizedBox(height: GVSpacing.sm),

              // Secondary CTA: View plan details
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    context.push(AppRoutes.scheduledPlanDetails);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(GVBorderRadius.md),
                    ),
                  ),
                  child: Text(
                    'View plan details',
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
