import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/branch_staff_models.dart';
import '../../../core/auth/merchant_role.dart';

class BranchesState extends Equatable {
  const BranchesState({
    this.branches = const [],
    this.staffMembers = const [],
    this.isLoading = false,
    this.actionMessage,
  });

  final List<MerchantBranch> branches;
  final List<MerchantStaffMember> staffMembers;
  final bool isLoading;
  final String? actionMessage;

  int get totalActiveBranches => branches.where((b) => b.isActive).length;
  int get totalStaffCount => staffMembers.length;

  BranchesState copyWith({
    List<MerchantBranch>? branches,
    List<MerchantStaffMember>? staffMembers,
    bool? isLoading,
    String? actionMessage,
    bool clearActionMessage = false,
  }) {
    return BranchesState(
      branches: branches ?? this.branches,
      staffMembers: staffMembers ?? this.staffMembers,
      isLoading: isLoading ?? this.isLoading,
      actionMessage: clearActionMessage ? null : (actionMessage ?? this.actionMessage),
    );
  }

  @override
  List<Object?> get props => [branches, staffMembers, isLoading, actionMessage];
}

class BranchesNotifier extends StateNotifier<BranchesState> {
  BranchesNotifier() : super(const BranchesState()) {
    _loadInitialData();
  }

  void _loadInitialData() {
    state = state.copyWith(
      branches: const [
        MerchantBranch(
          id: 'br_lekki_01',
          name: 'Lekki Phase 1 Flagship',
          address: '14 Admiralty Way, Lekki Phase 1',
          zone: 'Lekki / Victoria Island',
          managerName: 'Babatunde Alade',
          phone: '+2348031234567',
          activeOrdersCount: 2,
          isActive: true,
        ),
        MerchantBranch(
          id: 'br_vi_02',
          name: 'Victoria Island Hub',
          address: 'Plot 883, Saka Tinubu Street, VI',
          zone: 'Lagos Island',
          managerName: 'Chiamaka Nnaji',
          phone: '+2348039876543',
          activeOrdersCount: 1,
          isActive: true,
        ),
        MerchantBranch(
          id: 'br_ikeja_03',
          name: 'Ikeja City Mall Express',
          address: 'Shop L24, Ikeja City Mall, Alausa',
          zone: 'Ikeja / Mainland',
          managerName: 'Kayode Fashola',
          phone: '+2348021122339',
          activeOrdersCount: 0,
          isActive: true,
        ),
      ],
      staffMembers: const [
        MerchantStaffMember(
          id: 'stf_001',
          fullName: 'Babatunde Alade',
          email: 'babatunde@mamacass.ng',
          role: MerchantRole.storeOwner,
          assignedBranchIds: ['br_lekki_01', 'br_vi_02', 'br_ikeja_03'],
          status: 'active',
          lastActive: 'Just now',
        ),
        MerchantStaffMember(
          id: 'stf_002',
          fullName: 'Chiamaka Nnaji',
          email: 'chiamaka@mamacass.ng',
          role: MerchantRole.branchManager,
          assignedBranchIds: ['br_vi_02'],
          status: 'active',
          lastActive: '15 mins ago',
        ),
        MerchantStaffMember(
          id: 'stf_003',
          fullName: 'Dayo Adesina',
          email: 'dayo.dispatch@mamacass.ng',
          role: MerchantRole.dispatchAttendant,
          assignedBranchIds: ['br_lekki_01'],
          status: 'active',
          lastActive: '5 mins ago',
        ),
      ],
    );
  }

  void addBranch({
    required String name,
    required String address,
    required String zone,
    required String managerName,
    required String phone,
  }) {
    final count = state.branches.length + 1;
    final newBranch = MerchantBranch(
      id: 'br_branch_${count.toString().padLeft(2, '0')}',
      name: name,
      address: address,
      zone: zone,
      managerName: managerName,
      phone: phone,
      activeOrdersCount: 0,
      isActive: true,
    );

    state = state.copyWith(
      branches: [...state.branches, newBranch],
      actionMessage: 'New branch "$name" successfully registered!',
    );
  }

  void toggleBranchStatus(String branchId) {
    final updated = state.branches.map((b) {
      if (b.id == branchId) {
        return b.copyWith(isActive: !b.isActive);
      }
      return b;
    }).toList();

    state = state.copyWith(
      branches: updated,
      actionMessage: 'Branch operational status updated.',
    );
  }

  void inviteStaffMember({
    required String fullName,
    required String email,
    required MerchantRole role,
    required List<String> branchIds,
  }) {
    final count = state.staffMembers.length + 1;
    final newStaff = MerchantStaffMember(
      id: 'stf_${count.toString().padLeft(3, '0')}',
      fullName: fullName,
      email: email,
      role: role,
      assignedBranchIds: branchIds,
      status: 'invited',
      lastActive: 'Invitation sent',
    );

    state = state.copyWith(
      staffMembers: [...state.staffMembers, newStaff],
      actionMessage: 'Invitation email dispatched to $fullName ($email) as ${role.label}!',
    );
  }

  void inviteStaff({
    required String name,
    required String email,
    required MerchantRole role,
    required String branchId,
    String? branchName,
  }) {
    inviteStaffMember(
      fullName: name,
      email: email,
      role: role,
      branchIds: [branchId],
    );
  }

  void updateStaffRole(String staffId, MerchantRole newRole) {
    final updated = state.staffMembers.map((s) {
      if (s.id == staffId) {
        return s.copyWith(role: newRole);
      }
      return s;
    }).toList();

    state = state.copyWith(
      staffMembers: updated,
      actionMessage: 'Staff permissions updated to ${newRole.label}.',
    );
  }

  void toggleStaffStatus(String staffId) {
    final updated = state.staffMembers.map((s) {
      if (s.id == staffId) {
        final newStatus = s.isActive ? 'suspended' : 'active';
        return s.copyWith(status: newStatus);
      }
      return s;
    }).toList();

    state = state.copyWith(staffMembers: updated);
  }
}

final branchesNotifierProvider =
    StateNotifierProvider<BranchesNotifier, BranchesState>((ref) {
  return BranchesNotifier();
});
