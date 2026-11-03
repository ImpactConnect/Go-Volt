/// Staff roles supported by the Go-Volts platform (§5.1 of Technical Specification).
enum StaffRole {
  opsAgent(
    code: 'ops_agent',
    label: 'Operations Agent',
    description: 'Dispatch, live fleet monitoring, and booking reassignment',
  ),
  safetyOfficer(
    code: 'safety_officer',
    label: 'Safety Officer',
    description: 'Incident investigation, rider safeguarding, and chaperone audit',
  ),
  finance(
    code: 'finance',
    label: 'Finance Officer',
    description: 'Refunds, ledger settlements, payouts, and maker-checker approvals',
  ),
  promotionsManager(
    code: 'promotions_manager',
    label: 'Promotions Manager',
    description: 'Coupons, loyalty points, and referral campaign management',
  ),
  admin(
    code: 'admin',
    label: 'Operations Admin',
    description: 'Full operational administration across dispatch, fleet, and pricing',
  ),
  superAdmin(
    code: 'super_admin',
    label: 'Super Admin',
    description: 'Unrestricted system access, integrations, and audit logs',
  );

  const StaffRole({
    required this.code,
    required this.label,
    required this.description,
  });

  final String code;
  final String label;
  final String description;

  /// Check if the role can access Live Operations & Bookings.
  bool get canAccessOperations => true;

  /// Check if the role can access Market Errand Shopping Supervision.
  bool get canAccessErrands => true;

  /// Check if the role can access Scheduled Commute & School-Run Command Desk.
  bool get canAccessScheduled =>
      this == StaffRole.opsAgent ||
      this == StaffRole.safetyOfficer ||
      this == StaffRole.admin ||
      this == StaffRole.superAdmin;

  /// Check if the role can access Rider Onboarding & Compliance Review.
  bool get canAccessRiders =>
      this == StaffRole.opsAgent ||
      this == StaffRole.safetyOfficer ||
      this == StaffRole.admin ||
      this == StaffRole.superAdmin;

  /// Check if the role can access Customer Accounts & Identity Verification.
  bool get canAccessCustomers =>
      this == StaffRole.opsAgent ||
      this == StaffRole.safetyOfficer ||
      this == StaffRole.admin ||
      this == StaffRole.superAdmin;

  /// Check if the role can access Pricing Rules & Service Area Toggles.
  bool get canAccessPricing =>
      this == StaffRole.admin ||
      this == StaffRole.superAdmin;

  /// Check if the role can access Promotions & Coupons.
  bool get canAccessPromotions =>
      this == StaffRole.promotionsManager ||
      this == StaffRole.admin ||
      this == StaffRole.superAdmin;

  /// Check if the role can access Finance, Refunds & Payouts.
  bool get canAccessFinance =>
      this == StaffRole.finance ||
      this == StaffRole.superAdmin;

  /// Check if the role can view Confidential Safety Incidents.
  bool get canAccessSafety =>
      this == StaffRole.safetyOfficer ||
      this == StaffRole.admin ||
      this == StaffRole.superAdmin;

  /// Check if the role can access Tamper-Evident Audit Logs.
  bool get canAccessAudit =>
      this == StaffRole.admin ||
      this == StaffRole.superAdmin;

  /// Check if the role can access Emergency SOS Rapid Dispatch Desk.
  bool get canAccessSafetySos =>
      this == StaffRole.safetyOfficer ||
      this == StaffRole.opsAgent ||
      this == StaffRole.admin ||
      this == StaffRole.superAdmin;

  /// Check if the role can access EV Battery Swap & Telematics Station Desk.
  bool get canAccessBatterySwap =>
      this == StaffRole.opsAgent ||
      this == StaffRole.admin ||
      this == StaffRole.superAdmin ||
      this == StaffRole.finance;

  /// Check if the role can manage Partner Integrations (Retail Ai).
  bool get canAccessIntegrations =>
      this == StaffRole.admin ||
      this == StaffRole.superAdmin;
}
