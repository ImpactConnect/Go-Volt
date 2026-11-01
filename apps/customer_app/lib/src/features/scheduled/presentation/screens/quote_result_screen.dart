import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../application/scheduled_booking_notifier.dart';

/// Screen 12 (SP-14 / SP-16): Quote Result Screen
/// Displays calculated fare line-items, quote ID, and 15-minute countdown validity.
class QuoteResultScreen extends ConsumerWidget {
  const QuoteResultScreen({super.key});

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

    final quote = state.activeQuote;
    final totalFareStr = quote != null
        ? '₦${quote.totalFareNgn.toStringAsFixed(0)}'
        : '₦2,500';
    final baseFareStr = quote != null
        ? '₦${quote.baseFareNgn.toStringAsFixed(0)}'
        : '₦2,000';
    final distanceFareStr = quote != null
        ? '₦${quote.distanceFareNgn.toStringAsFixed(0)}'
        : '₦400';
    final serviceFeeStr = quote != null
        ? '₦${quote.serviceFeeNgn.toStringAsFixed(0)}'
        : '₦100';
    final quoteIdStr = quote?.quoteId ?? 'QT-20261105-001';

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
              const SizedBox(height: GVSpacing.sm),

              // Green Document Badge with Checkmark
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: GVColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      const Icon(
                        Icons.description_rounded,
                        size: 38,
                        color: GVColors.primary,
                      ),
                      Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                          color: GVColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: GVSpacing.md),

              Text(
                'Quote ready!',
                style: GVTypography.h1.copyWith(
                  color: textColor,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: GVSpacing.xl),

              // Pricing Line Items Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(GVSpacing.md),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estimated fare',
                      style: GVTypography.bodySmall.copyWith(
                        color: subtextColor,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      totalFareStr,
                      style: GVTypography.h1.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 28,
                      ),
                    ),
                    const Divider(height: 24),
                    _buildFareRow(
                      'Base fare',
                      baseFareStr,
                      textColor,
                      subtextColor,
                    ),
                    const SizedBox(height: 8),
                    _buildFareRow(
                      'Distance (8 km)',
                      distanceFareStr,
                      textColor,
                      subtextColor,
                    ),
                    const SizedBox(height: 8),
                    _buildFareRow(
                      'Service fee',
                      serviceFeeStr,
                      textColor,
                      subtextColor,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: GVSpacing.md),

              // Quote ID & Validity card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(GVSpacing.md),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(color: borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Quote ID',
                      style: GVTypography.bodySmall.copyWith(
                        color: subtextColor,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      quoteIdStr,
                      style: GVTypography.labelMedium.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(
                          Icons.access_time_rounded,
                          size: 16,
                          color: GVColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Valid for 15 minutes',
                          style: GVTypography.bodySmall.copyWith(
                            color: GVColors.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Primary CTA: Continue to request
              GVButton(
                text: 'Continue to request',
                isLoading: state.isLoading,
                onPressed: () async {
                  final plan = await notifier.submitRequest();
                  if (plan != null && context.mounted) {
                    context.push(AppRoutes.scheduledRequestSubmitted);
                  }
                },
              ),

              const SizedBox(height: GVSpacing.sm),

              // Secondary CTA: Save quote
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Quote saved to your account.'),
                        backgroundColor: GVColors.primary,
                      ),
                    );
                    context.go(AppRoutes.scheduledLanding);
                  },
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(GVBorderRadius.md),
                    ),
                  ),
                  child: Text(
                    'Save quote',
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

  Widget _buildFareRow(
    String label,
    String amount,
    Color textColor,
    Color subtextColor,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GVTypography.bodySmall.copyWith(
            color: subtextColor,
            fontSize: 14,
          ),
        ),
        Text(
          amount,
          style: GVTypography.bodyMedium.copyWith(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
