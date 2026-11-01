import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../application/scheduled_booking_notifier.dart';

/// Screen 3 (SP-03): Select Trip Purpose Screen
/// Selects journey purpose (School Run, Work Commute, Personal, Other).
class SelectTripPurposeScreen extends ConsumerWidget {
  const SelectTripPurposeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scheduledBookingNotifierProvider);
    final notifier = ref.read(scheduledBookingNotifierProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF131A16) : Colors.white;
    final textColor = isDark ? Colors.white : GVColors.textPrimary;
    final subtextColor = isDark ? GVColors.neutral400 : GVColors.textSecondary;
    final cardBg = isDark ? const Color(0xFF1C2420) : Colors.white;
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;

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
              const SizedBox(height: GVSpacing.sm),
              Text(
                'Select trip purpose',
                style: GVTypography.h1.copyWith(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: GVSpacing.xl),

              // 1. School run
              _buildPurposeCard(
                title: 'School run',
                subtitle: 'For student transport',
                icon: Icons.school_rounded,
                isSelected: state.purpose == TripPurpose.schoolRun,
                onTap: () => notifier.setTripPurpose(TripPurpose.schoolRun),
                cardBg: cardBg,
                borderColor: borderColor,
                textColor: textColor,
                subtextColor: subtextColor,
              ),

              const SizedBox(height: GVSpacing.md),

              // 2. Work commute
              _buildPurposeCard(
                title: 'Work commute',
                subtitle: 'For daily work or office',
                icon: Icons.business_center_rounded,
                isSelected: state.purpose == TripPurpose.workCommute,
                onTap: () => notifier.setTripPurpose(TripPurpose.workCommute),
                cardBg: cardBg,
                borderColor: borderColor,
                textColor: textColor,
                subtextColor: subtextColor,
              ),

              const SizedBox(height: GVSpacing.md),

              // 3. Personal
              _buildPurposeCard(
                title: 'Personal',
                subtitle: 'Shopping, appointments, etc.',
                icon: Icons.people_rounded,
                isSelected: state.purpose == TripPurpose.personal,
                onTap: () => notifier.setTripPurpose(TripPurpose.personal),
                cardBg: cardBg,
                borderColor: borderColor,
                textColor: textColor,
                subtextColor: subtextColor,
              ),

              const SizedBox(height: GVSpacing.md),

              // 4. Other
              _buildPurposeCard(
                title: 'Other',
                subtitle: 'Custom trip purpose',
                icon: Icons.more_horiz_rounded,
                isSelected: state.purpose == TripPurpose.other,
                onTap: () => notifier.setTripPurpose(TripPurpose.other),
                cardBg: cardBg,
                borderColor: borderColor,
                textColor: textColor,
                subtextColor: subtextColor,
              ),

              const Spacer(),

              // CTA: Continue
              GVButton(
                text: 'Continue',
                onPressed: () {
                  context.push(AppRoutes.scheduledPickupLocation);
                },
              ),
              const SizedBox(height: GVSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPurposeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required Color cardBg,
    required Color borderColor,
    required Color textColor,
    required Color subtextColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GVBorderRadius.md),
      child: Container(
        padding: const EdgeInsets.all(GVSpacing.md),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(GVBorderRadius.md),
          border: Border.all(
            color: isSelected ? GVColors.primary : borderColor,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected
                    ? GVColors.primary.withValues(alpha: 0.12)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isSelected ? GVColors.primary : textColor,
              ),
            ),
            const SizedBox(width: GVSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GVTypography.labelLarge.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GVTypography.bodySmall.copyWith(
                      color: subtextColor,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: GVColors.primary,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}
