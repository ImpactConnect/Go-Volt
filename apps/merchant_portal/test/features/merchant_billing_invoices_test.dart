import 'package:flutter_test/flutter_test.dart';
import 'package:merchant_portal/src/features/billing/application/merchant_billing_notifier.dart';
import 'package:merchant_portal/src/features/billing/domain/billing_models.dart';

void main() {
  group('Phase 4: Merchant Billing, Corporate Wallet & Invoices', () {
    test('initializes with corporate wallet and automated invoices', () {
      final notifier = MerchantBillingNotifier();

      expect(notifier.state.wallet.balanceKobo, BigInt.from(245000000)); // ₦2,450,000.00
      expect(notifier.state.wallet.creditLimitKobo, BigInt.from(500000000)); // ₦5,000,000.00
      expect(notifier.state.wallet.formattedBalance, contains('₦2,450,000.00'));
      expect(notifier.state.invoices, isNotEmpty);
      expect(
        notifier.state.invoices.any((i) => i.status == InvoiceStatus.pending),
        isTrue,
      );
    });

    test('tops up corporate wallet and records ledger transaction', () {
      final notifier = MerchantBillingNotifier();
      final initialBalance = notifier.state.wallet.balanceKobo;
      final topUpAmount = BigInt.from(50000000); // ₦500,000.00

      notifier.topUpWallet(topUpAmount, CorporatePaymentMethod.bankTransfer);

      expect(notifier.state.wallet.balanceKobo, initialBalance + topUpAmount);
      final latestTx = notifier.state.transactions.first;
      expect(latestTx.isCredit, isTrue);
      expect(latestTx.amountKobo, topUpAmount);
      expect(latestTx.type, CorporateTransactionType.creditTopup);
      expect(latestTx.balanceAfterKobo, initialBalance + topUpAmount);
      expect(notifier.state.successMessage, contains('₦500,000.00'));
    });

    test('deducts dispatch fee on booking creation and refunds on cancellation', () {
      final notifier = MerchantBillingNotifier();
      final initialBalance = notifier.state.wallet.balanceKobo;
      final fee = BigInt.from(285000); // ₦2,850.00

      // Deduct dispatch fee
      notifier.deductDispatchFee(
        amountKobo: fee,
        bookingId: 'dlv_001',
        trackingNumber: 'GV-LEK-90412',
        branchName: 'Lekki Phase 1 Hub',
      );

      expect(notifier.state.wallet.balanceKobo, initialBalance - fee);
      final debitTx = notifier.state.transactions.first;
      expect(debitTx.isCredit, isFalse);
      expect(debitTx.bookingTrackingNumber, 'GV-LEK-90412');
      expect(debitTx.branchName, 'Lekki Phase 1 Hub');

      // Refund dispatch fee on cancellation
      notifier.refundCancellation(
        amountKobo: fee,
        bookingId: 'dlv_001',
        trackingNumber: 'GV-LEK-90412',
        branchName: 'Lekki Phase 1 Hub',
      );

      expect(notifier.state.wallet.balanceKobo, initialBalance);
      final refundTx = notifier.state.transactions.first;
      expect(refundTx.isCredit, isTrue);
      expect(refundTx.type, CorporateTransactionType.cancellationRefund);
    });

    test('settles pending corporate invoice using corporate wallet', () {
      final notifier = MerchantBillingNotifier();
      final pendingInv =
          notifier.state.invoices.firstWhere((i) => i.status == InvoiceStatus.pending);
      final initialBalance = notifier.state.wallet.balanceKobo;

      final success = notifier.settleInvoice(pendingInv.id);
      expect(success, isTrue);

      final settledInv =
          notifier.state.invoices.firstWhere((i) => i.id == pendingInv.id);
      expect(settledInv.status, InvoiceStatus.paid);
      expect(settledInv.paymentDate, isNotNull);
      expect(notifier.state.wallet.balanceKobo, initialBalance - pendingInv.amountKobo);

      final settlementTx = notifier.state.transactions.first;
      expect(settlementTx.type, CorporateTransactionType.monthlySettlement);
      expect(settlementTx.amountKobo, pendingInv.amountKobo);
      expect(notifier.state.successMessage, contains(pendingInv.invoiceNumber));

      // Attempting to settle already paid invoice fails
      final secondAttempt = notifier.settleInvoice(pendingInv.id);
      expect(secondAttempt, isFalse);
      expect(notifier.state.errorMessage, contains('already settled'));
    });
  });
}
