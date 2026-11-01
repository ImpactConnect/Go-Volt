import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../application/scheduled_booking_notifier.dart';

/// Screen 6 (SP-06): Scheduled Trip Details Screen (One-off)
/// Configures single journey direction, date, time, and optional return trip leg.
class ScheduledTripDetailsScreen extends ConsumerStatefulWidget {
  const ScheduledTripDetailsScreen({super.key});

  @override
  ConsumerState<ScheduledTripDetailsScreen> createState() =>
      _ScheduledTripDetailsScreenState();
}

class _ScheduledTripDetailsScreenState
    extends ConsumerState<ScheduledTripDetailsScreen> {
  DateTime _selectedDate = DateTime(2026, 11, 5);
  TimeOfDay _selectedTime = const TimeOfDay(hour: 8, minute: 0);
  bool _returnLater = false;

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

    final dateStr =
        '${_weekDayName(_selectedDate.weekday)}, ${_selectedDate.day} ${_monthName(_selectedDate.month)} ${_selectedDate.year}';
    final timeStr = _selectedTime.format(context);

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
                'Trip details',
                style: GVTypography.h1.copyWith(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: GVSpacing.lg),

              // Journey type
              Text(
                'Journey type',
                style: GVTypography.labelLarge.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: GVSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _buildJourneyTypeCard(
                      title: 'One way',
                      icon: Icons.alt_route_rounded,
                      isSelected:
                          state.journeyDirection == JourneyDirection.oneWay,
                      onTap: () {
                        notifier.setJourneyDirection(JourneyDirection.oneWay);
                      },
                      cardBg: cardBg,
                      borderColor: borderColor,
                      textColor: textColor,
                    ),
                  ),
                  const SizedBox(width: GVSpacing.md),
                  Expanded(
                    child: _buildJourneyTypeCard(
                      title: 'Round trip',
                      icon: Icons.sync_alt_rounded,
                      isSelected:
                          state.journeyDirection == JourneyDirection.roundTrip,
                      onTap: () {
                        notifier.setJourneyDirection(JourneyDirection.roundTrip);
                      },
                      cardBg: cardBg,
                      borderColor: borderColor,
                      textColor: textColor,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: GVSpacing.xl),

              // Date and time
              Text(
                'Date and time',
                style: GVTypography.labelLarge.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: GVSpacing.sm),

              // Date Selector Card
              InkWell(
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                    notifier.setDateAndTime(
                      date: _selectedDate,
                      time: timeStr,
                    );
                  }
                },
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: GVSpacing.md, vertical: 14),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(GVBorderRadius.md),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          size: 20, color: GVColors.primary),
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

              const SizedBox(height: GVSpacing.md),

              // Time Selector Card
              InkWell(
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _selectedTime,
                  );
                  if (picked != null && context.mounted) {
                    setState(() => _selectedTime = picked);
                    notifier.setDateAndTime(
                      date: _selectedDate,
                      time: picked.format(context),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: GVSpacing.md, vertical: 14),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(GVBorderRadius.md),
                    border: Border.all(color: borderColor),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.access_time_rounded,
                          size: 20, color: GVColors.primary),
                      const SizedBox(width: GVSpacing.md),
                      Text(
                        timeStr,
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

              const SizedBox(height: GVSpacing.xl),

              // Return later switch card
              Container(
                padding: const EdgeInsets.all(GVSpacing.md),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Return later?',
                            style: GVTypography.labelMedium.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'You can add a return trip after this booking.',
                            style: GVTypography.bodySmall.copyWith(
                              color: subtextColor,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Switch.adaptive(
                      value: _returnLater,
                      activeTrackColor: GVColors.primary,
                      onChanged: (val) {
                        setState(() => _returnLater = val);
                        notifier.setDateAndTime(
                          date: _selectedDate,
                          time: timeStr,
                          returnLater: val,
                        );
                      },
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // CTA: Continue
              GVButton(
                text: 'Continue',
                onPressed: () {
                  notifier.setDateAndTime(
                    date: _selectedDate,
                    time: timeStr,
                    returnLater: _returnLater,
                  );
                  if (state.isRecurring) {
                    context.push(AppRoutes.scheduledCalendar);
                  } else {
                    context.push(AppRoutes.scheduledPassengerDetails);
                  }
                },
              ),
              const SizedBox(height: GVSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJourneyTypeCard({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color cardBg,
    required Color borderColor,
    required Color textColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GVBorderRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(GVBorderRadius.md),
          border: Border.all(
            color: isSelected ? GVColors.primary : borderColor,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected ? GVColors.primary : textColor,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              style: GVTypography.labelMedium.copyWith(
                color: isSelected ? GVColors.primary : textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ],
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

