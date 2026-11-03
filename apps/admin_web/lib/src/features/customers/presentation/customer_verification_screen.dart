import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/admin_kpi_card.dart';
import '../application/customer_verification_notifier.dart';
import 'widgets/customer_document_modal.dart';

class CustomerVerificationScreen extends ConsumerWidget {
  const CustomerVerificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(customerVerificationNotifierProvider);
    final notifier = ref.read(customerVerificationNotifierProvider.notifier);
    final filtered = state.filteredCustomers;
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

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
                        'Customer Identity & KYC Verification',
                        style: GVTypography.h1.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Authoritative review of customer NIN, LASRRA, and guardian consent documents (§A4)',
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
                    '${state.pendingCount} Pending Review',
                    style: GVTypography.caption.copyWith(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: GVSpacing.lg),

            // Action Feedback Alert Banner
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
                    const Icon(Icons.check_circle_outline, color: GVColors.brandGreen, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        state.actionMessage!,
                        style: GVTypography.bodySmall.copyWith(color: Colors.white),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white54, size: 16),
                      onPressed: () => notifier.clearActionMessage(),
                    ),
                  ],
                ),
              ),
            ],

            // KPI Summary Counters
            LayoutBuilder(
              builder: (ctx, constraints) {
                final isWide = constraints.maxWidth > 900;
                return GridView.count(
                  crossAxisCount: isWide ? 4 : 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: GVSpacing.md,
                  mainAxisSpacing: GVSpacing.md,
                  childAspectRatio: isWide ? 2.0 : 1.5,
                  children: [
                    AdminKpiCard(
                      title: 'Total Applications',
                      value: '${state.totalSubmitted}',
                      subtitle: 'Submitted KYC profiles',
                      icon: Icons.people_outline,
                      accentColor: Colors.blueAccent,
                    ),
                    AdminKpiCard(
                      title: 'Pending Verification',
                      value: '${state.pendingCount}',
                      subtitle: 'Needs agent audit',
                      icon: Icons.pending_actions_outlined,
                      accentColor: Colors.amber,
                    ),
                    AdminKpiCard(
                      title: 'Verified Customers',
                      value: '${state.verifiedCount}',
                      subtitle: 'Cleared for high-tier services',
                      icon: Icons.verified_user_outlined,
                      accentColor: GVColors.brandGreen,
                    ),
                    AdminKpiCard(
                      title: 'Action Required',
                      value: '${state.actionRequiredCount}',
                      subtitle: 'Resubmission requested',
                      icon: Icons.assignment_late_outlined,
                      accentColor: Colors.orangeAccent,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: GVSpacing.lg),

            // Search Bar & Filter Chips
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFF101713),
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                border: Border.all(color: const Color(0xFF1F2B25)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: notifier.search,
                          style: const TextStyle(color: Colors.white),
                          decoration: const InputDecoration(
                            hintText: 'Search by Customer Name, Phone, Email or NIN...',
                            prefixIcon: Icon(Icons.search, color: Colors.white54),
                            filled: true,
                            fillColor: Color(0xFF14241B),
                            border: OutlineInputBorder(borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      const Text(
                        'Filter Status: ',
                        style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      const SizedBox(width: 8),
                      _buildFilterChip(
                        label: 'ALL (${state.totalSubmitted})',
                        isSelected: state.selectedStatus == null,
                        onSelected: () => notifier.filterByStatus(null),
                      ),
                      const SizedBox(width: 6),
                      _buildFilterChip(
                        label: 'PENDING (${state.pendingCount})',
                        isSelected: state.selectedStatus == VerificationStatus.pending,
                        onSelected: () => notifier.filterByStatus(VerificationStatus.pending),
                      ),
                      const SizedBox(width: 6),
                      _buildFilterChip(
                        label: 'VERIFIED (${state.verifiedCount})',
                        isSelected: state.selectedStatus == VerificationStatus.verified,
                        onSelected: () => notifier.filterByStatus(VerificationStatus.verified),
                      ),
                      const SizedBox(width: 6),
                      _buildFilterChip(
                        label: 'ACTION REQUIRED (${state.actionRequiredCount})',
                        isSelected: state.selectedStatus == VerificationStatus.actionRequired,
                        onSelected: () => notifier.filterByStatus(VerificationStatus.actionRequired),
                      ),
                      const SizedBox(width: 6),
                      _buildFilterChip(
                        label: 'REJECTED (${state.rejectedCount})',
                        isSelected: state.selectedStatus == VerificationStatus.rejected,
                        onSelected: () => notifier.filterByStatus(VerificationStatus.rejected),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.lg),

            // Customers Table Card
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF101713),
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                border: Border.all(color: const Color(0xFF1F2B25)),
              ),
              child: filtered.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(40),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.person_off_outlined, size: 48, color: Colors.white24),
                            const SizedBox(height: 12),
                            Text(
                              'No customers match the current filter or search criteria.',
                              style: GVTypography.bodyMedium.copyWith(color: Colors.white60),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columnSpacing: 20,
                        headingRowColor: WidgetStateProperty.all(const Color(0xFF14241B)),
                        columns: const [
                          DataColumn(label: Text('Customer', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Contact', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Submitted Documents', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Service Tier', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Date Submitted', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Status', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Actions', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold))),
                        ],
                        rows: filtered.map((c) {
                          return DataRow(
                            cells: [
                              DataCell(
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 14,
                                      backgroundColor: GVColors.brandGreen.withValues(alpha: 0.15),
                                      child: Text(
                                        c.fullName.isNotEmpty ? c.fullName[0] : '?',
                                        style: const TextStyle(color: GVColors.brandGreen, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(c.fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                        Text(c.id, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(c.phone, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                                    Text(c.email, style: const TextStyle(color: Colors.white54, fontSize: 11)),
                                  ],
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [
                                    const Icon(Icons.attach_file, color: GVColors.brandGreen, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      '${c.documentUrls.length} / ${c.requiredDocuments.length} Uploaded',
                                      style: TextStyle(
                                        color: c.documentUrls.length >= c.requiredDocuments.length ? GVColors.brandGreen : Colors.amber,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Text(
                                  c.tier,
                                  style: const TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                              ),
                              DataCell(
                                Text(
                                  c.submittedAt != null ? dateFormat.format(c.submittedAt!) : 'Not Submitted',
                                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                                ),
                              ),
                              DataCell(_buildTableStatusBadge(c.status)),
                              DataCell(
                                ElevatedButton.icon(
                                  onPressed: () {
                                    showDialog<void>(
                                      context: context,
                                      builder: (ctx) => CustomerDocumentModal(customer: c),
                                    );
                                  },
                                  icon: const Icon(Icons.visibility_outlined, size: 14),
                                  label: const Text('Review Docs', style: TextStyle(fontSize: 12)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF1B3828),
                                    foregroundColor: GVColors.brandGreen,
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  ),
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
  }) {
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      selectedColor: GVColors.brandGreen,
      backgroundColor: const Color(0xFF14241B),
      labelStyle: TextStyle(
        color: isSelected ? Colors.black : Colors.white70,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        fontSize: 11,
      ),
      onSelected: (_) => onSelected(),
    );
  }

  Widget _buildTableStatusBadge(VerificationStatus status) {
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
