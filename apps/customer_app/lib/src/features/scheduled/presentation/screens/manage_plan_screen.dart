import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../application/scheduled_plans_notifier.dart';

/// Screen 21 (SP-20 / SP-25): Manage Plan Screen
/// Dedicated action menu providing schedule edits, trip skips, pausing, driver changes, and renewals.
class ManagePlanScreen extends ConsumerWidget {
  const ManagePlanScreen({super.key});

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

    final plan = state.selectedPlan ??
        (state.plans.isNotEmpty ? state.plans.first : null);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Manage Plan',
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
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg, vertical: GVSpacing.sm),
          children: [
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.edit_calendar_rounded,
                    title: 'Edit schedule',
                    subtitle: 'Change dates, times or locations',
                    textColor: textColor,
                    subtextColor: subtextColor,
                    onTap: () {
                      context.push(AppRoutes.scheduledCalendar);
                    },
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    icon: Icons.event_busy_rounded,
                    title: 'Skip a trip',
                    subtitle:
                        'Skip and keep your entitlement (> 6 hours before pickup)',
                    textColor: textColor,
                    subtextColor: subtextColor,
                    onTap: () {
                      context.push(AppRoutes.scheduledSkipTrip);
                    },
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    icon: Icons.pause_circle_outline_rounded,
                    title: 'Pause plan',
                    subtitle: 'Temporarily stop upcoming trips',
                    textColor: textColor,
                    subtextColor: subtextColor,
                    onTap: () {
                      context.push(AppRoutes.scheduledPausePlan);
                    },
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    icon: Icons.card_giftcard_rounded,
                    title: 'Change package',
                    subtitle: 'Get a new quote',
                    textColor: textColor,
                    subtextColor: subtextColor,
                    onTap: () {
                      context.push(AppRoutes.scheduledPackagePricing);
                    },
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    icon: Icons.person_outline_rounded,
                    title: 'Edit passenger details',
                    subtitle: null,
                    textColor: textColor,
                    subtextColor: subtextColor,
                    onTap: () {
                      context.push(AppRoutes.scheduledPassengerDetails);
                    },
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    icon: Icons.airline_seat_recline_normal_rounded,
                    title: 'Change driver',
                    subtitle: 'Request a different driver',
                    textColor: textColor,
                    subtextColor: subtextColor,
                    onTap: () {
                      context.push(AppRoutes.scheduledPreferredDriver);
                    },
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    icon: Icons.cancel_outlined,
                    iconColor: GVColors.error,
                    title: 'Cancel plan',
                    subtitle: 'End this plan',
                    textColor: GVColors.error,
                    subtextColor: subtextColor,
                    onTap: () async {
                      if (plan != null) {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Cancel Plan?'),
                            content: const Text(
                              'Are you sure you want to cancel this plan? Remaining entitlements will be handled per refund terms.',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Keep Plan'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Cancel Plan',
                                    style: TextStyle(color: GVColors.error)),
                              ),
                            ],
                          ),
                        );
                        if (confirm == true) {
                          await notifier.cancelPlan(
                            planId: plan.id,
                            reason: 'Customer initiated cancellation',
                          );
                          if (context.mounted) {
                            context.go(AppRoutes.scheduledMyPlans);
                          }
                        }
                      }
                    },
                  ),
                  const Divider(height: 1),
                  _buildMenuItem(
                    icon: Icons.sync_rounded,
                    title: 'Renew plan',
                    subtitle: 'Get a new quote to continue',
                    textColor: textColor,
                    subtextColor: subtextColor,
                    onTap: () {
                      context.push(AppRoutes.scheduledRenewPlan);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    Color? iconColor,
    required String title,
    String? subtitle,
    required Color textColor,
    required Color subtextColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: iconColor ?? subtextColor),
            const SizedBox(width: 14),
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
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: GVTypography.bodySmall.copyWith(
                        color: subtextColor,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                size: 14, color: subtextColor),
          ],
        ),
      ),
    );
  }
}
