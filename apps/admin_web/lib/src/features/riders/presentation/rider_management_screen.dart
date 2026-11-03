import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/admin_kpi_card.dart';
import '../application/rider_management_notifier.dart';
import '../domain/rider_management_state.dart';
import 'widgets/rider_document_modal.dart';

class RiderManagementScreen extends ConsumerWidget {
  const RiderManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(riderManagementNotifierProvider);
    final notifier = ref.read(riderManagementNotifierProvider.notifier);
    final filtered = state.filteredRiders;

    return Scaffold(
      backgroundColor: const Color(0xFF0C120F),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(GVSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Page Header
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rider Compliance & Fleet Review',
                  style: GVTypography.h1.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  'Inspect regulatory documents, certify service capabilities, and manage fleet compliance',
                  style: GVTypography.bodyMedium.copyWith(color: Colors.white70),
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
                      value: '${state.riders.length}',
                      icon: Icons.people_outline,
                      subtitle: 'Lagos Fleet Registry',
                    ),
                    AdminKpiCard(
                      title: 'Pending Review',
                      value: '${state.pendingCount}',
                      icon: Icons.pending_actions,
                      subtitle: 'Awaiting Document Audit',
                      iconColor: Colors.amber,
                      badgeLabel: 'Audit',
                    ),
                    AdminKpiCard(
                      title: 'Certified Active',
                      value: '${state.approvedCount}',
                      icon: Icons.verified_user_outlined,
                      subtitle: 'Dispatched & Eligible',
                      isPositive: true,
                    ),
                    AdminKpiCard(
                      title: 'Suspended Riders',
                      value: '${state.suspendedCount}',
                      icon: Icons.block,
                      subtitle: 'Compliance Lockout',
                      iconColor: Colors.redAccent,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: GVSpacing.lg),

            // Filter & Search Container
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFF141C18),
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                border: Border.all(color: const Color(0xFF223028)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search rider by name, phone (+234...), or vehicle plate...',
                        prefixIcon: const Icon(Icons.search, color: Colors.white60),
                        fillColor: const Color(0xFF1A2620),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: notifier.setSearchQuery,
                    ),
                  ),
                  const SizedBox(width: GVSpacing.md),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2620),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF2D3E33)),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: state.selectedStatusFilter,
                        dropdownColor: const Color(0xFF1A2620),
                        style: const TextStyle(color: Colors.white),
                        items: const [
                          DropdownMenuItem(value: 'ALL', child: Text('All Statuses')),
                          DropdownMenuItem(value: 'pendingReview', child: Text('Pending Review')),
                          DropdownMenuItem(value: 'approved', child: Text('Certified Active')),
                          DropdownMenuItem(value: 'suspended', child: Text('Suspended')),
                        ],
                        onChanged: (val) {
                          if (val != null) notifier.setStatusFilter(val);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.lg),

            // Riders Table
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF141C18),
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                border: Border.all(color: const Color(0xFF223028)),
              ),
              child: filtered.isEmpty
                  ? const Padding(
                      padding: EdgeInsets.all(48),
                      child: Center(
                        child: Text(
                          'No riders or applicants found matching current filters.',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Applicant / Rider')),
                    DataColumn(label: Text('Vehicle Specs')),
                    DataColumn(label: Text('Battery Health')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Certified Tiers')),
                    DataColumn(label: Text('Trips / Rating')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: filtered.map((r) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: GVColors.deepGreen,
                                child: Text(r.fullName.substring(0, 1), style: const TextStyle(color: Colors.white)),
                              ),
                              const SizedBox(width: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(r.fullName, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                                  Text(r.phone, style: GVTypography.caption.copyWith(color: Colors.white54)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        DataCell(Text('${r.vehicleClass}\n${r.vehiclePlate}')),
                        DataCell(
                          Row(
                            children: [
                              const Icon(Icons.battery_charging_full, size: 16, color: GVColors.brandGreen),
                              const SizedBox(width: 4),
                              Text('${r.batteryHealthPercent}% (${r.batteryCapacity})'),
                            ],
                          ),
                        ),
                        DataCell(
                          GVStatusChip(
                            label: r.status.label.toUpperCase(),
                            status: r.status == RiderComplianceStatus.approved
                                ? GVStatusType.active
                                : (r.status == RiderComplianceStatus.suspended
                                    ? GVStatusType.delayed
                                    : GVStatusType.pending),
                          ),
                        ),
                        DataCell(
                          Text('${r.certifiedTiers.length} Active Tiers'),
                        ),
                        DataCell(
                          Text('${r.completedTrips} trips · ⭐ ${r.ratingAverage > 0 ? r.ratingAverage : "New"}'),
                        ),
                        DataCell(
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: GVColors.brandGreen,
                              foregroundColor: GVColors.nearBlack,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              minimumSize: Size.zero,
                            ),
                            onPressed: () {
                              showDialog<void>(
                                context: context,
                                builder: (_) => RiderDocumentModal(
                                  rider: r,
                                  notifier: notifier,
                                ),
                              );
                            },
                            child: const Text('Review Docs'),
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
}
