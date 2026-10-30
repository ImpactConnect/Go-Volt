import 'package:equatable/equatable.dart';
import '../enums/service_code.dart';

/// Itemized financial quote / fare components.
class PriceBreakdownDto extends Equatable {

  factory PriceBreakdownDto.fromJson(Map<String, dynamic> json) {
    return PriceBreakdownDto(
      baseFare: (json['base_fare'] as num).toDouble(),
      distanceFare: (json['distance_fare'] as num).toDouble(),
      timeFare: (json['time_fare'] as num).toDouble(),
      surgeMultiplier: (json['surge_multiplier'] as num?)?.toDouble() ?? 1.0,
      surgeFare: (json['surge_fare'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      platformFee: (json['platform_fee'] as num?)?.toDouble() ?? 50.0,
      totalFare: (json['total_fare'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'NGN',
    );
  }
  const PriceBreakdownDto({
    required this.baseFare,
    required this.distanceFare,
    required this.timeFare,
    required this.totalFare,
    this.surgeMultiplier = 1.0,
    this.surgeFare = 0.0,
    this.discountAmount = 0.0,
    this.platformFee = 50.0,
    this.currency = 'NGN',
  });

  final double baseFare;
  final double distanceFare;
  final double timeFare;
  final double surgeMultiplier;
  final double surgeFare;
  final double discountAmount;
  final double platformFee;
  final double totalFare;
  final String currency;

  Map<String, dynamic> toJson() => {
        'base_fare': baseFare,
        'distance_fare': distanceFare,
        'time_fare': timeFare,
        'surge_multiplier': surgeMultiplier,
        'surge_fare': surgeFare,
        'discount_amount': discountAmount,
        'platform_fee': platformFee,
        'total_fare': totalFare,
        'currency': currency,
      };

  @override
  List<Object?> get props => [
        baseFare,
        distanceFare,
        timeFare,
        surgeMultiplier,
        surgeFare,
        discountAmount,
        platformFee,
        totalFare,
        currency,
      ];
}

/// Upfront binding fare quotation.
class QuoteDto extends Equatable {

  factory QuoteDto.fromJson(Map<String, dynamic> json) {
    return QuoteDto(
      quoteId: json['quote_id'] as String,
      serviceCode: ServiceCode.fromString(json['service_code'] as String),
      priceBreakdown: PriceBreakdownDto.fromJson(
        json['price_breakdown'] as Map<String, dynamic>,
      ),
      estimatedDurationMinutes: json['estimated_duration_minutes'] as int,
      estimatedDistanceKm: (json['estimated_distance_km'] as num).toDouble(),
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }
  const QuoteDto({
    required this.quoteId,
    required this.serviceCode,
    required this.priceBreakdown,
    required this.estimatedDurationMinutes,
    required this.estimatedDistanceKm,
    required this.expiresAt,
  });

  final String quoteId;
  final ServiceCode serviceCode;
  final PriceBreakdownDto priceBreakdown;
  final int estimatedDurationMinutes;
  final double estimatedDistanceKm;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  Map<String, dynamic> toJson() => {
        'quote_id': quoteId,
        'service_code': serviceCode.code,
        'price_breakdown': priceBreakdown.toJson(),
        'estimated_duration_minutes': estimatedDurationMinutes,
        'estimated_distance_km': estimatedDistanceKm,
        'expires_at': expiresAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        quoteId,
        serviceCode,
        priceBreakdown,
        estimatedDurationMinutes,
        estimatedDistanceKm,
        expiresAt,
      ];
}
