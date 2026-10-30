import 'package:equatable/equatable.dart';
import 'package:intl/intl.dart';

enum InvoiceStatus {
  paid,
  pending,
  overdue,
  draft;

  String get displayName {
    switch (this) {
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.pending:
        return 'Pending';
      case InvoiceStatus.overdue:
        return 'Overdue';
      case InvoiceStatus.draft:
        return 'Draft';
    }
  }
}

enum CorporatePaymentMethod {
  corporateWallet,
  bankTransfer,
  directDebit;

  String get displayName {
    switch (this) {
      case CorporatePaymentMethod.corporateWallet:
        return 'Corporate Wallet';
      case CorporatePaymentMethod.bankTransfer:
        return 'Bank Transfer (NIBSS)';
      case CorporatePaymentMethod.directDebit:
        return 'Direct Debit Mandate';
    }
  }
}

class MerchantInvoice extends Equatable {
  const MerchantInvoice({
    required this.id,
    required this.invoiceNumber,
    required this.billingPeriod,
    required this.issueDate,
    required this.dueDate,
    required this.amountKobo,
    required this.status,
    required this.totalDeliveries,
    required this.branchBreakdown,
    this.paymentDate,
    this.pdfUrl,
  });

  final String id;
  final String invoiceNumber;
  final String billingPeriod;
  final DateTime issueDate;
  final DateTime dueDate;
  final BigInt amountKobo;
  final InvoiceStatus status;
  final int totalDeliveries;
  final Map<String, int> branchBreakdown;
  final DateTime? paymentDate;
  final String? pdfUrl;

  double get amountNaira => amountKobo.toInt() / 100.0;

  String get formattedAmount {
    final format = NumberFormat.currency(
      locale: 'en_NG',
      symbol: '₦',
      decimalDigits: 2,
    );
    return format.format(amountNaira);
  }

  MerchantInvoice copyWith({
    String? id,
    String? invoiceNumber,
    String? billingPeriod,
    DateTime? issueDate,
    DateTime? dueDate,
    BigInt? amountKobo,
    InvoiceStatus? status,
    int? totalDeliveries,
    Map<String, int>? branchBreakdown,
    DateTime? paymentDate,
    String? pdfUrl,
  }) {
    return MerchantInvoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      billingPeriod: billingPeriod ?? this.billingPeriod,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      amountKobo: amountKobo ?? this.amountKobo,
      status: status ?? this.status,
      totalDeliveries: totalDeliveries ?? this.totalDeliveries,
      branchBreakdown: branchBreakdown ?? this.branchBreakdown,
      paymentDate: paymentDate ?? this.paymentDate,
      pdfUrl: pdfUrl ?? this.pdfUrl,
    );
  }

  @override
  List<Object?> get props => [
        id,
        invoiceNumber,
        billingPeriod,
        issueDate,
        dueDate,
        amountKobo,
        status,
        totalDeliveries,
        branchBreakdown,
        paymentDate,
        pdfUrl,
      ];
}

class CorporateWalletAccount extends Equatable {
  const CorporateWalletAccount({
    required this.id,
    required this.merchantId,
    required this.balanceKobo,
    required this.creditLimitKobo,
    required this.currency,
    required this.autoDebitEnabled,
    required this.lowBalanceThresholdKobo,
  });

  final String id;
  final String merchantId;
  final BigInt balanceKobo;
  final BigInt creditLimitKobo;
  final String currency;
  final bool autoDebitEnabled;
  final BigInt lowBalanceThresholdKobo;

  double get balanceNaira => balanceKobo.toInt() / 100.0;
  double get creditLimitNaira => creditLimitKobo.toInt() / 100.0;
  BigInt get availableCreditKobo => creditLimitKobo + balanceKobo;
  double get availableCreditNaira => availableCreditKobo.toInt() / 100.0;

  String get formattedBalance {
    final format = NumberFormat.currency(
      locale: 'en_NG',
      symbol: '₦',
      decimalDigits: 2,
    );
    return format.format(balanceNaira);
  }

  String get formattedCreditLimit {
    final format = NumberFormat.currency(
      locale: 'en_NG',
      symbol: '₦',
      decimalDigits: 2,
    );
    return format.format(creditLimitNaira);
  }

  CorporateWalletAccount copyWith({
    String? id,
    String? merchantId,
    BigInt? balanceKobo,
    BigInt? creditLimitKobo,
    String? currency,
    bool? autoDebitEnabled,
    BigInt? lowBalanceThresholdKobo,
  }) {
    return CorporateWalletAccount(
      id: id ?? this.id,
      merchantId: merchantId ?? this.merchantId,
      balanceKobo: balanceKobo ?? this.balanceKobo,
      creditLimitKobo: creditLimitKobo ?? this.creditLimitKobo,
      currency: currency ?? this.currency,
      autoDebitEnabled: autoDebitEnabled ?? this.autoDebitEnabled,
      lowBalanceThresholdKobo:
          lowBalanceThresholdKobo ?? this.lowBalanceThresholdKobo,
    );
  }

  @override
  List<Object?> get props => [
        id,
        merchantId,
        balanceKobo,
        creditLimitKobo,
        currency,
        autoDebitEnabled,
        lowBalanceThresholdKobo,
      ];
}

enum CorporateTransactionType {
  creditTopup,
  deliveryChargeBatch,
  monthlySettlement,
  cancellationRefund,
  overdraftFee;

  String get displayName {
    switch (this) {
      case CorporateTransactionType.creditTopup:
        return 'Wallet Top-up';
      case CorporateTransactionType.deliveryChargeBatch:
        return 'Dispatch Delivery Charge';
      case CorporateTransactionType.monthlySettlement:
        return 'Invoice Settlement';
      case CorporateTransactionType.cancellationRefund:
        return 'Cancellation Refund';
      case CorporateTransactionType.overdraftFee:
        return 'Fee Adjustment';
    }
  }
}

class CorporateTransactionItem extends Equatable {
  const CorporateTransactionItem({
    required this.id,
    required this.reference,
    required this.timestamp,
    required this.type,
    required this.description,
    required this.amountKobo,
    required this.isCredit,
    required this.balanceAfterKobo,
    this.branchName,
    this.bookingTrackingNumber,
  });

  final String id;
  final String reference;
  final DateTime timestamp;
  final CorporateTransactionType type;
  final String description;
  final BigInt amountKobo;
  final bool isCredit;
  final BigInt balanceAfterKobo;
  final String? branchName;
  final String? bookingTrackingNumber;

  double get amountNaira => amountKobo.toInt() / 100.0;
  double get balanceAfterNaira => balanceAfterKobo.toInt() / 100.0;

  String get formattedAmount {
    final format = NumberFormat.currency(
      locale: 'en_NG',
      symbol: isCredit ? '+₦' : '-₦',
      decimalDigits: 2,
    );
    return format.format(amountNaira);
  }

  String get formattedBalanceAfter {
    final format = NumberFormat.currency(
      locale: 'en_NG',
      symbol: '₦',
      decimalDigits: 2,
    );
    return format.format(balanceAfterNaira);
  }

  @override
  List<Object?> get props => [
        id,
        reference,
        timestamp,
        type,
        description,
        amountKobo,
        isCredit,
        balanceAfterKobo,
        branchName,
        bookingTrackingNumber,
      ];
}
