import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import '../../../../core/widgets/admin_modal_dialog.dart';
import '../../application/rider_management_notifier.dart';
import '../../domain/rider_management_state.dart';

class RiderDocumentModal extends StatefulWidget {
  const RiderDocumentModal({
    super.key,
    required this.rider,
    required this.notifier,
  });

  final AdminRiderApplicant rider;
  final RiderManagementNotifier notifier;

  @override
  State<RiderDocumentModal> createState() => _RiderDocumentModalState();
}

class _RiderDocumentModalState extends State<RiderDocumentModal> {
  late List<ServiceTierEligibility> _selectedTiers;
  final TextEditingController _auditNoteController =
      TextEditingController(text: 'Background checks and document verification passed');

  @override
  void initState() {
    super.initState();
    _selectedTiers = List<ServiceTierEligibility>.from(widget.rider.certifiedTiers);
  }

  @override
  void dispose() {
    _auditNoteController.dispose();
    super.dispose();
  }

  void _showSuspendDialog(BuildContext context) {
    final reasonCtrl = TextEditingController(text: 'Driver license expired / safety incident reported');

    showDialog<void>(
      context: context,
      builder: (dCtx) {
        return AdminModalDialog(
          title: 'Suspend Rider Account',
          subtitle: 'Suspend ${widget.rider.fullName} from dispatch and service matching',
          confirmLabel: 'Confirm Suspension',
          isDestructive: true,
          onConfirm: () async {
            final success = await widget.notifier.suspendRider(
              riderId: widget.rider.id,
              mandatoryReason: reasonCtrl.text.trim(),
            );
            if (dCtx.mounted && success) {
              Navigator.of(dCtx).pop();
              Navigator.of(context).pop();
            }
          },
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Mandatory Compliance Reason *', style: GVTypography.caption.copyWith(color: Colors.white70)),
              const SizedBox(height: 4),
              TextField(
                controller: reasonCtrl,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.rider;

    return Dialog(
      backgroundColor: const Color(0xFF141C18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        side: const BorderSide(color: Color(0xFF24342A)),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Padding(
          padding: const EdgeInsets.all(GVSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: GVColors.deepGreen,
                        child: Icon(Icons.person, color: GVColors.brandGreen),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            r.fullName,
                            style: GVTypography.h2.copyWith(color: Colors.white),
                          ),
                          Text(
                            '${r.phone} · Plate: ${r.vehiclePlate} (${r.vehicleClass})',
                            style: GVTypography.caption.copyWith(color: Colors.white60),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(color: Color(0xFF233229), height: GVSpacing.lg),

              // Uploaded Regulatory Documents Section
              Text(
                'Regulatory & Compliance Documents',
                style: GVTypography.caption.copyWith(color: Colors.white70, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...r.documents.map((doc) {
                final isExpired = doc.isExpired;

                return Container(
                  margin: const EdgeInsets.only(bottom: 6),
                  padding: const EdgeInsets.all(GVSpacing.sm),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1C2721),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isExpired
                          ? Colors.redAccent
                          : (doc.status == DocumentVerificationStatus.approved
                              ? GVColors.brandGreen.withValues(alpha: 0.5)
                              : const Color(0xFF2D3E33)),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isExpired ? Icons.error_outline : Icons.description,
                        color: isExpired ? Colors.redAccent : GVColors.brandGreen,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              doc.type.title,
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                            ),
                            Text(
                              'Number: ${doc.documentNumber} · Expiry: ${doc.expiryDate.toString().split(' ')[0]}',
                              style: TextStyle(
                                color: isExpired ? Colors.redAccent : Colors.white60,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                      GVStatusChip(
                        label: isExpired ? 'EXPIRED' : doc.status.name.toUpperCase(),
                        status: isExpired
                            ? GVStatusType.delayed
                            : (doc.status == DocumentVerificationStatus.approved
                                ? GVStatusType.active
                                : GVStatusType.pending),
                      ),
                    ],
                  ),
                );
              }),
              const SizedBox(height: GVSpacing.md),

              // Service Tier Certification Checkboxes
              Text(
                'Service Tier Certifications & Authorisations',
                style: GVTypography.caption.copyWith(color: Colors.white70, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Wrap(
                spacing: 12,
                children: ServiceTierEligibility.values.map((tier) {
                  final isChecked = _selectedTiers.contains(tier);
                  return FilterChip(
                    selected: isChecked,
                    label: Text(tier.label),
                    selectedColor: const Color(0xFF173827),
                    labelStyle: TextStyle(
                      color: isChecked ? GVColors.brandGreen : Colors.white70,
                      fontWeight: isChecked ? FontWeight.bold : FontWeight.normal,
                    ),
                    onSelected: (val) {
                      setState(() {
                        if (val) {
                          _selectedTiers.add(tier);
                        } else {
                          _selectedTiers.remove(tier);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: GVSpacing.md),

              // Audit Note
              Text('Audit Decision Note *', style: GVTypography.caption.copyWith(color: Colors.white70)),
              const SizedBox(height: 4),
              TextField(
                controller: _auditNoteController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  hintText: 'Enter compliance verification notes...',
                ),
              ),
              const SizedBox(height: GVSpacing.lg),

              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.redAccent,
                      side: const BorderSide(color: Colors.redAccent),
                    ),
                    onPressed: () => _showSuspendDialog(context),
                    child: const Text('Suspend Rider'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GVColors.brandGreen,
                      foregroundColor: GVColors.nearBlack,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () async {
                      final success = await widget.notifier.approveRider(
                        riderId: r.id,
                        certifiedTiers: _selectedTiers,
                        auditNote: _auditNoteController.text.trim(),
                      );
                      if (context.mounted && success) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Approve & Certify Rider'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
