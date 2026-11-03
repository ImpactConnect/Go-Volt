import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/supabase_admin_client.dart';
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
              grossGmvKobo: BigInt.zero,
              netPlatformRevenueKobo: BigInt.zero,
              totalRiderEarningsKobo: BigInt.zero,
              pendingRefundsKobo: BigInt.zero,
              settlementDate: DateTime.now(),
            ),
            refunds: const [],
            payoutBatches: const [],
          ),
        ) {
    fetchRealFinance();
  }

    @visibleForTesting
  void updateStateForTesting(FinanceState newState) {
    state = newState;
  }

  Future<void> fetchRealFinance() async {
    final client = tryGetSupabaseClient();
    if (client == null) return;
    try {
      final bookingsRes = await client.from('bookings').select();
      final bookings = bookingsRes as List<dynamic>;

      int gmv = 0;
      int commission = 0;
      for (final b in bookings) {
        gmv += (b['fare_kobo'] as num?)?.toInt() ?? 0;
        commission += (b['commission_kobo'] as num?)?.toInt() ?? 0;
      }
      final riderEarnings = gmv - commission;

      state = state.copyWith(
        summary: FinancialLedgerSummary(
          grossGmvKobo: BigInt.from(gmv),
          netPlatformRevenueKobo: BigInt.from(commission),
          totalRiderEarningsKobo: BigInt.from(riderEarnings),
          pendingRefundsKobo: BigInt.zero,
          settlementDate: DateTime.now(),
        ),
        refunds: const [],
        payoutBatches: const [],
      );
    } catch (e) {
      debugPrint('[FinanceNotifier] Error fetching finance data: $e');
    }
  }

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
