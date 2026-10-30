import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/merchant_bookings_notifier.dart';
import '../../domain/merchant_delivery_model.dart';
import '../../../../core/widgets/merchant_modal_dialog.dart';

class DeliveryDetailDrawer extends ConsumerWidget {
  const DeliveryDetailDrawer({
    super.key,
    required this.booking,
    required this.onClose,
  });

  final MerchantDeliveryBooking booking;
  final VoidCallback onClose;

  void _showCancelModal(BuildContext context, WidgetRef ref) {
    final reasonController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return MerchantModalDialog(
          title: 'Cancel Delivery Booking',
          subtitle: 'Tracking Ref: ${booking.trackingReference}',
          icon: Icons.cancel_outlined,
          accentColor: Colors.redAccent,
          primaryActionLabel: 'Confirm Cancellation',
          onPrimaryAction: () async {
            if (reasonController.text.trim().isEmpty) return;
            Navigator.of(ctx).pop();
            await ref.read(merchantBookingsNotifierProvider.notifier).cancelBooking(
                  bookingId: booking.id,
                  reason: reasonController.text.trim(),
                );
            onClose();
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Are you sure you want to cancel this delivery order? The upfront fare (${booking.formattedFare}) will be automatically refunded to your Corporate Wallet.',
                style: GVTypography.bodySmall.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: GVSpacing.md),
              TextField(
                controller: reasonController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Cancellation Reason *',
                  hintText: 'e.g., Customer called to reschedule dinner order',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 420,
      decoration: const BoxDecoration(
        color: Color(0xFF141C18),
        border: Border(left: BorderSide(color: Color(0xFF223028), width: 1)),
      ),
      child: Column(
        children: [
          // Header Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFF223028))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      booking.trackingReference,
                      style: GVTypography.h3.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      booking.branchName,
                      style: GVTypography.caption.copyWith(color: GVColors.brandGreen),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white54),
                  onPressed: onClose,
                ),
              ],
            ),
          ),

          // Scrollable Body
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(GVSpacing.md),
              children: [
                // Recipient Security OTP Pill
                Container(
                  padding: const EdgeInsets.all(GVSpacing.md),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1B2921),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: GVColors.brandGreen),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'RECIPIENT SECURE OTP',
                            style: GVTypography.caption.copyWith(
                              color: Colors.white60,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Provide to driver upon delivery arrival',
                            style: GVTypography.caption.copyWith(color: Colors.white38, fontSize: 10),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: GVColors.brandGreen,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          booking.recipientOtp,
                          style: const TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: GVSpacing.md),

                // Recipient & Destination Card
                _buildCard(
                  title: 'Destination & Recipient',
                  icon: Icons.person_pin_circle_outlined,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(booking.recipientName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                      Text(booking.recipientPhone, style: GVTypography.caption.copyWith(color: Colors.white60)),
                      const SizedBox(height: 8),
                      Text(booking.deliveryAddress, style: GVTypography.bodySmall.copyWith(color: Colors.white)),
                      const SizedBox(height: 2),
                      Text('Zone: ${booking.deliveryZone}', style: GVTypography.caption.copyWith(color: GVColors.brandGreen)),
                      if (booking.specialInstructions.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E2A23),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'Note: ${booking.specialInstructions}',
                            style: GVTypography.caption.copyWith(color: Colors.white70),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(height: GVSpacing.md),

                // Package Details Card
                _buildCard(
                  title: 'Package Specifications',
                  icon: Icons.inventory_2_outlined,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(booking.packageCategory, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          Text('${booking.weightKg} kg', style: GVTypography.caption.copyWith(color: Colors.white60)),
                        ],
                      ),
                      if (booking.isFragile)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: Colors.amber),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.warning_amber_rounded, size: 14, color: Colors.amber),
                              SizedBox(width: 4),
                              Text('Fragile', style: TextStyle(color: Colors.amber, fontSize: 11, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: GVSpacing.md),

                // Assigned Rider Card
                if (booking.assignedRiderName != null) ...[
                  _buildCard(
                    title: 'Assigned Electric Moped Rider',
                    icon: Icons.electric_moped_outlined,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 18,
                              backgroundColor: GVColors.brandGreen,
                              child: Icon(Icons.person, color: Colors.black, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(booking.assignedRiderName!, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  Text('${booking.assignedRiderPlate} · ${booking.assignedRiderPhone}', style: GVTypography.caption.copyWith(color: Colors.white60)),
                                ],
                              ),
                            ),
                            if (booking.assignedRiderBattery != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: GVColors.brandGreen.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.battery_charging_full, size: 14, color: GVColors.brandGreen),
                                    Text('${booking.assignedRiderBattery}%', style: const TextStyle(color: GVColors.brandGreen, fontSize: 11, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: GVSpacing.md),
                ],

                // Upfront Price Snapshot
                _buildCard(
                  title: 'Financial & Billing Snapshot',
                  icon: Icons.receipt_outlined,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Upfront Fare', style: TextStyle(color: Colors.white70)),
                      Text(
                        booking.formattedFare,
                        style: GVTypography.h3.copyWith(color: GVColors.brandGreen, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: GVSpacing.md),

                // Timeline Card
                _buildCard(
                  title: 'Delivery Progress Timeline',
                  icon: Icons.timeline,
                  child: Column(
                    children: booking.timeline.map((event) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(top: 4),
                              decoration: const BoxDecoration(
                                color: GVColors.brandGreen,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(event.status, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 12)),
                                      Text(event.timestamp, style: GVTypography.caption.copyWith(color: Colors.white38)),
                                    ],
                                  ),
                                  Text(event.note, style: GVTypography.caption.copyWith(color: Colors.white70)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Bottom Cancel Action if eligible
          if (booking.canBeCancelled)
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Color(0xFF223028))),
              ),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showCancelModal(context, ref),
                  icon: const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 18),
                  label: const Text('Cancel Delivery (Refund to Wallet)'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(GVSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF16211C),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF223028)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: GVColors.brandGreen),
              const SizedBox(width: 8),
              Text(
                title.toUpperCase(),
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 10.5,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const Divider(color: Color(0xFF223028), height: GVSpacing.md),
          child,
        ],
      ),
    );
  }
}
