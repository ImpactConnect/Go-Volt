import 'package:equatable/equatable.dart';
import '../enums/service_code.dart';
import 'location_dto.dart';

/// Itemized financial quote / fare components supporting integer minor units (kobo).
///
/// Complies with Technical Specification v1.3 §2.2, §5.1 & §8.1 while maintaining
/// 100% backward compatibility for legacy double parameters and const constructors.
class PriceBreakdownDto extends Equatable {
  const PriceBreakdownDto({
    int? baseAmountKobo,
    int? distanceAmountKobo,
    int? timeAmountKobo,
    int? serviceFeeKobo,
    this.surgeMultiplier = 1.0,
    int? surgeAmountKobo,
    int? discountAmountKobo,
    int? subtotalKobo,
    int? totalAmountKobo,
    int? walletCreditEligibleKobo,
    this.currency = 'NGN',
    // Legacy named parameters for backward compatibility
    double? baseFare,
    double? distanceFare,
    double? timeFare,
    double? platformFee,
    double? totalFare,
    double? discountAmount,
    double? surgeFare,
  })  : _baseAmountKobo = baseAmountKobo,
        _distanceAmountKobo = distanceAmountKobo,
        _timeAmountKobo = timeAmountKobo,
        _serviceFeeKobo = serviceFeeKobo,
        _surgeAmountKobo = surgeAmountKobo,
        _discountAmountKobo = discountAmountKobo,
        _subtotalKobo = subtotalKobo,
        _totalAmountKobo = totalAmountKobo,
        _walletCreditEligibleKobo = walletCreditEligibleKobo,
        _baseFare = baseFare,
        _distanceFare = distanceFare,
        _timeFare = timeFare,
        _platformFee = platformFee,
        _totalFare = totalFare,
        _discountAmount = discountAmount,
        _surgeFare = surgeFare;

  /// Factory supporting both new v1.3 kobo JSON and legacy double JSON.
  factory PriceBreakdownDto.fromJson(Map<String, dynamic> json) {
    final baseKobo = json['base_amount_kobo'] != null
        ? (json['base_amount_kobo'] as num).toInt()
        : (((json['base_fare'] as num?)?.toDouble() ?? 0.0) * 100).round();

    final distKobo = json['distance_amount_kobo'] != null
        ? (json['distance_amount_kobo'] as num).toInt()
        : (((json['distance_fare'] as num?)?.toDouble() ?? 0.0) * 100).round();

    final timeKobo = json['time_amount_kobo'] != null
        ? (json['time_amount_kobo'] as num).toInt()
        : (((json['time_fare'] as num?)?.toDouble() ?? 0.0) * 100).round();

    final feeKobo = json['service_fee_kobo'] != null
        ? (json['service_fee_kobo'] as num).toInt()
        : (json['platform_fee'] != null
            ? ((json['platform_fee'] as num).toDouble() * 100).round()
            : 20000);

    final discKobo = json['discount_amount_kobo'] != null
        ? (json['discount_amount_kobo'] as num).toInt()
        : (((json['discount_amount'] as num?)?.toDouble() ?? 0.0) * 100).round();

    final surgeKobo = json['surge_amount_kobo'] != null
        ? (json['surge_amount_kobo'] as num).toInt()
        : (((json['surge_fare'] as num?)?.toDouble() ?? 0.0) * 100).round();

    final totalKobo = json['total_amount_kobo'] != null
        ? (json['total_amount_kobo'] as num).toInt()
        : (json['total_fare'] != null
            ? ((json['total_fare'] as num).toDouble() * 100).round()
            : null);

    return PriceBreakdownDto(
      baseAmountKobo: baseKobo,
      distanceAmountKobo: distKobo,
      timeAmountKobo: timeKobo,
      serviceFeeKobo: feeKobo,
      surgeMultiplier: (json['surge_multiplier'] as num?)?.toDouble() ?? 1.0,
      surgeAmountKobo: surgeKobo,
      discountAmountKobo: discKobo,
      subtotalKobo: json['subtotal_kobo'] != null
          ? (json['subtotal_kobo'] as num).toInt()
          : null,
      totalAmountKobo: totalKobo,
      walletCreditEligibleKobo: json['wallet_credit_eligible_kobo'] != null
          ? (json['wallet_credit_eligible_kobo'] as num).toInt()
          : null,
      currency: json['currency'] as String? ?? 'NGN',
    );
  }

