import 'package:equatable/equatable.dart';

/// Itemized earnings transaction entry in the rider's ledger.
class RiderLedgerEntryDto extends Equatable {
  const RiderLedgerEntryDto({
    required this.id,
    required this.reference,
    required this.title,
    required this.time,
    required this.grossKobo,
    required this.platformCommissionKobo,
    required this.tipKobo,
    required this.netKobo,
    this.isPayout = false,
  });

  final String id;
  final String reference;
  final String title;
  final String time;
  final int grossKobo;
  final int platformCommissionKobo;
  final int tipKobo;
  final int netKobo;
  final bool isPayout;

  @override
  List<Object?> get props => [
        id,
        reference,
        title,
        time,
        grossKobo,
        platformCommissionKobo,
        tipKobo,
        netKobo,
        isPayout,
      ];
}

/// State for the rider earnings ledger, commissions, and weekly Paystack settlement.
class RiderEarningsState extends Equatable {
  const RiderEarningsState({
    this.grossWeekKobo = 10800000, // ₦108,000
    this.commissionWeekKobo = 2160000, // ₦21,600 (20%)
    this.tipsWeekKobo = 450000, // ₦4,500
    this.settledWeekKobo = 8640000, // ₦86,400 net
    this.settlementDay = 'Tuesday',
    this.bankName = 'Access Bank',
    this.maskedAccountNumber = '•••• 4920',
    this.entries = const [],
    this.isWithdrawing = false,
    this.lastDisputeSubmittedReference,
  });

  final int grossWeekKobo;
  final int commissionWeekKobo;
  final int tipsWeekKobo;
  final int settledWeekKobo;
  final String settlementDay;
  final String bankName;
  final String maskedAccountNumber;
  final List<RiderLedgerEntryDto> entries;
  final bool isWithdrawing;
  final String? lastDisputeSubmittedReference;

  RiderEarningsState copyWith({
    int? grossWeekKobo,
    int? commissionWeekKobo,
    int? tipsWeekKobo,
    int? settledWeekKobo,
    String? settlementDay,
    String? bankName,
    String? maskedAccountNumber,
    List<RiderLedgerEntryDto>? entries,
    bool? isWithdrawing,
    String? lastDisputeSubmittedReference,
  }) {
    return RiderEarningsState(
      grossWeekKobo: grossWeekKobo ?? this.grossWeekKobo,
      commissionWeekKobo: commissionWeekKobo ?? this.commissionWeekKobo,
      tipsWeekKobo: tipsWeekKobo ?? this.tipsWeekKobo,
      settledWeekKobo: settledWeekKobo ?? this.settledWeekKobo,
      settlementDay: settlementDay ?? this.settlementDay,
      bankName: bankName ?? this.bankName,
      maskedAccountNumber: maskedAccountNumber ?? this.maskedAccountNumber,
      entries: entries ?? this.entries,
      isWithdrawing: isWithdrawing ?? this.isWithdrawing,
      lastDisputeSubmittedReference:
          lastDisputeSubmittedReference ?? this.lastDisputeSubmittedReference,
    );
  }

  @override
  List<Object?> get props => [
        grossWeekKobo,
        commissionWeekKobo,
        tipsWeekKobo,
        settledWeekKobo,
        settlementDay,
        bankName,
        maskedAccountNumber,
        entries,
        isWithdrawing,
        lastDisputeSubmittedReference,
      ];
}
