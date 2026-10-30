import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_portal/src/core/auth/merchant_role.dart';
import 'package:merchant_portal/src/features/branches/application/branches_notifier.dart';

void main() {
  group('Phase 4: Merchant Multi-Branch & Staff Delegation', () {
    test('initializes with seed branches across Lagos hubs', () {
      final notifier = BranchesNotifier();

      expect(notifier.state.branches.length, 3);
      expect(
        notifier.state.branches.map((b) => b.name),
        containsAll([
          'Lekki Phase 1 Flagship',
          'Victoria Island Hub',
          'Ikeja City Mall Express',
        ]),
      );
      expect(notifier.state.staffMembers, isNotEmpty);
    });

    test('registers a new branch with operational zone and assigned manager', () {
      final notifier = BranchesNotifier();
      final initialCount = notifier.state.branches.length;

      notifier.addBranch(
        name: 'Maryland Mall Express',
        address: 'Maryland Mall, Ikorodu Road, Lagos',
        zone: 'Ikeja / Mainland',
        managerName: 'Chidi Mokeme',
        phone: '+2348033333333',
      );

      expect(notifier.state.branches.length, initialCount + 1);
      final newBranch = notifier.state.branches.last;
      expect(newBranch.name, 'Maryland Mall Express');
      expect(newBranch.zone, 'Ikeja / Mainland');
      expect(newBranch.isActive, isTrue);
      expect(notifier.state.actionMessage, contains('Maryland Mall Express'));
    });

    test('toggles branch active status', () {
      final notifier = BranchesNotifier();
      final targetBranch = notifier.state.branches.first;
      final initialStatus = targetBranch.isActive;

      notifier.toggleBranchStatus(targetBranch.id);
      final updated = notifier.state.branches.firstWhere((b) => b.id == targetBranch.id);
      expect(updated.isActive, !initialStatus);

      // Toggle back
      notifier.toggleBranchStatus(targetBranch.id);
      final reverted = notifier.state.branches.firstWhere((b) => b.id == targetBranch.id);
      expect(reverted.isActive, initialStatus);
    });

    test('invites new staff member and delegates role', () {
      final notifier = BranchesNotifier();
      final initialStaffCount = notifier.state.staffMembers.length;

      notifier.inviteStaff(
        name: 'Grace Bassey',
        email: 'grace.bassey@mamacass.ng',
        role: MerchantRole.dispatchAttendant,
        branchId: 'br_lekki_01',
        branchName: 'Lekki Phase 1 Flagship',
      );

      expect(notifier.state.staffMembers.length, initialStaffCount + 1);
      final newStaff = notifier.state.staffMembers.last;
      expect(newStaff.name, 'Grace Bassey');
      expect(newStaff.role, MerchantRole.dispatchAttendant);
      expect(newStaff.branchId, 'br_lekki_01');
      expect(newStaff.isActive, isTrue);
      expect(notifier.state.actionMessage, contains('Grace Bassey'));
    });

    test('promotes staff role and toggles operational status', () {
      final notifier = BranchesNotifier();
      final staff = notifier.state.staffMembers.first;

      // Update role to branchManager
      notifier.updateStaffRole(staff.id, MerchantRole.branchManager);
      final updatedRoleStaff =
          notifier.state.staffMembers.firstWhere((s) => s.id == staff.id);
      expect(updatedRoleStaff.role, MerchantRole.branchManager);

      // Deactivate staff member
      notifier.toggleStaffStatus(staff.id);
      final deactivatedStaff =
          notifier.state.staffMembers.firstWhere((s) => s.id == staff.id);
      expect(deactivatedStaff.isActive, !staff.isActive);
    });
  });
}
