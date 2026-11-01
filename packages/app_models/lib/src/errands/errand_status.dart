/// Complete errand lifecycle status domain (v1.6 §1873-1905).
enum ErrandStatus {
  draft('DRAFT', 'Draft'),
  submitted('SUBMITTED', 'Submitted'),
  reviewRequired('REVIEW_REQUIRED', 'Under Review'),
  quoted('QUOTED', 'Quote Available'),
  awaitingCustomerAcceptance('AWAITING_CUSTOMER_ACCEPTANCE', 'Awaiting Acceptance'),
  awaitingPayment('AWAITING_PAYMENT', 'Awaiting Payment'),
  paymentPending('PAYMENT_PENDING', 'Payment Pending'),
  paymentVerified('PAYMENT_VERIFIED', 'Payment Confirmed'),
  searchingForAgent('SEARCHING_FOR_AGENT', 'Searching for Rider'),
  agentAssigned('AGENT_ASSIGNED', 'Rider Assigned'),
  agentAccepted('AGENT_ACCEPTED', 'Rider Accepted'),
  shoppingInProgress('SHOPPING_IN_PROGRESS', 'Shopping in Progress'),
  itemsPurchased('ITEMS_PURCHASED', 'Items Purchased'),
  inProgress('IN_PROGRESS', 'Task in Progress'),
  outForDelivery('OUT_FOR_DELIVERY', 'Out for Delivery'),
  delivered('DELIVERED', 'Delivered'),
  completed('COMPLETED', 'Completed'),
  rejected('REJECTED', 'Rejected'),
  cancelled('CANCELLED', 'Cancelled'),
  paymentFailed('PAYMENT_FAILED', 'Payment Failed'),
  assignmentFailed('ASSIGNMENT_FAILED', 'Assignment Failed'),
  onHold('ON_HOLD', 'On Hold'),
  issueReported('ISSUE_REPORTED', 'Issue Reported'),
  refundPending('REFUND_PENDING', 'Refund Pending'),
  refundInitiated('REFUND_INITIATED', 'Refund Initiated'),
  refunded('REFUNDED', 'Refunded');

  const ErrandStatus(this.code, this.label);

  final String code;
  final String label;

  static ErrandStatus fromString(String? raw) {
    if (raw == null) return ErrandStatus.draft;
    final normalized = raw.trim().toUpperCase();
    return ErrandStatus.values.firstWhere(
      (s) => s.code == normalized || s.name.toUpperCase() == normalized,
      orElse: () => ErrandStatus.draft,
    );
  }

  bool get isTerminal =>
      this == ErrandStatus.completed ||
      this == ErrandStatus.cancelled ||
      this == ErrandStatus.rejected ||
      this == ErrandStatus.refunded;

  bool get isActive => !isTerminal && this != ErrandStatus.draft;

  bool get canCancel =>
      this == ErrandStatus.submitted ||
      this == ErrandStatus.reviewRequired ||
      this == ErrandStatus.quoted ||
      this == ErrandStatus.awaitingCustomerAcceptance ||
      this == ErrandStatus.awaitingPayment ||
      this == ErrandStatus.searchingForAgent;
}

