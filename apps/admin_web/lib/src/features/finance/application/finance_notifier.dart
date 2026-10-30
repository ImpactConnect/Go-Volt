import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/finance_models.dart';

class FinanceState extends Equatable {
  const FinanceState({
    required this.summary,
    required this.refunds,
    required this.payoutBatches,
    this.errorMessage,
  });

  final FinancialLedgerSummary summary;
  final List<RefundRequestModel> refunds;
  final List<PayoutBatchModel> payoutBatches;
  final String? errorMessage;

  int get pendingMakerCheckerCount => refunds.where(
        (r) => r.status == RefundStatus.pendingCheckerSignoff,
      ).length;

  int get pendingSingleReviewCount => refunds.where(
        (r) => r.status == RefundStatus.pendingReview,
      ).length;

  FinanceState copyWith({
    FinancialLedgerSummary? summary,
    List<RefundRequestModel>? refunds,
    List<PayoutBatchModel>? payoutBatches,
    String? errorMessage,
  }) {
    return FinanceState(
      summary: summary ?? this.summary,
      refunds: refunds ?? this.refunds,
      payoutBatches: payoutBatches ?? this.payoutBatches,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [summary, refunds, payoutBatches, errorMessage];
}

class FinanceNotifier extends StateNotifier<FinanceState> {
  FinanceNotifier()
      : super(
          FinanceState(
            summary: FinancialLedgerSummary(
              grossGmvKobo: BigInt.from(1425000000), // ₦14,250,000 GMV
              netPlatformRevenueKobo: BigInt.from(285000000), // ₦2,850,000 (20% take)
              totalRiderEarningsKobo: BigInt.from(1140000000), // ₦11,400,000 (80%)
              pendingRefundsKobo: BigInt.from(3850000), // ₦38,500
              settlementDate: DateTime(2026, 10, 24),
            ),
            refunds: _seedRefunds,
            payoutBatches: _seedBatches,
          ),
        );

  static final List<RefundRequestModel> _seedRefunds = [
    RefundRequestModel(
      id: 'ref_req_101',
      bookingRef: 'GV-LKG-9021',
      customerName: 'Chiamaka Okonjo',
      amountKobo: BigInt.from(1500000), // ₦15,000 (>= ₦10,000 => requires dual approval)
      reason: 'School-Run trip cancelled due to sudden route flooding; parent pre-paid weekly bundle',
      makerId: 'staff_ops_ade',
      makerName: 'Adeola Sowande (Ops Agent)',
      makerTimestamp: DateTime(2026, 10, 24, 8, 30),
      status: RefundStatus.pendingCheckerSignoff,
    ),
    RefundRequestModel(
      id: 'ref_req_102',
      bookingRef: 'GV-B2B-4412',
      customerName: 'Emeka Eze',
      amountKobo: BigInt.from(450000), // ₦4,500 (< ₦10,000 => single review)
      reason: 'Delivery package delayed by 45 mins due to tire puncture',
      makerId: 'staff_ops_kemi',
      makerName: 'Kemi Balogun (Ops Agent)',
      makerTimestamp: DateTime(2026, 10, 24, 11, 15),
      status: RefundStatus.pendingReview,
    ),
    RefundRequestModel(
      id: 'ref_req_103',
      bookingRef: 'GV-TRIP-3310',
      customerName: 'Babatunde Fashola',
      amountKobo: BigInt.from(2500000), // ₦25,000 (Approved via dual signoff)
      reason: 'VIP hourly dispatch cancelled 24h prior in accordance with refund policy',
      makerId: 'staff_ops_ade',
      makerName: 'Adeola Sowande (Ops Agent)',
      makerTimestamp: DateTime(2026, 10, 23, 14, 0),
      status: RefundStatus.approved,
      checkerId: 'staff_fin_olumide',
      checkerName: 'Olumide Bakare (Finance Officer)',
      checkerTimestamp: DateTime(2026, 10, 23, 16, 20),
    ),
  ];

  static final List<PayoutBatchModel> _seedBatches = [
    PayoutBatchModel(
      batchId: 'BATCH-2026-W42',
      period: '17 Oct - 23 Oct 2026',
      totalRiders: 142,
      totalAmountKobo: BigInt.from(894500000), // ₦8,945,000
      status: 'settled',
      generatedAt: DateTime(2026, 10, 24, 6, 0),
      settledAt: DateTime(2026, 10, 24, 7, 30),
    ),
    PayoutBatchModel(
      batchId: 'BATCH-2026-W43-MID',
      period: '24 Oct 2026 (Daily Instant)',
      totalRiders: 36,
      totalAmountKobo: BigInt.from(245500000), // ₦2,455,000
      status: 'pending_payout',
      generatedAt: DateTime(2026, 10, 24, 17, 0),
    ),
  ];

  /// Request a refund. If >= ₦10,000 (1,000,000 kobo), requires Maker-Checker dual sign-off.
  void requestRefund({
    required String bookingRef,
    required String customerName,
    required BigInt amountKobo,
    required String reason,
    required String makerId,
    required String makerName,
  }) {
    final requiresDual = amountKobo >= RefundRequestModel.dualApprovalThresholdKobo;
    final newRequest = RefundRequestModel(
      id: 'ref_req_${DateTime.now().millisecondsSinceEpoch}',
      bookingRef: bookingRef,
      customerName: customerName,
      amountKobo: amountKobo,
      reason: reason,
      makerId: makerId,
      makerName: makerName,
      makerTimestamp: DateTime.now(),
      status: requiresDual ? RefundStatus.pendingCheckerSignoff : RefundStatus.pendingReview,
    );

    state = state.copyWith(
      refunds: [newRequest, ...state.refunds],
      errorMessage: null,
    );
  }

  /// Approve a refund request.
  /// Enforces maker-checker rule: maker cannot act as checker!
  bool approveRefund({
    required String requestId,
    required String checkerId,
    required String checkerName,
  }) {
    final refund = state.refunds.firstWhere((r) => r.id == requestId);

    if (refund.requiresMakerChecker && refund.makerId == checkerId) {
      state = state.copyWith(
        errorMessage: 'Maker-Checker Violation: The initiating officer ($checkerId) cannot approve their own refund request.',
      );
      return false;
    }

    final updated = state.refunds.map((r) {
      if (r.id == requestId) {
        return r.copyWith(
          status: RefundStatus.approved,
          checkerId: checkerId,
          checkerName: checkerName,
          checkerTimestamp: DateTime.now(),
        );
      }
      return r;
    }).toList();

    state = state.copyWith(refunds: updated, errorMessage: null);
    return true;
  }

  void rejectRefund({
    required String requestId,
    required String checkerId,
    required String reason,
  }) {
    final updated = state.refunds.map((r) {
      if (r.id == requestId) {
        return r.copyWith(
          status: RefundStatus.rejected,
          rejectionReason: reason,
          checkerId: checkerId,
          checkerTimestamp: DateTime.now(),
        );
      }
      return r;
    }).toList();

    state = state.copyWith(refunds: updated, errorMessage: null);
  }

  void settlePayoutBatch(String batchId) {
    final updated = state.payoutBatches.map((b) {
      if (b.batchId == batchId) {
        return b.copyWith(
          status: 'settled',
          settledAt: DateTime.now(),
        );
      }
      return b;
    }).toList();

    state = state.copyWith(payoutBatches: updated);
  }
}

final financeNotifierProvider =
    StateNotifierProvider<FinanceNotifier, FinanceState>((ref) {
  return FinanceNotifier();
});
