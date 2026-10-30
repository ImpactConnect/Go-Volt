import 'package:equatable/equatable.dart';

/// User wallet balance.
class WalletDto extends Equatable {

  factory WalletDto.fromJson(Map<String, dynamic> json) {
    return WalletDto(
      userId: json['user_id'] as String,
      balance: (json['balance'] as num).toDouble(),
      lockedBalance: (json['locked_balance'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'NGN',
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }
  const WalletDto({
    required this.userId,
    required this.balance,
    this.lockedBalance = 0.0,
    this.currency = 'NGN',
    this.updatedAt,
  });

  final String userId;
  final double balance;
  final double lockedBalance;
  final String currency;
  final DateTime? updatedAt;

  double get availableBalance => balance - lockedBalance;

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'balance': balance,
        'locked_balance': lockedBalance,
        'currency': currency,
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      };

  @override
  List<Object?> get props => [userId, balance, lockedBalance, currency, updatedAt];
}

/// Ledger-verified wallet transaction entry.
class WalletTransactionDto extends Equatable {

  factory WalletTransactionDto.fromJson(Map<String, dynamic> json) {
    return WalletTransactionDto(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      isCredit: json['is_credit'] as bool? ?? (json['type'] == 'CREDIT'),
      description: json['description'] as String? ?? '',
      reference: json['reference'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      status: json['status'] as String? ?? 'COMPLETED',
    );
  }
  const WalletTransactionDto({
    required this.id,
    required this.userId,
    required this.amount,
    required this.isCredit,
    required this.description,
    required this.reference,
    required this.createdAt,
    this.status = 'COMPLETED',
  });

  final String id;
  final String userId;
  final double amount;
  final bool isCredit;
  final String description;
  final String reference;
  final DateTime createdAt;
  final String status;

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'amount': amount,
        'is_credit': isCredit,
        'description': description,
        'reference': reference,
        'created_at': createdAt.toIso8601String(),
        'status': status,
      };

  @override
  List<Object?> get props => [id, userId, amount, isCredit, reference, createdAt, status];
}

/// Loyalty points balance and conversion quote.
class LoyaltyRewardDto extends Equatable {
  const LoyaltyRewardDto({
    required this.pointsBalance,
    required this.conversionRatePointsPerNaira,
    required this.tierName,
    this.pointsExpiringSoon = 0,
    this.referralCode = 'VOLT-LAGOS',
    this.referralCount = 3,
    this.referralEarningsNaira = 1500.0,
  });

  factory LoyaltyRewardDto.fromJson(Map<String, dynamic> json) {
    return LoyaltyRewardDto(
      pointsBalance: (json['points_balance'] as num?)?.toInt() ?? 0,
      conversionRatePointsPerNaira: (json['conversion_rate'] as num?)?.toInt() ?? 10,
      tierName: json['tier_name'] as String? ?? 'Green Explorer',
      pointsExpiringSoon: (json['points_expiring_soon'] as num?)?.toInt() ?? 0,
      referralCode: json['referral_code'] as String? ?? 'VOLT-LAGOS',
      referralCount: (json['referral_count'] as num?)?.toInt() ?? 0,
      referralEarningsNaira: (json['referral_earnings'] as num?)?.toDouble() ?? 0.0,
    );
  }

  final int pointsBalance;
  final int conversionRatePointsPerNaira;
  final String tierName;
  final int pointsExpiringSoon;
  final String referralCode;
  final int referralCount;
  final double referralEarningsNaira;

  /// 10 points = ₦1 wallet credit
  double get redeemableNaira => pointsBalance / conversionRatePointsPerNaira;

  Map<String, dynamic> toJson() => {
        'points_balance': pointsBalance,
        'conversion_rate': conversionRatePointsPerNaira,
        'tier_name': tierName,
        'points_expiring_soon': pointsExpiringSoon,
        'referral_code': referralCode,
        'referral_count': referralCount,
        'referral_earnings': referralEarningsNaira,
      };

  @override
  List<Object?> get props => [
        pointsBalance,
        conversionRatePointsPerNaira,
        tierName,
        pointsExpiringSoon,
        referralCode,
        referralCount,
        referralEarningsNaira,
      ];
}

/// Promotional coupon / voucher discount.
class CouponDto extends Equatable {
  const CouponDto({
    required this.code,
    required this.title,
    required this.discountAmountNaira,
    required this.minOrderAmountNaira,
    required this.expiryDate,
    this.isUsed = false,
  });

  factory CouponDto.fromJson(Map<String, dynamic> json) {
    return CouponDto(
      code: json['code'] as String,
      title: json['title'] as String,
      discountAmountNaira: (json['discount_amount'] as num).toDouble(),
      minOrderAmountNaira: (json['min_order_amount'] as num?)?.toDouble() ?? 0.0,
      expiryDate: DateTime.parse(json['expiry_date'] as String),
      isUsed: json['is_used'] as bool? ?? false,
    );
  }

  final String code;
  final String title;
  final double discountAmountNaira;
  final double minOrderAmountNaira;
  final DateTime expiryDate;
  final bool isUsed;

  bool get isExpired => DateTime.now().isAfter(expiryDate);
  bool get isValid => !isUsed && !isExpired;

  Map<String, dynamic> toJson() => {
        'code': code,
        'title': title,
        'discount_amount': discountAmountNaira,
        'min_order_amount': minOrderAmountNaira,
        'expiry_date': expiryDate.toIso8601String(),
        'is_used': isUsed,
      };

  @override
  List<Object?> get props => [
        code,
        title,
        discountAmountNaira,
        minOrderAmountNaira,
        expiryDate,
        isUsed,
      ];
}

