import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../application/parcel_booking_notifier.dart';

/// Screen 16 — Delivery Receipt:
/// Official receipt with tracking reference (DVL12345678), itemized fare breakdown,
/// payment method details, Download/Share actions, and Rate CTA.
class ParcelReceiptScreen extends ConsumerWidget {
  const ParcelReceiptScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(parcelBookingNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final tracking = state.activeDelivery?.trackingNumber ?? 'DVL12345678';
    final quote = state.quote;
    final totalPaid = quote?.formattedTotalFare ?? '₦2,500';

    final pickupLabel = state.pickupLocation?.label ?? 'Eko Hotel and Suites';
    final pickupAddress = state.pickupLocation?.address ?? 'Victoria Island, Lagos';
    final destLabel = state.destinationLocation?.label ?? 'Palms Mall';
    final destAddress = state.destinationLocation?.address ?? 'Lekki, Lagos';

    final packageTitle =
        '${state.selectedCategory.name} item • ${state.weightKg.toStringAsFixed(1)} kg';

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
          'Delivery receipt',
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
                  children: [
                    const SizedBox(height: GVSpacing.sm),

                    // Receipt Container Card
                    Container(
                      padding: const EdgeInsets.all(GVSpacing.lg),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1A221E) : Colors.white,
                        borderRadius: BorderRadius.circular(GVBorderRadius.xl),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF2E3D35)
                              : GVColors.border,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Go-Volts Branding & Timestamp
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 32,
                                      height: 32,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFFDCFCE7),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Center(
                                        child: Text(
                                          'gb',
                                          style: TextStyle(
                                            color: GVColors.deepGreen,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: GVSpacing.sm),
                                    Flexible(
                                      child: Text(
                                        'GO-VOLTS',
                                        style: GVTypography.h3.copyWith(
                                          fontWeight: FontWeight.w900,
                                          color: GVColors.brandGreen,
                                          letterSpacing: 1.0,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: GVSpacing.sm),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Oct 29, 2026, 10:45 AM',
                                    style: GVTypography.caption.copyWith(
                                      color: isDark
                                          ? GVColors.neutral400
                                          : GVColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    tracking,
                                    style: GVTypography.caption.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : GVColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          const SizedBox(height: GVSpacing.md),
                          const Divider(height: 1),
                          const SizedBox(height: GVSpacing.md),

                          // Delivery Details Section
                          Text(
                            'Delivery details',
                            style: GVTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color:
                                  isDark ? Colors.white : GVColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: GVSpacing.sm),

                          // Pickup
                          Row(
                            children: [
                              const Icon(Icons.circle,
                                  size: 10, color: GVColors.brandGreen),
                              const SizedBox(width: GVSpacing.sm),
                              Expanded(
                                child: Text(
                                  '$pickupLabel, $pickupAddress',
                                  style: GVTypography.caption.copyWith(
                                    color: isDark
                                        ? GVColors.neutral300
                                        : GVColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: GVSpacing.xs),

                          // Dropoff
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 12, color: GVColors.error),
                              const SizedBox(width: GVSpacing.sm),
                              Expanded(
                                child: Text(
                                  '$destLabel, $destAddress',
                                  style: GVTypography.caption.copyWith(
                                    color: isDark
                                        ? GVColors.neutral300
                                        : GVColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: GVSpacing.xs),

                          // Package info
                          Row(
                            children: [
                              const Icon(Icons.inventory_2_outlined,
                                  size: 14, color: GVColors.neutral500),
                              const SizedBox(width: GVSpacing.sm),
                              Expanded(
                                child: Text(
                                  '$packageTitle • ${state.selectedDeliveryOption.title}',
                                  style: GVTypography.caption.copyWith(
                                    color: isDark
                                        ? GVColors.neutral300
                                        : GVColors.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: GVSpacing.md),
                          const Divider(height: 1),
                          const SizedBox(height: GVSpacing.md),

                          // Fare breakdown
                          Text(
                            'Fare breakdown',
                            style: GVTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color:
                                  isDark ? Colors.white : GVColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: GVSpacing.sm),

                          _buildReceiptRow(
                            'Base fare',
                            quote?.formattedBaseFare ?? '₦2,000',
                            isDark,
                          ),
                          const SizedBox(height: GVSpacing.xs),
                          _buildReceiptRow(
                            'Distance (${quote?.distanceLabel ?? '12.4 km'})',
                            quote?.formattedDistanceFare ?? '₦300',
                            isDark,
                          ),
                          const SizedBox(height: GVSpacing.xs),
                          _buildReceiptRow(
                            'Package handling',
                            quote?.formattedHandlingFare ?? '₦200',
                            isDark,
                          ),

                          if (quote != null && quote.discountKobo > 0) ...[
                            const SizedBox(height: GVSpacing.xs),
                            _buildReceiptRow(
                              'Promo discount',
                              '-${quote.formattedDiscount}',
                              isDark,
                              color: GVColors.brandGreen,
                            ),
                          ],

                          const SizedBox(height: GVSpacing.sm),
                          const Divider(height: 1),
                          const SizedBox(height: GVSpacing.sm),

                          // Total Paid
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Total paid',
                                style: GVTypography.titleMedium.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark
                                      ? Colors.white
                                      : GVColors.textPrimary,
                                ),
                              ),
                              Text(
                                totalPaid,
                                style: GVTypography.h3.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: GVColors.brandGreen,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: GVSpacing.md),
                          const Divider(height: 1),
                          const SizedBox(height: GVSpacing.md),

                          // Payment method
                          Text(
                            'Payment method',
                            style: GVTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color:
                                  isDark ? Colors.white : GVColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: GVSpacing.sm),
                          Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFDCFCE7),
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text(
                                    'gb',
                                    style: TextStyle(
                                      color: GVColors.deepGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: GVSpacing.sm),
                              Text(
                                state.paymentMethod.label,
                                style: GVTypography.bodySmall.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.white
                                      : GVColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: GVSpacing.lg),

                    // Actions: Download & Share
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Receipt downloaded')),
                              );
                            },
                            icon: const Icon(Icons.download_rounded, size: 18),
                            label: const Text('Download receipt'),
                            style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
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
                          ),
                        ),
                        const SizedBox(width: GVSpacing.md),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Sharing receipt')),
                              );
                            },
                            icon: const Icon(Icons.share_outlined, size: 18),
                            label: const Text('Share'),
                            style: OutlinedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 12),
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
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: GVSpacing.xl),
                  ],
                ),
              ),
            ),

            // Sticky Bottom CTA: Rate delivery
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
                label: 'Rate your experience',
                onPressed: () {
                  if (GoRouter.maybeOf(context) != null) {
                    context.push(AppRoutes.parcelRating);
                  } else {
                    Navigator.of(context).pushNamed(AppRoutes.parcelRating);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value, bool isDark,
      {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GVTypography.bodySmall.copyWith(
            color: isDark ? GVColors.neutral400 : GVColors.textSecondary,
          ),
        ),
        Text(
          value,
          style: GVTypography.bodySmall.copyWith(
            fontWeight: FontWeight.bold,
            color: color ?? (isDark ? Colors.white : GVColors.textPrimary),
          ),
        ),
      ],
    );
  }
}
