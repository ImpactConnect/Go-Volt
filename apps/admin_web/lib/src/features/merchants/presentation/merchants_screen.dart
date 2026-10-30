import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/admin_kpi_card.dart';

class MerchantsScreen extends StatelessWidget {
  const MerchantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final hubs = [
      {
        'name': 'Victoria Island Central Swap Hub',
        'location': 'Ahmadu Bello Way / Adeola Odeku',
        'chargedPacks': 48,
        'chargingPacks': 12,
        'swapsToday': 184,
        'status': 'OPERATIONAL',
      },
      {
        'name': 'Lekki Phase 1 Solar Swap Station',
        'location': 'Admiralty Way, Lekki',
        'chargedPacks': 36,
        'chargingPacks': 8,
        'swapsToday': 122,
        'status': 'OPERATIONAL',
      },
      {
        'name': 'Ikeja Commercial Fulfilment Hub',
        'location': 'Allen Avenue, Ikeja',
        'chargedPacks': 52,
        'chargingPacks': 16,
        'swapsToday': 210,
        'status': 'OPERATIONAL',
      },
      {
        'name': 'Yaba Tech Corridor Hub',
        'location': 'Herbert Macaulay Way, Yaba',
        'chargedPacks': 14,
        'chargingPacks': 22,
        'swapsToday': 95,
        'status': 'HIGH DEMAND',
      },
    ];

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
          const Row(
            children: [
              Expanded(
                child: AdminKpiCard(
                  title: 'Active Swap Stations',
                  value: '12 Hubs',
                  subtitle: '100% solar & grid backed',
                  icon: Icons.electric_bolt,
                  accentColor: GVColors.brandGreen,
                ),
              ),
              SizedBox(width: GVSpacing.md),
              Expanded(
                child: AdminKpiCard(
                  title: 'Charged Battery Inventory',
                  value: '384 Packs',
                  subtitle: 'Ready for instant 60s swap',
                  icon: Icons.battery_charging_full,
                  accentColor: Colors.blueAccent,
                ),
              ),
              SizedBox(width: GVSpacing.md),
              Expanded(
                child: AdminKpiCard(
                  title: 'Total Swaps Today',
                  value: '611 Swaps',
                  subtitle: 'Zero downtime recorded',
                  icon: Icons.swap_horiz,
                  accentColor: Colors.amberAccent,
                ),
              ),
              SizedBox(width: GVSpacing.md),
              Expanded(
                child: AdminKpiCard(
                  title: 'Merchant Partners',
                  value: '28 Stores',
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
                ...hubs.map((hub) {
                  final isHighDemand = hub['status'] == 'HIGH DEMAND';

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
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: GVColors.deepGreen,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: GVColors.brandGreen),
                              ),
                              child: const Icon(Icons.ev_station, color: GVColors.brandGreen, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(hub['name'] as String, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                Text(hub['location'] as String, style: const TextStyle(color: Colors.white60, fontSize: 11)),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text('${hub['chargedPacks']} Charged', style: const TextStyle(color: GVColors.brandGreen, fontWeight: FontWeight.bold, fontSize: 12)),
                            const SizedBox(width: 12),
                            Text('${hub['chargingPacks']} Charging', style: const TextStyle(color: Colors.amber, fontSize: 12)),
                            const SizedBox(width: 12),
                            Text('${hub['swapsToday']} Swaps Today', style: const TextStyle(color: Colors.white70, fontSize: 12)),
                            const SizedBox(width: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isHighDemand ? Colors.amber.withValues(alpha: 0.2) : GVColors.brandGreen.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: isHighDemand ? Colors.amber : GVColors.brandGreen),
                              ),
                              child: Text(
                                hub['status'] as String,
                                style: TextStyle(
                                  color: isHighDemand ? Colors.amber : GVColors.brandGreen,
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
