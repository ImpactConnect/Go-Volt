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

/// Status of a referred user.
class ReferredFriendDto extends Equatable {
  const ReferredFriendDto({
    required this.id,
    required this.name,
    required this.status,
    required this.rewardAmountNaira,
    required this.date,
  });

  factory ReferredFriendDto.fromJson(Map<String, dynamic> json) {
    return ReferredFriendDto(
      id: json['id'] as String,
      name: json['name'] as String,
      status: json['status'] as String? ?? 'Registered',
      rewardAmountNaira: (json['reward_amount_naira'] as num?)?.toDouble() ?? 500.0,
      date: json['date'] != null
          ? DateTime.parse(json['date'] as String)
          : DateTime.now(),
    );
  }

  final String id;
  final String name;
  final String status;
  final double rewardAmountNaira;
  final DateTime date;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'status': status,
        'reward_amount_naira': rewardAmountNaira,
        'date': date.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, name, status, rewardAmountNaira, date];
}

/// Admin-controlled Loyalty points conversion and redemption thresholds (§5.9).
class LoyaltyConversionRuleDto extends Equatable {
  const LoyaltyConversionRuleDto({
    this.id = 'rule_default',
    this.pointsRequired = 10,
    this.creditAmountKobo = 100, // ₦1 (100 kobo)
    this.minimumPoints = 200,
    this.maximumPoints = 10000,
    this.presetPoints = const [200, 500, 1000, 2500],
    this.status = 'active',
    this.version = 1,
  });

  factory LoyaltyConversionRuleDto.fromJson(Map<String, dynamic> json) {
    return LoyaltyConversionRuleDto(
      id: json['id'] as String? ?? 'rule_default',
      pointsRequired: (json['points_required'] as num?)?.toInt() ?? 10,
      creditAmountKobo: (json['credit_amount_kobo'] as num?)?.toInt() ?? 100,
      minimumPoints: (json['minimum_points'] as num?)?.toInt() ?? 200,
      maximumPoints: (json['maximum_points'] as num?)?.toInt() ?? 10000,
      presetPoints: (json['preset_points'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [200, 500, 1000, 2500],
      status: json['status'] as String? ?? 'active',
      version: (json['version'] as num?)?.toInt() ?? 1,
    );
  }

  final String id;
  final int pointsRequired;
  final int creditAmountKobo;
  final int minimumPoints;
  final int maximumPoints;
  final List<int> presetPoints;
  final String status;
  final int version;

  /// Effective points required for ₦1 (100 kobo) credit:
  /// (pointsRequired * 100) / creditAmountKobo
  double get pointsPerNaira => (pointsRequired * 100) / creditAmountKobo;

  /// Calculate Naira credit for a given number of points
  double calculateCreditNaira(int points) {
    return (points * (creditAmountKobo / 100)) / pointsRequired;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'points_required': pointsRequired,
        'credit_amount_kobo': creditAmountKobo,
        'minimum_points': minimumPoints,
        'maximum_points': maximumPoints,
        'preset_points': presetPoints,
        'status': status,
        'version': version,
      };

  @override
  List<Object?> get props => [
        id,
        pointsRequired,
        creditAmountKobo,
        minimumPoints,
        maximumPoints,
        presetPoints,
        status,
        version,
      ];
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
    this.nextTierName = 'Eco Champion (Level 3)',
    this.nextTierPointsThreshold = 5000,
    this.currentTierPointsFloor = 2500,
    this.referredFriends = const [],
    this.conversionRule = const LoyaltyConversionRuleDto(),
  });

