import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../application/parcel_booking_notifier.dart';

/// Screen 2 — Send a Parcel: Choose Delivery Type (Standard, Express, Scheduled).
class ParcelDeliveryTypeScreen extends ConsumerWidget {
  const ParcelDeliveryTypeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(parcelBookingNotifierProvider);
    final notifier = ref.read(parcelBookingNotifierProvider.notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final options = DeliveryOptionDto.defaultOptions;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1512) : GVColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? GVColors.white : GVColors.textPrimary,
            size: 20,
          ),
          onPressed: () {
            if (GoRouter.maybeOf(context) != null) {
              context.pop();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
        title: Text(
          'Send a Parcel',
          style: GVTypography.h3.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? GVColors.white : GVColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: GVSpacing.sm),
                    Text(
                      'Choose a delivery type',
                      style: GVTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? GVColors.white : GVColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: GVSpacing.md),

                    // Delivery Type Selection Cards
                    for (final option in options) ...[
                      GVDeliveryTypeCard(
                        title: option.title,
                        description: option.description,
                        icon: option.code == 'EXPRESS'
                            ? Icons.electric_bolt_rounded
                            : (option.code == 'SCHEDULED'
                                ? Icons.calendar_month_rounded
                                : Icons.inventory_2_rounded),
                        isSelected:
                            state.selectedDeliveryOption.code == option.code,
                        onTap: () => notifier.selectDeliveryOption(option),
                      ),
                      const SizedBox(height: GVSpacing.md),
                    ],

                    const SizedBox(height: GVSpacing.md),

                    // Value Propositions List
                    _buildValueProposition(
                      context,
                      icon: Icons.track_changes_rounded,
                      title: 'Real-time tracking',
                      subtitle: 'Track your parcel live',
                    ),
                    const SizedBox(height: GVSpacing.md),
                    _buildValueProposition(
                      context,
                      icon: Icons.shield_outlined,
                      title: 'Safe and reliable',
                      subtitle: 'Trusted riders',
                    ),
                    const SizedBox(height: GVSpacing.md),
                    _buildValueProposition(
                      context,
                      icon: Icons.sell_outlined,
                      title: 'Affordable rates',
                      subtitle: 'Transparent pricing',
                    ),
                    const SizedBox(height: GVSpacing.xl),
                  ],
                ),
              ),
            ),

            // Sticky Bottom CTA: Continue
            Container(
              padding: const EdgeInsets.all(GVSpacing.lg),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131A16) : GVColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: GVPrimaryButton(
                label: 'Continue',
                onPressed: () {
                  if (GoRouter.maybeOf(context) != null) {
                    context.push(AppRoutes.packageDetails);
                  } else {
                    Navigator.of(context).pushNamed(AppRoutes.packageDetails);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValueProposition(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF1E2822)
                : const Color(0xFFF0FDF4),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: GVColors.deepGreen,
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
                  color: isDark ? GVColors.white : GVColors.textPrimary,
                ),
              ),
              Text(
                subtitle,
                style: GVTypography.bodySmall.copyWith(
                  color: isDark ? GVColors.neutral400 : GVColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

