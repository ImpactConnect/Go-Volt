import 'package:app_models/app_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Go-Volts Send: Step 1 Domain Models & Financial Contracts Unit Tests', () {
    test('DeliveryOptionDto enforces kobo amounts and formats pricing', () {
      final std = DeliveryOptionDto.standard;
      expect(std.code, 'STANDARD');
      expect(std.baseFareKobo, 200000);
      expect(std.formattedBaseFare, '₦2000');
      expect(std.isDefault, isTrue);

      final json = std.toJson();
      final roundTrip = DeliveryOptionDto.fromJson(json);
      expect(roundTrip, equals(std));
    });

    test('ParcelCategoryDto correctly categorizes goods with handling constraints', () {
      final fragile = ParcelCategoryDto.fragile;
      expect(fragile.code, 'FRAGILE');
      expect(fragile.requiresSpecialHandling, isTrue);

      final doc = ParcelCategoryDto.documents;
      expect(doc.code, 'DOCUMENTS');
      expect(doc.requiresSpecialHandling, isFalse);

      final json = fragile.toJson();
      final roundTrip = ParcelCategoryDto.fromJson(json);
      expect(roundTrip, equals(fragile));
    });

    test('SpecialHandlingOptionDto calculates surcharges and toggles state', () {
      const option = SpecialHandlingOptionDto(
        code: 'FRAGILE',
        label: 'Fragile (Handle with care)',
        surchargeKobo: 20000,
        isEnabled: false,
      );

      final enabled = option.copyWith(isEnabled: true);
      expect(enabled.isEnabled, isTrue);
      expect(enabled.surchargeKobo, 20000);

      final json = enabled.toJson();
      final roundTrip = SpecialHandlingOptionDto.fromJson(json);
      expect(roundTrip, equals(enabled));
    });

    test('RecipientDetailsDto models Nigerian phone and delivery address', () {
      const recipient = RecipientDetailsDto(
        fullName: 'John Doe',
        phoneNumber: '0803 123 4567',
        countryCode: '+234',
        deliveryAddress: 'Palms Mall, Lekki, Lagos',
        additionalAddressInfo: 'Shop B12, Second floor',
      );

      expect(recipient.formattedPhone, '+234 0803 123 4567');
      expect(recipient.saveAsRecipient, isTrue);

      final json = recipient.toJson();
      final roundTrip = RecipientDetailsDto.fromJson(json);
      expect(roundTrip, equals(recipient));
    });

    test('ParcelDetailsDto correctly tracks fragile status and surcharge summation', () {
      final details = ParcelDetailsDto.defaultFragile;
      expect(details.isFragile, isTrue);
      expect(details.formattedWeight, '1.5 kg');
      expect(details.totalHandlingSurchargeKobo, 20000);

      final json = details.toJson();
      final roundTrip = ParcelDetailsDto.fromJson(json);
      expect(roundTrip.category.code, 'FRAGILE');
      expect(roundTrip.weightKg, 1.5);
    });

    test('ParcelPriceBreakdownDto enforces exact integer kobo arithmetic and zero floating-point error', () {
      const breakdown = ParcelPriceBreakdownDto(
        baseFareKobo: 200000,     // ₦2,000
        distanceFareKobo: 30000,   // ₦300
        handlingFareKobo: 20000,   // ₦200
        insuranceFareKobo: 0,      // ₦0
        discountKobo: 0,
        distanceKm: 12.4,
      );

      expect(breakdown.subtotalKobo, 250000); // ₦2,500
      expect(breakdown.totalAmountKobo, 250000);
      expect(breakdown.formattedBaseFare, '₦2,000');
      expect(breakdown.formattedDistanceFare, '₦300');
      expect(breakdown.formattedHandlingFare, '₦200');
      expect(breakdown.formattedInsuranceFare, '₦0');
      expect(breakdown.formattedTotalFare, '₦2,500');
      expect(breakdown.distanceLabel, '12.4 km');

      // Test with discount applied
      final withDiscount = breakdown.copyWith(discountKobo: 50000); // ₦500 off
      expect(withDiscount.totalAmountKobo, 200000);
      expect(withDiscount.formattedDiscount, '₦500');
      expect(withDiscount.formattedTotalFare, '₦2,000');

      final json = breakdown.toJson();
      final roundTrip = ParcelPriceBreakdownDto.fromJson(json);
      expect(roundTrip, equals(breakdown));
    });

    test('ProofOfDeliveryDto formats delivery timestamp and recipient signature', () {
      final pod = ProofOfDeliveryDto.sampleDelivered;
      expect(pod.trackingNumber, 'DVL12345678');
      expect(pod.recipientName, 'John Doe');
      expect(pod.receivedByName, 'John Doe');
      expect(pod.formattedDeliveredAt, contains('Oct 29, 2026'));
      expect(pod.verificationMethod, 'SIGNATURE');

      final json = pod.toJson();
      final roundTrip = ProofOfDeliveryDto.fromJson(json);
      expect(roundTrip.trackingNumber, 'DVL12345678');
      expect(roundTrip.recipientName, 'John Doe');
    });

    test('ParcelDeliveryDto models complete active dispatch entity and milestones', () {
      final delivery = ParcelDeliveryDto.sampleDelivery;
      expect(delivery.trackingNumber, 'DVL12345678');
      expect(delivery.status, BookingStatus.assigned);
      expect(delivery.riderName, 'Daniel Okafor');
      expect(delivery.riderRating, 4.9);
      expect(delivery.riderVehicle, 'Yamaha Bike - ABC-123XY');
      expect(delivery.formattedEta, '6 min');

      // State transitions
      final collected = delivery.copyWith(status: BookingStatus.parcelCollected);
      expect(collected.status, BookingStatus.parcelCollected);

      final inTransit = delivery.copyWith(status: BookingStatus.inProgress);
      expect(inTransit.status, BookingStatus.inProgress);

      final delivered = delivery.copyWith(status: BookingStatus.delivered);
      expect(delivered.status, BookingStatus.delivered);
      expect(delivered.status.isTerminal, isTrue);

      final json = delivery.toJson();
      final roundTrip = ParcelDeliveryDto.fromJson(json);
      expect(roundTrip.trackingNumber, delivery.trackingNumber);
      expect(roundTrip.status, delivery.status);
    });

    test('ParcelRatingDto validates rating stars and compliment tags', () {
      final rating = ParcelRatingDto(
        trackingNumber: 'DVL12345678',
        ratingStars: 5,
        compliments: const ['Excellent', 'On time', 'Handled with care'],
        comment: 'Great delivery, driver handled fragile package carefully.',
        submittedAt: DateTime(2026, 10, 29, 11, 0),
      );

      expect(rating.ratingStars, 5);
      expect(rating.compliments.length, 3);
      expect(rating.riderName, 'Daniel Okafor');

      final json = rating.toJson();
      final roundTrip = ParcelRatingDto.fromJson(json);
      expect(roundTrip.ratingStars, 5);
      expect(roundTrip.compliments, contains('Handled with care'));
    });

    test('ParcelCatalogueDto correctly bundles delivery options, categories and policy notice', () {
      const catalogue = ParcelCatalogueDto();
      expect(catalogue.deliveryOptions.length, 3);
      expect(catalogue.packageCategories.length, 6);
      expect(catalogue.sizeBands.length, 3);
      expect(catalogue.handlingOptions.length, 3);
      expect(catalogue.policyVersion, 'v1.4');
      expect(catalogue.prohibitedItemsNotice, contains('Hazardous materials'));

      final json = catalogue.toJson();
      final roundTrip = ParcelCatalogueDto.fromJson(json);
      expect(roundTrip.deliveryOptions.length, 3);
      expect(roundTrip.policyVersion, 'v1.4');
    });
  });
}

