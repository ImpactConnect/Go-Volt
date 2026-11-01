import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../application/scheduled_trips_notifier.dart';

/// Screen 31 (SP-33): Trip Completed Screen
/// Shows trip completion confirmation, fare breakdown (e.g. ₦2,500 Package), driver rating, and trip details link.
class ScheduledTripCompletedScreen extends ConsumerStatefulWidget {
  const ScheduledTripCompletedScreen({super.key});

  @override
  ConsumerState<ScheduledTripCompletedScreen> createState() =>
      _ScheduledTripCompletedScreenState();
}

class _ScheduledTripCompletedScreenState
    extends ConsumerState<ScheduledTripCompletedScreen> {
  int _rating = 5;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(scheduledTripsNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF131A16) : Colors.white;
    final textColor = isDark ? Colors.white : GVColors.textPrimary;
    final subtextColor = isDark ? GVColors.neutral400 : GVColors.textSecondary;
    final cardBg = isDark ? const Color(0xFF1C2420) : GVColors.neutral50;
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;

    final trip = state.selectedTrip ??
        (state.completedTrips.isNotEmpty
            ? state.completedTrips.first
            : (state.trips.isNotEmpty ? state.trips.first : null));
    final driver = trip?.assignedDriver;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            size: 24,
            color: textColor,
          ),
          onPressed: () => context.go(AppRoutes.home),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: GVSpacing.md),

              // Celebration checkmark with sparkles
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: GVColors.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 68,
                      height: 68,
                      decoration: const BoxDecoration(
                        color: GVColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GVSpacing.lg),

              Text(
                'Trip completed!',
                style: GVTypography.h1.copyWith(
                  color: textColor,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'You have arrived at your destination.',
                style: GVTypography.bodyMedium.copyWith(
                  color: subtextColor,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: GVSpacing.xl),

              // Trip route summary card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(GVSpacing.md),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(GVBorderRadius.card),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today_outlined,
                          size: 16,
                          color: GVColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Mon, 6 Nov 2026, 8:32 AM',
                          style: GVTypography.bodyMedium.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          margin: const EdgeInsets.only(top: 4),
                          decoration: const BoxDecoration(
                            color: GVColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            trip?.pickupAddress ??
                                'Central Roundabout, Shaganu, Ogun State',
                            style: GVTypography.bodyMedium.copyWith(
                              color: textColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 4),
                      child: Container(
                        width: 2,
                        height: 20,
                        color: borderColor,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.location_on_rounded,
                          size: 14,
                          color: Color(0xFFEF4444),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            trip?.destinationAddress ??
                                'Remo High Street, Shaganu, Ogun State',
                            style: GVTypography.bodyMedium.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GVSpacing.md),

              // Fare card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: GVSpacing.md,
                  vertical: GVSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(GVBorderRadius.card),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Fare',
                      style: GVTypography.bodyLarge.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          '₦2,500',
                          style: GVTypography.h3.copyWith(
                            color: textColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '(Package)',
                          style: GVTypography.bodySmall.copyWith(
                            color: subtextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GVSpacing.md),

              // Driver Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(GVSpacing.md),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(GVBorderRadius.card),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: GVColors.primary.withValues(alpha: 0.2),
                      child: Text(
                        driver != null && driver.name.isNotEmpty
                            ? driver.name[0]
                            : 'A',
                        style: GVTypography.h3.copyWith(
                          color: GVColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: GVSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            driver?.name ?? 'Ahmed Ibrahim',
                            style: GVTypography.bodyLarge.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFFF59E0B),
                                size: 16,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                driver != null
                                    ? driver.rating.toStringAsFixed(1)
                                    : '4.8',
                                style: GVTypography.caption.copyWith(
                                  color: subtextColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GVSpacing.xl),

              // Secondary: View trip details
              TextButton(
                onPressed: () {
                  context.push(AppRoutes.scheduledPaymentRefundDetails);
                },
                child: Text(
                  'View trip details',
                  style: GVTypography.bodyMedium.copyWith(
                    color: GVColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: GVSpacing.sm),

              // Primary CTA: Rate driver
              GVButton(
                text: 'Rate driver',
                type: GVButtonType.primary,
                onPressed: () => _showRatingModal(context),
              ),
              const SizedBox(height: GVSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  void _showRatingModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setSheetState) {
          return Padding(
            padding: const EdgeInsets.all(GVSpacing.xl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'How was your trip with Ahmed?',
                  style: GVTypography.h3.copyWith(fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: GVSpacing.md),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starIndex = index + 1;
                    return IconButton(
                      icon: Icon(
                        starIndex <= _rating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: const Color(0xFFF59E0B),
                        size: 36,
                      ),
                      onPressed: () {
                        setSheetState(() => _rating = starIndex);
                        setState(() => _rating = starIndex);
                      },
                    );
                  }),
                ),
                const SizedBox(height: GVSpacing.lg),
                GVButton(
                  text: 'Submit rating',
                  type: GVButtonType.primary,
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Thank you for rating your driver!'),
                      ),
                    );
                    context.go(AppRoutes.home);
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
