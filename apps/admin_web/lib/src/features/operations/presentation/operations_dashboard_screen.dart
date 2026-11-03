import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/admin_kpi_card.dart';
import '../../../core/widgets/admin_modal_dialog.dart';
import '../application/operations_notifier.dart';
import '../domain/operations_state.dart';

class OperationsDashboardScreen extends ConsumerWidget {
  const OperationsDashboardScreen({super.key});

  void _showAssignDialog(
    BuildContext context,
    OperationsNotifier notifier,
    UnassignedJobAlert job,
    List<OnlineRiderTelemetry> availableRiders,
  ) {
    String selectedRiderId = availableRiders.first.id;
    final reasonController = TextEditingController(text: 'Nearest idle rider with optimal battery SoC');

    showDialog<void>(
      context: context,
      builder: (dCtx) {
        return StatefulBuilder(
          builder: (modalCtx, setModalState) {
            return AdminModalDialog(
              title: 'Manual Dispatch Assignment',
              subtitle: 'Assign job ${job.reference} to an active EV rider',
              confirmLabel: 'Confirm Assignment',
              onConfirm: () async {
                final success = await notifier.assignRiderToJob(
                  bookingId: job.bookingId,
                  riderId: selectedRiderId,
                  reason: reasonController.text,
                );
                if (modalCtx.mounted && success) {
                  Navigator.of(modalCtx).pop();
                }
              },
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(GVSpacing.sm),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C2420),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${job.serviceType.label} · ₦${job.fareNaira.toStringAsFixed(0)}',
                          style: GVTypography.bodyMedium.copyWith(
                            color: GVColors.brandGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Pickup: ${job.pickupAddress}',
                          style: GVTypography.caption.copyWith(color: Colors.white70),
                        ),
                        Text(
                          'Dropoff: ${job.dropoffAddress}',
                          style: GVTypography.caption.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: GVSpacing.md),
                  Text(
                    'Select Candidate Rider *',
                    style: GVTypography.caption.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1C2420),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF2E3E34)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedRiderId,
                        dropdownColor: const Color(0xFF1C2420),
                        isExpanded: true,
                        style: const TextStyle(color: Colors.white),
                        items: availableRiders.map((r) {
                          return DropdownMenuItem<String>(
                            value: r.id,
                            child: Text(
                              '${r.fullName} (${r.vehiclePlate} · ${r.batteryPercent}% Batt)',
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          if (val != null) {
                            setModalState(() => selectedRiderId = val);
                          }
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: GVSpacing.md),
                  Text(
                    'Mandatory Audit Justification *',
                    style: GVTypography.caption.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: reasonController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Enter reason for manual override...',
                    ),
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
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(operationsNotifierProvider);
    final notifier = ref.read(operationsNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: const Color(0xFF0C120F),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(GVSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Page Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Live Fleet Operations',
                        style: GVTypography.h1.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Real-time fleet presence, unassigned booking escalations, and telematics in ${state.activeZone}',
                        style: GVTypography.bodyMedium.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                if (state.surgeMultiplier > 1.0) ...[
                  const SizedBox(width: GVSpacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF14241B),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: GVColors.brandGreen),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.bolt, color: GVColors.brandGreen, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${state.surgeMultiplier}x Active Surge',
                          style: GVTypography.caption.copyWith(
                            color: GVColors.brandGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: GVSpacing.lg),

            // Action Alert Banner
            if (state.lastActionMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(GVSpacing.md),
                margin: const EdgeInsets.only(bottom: GVSpacing.lg),
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
                        state.lastActionMessage!,
                        style: GVTypography.bodySmall.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // KPI Metrics Grid
            LayoutBuilder(
              builder: (ctx, constraints) {
                final isWide = constraints.maxWidth > 900;
                return GridView.count(
                  crossAxisCount: isWide ? 4 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: GVSpacing.md,
                  mainAxisSpacing: GVSpacing.md,
                  childAspectRatio: isWide ? 1.8 : 1.4,
                  children: [
                    AdminKpiCard(
                      title: 'Active Trips',
                      value: '${state.activeTripsCount}',
                      icon: Icons.electric_moped,
                      subtitle: state.activeTripsCount > 0 ? '${state.activeTripsCount} trips in transit' : 'No active trips',
                      isPositive: state.activeTripsCount > 0,
                    ),
                    AdminKpiCard(
                      title: 'Online Fleet',
                      value: '${state.onlineRidersCount}',
                      icon: Icons.battery_charging_full,
                      subtitle: state.onlineRidersCount > 0 ? '${state.onlineRidersCount} riders transmitting' : 'No online riders',
                      isPositive: state.onlineRidersCount > 0,
                    ),
                    AdminKpiCard(
                      title: 'Unassigned Queue',
                      value: '${state.urgentJobs.length}',
                      icon: Icons.assignment_late_outlined,
                      subtitle: state.urgentJobs.isNotEmpty ? '${state.urgentJobs.length} jobs awaiting dispatch' : 'Queue cleared',
                      iconColor: state.urgentJobs.isNotEmpty ? Colors.amber : GVColors.brandGreen,
                      badgeLabel: state.urgentJobs.isNotEmpty ? 'Escalation' : null,
                    ),
                    AdminKpiCard(
                      title: 'Overdue Pickups',
                      value: '${state.overduePickupsCount}',
                      icon: Icons.warning_amber_rounded,
                      subtitle: state.overduePickupsCount > 0 ? '${state.overduePickupsCount} overdue pickups' : 'All pickups on-time',
                      isPositive: state.overduePickupsCount == 0,
                      iconColor: state.overduePickupsCount > 0 ? Colors.redAccent : GVColors.brandGreen,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: GVSpacing.xl),

            // Two-column layout: Fleet Telemetry & Work Queue
            LayoutBuilder(
              builder: (ctx, constraints) {
                final isWide = constraints.maxWidth > 1000;
                return Flex(
                  direction: isWide ? Axis.horizontal : Axis.vertical,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Live Riders Table
                    Expanded(
                      flex: isWide ? 3 : 0,
                      child: Container(
                        padding: const EdgeInsets.all(GVSpacing.md),
                        decoration: BoxDecoration(
                          color: const Color(0xFF141C18),
                          borderRadius: BorderRadius.circular(GVBorderRadius.md),
                          border: Border.all(color: const Color(0xFF223028)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Online Fleet Telemetry',
                                  style: GVTypography.h3.copyWith(color: Colors.white),
                                ),
                                Text(
                                  '${state.onlineRiders.length} Riders Active',
                                  style: GVTypography.caption.copyWith(color: GVColors.brandGreen),
                                ),
                              ],
                            ),
                            const Divider(color: Color(0xFF25332C), height: GVSpacing.md),
                            if (state.onlineRiders.isEmpty) ...[
                              const Padding(
                                padding: EdgeInsets.all(32),
                                child: Center(
                                  child: Text(
                                    'No riders currently online or transmitting telemetry.',
                                    style: TextStyle(color: Colors.white54),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ] else ...[
                              SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: DataTable(
                                columns: const [
                                  DataColumn(label: Text('Rider Name')),
                                  DataColumn(label: Text('Vehicle & Plate')),
                                  DataColumn(label: Text('Battery SoC')),
                                  DataColumn(label: Text('Zone')),
                                  DataColumn(label: Text('Heartbeat')),
                                  DataColumn(label: Text('Status')),
                                ],
                                rows: state.onlineRiders.map((r) {
                                  return DataRow(
                                    cells: [
                                      DataCell(
                                        Row(
                                          children: [
                                            const CircleAvatar(
                                              radius: 12,
                                              backgroundColor: GVColors.deepGreen,
                                              child: Icon(Icons.person, size: 14, color: Colors.white),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              r.fullName,
                                              style: const TextStyle(fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ),
                                      DataCell(Text('${r.vehicleModel} (${r.vehiclePlate})')),
                                      DataCell(
                                        Row(
                                          children: [
                                            Icon(
                                              r.isBatteryCritical
                                                  ? Icons.battery_alert
                                                  : Icons.battery_charging_full,
                                              color: r.isBatteryCritical
                                                  ? Colors.redAccent
                                                  : GVColors.brandGreen,
                                              size: 16,
                                            ),
                                            const SizedBox(width: 4),
                                            Text(
                                              '${r.batteryPercent}%',
                                              style: TextStyle(
                                                color: r.isBatteryCritical ? Colors.redAccent : Colors.white,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      DataCell(Text(r.currentZone)),
                                      DataCell(Text('${r.lastHeartbeatSecondsAgo}s ago')),
                                      DataCell(
                                        GVStatusChip(
                                          label: r.status.toUpperCase(),
                                          status: r.status == 'idle'
                                              ? GVStatusType.active
                                              : (r.status == 'low_battery'
                                                  ? GVStatusType.delayed
                                                  : GVStatusType.assigned),
                                        ),
                                      ),
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ],
                        ),
                      ),
                    ),
                    if (isWide) const SizedBox(width: GVSpacing.lg) else const SizedBox(height: GVSpacing.lg),

                    // Right Column: Urgent Work Queue
                    Expanded(
                      flex: isWide ? 2 : 0,
                      child: Container(
                        padding: const EdgeInsets.all(GVSpacing.md),
                        decoration: BoxDecoration(
                          color: const Color(0xFF141C18),
                          borderRadius: BorderRadius.circular(GVBorderRadius.md),
                          border: Border.all(color: const Color(0xFF223028)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Urgent Dispatch Queue',
                                    style: GVTypography.h3.copyWith(color: Colors.white),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: state.urgentJobs.isNotEmpty
                                        ? Colors.redAccent.withValues(alpha: 0.2)
                                        : GVColors.brandGreen.withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    state.urgentJobs.isNotEmpty
                                        ? '${state.urgentJobs.length} PENDING'
                                        : 'CLEARED',
                                    style: TextStyle(
                                      color: state.urgentJobs.isNotEmpty
                                          ? Colors.redAccent
                                          : GVColors.brandGreen,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: Color(0xFF25332C), height: GVSpacing.md),
                            if (state.urgentJobs.isEmpty) ...[
                              const Padding(
                                padding: EdgeInsets.all(32),
                                child: Center(
                                  child: Text(
                                    'All dispatch offers currently matched and serviced.',
                                    style: TextStyle(color: Colors.white54),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ] else ...[
                              ...state.urgentJobs.map((job) {
                                return Container(
                                  margin: const EdgeInsets.only(bottom: GVSpacing.sm),
                                  padding: const EdgeInsets.all(GVSpacing.sm),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1A241F),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: job.isOverdue
                                          ? Colors.redAccent.withValues(alpha: 0.6)
                                          : const Color(0xFF2B3A32),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            job.reference,
                                            style: GVTypography.bodySmall.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          if (job.isOverdue) ...[
                                            const Text(
                                              'OVERDUE',
                                              style: TextStyle(
                                                color: Colors.redAccent,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Customer: ${job.customerName} · ₦${job.fareNaira.toStringAsFixed(0)}',
                                        style: GVTypography.caption.copyWith(color: GVColors.brandGreen),
                                      ),
                                      Text(
                                        'Pickup: ${job.pickupAddress}',
                                        style: GVTypography.caption.copyWith(color: Colors.white70),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Waiting: ${job.minutesWaiting} mins',
                                            style: GVTypography.caption.copyWith(color: Colors.white54),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: GVColors.brandGreen,
                                              foregroundColor: GVColors.nearBlack,
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              minimumSize: Size.zero,
                                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                            ),
                                            onPressed: () {
                                              _showAssignDialog(
                                                context,
                                                notifier,
                                                job,
                                                state.onlineRiders.where((r) => r.status == 'idle').toList(),
                                              );
                                            },
                                            child: const Text('Assign Rider'),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              }),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
