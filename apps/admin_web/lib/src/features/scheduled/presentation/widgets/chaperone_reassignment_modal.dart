import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/widgets/admin_modal_dialog.dart';
import '../../application/scheduled_operations_notifier.dart';

class ChaperoneReassignmentModal extends ConsumerStatefulWidget {
  const ChaperoneReassignmentModal({
    super.key,
    required this.trip,
  });

  final ScheduledTripDto trip;

  @override
  ConsumerState<ChaperoneReassignmentModal> createState() =>
      _ChaperoneReassignmentModalState();
}

class _ChaperoneReassignmentModalState
    extends ConsumerState<ChaperoneReassignmentModal> {
  final _reasonController = TextEditingController(
    text: 'Pre-scheduled vehicle battery top-up / routine maintenance',
  );
  RiderDto? _selectedDriver;

  // Vetted standby school chaperones with LASRRA / background checks
  final List<RiderDto> _availableChaperones = const [
    RiderDto(
      id: 'RIDER-004',
      profileId: 'PROF-004',
      fullName: 'Zainab Danjuma',
      phoneNumber: '+2348039871122',
      email: 'zainab.danjuma@govolts.ng',
      rating: 4.95,
      status: RiderStatus.online,
      vehiclePlate: 'KD-882-AB',
      vehicleModel: 'Roam Commuter EV',
      batteryLevelPercent: 92,
    ),
    RiderDto(
      id: 'RIDER-005',
      profileId: 'PROF-005',
      fullName: 'Bala Mohammed',
      phoneNumber: '+2348052219988',
      email: 'bala.mohammed@govolts.ng',
      rating: 4.88,
      status: RiderStatus.online,
      vehiclePlate: 'KD-331-ZX',
      vehicleModel: 'Spiro EV Sedan',
      batteryLevelPercent: 85,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedDriver = _availableChaperones.first;
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(scheduledOperationsNotifierProvider.notifier);

    return AdminModalDialog(
      title: 'Reassign Vetted Chaperone — ${widget.trip.tripReference}',
      maxWidth: 680,
      cancelLabel: 'Cancel',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Trip Summary Card
          Container(
            padding: const EdgeInsets.all(GVSpacing.md),
            decoration: BoxDecoration(
              color: const Color(0xFF14241B),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF263C2E)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Student: ${widget.trip.passengerName}',
                        style: GVTypography.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Destination: ${widget.trip.destinationLocation.address}',
                        style: GVTypography.caption.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Current Chaperone: ${widget.trip.assignedDriver?.fullName ?? 'None Assigned'}',
                        style: GVTypography.caption.copyWith(color: Colors.amber),
                      ),
                    ],
                  ),
                ),
                Text(
                  widget.trip.scheduledTimeStr,
                  style: GVTypography.h3.copyWith(
                    color: GVColors.brandGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: GVSpacing.md),

          // Vetted Chaperone Selection
          Text(
            'SELECT VETTED STANDBY CHAPERONE',
            style: GVTypography.caption.copyWith(
              color: GVColors.brandGreen,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            children: _availableChaperones.map((driver) {
              final isSelected = _selectedDriver?.id == driver.id;
              return GestureDetector(
                onTap: () => setState(() => _selectedDriver = driver),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(GVSpacing.md),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1B3826) : const Color(0xFF161F1A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? GVColors.brandGreen : const Color(0xFF263C2E),
                      width: isSelected ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                        color: isSelected ? GVColors.brandGreen : Colors.white38,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  driver.fullName,
                                  style: GVTypography.bodySmall.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF143021),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    '★ ${driver.rating}',
                                    style: GVTypography.caption.copyWith(
                                      color: GVColors.brandGreen,
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${driver.vehicleModel} • ${driver.vehiclePlate}',
                              style: GVTypography.caption.copyWith(color: Colors.white60),
                            ),
                          ],
                        ),
                      ),
                      // EV Battery SoC badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF14241B),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(color: GVColors.brandGreen),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.battery_charging_full,
                                size: 14, color: GVColors.brandGreen),
                            const SizedBox(width: 4),
                            Text(
                              '${driver.batteryLevelPercent}% SoC',
                              style: GVTypography.caption.copyWith(
                                color: GVColors.brandGreen,
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
            }).toList(),
          ),
          const SizedBox(height: GVSpacing.md),

          // Operational Note
          Text(
            'Reassignment Justification (Audit Log)',
            style: GVTypography.caption.copyWith(
              color: Colors.white70,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            key: const Key('chaperone_reason_input'),
            controller: _reasonController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color(0xFF161F1A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Color(0xFF263C2E)),
              ),
            ),
          ),
          const SizedBox(height: GVSpacing.lg),

          // Submit Reassign
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              key: const Key('submit_chaperone_reassign_btn'),
              onPressed: () async {
                if (_selectedDriver == null) return;
                await notifier.reassignDriver(
                  widget.trip.id,
                  _selectedDriver!,
                  reason: _reasonController.text.trim(),
                );
                if (context.mounted) Navigator.of(context).pop();
              },
              icon: const Icon(Icons.swap_horiz, size: 18),
              label: const Text('Confirm Chaperone Reassignment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: GVColors.brandGreen,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
