import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../application/scheduled_booking_notifier.dart';

/// Screen 11 (SP-13): Review Your Trip Screen
/// Displays full summary of route, schedule, direction, passenger, and package with inline Edit links.
class ReviewQuoteScreen extends ConsumerWidget {
  const ReviewQuoteScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(scheduledBookingNotifierProvider);
    final notifier = ref.read(scheduledBookingNotifierProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF131A16) : Colors.white;
    final textColor = isDark ? Colors.white : GVColors.textPrimary;
    final subtextColor = isDark ? GVColors.neutral400 : GVColors.textSecondary;
    final cardBg = isDark ? const Color(0xFF1C2420) : const Color(0xFFF6F8F7);
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;

    final dateDisplay = state.isRecurring
        ? '${state.selectedDays.join(', ')} (${state.pickupTime})'
        : '${state.scheduledDate?.day ?? 5} Nov 2026, ${state.pickupTime}';

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
                'Review your trip',
                style: GVTypography.h1.copyWith(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: GVSpacing.xl),

              // Summary Card with inline Edit actions
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  children: [
                    _buildReviewItem(
                      icon: Icons.school_rounded,
                      title: 'Trip purpose',
                      value: state.purpose.label,
                      onEdit: () =>
                          context.push(AppRoutes.scheduledTripPurpose),
                      textColor: textColor,
                      subtextColor: subtextColor,
                    ),
                    const Divider(height: 1),
                    _buildReviewItem(
                      icon: Icons.alt_route_rounded,
                      title: 'Journey type',
                      value: state.journeyDirection.label,
                      onEdit: () {
                        if (state.isRecurring) {
                          context.push(AppRoutes.scheduledCalendar);
                        } else {
                          context.push(AppRoutes.scheduledTripDetails);
                        }
                      },
                      textColor: textColor,
                      subtextColor: subtextColor,
                    ),
                    const Divider(height: 1),
                    _buildReviewItem(
                      icon: Icons.location_on_rounded,
                      iconColor: GVColors.primary,
                      title: 'Pickup',
                      value: state.pickupLocation.address,
                      onEdit: () =>
                          context.push(AppRoutes.scheduledPickupLocation),
                      textColor: textColor,
                      subtextColor: subtextColor,
                    ),
                    const Divider(height: 1),
                    _buildReviewItem(
                      icon: Icons.location_on_rounded,
                      iconColor: Colors.redAccent,
                      title: 'Destination',
                      value: state.destinationLocation.address,
                      onEdit: () =>
                          context.push(AppRoutes.scheduledDestination),
                      textColor: textColor,
                      subtextColor: subtextColor,
                    ),
                    const Divider(height: 1),
                    _buildReviewItem(
                      icon: Icons.calendar_today_rounded,
                      title: 'Date & time',
                      value: dateDisplay,
                      onEdit: () {
                        if (state.isRecurring) {
                          context.push(AppRoutes.scheduledCalendar);
                        } else {
                          context.push(AppRoutes.scheduledTripDetails);
                        }
                      },
                      textColor: textColor,
                      subtextColor: subtextColor,
                    ),
                    const Divider(height: 1),
                    _buildReviewItem(
                      icon: Icons.card_giftcard_rounded,
                      title: 'Package',
                      value: state.billingModel.label,
                      onEdit: () =>
                          context.push(AppRoutes.scheduledPackagePricing),
                      textColor: textColor,
                      subtextColor: subtextColor,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: GVSpacing.md),

              // Estimated Price row
              Container(
                padding: const EdgeInsets.all(GVSpacing.md),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.payments_outlined,
                      size: 20,
                      color: GVColors.primary,
                    ),
                    const SizedBox(width: GVSpacing.md),
                    Text(
                      'Estimated price',
                      style: GVTypography.bodyMedium.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '₦2,500',
                      style: GVTypography.labelLarge.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Primary CTA: Get quote
              GVButton(
                text: 'Get quote',
                isLoading: state.isLoading,
                onPressed: () async {
                  final quote = await notifier.generateQuote();
                  if (quote != null && context.mounted) {
                    context.push(AppRoutes.scheduledQuoteResult);
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

  Widget _buildReviewItem({
    required IconData icon,
    Color? iconColor,
    required String title,
    required String value,
    required VoidCallback onEdit,
    required Color textColor,
    required Color subtextColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: iconColor ?? subtextColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GVTypography.bodySmall.copyWith(
                    color: subtextColor,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: GVTypography.bodyMedium.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          InkWell(
            onTap: onEdit,
            child: Text(
              'Edit',
              style: TextStyle(
                color: GVColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
