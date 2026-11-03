import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/auth/admin_auth_notifier.dart';
import '../../../../core/widgets/admin_modal_dialog.dart';
import '../../application/battery_swap_notifier.dart';
import '../../domain/battery_swap_models.dart';

class BatteryBayInspectModal extends ConsumerStatefulWidget {
  const BatteryBayInspectModal({
    super.key,
    required this.stationId,
  });

  final String stationId;

  @override
  ConsumerState<BatteryBayInspectModal> createState() =>
      _BatteryBayInspectModalState();
}

class _BatteryBayInspectModalState extends ConsumerState<BatteryBayInspectModal> {
  int? _selectedBayNumber;
  final _quarantineReasonController = TextEditingController();
  bool _isSubmittingQuarantine = false;

  final List<String> _commonQuarantineReasons = const [
    'Thermal Runaway Warning (>44°C cell temperature)',
    'Cell impedance mismatch flagged by BMS',
    'State of Health (SOH) degraded below 70%',
    'Physical enclosure damage or pin wear',
    'Communication bus failure with Cabinet BMS',
  ];

  @override
  void initState() {
    super.initState();
    _quarantineReasonController.text = _commonQuarantineReasons.first;
  }

  @override
  void dispose() {
    _quarantineReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(batterySwapNotifierProvider);
    final notifier = ref.read(batterySwapNotifierProvider.notifier);
    final authState = ref.watch(adminAuthNotifierProvider);
    final officerName = authState.fullName;

    final station = state.stations.firstWhere(
      (s) => s.id == widget.stationId,
      orElse: () => const BatterySwapStationModel(
        id: 'UNKNOWN',
        name: 'Unknown Station',
        address: 'N/A',
        location: LocationDto(latitude: 0, longitude: 0, address: ''),
        dailySwapCount: 0,
      ),
    );

    final selectedBay = _selectedBayNumber == null
        ? (station.bays.isNotEmpty ? station.bays.first : null)
        : station.bays.firstWhere(
            (b) => b.bayNumber == _selectedBayNumber,
            orElse: () => station.bays.first,
          );

    return AdminModalDialog(
      title: 'Cabinet Bay Telematics Inspector — ${station.name}',
      maxWidth: 920,
      cancelLabel: 'Close',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Station Header Banner
          Container(
            padding: const EdgeInsets.all(GVSpacing.md),
            decoration: BoxDecoration(
              color: station.status == 'MAINTENANCE'
                  ? const Color(0xFF2E2211)
                  : const Color(0xFF14241B),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: station.status == 'MAINTENANCE'
                    ? const Color(0xFFFFB300)
                    : const Color(0xFF263C2E),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: station.status == 'OPERATIONAL'
                                  ? GVColors.brandGreen.withValues(alpha: 0.2)
                                  : station.status == 'HIGH_DEMAND'
                                      ? Colors.blueAccent.withValues(alpha: 0.2)
                                      : const Color(0xFFFFB300).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              station.status,
                              style: GVTypography.caption.copyWith(
                                color: station.status == 'OPERATIONAL'
                                    ? GVColors.brandGreen
                                    : station.status == 'HIGH_DEMAND'
                                        ? Colors.blueAccent
                                        : const Color(0xFFFFB300),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Text(
                            station.id,
                            style: GVTypography.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Power: ${station.powerSource}',
                            style: GVTypography.caption
                                .copyWith(color: Colors.white70),
                          ),
                          Text(
                            'Cabinet Temp: ${station.temperatureCelsius}°C',
                            style: GVTypography.caption.copyWith(
                              color: station.temperatureCelsius > 32
                                  ? const Color(0xFFFFB300)
                                  : GVColors.brandGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        station.address,
                        style:
                            GVTypography.caption.copyWith(color: Colors.white60),
                      ),
                    ],
                  ),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    notifier.toggleStationMaintenance(
                      station.id,
                      reason: station.status == 'MAINTENANCE'
                          ? 'Technician routine check completed'
                          : 'Manual lockdown for cabinet servicing',
                      officerName: officerName,
                    );
                  },
                  icon: Icon(
                    station.status == 'MAINTENANCE'
                        ? Icons.play_arrow
                        : Icons.build,
                    size: 16,
                    color: station.status == 'MAINTENANCE'
                        ? GVColors.brandGreen
                        : const Color(0xFFFFB300),
                  ),
                  label: Text(
                    station.status == 'MAINTENANCE'
                        ? 'Set Operational'
                        : 'Set Maintenance',
                    style: TextStyle(
                      color: station.status == 'MAINTENANCE'
                          ? GVColors.brandGreen
                          : const Color(0xFFFFB300),
                      fontSize: 12,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(
                      color: station.status == 'MAINTENANCE'
                          ? GVColors.brandGreen
                          : const Color(0xFFFFB300),
                    ),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: GVSpacing.md),

          // Inventory summary strip
          Row(
            children: [
              _buildMiniMetric(
                label: 'READY FOR SWAP (SoC ≥ 90%)',
                value: '${station.chargedPacksAvailable}',
                color: GVColors.brandGreen,
                icon: Icons.battery_charging_full,
              ),
              const SizedBox(width: 12),
              _buildMiniMetric(
                label: 'CHARGING ACTIVE',
                value: '${station.chargingPacks}',
                color: Colors.lightBlueAccent,
                icon: Icons.bolt,
              ),
              const SizedBox(width: 12),
              _buildMiniMetric(
                label: 'QUARANTINED / DEGRADED',
                value: '${station.quarantinedPacks}',
                color: station.quarantinedPacks > 0
                    ? Colors.redAccent
                    : Colors.white38,
                icon: Icons.gpp_bad,
              ),
              const SizedBox(width: 12),
              _buildMiniMetric(
                label: 'DAILY SWAPS COMPLETED',
                value: '${station.dailySwapCount}',
                color: Colors.white,
                icon: Icons.autorenew,
              ),
            ],
          ),
          const SizedBox(height: GVSpacing.md),

          const Divider(color: Color(0xFF263C2E)),
          const SizedBox(height: GVSpacing.sm),

          Text(
            '24-Bay Smart Cabinet Matrix (Select a bay to inspect telematics and execute remote lock/quarantine)',
            style: GVTypography.caption.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: GVSpacing.sm),

          // 24-Bay Cabinet Matrix Grid (6 columns x 4 rows)
          station.bays.isEmpty
              ? Container(
                  height: 120,
                  alignment: Alignment.center,
                  child: const Text('No bays configured for this station.',
                      style: TextStyle(color: Colors.white54)),
                )
              : SizedBox(
                  height: 240,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.7,
                    ),
                    itemCount: station.bays.length,
                    itemBuilder: (context, index) {
                      final bay = station.bays[index];
                      final isSelected = selectedBay?.bayNumber == bay.bayNumber;

                      Color borderColor;
                      Color bgColor;
                      Color statusColor;
                      String statusText;

                      if (bay.isQuarantined) {
                        borderColor = Colors.redAccent;
                        bgColor = const Color(0xFF2D1212);
                        statusColor = Colors.redAccent;
                        statusText = 'QUAR';
                      } else if (bay.isReadyForSwap) {
                        borderColor = GVColors.brandGreen;
                        bgColor = const Color(0xFF14241B);
                        statusColor = GVColors.brandGreen;
                        statusText = '${bay.socPercent}% RDY';
                      } else {
                        borderColor = Colors.lightBlueAccent;
                        bgColor = const Color(0xFF0F1E28);
                        statusColor = Colors.lightBlueAccent;
                        statusText = '${bay.socPercent}% CHG';
                      }

                      if (isSelected) {
                        borderColor = Colors.white;
                      }

                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedBayNumber = bay.bayNumber;
                            _isSubmittingQuarantine = false;
                          });
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 6),
                          decoration: BoxDecoration(
                            color: bgColor,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: borderColor,
                              width: isSelected ? 2.0 : 1.0,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Bay ${bay.bayNumber.toString().padLeft(2, '0')}',
                                    style: GVTypography.caption.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 11,
                                    ),
                                  ),
                                  Icon(
                                    bay.isLocked ? Icons.lock : Icons.lock_open,
                                    size: 13,
                                    color: bay.isLocked
                                        ? Colors.white38
                                        : GVColors.brandGreen,
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      statusText,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: statusColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${bay.temperatureCelsius.toStringAsFixed(0)}°C',
                                    style: TextStyle(
                                      color: bay.temperatureCelsius > 40
                                          ? Colors.redAccent
                                          : Colors.white60,
                                      fontSize: 10,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

          const SizedBox(height: GVSpacing.md),

          // Selected Bay Telematics & Quick Actions Panel
          if (selectedBay != null) ...[
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(
                            selectedBay.isQuarantined
                                ? Icons.warning_amber
                                : Icons.battery_charging_full,
                            color: selectedBay.isQuarantined
                                ? Colors.redAccent
                                : GVColors.brandGreen,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Bay #${selectedBay.bayNumber.toString().padLeft(2, '0')} Telematics — ${selectedBay.batterySerial}',
                            style: GVTypography.bodyMedium.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: selectedBay.isLocked
                              ? Colors.grey.withValues(alpha: 0.2)
                              : GVColors.brandGreen.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          selectedBay.isLocked ? 'DOOR SOLENOID: LOCKED' : 'DOOR SOLENOID: UNLOCKED',
                          style: TextStyle(
                            color: selectedBay.isLocked
                                ? Colors.white60
                                : GVColors.brandGreen,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Telematics Chips
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _buildChip(
                        label: 'State of Charge (SoC)',
                        value: '${selectedBay.socPercent}%',
                        color: selectedBay.socPercent >= 90
                            ? GVColors.brandGreen
                            : selectedBay.socPercent >= 40
                                ? Colors.lightBlueAccent
                                : Colors.redAccent,
                      ),
                      _buildChip(
                        label: 'State of Health (SOH)',
                        value: '${selectedBay.sohHealthPercent}%',
                        color: selectedBay.sohHealthPercent >= 80
                            ? GVColors.brandGreen
                            : const Color(0xFFFFB300),
                      ),
                      _buildChip(
                        label: 'Core Cell Temperature',
                        value: '${selectedBay.temperatureCelsius}°C',
                        color: selectedBay.temperatureCelsius > 40
                            ? Colors.redAccent
                            : Colors.white,
                      ),
                      _buildChip(
                        label: 'Charging Status',
                        value: selectedBay.isQuarantined
                            ? 'HALTED (QUARANTINED)'
                            : selectedBay.isCharging
                                ? 'ACTIVE (FAST DC)'
                                : 'STANDBY / FLOAT',
                        color: selectedBay.isQuarantined
                            ? Colors.redAccent
                            : selectedBay.isCharging
                                ? Colors.lightBlueAccent
                                : Colors.white70,
                      ),
                    ],
                  ),

                  // Quarantined warning banner
                  if (selectedBay.isQuarantined) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D1212),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.redAccent),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.report,
                              color: Colors.redAccent, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'QUARANTINE ACTIVE: ${selectedBay.quarantineReason ?? "Thermal runaway threshold exceeded"}. Bay isolated from dispatch algorithms.',
                              style: GVTypography.caption.copyWith(
                                color: Colors.redAccent,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  // Inline quarantine reason input if opened
                  if (_isSubmittingQuarantine) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1313),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Select or enter quarantine reason:',
                            style: GVTypography.caption
                                .copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            initialValue: _quarantineReasonController.text.isNotEmpty &&
                                    _commonQuarantineReasons.contains(_quarantineReasonController.text)
                                ? _quarantineReasonController.text
                                : _commonQuarantineReasons.first,
                            dropdownColor: const Color(0xFF1E2822),
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: const InputDecoration(
                              filled: true,
                              fillColor: Color(0xFF121915),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 8),
                              border: OutlineInputBorder(),
                            ),
                            items: _commonQuarantineReasons
                                .map((r) => DropdownMenuItem(
                                      value: r,
                                      child: Text(r),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                _quarantineReasonController.text = val;
                              }
                            },
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _isSubmittingQuarantine = false;
                                  });
                                },
                                child: const Text('Cancel',
                                    style: TextStyle(color: Colors.white60)),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                onPressed: () async {
                                  await notifier.quarantineBatteryBay(
                                    station.id,
                                    selectedBay.bayNumber,
                                    reason: _quarantineReasonController.text,
                                    officerName: officerName,
                                  );
                                  setState(() {
                                    _isSubmittingQuarantine = false;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.redAccent,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Confirm Quarantine'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 14),

                  // Actions row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Remote Unlock Bay Door
                      OutlinedButton.icon(
                        onPressed: selectedBay.isLocked
                            ? () {
                                notifier.remoteUnlockBay(
                                  station.id,
                                  selectedBay.bayNumber,
                                  officerName: officerName,
                                );
                              }
                            : null,
                        icon: const Icon(Icons.lock_open, size: 16),
                        label: Text(
                          selectedBay.isLocked
                              ? 'Remote Unlock Door'
                              : 'Door Unlocked',
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Color(0xFF263C2E)),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Quarantine or Release Button
                      if (selectedBay.isQuarantined)
                        ElevatedButton.icon(
                          onPressed: () {
                            notifier.releaseQuarantineBay(
                              station.id,
                              selectedBay.bayNumber,
                              officerName: officerName,
                            );
                          },
                          icon: const Icon(Icons.check_circle_outline, size: 16),
                          label: const Text('Release Quarantine'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: GVColors.brandGreen,
                            foregroundColor: Colors.black,
                          ),
                        )
                      else if (!_isSubmittingQuarantine)
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {
                              _isSubmittingQuarantine = true;
                            });
                          },
                          icon: const Icon(Icons.warning, size: 16),
                          label: const Text('Quarantine Bay'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMiniMetric({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF141D18),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: const Color(0xFF263C2E)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      color: color,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2B23),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.white60, fontSize: 12),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
