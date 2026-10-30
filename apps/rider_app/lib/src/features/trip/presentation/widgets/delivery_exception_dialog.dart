import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Modal dialog for reporting in-transit exceptions and route deviations (RD16).
class DeliveryExceptionDialog extends StatefulWidget {
  const DeliveryExceptionDialog({
    super.key,
    required this.onReport,
  });

  final void Function(String reason, String? notes) onReport;

  @override
  State<DeliveryExceptionDialog> createState() => _DeliveryExceptionDialogState();
}

class _DeliveryExceptionDialogState extends State<DeliveryExceptionDialog> {
  final List<String> _exceptionTypes = [
    'Recipient Unreachable / Phone Switched Off',
    'Incorrect or Inaccessible Delivery Address',
    'Customer Refuses Handover OTP',
    'Severe Traffic Gridlock / Road Blockade',
    'EV Mechanical or Battery Issue',
    'Security or Safety Hazard in Area',
  ];

  late String _selectedException;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _selectedException = _exceptionTypes.first;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF141917),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GVBorderRadius.lg),
        side: const BorderSide(color: Color(0xFF2A3630)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(GVSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3D2A10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.report_problem, color: Colors.amber, size: 20),
                ),
                const SizedBox(width: GVSpacing.xs),
                Expanded(
                  child: Text(
                    'Report Delivery Exception',
                    style: GVTypography.h3.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: GVSpacing.xs),
            Text(
              'Go-Volts Dispatch Support will be notified immediately to assist with resolution.',
              style: GVTypography.caption.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: GVSpacing.md),

            // Selectable Exception Options
            ..._exceptionTypes.map((type) {
              final isSelected = _selectedException == type;
              return InkWell(
                onTap: () => setState(() => _selectedException = type),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1C2420) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? Colors.amber : Colors.white12,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isSelected ? Colors.amber : Colors.white38,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          type,
                          style: GVTypography.caption.copyWith(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: GVSpacing.sm),
            TextField(
              controller: _notesController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Additional Notes (Optional)',
                hintText: 'e.g. Waiting at security gate for 10 minutes...',
              ),
            ),
            const SizedBox(height: GVSpacing.md),

            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber.shade700,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onReport(_selectedException, _notesController.text.trim());
                    },
                    child: const Text('Submit Report', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
