import 'package:app_models/app_models.dart';
import 'package:equatable/equatable.dart';

/// State representation for Go-Volts customer wallet, rewards and transactions.
class WalletState extends Equatable {
  const WalletState({
    required this.wallet,
    this.transactions = const [],
    this.loyalty,
    this.coupons = const [],
    this.isLoading = false,
    this.isProcessingTopUp = false,
    this.topUpRedirectUrl,
    this.error,
  });

  final WalletDto wallet;
  final List<WalletTransactionDto> transactions;
  final LoyaltyRewardDto? loyalty;
  final List<CouponDto> coupons;
  final bool isLoading;
  final bool isProcessingTopUp;
  final String? topUpRedirectUrl;
  final String? error;

  WalletState copyWith({
    WalletDto? wallet,
    List<WalletTransactionDto>? transactions,
    LoyaltyRewardDto? loyalty,
    List<CouponDto>? coupons,
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
        isLoading,
        isProcessingTopUp,
        topUpRedirectUrl,
        error,
      ];
}
