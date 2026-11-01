import 'package:equatable/equatable.dart';

enum DiscountType {
  percentage,
  fixedAmount,
}

class CouponModel extends Equatable {
  const CouponModel({
    required this.id,
    required this.code,
    required this.discountType,
    required this.discountValue,
    required this.minOrderKobo,
    this.maxDiscountKobo,
    required this.usageLimit,
    required this.usageCount,
    required this.expiresAt,
    required this.isActive,
    required this.description,
  });

  final String id;
  final String code;
  final DiscountType discountType;
  final double discountValue; // percentage (e.g. 20 for 20%) or kobo for fixed
  final BigInt minOrderKobo;
  final BigInt? maxDiscountKobo;
  final int usageLimit;
  final int usageCount;
  final DateTime expiresAt;
  final bool isActive;
  final String description;

  String get formattedDiscount {
    if (discountType == DiscountType.percentage) {
      return '${discountValue.toStringAsFixed(0)}% OFF';
    } else {
      return '₦${(BigInt.from(discountValue) / BigInt.from(100)).toStringAsFixed(0)} OFF';
    }
  }

  String get formattedMinOrder => '₦${(minOrderKobo / BigInt.from(100)).toStringAsFixed(0)}';

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  CouponModel copyWith({
    String? id,
    String? code,
    DiscountType? discountType,
    double? discountValue,
    BigInt? minOrderKobo,
    BigInt? maxDiscountKobo,
    int? usageLimit,
    int? usageCount,
    DateTime? expiresAt,
    bool? isActive,
    String? description,
  }) {
    return CouponModel(
      id: id ?? this.id,
      code: code ?? this.code,
      discountType: discountType ?? this.discountType,
      discountValue: discountValue ?? this.discountValue,
      minOrderKobo: minOrderKobo ?? this.minOrderKobo,
      maxDiscountKobo: maxDiscountKobo ?? this.maxDiscountKobo,
      usageLimit: usageLimit ?? this.usageLimit,
      usageCount: usageCount ?? this.usageCount,
      expiresAt: expiresAt ?? this.expiresAt,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
    );
  }

  @override
  List<Object?> get props => [
        id,
        code,
        discountType,
        discountValue,
        minOrderKobo,
        maxDiscountKobo,
        usageLimit,
        usageCount,
        expiresAt,
        isActive,
        description,
      ];
}

class LoyaltyConfigModel extends Equatable {
  const LoyaltyConfigModel({
    required this.pointsPerHundredNairaSpent,
    required this.koboPerPointRedeemed,
    required this.minRedemptionPoints,
    required this.totalCirculatingPoints,
    this.pointsRequired = 10,
    this.creditAmountKobo = 100, // ₦1
    this.maxRedemptionPoints = 10000,
    this.presetPoints = const [200, 500, 1000, 2500],
  });

  final int pointsPerHundredNairaSpent;
  final BigInt koboPerPointRedeemed; // e.g. 100 kobo (₦1) per point
  final int minRedemptionPoints;
  final int totalCirculatingPoints;
  final int pointsRequired;
  final int creditAmountKobo;
  final int maxRedemptionPoints;
  final List<int> presetPoints;

  String get formattedRate => '$pointsRequired pts = ₦${(creditAmountKobo / 100).toStringAsFixed(0)}';
  String get formattedPresetChips => presetPoints.join(', ');

  LoyaltyConfigModel copyWith({
    int? pointsPerHundredNairaSpent,
    BigInt? koboPerPointRedeemed,
    int? minRedemptionPoints,
    int? totalCirculatingPoints,
    int? pointsRequired,
    int? creditAmountKobo,
    int? maxRedemptionPoints,
    List<int>? presetPoints,
  }) {
    return LoyaltyConfigModel(
      pointsPerHundredNairaSpent: pointsPerHundredNairaSpent ?? this.pointsPerHundredNairaSpent,
      koboPerPointRedeemed: koboPerPointRedeemed ?? this.koboPerPointRedeemed,
      minRedemptionPoints: minRedemptionPoints ?? this.minRedemptionPoints,
      totalCirculatingPoints: totalCirculatingPoints ?? this.totalCirculatingPoints,
      pointsRequired: pointsRequired ?? this.pointsRequired,
      creditAmountKobo: creditAmountKobo ?? this.creditAmountKobo,
      maxRedemptionPoints: maxRedemptionPoints ?? this.maxRedemptionPoints,
      presetPoints: presetPoints ?? this.presetPoints,
    );
  }

  @override
  List<Object?> get props => [
        pointsPerHundredNairaSpent,
        koboPerPointRedeemed,
        minRedemptionPoints,
        totalCirculatingPoints,
        pointsRequired,
        creditAmountKobo,
        maxRedemptionPoints,
        presetPoints,
      ];
}

class ReferralCampaignModel extends Equatable {
  const ReferralCampaignModel({
    required this.campaignId,
    required this.campaignName,
    required this.referrerRewardKobo,
    required this.refereeDiscountPercent,
    required this.totalConversions,
    required this.isActive,
  });

  final String campaignId;
  final String campaignName;
  final BigInt referrerRewardKobo; // e.g. ₦500 (50,000 kobo) wallet credit
  final double refereeDiscountPercent; // e.g. 25% off first 2 rides
  final int totalConversions;
  final bool isActive;

  String get formattedReferrerReward => '₦${(referrerRewardKobo / BigInt.from(100)).toStringAsFixed(0)}';

  ReferralCampaignModel copyWith({
    String? campaignId,
    String? campaignName,
    BigInt? referrerRewardKobo,
    double? refereeDiscountPercent,
    int? totalConversions,
    bool? isActive,
  }) {
    return ReferralCampaignModel(
      campaignId: campaignId ?? this.campaignId,
      campaignName: campaignName ?? this.campaignName,
      referrerRewardKobo: referrerRewardKobo ?? this.referrerRewardKobo,
      refereeDiscountPercent: refereeDiscountPercent ?? this.refereeDiscountPercent,
      totalConversions: totalConversions ?? this.totalConversions,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        campaignId,
        campaignName,
        referrerRewardKobo,
        refereeDiscountPercent,
        totalConversions,
        isActive,
      ];
}
