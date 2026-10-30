import 'package:app_models/app_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/api_providers.dart';
import '../data/wallet_repository.dart';
import '../domain/wallet_state.dart';

final walletRepositoryProvider = Provider<WalletRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return WalletRepository(apiClient: apiClient);
});

final walletNotifierProvider =
    StateNotifierProvider<WalletNotifier, WalletState>((ref) {
  final repository = ref.watch(walletRepositoryProvider);
  return WalletNotifier(repository: repository);
});

class WalletNotifier extends StateNotifier<WalletState> {
  WalletNotifier({required WalletRepository repository})
      : _repository = repository,
        super(
          const WalletState(
            wallet: WalletDto(
              userId: 'usr-customer-01',
              balance: 14500.0,
              lockedBalance: 0.0,
              currency: 'NGN',
            ),
          ),
        ) {
    loadWallet();
  }

  final WalletRepository _repository;

  /// Loads full wallet ledger, loyalty points and promotional coupons.
  Future<void> loadWallet() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final wallet = await _repository.getWallet();
      final transactions = await _repository.getTransactions();
      final loyalty = await _repository.getLoyaltyRewards();
      final coupons = await _repository.getCoupons();

      state = state.copyWith(
        wallet: wallet,
        transactions: transactions,
        loyalty: loyalty,
        coupons: coupons,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to synchronize wallet balance: $e',
      );
    }
  }

  /// Initiates top-up via Paystack checkout.
  Future<String?> initiateTopUp(double amountNaira) async {
    state = state.copyWith(isProcessingTopUp: true, error: null);
    try {
      final res = await _repository.initiateTopUp(amountNaira);
      final url = res['authorization_url'] as String?;
      state = state.copyWith(
        isProcessingTopUp: false,
        topUpRedirectUrl: url,
      );
      return url;
    } catch (e) {
      state = state.copyWith(
        isProcessingTopUp: false,
        error: 'Top-up initiation failed: $e',
      );
      return null;
    }
  }

  /// Completes Paystack top-up post verification and updates balance atomically.
  Future<bool> completeTopUp(String reference, double amountNaira) async {
    state = state.copyWith(isProcessingTopUp: true);
    try {
      final updatedWallet = await _repository.verifyTopUp(reference, amountNaira);
      final newTx = WalletTransactionDto(
        id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
        userId: updatedWallet.userId,
        amount: amountNaira,
        isCredit: true,
        description: 'Paystack Instant Top-Up',
        reference: reference,
        createdAt: DateTime.now(),
        status: 'COMPLETED',
      );

      state = state.copyWith(
        wallet: updatedWallet,
        transactions: [newTx, ...state.transactions],
        isProcessingTopUp: false,
        topUpRedirectUrl: null,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isProcessingTopUp: false,
        error: 'Verification pending: Please check your bank debit notification.',
      );
      return false;
    }
  }

  /// Atomically converts Eco-Points into wallet credit.
  Future<bool> redeemLoyaltyPoints(int pointsToRedeem) async {
    if (state.loyalty == null || state.loyalty!.pointsBalance < pointsToRedeem) {
      state = state.copyWith(error: 'Insufficient Eco-Points for redemption.');
      return false;
    }

    final creditNaira =
        pointsToRedeem / state.loyalty!.conversionRatePointsPerNaira;
    state = state.copyWith(isLoading: true);

    try {
      await _repository.redeemPoints(
        points: pointsToRedeem,
        creditNaira: creditNaira,
      );

      final newBalance = state.wallet.balance + creditNaira;
      final updatedWallet = WalletDto(
        userId: state.wallet.userId,
        balance: newBalance,
        lockedBalance: state.wallet.lockedBalance,
        currency: state.wallet.currency,
        updatedAt: DateTime.now(),
      );

      final newLoyalty = LoyaltyRewardDto(
        pointsBalance: state.loyalty!.pointsBalance - pointsToRedeem,
        conversionRatePointsPerNaira:
            state.loyalty!.conversionRatePointsPerNaira,
        tierName: state.loyalty!.tierName,
        pointsExpiringSoon: state.loyalty!.pointsExpiringSoon,
        referralCode: state.loyalty!.referralCode,
        referralCount: state.loyalty!.referralCount,
        referralEarningsNaira: state.loyalty!.referralEarningsNaira,
      );

      final redemptionTx = WalletTransactionDto(
        id: 'tx-red-${DateTime.now().millisecondsSinceEpoch}',
        userId: state.wallet.userId,
        amount: creditNaira,
        isCredit: true,
        description: 'Eco-Points Redemption ($pointsToRedeem pts)',
        reference: 'RWD-RED-${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
        status: 'COMPLETED',
      );

      state = state.copyWith(
        wallet: updatedWallet,
        loyalty: newLoyalty,
        transactions: [redemptionTx, ...state.transactions],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to convert points: $e',
      );
      return false;
    }
  }
}
