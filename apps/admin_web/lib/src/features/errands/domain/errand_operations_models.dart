import 'package:equatable/equatable.dart';

/// Errand item substitution or receipt dispute model (§1975-2004).
class ErrandDisputeModel extends Equatable {
  const ErrandDisputeModel({
    required this.id,
    required this.errandId,
    required this.referenceNumber,
    required this.customerName,
    required this.customerPhone,
    required this.shopperName,
    required this.shopperPhone,
    required this.shopName,
    required this.disputeReason,
    this.customerNote,
    this.shopperReceiptUrl,
    required this.budgetedAmountKobo,
    required this.actualReceiptKobo,
    required this.differenceKobo,
    this.status = 'PENDING_REVIEW', // PENDING_REVIEW, RESOLVED_REFUND, RESOLVED_CHARGE, REJECTED
    this.resolutionNotes,
    this.resolvedBy,
    this.resolvedAt,
  });

  final String id;
  final String errandId;
  final String referenceNumber;
  final String customerName;
  final String customerPhone;
  final String shopperName;
  final String shopperPhone;
  final String shopName;
  final String disputeReason;
  final String? customerNote;
  final String? shopperReceiptUrl;
  final int budgetedAmountKobo;
  final int actualReceiptKobo;
  final int differenceKobo;
  final String status;
  final String? resolutionNotes;
  final String? resolvedBy;
  final DateTime? resolvedAt;

  double get budgetedAmountNgn => budgetedAmountKobo / 100.0;
  double get actualReceiptNgn => actualReceiptKobo / 100.0;
  double get differenceNgn => differenceKobo / 100.0;

  bool get isResolved =>
      status == 'RESOLVED_REFUND' ||
      status == 'RESOLVED_CHARGE' ||
      status == 'REJECTED';

  ErrandDisputeModel copyWith({
    String? id,
    String? errandId,
    String? referenceNumber,
    String? customerName,
    String? customerPhone,
    String? shopperName,
    String? shopperPhone,
    String? shopName,
    String? disputeReason,
    String? customerNote,
    String? shopperReceiptUrl,
    int? budgetedAmountKobo,
    int? actualReceiptKobo,
    int? differenceKobo,
    String? status,
    String? resolutionNotes,
    String? resolvedBy,
    DateTime? resolvedAt,
  }) {
    return ErrandDisputeModel(
      id: id ?? this.id,
      errandId: errandId ?? this.errandId,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      shopperName: shopperName ?? this.shopperName,
      shopperPhone: shopperPhone ?? this.shopperPhone,
      shopName: shopName ?? this.shopName,
      disputeReason: disputeReason ?? this.disputeReason,
      customerNote: customerNote ?? this.customerNote,
      shopperReceiptUrl: shopperReceiptUrl ?? this.shopperReceiptUrl,
      budgetedAmountKobo: budgetedAmountKobo ?? this.budgetedAmountKobo,
      actualReceiptKobo: actualReceiptKobo ?? this.actualReceiptKobo,
      differenceKobo: differenceKobo ?? this.differenceKobo,
      status: status ?? this.status,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        errandId,
        referenceNumber,
        customerName,
        shopperName,
        status,
        differenceKobo,
        resolvedAt,
      ];
}

/// Price reconciliation record between budgeted errand cost and physical receipt.
class ErrandReconciliationModel extends Equatable {
  const ErrandReconciliationModel({
    required this.id,
    required this.errandId,
    required this.referenceNumber,
    required this.customerId,
    required this.customerName,
    required this.shopperName,
    required this.shopName,
    required this.budgetedKobo,
    required this.actualKobo,
    required this.differenceKobo,
    required this.type, // 'REFUND_CUSTOMER', 'CHARGE_CUSTOMER', 'BALANCED'
    this.status = 'PENDING', // 'PENDING', 'MAKER_APPROVED', 'CHECKER_APPROVED', 'REJECTED'
    this.makerStaffName,
    this.checkerStaffName,
    this.makerNotes,
    required this.createdAt,
    this.approvedAt,
  });

  final String id;
  final String errandId;
  final String referenceNumber;
  final String customerId;
  final String customerName;
  final String shopperName;
  final String shopName;
  final int budgetedKobo;
  final int actualKobo;
  final int differenceKobo;
  final String type;
  final String status;
  final String? makerStaffName;
  final String? checkerStaffName;
  final String? makerNotes;
  final DateTime createdAt;
  final DateTime? approvedAt;

  double get budgetedNgn => budgetedKobo / 100.0;
  double get actualNgn => actualKobo / 100.0;
  double get differenceNgn => differenceKobo.abs() / 100.0;

  /// High value reconciliation threshold: > ₦10,000 (1,000,000 kobo) requires dual maker-checker signoff.
  bool get needsDualApproval => differenceKobo.abs() > 1000000;

  bool get isApproved =>
      status == 'CHECKER_APPROVED' ||
      (!needsDualApproval && status == 'MAKER_APPROVED');

  ErrandReconciliationModel copyWith({
    String? id,
    String? errandId,
    String? referenceNumber,
    String? customerId,
    String? customerName,
    String? shopperName,
    String? shopName,
    int? budgetedKobo,
    int? actualKobo,
    int? differenceKobo,
    String? type,
    String? status,
    String? makerStaffName,
    String? checkerStaffName,
    String? makerNotes,
    DateTime? createdAt,
    DateTime? approvedAt,
  }) {
    return ErrandReconciliationModel(
      id: id ?? this.id,
      errandId: errandId ?? this.errandId,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      shopperName: shopperName ?? this.shopperName,
      shopName: shopName ?? this.shopName,
      budgetedKobo: budgetedKobo ?? this.budgetedKobo,
      actualKobo: actualKobo ?? this.actualKobo,
      differenceKobo: differenceKobo ?? this.differenceKobo,
      type: type ?? this.type,
      status: status ?? this.status,
      makerStaffName: makerStaffName ?? this.makerStaffName,
      checkerStaffName: checkerStaffName ?? this.checkerStaffName,
      makerNotes: makerNotes ?? this.makerNotes,
      createdAt: createdAt ?? this.createdAt,
      approvedAt: approvedAt ?? this.approvedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        errandId,
        referenceNumber,
        customerName,
        budgetedKobo,
        actualKobo,
        differenceKobo,
        status,
        makerStaffName,
        checkerStaffName,
      ];
}