  factory LoyaltyRewardDto.fromJson(Map<String, dynamic> json) {
    final rule = json['conversion_rule'] != null
        ? LoyaltyConversionRuleDto.fromJson(json['conversion_rule'] as Map<String, dynamic>)
        : LoyaltyConversionRuleDto(
            pointsRequired: (json['points_required'] as num?)?.toInt() ??
                (json['conversion_rate'] as num?)?.toInt() ??
                10,
            creditAmountKobo: (json['credit_amount_kobo'] as num?)?.toInt() ?? 100,
            minimumPoints: (json['minimum_points'] as num?)?.toInt() ??
                (json['min_redemption_points'] as num?)?.toInt() ??
                200,
            maximumPoints: (json['maximum_points'] as num?)?.toInt() ??
                (json['max_redemption_points'] as num?)?.toInt() ??
                10000,
            presetPoints: (json['preset_points'] as List<dynamic>?)
                    ?.map((e) => (e as num).toInt())
                    .toList() ??
                const [200, 500, 1000, 2500],
          );

    return LoyaltyRewardDto(
      pointsBalance: (json['points_balance'] as num?)?.toInt() ?? 0,
      conversionRatePointsPerNaira: rule.pointsPerNaira.round(),
      tierName: json['tier_name'] as String? ?? 'Green Explorer',
      pointsExpiringSoon: (json['points_expiring_soon'] as num?)?.toInt() ?? 0,
      referralCode: json['referral_code'] as String? ?? 'VOLT-LAGOS',
      referralCount: (json['referral_count'] as num?)?.toInt() ?? 0,
      referralEarningsNaira: (json['referral_earnings'] as num?)?.toDouble() ?? 0.0,
      nextTierName: json['next_tier_name'] as String? ?? 'Eco Champion (Level 3)',
      nextTierPointsThreshold: (json['next_tier_points_threshold'] as num?)?.toInt() ?? 5000,
      currentTierPointsFloor: (json['current_tier_points_floor'] as num?)?.toInt() ?? 2500,
      referredFriends: (json['referred_friends'] as List<dynamic>?)
              ?.map((e) => ReferredFriendDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      conversionRule: rule,
    );
  }

  final int pointsBalance;
  final int conversionRatePointsPerNaira;
  final String tierName;
  final int pointsExpiringSoon;
  final String referralCode;
  final int referralCount;
  final double referralEarningsNaira;
  final String nextTierName;
  final int nextTierPointsThreshold;
  final int currentTierPointsFloor;
  final List<ReferredFriendDto> referredFriends;
  final LoyaltyConversionRuleDto conversionRule;

  /// Admin-configured minimum points required for redemption
  int get minRedemptionPoints => conversionRule.minimumPoints;

  /// Admin-configured maximum points allowed for single redemption
  int get maxRedemptionPoints => conversionRule.maximumPoints;

  /// Admin-configured preset redemption point chips
  List<int> get redemptionPresets => conversionRule.presetPoints;

  /// Progress fraction towards the next loyalty tier (0.0 to 1.0).
  double get tierProgressFraction {
    if (nextTierPointsThreshold <= currentTierPointsFloor) return 1.0;
    final progress = (pointsBalance - currentTierPointsFloor) /
        (nextTierPointsThreshold - currentTierPointsFloor);
    return progress.clamp(0.0, 1.0);
  }

  /// Points needed to unlock the next tier.
  int get pointsToNextTier {
    final remaining = nextTierPointsThreshold - pointsBalance;
    return remaining > 0 ? remaining : 0;
  }

  /// Dynamic wallet credit calculation using admin-configured rate
  double get redeemableNaira => conversionRule.calculateCreditNaira(pointsBalance);

  Map<String, dynamic> toJson() => {
        'points_balance': pointsBalance,
        'conversion_rate': conversionRatePointsPerNaira,
        'tier_name': tierName,
        'points_expiring_soon': pointsExpiringSoon,
        'referral_code': referralCode,
        'referral_count': referralCount,
        'referral_earnings': referralEarningsNaira,
        'next_tier_name': nextTierName,
        'next_tier_points_threshold': nextTierPointsThreshold,
        'current_tier_points_floor': currentTierPointsFloor,
        'referred_friends': referredFriends.map((e) => e.toJson()).toList(),
        'conversion_rule': conversionRule.toJson(),
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
        nextTierName,
        nextTierPointsThreshold,
        currentTierPointsFloor,
        referredFriends,
        conversionRule,
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

/// Tokenized payment card (PCI-DSS compliant via Paystack authorization token).
/// Never contains primary account number (PAN) or CVV.
class SavedPaymentCardDto extends Equatable {
  const SavedPaymentCardDto({
    required this.id,
    required this.authorizationCode,
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
    this.bank = 'Paystack Verified',
    this.isDefault = false,
  });

  factory SavedPaymentCardDto.fromJson(Map<String, dynamic> json) {
    return SavedPaymentCardDto(
      id: json['id'] as String,
      authorizationCode: json['authorization_code'] as String? ?? '',
      brand: json['brand'] as String? ?? 'Card',
      last4: json['last4'] as String? ?? '****',
      expMonth: json['exp_month'] as String? ?? '12',
      expYear: json['exp_year'] as String? ?? '28',
      bank: json['bank'] as String? ?? 'Paystack Verified',
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  final String id;
  final String authorizationCode;
  final String brand;
  final String last4;
  final String expMonth;
  final String expYear;
  final String bank;
  final bool isDefault;

  String get formattedExpiry => '$expMonth/${expYear.length == 4 ? expYear.substring(2) : expYear}';

  SavedPaymentCardDto copyWith({
    String? id,
    String? authorizationCode,
    String? brand,
    String? last4,
    String? expMonth,
    String? expYear,
    String? bank,
    bool? isDefault,
  }) {
    return SavedPaymentCardDto(
      id: id ?? this.id,
      authorizationCode: authorizationCode ?? this.authorizationCode,
      brand: brand ?? this.brand,
      last4: last4 ?? this.last4,
      expMonth: expMonth ?? this.expMonth,
      expYear: expYear ?? this.expYear,
      bank: bank ?? this.bank,
      isDefault: isDefault ?? this.isDefault,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'authorization_code': authorizationCode,
        'brand': brand,
        'last4': last4,
        'exp_month': expMonth,
        'exp_year': expYear,
        'bank': bank,
        'is_default': isDefault,
      };

  @override
  List<Object?> get props => [
        id,
        authorizationCode,
        brand,
        last4,
        expMonth,
        expYear,
        bank,
        isDefault,
      ];
}

/// Dedicated NUBAN virtual bank account assigned to the user for instant funding.
class DedicatedAccountDto extends Equatable {
  const DedicatedAccountDto({
    required this.accountNumber,
    required this.bankName,
    required this.accountName,
    this.currency = 'NGN',
  });

  factory DedicatedAccountDto.fromJson(Map<String, dynamic> json) {
    return DedicatedAccountDto(
      accountNumber: json['account_number'] as String,
      bankName: json['bank_name'] as String? ?? 'Providus Bank',
      accountName: json['account_name'] as String,
      currency: json['currency'] as String? ?? 'NGN',
    );
  }

  final String accountNumber;
  final String bankName;
  final String accountName;
  final String currency;

  String get formattedAccountNumber {
    if (accountNumber.length >= 10) {
      return '${accountNumber.substring(0, 4)} ${accountNumber.substring(4, 8)} ${accountNumber.substring(8)}';
    }
    return accountNumber;
  }

  Map<String, dynamic> toJson() => {
        'account_number': accountNumber,
        'bank_name': bankName,
        'account_name': accountName,
        'currency': currency,
      };

  @override
  List<Object?> get props => [accountNumber, bankName, accountName, currency];
}

