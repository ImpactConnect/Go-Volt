import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../application/scheduled_booking_notifier.dart';

/// Screen 7 (SP-07): Schedule Calendar Screen (Recurring)
/// Configures weekly/monthly frequency, days of the week, term dates, and holiday exceptions.
class ScheduleCalendarScreen extends ConsumerStatefulWidget {
  const ScheduleCalendarScreen({super.key});

  @override
  ConsumerState<ScheduleCalendarScreen> createState() =>
      _ScheduleCalendarScreenState();
}

class _ScheduleCalendarScreenState
    extends ConsumerState<ScheduleCalendarScreen> {
  DateTime _startDate = DateTime(2026, 11, 3);
  DateTime _endDate = DateTime(2027, 1, 30);

  final List<String> _allDays = const [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scheduledBookingNotifierProvider);
    final notifier = ref.read(scheduledBookingNotifierProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF131A16) : Colors.white;
    final textColor = isDark ? Colors.white : GVColors.textPrimary;
    final subtextColor = isDark ? GVColors.neutral400 : GVColors.textSecondary;
    final cardBg = isDark ? const Color(0xFF1C2420) : const Color(0xFFF6F8F7);
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;

    final startStr =
        '${_weekDayName(_startDate.weekday)}, ${_startDate.day} ${_monthName(_startDate.month)} ${_startDate.year}';
    final endStr =
        '${_weekDayName(_endDate.weekday)}, ${_endDate.day} ${_monthName(_endDate.month)} ${_endDate.year}';

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: GVSpacing.xs),
              Text(
                'Set your schedule',
                style: GVTypography.h1.copyWith(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: GVSpacing.lg),

              // Frequency Segmented Control: [Weekly] [Monthly]
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildFrequencyTab(
                        title: 'Weekly',
                        isSelected: state.frequency == ScheduleFrequency.weekly,
                        onTap: () {
                          notifier.setRecurringSchedule(
                            frequency: ScheduleFrequency.weekly,
                            days: state.selectedDays,
                            startDate: _startDate,
                            endDate: _endDate,
                          );
                        },
                      ),
                    ),
                    Expanded(
                      child: _buildFrequencyTab(
                        title: 'Monthly',
                        isSelected:
                            state.frequency == ScheduleFrequency.monthly,
                        onTap: () {
                          notifier.setRecurringSchedule(
                            frequency: ScheduleFrequency.monthly,
                            days: state.selectedDays,
                            startDate: _startDate,
                            endDate: _endDate,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: GVSpacing.xl),

              // Select days section
              Text(
                'Select days',
                style: GVTypography.labelLarge.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: GVSpacing.sm),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: _allDays.map((day) {
                  final isSelected = state.selectedDays.contains(day);
                  return InkWell(
                    onTap: () => notifier.toggleDay(day),
                    borderRadius: BorderRadius.circular(GVBorderRadius.full),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: isSelected ? GVColors.primary : cardBg,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected ? GVColors.primary : borderColor,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          day,
                          style: TextStyle(
                            color: isSelected ? Colors.white : textColor,
                            fontSize: 13,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: GVSpacing.xl),

              // Start date card
              Text(
                'Start date',
                style: GVTypography.labelLarge.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: GVSpacing.xs),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => _startDate = picked);
                    notifier.setRecurringSchedule(
                      frequency: state.frequency,
                      days: state.selectedDays,
                      startDate: picked,
                      endDate: _endDate,
                    );
                  }
                },
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                child: Container(
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
                        startStr,
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

              const SizedBox(height: GVSpacing.md),

              // End date card
              Text(
                'End date',
                style: GVTypography.labelLarge.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: GVSpacing.xs),
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _endDate,
                    firstDate: _startDate,
                    lastDate: _startDate.add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => _endDate = picked);
                    notifier.setRecurringSchedule(
                      frequency: state.frequency,
                      days: state.selectedDays,
                      startDate: _startDate,
                      endDate: picked,
                    );
                  }
                },
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                child: Container(
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
                        endStr,
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

              const SizedBox(height: GVSpacing.md),

              // Exclude dates (optional)
              InkWell(
                onTap: () {},
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                child: Container(
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
                        Icons.event_busy_rounded,
                        size: 20,
                        color: subtextColor,
                      ),
                      const SizedBox(width: GVSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Exclude dates (optional)',
                              style: GVTypography.labelMedium.copyWith(
                                color: textColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              'Add school holidays or specific dates >',
                              style: GVTypography.bodySmall.copyWith(
                                color: subtextColor,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: subtextColor,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: GVSpacing.xxl),

              // CTA: Continue
              GVButton(
                text: 'Continue',
                onPressed: () {
                  notifier.setRecurringSchedule(
                    frequency: state.frequency,
                    days: state.selectedDays,
                    startDate: _startDate,
                    endDate: _endDate,
                  );
                  context.push(AppRoutes.scheduledPassengerDetails);
                },
              ),
              const SizedBox(height: GVSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFrequencyTab({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GVBorderRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
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
              fontSize: 14,
            ),
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
