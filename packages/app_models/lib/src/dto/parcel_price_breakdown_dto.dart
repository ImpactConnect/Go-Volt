import 'package:equatable/equatable.dart';

/// DTO for integer-minor unit parcel price breakdowns (Screen 7 & Screen 16).
///
/// Features:
/// - Base fare (e.g. ₦2,000 = 200,000 kobo)
/// - Distance fare (e.g. 12.4 km = ₦300 = 30,000 kobo)
/// - Package handling fee (e.g. ₦200 = 20,000 kobo)
/// - Insurance fee (e.g. ₦0 = 0 kobo)
/// - Discount amount (e.g. ₦500 from promo code)
/// - Guaranteed integer math: total = base + distance + handling + insurance - discount.
class ParcelPriceBreakdownDto extends Equatable {
  const ParcelPriceBreakdownDto({
    required this.baseFareKobo,
    required this.distanceFareKobo,
    required this.handlingFareKobo,
    this.insuranceFareKobo = 0,
    this.discountKobo = 0,
    this.currency = 'NGN',
    this.distanceKm = 12.4,
    this.estimatedMinutes = 25,
  });

  factory ParcelPriceBreakdownDto.fromJson(Map<String, dynamic> json) {
    return ParcelPriceBreakdownDto(
      baseFareKobo: (json['base_fare_kobo'] as num?)?.toInt() ?? 200000,
      distanceFareKobo: (json['distance_fare_kobo'] as num?)?.toInt() ?? 30000,
      handlingFareKobo: (json['handling_fare_kobo'] as num?)?.toInt() ?? 20000,
      insuranceFareKobo: (json['insurance_fare_kobo'] as num?)?.toInt() ?? 0,
      discountKobo: (json['discount_kobo'] as num?)?.toInt() ?? 0,
      currency: json['currency'] as String? ?? 'NGN',
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 12.4,
      estimatedMinutes: (json['estimated_minutes'] as num?)?.toInt() ?? 25,
    );
  }

  final int baseFareKobo;
  final int distanceFareKobo;
  final int handlingFareKobo;
  final int insuranceFareKobo;
  final int discountKobo;
  final String currency;
  final double distanceKm;
  final int estimatedMinutes;

  int get subtotalKobo =>
      baseFareKobo + distanceFareKobo + handlingFareKobo + insuranceFareKobo;

  int get totalAmountKobo {
    final net = subtotalKobo - discountKobo;
    return net > 0 ? net : 0;
  }

  String _formatKobo(int kobo) {
    final naira = (kobo / 100).round();
    final parts = naira.toString().replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match m) => '${m[1]},',
        );
    return '₦$parts';
  }

  String get formattedBaseFare => _formatKobo(baseFareKobo);
  String get formattedDistanceFare => _formatKobo(distanceFareKobo);
  String get formattedHandlingFare => _formatKobo(handlingFareKobo);
  String get formattedInsuranceFare => _formatKobo(insuranceFareKobo);
  String get formattedDiscount => _formatKobo(discountKobo);
  String get formattedTotalFare => _formatKobo(totalAmountKobo);

  String get distanceLabel => '${distanceKm.toStringAsFixed(1)} km';

  ParcelPriceBreakdownDto copyWith({
    int? baseFareKobo,
    int? distanceFareKobo,
    int? handlingFareKobo,
    int? insuranceFareKobo,
    int? discountKobo,
    String? currency,
    double? distanceKm,
    int? estimatedMinutes,
  }) {
    return ParcelPriceBreakdownDto(
      baseFareKobo: baseFareKobo ?? this.baseFareKobo,
      distanceFareKobo: distanceFareKobo ?? this.distanceFareKobo,
      handlingFareKobo: handlingFareKobo ?? this.handlingFareKobo,
      insuranceFareKobo: insuranceFareKobo ?? this.insuranceFareKobo,
      discountKobo: discountKobo ?? this.discountKobo,
      currency: currency ?? this.currency,
      distanceKm: distanceKm ?? this.distanceKm,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'base_fare_kobo': baseFareKobo,
      'distance_fare_kobo': distanceFareKobo,
      'handling_fare_kobo': handlingFareKobo,
      'insurance_fare_kobo': insuranceFareKobo,
      'discount_kobo': discountKobo,
      'total_amount_kobo': totalAmountKobo,
      'currency': currency,
      'distance_km': distanceKm,
      'estimated_minutes': estimatedMinutes,
    };
  }

  static const ParcelPriceBreakdownDto defaultBreakdown =
      ParcelPriceBreakdownDto(
    baseFareKobo: 200000,
    distanceFareKobo: 30000,
    handlingFareKobo: 20000,
    insuranceFareKobo: 0,
    discountKobo: 0,
    currency: 'NGN',
    distanceKm: 12.4,
    estimatedMinutes: 25,
  );

  @override
  List<Object?> get props => [
        baseFareKobo,
        distanceFareKobo,
        handlingFareKobo,
        insuranceFareKobo,
        discountKobo,
        currency,
        distanceKm,
        estimatedMinutes,
      ];
}
