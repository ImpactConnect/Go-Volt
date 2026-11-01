import 'package:equatable/equatable.dart';
import 'errand_type.dart';

/// Authoritative cost and fee breakdown for an errand (Screens A6, B5, C4 & v1.6 §1761).
class ErrandQuoteDto extends Equatable {
  const ErrandQuoteDto({
    required this.id,
    required this.errandType,
    this.estimatedItemsCostKobo = 0,
    required this.serviceFeeKobo,
    required this.deliveryFeeKobo,
    this.surchargesKobo = 0,
    required this.totalKobo,
    this.isFinalQuote = true,
    this.currency = 'NGN',
    this.expiresAt,
    this.distanceKm = 0.0,
    this.estimatedMinutes = 20,
  });

  factory ErrandQuoteDto.fromJson(Map<String, dynamic> json) {
    return ErrandQuoteDto(
      id: json['id'] as String? ?? '',
      errandType: ErrandType.fromString(json['errand_type'] as String?),
      estimatedItemsCostKobo:
          (json['estimated_items_cost_kobo'] as num?)?.toInt() ?? 0,
      serviceFeeKobo: (json['service_fee_kobo'] as num?)?.toInt() ?? 0,
      deliveryFeeKobo: (json['delivery_fee_kobo'] as num?)?.toInt() ?? 0,
      surchargesKobo: (json['surcharges_kobo'] as num?)?.toInt() ?? 0,
      totalKobo: (json['total_kobo'] as num?)?.toInt() ?? 0,
      isFinalQuote: json['is_final_quote'] as bool? ?? true,
      currency: json['currency'] as String? ?? 'NGN',
      expiresAt: json['expires_at'] != null
          ? DateTime.tryParse(json['expires_at'] as String)
          : null,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      estimatedMinutes: (json['estimated_minutes'] as num?)?.toInt() ?? 20,
    );
  }

  final String id;
  final ErrandType errandType;
  final int estimatedItemsCostKobo;
  final int serviceFeeKobo;
  final int deliveryFeeKobo;
  final int surchargesKobo;
  final int totalKobo;
  final bool isFinalQuote;
  final String currency;
  final DateTime? expiresAt;
  final double distanceKm;
  final int estimatedMinutes;

  double get totalNgn => totalKobo / 100.0;
  double get serviceFeeNgn => serviceFeeKobo / 100.0;
  double get deliveryFeeNgn => deliveryFeeKobo / 100.0;
  double get estimatedItemsCostNgn => estimatedItemsCostKobo / 100.0;

  static String formatNgn(int kobo) {
    final naira = (kobo / 100).round();
    final str = naira.toString();
    final reg = RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))');
    final formatted = str.replaceAllMapped(reg, (Match m) => '${m[1]},');
    return '₦$formatted';
  }

  String get formattedTotal => formatNgn(totalKobo);
  String get formattedServiceFee => formatNgn(serviceFeeKobo);
  String get formattedDeliveryFee => formatNgn(deliveryFeeKobo);
  String get formattedItemsCost => formatNgn(estimatedItemsCostKobo);

  Map<String, dynamic> toJson() => {
        'id': id,
        'errand_type': errandType.code,
        'estimated_items_cost_kobo': estimatedItemsCostKobo,
        'service_fee_kobo': serviceFeeKobo,
        'delivery_fee_kobo': deliveryFeeKobo,
        'surcharges_kobo': surchargesKobo,
        'total_kobo': totalKobo,
        'is_final_quote': isFinalQuote,
        'currency': currency,
        if (expiresAt != null) 'expires_at': expiresAt!.toIso8601String(),
        'distance_km': distanceKm,
        'estimated_minutes': estimatedMinutes,
      };

  @override
  List<Object?> get props => [
        id,
        errandType,
        estimatedItemsCostKobo,
        serviceFeeKobo,
        deliveryFeeKobo,
        totalKobo,
        isFinalQuote,
      ];
}

