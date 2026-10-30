import 'package:app_models/app_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:design_system/design_system.dart';
import '../../../core/auth/merchant_auth_notifier.dart';
import '../../../core/widgets/merchant_kpi_card.dart';
import '../../bookings/application/merchant_bookings_notifier.dart';
import '../../bookings/presentation/widgets/delivery_detail_drawer.dart';

class MerchantDashboardScreen extends ConsumerWidget {
  const MerchantDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(merchantAuthNotifierProvider);
    final bookingsState = ref.watch(merchantBookingsNotifierProvider);
    final bookingsNotifier = ref.read(merchantBookingsNotifierProvider.notifier);

    final recentBookings = bookingsState.bookings.take(6).toList();

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 650;
                  final titleCol = Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Dispatch Command Center',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: GVColors.neutral100,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Active Hub: ${authState.activeBranchName} • 100% Zero-Emission Electric Moped Fleet',
                        style: const TextStyle(
                          color: GVColors.neutral400,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  );

                  final actionBtn = ElevatedButton.icon(
                    onPressed: () => context.go('/create-delivery'),
                    icon: const Icon(Icons.add_rounded, size: 18),
                    label: const Text('New Dispatch'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GVColors.voltGreen,
                      foregroundColor: GVColors.neutral900,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  );

                  return isNarrow
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            titleCol,
                            const SizedBox(height: 12),
                            actionBtn,
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            titleCol,
                            actionBtn,
                          ],
                        );
                },
              ),
              const SizedBox(height: 20),

              // KPI Metrics Row
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final crossAxisCount = width > 1000
                      ? 4
                      : width > 650
                          ? 2
                          : 1;

                  final kpis = [
                    MerchantKpiCard(
                      title: 'Active En-Route',
                      value: '${bookingsState.activeDispatchCount} Orders',
                      subtitle: 'Live electric mopeds in transit',
                      icon: Icons.electric_moped_rounded,
                      iconColor: GVColors.voltGreen,
                    ),
                    MerchantKpiCard(
                      title: 'Delivered Today',
                      value: '${bookingsState.completedTodayCount} Completed',
                      subtitle: 'OTP verified by recipient',
                      icon: Icons.task_alt_rounded,
                      iconColor: GVColors.electricBlue,
                    ),
                    const MerchantKpiCard(
                      title: 'Carbon Offset',
                      value: '48.2 kg CO₂',
                      subtitle: 'Zero tailpipe emissions saved',
                      icon: Icons.eco_rounded,
                      iconColor: GVColors.voltGreen,
                    ),
                    const MerchantKpiCard(
                      title: 'Average Fleet SoC',
                      value: '94% Battery',
                      subtitle: 'Smart battery swap ready',
                      icon: Icons.battery_charging_full_rounded,
                      iconColor: GVColors.deepPurple,
                    ),
                  ];

                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: crossAxisCount == 4
                        ? 1.8
                        : crossAxisCount == 2
                            ? 2.2
                            : 2.8,
                    children: kpis,
                  );
                },
              ),
              const SizedBox(height: 28),

              // Live Dispatches Table Card
              Container(
                decoration: BoxDecoration(
                  color: GVColors.neutral900,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: GVColors.neutral800),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Live Dispatch Stream',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: GVColors.neutral100,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Real-time telemetry, driver assignment & recipient verification',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: GVColors.neutral400,
                                ),
                              ),
                            ],
                          ),
                          TextButton.icon(
                            onPressed: () => context.go('/bookings'),
                            icon: const Icon(
                              Icons.arrow_forward_rounded,
                              size: 14,
                              color: GVColors.voltGreen,
                            ),
                            label: const Text(
                              'View All Orders',
                              style: TextStyle(
                                color: GVColors.voltGreen,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Divider(height: 1, color: GVColors.neutral800),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(
                          GVColors.neutral800.withValues(alpha: 0.5),
                        ),
                        dataRowColor: WidgetStateProperty.resolveWith(
                          (states) => GVColors.neutral900,
                        ),
                        columns: const [
                          DataColumn(
                            label: Text(
                              'TRACKING #',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: GVColors.neutral400,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'RECIPIENT',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: GVColors.neutral400,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'DESTINATION',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: GVColors.neutral400,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'ASSIGNED RIDER',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: GVColors.neutral400,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'BATTERY SOC',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: GVColors.neutral400,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'STATUS',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: GVColors.neutral400,
                              ),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'ACTION',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: GVColors.neutral400,
                              ),
                            ),
                          ),
                        ],
                        rows: recentBookings.map((b) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Text(
                                  b.trackingReference,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: GVColors.voltGreen,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  b.recipientName,
                                  style: const TextStyle(
                                    color: GVColors.neutral200,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              DataCell(
                                ConstrainedBox(
                                  constraints:
                                      const BoxConstraints(maxWidth: 180),
                                  child: Text(
                                    b.deliveryAddress,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: GVColors.neutral300,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                              DataCell(
                                Text(
                                  b.assignedRiderName ?? 'Assigning rider...',
                                  style: TextStyle(
                                    color: b.assignedRiderName != null
                                        ? GVColors.neutral200
                                        : GVColors.neutral500,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                              DataCell(
                                b.assignedRiderBatterySoc != null
                                    ? Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          const Icon(
                                            Icons.battery_charging_full_rounded,
                                            size: 14,
                                            color: GVColors.voltGreen,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            '${b.assignedRiderBatterySoc}%',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color: GVColors.voltGreen,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const Text(
                                        '-',
                                        style: TextStyle(
                                          color: GVColors.neutral500,
                                          fontSize: 12,
                                        ),
                                      ),
                              ),
                              DataCell(
                                _buildStatusBadge(b.status),
                              ),
                              DataCell(
                                TextButton(
                                  onPressed: () =>
                                      bookingsNotifier.selectBooking(b),
                                  style: TextButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    minimumSize: Size.zero,
                                    tapTargetSize:
                                        MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: const Text(
                                    'Inspect',
                                    style: TextStyle(
                                      color: GVColors.voltGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Slide-out Drawer for Selected Booking
        if (bookingsState.selectedBooking != null)
          Positioned.fill(
            child: Stack(
              children: [
                GestureDetector(
                  onTap: () => bookingsNotifier.clearSelection(),
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.5),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: DeliveryDetailDrawer(
                    booking: bookingsState.selectedBooking!,
                    onClose: () => bookingsNotifier.clearSelection(),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildStatusBadge(BookingStatus status) {
    Color color;
    switch (status) {
      case BookingStatus.completed:
        color = GVColors.voltGreen;
        break;
      case BookingStatus.inProgress:
        color = GVColors.electricBlue;
        break;
      case BookingStatus.searchingRider:
      case BookingStatus.assigned:
        color = GVColors.warningOrange;
        break;
      case BookingStatus.cancelled:
        color = GVColors.errorRed;
        break;
      default:
        color = GVColors.neutral400;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.name.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
