import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/booking_management_notifier.dart';
import 'widgets/booking_detail_modal.dart';

class BookingManagementScreen extends ConsumerWidget {
  const BookingManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(bookingManagementNotifierProvider);
    final notifier = ref.read(bookingManagementNotifierProvider.notifier);
    final filtered = state.filteredBookings;

    final statusFilters = [
      'ALL',
      'assigned',
      'in_progress',
      'searching_rider',
      'completed',
      'cancelled',
    ];

    return Scaffold(
      backgroundColor: const Color(0xFF0C120F),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(GVSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Page Title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Booking & Trip Management',
                        style: GVTypography.h1.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Filter, inspect route waypoints, reassign drivers, and manage booking cancellations',
                        style: GVTypography.bodyMedium.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: GVSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14241B),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF263C2E)),
                  ),
                  child: Text(
                    '${state.bookings.length} Total Bookings',
                    style: GVTypography.caption.copyWith(
                      color: GVColors.brandGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: GVSpacing.lg),

            // Action Feedback Banner
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

            // Filters & Search Bar Card
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
                      // Search field
                      Expanded(
                        child: TextField(
                          key: const Key('booking_search_field'),
                          style: const TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: 'Search by reference, customer, driver, or pickup...',
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
                      const SizedBox(width: GVSpacing.md),
                      // Service Filter Dropdown
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A2620),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xFF2D3E33)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: state.selectedServiceFilter,
                            dropdownColor: const Color(0xFF1A2620),
                            style: const TextStyle(color: Colors.white),
                            items: const [
                              DropdownMenuItem(value: 'ALL', child: Text('All Service Types')),
                              DropdownMenuItem(value: 'parcelDelivery', child: Text('Parcel Delivery')),
                              DropdownMenuItem(value: 'schoolRunCommute', child: Text('School-Run')),
                              DropdownMenuItem(value: 'passengerRide', child: Text('Passenger Ride')),
                            ],
                            onChanged: (val) {
                              if (val != null) notifier.setServiceFilter(val);
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: GVSpacing.sm),
                  // Status Filter Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: statusFilters.map((s) {
                        final isSelected = state.selectedStatusFilter == s;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            selected: isSelected,
                            label: Text(s.toUpperCase().replaceAll('_', ' ')),
                            selectedColor: const Color(0xFF173827),
                            labelStyle: TextStyle(
                              color: isSelected ? GVColors.brandGreen : Colors.white60,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              fontSize: 11,
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

            // Data Table of Bookings
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
                    DataColumn(label: Text('Booking Ref')),
                    DataColumn(label: Text('Service Type')),
                    DataColumn(label: Text('Customer')),
                    DataColumn(label: Text('Assigned Fleet')),
                    DataColumn(label: Text('Pickup / Dropoff')),
                    DataColumn(label: Text('Gross Fare')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: filtered.map((b) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            b.reference,
                            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                          ),
                        ),
                        DataCell(Text(b.serviceType.label)),
                        DataCell(Text('${b.customerName}\n${b.customerPhone}')),
                        DataCell(
                          Text(
                            b.riderName != null ? '${b.riderName}\n${b.riderPlate}' : 'Unassigned',
                            style: TextStyle(color: b.riderName != null ? Colors.white : Colors.amber),
                          ),
                        ),
                        DataCell(
                          SizedBox(
                            width: 220,
                            child: Text(
                              '${b.pickupAddress} ➔ ${b.dropoffAddress}',
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ),
                        DataCell(Text('₦${b.grossFareNaira.toStringAsFixed(0)}')),
                        DataCell(
                          GVStatusChip(
                            label: b.status.name.toUpperCase(),
                            status: b.status == BookingStatus.completed
                                ? GVStatusType.active
                                : (b.status == BookingStatus.cancelled
                                    ? GVStatusType.delayed
                                    : GVStatusType.assigned),
                          ),
                        ),
                        DataCell(
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: GVColors.brandGreen,
                              side: const BorderSide(color: GVColors.brandGreen),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              minimumSize: Size.zero,
                            ),
                            onPressed: () {
                              showDialog<void>(
                                context: context,
                                builder: (_) => BookingDetailModal(
                                  booking: b,
                                  notifier: notifier,
                                ),
                              );
                            },
                            child: const Text('View Details'),
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
    );
  }
}
