import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/admin_modal_dialog.dart';
import '../../application/booking_management_notifier.dart';
import '../../domain/booking_management_state.dart';

class BookingDetailModal extends StatelessWidget {
  const BookingDetailModal({
    super.key,
    required this.booking,
    required this.notifier,
  });

  final AdminBookingItem booking;
  final BookingManagementNotifier notifier;

  void _showReassignDialog(BuildContext context) {
    final riderCtrl = TextEditingController(text: 'Aminu Dantata');
    final plateCtrl = TextEditingController(text: 'LAG-310-EV');
    final reasonCtrl = TextEditingController(text: 'Previous rider delayed in traffic');

    showDialog<void>(
      context: context,
      builder: (dCtx) {
        return AdminModalDialog(
          title: 'Reassign Booking Rider',
          subtitle: 'Transfer ${booking.reference} to another available EV rider',
          confirmLabel: 'Confirm Reassignment',
          onConfirm: () async {
            final success = await notifier.reassignBooking(
              bookingId: booking.id,
              newRiderName: riderCtrl.text.trim(),
              newRiderPlate: plateCtrl.text.trim(),
              reason: reasonCtrl.text.trim(),
            );
            if (dCtx.mounted && success) {
              Navigator.of(dCtx).pop(); // close reassign dialog
              Navigator.of(context).pop(); // close detail dialog
            }
          },
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('New Rider Name *', style: GVTypography.caption.copyWith(color: Colors.white70)),
              const SizedBox(height: 4),
              TextField(
                controller: riderCtrl,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: GVSpacing.sm),
              Text('Vehicle Plate *', style: GVTypography.caption.copyWith(color: Colors.white70)),
              const SizedBox(height: 4),
              TextField(
                controller: plateCtrl,
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: GVSpacing.sm),
              Text('Mandatory Audit Reason *', style: GVTypography.caption.copyWith(color: Colors.white70)),
              const SizedBox(height: 4),
              TextField(
                controller: reasonCtrl,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Enter reason for reassignment...',
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCancelDialog(BuildContext context) {
    final reasonCtrl = TextEditingController(text: 'Customer requested cancellation via call center');
    var refundCustomer = true;

    showDialog<void>(
      context: context,
      builder: (dCtx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return AdminModalDialog(
              title: 'Cancel Booking',
              subtitle: 'Are you sure you want to cancel booking ${booking.reference}?',
              confirmLabel: 'Confirm Cancellation',
              isDestructive: true,
              onConfirm: () async {
                final success = await notifier.cancelBooking(
                  bookingId: booking.id,
                  reason: reasonCtrl.text.trim(),
                  refundCustomer: refundCustomer,
                );
                if (modalCtx.mounted && success) {
                  Navigator.of(modalCtx).pop(); // close cancel dialog
                  Navigator.of(context).pop(); // close detail dialog
                }
              },
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Mandatory Cancellation Reason *', style: GVTypography.caption.copyWith(color: Colors.white70)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: reasonCtrl,
                    style: const TextStyle(color: Colors.white),
                  ),
                  const SizedBox(height: GVSpacing.sm),
                  Row(
                    children: [
                      Checkbox(
                        value: refundCustomer,
                        activeColor: GVColors.brandGreen,
                        onChanged: (val) {
                          setModalState(() => refundCustomer = val ?? true);
                        },
                      ),
                      const Expanded(
                        child: Text(
                          'Issue automatic wallet refund to customer (₦ gross fare)',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF141C18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        side: const BorderSide(color: Color(0xFF24342A)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: Padding(
          padding: const EdgeInsets.all(GVSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        booking.reference,
                        style: GVTypography.h2.copyWith(color: Colors.white),
                      ),
                      const SizedBox(width: 8),
                      GVStatusChip(
                        label: booking.status.name.toUpperCase(),
                        status: booking.status == BookingStatus.completed
                            ? GVStatusType.active
                            : (booking.status == BookingStatus.cancelled
                                ? GVStatusType.delayed
                                : GVStatusType.assigned),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Text(
                'Source: ${booking.source} · Created: ${booking.createdAt}',
                style: GVTypography.caption.copyWith(color: Colors.white54),
              ),
              const Divider(color: Color(0xFF233229), height: GVSpacing.lg),

              // Route & Waypoints Card
              Container(
                padding: const EdgeInsets.all(GVSpacing.sm),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2620),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.radio_button_checked, size: 16, color: GVColors.brandGreen),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Pickup Location', style: GVTypography.caption.copyWith(color: Colors.white54)),
                              Text(booking.pickupAddress, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 4),
                      child: Divider(color: Colors.white12, height: 1),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.location_on, size: 16, color: Colors.amber),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Dropoff Destination', style: GVTypography.caption.copyWith(color: Colors.white54)),
                              Text(booking.dropoffAddress, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GVSpacing.md),

              // Customer & Rider Details
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(GVSpacing.sm),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B2620),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Customer', style: GVTypography.caption.copyWith(color: Colors.white54)),
                          Text(booking.customerName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          Text(booking.customerPhone, style: GVTypography.caption.copyWith(color: GVColors.brandGreen)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: GVSpacing.sm),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(GVSpacing.sm),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1B2620),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Assigned Rider', style: GVTypography.caption.copyWith(color: Colors.white54)),
                          Text(booking.riderName ?? 'Unassigned', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          Text(
                            booking.riderPlate != null ? 'Plate: ${booking.riderPlate}' : 'Awaiting dispatch',
                            style: GVTypography.caption.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: GVSpacing.md),

              // Financial Ledger Breakdown Snapshot
              Container(
                padding: const EdgeInsets.all(GVSpacing.sm),
                decoration: BoxDecoration(
                  color: const Color(0xFF14241B),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF263F30)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        Text('Customer Gross', style: GVTypography.caption.copyWith(color: Colors.white60)),
                        Text('₦${booking.grossFareNaira.toStringAsFixed(0)}', style: GVTypography.h3.copyWith(color: Colors.white)),
                      ],
                    ),
                    Column(
                      children: [
                        Text('Platform Fee (20%)', style: GVTypography.caption.copyWith(color: Colors.white60)),
                        Text('₦${booking.commissionNaira.toStringAsFixed(0)}', style: GVTypography.h3.copyWith(color: Colors.amber)),
                      ],
                    ),
                    Column(
                      children: [
                        Text('Rider Take-Home (80%)', style: GVTypography.caption.copyWith(color: Colors.white60)),
                        Text('₦${booking.riderTakeHomeNaira.toStringAsFixed(0)}', style: GVTypography.h3.copyWith(color: GVColors.brandGreen)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GVSpacing.md),

              // Audit Timeline
              Text('Audit Status Events', style: GVTypography.caption.copyWith(color: Colors.white60, fontWeight: FontWeight.bold)),
              const SizedBox(height: 6),
              ...booking.timeline.map((event) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Text(
                        event.timestamp,
                        style: const TextStyle(color: Colors.white38, fontSize: 11, fontFamily: 'monospace'),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFF22362A),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          event.status,
                          style: const TextStyle(color: GVColors.brandGreen, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          event.note,
                          style: const TextStyle(color: Colors.white70, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: GVSpacing.lg),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                    ),
                    onPressed: () => _showCancelDialog(context),
                    child: const Text('Cancel Booking'),
                  ),
                  const SizedBox(width: GVSpacing.sm),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GVColors.brandGreen,
                      foregroundColor: GVColors.nearBlack,
                    ),
                    onPressed: () => _showReassignDialog(context),
                    child: const Text('Reassign Rider'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
