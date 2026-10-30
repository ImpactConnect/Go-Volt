import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../application/booking_notifier.dart';

/// SP01 - SP05 — Scheduled Services & Recurring Pickup/Ride Overview Screen
/// Follows UI reference `02_go_volts_service_and_scheduled_pickup_overview.png`.
class ScheduledBookingScreen extends ConsumerStatefulWidget {
  const ScheduledBookingScreen({super.key});

  @override
  ConsumerState<ScheduledBookingScreen> createState() =>
      _ScheduledBookingScreenState();
}

class _ScheduledBookingScreenState
    extends ConsumerState<ScheduledBookingScreen> {
  DateTime _scheduledDate = DateTime.now().add(const Duration(days: 1));
  TimeOfDay _scheduledTime = const TimeOfDay(hour: 7, minute: 30);
  String _selectedPlanType = 'RECURRING'; // ONE_OFF, RECURRING, SCHOOL_RUN
  String _frequency = 'MON_FRI'; // DAILY, MON_FRI, WEEKLY

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSchedule();
    });
  }

  void _updateSchedule() {
    final scheduledDateTime = DateTime(
      _scheduledDate.year,
      _scheduledDate.month,
      _scheduledDate.day,
      _scheduledTime.hour,
      _scheduledTime.minute,
    );
    ref.read(bookingNotifierProvider.notifier).setSchedule(
          scheduledTime: scheduledDateTime,
          recurringFrequency: _selectedPlanType == 'ONE_OFF' ? null : _frequency,
        );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 90)),
    );
    if (picked != null) {
      setState(() => _scheduledDate = picked);
      _updateSchedule();
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _scheduledTime,
    );
    if (picked != null) {
      setState(() => _scheduledTime = picked);
      _updateSchedule();
    }
  }

  Future<void> _confirmSchedule() async {
    final booking =
        await ref.read(bookingNotifierProvider.notifier).commitBooking();
    if (booking != null && mounted) {
      context.push(AppRoutes.findingDriver);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingNotifierProvider);
    final quote = bookingState.quote;
    final breakdown = quote?.priceBreakdown;

    final dateFormatted =
        '${_scheduledDate.day}/${_scheduledDate.month}/${_scheduledDate.year}';
    final timeFormatted =
        '${_scheduledTime.hour.toString().padLeft(2, '0')}:${_scheduledTime.minute.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const GVTopBar(title: 'Scheduled Services'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(GVSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Hero Plan Banner
              Container(
                padding: const EdgeInsets.all(GVSpacing.lg),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [GVColors.deepGreen, Color(0xFF063327)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(GVSpacing.xs),
                          decoration: BoxDecoration(
                            color: GVColors.limeHighlight.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.calendar_month_rounded,
                            color: GVColors.limeHighlight,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: GVSpacing.sm),
                        Text(
                          'Guaranteed Dispatch',
                          style: GVTypography.bodyMedium.copyWith(
                            color: GVColors.limeHighlight,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: GVSpacing.sm),
                    Text(
                      'Zero Stress. On-Time Commutes.',
                      style: GVTypography.h3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Dedicated electric vehicle allocated 20 minutes before your scheduled pickup window.',
                      style: GVTypography.bodySmall.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GVSpacing.lg),

              // 2. Select Plan Category
              Text(
                'Choose Schedule Type',
                style: GVTypography.h3.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: GVSpacing.sm),

              _buildPlanTypeOption(
                type: 'RECURRING',
                title: 'Recurring Commute Plan',
                subtitle: 'Daily work or office runs at locked discount fares',
                icon: Icons.repeat_rounded,
              ),
              const SizedBox(height: GVSpacing.sm),

              _buildPlanTypeOption(
                type: 'SCHOOL_RUN',
                title: 'Safe School-Run Plan',
                subtitle: 'Vetted drivers, live parent OTP handover & roundtrip',
                icon: Icons.school_outlined,
              ),
              const SizedBox(height: GVSpacing.sm),

              _buildPlanTypeOption(
                type: 'ONE_OFF',
                title: 'One-off Advance Booking',
                subtitle: 'Single scheduled pickup for flights, events or meetings',
                icon: Icons.event_available_rounded,
              ),
              const SizedBox(height: GVSpacing.lg),

              // 3. Date & Time Selection
              Text(
                'Pickup Window',
                style: GVTypography.h3.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: GVSpacing.sm),

              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _pickDate,
                      borderRadius: BorderRadius.circular(GVBorderRadius.sm),
                      child: Container(
                        padding: const EdgeInsets.all(GVSpacing.md),
                        decoration: BoxDecoration(
                          color: GVColors.softBackground,
                          borderRadius: BorderRadius.circular(GVBorderRadius.sm),
                          border: Border.all(color: GVColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_rounded,
                                size: 18, color: GVColors.brandGreen),
                            const SizedBox(width: GVSpacing.sm),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('DATE', style: GVTypography.caption),
                                Text(
                                  dateFormatted,
                                  style: GVTypography.bodySmallMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: GVSpacing.sm),
                  Expanded(
                    child: InkWell(
                      onTap: _pickTime,
                      borderRadius: BorderRadius.circular(GVBorderRadius.sm),
                      child: Container(
                        padding: const EdgeInsets.all(GVSpacing.md),
                        decoration: BoxDecoration(
                          color: GVColors.softBackground,
                          borderRadius: BorderRadius.circular(GVBorderRadius.sm),
                          border: Border.all(color: GVColors.border),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.access_time_rounded,
                                size: 18, color: GVColors.brandGreen),
                            const SizedBox(width: GVSpacing.sm),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('TIME', style: GVTypography.caption),
                                Text(
                                  timeFormatted,
                                  style: GVTypography.bodySmallMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: GVSpacing.lg),

              // 4. Frequency Selector (If recurring or school run)
              if (_selectedPlanType != 'ONE_OFF') ...[
                Text(
                  'Frequency Schedule',
                  style: GVTypography.h3.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: GVSpacing.sm),

                Row(
                  children: [
                    _buildFrequencyOption('MON_FRI', 'Mon – Fri'),
                    const SizedBox(width: GVSpacing.sm),
                    _buildFrequencyOption('DAILY', 'Every Day'),
                    const SizedBox(width: GVSpacing.sm),
                    _buildFrequencyOption('WEEKLY', 'Weekly'),
                  ],
                ),
                const SizedBox(height: GVSpacing.lg),
              ],

              // 5. Price & Entitlement Breakdown
              if (breakdown != null) ...[
                GVPriceBreakdown(
                  isEstimate: false,
                  estimateDisclaimer:
                      'Includes guaranteed vehicle reservation and carbon offset reporting.',
                  lines: [
                    GVPriceLine(
                      label: 'Single Leg Scheduled Fare',
                      amountLabel: '₦${breakdown.totalFare.toStringAsFixed(0)}',
                    ),
                    if (_selectedPlanType == 'MON_FRI')
                      const GVPriceLine(
                        label: 'Bundle Discount (5 Trips/week)',
                        amountLabel: '-15% applied',
                        isDiscount: true,
                      ),
                    const GVPriceLine(
                      label: 'Guaranteed Slot Reservation',
                      amountLabel: '₦0 (Included)',
                    ),
                  ],
                  totalLabel:
                      '₦${(_selectedPlanType == 'MON_FRI' ? breakdown.totalFare * 5 * 0.85 : breakdown.totalFare).toStringAsFixed(0)}',
                ),
                const SizedBox(height: GVSpacing.lg),
              ],

              // 6. Action Button
              GVPrimaryButton(
                label: _selectedPlanType == 'ONE_OFF'
                    ? 'Confirm Scheduled Ride'
                    : 'Submit Commute Plan',
                isLoading: bookingState.isCreatingBooking,
                onPressed: _confirmSchedule,
              ),
              const SizedBox(height: GVSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPlanTypeOption({
    required String type,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = _selectedPlanType == type;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedPlanType = type);
        _updateSchedule();
      },
      child: Container(
        padding: const EdgeInsets.all(GVSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? GVColors.softBackground : Colors.white,
          borderRadius: BorderRadius.circular(GVBorderRadius.md),
          border: Border.all(
            color: isSelected ? GVColors.brandGreen : GVColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? GVShadows.elevated : GVShadows.card,
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(GVSpacing.sm),
              decoration: BoxDecoration(
                color: isSelected
                    ? GVColors.brandGreen.withValues(alpha: 0.15)
                    : GVColors.softBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? GVColors.brandGreen : GVColors.nearBlack,
                size: 24,
              ),
            ),
            const SizedBox(width: GVSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GVTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GVTypography.caption.copyWith(
                      color: GVColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: isSelected ? GVColors.brandGreen : GVColors.border,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyOption(String code, String label) {
    final isSelected = _frequency == code;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _frequency = code);
          _updateSchedule();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: GVSpacing.sm),
          decoration: BoxDecoration(
            color: isSelected
                ? GVColors.brandGreen.withValues(alpha: 0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(GVBorderRadius.sm),
            border: Border.all(
              color: isSelected ? GVColors.brandGreen : GVColors.border,
              width: isSelected ? 2 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: GVTypography.bodySmallMedium.copyWith(
              color: isSelected ? GVColors.brandGreen : GVColors.textPrimary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
