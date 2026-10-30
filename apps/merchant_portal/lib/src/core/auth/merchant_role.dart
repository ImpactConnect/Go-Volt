enum MerchantRole {
  storeOwner,
  branchManager,
  dispatchAttendant;

  String get label {
    switch (this) {
      case MerchantRole.storeOwner:
        return 'Store Owner';
      case MerchantRole.branchManager:
        return 'Branch Manager';
      case MerchantRole.dispatchAttendant:
        return 'Dispatch Attendant';
    }
  }

  bool get canManageBranches => this == MerchantRole.storeOwner;
  bool get canCreateBranches => canManageBranches;
  bool get canManageStaff => this == MerchantRole.storeOwner || this == MerchantRole.branchManager;
  bool get canViewBilling => this == MerchantRole.storeOwner;
  bool get canAccessDeveloperApi => this == MerchantRole.storeOwner;
  bool get canCreateDeliveries => true; // All roles can dispatch orders
  bool get canCancelDeliveries => this == MerchantRole.storeOwner || this == MerchantRole.branchManager;
  bool get canCancelBookings => canCancelDeliveries;
  bool get canSwitchAllBranches => this == MerchantRole.storeOwner;
  bool get canSwitchBranches => canSwitchAllBranches;
}
