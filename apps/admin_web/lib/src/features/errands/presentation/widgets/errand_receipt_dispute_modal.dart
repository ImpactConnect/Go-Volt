import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/auth/admin_auth_notifier.dart';
import '../../../../core/widgets/admin_modal_dialog.dart';
import '../../application/errand_operations_notifier.dart';
import '../../domain/errand_operations_models.dart';

class ErrandReceiptDisputeModal extends ConsumerStatefulWidget {
  const ErrandReceiptDisputeModal({
    super.key,
    this.reconciliation,
    this.dispute,
  });

  final ErrandReconciliationModel? reconciliation;
  final ErrandDisputeModel? dispute;

  @override
  ConsumerState<ErrandReceiptDisputeModal> createState() =>
      _ErrandReceiptDisputeModalState();
}

class _ErrandReceiptDisputeModalState
    extends ConsumerState<ErrandReceiptDisputeModal> {
  final _resolutionNotesController = TextEditingController();

  @override
  void dispose() {
    _resolutionNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(adminAuthNotifierProvider);
    final notifier = ref.read(errandOperationsNotifierProvider.notifier);

    final isDispute = widget.dispute != null;
    final title = isDispute
        ? 'Dispute Review — ${widget.dispute!.referenceNumber}'
        : 'Receipt Reconciliation — ${widget.reconciliation!.referenceNumber}';

    return AdminModalDialog(
      title: title,
      maxWidth: 780,
      cancelLabel: 'Close',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.reconciliation != null) ...[
            _buildReconciliationView(context, widget.reconciliation!, authState, notifier),
          ],
          if (widget.dispute != null) ...[
            _buildDisputeView(context, widget.dispute!, authState, notifier),
          ],
        ],
      ),
    );
  }

  Widget _buildReconciliationView(
    BuildContext context,
    ErrandReconciliationModel rec,
    AdminUserState authState,
    ErrandOperationsNotifier notifier,
  ) {
    final isOverThreshold = rec.needsDualApproval;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dual signoff alert if > ₦10,000
        if (isOverThreshold) ...[
          Container(
            padding: const EdgeInsets.all(GVSpacing.md),
            margin: const EdgeInsets.only(bottom: GVSpacing.md),
            decoration: BoxDecoration(
              color: const Color(0xFF2B1D0E),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber),
            ),
            child: Row(
              children: [
                const Icon(Icons.security, color: Colors.amber, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'DUAL MAKER-CHECKER GOVERNANCE REQUIRED',
                        style: GVTypography.caption.copyWith(
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Adjustments exceeding ₦10,000 require Maker submission followed by Finance Officer or Super Admin sign-off.',
                        style: GVTypography.bodySmall.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],

        // Financial comparison cards
        Row(
          children: [
            Expanded(
              child: _summaryBox(
                'CUSTOMER BUDGET',
                '₦${rec.budgetedNgn.toStringAsFixed(0)}',
                'Customer app estimated quote',
                Colors.white70,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryBox(
                'ACTUAL STORE RECEIPT',
                '₦${rec.actualNgn.toStringAsFixed(0)}',
                'Paper receipt captured by rider',
                GVColors.brandGreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryBox(
                rec.differenceKobo < 0 ? 'REFUND DUE' : 'EXTRA CHARGE',
                '₦${rec.differenceNgn.toStringAsFixed(0)}',
                rec.differenceKobo < 0
                    ? 'Credit to customer wallet'
                    : 'Charge customer wallet',
                rec.differenceKobo < 0 ? GVColors.brandGreen : Colors.redAccent,
              ),
            ),
          ],
        ),
        const SizedBox(height: GVSpacing.md),

        // Parties metadata
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
              _metadataRow('Customer:', rec.customerName),
              const SizedBox(height: 4),
              _metadataRow('Shopper / Rider:', rec.shopperName),
              const SizedBox(height: 4),
              _metadataRow('Store / Market:', rec.shopName),
              const SizedBox(height: 4),
              _metadataRow('Audit Status:', rec.status),
              if (rec.makerStaffName != null) ...[
                const SizedBox(height: 4),
                _metadataRow('Maker Sign-off:', rec.makerStaffName!),
              ],
              if (rec.checkerStaffName != null) ...[
                const SizedBox(height: 4),
                _metadataRow('Checker Sign-off:', rec.checkerStaffName!),
              ],
            ],
          ),
        ),
        const SizedBox(height: GVSpacing.lg),

        // Approval Buttons
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: [
            if (rec.status == 'PENDING') ...[
              ElevatedButton.icon(
                onPressed: () async {
                  await notifier.approveReconciliation(
                    rec.id,
                    staffName: authState.fullName,
                    staffRole: authState.role,
                  );
                  if (context.mounted) Navigator.of(context).pop();
                },
                icon: const Icon(Icons.check, size: 16),
                label: Text(
                  isOverThreshold
                      ? 'Submit as Maker (Sign-Off Step 1)'
                      : 'Approve & Settle ₦${rec.differenceNgn.toStringAsFixed(0)}',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GVColors.brandGreen,
                  foregroundColor: Colors.black,
                ),
              ),
            ] else if (rec.status == 'MAKER_APPROVED') ...[
              ElevatedButton.icon(
                onPressed: () async {
                  await notifier.approveReconciliation(
                    rec.id,
                    staffName: authState.fullName,
                    staffRole: authState.role,
                  );
                  if (context.mounted) Navigator.of(context).pop();
                },
                icon: const Icon(Icons.verified, size: 16),
                label: Text('Sign as Checker & Disburse ₦${rec.differenceNgn.toStringAsFixed(0)}'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                ),
              ),
            ] else ...[
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF14241B),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: GVColors.brandGreen, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Reconciliation Settled & Disbursed',
                      style: GVTypography.caption.copyWith(
                        color: GVColors.brandGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildDisputeView(
    BuildContext context,
    ErrandDisputeModel disp,
    AdminUserState authState,
    ErrandOperationsNotifier notifier,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Dispute context card
        Container(
          padding: const EdgeInsets.all(GVSpacing.md),
          decoration: BoxDecoration(
            color: const Color(0xFF231414),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.redAccent, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'CUSTOMER COMPLAINT: ${disp.disputeReason}',
                      style: GVTypography.caption.copyWith(
                        color: Colors.redAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (disp.customerNote != null)
                Text(
                  'Customer Statement: "${disp.customerNote}"',
                  style: GVTypography.bodySmall.copyWith(
                    color: Colors.white,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: GVSpacing.md),

        // Disputed numbers
        Row(
          children: [
            Expanded(
              child: _summaryBox(
                'BUDGETED',
                '₦${disp.budgetedAmountNgn.toStringAsFixed(0)}',
                'Pre-authorized amount',
                Colors.white70,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryBox(
                'CHARGED RECEIPT',
                '₦${disp.actualReceiptNgn.toStringAsFixed(0)}',
                'Submitted by shopper',
                Colors.redAccent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _summaryBox(
                'DISPUTED DELTA',
                '₦${disp.differenceNgn.toStringAsFixed(0)}',
                'Variance amount',
                Colors.amber,
              ),
            ),
          ],
        ),
        const SizedBox(height: GVSpacing.md),

        // Dispute Resolution Input
        Text(
          'Resolution Decision & Explanation',
          style: GVTypography.caption.copyWith(
            color: Colors.white70,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _resolutionNotesController,
          maxLines: 2,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter resolution note to be documented in audit trail...',
            hintStyle: const TextStyle(color: Colors.white38),
            filled: true,
            fillColor: const Color(0xFF161F1A),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF263C2E)),
            ),
          ),
        ),
        const SizedBox(height: GVSpacing.lg),

        // Resolution Actions
        if (!disp.isResolved) ...[
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: [
              ElevatedButton.icon(
                onPressed: () async {
                  final notes = _resolutionNotesController.text.trim().isNotEmpty
                      ? _resolutionNotesController.text.trim()
                      : 'Refund granted. Shopper violated substitution policy.';
                  await notifier.resolveDispute(
                    disp.id,
                    refundCustomer: true,
                    refundAmountKobo: disp.differenceKobo,
                    resolutionNotes: notes,
                    staffName: authState.fullName,
                  );
                  if (context.mounted) Navigator.of(context).pop();
                },
                icon: const Icon(Icons.undo, size: 16),
                label: Text('Refund Customer (₦${disp.differenceNgn.toStringAsFixed(0)})'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GVColors.brandGreen,
                  foregroundColor: Colors.black,
                ),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final notes = _resolutionNotesController.text.trim().isNotEmpty
                      ? _resolutionNotesController.text.trim()
                      : 'Dispute rejected: Shopper provided valid paper receipt within approved tolerances.';
                  await notifier.resolveDispute(
                    disp.id,
                    refundCustomer: false,
                    refundAmountKobo: 0,
                    resolutionNotes: notes,
                    staffName: authState.fullName,
                  );
                  if (context.mounted) Navigator.of(context).pop();
                },
                icon: const Icon(Icons.close, size: 16),
                label: const Text('Reject Dispute (Uphold Receipt)'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Colors.redAccent),
                ),
              ),
            ],
          ),
        ] else ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF14241B),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Dispute Status: ${disp.status}',
              style: GVTypography.caption.copyWith(
                color: GVColors.brandGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _summaryBox(String title, String amount, String subtitle, Color color) {
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
          Text(
            title,
            style: GVTypography.caption.copyWith(
              color: Colors.white60,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: GVTypography.h3.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: GVTypography.caption.copyWith(color: Colors.white38, fontSize: 11),
          ),
        ],
      ),
    );
  }

  Widget _metadataRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 140,
          child: Text(
            label,
            style: GVTypography.caption.copyWith(color: Colors.white60),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GVTypography.bodySmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
