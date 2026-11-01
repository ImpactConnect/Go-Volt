import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../application/scheduled_booking_notifier.dart';

/// Screen 24 (SP-27): Renew Plan Screen
/// Manually configures renewal term dates and requests an updated binding quote.
class RenewPlanScreen extends ConsumerStatefulWidget {
  const RenewPlanScreen({super.key});

  @override
  ConsumerState<RenewPlanScreen> createState() => _RenewPlanScreenState();
}

class _RenewPlanScreenState extends ConsumerState<RenewPlanScreen> {
  DateTime _startDate = DateTime(2027, 2, 2);
  DateTime _endDate = DateTime(2027, 4, 30);

  @override
  Widget build(BuildContext context) {
    final bookingNotifier =
        ref.read(scheduledBookingNotifierProvider.notifier);

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: GVSpacing.md),

              // Green Refresh Badge
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: GVColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.sync_rounded,
                    size: 46,
                    color: GVColors.primary,
                  ),
                ),
              ),

              const SizedBox(height: GVSpacing.md),

              Text(
                'Renew plan',
                style: GVTypography.h1.copyWith(
                  color: textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: GVSpacing.xs),
              Text(
                'Get a new quote to continue your scheduled trips.',
                textAlign: TextAlign.center,
                style: GVTypography.bodyMedium.copyWith(
                  color: subtextColor,
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: GVSpacing.xl),

              // Start date selector
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Start date',
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
                    initialDate: _startDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => _startDate = picked);
                  }
                },
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                child: Container(
                  width: double.infinity,
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

              // End date selector
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'End date',
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
                    initialDate: _endDate,
                    firstDate: _startDate,
                    lastDate: _startDate.add(const Duration(days: 365)),
                  );
                  if (picked != null) {
                    setState(() => _endDate = picked);
                  }
                },
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                child: Container(
                  width: double.infinity,
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

              const Spacer(),

              // Primary CTA: Get new quote
              GVButton(
                text: 'Get new quote',
                onPressed: () async {
                  final quote = await bookingNotifier.generateQuote();
                  if (quote != null && context.mounted) {
                    context.push(AppRoutes.scheduledQuoteResult);
                  }
                },
              ),

              const SizedBox(height: GVSpacing.sm),

              // Secondary CTA: View plan details
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => context.pop(),
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
