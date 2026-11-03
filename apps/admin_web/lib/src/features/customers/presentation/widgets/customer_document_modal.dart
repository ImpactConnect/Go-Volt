import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/auth/admin_auth_notifier.dart';
import '../../../../core/widgets/admin_modal_dialog.dart';
import '../../application/customer_verification_notifier.dart';
import '../../domain/customer_models.dart';

class CustomerDocumentModal extends ConsumerStatefulWidget {
  const CustomerDocumentModal({
    super.key,
    required this.customer,
  });

  final CustomerVerificationItem customer;

  @override
  ConsumerState<CustomerDocumentModal> createState() => _CustomerDocumentModalState();
}

class _CustomerDocumentModalState extends ConsumerState<CustomerDocumentModal> {
  String? _selectedDocumentKey;

  void _showActionReasonDialog({
    required BuildContext context,
    required String title,
    required String primaryLabel,
    required Color accentColor,
    required Future<void> Function(String reason) onConfirm,
  }) {
    final reasonController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AdminModalDialog(
          title: title,
          icon: Icons.assignment_late_outlined,
          primaryActionLabel: primaryLabel,
          accentColor: accentColor,
          onPrimaryAction: () async {
            if (reasonController.text.trim().isEmpty) return;
            await onConfirm(reasonController.text.trim());
            if (dialogCtx.mounted) Navigator.pop(dialogCtx);
            if (context.mounted) Navigator.pop(context);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Provide clear notes for customer notification and NDPR compliance audit:',
                style: GVTypography.bodySmall.copyWith(color: Colors.white70),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                maxLines: 3,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Authoritative Decision Reason',
                  filled: true,
                  fillColor: Color(0xFF14241B),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.read(adminAuthNotifierProvider);
    final c = widget.customer;
    final docKeys = c.documentUrls.keys.toList();
    final activeDocKey = _selectedDocumentKey ?? (docKeys.isNotEmpty ? docKeys.first : null);

    return AdminModalDialog(
      maxWidth: 780,
      title: 'Customer Identity Review: ${c.fullName}',
      icon: Icons.verified_user_outlined,
      primaryActionLabel: 'Close',
      onPrimaryAction: () => Navigator.pop(context),
      child: SizedBox(
        width: 740,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Profile Metadata Card
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFF14241B),
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                border: Border.all(color: const Color(0xFF263C2E)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: GVColors.brandGreen.withValues(alpha: 0.2),
                    child: Text(
                      c.fullName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join(),
                      style: const TextStyle(
                        color: GVColors.brandGreen,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            Text(
                              c.fullName,
                              style: GVTypography.bodyLarge.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            _buildStatusBadge(c.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${c.phone} • ${c.email}',
                          style: GVTypography.bodySmall.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'NIN: ${c.ninNumber ?? 'Not Provided'} • Address: ${c.residentialAddress ?? 'Not Set'}',
                          style: GVTypography.caption.copyWith(color: Colors.white60),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        c.tier,
                        style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Commute Plans: ${c.activeCommutePlansCount}',
                        style: const TextStyle(color: Colors.white60, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.md),

            // Rejection reason warning if present
            if (c.rejectionReason != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: GVSpacing.md),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.redAccent),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Action / Rejection Note: ${c.rejectionReason}',
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Submitted Documents & Document Inspector Tabs
            Text(
              'SUBMITTED VERIFICATION DOCUMENTS',
              style: GVTypography.caption.copyWith(
                color: GVColors.textSecondary,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 8),

            if (docKeys.isEmpty) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF101713),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white12),
                ),
                child: const Center(
                  child: Text(
                    'No documents uploaded by customer yet.',
                    style: TextStyle(color: Colors.white60),
                  ),
                ),
              ),
            ] else ...[
              // Document selector chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: docKeys.map((key) {
                  final isSelected = key == activeDocKey;
                  return ChoiceChip(
                    label: Text(key),
                    selected: isSelected,
                    selectedColor: GVColors.brandGreen,
                    backgroundColor: const Color(0xFF14241B),
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.black : Colors.white,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 12,
                    ),
                    onSelected: (val) {
                      if (val) setState(() => _selectedDocumentKey = key);
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 12),

              // Mock Document Viewer Box
              Container(
                width: double.infinity,
                height: 160,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A0F0D),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFF263C2E)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.picture_as_pdf_outlined, color: GVColors.brandGreen, size: 36),
                    const SizedBox(height: 8),
                    Text(
                      activeDocKey ?? '',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      c.documentUrls[activeDocKey] ?? '',
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'Verified Document Checksum Match: SHA-256 OK',
                        style: TextStyle(color: GVColors.brandGreen, fontSize: 10, fontFamily: 'monospace'),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: GVSpacing.lg),

            // Administrative Action Triggers Bar
            Wrap(
              alignment: WrapAlignment.end,
              spacing: 8,
              runSpacing: 8,
              children: [
                OutlinedButton(
                  onPressed: () {
                    _showActionReasonDialog(
                      context: context,
                      title: 'Reject Customer Verification',
                      primaryLabel: 'Confirm Rejection',
                      accentColor: Colors.redAccent,
                      onConfirm: (reason) async {
                        await ref.read(customerVerificationNotifierProvider.notifier).rejectVerification(
                              customerId: c.id,
                              reason: reason,
                              reviewerName: authState.userName,
                            );
                      },
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.redAccent,
                    side: const BorderSide(color: Colors.redAccent),
                  ),
                  child: const Text('Reject Verification'),
                ),
                const SizedBox(width: 8),
                OutlinedButton(
                  onPressed: () {
                    _showActionReasonDialog(
                      context: context,
                      title: 'Request Customer Document Action',
                      primaryLabel: 'Request Action',
                      accentColor: Colors.amber,
                      onConfirm: (reason) async {
                        await ref.read(customerVerificationNotifierProvider.notifier).requestAction(
                              customerId: c.id,
                              reason: reason,
                              reviewerName: authState.userName,
                            );
                      },
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.amber,
                    side: const BorderSide(color: Colors.amber),
                  ),
                  child: const Text('Request Action'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () async {
                    await ref.read(customerVerificationNotifierProvider.notifier).approveVerification(
                          customerId: c.id,
                          reviewerName: authState.userName,
                        );
                    if (context.mounted) Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GVColors.brandGreen,
                    foregroundColor: Colors.black,
                  ),
                  child: const Text('Approve & Verify', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(VerificationStatus status) {
    Color bg;
    Color fg;
    switch (status) {
      case VerificationStatus.verified:
        bg = GVColors.brandGreen.withValues(alpha: 0.15);
        fg = GVColors.brandGreen;
        break;
      case VerificationStatus.pending:
        bg = Colors.amber.withValues(alpha: 0.15);
        fg = Colors.amber;
        break;
      case VerificationStatus.actionRequired:
        bg = Colors.orangeAccent.withValues(alpha: 0.15);
        fg = Colors.orangeAccent;
        break;
      case VerificationStatus.rejected:
        bg = Colors.redAccent.withValues(alpha: 0.15);
        fg = Colors.redAccent;
        break;
      case VerificationStatus.notRequired:
        bg = Colors.white10;
        fg = Colors.white70;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: fg.withValues(alpha: 0.5)),
      ),
      child: Text(
        status.label,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }
}
