import 'package:app_models/app_models.dart';
import 'package:equatable/equatable.dart';

/// State representation for Go-Volts customer wallet, rewards and transactions.
class WalletState extends Equatable {
  const WalletState({
    required this.wallet,
    this.transactions = const [],
    this.loyalty,
    this.coupons = const [],
    this.savedCards = const [],
    this.dedicatedAccount,
    this.isLoading = false,
    this.isProcessingTopUp = false,
    this.topUpRedirectUrl,
    this.error,
  });

  final WalletDto wallet;
  final List<WalletTransactionDto> transactions;
  final LoyaltyRewardDto? loyalty;
  final List<CouponDto> coupons;
  final List<SavedPaymentCardDto> savedCards;
  final DedicatedAccountDto? dedicatedAccount;
  final bool isLoading;
  final bool isProcessingTopUp;
  final String? topUpRedirectUrl;
  final String? error;

  WalletState copyWith({
    WalletDto? wallet,
    List<WalletTransactionDto>? transactions,
    LoyaltyRewardDto? loyalty,
    List<CouponDto>? coupons,
    List<SavedPaymentCardDto>? savedCards,
    DedicatedAccountDto? dedicatedAccount,
    bool? isLoading,
    bool? isProcessingTopUp,
    String? topUpRedirectUrl,
    String? error,
  }) {
    return WalletState(
      wallet: wallet ?? this.wallet,
      transactions: transactions ?? this.transactions,
      loyalty: loyalty ?? this.loyalty,
      coupons: coupons ?? this.coupons,
      savedCards: savedCards ?? this.savedCards,
      dedicatedAccount: dedicatedAccount ?? this.dedicatedAccount,
      isLoading: isLoading ?? this.isLoading,
      isProcessingTopUp: isProcessingTopUp ?? this.isProcessingTopUp,
      topUpRedirectUrl: topUpRedirectUrl,
      error: error,
    );
  }

  @override
  List<Object?> get props => [
        wallet,
        transactions,
        loyalty,
        coupons,
        savedCards,
        dedicatedAccount,
        isLoading,
        isProcessingTopUp,
        topUpRedirectUrl,
        error,
      ];
}
