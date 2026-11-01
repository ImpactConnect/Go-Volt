import 'package:equatable/equatable.dart';
import '../enums/domain_enums.dart';
import 'price_quote_dto.dart';

/// Itemized digital trip receipt entity (Screen 16: RIDE-12).
class TripReceiptDto extends Equatable {
  const TripReceiptDto({
    required this.receiptReference,
    required this.bookingId,
    required this.serviceType,
    required this.driverName,
    required this.vehicleModel,
    required this.vehiclePlate,
    required this.pickupAddress,
    required this.pickupTime,
    required this.dropoffAddress,
    required this.dropoffTime,
    required this.distanceKm,
    required this.durationMinutes,
    required this.priceBreakdown,
    required this.totalPaidKobo,
    this.driverRating = 4.8,
    this.driverTripsCount = 320,
    this.driverPhotoUrl,
    this.subtotalKobo,
    this.promoDiscountKobo = 0,
    this.walletCreditAppliedKobo = 0,
    this.paymentMethod = PaymentMethod.wallet,
    this.paymentReference = 'PAY-REF-001',
    this.carbonSavedGrams = 1250,
  });

  factory TripReceiptDto.fromJson(Map<String, dynamic> json) {
    return TripReceiptDto(
      receiptReference: json['receipt_reference'] as String? ?? 'GV-TRP-001',
      bookingId: json['booking_id'] as String,
      serviceType: json['service_type'] as String? ?? 'GoRide Standard',
      driverName: json['driver_name'] as String? ?? 'Driver',
      driverRating: (json['driver_rating'] as num?)?.toDouble() ?? 5.0,
      driverTripsCount: (json['driver_trips_count'] as num?)?.toInt() ?? 0,
      driverPhotoUrl: json['driver_photo_url'] as String?,
      vehicleModel: json['vehicle_model'] as String? ?? 'Go-Volt EV',
      vehiclePlate: json['vehicle_plate'] as String? ?? '',
      pickupAddress: json['pickup_address'] as String,
      pickupTime: DateTime.parse(json['pickup_time'] as String),
      dropoffAddress: json['dropoff_address'] as String,
      dropoffTime: DateTime.parse(json['dropoff_time'] as String),
      distanceKm: (json['distance_km'] as num).toDouble(),
      durationMinutes: (json['duration_minutes'] as num).toInt(),
      priceBreakdown: PriceBreakdownDto.fromJson(
        json['price_breakdown'] as Map<String, dynamic>,
      ),
      subtotalKobo: json['subtotal_kobo'] != null
          ? (json['subtotal_kobo'] as num).toInt()
          : null,
      promoDiscountKobo: (json['promo_discount_kobo'] as num?)?.toInt() ?? 0,
      walletCreditAppliedKobo:
          (json['wallet_credit_applied_kobo'] as num?)?.toInt() ?? 0,
      totalPaidKobo: (json['total_paid_kobo'] as num).toInt(),
      paymentMethod: PaymentMethod.fromString(
        json['payment_method'] as String? ?? 'WALLET',
      ),
      paymentReference: json['payment_reference'] as String? ?? 'PAY-REF-001',
      carbonSavedGrams: (json['carbon_saved_grams'] as num?)?.toInt() ?? 1250,
    );
  }

  final String receiptReference;
  final String bookingId;
  final String serviceType;
  final String driverName;
  final double driverRating;
  final int driverTripsCount;
  final String? driverPhotoUrl;
  final String vehicleModel;
  final String vehiclePlate;
  final String pickupAddress;
  final DateTime pickupTime;
  final String dropoffAddress;
  final DateTime dropoffTime;
  final double distanceKm;
  final int durationMinutes;
  final PriceBreakdownDto priceBreakdown;
  final int? subtotalKobo;
  final int promoDiscountKobo;
  final int walletCreditAppliedKobo;
  final int totalPaidKobo;
  final PaymentMethod paymentMethod;
  final String paymentReference;
  final int carbonSavedGrams;

  String get formattedTotalPaid => _formatCurrency((totalPaidKobo / 100).round());
  String get formattedSubtotal =>
      _formatCurrency(((subtotalKobo ?? totalPaidKobo) / 100).round());
  String get formattedPromoDiscount =>
      '-${_formatCurrency((promoDiscountKobo / 100).round())}';
  String get formattedCarbonSaved => '${(carbonSavedGrams / 1000).toStringAsFixed(1)} kg';

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
        'receipt_reference': receiptReference,
        'booking_id': bookingId,
        'service_type': serviceType,
        'driver_name': driverName,
        'driver_rating': driverRating,
        'driver_trips_count': driverTripsCount,
        'driver_photo_url': driverPhotoUrl,
        'vehicle_model': vehicleModel,
        'vehicle_plate': vehiclePlate,
        'pickup_address': pickupAddress,
        'pickup_time': pickupTime.toIso8601String(),
        'dropoff_address': dropoffAddress,
        'dropoff_time': dropoffTime.toIso8601String(),
        'distance_km': distanceKm,
        'duration_minutes': durationMinutes,
        'price_breakdown': priceBreakdown.toJson(),
        'subtotal_kobo': subtotalKobo,
        'promo_discount_kobo': promoDiscountKobo,
        'wallet_credit_applied_kobo': walletCreditAppliedKobo,
        'total_paid_kobo': totalPaidKobo,
        'payment_method': paymentMethod.name.toUpperCase(),
        'payment_reference': paymentReference,
        'carbon_saved_grams': carbonSavedGrams,
      };

  @override
  List<Object?> get props => [
        receiptReference,
        bookingId,
        serviceType,
        driverName,
        driverRating,
        driverTripsCount,
        driverPhotoUrl,
        vehicleModel,
        vehiclePlate,
        pickupAddress,
        pickupTime,
        dropoffAddress,
        dropoffTime,
        distanceKm,
        durationMinutes,
        priceBreakdown,
        subtotalKobo,
        promoDiscountKobo,
        walletCreditAppliedKobo,
        totalPaidKobo,
        paymentMethod,
        paymentReference,
        carbonSavedGrams,
      ];
}

