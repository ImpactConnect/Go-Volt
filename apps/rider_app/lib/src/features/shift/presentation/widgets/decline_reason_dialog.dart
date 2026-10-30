import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Modal dialog for capturing why a rider declined a dispatch offer.
class DeclineReasonDialog extends StatefulWidget {
  const DeclineReasonDialog({
    super.key,
    required this.onConfirm,
  });

  final void Function(DispatchDeclineReason reason, String? note) onConfirm;

  @override
  State<DeclineReasonDialog> createState() => _DeclineReasonDialogState();
}

class _DeclineReasonDialogState extends State<DeclineReasonDialog> {
  DispatchDeclineReason _selectedReason = DispatchDeclineReason.distanceTooFar;
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _noteController.dispose();
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
                    color: const Color(0xFF3D1C1C),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.cancel_outlined, color: Colors.redAccent, size: 20),
                ),
                const SizedBox(width: GVSpacing.xs),
                Expanded(
                  child: Text(
                    'Decline Dispatch Offer',
                    style: GVTypography.h3.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(height: GVSpacing.xs),
            Text(
              'Select a reason to help Go-Volts improve fleet matching and dispatch accuracy.',
              style: GVTypography.caption.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: GVSpacing.md),

            // Selectable Reasons
            ...DispatchDeclineReason.values.map((reason) {
              final isSelected = _selectedReason == reason;
              return InkWell(
                onTap: () => setState(() => _selectedReason = reason),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF1C2420) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? GVColors.brandGreen : Colors.white12,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                        color: isSelected ? GVColors.brandGreen : Colors.white38,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          reason.label,
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

            const SizedBox(height: GVSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Keep Offer',
                      style: GVTypography.bodyMedium.copyWith(color: Colors.white60),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent.shade700,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onConfirm(_selectedReason, _noteController.text.trim());
                    },
                    child: const Text('Confirm'),
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
