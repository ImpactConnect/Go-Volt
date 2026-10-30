import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/battery_swap_notifier.dart';
import '../domain/battery_swap_state.dart';

/// Screen RD22 & RD23: EV Battery Swapping Station Hubs across Lagos.
class BatterySwapScreen extends ConsumerWidget {
  const BatterySwapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(batterySwapNotifierProvider);
    final notifier = ref.read(batterySwapNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: GVColors.darkBg,
      appBar: AppBar(
        title: const Text('EV Battery Swapping Stations'),
        backgroundColor: GVColors.darkBg,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Scan Station QR',
            icon: const Icon(Icons.qr_code_scanner, color: GVColors.brandGreen),
            onPressed: () => _showQrScannerModal(context, ref),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(GVSpacing.md),
          children: [
            // Current Battery State
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2420),
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                border: Border.all(color: const Color(0xFF2A3630)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.battery_charging_full,
                      color: GVColors.brandGreen, size: 36),
                  const SizedBox(width: GVSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Battery Status: ${state.batteryHealthPercent}% (Good Health)',
                          style: GVTypography.bodyMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'Estimated Range: ~${state.estimatedRangeKm} km · Dual 3.2 kWh Packs',
                          style: GVTypography.caption.copyWith(color: Colors.white60),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  const GVStatusChip(label: 'READY', status: GVStatusType.active),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.md),

            // Active Reservation Banner
            if (state.hasActiveReservation)
              Container(
                margin: const EdgeInsets.only(bottom: GVSpacing.md),
                padding: const EdgeInsets.all(GVSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xFF133B26),
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(color: GVColors.brandGreen),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.lock_clock, color: GVColors.brandGreen, size: 24),
                    const SizedBox(width: GVSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Active Reservation: ${state.reservedStationName}',
                            style: GVTypography.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'Locker held for 15 mins. Head to kiosk to scan QR.',
                            style: GVTypography.caption.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () {
                        notifier.cancelReservation();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Reservation cancelled.')),
                        );
                      },
                      child: const Text('Cancel', style: TextStyle(color: Colors.amber)),
                    ),
                  ],
                ),
              ),

            // Locker Unlocked Celebration Banner
            if (state.unlockedLockerNumber != null)
              Container(
                margin: const EdgeInsets.only(bottom: GVSpacing.md),
                padding: const EdgeInsets.all(GVSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F3D24),
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(color: GVColors.brandGreen, width: 2),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: GVColors.brandGreen, size: 28),
                    const SizedBox(width: GVSpacing.sm),
                    Expanded(
                      child: Text(
                        'Locker #${state.unlockedLockerNumber} Unlocked! Swap completed in under 90s.',
                        style: GVTypography.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Lagos Fast-Swap Hubs (Under 90 Secs)',
                    style: GVTypography.h3.copyWith(color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.qr_code, size: 16, color: GVColors.brandGreen),
                  label: const Text('Unlock', style: TextStyle(color: GVColors.brandGreen)),
                  onPressed: () => _showQrScannerModal(context, ref),
                ),
              ],
            ),
            const SizedBox(height: GVSpacing.xs),

            for (final station in state.stations)
              _buildStationCard(context, ref, station, state.reservedStationId == station.id),
          ],
        ),
      ),
    );
  }

  Widget _buildStationCard(
    BuildContext context,
    WidgetRef ref,
    BatterySwapStationDto station,
    bool isReserved,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(GVSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2420),
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        border: Border.all(
          color: isReserved ? GVColors.brandGreen : const Color(0xFF2A3630),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  station.name,
                  style: GVTypography.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: GVColors.deepGreen,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  '${station.availablePacks} / ${station.totalSlots} Ready',
                  style: GVTypography.caption.copyWith(
                    color: GVColors.brandGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            '${station.address} · ${station.distanceKm} km away',
            style: GVTypography.caption.copyWith(color: Colors.white60),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: GVSpacing.sm),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: isReserved ? Colors.amber : GVColors.brandGreen,
                  side: BorderSide(
                    color: isReserved ? Colors.amber : GVColors.brandGreen,
                  ),
                ),
                icon: Icon(isReserved ? Icons.check : Icons.lock_clock, size: 16),
                label: Text(isReserved ? 'Reserved (15 min)' : 'Reserve Slot (15 min)'),
                onPressed: () {
                  if (isReserved) {
                    ref.read(batterySwapNotifierProvider.notifier).cancelReservation();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Reservation at ${station.name} released.')),
                    );
                  } else {
                    final success = ref
                        .read(batterySwapNotifierProvider.notifier)
                        .reserveSlot(station.id);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Battery slot reserved at ${station.name} for 15 mins.'),
                          backgroundColor: GVColors.deepGreen,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showQrScannerModal(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF1C2420),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(GVBorderRadius.md)),
      ),
      builder: (sheetCtx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(GVSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.qr_code_scanner, color: GVColors.brandGreen, size: 48),
              const SizedBox(height: GVSpacing.sm),
              Text(
                'Scan Kiosk Station QR Code',
                style: GVTypography.h3.copyWith(color: Colors.white),
              ),
              const SizedBox(height: GVSpacing.xs),
              const Text(
                'Point your camera at the QR code displayed on the Go-Volts Swap Kiosk to unlock your charged battery.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: GVSpacing.lg),
              GVPrimaryButton(
                label: 'Simulate Kiosk Scan & Unlock Door',
                onPressed: () async {
                  Navigator.of(sheetCtx).pop();
                  final locker = await ref
                      .read(batterySwapNotifierProvider.notifier)
                      .unlockLockerWithQr('SWAP-KIOSK-IKJ-01');
                  if (context.mounted && locker != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Success! Locker #$locker door popped open. Battery swapped.'),
                        backgroundColor: GVColors.deepGreen,
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
