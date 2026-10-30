import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/auth/admin_auth_notifier.dart';
import '../../../core/widgets/admin_kpi_card.dart';
import '../../../core/widgets/admin_modal_dialog.dart';
import '../application/finance_notifier.dart';
import '../domain/finance_models.dart';

class FinanceManagementScreen extends ConsumerStatefulWidget {
  const FinanceManagementScreen({super.key});

  @override
  ConsumerState<FinanceManagementScreen> createState() =>
      _FinanceManagementScreenState();
}

class _FinanceManagementScreenState
    extends ConsumerState<FinanceManagementScreen> {
  final _dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  void _showInitiateRefundModal(BuildContext context) {
    final bookingRefController = TextEditingController();
    final customerController = TextEditingController();
    final amountController = TextEditingController(text: '12000');
    final reasonController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AdminModalDialog(
          title: 'Initiate Refund Request',
          icon: Icons.account_balance_wallet_outlined,
          primaryActionLabel: 'Submit for Sign-off',
          onPrimaryAction: () {
            if (bookingRefController.text.trim().isEmpty) return;
            final amount = BigInt.from((double.tryParse(amountController.text) ?? 1000) * 100);
            final authState = ref.read(adminAuthNotifierProvider);

            ref.read(financeNotifierProvider.notifier).requestRefund(
                  bookingRef: bookingRefController.text.trim(),
                  customerName: customerController.text.trim(),
                  amountKobo: amount,
                  reason: reasonController.text.trim(),
                  makerId: authState.userId,
                  makerName: '${authState.userName} (${authState.role.label})',
                );

            Navigator.pop(dialogCtx);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Refund request initiated.')),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Refunds exceeding ₦10,000 require Maker-Checker dual authorization. You will be recorded as the Maker.',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: bookingRefController,
                decoration: const InputDecoration(
                  labelText: 'Booking Reference (e.g. GV-LKG-9021)',
                  filled: true,
                  fillColor: Color(0xFF14241B),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: customerController,
                decoration: const InputDecoration(
                  labelText: 'Customer Full Name',
                  filled: true,
                  fillColor: Color(0xFF14241B),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Refund Amount (₦)',
                  filled: true,
                  fillColor: Color(0xFF14241B),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonController,
                decoration: const InputDecoration(
                  labelText: 'Reason & Evidence Summary',
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

  void _showApprovalDialog(BuildContext context, RefundRequestModel refund) {
    final authState = ref.read(adminAuthNotifierProvider);

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return AdminModalDialog(
          title: 'Sign Off / Approve Refund',
          icon: Icons.check_circle_outline,
          primaryActionLabel: 'Confirm Approval',
          accentColor: GVColors.brandGreen,
          onPrimaryAction: () {
            final success = ref.read(financeNotifierProvider.notifier).approveRefund(
                  requestId: refund.id,
                  checkerId: authState.userId,
                  checkerName: '${authState.userName} (${authState.role.label})',
                );

            Navigator.pop(dialogCtx);

            if (!success) {
              final err = ref.read(financeNotifierProvider).errorMessage;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(err ?? 'Approval failed.'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Refund ${refund.id} approved successfully.')),
              );
            }
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Reviewing refund for ${refund.customerName} on ${refund.bookingRef}.',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Amount: ${refund.formattedAmount}',
                style: const TextStyle(color: GVColors.brandGreen, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Reason: ${refund.reason}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 8),
              Text('Maker (Initiator): ${refund.makerName}', style: const TextStyle(color: Colors.white60, fontSize: 11)),
              const Divider(color: Color(0xFF1F2B25), height: 24),
              if (refund.requiresMakerChecker)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.amber),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.security, color: Colors.amber, size: 16),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Maker-Checker Policy: As Checker, your credentials will be logged as the second mandatory authority.',
                          style: TextStyle(color: Colors.amber, fontSize: 11),
                        ),
                      ),
                    ],
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
    final financeState = ref.watch(financeNotifierProvider);
    final summary = financeState.summary;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(GVSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Finance & Dual Maker-Checker Reconciliation',
                      style: GVTypography.h2.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Ledger settlements, rider payout batches, and dual sign-off on refunds ≥ ₦10,000 (§6.8)',
                      style: GVTypography.bodySmall.copyWith(color: Colors.white60),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: GVSpacing.md),
              ElevatedButton.icon(
                key: const Key('initiate_refund_btn'),
                onPressed: () => _showInitiateRefundModal(context),
                icon: const Icon(Icons.currency_exchange, size: 18),
                label: const Text('Initiate Refund Request'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GVColors.brandGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: GVSpacing.lg),

          // Error Banner if Maker-Checker constraint triggered
          if (financeState.errorMessage != null) ...[
            Container(
              margin: const EdgeInsets.only(bottom: GVSpacing.md),
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.redAccent),
              ),
              child: Row(
                children: [
                  const Icon(Icons.gavel, color: Colors.redAccent, size: 24),
                  const SizedBox(width: GVSpacing.md),
                  Expanded(
                    child: Text(
                      financeState.errorMessage!,
                      style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // KPIs
          Row(
            children: [
              Expanded(
                child: AdminKpiCard(
                  title: 'Gross Platform GMV',
                  value: summary.formattedGrossGmv,
                  subtitle: 'Total completed trip volume',
                  icon: Icons.payments_outlined,
                  accentColor: GVColors.brandGreen,
                ),
              ),
              const SizedBox(width: GVSpacing.md),
              Expanded(
                child: AdminKpiCard(
                  title: 'Net Platform Take (20%)',
                  value: summary.formattedNetRevenue,
                  subtitle: 'Realized commission revenue',
                  icon: Icons.trending_up,
                  accentColor: Colors.blueAccent,
                ),
              ),
              const SizedBox(width: GVSpacing.md),
              Expanded(
                child: AdminKpiCard(
                  title: 'Rider Payout Pool (80%)',
                  value: summary.formattedRiderEarnings,
                  subtitle: 'Disbursed via automated batch',
                  icon: Icons.electric_moped_outlined,
                  accentColor: Colors.purpleAccent,
                ),
              ),
              const SizedBox(width: GVSpacing.md),
              Expanded(
                child: AdminKpiCard(
                  title: 'Pending Maker-Checker',
                  value: '${financeState.pendingMakerCheckerCount} Required',
                  subtitle: 'Refunds ≥ ₦10,000 awaiting checker',
                  icon: Icons.policy_outlined,
                  accentColor: financeState.pendingMakerCheckerCount > 0 ? Colors.amber : GVColors.brandGreen,
                ),
              ),
            ],
          ),
          const SizedBox(height: GVSpacing.xl),

          // Refund Requests Queue
          Container(
            padding: const EdgeInsets.all(GVSpacing.md),
            decoration: BoxDecoration(
              color: const Color(0xFF101713),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1F2B25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Customer Refund & Chargeback Queue',
                      style: GVTypography.h3.copyWith(color: Colors.white),
                    ),
                    Text(
                      '${financeState.refunds.length} total refund records',
                      style: const TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: GVSpacing.md),
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1.4),
                    1: FlexColumnWidth(1.8),
                    2: FlexColumnWidth(1.2),
                    3: FlexColumnWidth(1.4),
                    4: FlexColumnWidth(1.6),
                    5: FlexColumnWidth(1.4),
                    6: FlexColumnWidth(1.4),
                  },
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0xFF1F2B25))),
                      ),
                      children: [
                        _headerCell('BOOKING / REF'),
                        _headerCell('CUSTOMER & REASON'),
                        _headerCell('AMOUNT'),
                        _headerCell('POLICY'),
                        _headerCell('MAKER SIGN-OFF'),
                        _headerCell('CHECKER SIGN-OFF'),
                        _headerCell('ACTION'),
                      ],
                    ),
                    ...financeState.refunds.map((refund) {
                      Color statusColor;
                      switch (refund.status) {
                        case RefundStatus.approved:
                          statusColor = GVColors.brandGreen;
                          break;
                        case RefundStatus.pendingCheckerSignoff:
                          statusColor = Colors.amber;
                          break;
                        case RefundStatus.pendingReview:
                          statusColor = Colors.blueAccent;
                          break;
                        case RefundStatus.rejected:
                          statusColor = Colors.redAccent;
                          break;
                      }

                      return TableRow(
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xFF18221D))),
                        ),
                        children: [
                          _dataCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(refund.bookingRef, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                                Text(refund.id, style: const TextStyle(color: Colors.white38, fontSize: 10)),
                              ],
                            ),
                          ),
                          _dataCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(refund.customerName, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                                Text(refund.reason, style: const TextStyle(color: Colors.white60, fontSize: 10), maxLines: 2, overflow: TextOverflow.ellipsis),
                              ],
                            ),
                          ),
                          _dataCell(
                            Text(refund.formattedAmount, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                          ),
                          _dataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                              decoration: BoxDecoration(
                                color: refund.requiresMakerChecker
                                    ? Colors.amber.withValues(alpha: 0.15)
                                    : Colors.blueAccent.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: refund.requiresMakerChecker ? Colors.amber : Colors.blueAccent,
                                ),
                              ),
                              child: Text(
                                refund.requiresMakerChecker ? 'MAKER-CHECKER (≥₦10K)' : 'SINGLE REVIEW',
                                style: TextStyle(
                                  color: refund.requiresMakerChecker ? Colors.amber : Colors.blueAccent,
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          _dataCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(refund.makerName, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                                Text(_dateFormat.format(refund.makerTimestamp), style: const TextStyle(color: Colors.white38, fontSize: 10)),
                              ],
                            ),
                          ),
                          _dataCell(
                            refund.checkerName != null
                                ? Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(refund.checkerName!, style: const TextStyle(color: GVColors.brandGreen, fontSize: 11)),
                                      Text(_dateFormat.format(refund.checkerTimestamp!), style: const TextStyle(color: Colors.white38, fontSize: 10)),
                                    ],
                                  )
                                : Text(
                                    refund.requiresMakerChecker ? 'Awaiting 2nd Officer' : 'Awaiting Review',
                                    style: TextStyle(color: statusColor, fontSize: 11, fontStyle: FontStyle.italic),
                                  ),
                          ),
                          _dataCell(
                            refund.status == RefundStatus.approved
                                ? Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: GVColors.brandGreen.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: const Text('SETTLED', style: TextStyle(color: GVColors.brandGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                                  )
                                : ElevatedButton(
                                    key: Key('approve_refund_${refund.id}'),
                                    onPressed: () => _showApprovalDialog(context, refund),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: GVColors.brandGreen,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      minimumSize: const Size(64, 28),
                                    ),
                                    child: const Text('Approve', style: TextStyle(fontSize: 11)),
                                  ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: GVSpacing.xl),

          // Payout Batches
          Container(
            padding: const EdgeInsets.all(GVSpacing.md),
            decoration: BoxDecoration(
              color: const Color(0xFF101713),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1F2B25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Rider Automated Payout Batches',
                      style: GVTypography.h3.copyWith(color: Colors.white),
                    ),
                    const Text('Daily & Weekly Payout Cadence', style: TextStyle(color: Colors.white38, fontSize: 12)),
                  ],
                ),
                const SizedBox(height: GVSpacing.md),
                ...financeState.payoutBatches.map((batch) {
                  final isSettled = batch.status == 'settled';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF14241B),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF274332)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              isSettled ? Icons.check_circle : Icons.hourglass_top,
                              color: isSettled ? GVColors.brandGreen : Colors.amber,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(batch.batchId, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                Text('${batch.period} · ${batch.totalRiders} electric moto riders', style: const TextStyle(color: Colors.white60, fontSize: 11)),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              batch.formattedTotal,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                            const SizedBox(width: 16),
                            if (!isSettled)
                              ElevatedButton(
                                key: Key('settle_batch_${batch.batchId}'),
                                onPressed: () {
                                  ref.read(financeNotifierProvider.notifier).settlePayoutBatch(batch.batchId);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Payout batch ${batch.batchId} settled.')),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: GVColors.brandGreen,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  minimumSize: const Size(60, 28),
                                ),
                                child: const Text('Settle', style: TextStyle(fontSize: 11)),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: GVColors.brandGreen.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text('DISBURSED', style: TextStyle(color: GVColors.brandGreen, fontSize: 10, fontWeight: FontWeight.bold)),
                              ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Text(
        title,
        style: GVTypography.caption.copyWith(
          color: Colors.white38,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _dataCell(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: child,
    );
  }
}
