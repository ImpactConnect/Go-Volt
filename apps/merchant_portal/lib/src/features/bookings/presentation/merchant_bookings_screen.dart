import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/merchant_bookings_notifier.dart';
import 'widgets/delivery_detail_drawer.dart';

class MerchantBookingsScreen extends ConsumerWidget {
  const MerchantBookingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(merchantBookingsNotifierProvider);
    final notifier = ref.read(merchantBookingsNotifierProvider.notifier);
    final filtered = state.filteredBookings;

    final statusTabs = [
      'ALL',
      'in_progress',
      'searching_rider',
      'completed',
      'cancelled',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0C120F),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(GVSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header Bar
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Delivery Bookings & Live Dispatch',
                            style: GVTypography.h1.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Monitor active parcel deliveries, track electric moped riders, and inspect recipient OTPs',
                            style: GVTypography.bodyMedium.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: GVSpacing.md),
                    ElevatedButton.icon(
                      key: const Key('merchant_create_delivery_btn'),
                      onPressed: () => context.go('/create-delivery'),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('Dispatch New Delivery'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GVColors.brandGreen,
                        foregroundColor: GVColors.nearBlack,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: GVSpacing.lg),

                // Action Banner
                if (state.actionMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(GVSpacing.md),
                    margin: const EdgeInsets.only(bottom: GVSpacing.md),
                    decoration: BoxDecoration(
                      color: const Color(0xFF143021),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: GVColors.brandGreen),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_outline, color: GVColors.brandGreen, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.actionMessage!,
                            style: GVTypography.bodySmall.copyWith(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Search & Filter Card
                Container(
                  padding: const EdgeInsets.all(GVSpacing.md),
                  decoration: BoxDecoration(
                    color: const Color(0xFF141C18),
                    borderRadius: BorderRadius.circular(GVBorderRadius.md),
                    border: Border.all(color: const Color(0xFF223028)),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              key: const Key('merchant_booking_search'),
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Search by tracking reference, recipient, rider, or address...',
                                prefixIcon: const Icon(Icons.search, color: Colors.white60),
                                fillColor: const Color(0xFF1A2620),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                              onChanged: notifier.setSearchQuery,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: GVSpacing.sm),

                      // Status Tabs Row
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: statusTabs.map((s) {
                            final isSelected = state.selectedStatusFilter == s;
                            final label = s == 'ALL'
                                ? 'All Statuses'
                                : s.replaceAll('_', ' ').toUpperCase();

                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: ChoiceChip(
                                label: Text(label),
                                selected: isSelected,
                                selectedColor: GVColors.brandGreen,
                                backgroundColor: const Color(0xFF1A2620),
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.black : Colors.white70,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  fontSize: 12,
                                ),
                                onSelected: (_) => notifier.setStatusFilter(s),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: GVSpacing.lg),

                // Deliveries Data Table Card
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF141C18),
                    borderRadius: BorderRadius.circular(GVBorderRadius.md),
                    border: Border.all(color: const Color(0xFF223028)),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('Tracking Ref')),
                        DataColumn(label: Text('Branch')),
                        DataColumn(label: Text('Recipient')),
                        DataColumn(label: Text('Destination')),
                        DataColumn(label: Text('Package')),
                        DataColumn(label: Text('Status')),
                        DataColumn(label: Text('Rider / Battery')),
                        DataColumn(label: Text('Fare')),
                        DataColumn(label: Text('Action')),
                      ],
                      rows: filtered.map((b) {
                        return DataRow(
                          cells: [
                            DataCell(
                              Text(
                                b.trackingReference,
                                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                            DataCell(Text(b.branchName)),
                            DataCell(
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(b.recipientName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  Text(b.recipientPhone, style: GVTypography.caption.copyWith(color: Colors.white54)),
                                ],
                              ),
                            ),
                            DataCell(Text('${b.deliveryAddress}\n(${b.deliveryZone})')),
                            DataCell(Text('${b.packageCategory}\n${b.weightKg} kg')),
                            DataCell(
                              GVStatusChip(
                                label: b.status.name.replaceAll('_', ' ').toUpperCase(),
                                status: b.status == BookingStatus.completed
                                    ? GVStatusType.completed
                                    : (b.status == BookingStatus.inProgress
                                        ? GVStatusType.active
                                        : (b.status == BookingStatus.cancelled
                                            ? GVStatusType.cancelled
                                            : GVStatusType.pending)),
                              ),
                            ),
                            DataCell(
                              b.assignedRiderName != null
                                  ? Row(
                                      children: [
                                        const Icon(Icons.battery_charging_full, size: 14, color: GVColors.brandGreen),
                                        const SizedBox(width: 4),
                                        Text('${b.assignedRiderName!}\n(${b.assignedRiderBattery}%)'),
                                      ],
                                    )
                                  : const Text('Searching...', style: TextStyle(color: Colors.amber)),
                            ),
                            DataCell(
                              Text(
                                b.formattedFare,
                                style: const TextStyle(color: GVColors.brandGreen, fontWeight: FontWeight.bold),
                              ),
                            ),
                            DataCell(
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1D2A22),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                ),
                                onPressed: () => notifier.selectBooking(b),
                                child: const Text('Inspect'),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Slide-out Drawer
          if (state.selectedBooking != null)
            Positioned(
              top: 0,
              right: 0,
              bottom: 0,
              child: DeliveryDetailDrawer(
                booking: state.selectedBooking!,
                onClose: () => notifier.selectBooking(null),
              ),
            ),
        ],
      ),
    );
  }
}
