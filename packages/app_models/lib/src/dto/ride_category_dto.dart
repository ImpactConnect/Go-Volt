import 'package:equatable/equatable.dart';

/// Backend-managed ride catalogue category (v1.3 §5.4 & §6.8.1).
///
/// Categories are dynamic records published through the Admin Ride Configuration
/// module, NOT client-side constants or hardcoded formulas.
class RideCategoryDto extends Equatable {
  const RideCategoryDto({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.passengerCapacity,
    required this.baseFareKobo,
    this.etaMinutes = 3,
    this.capacityLabel = '3 Seats',
    this.features = const ['AC', '3 Seats', 'Trusted riders'],
    this.iconKey = 'electric_car',
    this.imageUrl,
    this.serviceAreaId,
    this.pricingRuleId,
    this.isAvailable = true,
    this.displayOrder = 0,
    this.co2OffsetGrams = 850,
  });

  factory RideCategoryDto.fromJson(Map<String, dynamic> json) {
    final baseKobo = json['base_fare_kobo'] != null
        ? (json['base_fare_kobo'] as num).toInt()
        : (((json['base_fare'] as num?)?.toDouble() ?? 2800.0) * 100).round();

    return RideCategoryDto(
      id: json['id'] as String,
      code: json['code'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      passengerCapacity: (json['passenger_capacity'] as num?)?.toInt() ?? 3,
      baseFareKobo: baseKobo,
      etaMinutes: (json['eta_minutes'] as num?)?.toInt() ?? 3,
      capacityLabel: json['capacity_label'] as String? ??
          '${(json['passenger_capacity'] as num?)?.toInt() ?? 3} Seats',
      features: (json['features'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['AC', '3 Seats', 'Trusted riders'],
      iconKey: json['icon_key'] as String? ?? 'electric_car',
      imageUrl: json['image_url'] as String?,
      serviceAreaId: json['service_area_id'] as String?,
      pricingRuleId: json['pricing_rule_id'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      displayOrder: (json['display_order'] as num?)?.toInt() ?? 0,
      co2OffsetGrams: (json['co2_offset_grams'] as num?)?.toInt() ?? 850,
    );
  }

  final String id;
  final String code;
  final String name;
  final String description;
  final int passengerCapacity;
  final int baseFareKobo;
  final int etaMinutes;
  final String capacityLabel;
  final List<String> features;
  final String iconKey;
  final String? imageUrl;
  final String? serviceAreaId;
  final String? pricingRuleId;
  final bool isAvailable;
  final int displayOrder;
  final int co2OffsetGrams;

  /// Formatted Naira price for upfront display (e.g. ₦2,800).
  String get formattedPrice {
    final naira = (baseFareKobo / 100).round();
    return _formatCurrency(naira);
  }

  /// Alias for formattedPrice matching booking screen naming.
  String get formattedBaseFare => formattedPrice;

  /// Backward-compatibility getter for base fare in Naira.
  double get baseFare => baseFareKobo / 100.0;

  static String _formatCurrency(int amount) {
    final str = amount.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = str.length - 1; i >= 0; i--) {
      buffer.write(str[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write(',');
      }
    }
    return '₦${buffer.toString().split('').reversed.join()}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'name': name,
        'description': description,
        'passenger_capacity': passengerCapacity,
        'base_fare_kobo': baseFareKobo,
        'eta_minutes': etaMinutes,
        'capacity_label': capacityLabel,
        'features': features,
        'icon_key': iconKey,
        'image_url': imageUrl,
        'service_area_id': serviceAreaId,
        'pricing_rule_id': pricingRuleId,
        'is_available': isAvailable,
        'display_order': displayOrder,
        'co2_offset_grams': co2OffsetGrams,
      };

  RideCategoryDto copyWith({
    String? id,
    String? code,
    String? name,
    String? description,
    int? passengerCapacity,
    int? baseFareKobo,
    int? etaMinutes,
    String? capacityLabel,
    List<String>? features,
    String? iconKey,
    String? imageUrl,
    String? serviceAreaId,
    String? pricingRuleId,
    bool? isAvailable,
    int? displayOrder,
    int? co2OffsetGrams,
  }) {
    return RideCategoryDto(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      description: description ?? this.description,
      passengerCapacity: passengerCapacity ?? this.passengerCapacity,
      baseFareKobo: baseFareKobo ?? this.baseFareKobo,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      capacityLabel: capacityLabel ?? this.capacityLabel,
      features: features ?? this.features,
      iconKey: iconKey ?? this.iconKey,
      imageUrl: imageUrl ?? this.imageUrl,
      serviceAreaId: serviceAreaId ?? this.serviceAreaId,
      pricingRuleId: pricingRuleId ?? this.pricingRuleId,
      isAvailable: isAvailable ?? this.isAvailable,
      displayOrder: displayOrder ?? this.displayOrder,
      co2OffsetGrams: co2OffsetGrams ?? this.co2OffsetGrams,
    );
  }

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        description,
        passengerCapacity,
        baseFareKobo,
        etaMinutes,
        capacityLabel,
        features,
        iconKey,
        imageUrl,
        serviceAreaId,
        pricingRuleId,
        isAvailable,
        displayOrder,
        co2OffsetGrams,
      ];
}
