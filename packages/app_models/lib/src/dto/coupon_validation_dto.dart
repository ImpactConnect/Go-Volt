import 'package:equatable/equatable.dart';

/// Coupon validation result from backend (v1.3 §6.4 & §8.7).
///
/// Validation is advisory and does not consume the coupon until booking commit.
class CouponValidationDto extends Equatable {
  const CouponValidationDto({
    required this.code,
    required this.isValid,
    this.discountAmountKobo = 0,
    this.discountPercentage,
    this.message = 'Coupon applied successfully',
    this.expiresAt,
  });

  factory CouponValidationDto.fromJson(Map<String, dynamic> json) {
    final discountKobo = json['discount_amount_kobo'] != null
        ? (json['discount_amount_kobo'] as num).toInt()
        : (((json['discount_amount'] as num?)?.toDouble() ?? 0.0) * 100).round();

    return CouponValidationDto(
      code: json['code'] as String,
      isValid: json['is_valid'] as bool? ?? true,
      discountAmountKobo: discountKobo,
      discountPercentage: (json['discount_percentage'] as num?)?.toDouble(),
      message: json['message'] as String? ?? 'Coupon applied successfully',
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
    );
  }

  final String code;
  final bool isValid;
  final int discountAmountKobo;
  final double? discountPercentage;
  final String message;
  final DateTime? expiresAt;

  /// Formatted discount for display e.g. -₦300
  String get formattedDiscount {
    final naira = (discountAmountKobo / 100).round();
    return '-₦$naira';
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'is_valid': isValid,
        'discount_amount_kobo': discountAmountKobo,
        'discount_percentage': discountPercentage,
        'message': message,
        'expires_at': expiresAt?.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        code,
        isValid,
        discountAmountKobo,
        discountPercentage,
        message,
        expiresAt,
      ];
}
