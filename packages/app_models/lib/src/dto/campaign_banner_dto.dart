import 'package:equatable/equatable.dart';

/// Promotional campaign or announcement banner displayed on the Home dashboard.
class CampaignBannerDto extends Equatable {
  const CampaignBannerDto({
    required this.id,
    required this.title,
    this.promoCode,
    this.subtitle,
    this.description,
    this.ctaText = 'Learn more',
    this.ctaRoute = '/ride-booking',
    this.bannerType = 'discount',
    this.discountPercentage,
    this.pointsReward,
    this.imageUrl,
    this.isActive = true,
  });

  factory CampaignBannerDto.fromJson(Map<String, dynamic> json) {
    return CampaignBannerDto(
      id: json['id'] as String,
      title: json['title'] as String,
      promoCode: json['promo_code'] as String?,
      subtitle: json['subtitle'] as String?,
      description: json['description'] as String?,
      ctaText: json['cta_text'] as String? ?? 'Learn more',
      ctaRoute: json['cta_route'] as String? ?? '/ride-booking',
      bannerType: json['banner_type'] as String? ?? 'discount',
      discountPercentage: json['discount_percentage'] as int?,
      pointsReward: json['points_reward'] as int?,
      imageUrl: json['image_url'] as String?,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  final String id;
  final String title;
  final String? promoCode;
  final String? subtitle;
  final String? description;
  final String ctaText;
  final String ctaRoute;
  final String bannerType;
  final int? discountPercentage;
  final int? pointsReward;
  final String? imageUrl;
  final bool isActive;

  bool get isReferral => bannerType == 'referral' || pointsReward != null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        if (promoCode != null) 'promo_code': promoCode,
        if (subtitle != null) 'subtitle': subtitle,
        if (description != null) 'description': description,
        'cta_text': ctaText,
        'cta_route': ctaRoute,
        'banner_type': bannerType,
        if (discountPercentage != null) 'discount_percentage': discountPercentage,
        if (pointsReward != null) 'points_reward': pointsReward,
        if (imageUrl != null) 'image_url': imageUrl,
        'is_active': isActive,
      };

  @override
  List<Object?> get props => [
        id,
        title,
        promoCode,
        subtitle,
        description,
        ctaText,
        ctaRoute,
        bannerType,
        discountPercentage,
        pointsReward,
        imageUrl,
        isActive,
      ];
}

