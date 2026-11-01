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
              userId: '',
              balance: 0.0,
              lockedBalance: 0.0,
              currency: 'NGN',
            ),
          ),
        ) {
    loadWallet();
  }

  final WalletRepository _repository;

  /// Loads full wallet ledger, loyalty points and promotional coupons.
  Future<void> loadWallet({String? userId, String? userName}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final wallet = await _repository.getWallet(userId: userId);
      final transactions = await _repository.getTransactions(userId: userId);
      final loyalty = await _repository.getLoyaltyRewards(userId: userId, userName: userName);
      final coupons = await _repository.getCoupons();
      final cards = await _repository.getSavedCards(userId: userId);
      final dedicated = await _repository.getDedicatedAccount(userId: userId, userName: userName);

      state = state.copyWith(
        wallet: wallet,
        transactions: transactions,
        loyalty: loyalty,
        coupons: coupons,
        savedCards: cards,
        dedicatedAccount: dedicated,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to synchronize wallet balance: $e',
      );
    }
  }

  /// Generates or refreshes user's unique referral code dynamically.
  Future<String?> generateUniqueReferralCode({
    required String userId,
    String? userName,
  }) async {
    try {
      final code = await _repository.generateUniqueReferralCode(
        userId: userId,
        userName: userName,
      );
      if (state.loyalty != null) {
        final updatedLoyalty = LoyaltyRewardDto(
          pointsBalance: state.loyalty!.pointsBalance,
          conversionRatePointsPerNaira: state.loyalty!.conversionRatePointsPerNaira,
          tierName: state.loyalty!.tierName,
          pointsExpiringSoon: state.loyalty!.pointsExpiringSoon,
          referralCode: code,
          referralCount: state.loyalty!.referralCount,
          referralEarningsNaira: state.loyalty!.referralEarningsNaira,
          nextTierName: state.loyalty!.nextTierName,
          nextTierPointsThreshold: state.loyalty!.nextTierPointsThreshold,
          currentTierPointsFloor: state.loyalty!.currentTierPointsFloor,
          referredFriends: state.loyalty!.referredFriends,
          conversionRule: state.loyalty!.conversionRule,
        );
        state = state.copyWith(loyalty: updatedLoyalty);
      }
      return code;
    } catch (_) {
      return null;
    }
  }

  /// Links a debit card authorization tokenized via Paystack.
  Future<SavedPaymentCardDto?> linkCardViaPaystack({
    required String reference,
    String brand = 'Mastercard',
    String last4 = '4242',
    String expMonth = '12',
    String expYear = '28',
    String bank = 'Paystack Verified Bank',
    String? userId,
  }) async {
    try {
      final newCard = await _repository.verifyCardAuthorization(
        reference: reference,
        brand: brand,
        last4: last4,
        expMonth: expMonth,
        expYear: expYear,
        bank: bank,
        userId: userId,
      );

      final updatedCards = [
        ...state.savedCards.map((c) => newCard.isDefault ? c.copyWith(isDefault: false) : c),
        newCard,
      ];
      state = state.copyWith(savedCards: updatedCards);
      return newCard;
    } catch (e) {
      state = state.copyWith(error: 'Failed to link card: $e');
      return null;
    }
  }

  /// Deletes a saved card authorization.
  Future<bool> deleteCard(String cardId, {String? userId}) async {
    final ok = await _repository.deleteCard(cardId, userId: userId);
    if (ok) {
      final remaining = state.savedCards.where((c) => c.id != cardId).toList();
      if (remaining.isNotEmpty && !remaining.any((c) => c.isDefault)) {
        remaining[0] = remaining[0].copyWith(isDefault: true);
      }
      state = state.copyWith(savedCards: remaining);
    }
    return ok;
  }

  /// Sets a saved card as default.
  Future<bool> setDefaultCard(String cardId, {String? userId}) async {
    final ok = await _repository.setDefaultCard(cardId, userId: userId);
    if (ok) {
      final updated = state.savedCards
          .map((c) => c.copyWith(isDefault: c.id == cardId))
          .toList();
      state = state.copyWith(savedCards: updated);
    }
    return ok;
  }

  /// Validates a promo code against active backend coupons.
  Future<Map<String, dynamic>> validateCoupon(String code, {double orderAmount = 0.0}) async {
    return await _repository.validateCoupon(code, orderAmount: orderAmount);
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

  /// Completes Paystack top-up post authoritative verification and updates balance atomically.
  Future<bool> completeTopUp(String reference, double amountNaira, {String? userId}) async {
    state = state.copyWith(isProcessingTopUp: true, error: null);
    try {
      final updatedWallet = await _repository.verifyTopUp(reference, amountNaira, userId: userId);
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
      final cleanMsg = e.toString().replaceFirst('Exception: ', '').trim();
      final displayError = cleanMsg.isNotEmpty && !cleanMsg.startsWith('DioException')
          ? cleanMsg
          : 'Payment has not been confirmed by Paystack or your bank yet. Please complete payment before verifying.';

      state = state.copyWith(
        isProcessingTopUp: false,
        error: displayError,
      );
      return false;
    }
  }

  /// Verifies if dedicated virtual account bank transfer has settled in database.
  Future<Map<String, dynamic>> checkBankTransfer({String? userId, String? accountNumber}) async {
    state = state.copyWith(isProcessingTopUp: true, error: null);
    try {
      final res = await _repository.checkBankTransfer(userId: userId, accountNumber: accountNumber);
      final isVerified = res['data']?['verified'] == true;
      if (isVerified) {
        await loadWallet(userId: userId);
      }
      state = state.copyWith(isProcessingTopUp: false);
      return res;
    } catch (e) {
      state = state.copyWith(isProcessingTopUp: false);
      return {
        'data': {
          'verified': false,
          'status': 'PENDING_SETTLEMENT',
          'message': 'No transfer detected from NIBSS yet. Inter-bank settlements typically take 1 to 3 minutes.',
        }
      };
    }
  }

  /// Atomically converts Eco-Points into wallet credit using admin-configured rate.
  Future<bool> redeemLoyaltyPoints(int pointsToRedeem) async {
    if (state.loyalty == null || state.loyalty!.pointsBalance < pointsToRedeem) {
      state = state.copyWith(error: 'Insufficient Eco-Points for redemption.');
      return false;
    }

    final creditNaira = state.loyalty!.conversionRule.calculateCreditNaira(pointsToRedeem);
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
        nextTierName: state.loyalty!.nextTierName,
        nextTierPointsThreshold: state.loyalty!.nextTierPointsThreshold,
        currentTierPointsFloor: state.loyalty!.currentTierPointsFloor,
        referredFriends: state.loyalty!.referredFriends,
        conversionRule: state.loyalty!.conversionRule,
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
