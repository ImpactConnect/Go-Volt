import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../application/scheduled_booking_notifier.dart';
import '../../application/scheduled_plans_notifier.dart';

/// Screen 14 (SP-15): Approval Status Screen
/// Real-time 5-stage progress timeline tracking operations review, approval, payment, and plan activation.
class ApprovalStatusScreen extends ConsumerWidget {
  const ApprovalStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scheduledBookingNotifierProvider);
    final plansNotifier = ref.read(scheduledPlansNotifierProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF131A16) : Colors.white;
    final textColor = isDark ? Colors.white : GVColors.textPrimary;
    final subtextColor = isDark ? GVColors.neutral400 : GVColors.textSecondary;
    final cardBg = isDark ? const Color(0xFF1C2420) : const Color(0xFFF6F8F7);
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;

    final planRef = state.createdPlan?.planReference ?? 'SP-20261105-001';

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
                'Approval status',
                style: GVTypography.h1.copyWith(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: GVSpacing.xl),

              // Vertical Status Timeline Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(GVSpacing.md),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    // Step 1: Request submitted (Completed)
                    _buildTimelineStep(
                      isCompleted: true,
                      isCurrent: false,
                      title: 'Request submitted',
                      subtitle: '5 Nov 2026, 10:25 AM',
                      textColor: textColor,
                      subtextColor: subtextColor,
                      showConnector: true,
                    ),

                    // Step 2: Under review (Current)
                    _buildTimelineStep(
                      isCompleted: false,
                      isCurrent: true,
                      title: 'Under review',
                      subtitle:
                          'We\'re reviewing your request. This usually takes less than 24 hours.',
                      textColor: textColor,
                      subtextColor: subtextColor,
                      showConnector: true,
                    ),

                    // Step 3: Approved (Pending)
                    _buildTimelineStep(
                      isCompleted: false,
                      isCurrent: false,
                      title: 'Approved',
                      subtitle: 'Pending',
                      textColor: textColor,
                      subtextColor: subtextColor,
                      showConnector: true,
                    ),

                    // Step 4: Payment (Pending)
                    _buildTimelineStep(
                      isCompleted: false,
                      isCurrent: false,
                      title: 'Payment',
                      subtitle: 'Pending',
                      textColor: textColor,
                      subtextColor: subtextColor,
                      showConnector: true,
                    ),

                    // Step 5: Plan active (Pending)
                    _buildTimelineStep(
                      isCompleted: false,
                      isCurrent: false,
                      title: 'Plan active',
                      subtitle: 'Pending',
                      textColor: textColor,
                      subtextColor: subtextColor,
                      showConnector: false,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: GVSpacing.md),

              // Request ID row
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Request ID',
                      style: GVTypography.bodySmall.copyWith(
                        color: subtextColor,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      planRef,
                      style: GVTypography.labelMedium.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Quick Action: Simulate Operations Approval (for testing)
              InkWell(
                onTap: () async {
                  final planId = state.createdPlan?.id ?? 'plan-001';
                  await plansNotifier.simulateApproval(planId);
                  if (context.mounted) {
                    context.push(AppRoutes.scheduledRequestApproved);
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: GVColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bolt_rounded,
                          size: 18, color: GVColors.primary),
                      const SizedBox(width: 6),
                      Text(
                        'Simulate operations approval (Test flow)',
                        style: TextStyle(
                          color: GVColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: GVSpacing.md),

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

  Widget _buildTimelineStep({
    required bool isCompleted,
    required bool isCurrent,
    required String title,
    required String subtitle,
    required Color textColor,
    required Color subtextColor,
    required bool showConnector,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted
                    ? GVColors.primary
                    : isCurrent
                        ? const Color(0xFFFFB800)
                        : Colors.grey.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : isCurrent
                        ? Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          )
                        : null,
              ),
            ),
            if (showConnector)
              Container(
                width: 2,
                height: 36,
                color: isCompleted
                    ? GVColors.primary
                    : Colors.grey.withValues(alpha: 0.3),
              ),
          ],
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GVTypography.labelMedium.copyWith(
                  color: isCurrent
                      ? const Color(0xFFD97706)
                      : isCompleted
                          ? textColor
                          : subtextColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: GVTypography.bodySmall.copyWith(
                  color: subtextColor,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ],
    );
  }
}
