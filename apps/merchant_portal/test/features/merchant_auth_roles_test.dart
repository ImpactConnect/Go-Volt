import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_portal/src/core/auth/merchant_auth_notifier.dart';
import 'package:merchant_portal/src/core/auth/merchant_role.dart';

void main() {
  group('Phase 4: Merchant Role-Based Access Control (RBAC)', () {
    test('storeOwner has full organizational and billing access', () {
      const role = MerchantRole.storeOwner;

      expect(role.canManageStaff, isTrue);
      expect(role.canCreateBranches, isTrue);
      expect(role.canViewBilling, isTrue);
      expect(role.canAccessDeveloperApi, isTrue);
      expect(role.canSwitchBranches, isTrue);
      expect(role.canCancelBookings, isTrue);
      expect(role.label, 'Store Owner');
    });

    test('branchManager has operational staff management but no billing access', () {
      const role = MerchantRole.branchManager;

      expect(role.canManageStaff, isTrue);
      expect(role.canCreateBranches, isFalse);
      expect(role.canViewBilling, isFalse);
      expect(role.canAccessDeveloperApi, isFalse);
      expect(role.canSwitchBranches, isFalse);
      expect(role.canCancelBookings, isTrue);
      expect(role.label, 'Branch Manager');
    });

    test('dispatchAttendant has dispatch-only operational scope', () {
      const role = MerchantRole.dispatchAttendant;

      expect(role.canManageStaff, isFalse);
      expect(role.canCreateBranches, isFalse);
      expect(role.canViewBilling, isFalse);
      expect(role.canAccessDeveloperApi, isFalse);
      expect(role.canSwitchBranches, isFalse);
      expect(role.canCancelBookings, isFalse);
      expect(role.label, 'Dispatch Attendant');
    });

    test('MerchantAuthNotifier supports branch switching and role simulation', () {
      final notifier = MerchantAuthNotifier();

      expect(notifier.state.activeBranchId, 'br_lekki_01');
      expect(notifier.state.role, MerchantRole.storeOwner);

      // Switch to Victoria Island
      notifier.switchBranch(branchId: 'br_vi_02', branchName: 'Victoria Island Hub');
      expect(notifier.state.activeBranchId, 'br_vi_02');
      expect(notifier.state.activeBranchName, 'Victoria Island Hub');

      // Switch role to branch manager
      notifier.switchRole(MerchantRole.branchManager);
      expect(notifier.state.role, MerchantRole.branchManager);
      expect(notifier.state.role.canViewBilling, isFalse);

      // Top up corporate balance
      final oldBalance = notifier.state.walletBalanceKobo;
      notifier.topUpWalletBalance(10000000); // +₦100,000
      expect(notifier.state.walletBalanceKobo, oldBalance + 10000000);
      expect(notifier.state.formattedWalletBalance, contains('₦'));
    });
  });
}
