import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../application/scheduled_trips_notifier.dart';

/// Screen 32 (SP-34): School Run Status Screen
/// Real-time multi-milestone school run tracker with progress timeline from assignment through handover verification.
class SchoolRunStatusScreen extends ConsumerWidget {
  const SchoolRunStatusScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scheduledTripsNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF131A16) : Colors.white;
    final textColor = isDark ? Colors.white : GVColors.textPrimary;
    final subtextColor = isDark ? GVColors.neutral400 : GVColors.textSecondary;
    final cardBg = isDark ? const Color(0xFF1C2420) : GVColors.neutral50;
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;

    final trip = state.selectedTrip ??
        (state.upcomingTrips.isNotEmpty ? state.upcomingTrips.first : null);

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
              // Header title with school bus illustration card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(GVSpacing.md),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF2E2A14) : const Color(0xFFFEF9C3),
                  borderRadius: BorderRadius.circular(GVBorderRadius.card),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF534812)
                        : const Color(0xFFFDE047),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'School Run',
                            style: GVTypography.h1.copyWith(
                              color: isDark ? Colors.white : const Color(0xFF713F12),
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Mon, 6 Nov 2026',
                            style: GVTypography.bodyMedium.copyWith(
                              color: isDark
                                  ? const Color(0xFFFDE047)
                                  : const Color(0xFF854D0E),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Passenger: ${trip?.passengerName ?? "Fatima Okafor"} (JSS 1)',
                            style: GVTypography.caption.copyWith(
                              color: isDark
                                  ? const Color(0xFFD4D4D8)
                                  : const Color(0xFFA16207),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFACC15),
                        borderRadius: BorderRadius.circular(GVBorderRadius.md),
                      ),
                      child: const Icon(
                        Icons.directions_bus_rounded,
                        color: Color(0xFF713F12),
                        size: 32,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GVSpacing.xl),

              // Vertical progress timeline
              Text(
                'Journey milestones',
                style: GVTypography.h3.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: GVSpacing.md),

              Container(
                padding: const EdgeInsets.all(GVSpacing.md),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(GVBorderRadius.card),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    _buildMilestoneStep(
                      title: 'Driver assigned',
                      time: '7:45 AM',
                      isCompleted: true,
                      isLast: false,
                      textColor: textColor,
                      subtextColor: subtextColor,
                    ),
                    _buildMilestoneStep(
                      title: 'Arrived at pickup',
                      time: '8:00 AM',
                      isCompleted: true,
                      isLast: false,
                      textColor: textColor,
                      subtextColor: subtextColor,
                    ),
                    _buildMilestoneStep(
                      title: 'Child picked up',
                      time: '8:05 AM',
                      isCompleted: true,
                      isLast: false,
                      textColor: textColor,
                      subtextColor: subtextColor,
                    ),
                    _buildMilestoneStep(
                      title: 'In transit',
                      time: 'En route to school',
                      isCompleted: true,
                      isLast: false,
                      textColor: textColor,
                      subtextColor: subtextColor,
                    ),
                    _buildMilestoneStep(
                      title: 'Arrived at school',
                      time: '8:28 AM',
                      isCompleted: true,
                      isLast: false,
                      textColor: textColor,
                      subtextColor: subtextColor,
                    ),
                    _buildMilestoneStep(
                      title: 'Handover pending',
                      time: 'Waiting for verification',
                      isCompleted: false,
                      isPending: true,
                      isLast: true,
                      textColor: textColor,
                      subtextColor: subtextColor,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GVSpacing.xl),

              // Action buttons
              GVButton(
                text: 'Verify handover',
                type: GVButtonType.primary,
                onPressed: () {
                  context.push(AppRoutes.scheduledHandoverVerification);
                },
              ),
              const SizedBox(height: GVSpacing.sm),
              GVButton(
                text: 'View trip details',
                type: GVButtonType.outline,
                onPressed: () {
                  context.push(AppRoutes.scheduledPaymentRefundDetails);
                },
              ),
              const SizedBox(height: GVSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMilestoneStep({
    required String title,
    required String time,
    required bool isCompleted,
    bool isPending = false,
    required bool isLast,
    required Color textColor,
    required Color subtextColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: isCompleted
                    ? GVColors.primary
                    : (isPending
                        ? const Color(0xFFF59E0B)
                        : GVColors.neutral300),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isCompleted
                    ? Icons.check_rounded
                    : (isPending
                        ? Icons.access_time_rounded
                        : Icons.circle_outlined),
                size: 14,
                color: Colors.white,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 38,
                color: isCompleted ? GVColors.primary : GVColors.neutral300,
              ),
          ],
        ),
        const SizedBox(width: GVSpacing.md),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GVTypography.bodyMedium.copyWith(
                    color: textColor,
                    fontWeight: isPending || isCompleted
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  time,
                  style: GVTypography.caption.copyWith(
                    color: isPending
                        ? const Color(0xFFD97706)
                        : subtextColor,
                    fontWeight: isPending ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
