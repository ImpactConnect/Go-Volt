import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../application/scheduled_plans_notifier.dart';

/// Screen 23 (SP-24): Pause Plan Screen
/// Sets effective pause date and stops generation and dispatch of future trips.
class PausePlanScreen extends ConsumerStatefulWidget {
  const PausePlanScreen({super.key});

  @override
  ConsumerState<PausePlanScreen> createState() => _PausePlanScreenState();
}

class _PausePlanScreenState extends ConsumerState<PausePlanScreen> {
  DateTime _effectiveDate = DateTime(2026, 11, 10);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scheduledPlansNotifierProvider);
    final notifier = ref.read(scheduledPlansNotifierProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF131A16) : Colors.white;
    final textColor = isDark ? Colors.white : GVColors.textPrimary;
    final subtextColor = isDark ? GVColors.neutral400 : GVColors.textSecondary;
    final cardBg = isDark ? const Color(0xFF1C2420) : const Color(0xFFF6F8F7);
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;

    final plan =
        state.selectedPlan ??
        (state.plans.isNotEmpty ? state.plans.first : null);

    final dateStr =
        '${_weekDayName(_effectiveDate.weekday)}, ${_effectiveDate.day} ${_monthName(_effectiveDate.month)} ${_effectiveDate.year}';

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

              // Red Pause Circle Icon
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.pause_circle_filled_rounded,
                    size: 48,
                    color: Colors.redAccent,
                  ),
                ),
              ),

              const SizedBox(height: GVSpacing.md),

              Text(
                'Pause plan?',
                style: GVTypography.h1.copyWith(
                  color: textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: GVSpacing.xs),
              Text(
                'Upcoming trips will not be generated or assigned after the effective date.',
                textAlign: TextAlign.center,
                style: GVTypography.bodyMedium.copyWith(
                  color: subtextColor,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: GVSpacing.xl),

              // Effective Date Picker Card
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Effective from',
                  style: GVTypography.labelMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: GVSpacing.xs),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _effectiveDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 90)),
                  );
                  if (picked != null) {
                    setState(() => _effectiveDate = picked);
                  }
                },
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: GVSpacing.md,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(GVBorderRadius.md),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today_rounded,
                        size: 20,
                        color: GVColors.primary,
                      ),
                      const SizedBox(width: GVSpacing.md),
                      Text(
                        dateStr,
                        style: GVTypography.bodyMedium.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const Spacer(),
                      Icon(Icons.arrow_drop_down_rounded, color: subtextColor),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Primary CTA: Pause plan
              GVButton(
                text: 'Pause plan',
                isLoading: state.isLoading,
                onPressed: () async {
                  if (plan != null) {
                    await notifier.pausePlan(
                      planId: plan.id,
                      effectiveDate: _effectiveDate,
                    );
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Plan paused successfully.'),
                          backgroundColor: GVColors.primary,
                        ),
                      );
                      context.go(AppRoutes.scheduledMyPlans);
                    }
                  }
                },
              ),

              const SizedBox(height: GVSpacing.sm),

              // Secondary CTA: Cancel
              SizedBox(
                width: double.infinity,
                height: 52,
                child: TextButton(
                  onPressed: () => context.pop(),
                  child: Text(
                    'Cancel',
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

  String _weekDayName(int weekday) {
    return switch (weekday) {
      DateTime.monday => 'Mon',
      DateTime.tuesday => 'Tue',
      DateTime.wednesday => 'Wed',
      DateTime.thursday => 'Thu',
      DateTime.friday => 'Fri',
      DateTime.saturday => 'Sat',
      _ => 'Sun',
    };
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
