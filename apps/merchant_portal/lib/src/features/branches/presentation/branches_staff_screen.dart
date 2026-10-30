import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/branches_notifier.dart';
import '../../../core/auth/merchant_role.dart';
import '../../../core/widgets/merchant_kpi_card.dart';
import '../../../core/widgets/merchant_modal_dialog.dart';

class BranchesStaffScreen extends ConsumerWidget {
  const BranchesStaffScreen({super.key});

  void _showAddBranchModal(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final managerController = TextEditingController();
    final phoneController = TextEditingController();
    String selectedZone = 'Lekki / Victoria Island';

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return MerchantModalDialog(
              title: 'Register New Store Branch',
              subtitle: 'Add operational dispatch location in Lagos',
              icon: Icons.storefront,
              primaryActionLabel: 'Register Branch',
              onPrimaryAction: () {
                if (nameController.text.trim().isEmpty || addressController.text.trim().isEmpty) return;
                ref.read(branchesNotifierProvider.notifier).addBranch(
                      name: nameController.text.trim(),
                      address: addressController.text.trim(),
                      zone: selectedZone,
                      managerName: managerController.text.trim().isEmpty ? 'Pending' : managerController.text.trim(),
                      phone: phoneController.text.trim().isEmpty ? '+2348000000000' : phoneController.text.trim(),
                    );
                Navigator.of(ctx).pop();
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Branch Name *', hintText: 'e.g., Yaba Tech Hub Outlet'),
                  ),
                  const SizedBox(height: GVSpacing.md),
                  TextField(
                    controller: addressController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Street Address *', hintText: 'e.g., 290 Herbert Macaulay Way'),
                  ),
                  const SizedBox(height: GVSpacing.md),
                  DropdownButtonFormField<String>(
                    initialValue: selectedZone,
                    dropdownColor: const Color(0xFF1B241F),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Lagos Zone *'),
                    items: const [
                      DropdownMenuItem(value: 'Lekki / Victoria Island', child: Text('Lekki / Victoria Island')),
                      DropdownMenuItem(value: 'Lagos Island', child: Text('Lagos Island / Ikoyi')),
                      DropdownMenuItem(value: 'Ikeja / Mainland', child: Text('Ikeja / Mainland')),
                    ],
                    onChanged: (val) {
                      if (val != null) setState(() => selectedZone = val);
                    },
                  ),
                  const SizedBox(height: GVSpacing.md),
                  TextField(
                    controller: managerController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Branch Manager Name', hintText: 'e.g., Tolu Ojo'),
                  ),
                  const SizedBox(height: GVSpacing.md),
                  TextField(
                    controller: phoneController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Contact Phone Number', hintText: '+234...'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showInviteStaffModal(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    MerchantRole selectedRole = MerchantRole.dispatchAttendant;

    showDialog<void>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return MerchantModalDialog(
              title: 'Invite Staff Member',
              subtitle: 'Send access invitation with delegated role',
              icon: Icons.person_add_alt_1,
              primaryActionLabel: 'Send Invitation',
              onPrimaryAction: () {
                if (nameController.text.trim().isEmpty || emailController.text.trim().isEmpty) return;
                ref.read(branchesNotifierProvider.notifier).inviteStaffMember(
                      fullName: nameController.text.trim(),
                      email: emailController.text.trim(),
                      role: selectedRole,
                      branchIds: ['br_lekki_01'],
                    );
                Navigator.of(ctx).pop();
              },
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Staff Full Name *'),
                  ),
                  const SizedBox(height: GVSpacing.md),
                  TextField(
                    controller: emailController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Corporate Email *'),
                  ),
                  const SizedBox(height: GVSpacing.md),
                  DropdownButtonFormField<MerchantRole>(
                    initialValue: selectedRole,
                    dropdownColor: const Color(0xFF1B241F),
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(labelText: 'Delegated Role *'),
                    items: MerchantRole.values.map((r) {
                      return DropdownMenuItem(value: r, child: Text(r.label));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedRole = val);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(branchesNotifierProvider);
    final notifier = ref.read(branchesNotifierProvider.notifier);

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
                        'Branches & Staff Delegation',
                        style: GVTypography.h1.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage store branch locations, operational addresses, and authorized staff roles',
                        style: GVTypography.bodyMedium.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: GVSpacing.md),
                Wrap(
                  spacing: 12,
                  children: [
                    OutlinedButton.icon(
                      key: const Key('invite_staff_btn'),
                      onPressed: () => _showInviteStaffModal(context, ref),
                      icon: const Icon(Icons.person_add, size: 18),
                      label: const Text('Invite Staff'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Color(0xFF2A3D32)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      ),
                    ),
                    ElevatedButton.icon(
                      key: const Key('add_branch_btn'),
                      onPressed: () => _showAddBranchModal(context, ref),
                      icon: const Icon(Icons.add_business, size: 18),
                      label: const Text('Register Branch'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GVColors.brandGreen,
                        foregroundColor: GVColors.nearBlack,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: GVSpacing.lg),

            // Action Banner
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
            Row(
              children: [
                Expanded(
                  child: MerchantKpiCard(
                    title: 'Active Branches',
                    value: '${state.totalActiveBranches}',
                    icon: Icons.storefront,
                    subtitle: 'Operational Lagos Dispatch Hubs',
                    accentColor: GVColors.brandGreen,
                  ),
                ),
                const SizedBox(width: GVSpacing.md),
                Expanded(
                  child: MerchantKpiCard(
                    title: 'Authorized Staff',
                    value: '${state.totalStaffCount}',
                    icon: Icons.badge_outlined,
                    subtitle: 'Store Owners, Managers, Attendants',
                    accentColor: Colors.blueAccent,
                  ),
                ),
                const SizedBox(width: GVSpacing.md),
                const Expanded(
                  child: MerchantKpiCard(
                    title: 'Coverage Zones',
                    value: '3 Zones',
                    icon: Icons.map_outlined,
                    subtitle: 'Lekki/VI, Lagos Island, Mainland',
                    accentColor: Colors.purpleAccent,
                  ),
                ),
              ],
            ),

            const SizedBox(height: GVSpacing.xl),

            // Branch Locations Section
            Text('REGISTERED STORE BRANCHES',
                style: GVTypography.caption.copyWith(color: Colors.white60, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
            const SizedBox(height: GVSpacing.md),

            LayoutBuilder(
              builder: (ctx, constraints) {
                final isWide = constraints.maxWidth > 800;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: isWide ? 3 : 1,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 1.8,
                  ),
                  itemCount: state.branches.length,
                  itemBuilder: (context, i) {
                    final branch = state.branches[i];
                    return Container(
                      padding: const EdgeInsets.all(GVSpacing.md),
                      decoration: BoxDecoration(
                        color: const Color(0xFF141C18),
                        borderRadius: BorderRadius.circular(GVBorderRadius.md),
                        border: Border.all(
                          color: branch.isActive ? const Color(0xFF223028) : Colors.redAccent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  branch.name,
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Switch(
                                value: branch.isActive,
                                activeThumbColor: GVColors.brandGreen,
                                onChanged: (_) => notifier.toggleBranchStatus(branch.id),
                              ),
                            ],
                          ),
                          Text(branch.address, style: GVTypography.caption.copyWith(color: Colors.white70)),
                          Text('Zone: ${branch.zone}', style: GVTypography.caption.copyWith(color: GVColors.brandGreen)),
                          const Divider(color: Color(0xFF1E2B23), height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Mgr: ${branch.managerName}', style: GVTypography.caption.copyWith(color: Colors.white54)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: GVColors.brandGreen.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  '${branch.activeOrdersCount} Active Deliveries',
                                  style: const TextStyle(color: GVColors.brandGreen, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),

            const SizedBox(height: GVSpacing.xl),

            // Staff Delegation Table
            Text('AUTHORIZED PERSONNEL & ROLE DELEGATION',
                style: GVTypography.caption.copyWith(color: Colors.white60, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
            const SizedBox(height: GVSpacing.md),

            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF141C18),
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                border: Border.all(color: const Color(0xFF223028)),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: const [
                    DataColumn(label: Text('Staff Member')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Role Privilege')),
                    DataColumn(label: Text('Branch Scopes')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Last Active')),
                  ],
                  rows: state.staffMembers.map((s) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 14,
                                backgroundColor: const Color(0xFF223328),
                                child: Text(s.fullName[0], style: const TextStyle(color: GVColors.brandGreen)),
                              ),
                              const SizedBox(width: 8),
                              Text(s.fullName, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        DataCell(Text(s.email)),
                        DataCell(
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B2920),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(color: const Color(0xFF2D4235)),
                            ),
                            child: Text(s.role.label, style: const TextStyle(color: Colors.white, fontSize: 12)),
                          ),
                        ),
                        DataCell(Text('${s.assignedBranchIds.length} Assigned Branch(es)')),
                        DataCell(
                          GVStatusChip(
                            label: s.status.toUpperCase(),
                            status: s.status == 'active' ? GVStatusType.active : GVStatusType.pending,
                          ),
                        ),
                        DataCell(Text(s.lastActive, style: GVTypography.caption.copyWith(color: Colors.white54))),
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
