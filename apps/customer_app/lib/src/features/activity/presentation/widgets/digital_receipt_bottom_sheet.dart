import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Modal bottom sheet showing the official itemized digital receipt (Master Tech Spec §8 & Screen W08/R11).
class DigitalReceiptBottomSheet extends StatelessWidget {
  const DigitalReceiptBottomSheet({
    super.key,
    required this.receipt,
  });

  final TripReceiptDto receipt;

  @override
  Widget build(BuildContext context) {
    final fareItems = [
      GVFareItem(
        label: 'Base Fare',
        amountLabel: '₦${(receipt.priceBreakdown.baseAmountKobo / 100).toStringAsFixed(0)}',
      ),
      if (receipt.priceBreakdown.distanceAmountKobo > 0)
        GVFareItem(
          label: 'Distance Fare (${receipt.distanceKm.toStringAsFixed(1)} km)',
          amountLabel: '₦${(receipt.priceBreakdown.distanceAmountKobo / 100).toStringAsFixed(0)}',
        ),
      if (receipt.priceBreakdown.timeAmountKobo > 0)
        GVFareItem(
          label: 'Time Charge (${receipt.durationMinutes} min)',
          amountLabel: '₦${(receipt.priceBreakdown.timeAmountKobo / 100).toStringAsFixed(0)}',
        ),
      if (receipt.priceBreakdown.serviceFeeKobo > 0)
        GVFareItem(
          label: 'Service & Safety Fee',
          amountLabel: '₦${(receipt.priceBreakdown.serviceFeeKobo / 100).toStringAsFixed(0)}',
        ),
      if (receipt.promoDiscountKobo > 0)
        GVFareItem(
          label: 'Promotional Discount',
          amountLabel: '-₦${(receipt.promoDiscountKobo / 100).toStringAsFixed(0)}',
          isDiscount: true,
        ),
      if (receipt.walletCreditAppliedKobo > 0)
        GVFareItem(
          label: 'Wallet Credit Applied',
          amountLabel: '-₦${(receipt.walletCreditAppliedKobo / 100).toStringAsFixed(0)}',
          isDiscount: true,
        ),
    ];

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: const EdgeInsets.only(top: GVSpacing.sm),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: GVSpacing.sm),
            decoration: BoxDecoration(
              color: GVColors.neutral300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Digital Receipt', style: GVTypography.h3),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(GVSpacing.lg),
              child: GVTripReceiptCard(
                tripReference: receipt.receiptReference,
                formattedDate:
                    '${receipt.pickupTime.day}/${receipt.pickupTime.month}/${receipt.pickupTime.year} • ${receipt.pickupTime.hour.toString().padLeft(2, '0')}:${receipt.pickupTime.minute.toString().padLeft(2, '0')}',
                driverName: receipt.driverName,
                driverVehicle: '${receipt.vehicleModel} • ${receipt.vehiclePlate}',
                driverRating: receipt.driverRating,
                driverTrips: receipt.driverTripsCount,
                pickupAddress: receipt.pickupAddress,
                pickupTime:
                    '${receipt.pickupTime.hour.toString().padLeft(2, '0')}:${receipt.pickupTime.minute.toString().padLeft(2, '0')}',
                destinationAddress: receipt.dropoffAddress,
                destinationTime:
                    '${receipt.dropoffTime.hour.toString().padLeft(2, '0')}:${receipt.dropoffTime.minute.toString().padLeft(2, '0')}',
                fareItems: fareItems,
                totalPaidLabel:
                    '₦${(receipt.totalPaidKobo / 100).toStringAsFixed(0)}',
                paymentMethodName: receipt.paymentMethod.name.toUpperCase(),
                paymentMethodAmount:
                    '₦${(receipt.totalPaidKobo / 100).toStringAsFixed(0)}',
                onDownloadReceipt: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Receipt ${receipt.receiptReference} saved to Downloads.'),
                      backgroundColor: GVColors.deepGreen,
                    ),
                  );
                },
                onShareReceipt: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Receipt link copied to clipboard.'),
                    ),
                  );
                },
                onReportIssue: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Opening Support Ticket for this booking...'),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
