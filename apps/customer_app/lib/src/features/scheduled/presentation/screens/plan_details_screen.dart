import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../application/scheduled_plans_notifier.dart';

/// Screen 19 (SP-20): Plan Details Screen
/// Displays subscription progress, entitlement ledger balance, route details, and management actions.
class PlanDetailsScreen extends ConsumerWidget {
  const PlanDetailsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scheduledPlansNotifierProvider);
    final plan =
        state.selectedPlan ??
        (state.plans.isNotEmpty ? state.plans.first : null);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF131A16) : Colors.white;
    final textColor = isDark ? Colors.white : GVColors.textPrimary;
    final subtextColor = isDark ? GVColors.neutral400 : GVColors.textSecondary;
    final cardBg = isDark ? const Color(0xFF1C2420) : const Color(0xFFF6F8F7);
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;

    if (plan == null) {
      return Scaffold(
        backgroundColor: bgColor,
        body: const Center(child: Text('No plan selected')),
      );
    }

    final amountPaidStr = plan.amountPaidNgn > 0
        ? '₦${plan.totalAmountNgn.toStringAsFixed(0)} (Paid)'
        : '₦${plan.totalAmountNgn.toStringAsFixed(0)}';

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Plan details',
          style: GVTypography.h2.copyWith(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.push(AppRoutes.scheduledManagePlan);
            },
            child: Text(
              'Edit',
              style: TextStyle(
                color: GVColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: GVSpacing.xs),

              // Plan Header Card
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
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: GVColors.primary.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            plan.isSchoolRun
                                ? Icons.school_rounded
                                : Icons.business_center_rounded,
                            color: GVColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plan.title,
                                style: GVTypography.h2.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                plan.planReference,
                                style: GVTypography.bodySmall.copyWith(
                                  color: subtextColor,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: GVColors.primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(
                              GVBorderRadius.full,
                            ),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(
                              color: GVColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const Divider(height: 24),

                    _buildInfoRow(
                      Icons.calendar_today_rounded,
                      '${plan.scheduledDays.first} - ${plan.scheduledDays.last}',
                      textColor,
                      subtextColor,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.date_range_rounded,
                      '${plan.startDate.day} ${_monthName(plan.startDate.month)} ${plan.startDate.year} - ${plan.expiryDate.day} ${_monthName(plan.expiryDate.month)} ${plan.expiryDate.year}',
                      textColor,
                      subtextColor,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.alt_route_rounded,
                      '${plan.totalTrips} trips (${plan.remainingTrips} remaining)',
                      textColor,
                      subtextColor,
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      Icons.payments_outlined,
                      amountPaidStr,
                      textColor,
                      subtextColor,
                    ),

                    const SizedBox(height: GVSpacing.md),

                    // Progress bar: 18 of 60 trips used
                    ClipRRect(
                      borderRadius: BorderRadius.circular(GVBorderRadius.full),
                      child: LinearProgressIndicator(
                        value: plan.usageProgress,
                        minHeight: 6,
                        backgroundColor: isDark
                            ? Colors.black26
                            : Colors.grey.withValues(alpha: 0.2),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          GVColors.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${plan.usedTrips} of ${plan.totalTrips} trips used',
                      style: GVTypography.bodySmall.copyWith(
                        color: subtextColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: GVSpacing.md),

              // Route Information Card
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
                    _buildRouteDetailRow(
                      icon: Icons.location_on_rounded,
                      iconColor: GVColors.primary,
                      title: 'Pickup',
                      value: plan.pickupLocation.address,
                      textColor: textColor,
                      subtextColor: subtextColor,
                    ),
                    const Divider(height: 20),
                    _buildRouteDetailRow(
                      icon: Icons.location_on_rounded,
                      iconColor: Colors.redAccent,
                      title: 'Destination',
                      value: plan.dropoffLocation.address,
                      textColor: textColor,
                      subtextColor: subtextColor,
                    ),
                    const Divider(height: 20),
                    _buildRouteDetailRow(
                      icon: Icons.access_time_rounded,
                      iconColor: subtextColor,
                      title: 'Pickup time',
                      value: plan.pickupTime,
                      textColor: textColor,
                      subtextColor: subtextColor,
                    ),
                    const Divider(height: 20),
                    _buildRouteDetailRow(
                      icon: Icons.alt_route_rounded,
                      iconColor: subtextColor,
                      title: 'Journey type',
                      value: 'One way',
                      textColor: textColor,
                      subtextColor: subtextColor,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: GVSpacing.xl),

              // Primary CTA: Manage plan
              GVButton(
                text: 'Manage plan',
                onPressed: () {
                  context.push(AppRoutes.scheduledManagePlan);
                },
              ),

              const SizedBox(height: GVSpacing.sm),

              // Secondary CTA: View upcoming trips
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    context.push(AppRoutes.scheduledUpcomingTrips);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(GVBorderRadius.md),
                    ),
                  ),
                  child: Text(
                    'View upcoming trips',
                    style: GVTypography.labelLarge.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: GVSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String text,
    Color textColor,
    Color subtextColor,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: subtextColor),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: GVTypography.bodySmall.copyWith(
              color: textColor,
              fontSize: 13,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRouteDetailRow({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required Color textColor,
    required Color subtextColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GVTypography.bodySmall.copyWith(
                  color: subtextColor,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: GVTypography.bodyMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _monthName(int month) {
    return switch (month) {
      1 => 'Jan',
      2 => 'Feb',
      3 => 'Mar',
      4 => 'Apr',
      5 => 'May',
      6 => 'Jun',
      7 => 'Jul',
      8 => 'Aug',
      9 => 'Sep',
      10 => 'Oct',
      11 => 'Nov',
      _ => 'Dec',
    };
  }
}
