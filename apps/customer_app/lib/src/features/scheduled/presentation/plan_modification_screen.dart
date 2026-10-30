import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Screen SP15: Change Scheduled Plan Address / Time with Pro-rata Quote Preview.
class PlanModificationScreen extends StatefulWidget {
  const PlanModificationScreen({
    super.key,
    this.planReference = 'PLN-SCH-2026-092',
    this.planTitle = 'Weekday Work Commute (Lekki to VI)',
  });

  final String planReference;
  final String planTitle;

  @override
  State<PlanModificationScreen> createState() => _PlanModificationScreenState();
}

class _PlanModificationScreenState extends State<PlanModificationScreen> {
  final _pickupController = TextEditingController(text: '14 Admiralty Way, Lekki Phase 1');
  final _dropoffController = TextEditingController(text: '18 Adeola Odeku St, Victoria Island');
  TimeOfDay _pickupTime = const TimeOfDay(hour: 7, minute: 45);
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GVColors.darkBg,
      appBar: AppBar(
        title: const Text('Modify Subscription Plan'),
        backgroundColor: GVColors.darkBg,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(GVSpacing.md),
          children: [
            // Plan Header Card
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2420),
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                border: Border.all(color: const Color(0xFF2A3630)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Text(
                          widget.planTitle,
                          style: GVTypography.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const GVStatusChip(label: 'ACTIVE PLAN', status: GVStatusType.active),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Reference: ${widget.planReference}',
                    style: GVTypography.caption.copyWith(color: Colors.white54),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.md),

            // Policy Notice
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFF133B26),
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                border: Border.all(color: GVColors.brandGreen),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: GVColors.brandGreen, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Material route or timing adjustments require Go-Volts operations re-validation. Approved changes become effective on the following Monday cycle.',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.lg),

            Text('Updated Journey Route', style: GVTypography.h3.copyWith(color: Colors.white)),
            const SizedBox(height: GVSpacing.xs),
            _buildInputField('Pickup Location', _pickupController, Icons.circle, GVColors.brandGreen),
            const SizedBox(height: GVSpacing.md),
            _buildInputField('Drop-off Destination', _dropoffController, Icons.location_on, Colors.redAccent),
            const SizedBox(height: GVSpacing.lg),

            Text('Updated Pickup Schedule', style: GVTypography.h3.copyWith(color: Colors.white)),
            const SizedBox(height: GVSpacing.xs),
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2420),
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                border: Border.all(color: const Color(0xFF2A3630)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Morning Pickup Window', style: TextStyle(color: Colors.white60, fontSize: 12)),
                      const SizedBox(height: 2),
                      Text(
                        _pickupTime.format(context),
                        style: GVTypography.h2.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: GVColors.brandGreen,
                      side: const BorderSide(color: GVColors.brandGreen),
                    ),
                    icon: const Icon(Icons.access_time, size: 16),
                    label: const Text('Change Time'),
                    onPressed: () async {
                      final picked = await showTimePicker(
                        context: context,
                        initialTime: _pickupTime,
                      );
                      if (picked != null) {
                        setState(() => _pickupTime = picked);
                      }
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.xl),

            GVPrimaryButton(
              label: _isSubmitting ? 'Submitting Modification...' : 'Submit Schedule Adjustment',
              onPressed: _isSubmitting ? null : _submitModification,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller,
    IconData icon,
    Color iconColor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2420),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF2A3630)),
          ),
          child: Row(
            children: [
              Icon(icon, color: iconColor, size: 16),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _submitModification() async {
    setState(() => _isSubmitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    setState(() => _isSubmitting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Plan modification request submitted for operations review.'),
          backgroundColor: GVColors.deepGreen,
        ),
      );
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }
}
