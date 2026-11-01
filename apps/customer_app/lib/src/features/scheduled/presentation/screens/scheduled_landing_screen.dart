import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';

/// Screen 1 (SP-01): Scheduled Pickup Landing Screen
/// Primary entry point explaining service, value propositions, and actions.
class ScheduledLandingScreen extends ConsumerWidget {
  const ScheduledLandingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF131A16) : Colors.white;
    final textColor = isDark ? Colors.white : GVColors.textPrimary;
    final subtextColor = isDark ? GVColors.neutral400 : GVColors.textSecondary;
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: GVColors.primary,
                borderRadius: BorderRadius.circular(GVBorderRadius.full),
              ),
              child: const Text(
                'gb',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'GO-VOLTS',
              style: GVTypography.labelLarge.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
                color: textColor,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, color: textColor),
            onPressed: () => context.push(AppRoutes.notifications),
          ),
          Padding(
            padding: const EdgeInsets.only(right: GVSpacing.md),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: GVColors.primary.withValues(alpha: 0.15),
              child: const Icon(
                Icons.person_rounded,
                size: 18,
                color: GVColors.primary,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: GVSpacing.sm),

              // Hero Illustration Container
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: GVSpacing.xl),
                decoration: BoxDecoration(
                  color: GVColors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(GVBorderRadius.lg),
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          color: GVColors.primary.withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                        ),
                      ),
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.calendar_month_rounded,
                              size: 40,
                              color: GVColors.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.person_rounded,
                                  size: 24, color: GVColors.primary),
                              const SizedBox(width: 4),
                              Icon(Icons.electric_car_rounded,
                                  size: 38, color: GVColors.primary),
                              const SizedBox(width: 4),
                              Icon(Icons.person_rounded,
                                  size: 24, color: GVColors.primary),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: GVSpacing.xl),

              // Title and Subtitle
              Text(
                'Scheduled Pickup',
                style: GVTypography.h1.copyWith(
                  color: textColor,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: GVSpacing.xs),
              Text(
                'Plan your trips ahead for school, work and regular journeys.',
                style: GVTypography.bodyMedium.copyWith(
                  color: subtextColor,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),

              const SizedBox(height: GVSpacing.xl),

              // Feature Bullet List
              _buildFeatureRow(
                icon: Icons.calendar_today_rounded,
                text: 'Book one-off or recurring trips',
                textColor: textColor,
              ),
              const SizedBox(height: GVSpacing.md),
              _buildFeatureRow(
                icon: Icons.access_time_rounded,
                text: 'Set preferred pickup times',
                textColor: textColor,
              ),
              const SizedBox(height: GVSpacing.md),
              _buildFeatureRow(
                icon: Icons.person_pin_circle_rounded,
                text: 'Request a preferred driver',
                textColor: textColor,
              ),
              const SizedBox(height: GVSpacing.md),
              _buildFeatureRow(
                icon: Icons.alt_route_rounded,
                text: 'Manage and track scheduled trips',
                textColor: textColor,
              ),

              const SizedBox(height: GVSpacing.xxl),

              // Primary CTA: Create a scheduled pickup
              GVButton(
                text: 'Create a scheduled pickup',
                onPressed: () {
                  context.push(AppRoutes.scheduledBookingType);
                },
              ),

              const SizedBox(height: GVSpacing.md),

              // Secondary CTA: View my scheduled plans
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    context.push(AppRoutes.scheduledMyPlans);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(GVBorderRadius.md),
                    ),
                  ),
                  child: Text(
                    'View my scheduled plans',
                    style: GVTypography.labelLarge.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: GVSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String text,
    required Color textColor,
  }) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: GVColors.primary.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: GVColors.primary),
        ),
        const SizedBox(width: GVSpacing.md),
        Expanded(
          child: Text(
            text,
            style: GVTypography.bodyMedium.copyWith(
              color: textColor,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
