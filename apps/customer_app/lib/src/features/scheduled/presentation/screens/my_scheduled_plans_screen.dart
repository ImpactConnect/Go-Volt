import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../application/scheduled_plans_notifier.dart';

/// Screen 18 (SP-19): My Scheduled Plans Screen
/// Central dashboard filtering plans by Active, Upcoming, and Past with actions and quick creation.
class MyScheduledPlansScreen extends ConsumerWidget {
  const MyScheduledPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scheduledPlansNotifierProvider);
    final notifier = ref.read(scheduledPlansNotifierProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF131A16) : Colors.white;
    final textColor = isDark ? Colors.white : GVColors.textPrimary;
    final subtextColor = isDark ? GVColors.neutral400 : GVColors.textSecondary;
    final cardBg = isDark ? const Color(0xFF1C2420) : const Color(0xFFF6F8F7);
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;

    final currentList = switch (state.activeTabIndex) {
      1 => state.upcomingPlans,
      2 => state.pastPlans,
      _ => state.activePlans,
    };

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'My Scheduled Plans',
          style: GVTypography.h2.copyWith(
            color: textColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: textColor,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.home);
            }
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: GVColors.primary,
        elevation: 4,
        onPressed: () {
          context.push(AppRoutes.scheduledBookingType);
        },
        child: const Icon(Icons.add_rounded, size: 30, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Tabs: [Active (2)] [Upcoming (1)] [Past (3)]
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg, vertical: GVSpacing.sm),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildTabButton(
                        title: 'Active (${state.activePlans.length})',
                        isSelected: state.activeTabIndex == 0,
                        onTap: () => notifier.setActiveTab(0),
                      ),
                    ),
                    Expanded(
                      child: _buildTabButton(
                        title: 'Upcoming (${state.upcomingPlans.length})',
                        isSelected: state.activeTabIndex == 1,
                        onTap: () => notifier.setActiveTab(1),
                      ),
                    ),
                    Expanded(
                      child: _buildTabButton(
                        title: 'Past (${state.pastPlans.length})',
                        isSelected: state.activeTabIndex == 2,
                        onTap: () => notifier.setActiveTab(2),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: GVSpacing.xs),

            // Plan Cards List
            Expanded(
              child: currentList.isEmpty
                  ? Center(
                      child: Text(
                        'No plans in this category.',
                        style: GVTypography.bodyMedium.copyWith(color: subtextColor),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(GVSpacing.lg),
                      itemCount: currentList.length,
                      itemBuilder: (context, index) {
                        final plan = currentList[index];
                        return _buildPlanCard(
                          context: context,
                          plan: plan,
                          cardBg: cardBg,
                          borderColor: borderColor,
                          textColor: textColor,
                          subtextColor: subtextColor,
                          onViewDetails: () {
                            notifier.selectPlan(plan);
                            context.push(AppRoutes.scheduledPlanDetails);
                          },
                          onManage: () {
                            notifier.selectPlan(plan);
                            context.push(AppRoutes.scheduledManagePlan);
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required BuildContext context,
    required ScheduledPlanDto plan,
    required Color cardBg,
    required Color borderColor,
    required Color textColor,
    required Color subtextColor,
    required VoidCallback onViewDetails,
    required VoidCallback onManage,
  }) {
    final isActive = plan.status == PlanStatus.active;
    final badgeColor = isActive ? GVColors.primary : const Color(0xFFFF9800);
    final badgeText = isActive ? 'Active' : 'Upcoming';
    final amountPaidStr = plan.amountPaidNgn > 0
        ? '₦${plan.totalAmountNgn.toStringAsFixed(0)} (Paid)'
        : '₦${plan.totalAmountNgn.toStringAsFixed(0)}';

    return Container(
      margin: const EdgeInsets.only(bottom: GVSpacing.md),
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
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: GVColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  plan.isSchoolRun
                      ? Icons.school_rounded
                      : Icons.business_center_rounded,
                  color: GVColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      plan.title,
                      style: GVTypography.labelLarge.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      plan.dropoffLocation.label ?? plan.dropoffLocation.address,
                      style: GVTypography.bodySmall.copyWith(
                        color: subtextColor,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(GVBorderRadius.full),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: badgeColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),

          const Divider(height: 24),

          _buildCardInfoRow(
            Icons.calendar_today_rounded,
            '${plan.scheduledDays.first} - ${plan.scheduledDays.last}',
            textColor,
            subtextColor,
          ),
          const SizedBox(height: 6),
          _buildCardInfoRow(
            Icons.date_range_rounded,
            '${plan.startDate.day} ${_monthName(plan.startDate.month)} ${plan.startDate.year} - ${plan.expiryDate.day} ${_monthName(plan.expiryDate.month)} ${plan.expiryDate.year}',
            textColor,
            subtextColor,
          ),
          const SizedBox(height: 6),
          _buildCardInfoRow(
            Icons.alt_route_rounded,
            '${plan.totalTrips} trips (${plan.remainingTrips} remaining)',
            textColor,
            subtextColor,
          ),
          const SizedBox(height: 6),
          _buildCardInfoRow(
            Icons.payments_outlined,
            amountPaidStr,
            textColor,
            subtextColor,
          ),

          const SizedBox(height: GVSpacing.md),

          // Action Buttons: View details & Manage
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: OutlinedButton(
                    onPressed: onViewDetails,
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(GVBorderRadius.sm),
                      ),
                    ),
                    child: Text(
                      'View details',
                      style: GVTypography.labelSmall.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    onPressed: onManage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cardBg,
                      elevation: 0,
                      side: BorderSide(color: borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(GVBorderRadius.sm),
                      ),
                    ),
                    child: Text(
                      'Manage',
                      style: GVTypography.labelSmall.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCardInfoRow(
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

  Widget _buildTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GVBorderRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? GVColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(GVBorderRadius.sm),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : GVColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 13,
            ),
          ),
        ),
      ),
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

