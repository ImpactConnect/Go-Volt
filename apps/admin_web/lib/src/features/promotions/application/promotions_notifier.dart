import 'dart:async';
import 'package:api_client/api_client.dart';
import 'package:app_config/app_config.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/promotion_models.dart';

class PromotionsState extends Equatable {
  const PromotionsState({
    required this.coupons,
    required this.loyaltyConfig,
    required this.referralCampaign,
    this.isLoading = false,
    this.statusMessage,
  });

  final List<CouponModel> coupons;
  final LoyaltyConfigModel loyaltyConfig;
  final ReferralCampaignModel referralCampaign;
  final bool isLoading;
  final String? statusMessage;

  int get activeCouponsCount => coupons.where((c) => c.isActive && !c.isExpired).length;
  int get totalRedemptionsCount => coupons.fold(0, (acc, c) => acc + c.usageCount);

  PromotionsState copyWith({
    List<CouponModel>? coupons,
    LoyaltyConfigModel? loyaltyConfig,
    ReferralCampaignModel? referralCampaign,
    bool? isLoading,
    String? statusMessage,
  }) {
    return PromotionsState(
      coupons: coupons ?? this.coupons,
      loyaltyConfig: loyaltyConfig ?? this.loyaltyConfig,
      referralCampaign: referralCampaign ?? this.referralCampaign,
      isLoading: isLoading ?? this.isLoading,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }

  @override
  List<Object?> get props => [coupons, loyaltyConfig, referralCampaign, isLoading, statusMessage];
}

class PromotionsNotifier extends StateNotifier<PromotionsState> {
  PromotionsNotifier({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(config: AppConfig.current),
        super(
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
        ) {
    loadFromBackend();
  }

  final ApiClient _apiClient;

  Future<void> loadFromBackend() async {
    try {
      final couponRes = await _apiClient.dio.get<Map<String, dynamic>>('/api/v1/coupons/admin');
      if (couponRes.data != null) {
        final list = (couponRes.data!['data'] as List<dynamic>? ?? []);
        if (list.isNotEmpty) {
          final loadedCoupons = list.map((item) {
            final m = item as Map<String, dynamic>;
            final discountVal = (m['discount_amount'] as num?)?.toDouble() ?? 500.0;
            final isPercent = m['discount_type'] == 'percentage';
            return CouponModel(
              id: m['id'] as String? ?? 'cp_${m['code']}',
              code: (m['code'] as String? ?? '').toUpperCase(),
              discountType: isPercent ? DiscountType.percentage : DiscountType.fixedAmount,
              discountValue: isPercent ? discountVal : discountVal * 100,
              minOrderKobo: BigInt.from(((m['min_order_amount'] as num?)?.toDouble() ?? 1000.0) * 100),
              usageLimit: (m['usage_limit'] as num?)?.toInt() ?? 1000,
              usageCount: (m['usage_count'] as num?)?.toInt() ?? 0,
              expiresAt: DateTime.tryParse(m['expiry_date'] as String? ?? '') ??
                  DateTime.now().add(const Duration(days: 30)),
              isActive: m['is_active'] as bool? ?? true,
              description: m['description'] as String? ?? '',
            );
          }).toList();
          state = state.copyWith(coupons: loadedCoupons);
        }
      }

      final loyaltyRes = await _apiClient.dio.get<Map<String, dynamic>>('/api/v1/loyalty/admin/conversion-rules');
      if (loyaltyRes.data != null) {
        final rules = (loyaltyRes.data!['data'] as List<dynamic>? ?? []);
        if (rules.isNotEmpty) {
          final r = rules.first as Map<String, dynamic>;
          final ptsReq = (r['points_required'] as num?)?.toInt() ?? 10;
          final creditKobo = (r['credit_amount_kobo'] as num?)?.toInt() ?? 100;
          final minPts = (r['minimum_points'] as num?)?.toInt() ?? 200;
          final maxPts = (r['maximum_points'] as num?)?.toInt() ?? 10000;
          final presets = (r['preset_points'] as List<dynamic>?)?.map((e) => (e as num).toInt()).toList() ??
              const [200, 500, 1000, 2500];

          state = state.copyWith(
            loyaltyConfig: state.loyaltyConfig.copyWith(
              pointsRequired: ptsReq,
              creditAmountKobo: creditKobo,
              koboPerPointRedeemed: BigInt.from(creditKobo ~/ ptsReq),
              minRedemptionPoints: minPts,
              maxRedemptionPoints: maxPts,
              presetPoints: presets,
            ),
          );
        }
      }
    } catch (_) {
      // Offline fallback
    }
  }

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

  void _safeBackendCall(Future<void> Function() call) {
    unawaited(() async {
      try {
        await call();
      } catch (_) {}
    }());
  }

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
    final cleanCode = code.toUpperCase().trim();
    final newCoupon = CouponModel(
      id: 'cp_${cleanCode.toLowerCase()}_${DateTime.now().millisecondsSinceEpoch}',
      code: cleanCode,
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

    _safeBackendCall(() async {
      await _apiClient.dio.post<Map<String, dynamic>>(
        '/api/v1/coupons/admin',
        data: {
          'code': cleanCode,
          'discount_amount': discountType == DiscountType.percentage ? discountValue : (discountValue / 100),
          'min_order_amount': (minOrderKobo / BigInt.from(100)).toDouble(),
          'expiry_date': expiresAt.toIso8601String(),
          'description': description,
        },
      );
    });
  }

  void toggleCouponStatus(String code) {
    final updated = state.coupons.map((c) {
      if (c.code == code) {
        return c.copyWith(isActive: !c.isActive);
      }
      return c;
    }).toList();

    state = state.copyWith(coupons: updated);

    _safeBackendCall(() async {
      await _apiClient.dio.patch<Map<String, dynamic>>(
        '/api/v1/coupons/admin/$code/toggle',
      );
    });
  }

  void updateLoyaltyConfig({
    required int pointsPerHundredNairaSpent,
    BigInt? koboPerPointRedeemed,
    required int minRedemptionPoints,
    int? maxRedemptionPoints,
    int? pointsRequired,
    int? creditAmountKobo,
    List<int>? presetPoints,
  }) {
    final effectivePointsReq = pointsRequired ?? 10;
    final effectiveCreditKobo = creditAmountKobo ?? (koboPerPointRedeemed != null ? (koboPerPointRedeemed.toInt() * effectivePointsReq) : 100);
    final calculatedKoboPerPoint = koboPerPointRedeemed ?? BigInt.from(effectiveCreditKobo ~/ effectivePointsReq);
    final effectivePresets = presetPoints ?? state.loyaltyConfig.presetPoints;
    final effectiveMax = maxRedemptionPoints ?? state.loyaltyConfig.maxRedemptionPoints;

    state = state.copyWith(
      loyaltyConfig: state.loyaltyConfig.copyWith(
        pointsPerHundredNairaSpent: pointsPerHundredNairaSpent,
        koboPerPointRedeemed: calculatedKoboPerPoint,
        minRedemptionPoints: minRedemptionPoints,
        maxRedemptionPoints: effectiveMax,
        pointsRequired: effectivePointsReq,
        creditAmountKobo: effectiveCreditKobo,
        presetPoints: effectivePresets,
      ),
    );

    _safeBackendCall(() async {
      await _apiClient.dio.put<Map<String, dynamic>>(
        '/api/v1/loyalty/admin/conversion-rules',
        data: {
          'points_required': effectivePointsReq,
          'credit_amount_kobo': effectiveCreditKobo,
          'minimum_points': minRedemptionPoints,
          'maximum_points': effectiveMax,
          'preset_points': effectivePresets,
        },
      );
    });
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
