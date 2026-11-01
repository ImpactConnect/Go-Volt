import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../application/tracking_notifier.dart';

/// Screen 16 — Trip Receipt ("Here are the details of your trip.")
///
/// Features:
/// - Go-Volts branded invoice header with trip reference and date.
/// - Driver information preview.
/// - Pickup & Dropoff addresses with recorded timestamps.
/// - Itemized fare breakdown (Base, Distance, Time, Platform fee, Promo discount, Total paid).
/// - Payment method summary.
/// - Actions: Download receipt, Share receipt, Report an issue.
class ReceiptScreen extends ConsumerWidget {
  const ReceiptScreen({
    super.key,
    this.tripReference = 'TRP123456789',
    this.formattedDate = 'Oct 29, 2026, 10:17 AM',
  });

  final String tripReference;
  final String formattedDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trackingState = ref.watch(liveTrackingNotifierProvider);
    final booking = trackingState?.booking;
    final breakdown = booking?.priceBreakdown;

    final driverName = booking?.riderName ?? 'Assigned Driver';
    final vehiclePlate = booking?.vehiclePlate ?? '';
    final vehicleModel = booking?.vehicleModel ?? 'Go-Volt EV';
    final rating = booking?.riderRating ?? 5.0;
    final tripsCount = booking?.driverTripsCount ?? 0;

    final pickupAddress = booking?.pickupLocation.address ?? '';
    final destinationAddress = booking?.dropoffLocation.address ?? '';

    final totalPaidLabel = breakdown?.formattedTotalAmount ?? '';
    final baseFareLabel = breakdown?.formattedBaseAmount ?? '';
    final distanceFareLabel = breakdown?.formattedDistanceAmount ?? '';
    final timeFareLabel = breakdown?.formattedTimeAmount ?? '';
    final serviceFeeLabel = breakdown?.formattedServiceFee ?? '';
    final subtotalLabel = breakdown?.formattedSubtotalNaira ?? '';
    final promoDiscountLabel = breakdown?.discountAmountKobo != null &&
            breakdown!.discountAmountKobo > 0
        ? '- ₦${(breakdown.discountAmountKobo / 100).round()}'
        : '- ₦0';

    final fareItems = [
      GVFareItem(label: 'Base fare', amountLabel: baseFareLabel),
      GVFareItem(
        label:
            'Distance (${booking?.distanceKm?.toStringAsFixed(1) ?? '8.4'} km)',
        amountLabel: distanceFareLabel,
      ),
      GVFareItem(
        label: 'Time (${booking?.durationMinutes ?? 12} min)',
        amountLabel: timeFareLabel,
      ),
      GVFareItem(label: 'Service fee', amountLabel: serviceFeeLabel),
      GVFareItem(label: 'Subtotal', amountLabel: subtotalLabel),
      GVFareItem(
        label: 'Promo discount',
        amountLabel: promoDiscountLabel,
        isDiscount: true,
      ),
    ];

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1512) : GVColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: isDark ? GVColors.white : GVColors.textPrimary,
          ),
          onPressed: () {
            if (GoRouter.maybeOf(context) != null) {
              context.pop();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Trip receipt',
                style: GVTypography.titleLarge.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isDark ? GVColors.white : GVColors.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Here are the details of your trip.',
                style: GVTypography.bodyMedium.copyWith(
                  color: isDark ? GVColors.neutral400 : GVColors.neutral600,
                ),
              ),
              const SizedBox(height: GVSpacing.lg),

              GVTripReceiptCard(
                tripReference: tripReference,
                formattedDate: formattedDate,
                driverName: driverName,
                driverVehicle: '$vehicleModel • $vehiclePlate',
                driverRating: rating,
                driverTrips: tripsCount,
                pickupAddress: pickupAddress,
                pickupTime: '10:05 AM',
                destinationAddress: destinationAddress,
                destinationTime: '10:17 AM',
                fareItems: fareItems,
                totalPaidLabel: totalPaidLabel,
                paymentMethodName: 'Go-Volts Wallet',
                paymentMethodAmount: totalPaidLabel,
                onDownloadReceipt: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Downloading digital receipt PDF...'),
                      backgroundColor: GVColors.brandGreen,
                    ),
                  );
                },
                onShareReceipt: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Receipt PDF shared to clipboard!'),
                      backgroundColor: GVColors.brandGreen,
                    ),
                  );
                },
                onReportIssue: () {
                  if (GoRouter.maybeOf(context) != null) {
                    context.push(AppRoutes.tripDispute);
                  }
                },
              ),
              const SizedBox(height: GVSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}