  final double surgeMultiplier;
  final String currency;

  final int? _baseAmountKobo;
  final int? _distanceAmountKobo;
  final int? _timeAmountKobo;
  final int? _serviceFeeKobo;
  final int? _surgeAmountKobo;
  final int? _discountAmountKobo;
  final int? _subtotalKobo;
  final int? _totalAmountKobo;
  final int? _walletCreditEligibleKobo;

  final double? _baseFare;
  final double? _distanceFare;
  final double? _timeFare;
  final double? _platformFee;
  final double? _totalFare;
  final double? _discountAmount;
  final double? _surgeFare;

  /// Base fare in integer kobo.
  int get baseAmountKobo =>
      _baseAmountKobo ?? (_baseFare != null ? (_baseFare * 100).round() : 0);

  /// Distance charge in integer kobo.
  int get distanceAmountKobo =>
      _distanceAmountKobo ??
      (_distanceFare != null ? (_distanceFare * 100).round() : 0);

  /// Time charge in integer kobo.
  int get timeAmountKobo =>
      _timeAmountKobo ?? (_timeFare != null ? (_timeFare * 100).round() : 0);

  /// Service / platform fee in integer kobo.
  int get serviceFeeKobo =>
      _serviceFeeKobo ?? (_platformFee != null ? (_platformFee * 100).round() : 20000);

  /// Surge fare in integer kobo.
  int get surgeAmountKobo =>
      _surgeAmountKobo ?? (_surgeFare != null ? (_surgeFare * 100).round() : 0);

  /// Promotional discount in integer kobo.
  int get discountAmountKobo =>
      _discountAmountKobo ??
      (_discountAmount != null ? (_discountAmount * 100).round() : 0);

  /// Pre-discount subtotal in integer kobo.
  int get subtotalKobo =>
      _subtotalKobo ??
      (baseAmountKobo +
          distanceAmountKobo +
          timeAmountKobo +
          serviceFeeKobo +
          surgeAmountKobo);

  /// Final payable amount in integer kobo.
  int get totalAmountKobo =>
      _totalAmountKobo ??
      (_totalFare != null
          ? (_totalFare * 100).round()
          : (subtotalKobo - discountAmountKobo).clamp(0, 999999999));

  /// Eligible ride-wallet credit in integer kobo.
  int get walletCreditEligibleKobo =>
      _walletCreditEligibleKobo ?? totalAmountKobo;

  // --- Backward-Compatibility Getters (returns Naira double) ---

  double get baseFare => _baseFare ?? (baseAmountKobo / 100.0);
  double get distanceFare => _distanceFare ?? (distanceAmountKobo / 100.0);
  double get timeFare => _timeFare ?? (timeAmountKobo / 100.0);
  double get platformFee => _platformFee ?? (serviceFeeKobo / 100.0);
  double get surgeFare => _surgeFare ?? (surgeAmountKobo / 100.0);
  double get discountAmount => _discountAmount ?? (discountAmountKobo / 100.0);
  double get totalFare => _totalFare ?? (totalAmountKobo / 100.0);

  // --- Display Formatted Helpers ---

  String get formattedBaseNaira => _formatCurrency((baseAmountKobo / 100).round());
  String get formattedDistanceNaira => _formatCurrency((distanceAmountKobo / 100).round());
  String get formattedTimeNaira => _formatCurrency((timeAmountKobo / 100).round());
  String get formattedServiceFeeNaira => _formatCurrency((serviceFeeKobo / 100).round());
  String get formattedSubtotalNaira => _formatCurrency((subtotalKobo / 100).round());
  String get formattedDiscountNaira => '-${_formatCurrency((discountAmountKobo / 100).round())}';
  String get formattedTotalNaira => _formatCurrency((totalAmountKobo / 100).round());

  String get formattedBaseAmount => formattedBaseNaira;
  String get formattedDistanceAmount => formattedDistanceNaira;
  String get formattedTimeAmount => formattedTimeNaira;
  String get formattedServiceFee => formattedServiceFeeNaira;
  String get formattedTotalAmount => formattedTotalNaira;
  String get estimatedRangeDisplay => formattedRange;

  /// Formatted estimated range matching Screen 9: ₦3,200 (₦2,800 - ₦3,500)
  String get formattedRange {
    final low = ((totalAmountKobo * 0.9) / 100).round();
    final high = ((totalAmountKobo * 1.1) / 100).round();
    return '(${_formatCurrency(low)} - ${_formatCurrency(high)})';
  }

