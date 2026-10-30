import 'package:app_models/app_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Step 1: Domain Models & Financial Contracts (amount_kobo) Unit Tests', () {
    test('PriceBreakdownDto enforces integer kobo and zero floating-point error', () {
      // ₦1,500 base, ₦1,100 distance, ₦300 time, ₦200 service fee = ₦3,100 subtotal
      // - ₦300 discount = ₦2,800 total
      const breakdown = PriceBreakdownDto(
        baseAmountKobo: 150000,
        distanceAmountKobo: 110000,
        timeAmountKobo: 30000,
        serviceFeeKobo: 20000,
        discountAmountKobo: 30000,
      );

      expect(breakdown.subtotalKobo, 310000);
      expect(breakdown.totalAmountKobo, 280000);
      expect(breakdown.walletCreditEligibleKobo, 280000);

      // Verify formatted display helpers
      expect(breakdown.formattedBaseNaira, '₦1,500');
      expect(breakdown.formattedDistanceNaira, '₦1,100');
      expect(breakdown.formattedTimeNaira, '₦300');
      expect(breakdown.formattedServiceFeeNaira, '₦200');
      expect(breakdown.formattedSubtotalNaira, '₦3,100');
      expect(breakdown.formattedDiscountNaira, '-₦300');
      expect(breakdown.formattedTotalNaira, '₦2,800');

      // Verify backward-compatible Naira double getters
      expect(breakdown.baseFare, 1500.0);
      expect(breakdown.distanceFare, 1100.0);
      expect(breakdown.timeFare, 300.0);
      expect(breakdown.platformFee, 200.0);
      expect(breakdown.totalFare, 2800.0);
      expect(breakdown.discountAmount, 300.0);
    });

    test('PriceBreakdownDto serializes and deserializes correctly with both kobo and legacy keys', () {
      final json = {
        'base_amount_kobo': 150000,
        'distance_amount_kobo': 110000,
        'time_amount_kobo': 30000,
        'service_fee_kobo': 20000,
        'surge_multiplier': 1.0,
        'surge_amount_kobo': 0,
        'discount_amount_kobo': 30000,
        'currency': 'NGN',
      };

      final breakdown = PriceBreakdownDto.fromJson(json);
      expect(breakdown.totalAmountKobo, 280000);
      expect(breakdown.formattedTotalNaira, '₦2,800');

      // Legacy fallback support
      final legacyJson = {
        'base_fare': 1500.0,
        'distance_fare': 1100.0,
        'time_fare': 300.0,
        'platform_fee': 200.0,
        'discount_amount': 300.0,
        'total_fare': 2800.0,
      };
      final fromLegacy = PriceBreakdownDto.fromJson(legacyJson);
      expect(fromLegacy.baseAmountKobo, 150000);
      expect(fromLegacy.totalAmountKobo, 280000);
      expect(fromLegacy.formattedTotalNaira, '₦2,800');
    });

    test('RideCategoryDto parses backend-published records and formats prices', () {
      final json = {
        'id': 'cat_std_001',
        'code': 'goride_standard',
        'name': 'GoRide Standard',
        'description': 'Affordable and reliable',
        'passenger_capacity': 3,
        'base_fare_kobo': 280000,
        'eta_minutes': 2,
        'capacity_label': '3 Seats',
        'features': ['AC', '3 Seats', 'Trusted riders'],
        'icon_key': 'electric_car',
        'is_available': true,
        'co2_offset_grams': 850,
      };

      final category = RideCategoryDto.fromJson(json);
      expect(category.id, 'cat_std_001');
      expect(category.name, 'GoRide Standard');
      expect(category.formattedPrice, '₦2,800');
      expect(category.etaMinutes, 2);
      expect(category.features, contains('AC'));
      expect(category.isAvailable, true);

      final serialized = category.toJson();
      expect(serialized['code'], 'goride_standard');
      expect(serialized['base_fare_kobo'], 280000);
    });

    test('CouponValidationDto correctly evaluates valid and invalid promo codes', () {
      final validJson = {
        'code': 'GO20',
        'is_valid': true,
        'discount_amount_kobo': 30000,
        'message': '₦300 discount applied',
      };
      final coupon = CouponValidationDto.fromJson(validJson);
      expect(coupon.isValid, true);
      expect(coupon.discountAmountKobo, 30000);
      expect(coupon.formattedDiscount, '-₦300');

      final invalidJson = {
        'code': 'EXPIRED',
        'is_valid': false,
        'discount_amount_kobo': 0,
        'message': 'This coupon has expired',
      };
      final invalidCoupon = CouponValidationDto.fromJson(invalidJson);
      expect(invalidCoupon.isValid, false);
      expect(invalidCoupon.discountAmountKobo, 0);
    });

    test('TripReceiptDto correctly models Screen 16 itemized receipt', () {
      final receipt = TripReceiptDto(
        receiptReference: 'TRP123456789',
        bookingId: 'bk_001',
        serviceType: 'GoRide Standard',
        driverName: 'Daniel Okafor',
        driverRating: 4.8,
        driverTripsCount: 320,
        vehicleModel: 'Toyota Corolla - Black',
        vehiclePlate: 'KJA 123 AB',
        pickupAddress: 'Eko Hotel and Suites, Victoria Island, Lagos',
        pickupTime: DateTime.parse('2026-10-29T10:05:00Z'),
        dropoffAddress: 'Palms Mall, Lekki, Lagos',
        dropoffTime: DateTime.parse('2026-10-29T10:17:00Z'),
        distanceKm: 8.4,
        durationMinutes: 12,
        priceBreakdown: const PriceBreakdownDto(
          baseAmountKobo: 150000,
          distanceAmountKobo: 110000,
          timeAmountKobo: 30000,
          serviceFeeKobo: 20000,
          discountAmountKobo: 30000,
        ),
        subtotalKobo: 310000,
        promoDiscountKobo: 30000,
        totalPaidKobo: 280000,
        paymentMethod: PaymentMethod.wallet,
        paymentReference: 'PAY-WLT-992',
        carbonSavedGrams: 1850,
      );

      expect(receipt.receiptReference, 'TRP123456789');
      expect(receipt.driverName, 'Daniel Okafor');
      expect(receipt.formattedTotalPaid, '₦2,800');
      expect(receipt.formattedSubtotal, '₦3,100');
      expect(receipt.formattedPromoDiscount, '-₦300');
      expect(receipt.formattedCarbonSaved, '1.9 kg');
    });

    test('TripRatingDto models Screen 17 customer rating and feedback', () {
      final rating = TripRatingDto(
        bookingId: 'bk_001',
        rating: 5,
        compliments: const ['Great driver', 'Clean car', 'On time'],
        comment: 'Very polite and smooth driving!',
        wouldRideAgain: true,
      );

      expect(rating.rating, 5);
      expect(rating.compliments.length, 3);
      expect(rating.wouldRideAgain, true);
      expect(rating.toJson()['rating'], 5);
    });

    test('BookingDto supports publicReference and Ride Flow metadata', () {
      final booking = BookingDto(
        id: 'bk_ride_883',
        bookingReference: 'GV-824755',
        serviceCode: ServiceCode.instantRide,
        status: BookingStatus.assigned,
        pickupLocation: const LocationDto(
          latitude: 6.4253,
          longitude: 3.4219,
          address: 'Eko Hotel and Suites, Victoria Island, Lagos',
        ),
        dropoffLocation: const LocationDto(
          latitude: 6.4350,
          longitude: 3.4470,
          address: 'Palms Mall, Lekki, Lagos',
        ),
        priceBreakdown: const PriceBreakdownDto(
          baseAmountKobo: 150000,
          distanceAmountKobo: 110000,
          timeAmountKobo: 30000,
          serviceFeeKobo: 20000,
        ),
        createdAt: DateTime.now(),
        riderName: 'Daniel Okafor',
        riderRating: 4.8,
        driverTripsCount: 320,
        vehicleModel: 'Toyota Corolla - Black',
        vehiclePlate: 'KJA 123 AB',
        etaMinutes: 6,
        distanceKm: 8.4,
        durationMinutes: 12,
      );

      expect(booking.publicReference, 'GV-824755');
      expect(booking.hasAssignedRider, true);
      expect(booking.riderName, 'Daniel Okafor');
      expect(booking.etaMinutes, 6);
    });
  });
}
