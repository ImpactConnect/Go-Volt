import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/promotion_models.dart';

class PromotionsState extends Equatable {
  const PromotionsState({
    required this.coupons,
    required this.loyaltyConfig,
    required this.referralCampaign,
  });

  final List<CouponModel> coupons;
  final LoyaltyConfigModel loyaltyConfig;
  final ReferralCampaignModel referralCampaign;

  int get activeCouponsCount => coupons.where((c) => c.isActive && !c.isExpired).length;
  int get totalRedemptionsCount => coupons.fold(0, (acc, c) => acc + c.usageCount);

  PromotionsState copyWith({
    List<CouponModel>? coupons,
    LoyaltyConfigModel? loyaltyConfig,
    ReferralCampaignModel? referralCampaign,
  }) {
    return PromotionsState(
      coupons: coupons ?? this.coupons,
      loyaltyConfig: loyaltyConfig ?? this.loyaltyConfig,
      referralCampaign: referralCampaign ?? this.referralCampaign,
    );
  }

  @override
  List<Object?> get props => [coupons, loyaltyConfig, referralCampaign];
}

class PromotionsNotifier extends StateNotifier<PromotionsState> {
  PromotionsNotifier()
      : super(
          PromotionsState(
            coupons: _seedCoupons,
            loyaltyConfig: LoyaltyConfigModel(
              pointsPerHundredNairaSpent: 5,
              koboPerPointRedeemed: BigInt.from(100), // ₦1 per point
              minRedemptionPoints: 200,
              totalCirculatingPoints: 148520,
            ),
            referralCampaign: ReferralCampaignModel(
              campaignId: 'lagos_launch_2026',
              campaignName: 'Lagos Clean Energy Referral Drive',
              referrerRewardKobo: BigInt.from(50000), // ₦500
              refereeDiscountPercent: 20.0,
              totalConversions: 842,
              isActive: true,
            ),
          ),
        );

  static final List<CouponModel> _seedCoupons = [
    CouponModel(
      id: 'cp_eco_20',
      code: 'ECO20',
      discountType: DiscountType.percentage,
      discountValue: 20.0,
      minOrderKobo: BigInt.from(100000), // ₦1,000
      maxDiscountKobo: BigInt.from(150000), // ₦1,500
      usageLimit: 1000,
      usageCount: 423,
      expiresAt: DateTime(2026, 12, 31),
      isActive: true,
      description: '20% off all electric motorcycle commute trips up to ₦1,500',
    ),
    CouponModel(
      id: 'cp_parcel_flat',
      code: 'VOLTPARCEL',
      discountType: DiscountType.fixedAmount,
      discountValue: 50000.0, // ₦500
      minOrderKobo: BigInt.from(120000), // ₦1,200
      maxDiscountKobo: null,
      usageLimit: 500,
      usageCount: 198,
      expiresAt: DateTime(2026, 11, 30),
      isActive: true,
      description: 'Flat ₦500 discount on first B2B express delivery parcel',
    ),
    CouponModel(
      id: 'cp_school_term',
      code: 'SAFESCHOOL',
      discountType: DiscountType.percentage,
      discountValue: 15.0,
      minOrderKobo: BigInt.from(250000), // ₦2,500
      maxDiscountKobo: BigInt.from(500000), // ₦5,000
      usageLimit: 200,
      usageCount: 77,
      expiresAt: DateTime(2026, 10, 31),
      isActive: true,
      description: '15% discount for verified School-Run chaperone subscriptions',
    ),
  ];

  void createCoupon({
    required String code,
    required DiscountType discountType,
    required double discountValue,
    required BigInt minOrderKobo,
    BigInt? maxDiscountKobo,
    required int usageLimit,
    required DateTime expiresAt,
    required String description,
  }) {
    final newCoupon = CouponModel(
      id: 'cp_${code.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}',
      code: code.toUpperCase().trim(),
      discountType: discountType,
      discountValue: discountValue,
      minOrderKobo: minOrderKobo,
      maxDiscountKobo: maxDiscountKobo,
      usageLimit: usageLimit,
      usageCount: 0,
      expiresAt: expiresAt,
      isActive: true,
      description: description,
    );

    state = state.copyWith(coupons: [newCoupon, ...state.coupons]);
  }

  void toggleCouponStatus(String code) {
    final updated = state.coupons.map((c) {
      if (c.code == code) {
        return c.copyWith(isActive: !c.isActive);
      }
      return c;
    }).toList();

    state = state.copyWith(coupons: updated);
  }

  void updateLoyaltyConfig({
    required int pointsPerHundredNairaSpent,
    required BigInt koboPerPointRedeemed,
    required int minRedemptionPoints,
  }) {
    state = state.copyWith(
      loyaltyConfig: state.loyaltyConfig.copyWith(
        pointsPerHundredNairaSpent: pointsPerHundredNairaSpent,
        koboPerPointRedeemed: koboPerPointRedeemed,
        minRedemptionPoints: minRedemptionPoints,
      ),
    );
  }

  void toggleReferralCampaign() {
    state = state.copyWith(
      referralCampaign: state.referralCampaign.copyWith(
        isActive: !state.referralCampaign.isActive,
      ),
    );
  }
}

final promotionsNotifierProvider =
    StateNotifierProvider<PromotionsNotifier, PromotionsState>((ref) {
  return PromotionsNotifier();
});
