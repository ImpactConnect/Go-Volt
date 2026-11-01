import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../application/scheduled_notifier.dart';

/// SP10 - SP18: Scheduled Pickup & Commute Plans Management Screen.
class ScheduledPlansScreen extends ConsumerStatefulWidget {
  const ScheduledPlansScreen({super.key});

  @override
  ConsumerState<ScheduledPlansScreen> createState() =>
      _ScheduledPlansScreenState();
}

class _ScheduledPlansScreenState extends ConsumerState<ScheduledPlansScreen> {
  void _showSkipTripDialog(BuildContext context, ScheduledPlanDto plan) {
    final tomorrowMorning = DateTime.now().add(const Duration(hours: 18));
    final canPreserve = plan.canSkipWithoutPenalty(tomorrowMorning);

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Skip Next Trip?', style: GVTypography.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Next Trip: ${plan.pickupTime}, ${plan.pickupLocation.label} → ${plan.dropoffLocation.label}',
              style: GVTypography.bodySmallMedium,
            ),
            const SizedBox(height: GVSpacing.sm),
            Container(
              padding: const EdgeInsets.all(GVSpacing.sm),
              decoration: BoxDecoration(
                color: canPreserve
                    ? GVColors.statusActiveBg
                    : GVColors.warning.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(GVBorderRadius.sm),
              ),
              child: Row(
                children: [
                  Icon(
                    canPreserve ? Icons.check_circle : Icons.warning_amber,
                    color: canPreserve ? GVColors.brandGreen : GVColors.warning,
                    size: 20,
                  ),
                  const SizedBox(width: GVSpacing.xs),
                  Expanded(
                    child: Text(
                      canPreserve
                          ? '6+ hours before pickup: Your trip credit will be PRESERVED.'
                          : 'Late skip (under 6h): Your trip credit will be FORFEITED per policy.',
                      style: GVTypography.bodySmallMedium.copyWith(
                        color: canPreserve
                            ? GVColors.brandGreen
                            : GVColors.nearBlack,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Back'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: GVColors.brandGreen,
              foregroundColor: GVColors.deepGreen,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref
                  .read(scheduledNotifierProvider.notifier)
                  .skipNextTrip(plan.id, tomorrowMorning);
              if (context.mounted) {
                final message =
                    ref.read(scheduledNotifierProvider).actionMessage;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(message ?? 'Trip skipped successfully.'),
                    backgroundColor: GVColors.brandGreen,
                  ),
                );
              }
            },
            child: const Text('Confirm Skip'),
          ),
        ],
      ),
    );
  }

  void _showCancellationPolicyDialog(
      BuildContext context, ScheduledPlanDto plan) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Cancel Subscription Plan?', style: GVTypography.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Remaining unused trips: ${plan.remainingTrips} of ${plan.totalTrips}',
              style: GVTypography.bodySmallMedium,
            ),
            const SizedBox(height: GVSpacing.sm),
            Text(
              'Published Refund Policy: Pro-rata refund calculated on base daily fare less a 10% administrative processing fee. Refunds are initiated within 1-3 business days back to your Go-Volts Wallet or original payment method.',
              style:
                  GVTypography.caption.copyWith(color: GVColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep Plan'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: GVColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                      'Plan cancellation request submitted for operations review.'),
                  backgroundColor: GVColors.deepGreen,
                ),
              );
            },
            child: const Text('Request Cancellation'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheduledState = ref.watch(scheduledNotifierProvider);
    final plans = scheduledState.plans;
    final selectedPlan = scheduledState.selectedPlan ?? plans.firstOrNull;

    return Scaffold(
      backgroundColor: GVColors.softBackground,
      appBar: GVTopBar(
        title: 'Scheduled Plans',
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: 'Create New Plan',
            onPressed: () => context.push(AppRoutes.scheduledBooking),
          ),
        ],
      ),
      body: SafeArea(
        child: scheduledState.isLoading && plans.isEmpty
            ? const Center(
                child: CircularProgressIndicator(color: GVColors.brandGreen))
            : ListView(
                padding: const EdgeInsets.all(GVSpacing.md),
                children: [
                  // Plan selector pills
                  if (plans.isNotEmpty)
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: plans.map((plan) {
                          final isSelected = selectedPlan?.id == plan.id;
                          return Padding(
                            padding: const EdgeInsets.only(right: GVSpacing.sm),
                            child: ChoiceChip(
                              label: Text(
                                plan.isSchoolRun
                                    ? '🎒 School Run'
                                    : '⚡ Work Commute',
                              ),
                              selected: isSelected,
                              selectedColor: GVColors.brandGreen,
                              backgroundColor: Colors.white,
                              labelStyle: TextStyle(
                                color: isSelected
                                    ? GVColors.deepGreen
                                    : GVColors.nearBlack,
                                fontWeight: FontWeight.w600,
                              ),
                              onSelected: (_) {
                                ref
                                    .read(scheduledNotifierProvider.notifier)
                                    .selectPlan(plan);
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  if (plans.isNotEmpty) const SizedBox(height: GVSpacing.md),

                  if (plans.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: GVSpacing.lg, vertical: GVSpacing.xxl),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(GVSpacing.lg),
                              decoration: BoxDecoration(
                                color: GVColors.brandGreen
                                    .withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.calendar_month_rounded,
                                size: 48,
                                color: GVColors.brandGreen,
                              ),
                            ),
                            const SizedBox(height: GVSpacing.md),
                            Text(
                              'No scheduled plans yet',
                              style: GVTypography.h2,
                            ),
                            const SizedBox(height: GVSpacing.xs),
                            Text(
                              'Set up weekly school-run safety pickups or recurring work commutes with guaranteed electric vehicles.',
                              textAlign: TextAlign.center,
                              style: GVTypography.bodyMedium.copyWith(
                                color: GVColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: GVSpacing.lg),
                            GVPrimaryButton(
                              label: 'Create Scheduled Plan',
                              onPressed: () =>
                                  context.push(AppRoutes.scheduledBooking),
                            ),
                          ],
                        ),
                      ),
                    ),

                  if (selectedPlan != null) ...[
                    // Plan Overview Card
                    Container(
                      padding: const EdgeInsets.all(GVSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(GVBorderRadius.md),
                        boxShadow: GVShadows.card,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  selectedPlan.title,
                                  style: GVTypography.h3,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: selectedPlan.isPaused
                                      ? GVColors.warning.withValues(alpha: 0.2)
                                      : GVColors.statusActiveBg,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  selectedPlan.status.label,
                                  style: GVTypography.bodySmallMedium.copyWith(
                                    color: selectedPlan.isPaused
                                        ? GVColors.warning
                                        : GVColors.brandGreen,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Ref: ${selectedPlan.planReference}',
                            style: GVTypography.caption
                                .copyWith(color: GVColors.textSecondary),
                          ),
                          const Divider(height: GVSpacing.lg),

                          // Entitlement Progress
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text('Trip Entitlements',
                                    style: GVTypography.bodySmallMedium,
                                    overflow: TextOverflow.ellipsis),
                              ),
                              const SizedBox(width: GVSpacing.xs),
                              Flexible(
                                child: Text(
                                  '${selectedPlan.remainingTrips} of ${selectedPlan.totalTrips} left',
                                  style: GVTypography.bodySmallMedium.copyWith(
                                    color: GVColors.brandGreen,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: GVSpacing.xs),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: selectedPlan.remainingTrips /
                                  selectedPlan.totalTrips,
                              minHeight: 8,
                              backgroundColor: GVColors.border,
                              color: GVColors.brandGreen,
                            ),
                          ),
                          const SizedBox(height: GVSpacing.xs),
                          Text(
                            'Valid until ${selectedPlan.expiryDate.day}/${selectedPlan.expiryDate.month}/${selectedPlan.expiryDate.year}',
                            style: GVTypography.caption
                                .copyWith(color: GVColors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: GVSpacing.md),

                    // Next Trip Card
                    Container(
                      padding: const EdgeInsets.all(GVSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(GVBorderRadius.md),
                        boxShadow: GVShadows.card,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.schedule,
                                  color: GVColors.brandGreen),
                              const SizedBox(width: GVSpacing.xs),
                              Flexible(
                                child: Text('Next Upcoming Trip',
                                    style: GVTypography.h3,
                                    overflow: TextOverflow.ellipsis),
                              ),
                            ],
                          ),
                          const SizedBox(height: GVSpacing.sm),
                          Text(
                            'Tomorrow at ${selectedPlan.pickupTime}',
                            style: GVTypography.bodyMedium
                                .copyWith(color: GVColors.deepGreen),
                          ),
                          const SizedBox(height: GVSpacing.xs),
                          Text(
                            'From: ${selectedPlan.pickupLocation.label}\nTo: ${selectedPlan.dropoffLocation.label}',
                            style: GVTypography.bodySmall
                                .copyWith(color: GVColors.textSecondary),
                          ),
                          const SizedBox(height: GVSpacing.md),

                          // Action buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: GVColors.error,
                                    side:
                                        const BorderSide(color: GVColors.error),
                                  ),
                                  onPressed: () => _showSkipTripDialog(
                                      context, selectedPlan),
                                  child: const Text('Skip Trip'),
                                ),
                              ),
                              const SizedBox(width: GVSpacing.sm),
                              if (selectedPlan.isSchoolRun)
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: GVColors.brandGreen,
                                      foregroundColor: GVColors.deepGreen,
                                    ),
                                    onPressed: () => context.push(
                                      AppRoutes.schoolRunSafety,
                                    ),
                                    icon: const Icon(Icons.shield, size: 16),
                                    label: const Text('Safety Hub'),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: GVSpacing.md),

                    // Subscription Management Options
                    Container(
                      padding: const EdgeInsets.all(GVSpacing.md),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(GVBorderRadius.md),
                        boxShadow: GVShadows.card,
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Manage Subscription', style: GVTypography.h3),
                            const SizedBox(height: GVSpacing.sm),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: Icon(
                                selectedPlan.isPaused
                                    ? Icons.play_arrow
                                    : Icons.pause_circle_outline,
                                color: GVColors.deepGreen,
                              ),
                              title: Text(
                                selectedPlan.isPaused
                                    ? 'Resume Plan'
                                    : 'Pause Plan',
                                style: GVTypography.bodyMedium,
                              ),
                              subtitle:
                                  const Text('Temporarily halt scheduled pickups'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () {
                                ref
                                    .read(scheduledNotifierProvider.notifier)
                                    .togglePlanPause(selectedPlan);
                              },
                            ),
                            const Divider(),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.edit_calendar_outlined,
                                  color: GVColors.deepGreen),
                              title: Text('Change Schedule or Route',
                                  style: GVTypography.bodyMedium),
                              subtitle:
                                  const Text('Modify pickup timing or destination address'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => context.push(AppRoutes.planModify),
                            ),
                            const Divider(),
                            ListTile(
                              contentPadding: EdgeInsets.zero,
                              leading: const Icon(Icons.cancel_outlined,
                                  color: GVColors.error),
                              title: Text(
                                'Cancel Subscription',
                                style: GVTypography.bodyMedium
                                    .copyWith(color: GVColors.error),
                              ),
                              subtitle:
                                  const Text('Calculate pro-rata refund & terms'),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => _showCancellationPolicyDialog(
                                  context, selectedPlan),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
