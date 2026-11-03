import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/admin_kpi_card.dart';
import '../application/safety_sos_notifier.dart';
import '../domain/safety_sos_models.dart';
import 'widgets/sos_dispatch_modal.dart';

class SafetySosScreen extends ConsumerWidget {
  const SafetySosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(safetySosNotifierProvider);
    final notifier = ref.read(safetySosNotifierProvider.notifier);
    final filtered = state.filteredAlerts;

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
                      Row(
                        children: [
                          const Icon(Icons.emergency, color: Colors.redAccent, size: 28),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Emergency SOS Rapid Dispatch Desk',
                              style: GVTypography.h1.copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Live GPS tracking, real-time distress alarms, 112 emergency service dispatch, and mobile EV patrol coordination (§5.3)',
                        style: GVTypography.bodyMedium.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: state.activeDistressCount > 0
                        ? const Color(0xFF3B1212)
                        : const Color(0xFF14241B),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: state.activeDistressCount > 0
                          ? Colors.redAccent
                          : const Color(0xFF263C2E),
                    ),
                  ),
                  child: Text(
                    '${state.activeDistressCount} Active Distress Alert${state.activeDistressCount == 1 ? '' : 's'}',
                    style: GVTypography.caption.copyWith(
                      color: state.activeDistressCount > 0
                          ? Colors.redAccent
                          : GVColors.brandGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: GVSpacing.lg),

            // Flashing Red Banner if Active Distress exists
            if (state.activeDistressCount > 0) ...[
              Container(
                padding: const EdgeInsets.all(GVSpacing.md),
                margin: const EdgeInsets.only(bottom: GVSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B1212),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.redAccent, width: 1.5),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.redAccent, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HIGH PRIORITY: ACTIVE PASSENGER DISTRESS TRIGGER DETECTED',
                            style: GVTypography.caption.copyWith(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'An emergency beacon is transmitting live GPS telemetry and audio stream. Immediate safety officer response required.',
                            style: GVTypography.bodySmall.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],

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
                    const Icon(Icons.check_circle_outline,
                        color: GVColors.brandGreen, size: 20),
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

            // 4 High-Contrast KPI Cards
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;
                return Wrap(
                  spacing: GVSpacing.md,
                  runSpacing: GVSpacing.md,
                  children: [
                    SizedBox(
                      width: isWide ? (constraints.maxWidth - 48) / 4 : constraints.maxWidth,
                      child: AdminKpiCard(
                        title: 'Active SOS Distress',
                        value: state.activeDistressCount.toString(),
                        subtitle: 'Live alarms awaiting dispatch',
                        icon: Icons.emergency_outlined,
                        badgeLabel: state.activeDistressCount > 0 ? 'CRITICAL' : null,
                        accentColor: state.activeDistressCount > 0 ? Colors.redAccent : null,
                      ),
                    ),
                    SizedBox(
                      width: isWide ? (constraints.maxWidth - 48) / 4 : constraints.maxWidth,
                      child: AdminKpiCard(
                        title: 'Patrol En Route',
                        value: state.patrolEnRouteCount.toString(),
                        subtitle: 'Go-Volts rapid EV mobile units',
                        icon: Icons.security_outlined,
                        badgeLabel: state.patrolEnRouteCount > 0 ? 'EN ROUTE' : null,
                        accentColor: state.patrolEnRouteCount > 0 ? Colors.amber : null,
                      ),
                    ),
                    SizedBox(
                      width: isWide ? (constraints.maxWidth - 48) / 4 : constraints.maxWidth,
                      child: AdminKpiCard(
                        title: 'Escalated to 112/Police',
                        value: state.dispatched112Count.toString(),
                        subtitle: 'Civil emergency commands active',
                        icon: Icons.local_police_outlined,
                        accentColor: Colors.blueAccent,
                      ),
                    ),
                    SizedBox(
                      width: isWide ? (constraints.maxWidth - 48) / 4 : constraints.maxWidth,
                      child: AdminKpiCard(
                        title: 'Resolved Today',
                        value: state.resolvedCount.toString(),
                        subtitle: 'Confirmed safe arrival & closed',
                        icon: Icons.check_circle_outline,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: GVSpacing.lg),

            // Search & Filter Card
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFF161F1A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF263C2E)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    onChanged: notifier.search,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search by SOS Incident Ref (e.g. SOS-2026), booking ref, victim, driver, or address...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.search, color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF14241B),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF263C2E)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Alert Status:',
                        style: GVTypography.caption.copyWith(
                          color: Colors.white60,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _filterChip('All Alerts', state.selectedStatus == null, () => notifier.filterByStatus(null)),
                      _filterChip('Active Distress', state.selectedStatus == SosAlertStatus.activeDistress, () => notifier.filterByStatus(SosAlertStatus.activeDistress)),
                      _filterChip('112 / Police Dispatched', state.selectedStatus == SosAlertStatus.dispatchedAuthorities, () => notifier.filterByStatus(SosAlertStatus.dispatchedAuthorities)),
                      _filterChip('Patrol En Route', state.selectedStatus == SosAlertStatus.patrolEnRoute, () => notifier.filterByStatus(SosAlertStatus.patrolEnRoute)),
                      _filterChip('Resolved Safe', state.selectedStatus == SosAlertStatus.resolvedSafe, () => notifier.filterByStatus(SosAlertStatus.resolvedSafe)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.lg),

            // Alerts Table
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF161F1A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF263C2E)),
              ),
              child: filtered.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(GVSpacing.xxl),
                      child: Center(
                        child: Text(
                          'No SOS distress incidents found matching current filters.',
                          style: GVTypography.bodyMedium.copyWith(color: Colors.white60),
                        ),
                      ),
                    )
                  : Table(
                      columnWidths: const {
                        0: FlexColumnWidth(2.2), // Ref & Time
                        1: FlexColumnWidth(2.0), // Victim & Contact
                        2: FlexColumnWidth(2.4), // Location & Telemetry
                        3: FlexColumnWidth(2.0), // Service & Driver
                        4: FlexColumnWidth(2.0), // Status
                        5: FlexColumnWidth(1.6), // Action
                      },
                      children: [
                        TableRow(
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0xFF263C2E))),
                            color: Color(0xFF14241B),
                          ),
                          children: [
                            _headerCell('INCIDENT REF & TIME'),
                            _headerCell('VICTIM / INITIATOR'),
                            _headerCell('LIVE LOCATION & SPEED'),
                            _headerCell('SERVICE & DRIVER'),
                            _headerCell('STATUS'),
                            _headerCell('DISPATCH DESK'),
                          ],
                        ),
                        ...filtered.map((alert) => TableRow(
                              decoration: BoxDecoration(
                                color: alert.status == SosAlertStatus.activeDistress
                                    ? const Color(0xFF231414)
                                    : Colors.transparent,
                                border: const Border(bottom: BorderSide(color: Color(0xFF263C2E))),
                              ),
                              children: [
                                // Ref & Time
                                _dataCell(
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        alert.incidentRef,
                                        style: GVTypography.bodySmall.copyWith(
                                          color: alert.status == SosAlertStatus.activeDistress
                                              ? Colors.redAccent
                                              : Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        'Ref: ${alert.bookingRef}',
                                        style: GVTypography.caption.copyWith(color: Colors.white60, fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                // Victim
                                _dataCell(
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        alert.victimName,
                                        style: GVTypography.bodySmall.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        alert.victimPhone,
                                        style: GVTypography.caption.copyWith(
                                          color: GVColors.brandGreen,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Location & Telemetry
                                _dataCell(
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        alert.location.address,
                                        style: GVTypography.caption.copyWith(color: Colors.white),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        '${alert.speedKmH.toStringAsFixed(0)} km/h • ${alert.evBatteryPercent}% SoC',
                                        style: GVTypography.caption.copyWith(
                                          color: alert.speedKmH > 80 ? Colors.redAccent : Colors.white60,
                                          fontSize: 10,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Service & Driver
                                _dataCell(
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        alert.serviceType,
                                        style: GVTypography.bodySmall.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        alert.driverName ?? 'Unassigned',
                                        style: GVTypography.caption.copyWith(
                                          color: Colors.white60,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Status
                                _dataCell(
                                  _statusBadge(alert.status),
                                ),
                                // Action
                                _dataCell(
                                  ElevatedButton(
                                    key: Key('open_sos_${alert.id}'),
                                    onPressed: () {
                                      showDialog<void>(
                                        context: context,
                                        builder: (_) => SosDispatchModal(alert: alert),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: alert.status == SosAlertStatus.activeDistress
                                          ? Colors.redAccent
                                          : const Color(0xFF263C2E),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    ),
                                    child: Text(
                                      alert.isActive ? 'DISPATCH' : 'INSPECT',
                                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            )),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterChip(String label, bool isSelected, VoidCallback onSelected) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: const Color(0xFF143021),
      backgroundColor: const Color(0xFF14241B),
      labelStyle: TextStyle(
        color: isSelected ? GVColors.brandGreen : Colors.white70,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      side: BorderSide(
        color: isSelected ? GVColors.brandGreen : const Color(0xFF263C2E),
      ),
    );
  }

  Widget _statusBadge(SosAlertStatus status) {
    Color color;
    switch (status) {
      case SosAlertStatus.activeDistress:
        color = Colors.redAccent;
        break;
      case SosAlertStatus.dispatchedAuthorities:
        color = Colors.blueAccent;
        break;
      case SosAlertStatus.patrolEnRoute:
        color = Colors.amber;
        break;
      case SosAlertStatus.resolvedSafe:
        color = GVColors.brandGreen;
        break;
      case SosAlertStatus.falseAlarm:
        color = Colors.white60;
        break;
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
        style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _headerCell(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Text(
        title,
        style: GVTypography.caption.copyWith(color: Colors.white70, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _dataCell(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: child,
    );
  }
}
