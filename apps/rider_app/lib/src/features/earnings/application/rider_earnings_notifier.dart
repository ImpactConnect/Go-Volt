import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/rider_earnings_state.dart';

final riderEarningsNotifierProvider =
    StateNotifierProvider<RiderEarningsNotifier, RiderEarningsState>((ref) {
  return RiderEarningsNotifier();
});

/// Manages rider weekly earnings, commission deductions (20%), customer tips,
/// instant withdrawal requests, and dispute logging.
class RiderEarningsNotifier extends StateNotifier<RiderEarningsState> {
  RiderEarningsNotifier() : super(const RiderEarningsState()) {
    _loadInitialLedger();
  }

  void _loadInitialLedger() {
    state = state.copyWith(
      entries: const [
        RiderLedgerEntryDto(
          id: 'ent_1',
          reference: 'TRP-LAG-8921',
          title: 'Express Parcel Delivery · Lekki Phase 1',
          time: 'Today, 14:15',
          grossKobo: 420000,
          platformCommissionKobo: 84000,
          tipKobo: 0,
          netKobo: 336000,
        ),
        RiderLedgerEntryDto(
          id: 'ent_2',
          reference: 'TRP-LAG-8914',
          title: 'Passenger Commute · Victoria Island to Ikoyi',
          time: 'Today, 12:40',
          grossKobo: 350000,
          platformCommissionKobo: 70000,
          tipKobo: 0,
          netKobo: 280000,
        ),
        RiderLedgerEntryDto(
          id: 'ent_3',
          reference: 'TRP-LAG-8890',
          title: 'School-Run Morning Leg · Corona School',
          time: 'Today, 07:45',
          grossKobo: 600000,
          platformCommissionKobo: 120000,
          tipKobo: 0,
          netKobo: 480000,
        ),
        RiderLedgerEntryDto(
          id: 'ent_4',
          reference: 'PAY-PSTK-09214',
          title: 'Weekly Payout Settled · Access Bank',
          time: 'Tue 21 Oct, 08:30',
          grossKobo: 9420000,
          platformCommissionKobo: 0,
          tipKobo: 0,
          netKobo: 9420000,
          isPayout: true,
        ),
      ],
    );
  }

  /// Request on-demand payout of earned balance to the rider's verified Paystack recipient.
  Future<bool> requestInstantWithdrawal(int amountKobo) async {
    if (amountKobo <= 0 || amountKobo > state.settledWeekKobo) return false;
    state = state.copyWith(isWithdrawing: true);
    await Future<void>.delayed(const Duration(milliseconds: 200));

    final newSettled = state.settledWeekKobo - amountKobo;
    final newEntry = RiderLedgerEntryDto(
      id: 'ent_wd_${DateTime.now().millisecondsSinceEpoch}',
      reference: 'PAY-PSTK-${DateTime.now().millisecondsSinceEpoch % 100000}',
      title: 'Instant Payout Requested · ${state.bankName}',
      time: 'Just now',
      grossKobo: amountKobo,
      platformCommissionKobo: 0,
      tipKobo: 0,
      netKobo: amountKobo,
      isPayout: true,
    );

    state = state.copyWith(
      settledWeekKobo: newSettled,
      isWithdrawing: false,
      entries: [newEntry, ...state.entries],
    );
    return true;
  }

  /// Submits an earnings dispute for operations review.
  void submitDispute(String reference, String reason) {
    state = state.copyWith(lastDisputeSubmittedReference: reference);
  }
}
