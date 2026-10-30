import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Screen W08: Itemized Electronic Receipt, Tax Invoice & Environmental Footprint.
class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({
    super.key,
    this.tripReference = 'TRP-LAG-8921',
    this.serviceName = 'Passenger Commute · Spiro EV',
    this.dateTime = 'Today, 14:35',
    this.pickupAddress = '14 Admiralty Way, Lekki Phase 1',
    this.dropoffAddress = '18 Adeola Odeku St, Victoria Island',
    this.grossFare = 3500.0,
    this.discount = 500.0,
    this.vat = 225.0,
    this.totalPaid = 3225.0,
    this.paymentMethod = 'Go-Volts Ride Wallet (Settled)',
  });

  final String tripReference;
  final String serviceName;
  final String dateTime;
  final String pickupAddress;
  final String dropoffAddress;
  final double grossFare;
  final double discount;
  final double vat;
  final double totalPaid;
  final String paymentMethod;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GVColors.darkBg,
      appBar: AppBar(
        title: const Text('Trip Receipt & Tax Invoice'),
        backgroundColor: GVColors.darkBg,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Share Receipt',
            icon: const Icon(Icons.share, color: GVColors.brandGreen),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Receipt PDF share sheet triggered.')),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(GVSpacing.md),
          children: [
            // Receipt Container Card
            Container(
              padding: const EdgeInsets.all(GVSpacing.lg),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2420),
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                border: Border.all(color: const Color(0xFF2A3630)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('GO-VOLTS NIGERIA',
                              style: GVTypography.h3.copyWith(color: GVColors.brandGreen, letterSpacing: 1.2)),
                          const SizedBox(height: 2),
                          Text('Tax Invoice & Payment Receipt',
                              style: GVTypography.caption.copyWith(color: Colors.white60)),
                        ],
                      ),
                      const GVStatusChip(label: 'PAID & SETTLED', status: GVStatusType.active),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 24),

                  _buildReceiptRow('Transaction Ref', tripReference),
                  _buildReceiptRow('Date & Time', dateTime),
                  _buildReceiptRow('Service Tier', serviceName),
                  _buildReceiptRow('Payment Channel', paymentMethod),
                  const Divider(color: Colors.white24, height: 24),

                  // Route
                  Text('Route Details', style: GVTypography.caption.copyWith(color: Colors.white60)),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.circle, color: GVColors.brandGreen, size: 10),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(pickupAddress,
                            style: const TextStyle(color: Colors.white, fontSize: 13), overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.location_on, color: Colors.redAccent, size: 12),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(dropoffAddress,
                            style: const TextStyle(color: Colors.white, fontSize: 13), overflow: TextOverflow.ellipsis),
                      ),
                    ],
                  ),
                  const Divider(color: Colors.white24, height: 24),

                  // Itemized Accounting
                  Text('Itemized Fare Breakdown', style: GVTypography.caption.copyWith(color: Colors.white60)),
                  const SizedBox(height: 8),
                  _buildFareRow('Base Fare', '₦${(grossFare * 0.4).toStringAsFixed(2)}'),
                  _buildFareRow('Distance Fare (8.2 km)', '₦${(grossFare * 0.6).toStringAsFixed(2)}'),
                  _buildFareRow('Promo Coupon (VOLT50)', '-₦${discount.toStringAsFixed(2)}', isDiscount: true),
                  _buildFareRow('Lagos State VAT (7.5%)', '₦${vat.toStringAsFixed(2)}'),
                  const Divider(color: Colors.white24, height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Total Paid', style: GVTypography.h3.copyWith(color: Colors.white)),
                      Text('₦${totalPaid.toStringAsFixed(2)}',
                          style: GVTypography.h2.copyWith(color: GVColors.brandGreen, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.md),

            // Carbon Impact Certificate Card
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [GVColors.deepGreen, Color(0xFF133B26)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
              ),
              child: Row(
                children: [
                  const Icon(Icons.eco, color: GVColors.brandGreen, size: 36),
                  const SizedBox(width: GVSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('1.84 kg CO2 Offset',
                            style: GVTypography.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                        Text('By choosing Go-Volts EV, you prevented 0.8 liters of fossil fuel combustion in Lagos.',
                            style: GVTypography.caption.copyWith(color: Colors.white70)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.lg),

            GVSecondaryButton(
              label: 'Download PDF Invoice',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invoice PDF saved to device downloads.'),
                    backgroundColor: GVColors.deepGreen,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiptRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFareRow(String label, String value, {bool isDiscount = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              color: isDiscount ? GVColors.brandGreen : Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