  static String _formatCurrency(int amount) {
    final str = amount.abs().toString();
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
        'base_amount_kobo': baseAmountKobo,
        'distance_amount_kobo': distanceAmountKobo,
        'time_amount_kobo': timeAmountKobo,
        'service_fee_kobo': serviceFeeKobo,
        'surge_multiplier': surgeMultiplier,
        'surge_amount_kobo': surgeAmountKobo,
        'discount_amount_kobo': discountAmountKobo,
        'subtotal_kobo': subtotalKobo,
        'total_amount_kobo': totalAmountKobo,
        'wallet_credit_eligible_kobo': walletCreditEligibleKobo,
        'currency': currency,
        // Legacy keys for backward compatibility
        'base_fare': baseFare,
        'distance_fare': distanceFare,
        'time_fare': timeFare,
        'platform_fee': platformFee,
        'total_fare': totalFare,
        'discount_amount': discountAmount,
        'surge_fare': surgeFare,
      };

  @override
  List<Object?> get props => [
        baseAmountKobo,
        distanceAmountKobo,
        timeAmountKobo,
        serviceFeeKobo,
        surgeMultiplier,
        surgeAmountKobo,
        discountAmountKobo,
        subtotalKobo,
        totalAmountKobo,
        walletCreditEligibleKobo,
        currency,
        baseFare,
        distanceFare,
        timeFare,
        totalFare,
      ];
}

/// Upfront binding fare quotation.
class QuoteDto extends Equatable {
  const QuoteDto({
    required this.quoteId,
    required this.serviceCode,
    required this.priceBreakdown,
    required this.estimatedDurationMinutes,
    required this.estimatedDistanceKm,
    required this.expiresAt,
    this.rideCategoryId,
    this.pickupLocation,
    this.dropoffLocation,
    this.isServiceable = true,
    this.serviceabilityMessage = 'Rides are available in this area',
    this.trafficCondition = 'Light traffic',
  });

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
      rideCategoryId: json['ride_category_id'] as String?,
      pickupLocation: json['pickup_location'] != null
          ? LocationDto.fromJson(json['pickup_location'] as Map<String, dynamic>)
          : null,
      dropoffLocation: json['dropoff_location'] != null
          ? LocationDto.fromJson(json['dropoff_location'] as Map<String, dynamic>)
          : null,
      isServiceable: json['is_serviceable'] as bool? ?? true,
      serviceabilityMessage: json['serviceability_message'] as String? ??
          'Rides are available in this area',
      trafficCondition: json['traffic_condition'] as String? ?? 'Light traffic',
    );
  }

  final String quoteId;
  final ServiceCode serviceCode;
  final PriceBreakdownDto priceBreakdown;
  final int estimatedDurationMinutes;
  final double estimatedDistanceKm;
  final DateTime expiresAt;
  final String? rideCategoryId;
  final LocationDto? pickupLocation;
  final LocationDto? dropoffLocation;
  final bool isServiceable;
  final String serviceabilityMessage;
  final String trafficCondition;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

  /// Formatted duration and distance string e.g. "12 min • 8.4 km"
  String get formattedJourneyOverview =>
      '$estimatedDurationMinutes min • ${estimatedDistanceKm.toStringAsFixed(1)} km';

  Map<String, dynamic> toJson() => {
        'quote_id': quoteId,
        'service_code': serviceCode.code,
        'price_breakdown': priceBreakdown.toJson(),
        'estimated_duration_minutes': estimatedDurationMinutes,
        'estimated_distance_km': estimatedDistanceKm,
        'expires_at': expiresAt.toIso8601String(),
        'ride_category_id': rideCategoryId,
        'pickup_location': pickupLocation?.toJson(),
        'dropoff_location': dropoffLocation?.toJson(),
        'is_serviceable': isServiceable,
        'serviceability_message': serviceabilityMessage,
        'traffic_condition': trafficCondition,
      };

  @override
  List<Object?> get props => [
        quoteId,
        serviceCode,
        priceBreakdown,
        estimatedDurationMinutes,
        estimatedDistanceKm,
        expiresAt,
        rideCategoryId,
        pickupLocation,
        dropoffLocation,
        isServiceable,
        serviceabilityMessage,
        trafficCondition,
      ];
}
