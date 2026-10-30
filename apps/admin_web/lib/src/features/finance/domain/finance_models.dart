import 'package:equatable/equatable.dart';

enum RefundStatus {
  pendingReview, // For < ₦10,000 awaiting single sign-off
  pendingCheckerSignoff, // For >= ₦10,000 maker signed off, checker required
  approved,
  rejected,
}

class RefundRequestModel extends Equatable {
  const RefundRequestModel({
    required this.id,
    required this.bookingRef,
    required this.customerName,
    required this.amountKobo,
    required this.reason,
    required this.makerId,
    required this.makerName,
    required this.makerTimestamp,
    required this.status,
    this.checkerId,
    this.checkerName,
    this.checkerTimestamp,
    this.rejectionReason,
  });

  final String id;
  final String bookingRef;
  final String customerName;
  final BigInt amountKobo;
  final String reason;
  final String makerId;
  final String makerName;
  final DateTime makerTimestamp;
  final RefundStatus status;
  final String? checkerId;
  final String? checkerName;
  final DateTime? checkerTimestamp;
  final String? rejectionReason;

  /// Maker-checker rule: Refunds >= ₦10,000 (1,000,000 kobo) require dual approval (§6.8).
  static final BigInt dualApprovalThresholdKobo = BigInt.from(1000000); // ₦10,000

  bool get requiresMakerChecker => amountKobo >= dualApprovalThresholdKobo;

  String get formattedAmount => '₦${(amountKobo / BigInt.from(100)).toStringAsFixed(2)}';

  RefundRequestModel copyWith({
    String? id,
    String? bookingRef,
    String? customerName,
    BigInt? amountKobo,
    String? reason,
    String? makerId,
    String? makerName,
    DateTime? makerTimestamp,
    RefundStatus? status,
    String? checkerId,
    String? checkerName,
    DateTime? checkerTimestamp,
    String? rejectionReason,
  }) {
    return RefundRequestModel(
      id: id ?? this.id,
      bookingRef: bookingRef ?? this.bookingRef,
      customerName: customerName ?? this.customerName,
      amountKobo: amountKobo ?? this.amountKobo,
      reason: reason ?? this.reason,
      makerId: makerId ?? this.makerId,
      makerName: makerName ?? this.makerName,
      makerTimestamp: makerTimestamp ?? this.makerTimestamp,
      status: status ?? this.status,
      checkerId: checkerId ?? this.checkerId,
      checkerName: checkerName ?? this.checkerName,
      checkerTimestamp: checkerTimestamp ?? this.checkerTimestamp,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  @override
  List<Object?> get props => [
        id,
        bookingRef,
        customerName,
        amountKobo,
        reason,
        makerId,
        makerName,
        makerTimestamp,
        status,
        checkerId,
        checkerName,
        checkerTimestamp,
        rejectionReason,
      ];
}

class PayoutBatchModel extends Equatable {
  const PayoutBatchModel({
    required this.batchId,
    required this.period,
    required this.totalRiders,
    required this.totalAmountKobo,
    required this.status,
    required this.generatedAt,
    this.settledAt,
  });

  final String batchId;
  final String period;
  final int totalRiders;
  final BigInt totalAmountKobo;
  final String status; // 'pending_payout', 'settled', 'processing'
  final DateTime generatedAt;
  final DateTime? settledAt;

  String get formattedTotal => '₦${(totalAmountKobo / BigInt.from(100)).toStringAsFixed(0)}';

  PayoutBatchModel copyWith({
    String? batchId,
    String? period,
    int? totalRiders,
    BigInt? totalAmountKobo,
    String? status,
    DateTime? generatedAt,
    DateTime? settledAt,
  }) {
    return PayoutBatchModel(
      batchId: batchId ?? this.batchId,
      period: period ?? this.period,
      totalRiders: totalRiders ?? this.totalRiders,
      totalAmountKobo: totalAmountKobo ?? this.totalAmountKobo,
      status: status ?? this.status,
      generatedAt: generatedAt ?? this.generatedAt,
      settledAt: settledAt ?? this.settledAt,
    );
  }

  @override
  List<Object?> get props => [
        batchId,
        period,
        totalRiders,
        totalAmountKobo,
        status,
        generatedAt,
        settledAt,
      ];
}

class FinancialLedgerSummary extends Equatable {
  const FinancialLedgerSummary({
    required this.grossGmvKobo,
    required this.netPlatformRevenueKobo,
    required this.totalRiderEarningsKobo,
    required this.pendingRefundsKobo,
    required this.settlementDate,
  });

  final BigInt grossGmvKobo;
  final BigInt netPlatformRevenueKobo;
  final BigInt totalRiderEarningsKobo;
  final BigInt pendingRefundsKobo;
  final DateTime settlementDate;

  String get formattedGrossGmv => '₦${(grossGmvKobo / BigInt.from(100)).toStringAsFixed(0)}';
  String get formattedNetRevenue => '₦${(netPlatformRevenueKobo / BigInt.from(100)).toStringAsFixed(0)}';
  String get formattedRiderEarnings => '₦${(totalRiderEarningsKobo / BigInt.from(100)).toStringAsFixed(0)}';
  String get formattedPendingRefunds => '₦${(pendingRefundsKobo / BigInt.from(100)).toStringAsFixed(0)}';

  @override
  List<Object?> get props => [
        grossGmvKobo,
        netPlatformRevenueKobo,
        totalRiderEarningsKobo,
        pendingRefundsKobo,
        settlementDate,
      ];
}
