import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/auth/admin_auth_notifier.dart';
import '../../../../core/widgets/admin_modal_dialog.dart';
import '../../application/safety_sos_notifier.dart';
import '../../domain/safety_sos_models.dart';

class SosDispatchModal extends ConsumerStatefulWidget {
  const SosDispatchModal({
    super.key,
    required this.alert,
  });

  final SosDistressAlert alert;

  @override
  ConsumerState<SosDispatchModal> createState() => _SosDispatchModalState();
}

class _SosDispatchModalState extends ConsumerState<SosDispatchModal> {
  final _dispatchNoteController = TextEditingController();
  final _resolutionController = TextEditingController();
  String _selectedAgency = 'Lagos 112 / 767 Emergency Center';
  bool _showResolutionInput = false;

  final List<String> _emergencyAgencies = const [
    'Lagos 112 / 767 Emergency Center',
    'State Police Command & Highway Patrol',
    'Federal Road Safety Corps (FRSC)',
    'State Emergency Management Agency (SEMA)',
    'Nearest Rapid Ambulance Service',
  ];

  @override
  void dispose() {
    _dispatchNoteController.dispose();
    _resolutionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(adminAuthNotifierProvider);
    final notifier = ref.read(safetySosNotifierProvider.notifier);
    final alert = widget.alert;

    return AdminModalDialog(
      title: 'Emergency SOS Command Desk — ${alert.incidentRef}',
      maxWidth: 820,
      cancelLabel: 'Close',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Flashing Distress Banner
          Container(
            padding: const EdgeInsets.all(GVSpacing.md),
            decoration: BoxDecoration(
              color: alert.isActive ? const Color(0xFF3B1212) : const Color(0xFF14241B),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: alert.isActive ? Colors.redAccent : GVColors.brandGreen,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  alert.isActive ? Icons.emergency : Icons.check_circle,
                  color: alert.isActive ? Colors.redAccent : GVColors.brandGreen,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Wrap(
                        spacing: 8,
                        runSpacing: 4,
                        children: [
                          Text(
                            alert.status.label.toUpperCase(),
                            style: GVTypography.caption.copyWith(
                              color: alert.isActive ? Colors.redAccent : GVColors.brandGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '• Triggered by: ${alert.triggeredBy}',
                            style: GVTypography.caption.copyWith(color: Colors.white70),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Booking: ${alert.bookingRef} (${alert.serviceType}) • Triggered: ${alert.triggeredAt.hour.toString().padLeft(2, '0')}:${alert.triggeredAt.minute.toString().padLeft(2, '0')}',
                        style: GVTypography.caption.copyWith(color: Colors.white60),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: GVSpacing.md),

          // 3 Column Telemetry Snapshot
          Row(
            children: [
              Expanded(
                child: _telemetryBox(
                  'CURRENT SPEED',
                  '${alert.speedKmH.toStringAsFixed(0)} km/h',
                  alert.speedKmH > 0 ? 'Vehicle in motion' : 'Stationary',
                  alert.speedKmH > 80 ? Colors.redAccent : GVColors.brandGreen,
                  Icons.speed,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _telemetryBox(
                  'EV BATTERY SOC',
                  '${alert.evBatteryPercent}%',
                  'Vehicle battery health',
                  alert.evBatteryPercent < 20 ? Colors.redAccent : GVColors.brandGreen,
                  Icons.battery_charging_full,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _telemetryBox(
                  'AUDIO MONITOR',
                  alert.audioRecordingUrl != null ? 'STREAMING' : 'OFFLINE',
                  alert.audioRecordingUrl != null ? 'Encrypted cloud buffer' : 'No mic stream',
                  alert.audioRecordingUrl != null ? Colors.amber : Colors.white38,
                  Icons.mic,
                ),
              ),
            ],
          ),
          const SizedBox(height: GVSpacing.md),

          // GPS Coordinates & Location Card
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
                        const Icon(Icons.location_on, color: Colors.redAccent, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'LIVE GPS TELEMETRY & LANDMARK',
                          style: GVTypography.caption.copyWith(
                            color: GVColors.brandGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      'Lat: ${alert.location.latitude.toStringAsFixed(4)}, Lng: ${alert.location.longitude.toStringAsFixed(4)}',
                      style: GVTypography.caption.copyWith(
                        color: Colors.white70,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  alert.location.address,
                  style: GVTypography.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: GVSpacing.md),

          // Parties Contact Row
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(GVSpacing.md),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161F1A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF263C2E)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'VICTIM / INITIATOR',
                        style: GVTypography.caption.copyWith(
                          color: Colors.white60,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alert.victimName,
                        style: GVTypography.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        alert.victimPhone,
                        style: GVTypography.caption.copyWith(color: GVColors.brandGreen),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(GVSpacing.md),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161F1A),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF263C2E)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DRIVER / VEHICLE',
                        style: GVTypography.caption.copyWith(
                          color: Colors.white60,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        alert.driverName ?? 'No driver assigned',
                        style: GVTypography.bodySmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${alert.vehicleModel ?? 'EV'} • ${alert.vehiclePlate ?? 'Plate N/A'}',
                        style: GVTypography.caption.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: GVSpacing.md),

          // Rapid Dispatch Action Section
          if (alert.isActive) ...[
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFF201313),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.5)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RAPID DISPATCH PROTOCOL',
                    style: GVTypography.caption.copyWith(
                      color: Colors.redAccent,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    initialValue: _selectedAgency,
                    items: _emergencyAgencies
                        .map((a) => DropdownMenuItem(
                              value: a,
                              child: Text(a, style: const TextStyle(color: Colors.white, fontSize: 13)),
                            ))
                        .toList(),
                    onChanged: (v) => setState(() => _selectedAgency = v ?? _selectedAgency),
                    dropdownColor: const Color(0xFF1A1A1A),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFF14241B),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFF263C2E)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    key: const Key('dispatch_notes_input'),
                    controller: _dispatchNoteController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Enter dispatch reference notes, caller remarks, or officer radio log...',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFF14241B),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFF263C2E)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      ElevatedButton.icon(
                        key: const Key('confirm_dispatch_agency_btn'),
                        onPressed: () async {
                          final note = _dispatchNoteController.text.trim().isNotEmpty
                              ? _dispatchNoteController.text.trim()
                              : 'Dispatched to $_selectedAgency at live coordinates';
                          await notifier.dispatchEmergencyServices(
                            alert.id,
                            agency: _selectedAgency,
                            officerName: authState.fullName,
                            notes: note,
                          );
                          if (context.mounted) Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.call, size: 16),
                        label: Text('Dispatch $_selectedAgency'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.redAccent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                      OutlinedButton.icon(
                        key: const Key('dispatch_patrol_btn'),
                        onPressed: () async {
                          await notifier.dispatchPatrolUnit(
                            alert.id,
                            patrolUnitCode: 'UNIT-ALPHA-EV',
                            officerName: authState.fullName,
                          );
                          if (context.mounted) Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.security, size: 16),
                        label: const Text('Deploy Go-Volts EV Patrol Unit'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.amber,
                          side: const BorderSide(color: Colors.amber),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.md),
          ],

          // Incident Resolution Action
          if (alert.isActive && !_showResolutionInput) ...[
            TextButton.icon(
              key: const Key('open_resolution_accordion_btn'),
              onPressed: () => setState(() => _showResolutionInput = true),
              icon: const Icon(Icons.check_circle_outline, color: GVColors.brandGreen, size: 16),
              label: const Text(
                'Mark Incident Resolved Safe / False Alarm',
                style: TextStyle(color: GVColors.brandGreen, fontSize: 13),
              ),
            ),
          ] else if (_showResolutionInput) ...[
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFF14241B),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: GVColors.brandGreen),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'INCIDENT CLOSURE & RESOLUTION AUDIT NOTE',
                    style: GVTypography.caption.copyWith(
                      color: GVColors.brandGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    key: const Key('resolution_summary_input'),
                    controller: _resolutionController,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'Document safety investigation findings and confirmation of safe arrival...',
                      hintStyle: const TextStyle(color: Colors.white38, fontSize: 13),
                      filled: true,
                      fillColor: const Color(0xFF161F1A),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Color(0xFF263C2E)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 12,
                    children: [
                      ElevatedButton.icon(
                        key: const Key('resolve_safe_btn'),
                        onPressed: () async {
                          final summary = _resolutionController.text.trim().isNotEmpty
                              ? _resolutionController.text.trim()
                              : 'Passenger and driver confirmed safe in person. Incident closed.';
                          await notifier.resolveAlert(
                            alert.id,
                            isFalseAlarm: false,
                            resolutionSummary: summary,
                            officerName: authState.fullName,
                          );
                          if (context.mounted) Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.verified, size: 16),
                        label: const Text('Resolve as Safe'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GVColors.brandGreen,
                          foregroundColor: Colors.black,
                        ),
                      ),
                      OutlinedButton.icon(
                        key: const Key('resolve_false_alarm_btn'),
                        onPressed: () async {
                          final summary = _resolutionController.text.trim().isNotEmpty
                              ? _resolutionController.text.trim()
                              : 'Accidental SOS trigger confirmed by user. No distress.';
                          await notifier.resolveAlert(
                            alert.id,
                            isFalseAlarm: true,
                            resolutionSummary: summary,
                            officerName: authState.fullName,
                          );
                          if (context.mounted) Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.cancel_outlined, size: 16),
                        label: const Text('Close as False Alarm'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: const BorderSide(color: Colors.white38),
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

  Widget _telemetryBox(String title, String value, String subtitle, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(GVSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF14241B),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF263C2E)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: GVTypography.caption.copyWith(color: Colors.white60, fontSize: 10),
              ),
              Icon(icon, size: 14, color: color),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GVTypography.h3.copyWith(color: color, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GVTypography.caption.copyWith(color: Colors.white38, fontSize: 10),
          ),
        ],
      ),
    );
  }
}
