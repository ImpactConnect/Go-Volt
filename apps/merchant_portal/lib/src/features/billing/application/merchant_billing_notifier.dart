import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/billing_models.dart';

class MerchantBillingState {
  const MerchantBillingState({
    required this.wallet,
    required this.invoices,
    required this.transactions,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  final CorporateWalletAccount wallet;
  final List<MerchantInvoice> invoices;
  final List<CorporateTransactionItem> transactions;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  MerchantBillingState copyWith({
    CorporateWalletAccount? wallet,
    List<MerchantInvoice>? invoices,
    List<CorporateTransactionItem>? transactions,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return MerchantBillingState(
      wallet: wallet ?? this.wallet,
      invoices: invoices ?? this.invoices,
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearMessages ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearMessages ? null : (successMessage ?? this.successMessage),
    );
  }
}

class MerchantBillingNotifier extends StateNotifier<MerchantBillingState> {
  MerchantBillingNotifier() : super(_initialState);

  static final MerchantBillingState _initialState = MerchantBillingState(
    wallet: CorporateWalletAccount(
      id: 'corp-wal-volt-001',
      merchantId: 'merch-retail-ai-001',
      balanceKobo: BigInt.from(245000000), // ₦2,450,000.00
      creditLimitKobo: BigInt.from(500000000), // ₦5,000,000.00
      currency: 'NGN',
      autoDebitEnabled: true,
      lowBalanceThresholdKobo: BigInt.from(50000000), // ₦500,000.00
    ),
    invoices: [
      MerchantInvoice(
        id: 'inv-0043',
        invoiceNumber: 'INV-2026-0043',
        billingPeriod: 'Oct 01 - Oct 15, 2026',
        issueDate: DateTime(2026, 10, 15),
        dueDate: DateTime(2026, 10, 30),
        amountKobo: BigInt.from(85000000), // ₦850,000.00
        status: InvoiceStatus.pending,
        totalDeliveries: 340,
        branchBreakdown: const {
          'Lekki Phase 1 Hub': 180,
          'Victoria Island Hub': 110,
          'Ikeja City Mall Hub': 50,
        },
      ),
      MerchantInvoice(
        id: 'inv-0042',
        invoiceNumber: 'INV-2026-0042',
        billingPeriod: 'Sep 15 - Sep 30, 2026',
        issueDate: DateTime(2026, 9, 30),
        dueDate: DateTime(2026, 10, 15),
        amountKobo: BigInt.from(125000000), // ₦1,250,000.00
        status: InvoiceStatus.paid,
        totalDeliveries: 495,
        paymentDate: DateTime(2026, 10, 12),
        branchBreakdown: const {
          'Lekki Phase 1 Hub': 250,
          'Victoria Island Hub': 160,
          'Ikeja City Mall Hub': 85,
        },
      ),
      MerchantInvoice(
        id: 'inv-0041',
        invoiceNumber: 'INV-2026-0041',
        billingPeriod: 'Sep 01 - Sep 14, 2026',
        issueDate: DateTime(2026, 9, 15),
        dueDate: DateTime(2026, 9, 30),
        amountKobo: BigInt.from(112000000), // ₦1,120,000.00
        status: InvoiceStatus.paid,
        totalDeliveries: 440,
        paymentDate: DateTime(2026, 9, 28),
        branchBreakdown: const {
          'Lekki Phase 1 Hub': 230,
          'Victoria Island Hub': 140,
          'Ikeja City Mall Hub': 70,
        },
      ),
    ],
    transactions: [
      CorporateTransactionItem(
        id: 'tx-1005',
        reference: 'TX-VOLT-TOPUP-9921',
        timestamp: DateTime(2026, 10, 25, 9, 30),
        type: CorporateTransactionType.creditTopup,
        description: 'Instant Bank Top-Up via NIBSS Instant Payment',
        amountKobo: BigInt.from(100000000), // ₦1,000,000.00
        isCredit: true,
        balanceAfterKobo: BigInt.from(245000000),
      ),
      CorporateTransactionItem(
        id: 'tx-1004',
        reference: 'TX-VOLT-DISP-8842',
        timestamp: DateTime(2026, 10, 24, 16, 45),
        type: CorporateTransactionType.deliveryChargeBatch,
        description: 'Express Dispatch delivery fee (GV-LEK-90412)',
        amountKobo: BigInt.from(285000), // ₦2,850.00
        isCredit: false,
        balanceAfterKobo: BigInt.from(145000000),
        branchName: 'Lekki Phase 1 Hub',
        bookingTrackingNumber: 'GV-LEK-90412',
      ),
      CorporateTransactionItem(
        id: 'tx-1003',
        reference: 'TX-VOLT-REF-7712',
        timestamp: DateTime(2026, 10, 24, 14, 10),
        type: CorporateTransactionType.cancellationRefund,
        description: 'Auto-refund for cancelled order (GV-VI-88201)',
        amountKobo: BigInt.from(320000), // ₦3,200.00
        isCredit: true,
        balanceAfterKobo: BigInt.from(145285000),
        branchName: 'Victoria Island Hub',
        bookingTrackingNumber: 'GV-VI-88201',
      ),
      CorporateTransactionItem(
        id: 'tx-1002',
        reference: 'TX-VOLT-SETTL-6640',
        timestamp: DateTime(2026, 10, 12, 11, 0),
        type: CorporateTransactionType.monthlySettlement,
        description: 'Corporate Invoice Settlement INV-2026-0042',
        amountKobo: BigInt.from(125000000), // ₦1,250,000.00
        isCredit: false,
        balanceAfterKobo: BigInt.from(142085000),
      ),
    ],
  );

  /// Top-up the corporate wallet
  void topUpWallet(BigInt amountKobo, CorporatePaymentMethod method) {
    if (amountKobo <= BigInt.zero) return;
    final newBalance = state.wallet.balanceKobo + amountKobo;
    final updatedWallet = state.wallet.copyWith(balanceKobo: newBalance);

    final newTx = CorporateTransactionItem(
      id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
      reference: 'TX-VOLT-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      timestamp: DateTime.now(),
      type: CorporateTransactionType.creditTopup,
      description: 'Corporate Top-Up via ${method.displayName}',
      amountKobo: amountKobo,
      isCredit: true,
      balanceAfterKobo: newBalance,
    );

    state = state.copyWith(
      wallet: updatedWallet,
      transactions: [newTx, ...state.transactions],
      successMessage: 'Successfully topped up ${newTx.formattedAmount}',
      clearMessages: false,
    );
  }

  /// Settle pending invoice using corporate wallet
  bool settleInvoice(String invoiceId) {
    final invoiceIndex = state.invoices.indexWhere((inv) => inv.id == invoiceId);
    if (invoiceIndex == -1) {
      state = state.copyWith(errorMessage: 'Invoice not found');
      return false;
    }

    final invoice = state.invoices[invoiceIndex];
    if (invoice.status == InvoiceStatus.paid) {
      state = state.copyWith(errorMessage: 'Invoice is already settled');
      return false;
    }

    if (state.wallet.balanceKobo < invoice.amountKobo) {
      state = state.copyWith(
        errorMessage: 'Insufficient corporate wallet balance to settle invoice',
      );
      return false;
    }

    final newBalance = state.wallet.balanceKobo - invoice.amountKobo;
    final updatedWallet = state.wallet.copyWith(balanceKobo: newBalance);

    final updatedInvoices = List<MerchantInvoice>.from(state.invoices);
    updatedInvoices[invoiceIndex] = invoice.copyWith(
      status: InvoiceStatus.paid,
      paymentDate: DateTime.now(),
    );

    final settlementTx = CorporateTransactionItem(
      id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
      reference: 'TX-SETTL-${invoice.invoiceNumber}',
      timestamp: DateTime.now(),
      type: CorporateTransactionType.monthlySettlement,
      description: 'Settlement for Invoice ${invoice.invoiceNumber}',
      amountKobo: invoice.amountKobo,
      isCredit: false,
      balanceAfterKobo: newBalance,
    );

    state = state.copyWith(
      wallet: updatedWallet,
      invoices: updatedInvoices,
      transactions: [settlementTx, ...state.transactions],
      successMessage: 'Invoice ${invoice.invoiceNumber} settled successfully',
      clearMessages: false,
    );
    return true;
  }

  /// Deduct dispatch fee upon delivery booking creation
  void deductDispatchFee({
    required BigInt amountKobo,
    required String bookingId,
    required String trackingNumber,
    required String branchName,
  }) {
    final newBalance = state.wallet.balanceKobo - amountKobo;
    final updatedWallet = state.wallet.copyWith(balanceKobo: newBalance);

    final tx = CorporateTransactionItem(
      id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
      reference: 'TX-DISP-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      timestamp: DateTime.now(),
      type: CorporateTransactionType.deliveryChargeBatch,
      description: 'Dispatch fee for $trackingNumber',
      amountKobo: amountKobo,
      isCredit: false,
      balanceAfterKobo: newBalance,
      branchName: branchName,
      bookingTrackingNumber: trackingNumber,
    );

    state = state.copyWith(
      wallet: updatedWallet,
      transactions: [tx, ...state.transactions],
    );
  }

  /// Refund wallet on delivery booking cancellation
  void refundCancellation({
    required BigInt amountKobo,
    required String bookingId,
    required String trackingNumber,
    required String branchName,
  }) {
    final newBalance = state.wallet.balanceKobo + amountKobo;
    final updatedWallet = state.wallet.copyWith(balanceKobo: newBalance);

    final tx = CorporateTransactionItem(
      id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
      reference: 'TX-REF-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
      timestamp: DateTime.now(),
      type: CorporateTransactionType.cancellationRefund,
      description: 'Auto-refund for cancelled order ($trackingNumber)',
      amountKobo: amountKobo,
      isCredit: true,
      balanceAfterKobo: newBalance,
      branchName: branchName,
      bookingTrackingNumber: trackingNumber,
    );

    state = state.copyWith(
      wallet: updatedWallet,
      transactions: [tx, ...state.transactions],
      successMessage: 'Refund of ${tx.formattedAmount} credited to corporate wallet',
    );
  }

  void clearMessages() {
    state = state.copyWith(clearMessages: true);
  }
}

final merchantBillingNotifierProvider =
    StateNotifierProvider<MerchantBillingNotifier, MerchantBillingState>((ref) {
  return MerchantBillingNotifier();
});
