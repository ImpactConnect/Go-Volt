import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../application/parcel_booking_notifier.dart';

/// Screen 9 — Booking Confirmation:
/// Green celebratory confirmation badge, tracking reference (DVL12345678) with copy action,
/// summary of pickup/destination and package specs, and "Track delivery" CTA.
class ParcelConfirmationScreen extends ConsumerWidget {
  const ParcelConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(parcelBookingNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final tracking = state.activeDelivery?.trackingNumber ?? 'DVL12345678';
    final pickupLabel = state.pickupLocation?.label ?? 'Eko Hotel and Suites';
    final pickupAddress = state.pickupLocation?.address ?? 'Victoria Island, Lagos';
    final destLabel = state.destinationLocation?.label ?? 'Palms Mall';
    final destAddress = state.destinationLocation?.address ?? 'Lekki, Lagos';

    final packageTitle =
        '${state.selectedCategory.name} item • ${state.weightKg.toStringAsFixed(1)} kg';
    final deliveryOptionTitle =
        '${state.selectedDeliveryOption.title}\n${state.selectedDeliveryOption.description}';

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1512) : GVColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.close_rounded,
            color: isDark ? GVColors.white : GVColors.textPrimary,
            size: 24,
          ),
          onPressed: () {
            if (GoRouter.maybeOf(context) != null) {
              context.go(AppRoutes.home);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
                child: Column(
                  children: [
                    const SizedBox(height: GVSpacing.md),

                    // 1. Success Icon Badge with Ripple Glow
                    Center(
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: GVColors.brandGreen,
                          boxShadow: [
                            BoxShadow(
                              color: GVColors.brandGreen.withValues(alpha: 0.35),
                              blurRadius: 24,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 46,
                        ),
                      ),
                    ),
                    const SizedBox(height: GVSpacing.lg),

                    // Title & Subtitle
                    Text(
                      'Delivery request sent!',
                      style: GVTypography.h2.copyWith(
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : GVColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: GVSpacing.xs),
                    Text(
                      'We are looking for a rider to deliver\nyour parcel.',
                      style: GVTypography.bodyMedium.copyWith(
                        color: isDark
                            ? GVColors.neutral400
                            : GVColors.textSecondary,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: GVSpacing.xl),

                    // 2. Tracking Number Box with Copy Action
                    Container(
                      padding: const EdgeInsets.all(GVSpacing.md),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1A221E)
                            : const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(GVBorderRadius.md),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF2E3D35)
                              : GVColors.border,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tracking number',
                                style: GVTypography.caption.copyWith(
                                  color: isDark
                                      ? GVColors.neutral400
                                      : GVColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                tracking,
                                style: GVTypography.body.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: isDark
                                      ? Colors.white
                                      : GVColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.copy_rounded,
                              size: 20,
                              color: GVColors.brandGreen,
                            ),
                            tooltip: 'Copy tracking number',
                            onPressed: () {
                              Clipboard.setData(ClipboardData(text: tracking));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Tracking number copied to clipboard',
                                  ),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: GVSpacing.lg),

                    // 3. Route & Package Summary Card
                    Container(
                      padding: const EdgeInsets.all(GVSpacing.md),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1A221E)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(GVBorderRadius.lg),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF2E3D35)
                              : GVColors.border,
                        ),
                      ),
                      child: Column(
                        children: [
                          // Pickup
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 4),
                                child: Icon(
                                  Icons.circle,
                                  size: 10,
                                  color: GVColors.brandGreen,
                                ),
                              ),
                              const SizedBox(width: GVSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pickupLabel,
                                      style: GVTypography.bodyMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : GVColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      pickupAddress,
                                      style: GVTypography.caption.copyWith(
                                        color: isDark
                                            ? GVColors.neutral400
                                            : GVColors.textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Divider(height: 1),
                          ),

                          // Dropoff
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Padding(
                                padding: EdgeInsets.only(top: 2),
                                child: Icon(
                                  Icons.location_on,
                                  size: 14,
                                  color: GVColors.error,
                                ),
                              ),
                              const SizedBox(width: GVSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      destLabel,
                                      style: GVTypography.bodyMedium.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : GVColors.textPrimary,
                                      ),
                                    ),
                                    Text(
                                      destAddress,
                                      style: GVTypography.caption.copyWith(
                                        color: isDark
                                            ? GVColors.neutral400
                                            : GVColors.textSecondary,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Divider(height: 1),
                          ),

                          // Package specs
                          Row(
                            children: [
                              const Icon(
                                Icons.inventory_2_outlined,
                                size: 16,
                                color: GVColors.neutral500,
                              ),
                              const SizedBox(width: GVSpacing.md),
                              Expanded(
                                child: Text(
                                  packageTitle,
                                  style: GVTypography.bodySmall.copyWith(
                                    color: isDark
                                        ? Colors.white
                                        : GVColors.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: GVSpacing.xs),

                          // Service Tier
                          Row(
                            children: [
                              const Icon(
                                Icons.schedule_rounded,
                                size: 16,
                                color: GVColors.neutral500,
                              ),
                              const SizedBox(width: GVSpacing.md),
                              Expanded(
                                child: Text(
                                  deliveryOptionTitle.replaceAll('\n', ' • '),
                                  style: GVTypography.caption.copyWith(
                                    color: isDark
                                        ? GVColors.neutral400
                                        : GVColors.textSecondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: GVSpacing.xl),
                  ],
                ),
              ),
            ),

            // Sticky Bottom CTAs
            Container(
              padding: const EdgeInsets.all(GVSpacing.lg),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131A16) : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  GVPrimaryButton(
                    label: 'Track delivery',
                    onPressed: () {
                      if (GoRouter.maybeOf(context) != null) {
                        context.push(AppRoutes.parcelFindingRider);
                      } else {
                        Navigator.of(context)
                            .pushNamed(AppRoutes.parcelFindingRider);
                      }
                    },
                  ),
                  const SizedBox(height: GVSpacing.sm),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton(
                      onPressed: () {
                        if (GoRouter.maybeOf(context) != null) {
                          context.push(AppRoutes.parcelReviewQuote);
                        } else {
                          Navigator.of(context)
                              .pushNamed(AppRoutes.parcelReviewQuote);
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: isDark
                              ? const Color(0xFF2E3D35)
                              : GVColors.border,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(GVBorderRadius.md),
                        ),
                      ),
                      child: Text(
                        'View details',
                        style: GVTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : GVColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
