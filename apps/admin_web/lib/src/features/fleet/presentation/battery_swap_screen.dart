import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/admin_kpi_card.dart';
import '../application/battery_swap_notifier.dart';
import '../domain/battery_swap_models.dart';
import 'widgets/battery_bay_inspect_modal.dart';

class BatterySwapScreen extends ConsumerWidget {
  const BatterySwapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(batterySwapNotifierProvider);
    final notifier = ref.read(batterySwapNotifierProvider.notifier);
    final filtered = state.filteredStations;

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
                          const Icon(Icons.ev_station,
                              color: GVColors.brandGreen, size: 28),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'EV Battery Swap & Telematics Station Desk',
                              style: GVTypography.h1.copyWith(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Live IoT telematics, cabinet bay diagnostics, thermal runaway quarantine controls, and solar grid balancing (§5.4)',
                        style: GVTypography.bodyMedium
                            .copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14241B),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF263C2E)),
                  ),
                  child: Text(
                    '${state.totalStationsCount} Active Swap Hubs in Lagos',
                    style: GVTypography.caption.copyWith(
                      color: GVColors.brandGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: GVSpacing.lg),

            // 4 KPI Cards
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth >= 900;
                final cards = [
                  AdminKpiCard(
                    title: 'ACTIVE SWAP HUBS',
                    value: '${state.totalStationsCount}',
                    subtitle: state.totalStationsCount > 0
                        ? 'Lagos Island & Mainland grid'
                        : 'No stations connected',
                    badgeLabel: state.totalStationsCount > 0
                        ? 'Solar & Grid Active'
                        : null,
                    accentColor: GVColors.brandGreen,
                    icon: Icons.ev_station,
                  ),
                  AdminKpiCard(
                    title: 'CHARGED PACKS (SoC ≥ 90%)',
                    value: '${state.totalChargedPacks}',
                    subtitle: state.totalChargedPacks > 0
                        ? 'Ready for instant automated swap'
                        : 'No charged packs in hubs',
                    badgeLabel: state.totalChargedPacks > 0
                        ? 'High Availability'
                        : null,
                    accentColor: GVColors.brandGreen,
                    icon: Icons.battery_charging_full,
                  ),
                  AdminKpiCard(
                    title: 'ACTIVE CHARGING PACKS',
                    value: '${state.totalChargingPacks}',
                    subtitle: state.totalChargingPacks > 0
                        ? 'Fast DC multi-bay charging'
                        : 'No active packs charging',
                    badgeLabel: state.totalChargingPacks > 0
                        ? 'Optimized Off-Peak'
                        : null,
                    accentColor: Colors.lightBlueAccent,
                    icon: Icons.bolt,
                  ),
                  AdminKpiCard(
                    title: 'QUARANTINED / DEGRADED',
                    value: '${state.totalQuarantinedPacks}',
                    subtitle: state.totalQuarantinedPacks > 0
                        ? 'Thermal runaway & BMS safety locks'
                        : 'All batteries operating normally',
                    badgeLabel: state.totalQuarantinedPacks > 0
                        ? '${state.totalQuarantinedPacks} ISOLATED'
                        : 'Zero Hazards',
                    accentColor: state.totalQuarantinedPacks > 0
                        ? Colors.redAccent
                        : GVColors.brandGreen,
                    icon: Icons.gpp_bad,
                  ),
                ];

                if (isWide) {
                  return Row(
                    children: cards
                        .map((c) => Expanded(
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                child: c,
                              ),
                            ))
                        .toList(),
                  );
                } else {
                  return Column(
                    children: cards
                        .map((c) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: c,
                            ))
                        .toList(),
                  );
                }
              },
            ),
            const SizedBox(height: GVSpacing.lg),

            // Action message feedback banner if present
            if (state.actionMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(GVSpacing.md),
                margin: const EdgeInsets.only(bottom: GVSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xFF14241B),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: GVColors.brandGreen),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline,
                        color: GVColors.brandGreen, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        state.actionMessage!,
                        style: GVTypography.caption.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close,
                          size: 16, color: Colors.white60),
                      onPressed: () {
                        notifier.filterByStatus(state.selectedStatus);
                      },
                    ),
                  ],
                ),
              ),
            ],

            // Filter & Search Toolbar
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFF141D18),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF263C2E)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style:
                          const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search swap station by name or street address...',
                        hintStyle: TextStyle(
                            color: Colors.white.withValues(alpha: 0.4),
                            fontSize: 13),
                        prefixIcon: const Icon(Icons.search,
                            color: Colors.white60, size: 20),
                        filled: true,
                        fillColor: const Color(0xFF0C120F),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide:
                              const BorderSide(color: Color(0xFF263C2E)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide:
                              const BorderSide(color: Color(0xFF263C2E)),
                        ),
                      ),
                      onChanged: notifier.search,
                    ),
                  ),
                  const SizedBox(width: 16),
                  _buildStatusChip(
                    label: 'All Stations (${state.stations.length})',
                    isSelected: state.selectedStatus == null,
                    onTap: () => notifier.filterByStatus(null),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(
                    label: 'Operational',
                    isSelected: state.selectedStatus == 'OPERATIONAL',
                    onTap: () => notifier.filterByStatus('OPERATIONAL'),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(
                    label: 'High Demand',
                    isSelected: state.selectedStatus == 'HIGH_DEMAND',
                    onTap: () => notifier.filterByStatus('HIGH_DEMAND'),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusChip(
                    label: 'Maintenance',
                    isSelected: state.selectedStatus == 'MAINTENANCE',
                    onTap: () => notifier.filterByStatus('MAINTENANCE'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.md),

            // Stations Data Table / Cards
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF141D18),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF263C2E)),
              ),
              child: filtered.isEmpty
                  ? Container(
                      padding: const EdgeInsets.all(40),
                      alignment: Alignment.center,
                      child: Text(
                        'No battery swap stations matching your search.',
                        style: GVTypography.bodyMedium
                            .copyWith(color: Colors.white54),
                      ),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filtered.length,
                      separatorBuilder: (context, index) =>
                          const Divider(color: Color(0xFF263C2E), height: 1),
                      itemBuilder: (context, index) {
                        final station = filtered[index];
                        return _buildStationRow(context, ref, station);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStationRow(
    BuildContext context,
    WidgetRef ref,
    BatterySwapStationModel station,
  ) {
    Color statusBadgeColor;
    if (station.status == 'OPERATIONAL') {
      statusBadgeColor = GVColors.brandGreen;
    } else if (station.status == 'HIGH_DEMAND') {
      statusBadgeColor = Colors.blueAccent;
    } else {
      statusBadgeColor = const Color(0xFFFFB300);
    }

    return Padding(
      padding: const EdgeInsets.all(GVSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Station Identity
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF1C2720),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF263C2E)),
            ),
            child: const Icon(Icons.ev_station,
                color: GVColors.brandGreen, size: 24),
          ),
          const SizedBox(width: 14),

          // Station Name & Address
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(
                      station.name,
                      style: GVTypography.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusBadgeColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: statusBadgeColor.withValues(alpha: 0.5)),
                      ),
                      child: Text(
                        station.status,
                        style: TextStyle(
                          color: statusBadgeColor,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  station.address,
                  style: GVTypography.caption.copyWith(color: Colors.white60),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 12,
                  runSpacing: 4,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.solar_power, size: 14, color: Colors.white54),
                        const SizedBox(width: 4),
                        Text(
                          station.powerSource,
                          style: const TextStyle(color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.thermostat,
                            size: 14,
                            color: station.temperatureCelsius > 32
                                ? const Color(0xFFFFB300)
                                : Colors.white54),
                        const SizedBox(width: 4),
                        Text(
                          '${station.temperatureCelsius}°C Ambient',
                          style: TextStyle(
                            color: station.temperatureCelsius > 32
                                ? const Color(0xFFFFB300)
                                : Colors.white54,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Telematics Bay Breakdown
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF0C120F),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFF263C2E)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          'CABINET (${station.totalCabinetBays} BAYS)',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.6),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${station.dailySwapCount} swaps today',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      _buildInventoryTag(
                        label: 'Ready',
                        count: station.chargedPacksAvailable,
                        color: GVColors.brandGreen,
                      ),
                      _buildInventoryTag(
                        label: 'Charging',
                        count: station.chargingPacks,
                        color: Colors.lightBlueAccent,
                      ),
                      _buildInventoryTag(
                        label: 'Quarantined',
                        count: station.quarantinedPacks,
                        color: station.quarantinedPacks > 0
                            ? Colors.redAccent
                            : Colors.white38,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Action Button: Inspect 24-Bay Cabinet
          ElevatedButton.icon(
            onPressed: () {
              showDialog<void>(
                context: context,
                builder: (context) =>
                    BatteryBayInspectModal(stationId: station.id),
              );
            },
            icon: const Icon(Icons.grid_view, size: 16),
            label: const Text('Inspect 24-Bay Cabinet'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E2822),
              foregroundColor: GVColors.brandGreen,
              side: const BorderSide(color: GVColors.brandGreen),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryTag({
    required String label,
    required int count,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            '$count $label',
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? GVColors.brandGreen : const Color(0xFF0C120F),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected ? GVColors.brandGreen : const Color(0xFF263C2E),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white70,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
