import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/admin_kpi_card.dart';
import '../../fleet/application/battery_swap_notifier.dart';

class MerchantsScreen extends ConsumerWidget {
  const MerchantsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fleetState = ref.watch(batterySwapNotifierProvider);
    final stations = fleetState.stations;

    final totalCharged = stations.fold<int>(0, (sum, s) => sum + s.chargedPacksAvailable);
    final totalSwaps = stations.fold<int>(0, (sum, s) => sum + s.dailySwapCount);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(GVSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Merchants & Battery Swap Hubs',
                    style: GVTypography.h2.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Clean energy charging station telemetry, battery swap availability, and retail partners (§5.2)',
                    style: GVTypography.bodySmall.copyWith(color: Colors.white60),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: GVSpacing.lg),

          // KPIs
          Row(
            children: [
              Expanded(
                child: AdminKpiCard(
                  title: 'Active Swap Stations',
                  value: '${stations.length} Hubs',
                  subtitle: stations.isEmpty ? 'No hubs registered' : '100% solar & grid backed',
                  icon: Icons.electric_bolt,
                  accentColor: GVColors.brandGreen,
                ),
              ),
              const SizedBox(width: GVSpacing.md),
              Expanded(
                child: AdminKpiCard(
                  title: 'Charged Battery Inventory',
                  value: '$totalCharged Packs',
                  subtitle: stations.isEmpty ? 'No inventory' : 'Ready for instant 60s swap',
                  icon: Icons.battery_charging_full,
                  accentColor: Colors.blueAccent,
                ),
              ),
              const SizedBox(width: GVSpacing.md),
              Expanded(
                child: AdminKpiCard(
                  title: 'Total Swaps Today',
                  value: '$totalSwaps Swaps',
                  subtitle: stations.isEmpty ? 'Zero activity' : 'Live telemetry',
                  icon: Icons.swap_horiz,
                  accentColor: Colors.amberAccent,
                ),
              ),
              const SizedBox(width: GVSpacing.md),
              const Expanded(
                child: AdminKpiCard(
                  title: 'Merchant Partners',
                  value: '0 Stores',
                  subtitle: 'B2B scheduled pickups',
                  icon: Icons.storefront,
                  accentColor: Colors.purpleAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: GVSpacing.xl),

          // Hubs Table
          Container(
            padding: const EdgeInsets.all(GVSpacing.md),
            decoration: BoxDecoration(
              color: const Color(0xFF101713),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1F2B25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Battery Swapping Stations & Telemetry', style: GVTypography.h3.copyWith(color: Colors.white)),
                    const Text('Live IoT Telemetry', style: TextStyle(color: GVColors.brandGreen, fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: GVSpacing.md),
                if (stations.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Center(
                      child: Column(
                        children: [
                          Icon(Icons.hub_outlined, size: 48, color: Colors.white.withValues(alpha: 0.3)),
                          const SizedBox(height: 12),
                          Text(
                            'No active battery swap stations or merchant hubs online in this operating region.',
                            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...stations.map((stn) {
                    final isOperational = stn.status.toUpperCase() == 'OPERATIONAL';

                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF14241B),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFF274332)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: GVColors.brandGreen.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Icon(Icons.ev_station, color: GVColors.brandGreen, size: 20),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(stn.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                  const SizedBox(height: 2),
                                  Text(stn.address, style: const TextStyle(color: Colors.white60, fontSize: 11)),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('${stn.chargedPacksAvailable} Charged / ${stn.chargingPacks} Charging', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 2),
                                  Text('${stn.dailySwapCount} swaps today', style: const TextStyle(color: Colors.white54, fontSize: 10)),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isOperational ? GVColors.brandGreen.withValues(alpha: 0.15) : Colors.redAccent.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(color: isOperational ? GVColors.brandGreen : Colors.redAccent),
                                ),
                                child: Text(
                                  stn.status.toUpperCase(),
                                  style: TextStyle(
                                    color: isOperational ? GVColors.brandGreen : Colors.redAccent,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
