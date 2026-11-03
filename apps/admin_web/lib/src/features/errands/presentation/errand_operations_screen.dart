import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/admin_kpi_card.dart';
import '../application/errand_operations_notifier.dart';
import 'widgets/errand_detail_modal.dart';
import 'widgets/errand_receipt_dispute_modal.dart';

class ErrandOperationsScreen extends ConsumerWidget {
  const ErrandOperationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(errandOperationsNotifierProvider);
    final notifier = ref.read(errandOperationsNotifierProvider.notifier);
    final filtered = state.filteredErrands;

    return Scaffold(
      backgroundColor: const Color(0xFF0C120F),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(GVSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Page Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Market Errand Supervision Hub',
                        style: GVTypography.h1.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Supervise shopping runs, audit store purchase receipts, settle price differences, and resolve item substitution disputes',
                        style: GVTypography.bodyMedium.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF14241B),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFF263C2E)),
                  ),
                  child: Text(
                    '${state.totalErrands} Total Errands',
                    style: GVTypography.caption.copyWith(
                      color: GVColors.brandGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: GVSpacing.lg),

            // Action Feedback Banner
            if (state.actionMessage != null) ...[
              Container(
                padding: const EdgeInsets.all(GVSpacing.md),
                margin: const EdgeInsets.only(bottom: GVSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xFF143021),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: GVColors.brandGreen),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_outline,
                        color: GVColors.brandGreen, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.actionMessage!,
                        style: GVTypography.bodySmall.copyWith(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // 4 High-Contrast KPI Cards
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;
                return Wrap(
                  spacing: GVSpacing.md,
                  runSpacing: GVSpacing.md,
                  children: [
                    SizedBox(
                      width: isWide ? (constraints.maxWidth - 48) / 4 : constraints.maxWidth,
                      child: AdminKpiCard(
                        title: 'Active Errands',
                        value: state.activeShoppingCount.toString(),
                        subtitle: 'Shopping & out for delivery',
                        icon: Icons.electric_moped_outlined,
                      ),
                    ),
                    SizedBox(
                      width: isWide ? (constraints.maxWidth - 48) / 4 : constraints.maxWidth,
                      child: AdminKpiCard(
                        title: 'Pending Reconciliations',
                        value: state.pendingReconciliationsCount.toString(),
                        subtitle: 'Receipt deltas awaiting settlement',
                        icon: Icons.receipt_long_outlined,
                        badgeLabel: state.pendingReconciliationsCount > 0 ? 'ACTION' : null,
                        accentColor: state.pendingReconciliationsCount > 0 ? Colors.amber : null,
                      ),
                    ),
                    SizedBox(
                      width: isWide ? (constraints.maxWidth - 48) / 4 : constraints.maxWidth,
                      child: AdminKpiCard(
                        title: 'Substitution Disputes',
                        value: state.disputeCount.toString(),
                        subtitle: 'Customer-reported price flags',
                        icon: Icons.report_problem_outlined,
                        badgeLabel: state.disputeCount > 0 ? 'ALERT' : null,
                        accentColor: state.disputeCount > 0 ? Colors.redAccent : null,
                      ),
                    ),
                    SizedBox(
                      width: isWide ? (constraints.maxWidth - 48) / 4 : constraints.maxWidth,
                      child: AdminKpiCard(
                        title: 'Completed Today',
                        value: state.completedTodayCount.toString(),
                        subtitle: 'Successfully delivered to customer',
                        icon: Icons.check_circle_outline,
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: GVSpacing.lg),

            // Pending Reconciliations & Disputes Quick-Action Desk
            if (state.reconciliations.isNotEmpty || state.disputes.isNotEmpty) ...[
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
                            const Icon(Icons.fact_check_outlined,
                                color: GVColors.brandGreen, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'AUDIT DESK: STORE RECEIPTS & CUSTOMER DISPUTES',
                              style: GVTypography.caption.copyWith(
                                color: GVColors.brandGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${state.pendingReconciliationsCount} Reconciliations Pending • ${state.disputeCount} Disputes',
                          style: GVTypography.caption.copyWith(color: Colors.white60),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 12,
                      runSpacing: 8,
                      children: [
                        ...state.reconciliations.map((rec) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF14241B),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: rec.needsDualApproval
                                      ? Colors.amber.withValues(alpha: 0.5)
                                      : const Color(0xFF263C2E),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    rec.needsDualApproval
                                        ? Icons.security
                                        : Icons.receipt_outlined,
                                    size: 16,
                                    color: rec.needsDualApproval
                                        ? Colors.amber
                                        : GVColors.brandGreen,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${rec.referenceNumber}: ${rec.shopName} (Delta: ₦${rec.differenceNgn.toStringAsFixed(0)})',
                                    style: GVTypography.caption.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    key: Key('reconcile_btn_${rec.id}'),
                                    onPressed: () {
                                      showDialog<void>(
                                        context: context,
                                        builder: (_) => ErrandReceiptDisputeModal(
                                          reconciliation: rec,
                                        ),
                                      );
                                    },
                                    child: Text(
                                      rec.status == 'MAKER_APPROVED'
                                          ? 'Sign Checker'
                                          : 'Review Receipt',
                                      style: TextStyle(
                                        color: rec.status == 'MAKER_APPROVED'
                                            ? Colors.amber
                                            : GVColors.brandGreen,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                        ...state.disputes.map((disp) => Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF231414),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.redAccent.withValues(alpha: 0.4)),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.report_problem_outlined,
                                      size: 16, color: Colors.redAccent),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${disp.referenceNumber}: ${disp.customerName} (Diff: ₦${disp.differenceNgn.toStringAsFixed(0)})',
                                    style: GVTypography.caption.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  TextButton(
                                    key: Key('dispute_btn_${disp.id}'),
                                    onPressed: () {
                                      showDialog<void>(
                                        context: context,
                                        builder: (_) => ErrandReceiptDisputeModal(
                                          dispute: disp,
                                        ),
                                      );
                                    },
                                    child: const Text(
                                      'Resolve Dispute',
                                      style: TextStyle(
                                        color: Colors.redAccent,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: GVSpacing.lg),
            ],

            // Filters & Search Bar Card
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
                  // Search Bar
                  TextField(
                    onChanged: notifier.search,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Search by Order Ref (e.g. ERR-2026), customer name, shopper, or store...',
                      hintStyle: const TextStyle(color: Colors.white38),
                      prefixIcon: const Icon(Icons.search, color: Colors.white54),
                      filled: true,
                      fillColor: const Color(0xFF14241B),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF263C2E)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Color(0xFF263C2E)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Filter Chips
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Flow Type:',
                        style: GVTypography.caption.copyWith(
                          color: Colors.white60,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      _flowChip(
                        label: 'All Flows',
                        isSelected: state.selectedType == null,
                        onSelected: () => notifier.filterByType(null),
                      ),
                      _flowChip(
                        label: 'Flow A: Buy Items',
                        isSelected: state.selectedType == ErrandType.buyItems,
                        onSelected: () => notifier.filterByType(ErrandType.buyItems),
                      ),
                      _flowChip(
                        label: 'Flow B: Package Pickup',
                        isSelected: state.selectedType == ErrandType.pickupPackage,
                        onSelected: () => notifier.filterByType(ErrandType.pickupPackage),
                      ),
                      _flowChip(
                        label: 'Flow C: Other Errand',
                        isSelected: state.selectedType == ErrandType.otherErrand,
                        onSelected: () => notifier.filterByType(ErrandType.otherErrand),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.lg),

            // Errand Orders Table
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF161F1A),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF263C2E)),
              ),
              child: filtered.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(GVSpacing.xxl),
                      child: Center(
                        child: Text(
                          'No errand orders found matching current filters.',
                          style: GVTypography.bodyMedium.copyWith(color: Colors.white60),
                        ),
                      ),
                    )
                  : Table(
                      columnWidths: const {
                        0: FlexColumnWidth(2.2), // Order Ref & Type
                        1: FlexColumnWidth(2.0), // Customer & Phone
                        2: FlexColumnWidth(2.2), // Store / Origin
                        3: FlexColumnWidth(2.0), // Shopper / Rider
                        4: FlexColumnWidth(1.6), // Financial Total
                        5: FlexColumnWidth(1.8), // Status
                        6: FlexColumnWidth(1.6), // Action
                      },
                      children: [
                        TableRow(
                          decoration: const BoxDecoration(
                            border: Border(bottom: BorderSide(color: Color(0xFF263C2E))),
                            color: Color(0xFF14241B),
                          ),
                          children: [
                            _headerCell('ORDER REF & FLOW'),
                            _headerCell('CUSTOMER'),
                            _headerCell('ORIGIN / STORE'),
                            _headerCell('SHOPPER / RIDER'),
                            _headerCell('TOTAL / ITEMS'),
                            _headerCell('STATUS'),
                            _headerCell('ACTION'),
                          ],
                        ),
                        ...filtered.map((errand) => TableRow(
                              decoration: const BoxDecoration(
                                border: Border(bottom: BorderSide(color: Color(0xFF263C2E))),
                              ),
                              children: [
                                // Order Ref & Type
                                _dataCell(
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        errand.referenceNumber,
                                        style: GVTypography.bodySmall.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        errand.type == ErrandType.buyItems
                                            ? 'Flow A: Buy Items'
                                            : errand.type == ErrandType.pickupPackage
                                                ? 'Flow B: Pick Package'
                                                : 'Flow C: Other Errand',
                                        style: GVTypography.caption.copyWith(
                                          color: GVColors.brandGreen,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Customer
                                _dataCell(
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        errand.recipient.fullName,
                                        style: GVTypography.bodySmall.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      Text(
                                        errand.recipient.phoneNumber,
                                        style: GVTypography.caption.copyWith(
                                          color: Colors.white60,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Origin / Store
                                _dataCell(
                                  Text(
                                    errand.type == ErrandType.buyItems
                                        ? (errand.shop?.name ?? 'Local Market')
                                        : errand.type == ErrandType.pickupPackage
                                            ? (errand.pickupDetails?.pickupBusinessName ?? 'Pickup Hub')
                                            : 'Custom Task Point',
                                    style: GVTypography.caption.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                // Shopper / Rider
                                _dataCell(
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        errand.assignedRider?.fullName ?? 'Unassigned',
                                        style: GVTypography.bodySmall.copyWith(
                                          color: errand.assignedRider != null
                                              ? Colors.white
                                              : Colors.amber,
                                        ),
                                      ),
                                      if (errand.assignedRider?.vehiclePlate != null)
                                        Text(
                                          errand.assignedRider!.vehiclePlate,
                                          style: GVTypography.caption.copyWith(
                                            color: Colors.white60,
                                            fontSize: 11,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                // Total
                                _dataCell(
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '₦${(errand.quote.totalKobo / 100).toStringAsFixed(0)}',
                                        style: GVTypography.bodySmall.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (errand.items.isNotEmpty)
                                        Text(
                                          '${errand.items.length} items',
                                          style: GVTypography.caption.copyWith(
                                            color: Colors.white60,
                                            fontSize: 11,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                // Status
                                _dataCell(
                                  _statusBadge(errand.status),
                                ),
                                // Action
                                _dataCell(
                                  OutlinedButton(
                                    key: Key('inspect_errand_${errand.id}'),
                                    onPressed: () {
                                      showDialog<void>(
                                        context: context,
                                        builder: (_) => ErrandDetailModal(errand: errand),
                                      );
                                    },
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: GVColors.brandGreen,
                                      side: const BorderSide(color: Color(0xFF263C2E)),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    ),
                                    child: const Text('Inspect', style: TextStyle(fontSize: 12)),
                                  ),
                                ),
                              ],
                            )),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _flowChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      selectedColor: const Color(0xFF143021),
      backgroundColor: const Color(0xFF14241B),
      labelStyle: TextStyle(
        color: isSelected ? GVColors.brandGreen : Colors.white70,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 12,
      ),
      side: BorderSide(
        color: isSelected ? GVColors.brandGreen : const Color(0xFF263C2E),
      ),
    );
  }

  Widget _statusBadge(ErrandStatus status) {
    Color color;
    switch (status) {
      case ErrandStatus.completed:
        color = GVColors.brandGreen;
        break;
      case ErrandStatus.shoppingInProgress:
      case ErrandStatus.inProgress:
      case ErrandStatus.outForDelivery:
        color = Colors.amber;
        break;
      case ErrandStatus.issueReported:
        color = Colors.redAccent;
        break;
      default:
        color = Colors.white70;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _headerCell(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Text(
        title,
        style: GVTypography.caption.copyWith(
          color: Colors.white70,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _dataCell(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: child,
    );
  }
}
