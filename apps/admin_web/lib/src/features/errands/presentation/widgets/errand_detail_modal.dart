import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/admin_modal_dialog.dart';
import '../../application/errand_operations_notifier.dart';

class ErrandDetailModal extends ConsumerWidget {
  const ErrandDetailModal({
    super.key,
    required this.errand,
  });

  final ErrandDto errand;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(errandOperationsNotifierProvider.notifier);

    return AdminModalDialog(
      title: 'Errand Details — ${errand.referenceNumber}',
      maxWidth: 780,
      cancelLabel: 'Close',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header summary badge
          Container(
            padding: const EdgeInsets.all(GVSpacing.md),
            decoration: BoxDecoration(
              color: const Color(0xFF14241B),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF263C2E)),
            ),
            child: Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 12,
              runSpacing: 8,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTypeChip(errand.type),
                    const SizedBox(width: 8),
                    _buildStatusChip(errand.status),
                  ],
                ),
                Text(
                  'Created: ${errand.createdAt.hour.toString().padLeft(2, '0')}:${errand.createdAt.minute.toString().padLeft(2, '0')}',
                  style: GVTypography.caption.copyWith(color: Colors.white70),
                ),
              ],
            ),
          ),
          const SizedBox(height: GVSpacing.md),

          // Two-column layout for details
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Customer & Rider Info
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(GVSpacing.md),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161F1A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF263C2E)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CUSTOMER & DESTINATION',
                        style: GVTypography.caption.copyWith(
                          color: GVColors.brandGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        errand.recipient.fullName,
                        style: GVTypography.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        errand.recipient.phoneNumber,
                        style: GVTypography.caption.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.location_on_outlined,
                              size: 16, color: Colors.white60),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              errand.deliveryLocation.address,
                              style: GVTypography.caption.copyWith(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                      if (errand.recipient.additionalAddressInfo != null &&
                          errand.recipient.additionalAddressInfo!.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Delivery Note: "${errand.recipient.additionalAddressInfo}"',
                          style: GVTypography.caption.copyWith(
                            color: Colors.amber,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                      const Divider(color: Color(0xFF263C2E), height: 20),

                      // Rider / Shopper Section
                      Text(
                        'ASSIGNED SHOPPER / RIDER',
                        style: GVTypography.caption.copyWith(
                          color: GVColors.brandGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (errand.assignedRider != null) ...[
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: const Color(0xFF14241B),
                              child: Text(
                                errand.assignedRider!.fullName[0],
                                style: const TextStyle(
                                  color: GVColors.brandGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    errand.assignedRider!.fullName,
                                    style: GVTypography.bodySmall.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '${errand.assignedRider!.vehicleModel} • ${errand.assignedRider!.vehiclePlate}',
                                    style: GVTypography.caption.copyWith(
                                      color: Colors.white60,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Text(
                          'No rider currently assigned',
                          style: GVTypography.caption.copyWith(color: Colors.redAccent),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: GVSpacing.md),

              // Right Column: Flow-Specific Task Details
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(GVSpacing.md),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161F1A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF263C2E)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TASK SPECIFICATION',
                        style: GVTypography.caption.copyWith(
                          color: GVColors.brandGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (errand.type == ErrandType.buyItems) ...[
                        Text(
                          'Store: ${errand.shop?.name ?? 'Nearby Market'}',
                          style: GVTypography.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (errand.shop?.address != null)
                          Text(
                            errand.shop!.address,
                            style: GVTypography.caption.copyWith(color: Colors.white60),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          'Items (${errand.items.length}):',
                          style: GVTypography.caption.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ...errand.items.map((it) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    it.isPurchased
                                        ? Icons.check_circle
                                        : Icons.radio_button_unchecked,
                                    size: 14,
                                    color: it.isPurchased
                                        ? GVColors.brandGreen
                                        : Colors.white38,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      '${it.name} (${it.quantity} ${it.unit})',
                                      style: GVTypography.caption.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    it.actualPriceKobo != null
                                        ? '₦${(it.actualPriceKobo! / 100).toStringAsFixed(0)}'
                                        : '₦${(it.estimatedPriceKobo / 100).toStringAsFixed(0)} (est)',
                                    style: GVTypography.caption.copyWith(
                                      color: it.actualPriceKobo != null
                                          ? GVColors.brandGreen
                                          : Colors.white70,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        if (errand.preferences != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Substitution: ${errand.preferences!.substitutionPolicy.title}',
                            style: GVTypography.caption.copyWith(
                              color: Colors.amber,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ] else if (errand.type == ErrandType.pickupPackage) ...[
                        Text(
                          'Pickup: ${errand.pickupDetails?.pickupBusinessName ?? 'Custom Address'}',
                          style: GVTypography.bodySmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Contact: ${errand.pickupDetails?.contactPerson ?? 'N/A'} (${errand.pickupDetails?.phoneNumber ?? 'N/A'})',
                          style: GVTypography.caption.copyWith(color: Colors.white60),
                        ),
                        if (errand.pickupDetails?.referenceOrderNumber != null)
                          Text(
                            'Order #: ${errand.pickupDetails!.referenceOrderNumber}',
                            style: GVTypography.caption.copyWith(color: GVColors.brandGreen),
                          ),
                        const SizedBox(height: 8),
                        Text(
                          'Package: ${errand.packageDetails?.description ?? 'Standard Package'}',
                          style: GVTypography.caption.copyWith(color: Colors.white70),
                        ),
                        Text(
                          'Weight: ${errand.packageDetails?.formattedWeight ?? '3.5 kg'} • ${errand.packageDetails?.sizeBand.label ?? 'Medium'}',
                          style: GVTypography.caption.copyWith(color: Colors.white60),
                        ),
                      ] else ...[
                        Text(
                          'Custom Errand Description:',
                          style: GVTypography.caption.copyWith(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          errand.customErrandDetails?.description ??
                              'Custom errands task requested by customer.',
                          style: GVTypography.caption.copyWith(color: Colors.white),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Category: ${errand.customErrandDetails?.category ?? 'General'} • Urgency: ${errand.customErrandDetails?.urgency.label ?? 'Standard'}',
                          style: GVTypography.caption.copyWith(color: Colors.amber),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: GVSpacing.md),

          // Financial Breakdown Card
          Container(
            padding: const EdgeInsets.all(GVSpacing.md),
            decoration: BoxDecoration(
              color: const Color(0xFF14241B),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF263C2E)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'FINANCIAL TOTAL',
                      style: GVTypography.caption.copyWith(
                        color: GVColors.brandGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₦${(errand.quote.totalKobo / 100).toStringAsFixed(0)}',
                      style: GVTypography.h3.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 16,
                  children: [
                    _financialStat('Service Fee', '₦${(errand.quote.serviceFeeKobo / 100).toStringAsFixed(0)}'),
                    _financialStat('Delivery Fee', '₦${(errand.quote.deliveryFeeKobo / 100).toStringAsFixed(0)}'),
                    if (errand.quote.estimatedItemsCostKobo > 0)
                      _financialStat('Items Budget', '₦${(errand.quote.estimatedItemsCostKobo / 100).toStringAsFixed(0)}'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: GVSpacing.md),

          // Operational Controls Row
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () {
                  // Simulate rapid reassign to top available standby driver
                  const standbyShopper = RiderDto(
                    id: 'RIDER-003',
                    profileId: 'PROF-003',
                    fullName: 'Fatima Abubakar',
                    phoneNumber: '+2348023456789',
                    rating: 4.95,
                    status: RiderStatus.assigned,
                    vehiclePlate: 'KN-789-GH',
                    vehicleModel: 'Ampersand Cargo EV',
                    batteryLevelPercent: 91,
                  );
                  notifier.reassignShopper(
                    errand.id,
                    standbyShopper,
                    reason: 'Admin manual re-assignment to faster standby EV rider',
                  );
                  Navigator.of(context).pop();
                },
                icon: const Icon(Icons.swap_horiz, size: 16),
                label: const Text('Reassign Standby Shopper'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: GVColors.brandGreen,
                  side: const BorderSide(color: GVColors.brandGreen),
                ),
              ),
              if (errand.status != ErrandStatus.completed) ...[
                ElevatedButton.icon(
                  onPressed: () {
                    notifier.updateErrandStatus(
                      errand.id,
                      ErrandStatus.completed,
                      notes: 'Marked completed by operations supervisor desk',
                    );
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(Icons.check, size: 16),
                  label: const Text('Mark Completed'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GVColors.brandGreen,
                    foregroundColor: Colors.black,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(ErrandType type) {
    String label;
    IconData icon;
    switch (type) {
      case ErrandType.buyItems:
        label = 'Flow A: Buy Items';
        icon = Icons.shopping_basket_outlined;
        break;
      case ErrandType.pickupPackage:
        label = 'Flow B: Package Pickup';
        icon = Icons.inventory_2_outlined;
        break;
      case ErrandType.otherErrand:
        label = 'Flow C: Other Errand';
        icon = Icons.assignment_outlined;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A3423),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: GVColors.brandGreen),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: GVColors.brandGreen),
          const SizedBox(width: 4),
          Text(
            label,
            style: GVTypography.caption.copyWith(
              color: GVColors.brandGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(ErrandStatus status) {
    Color color;
    switch (status) {
      case ErrandStatus.completed:
        color = GVColors.brandGreen;
        break;
      case ErrandStatus.shoppingInProgress:
      case ErrandStatus.outForDelivery:
      case ErrandStatus.inProgress:
        color = Colors.amber;
        break;
      case ErrandStatus.issueReported:
        color = Colors.redAccent;
        break;
      default:
        color = Colors.white70;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status.label,
        style: GVTypography.caption.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _financialStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GVTypography.caption.copyWith(color: Colors.white60),
        ),
        Text(
          value,
          style: GVTypography.bodySmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
