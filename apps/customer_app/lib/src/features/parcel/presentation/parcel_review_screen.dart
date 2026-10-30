import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../application/parcel_booking_notifier.dart';

/// Screen 7 — Review and Quote:
/// Summarizes delivery details (pickup & dropoff with edit shortcut),
/// package details (category, weight, size band, special handling, delivery tier),
/// and itemized exact integer-kobo price breakdown.
class ParcelReviewScreen extends ConsumerWidget {
  const ParcelReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(parcelBookingNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final quote = state.quote;
    final pickup = state.pickupLocation?.address ??
        'Eko Hotel and Suites, Victoria Island, Lagos';
    final destination =
        state.destinationLocation?.address ?? 'Palms Mall, Lekki, Lagos';

    // Package subtitle
    final packageTitle = '${state.selectedCategory.name} item';
    final handlingTag = state.handlingOptions
        .where((h) => h.isEnabled)
        .map((h) => h.label)
        .join(', ');
    final fullHandlingTag = handlingTag.isNotEmpty
        ? handlingTag
        : 'Standard handling';

    final packageSubtitle =
        '${state.weightKg.toStringAsFixed(1)} kg • ${state.selectedSizeBand.label}\n$fullHandlingTag';

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
          'Review and Quote',
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
                    const SizedBox(height: GVSpacing.xs),

                    // Reusable Review Card Component
                    GVParcelReviewCard(
                      pickupAddress: pickup,
                      deliveryAddress: destination,
                      packageTitle: packageTitle,
                      handlingTag: packageSubtitle,
                      deliveryTypeTitle:
                          '${state.selectedDeliveryOption.title}\n${state.selectedDeliveryOption.description}',
                      baseFareLabel: quote?.formattedBaseFare ?? '₦2,000',
                      distanceFareLabel: quote?.formattedDistanceFare ?? '₦300',
                      distanceLabel: quote?.distanceLabel ?? '12.4 km',
                      handlingFareLabel: quote?.formattedHandlingFare ?? '₦200',
                      insuranceFareLabel: quote?.formattedInsuranceFare ?? '₦0',
                      totalFareLabel: quote?.formattedTotalFare ?? '₦2,500',
                      onEditDeliveryDetails: () {
                        if (GoRouter.maybeOf(context) != null) {
                          context.push(AppRoutes.parcelPickupLocation);
                        } else {
                          Navigator.of(context)
                              .pushNamed(AppRoutes.parcelPickupLocation);
                        }
                      },
                    ),

                    const SizedBox(height: GVSpacing.xl),
                  ],
                ),
              ),
            ),

            // Sticky Bottom CTA: Continue to payment
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
                label: 'Continue to payment',
                onPressed: () {
                  if (GoRouter.maybeOf(context) != null) {
                    context.push(AppRoutes.parcelPayment);
                  } else {
                    Navigator.of(context).pushNamed(AppRoutes.parcelPayment);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
