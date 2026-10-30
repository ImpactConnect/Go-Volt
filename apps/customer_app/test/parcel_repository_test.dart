import 'package:api_client/api_client.dart';
import 'package:app_config/app_config.dart';
import 'package:app_models/app_models.dart';
import 'package:customer_app/src/features/parcel/data/parcel_repository.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeApiClient extends ApiClient {
  _FakeApiClient() : super(config: AppConfig.dev());

  @override
  Future<ApiResponse<ParcelCatalogueDto>> getDeliveryCatalogue({
    double? latitude,
    double? longitude,
  }) async {
    return ApiResponse.success(const ParcelCatalogueDto());
  }

  @override
  Future<ApiResponse<ParcelPriceBreakdownDto>> requestParcelQuote({
    required LocationDto pickup,
    required LocationDto dropoff,
    required DeliveryOptionDto deliveryOption,
    required ParcelCategoryDto category,
    required double weightKg,
    required ParcelSizeBandDto sizeBand,
    List<SpecialHandlingOptionDto> handlingOptions = const [],
    String? couponCode,
  }) async {
    return ApiResponse.success(
      ParcelPriceBreakdownDto(
        baseFareKobo: deliveryOption.baseFareKobo,
        distanceFareKobo: 30000,
        handlingFareKobo: 20000,
        discountKobo: couponCode != null ? 40000 : 0,
      ),
    );
  }

  @override
  Future<ApiResponse<ParcelDeliveryDto>> createParcelDelivery({
    required DeliveryOptionDto deliveryOption,
    required LocationDto pickupLocation,
    required LocationDto destinationLocation,
    required RecipientDetailsDto recipient,
    required ParcelDetailsDto packageDetails,
    required ParcelPriceBreakdownDto priceBreakdown,
    required PaymentMethod paymentMethod,
    String? couponCode,
    String? idempotencyKey,
  }) async {
    return ApiResponse.success(
      ParcelDeliveryDto(
        id: 'del_12345',
        trackingNumber: 'DVL12345678',
        status: BookingStatus.assigned,
        deliveryOption: deliveryOption,
        pickupLocation: pickupLocation,
        destinationLocation: destinationLocation,
        recipient: recipient,
        packageDetails: packageDetails,
        priceBreakdown: priceBreakdown,
        paymentMethod: paymentMethod,
        riderName: 'Daniel Okafor',
        riderPhone: '+234 802 000 1122',
        riderRating: 4.9,
        riderTotalTrips: 320,
        riderVehicle: 'Yamaha Bike - ABC-123XY',
        createdAt: DateTime.now(),
        pickupTimestamp: DateTime.now().add(const Duration(minutes: 6)),
        etaMinutes: 6,
      ),
    );
  }

  @override
  Future<ApiResponse<ParcelDeliveryDto>> getParcelDelivery(String id) async {
    return ApiResponse.success(
      ParcelDeliveryDto(
        id: id,
        trackingNumber: 'DVL12345678',
        status: BookingStatus.assigned,
        deliveryOption: DeliveryOptionDto.standard,
        pickupLocation: const LocationDto(
          latitude: 6.4281,
          longitude: 3.4219,
          address: 'Eko Hotel and Suites',
        ),
        destinationLocation: const LocationDto(
          latitude: 6.4357,
          longitude: 3.4418,
          address: 'Palms Mall',
        ),
        recipient: RecipientDetailsDto.defaultRecipient,
        packageDetails: const ParcelDetailsDto(
          category: ParcelCategoryDto.fragile,
          weightKg: 1.5,
          sizeBand: ParcelSizeBandDto.small,
        ),
        priceBreakdown: ParcelPriceBreakdownDto.defaultBreakdown,
        paymentMethod: PaymentMethod.wallet,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Future<ApiResponse<bool>> cancelParcelDelivery(
    String id, {
    required String reason,
  }) async {
    return ApiResponse.success(true);
  }

  @override
  Future<ApiResponse<bool>> submitParcelRating(ParcelRatingDto rating) async {
    return ApiResponse.success(true);
  }
}

void main() {
  late ApiClient apiClient;
  late ParcelRepository repository;

  setUp(() {
    apiClient = _FakeApiClient();
    repository = ParcelRepositoryImpl(apiClient: apiClient);
  });

  group('ParcelRepository Tests', () {
    test('getCatalogue returns default published catalogue configuration', () async {
      final catalogue = await repository.getCatalogue();
      expect(catalogue.deliveryOptions.length, 3);
      expect(catalogue.packageCategories.length, 6);
      expect(catalogue.sizeBands.length, 3);
      expect(catalogue.policyVersion, 'v1.4');
    });

    test('requestQuote calculates exact integer kobo pricing breakdown', () async {
      final quote = await repository.requestQuote(
        pickup: const LocationDto(
          latitude: 6.4281,
          longitude: 3.4219,
          address: 'Eko Hotel and Suites',
        ),
        dropoff: const LocationDto(
          latitude: 6.4357,
          longitude: 3.4418,
          address: 'Palms Mall',
        ),
        deliveryOption: DeliveryOptionDto.standard,
        category: ParcelCategoryDto.fragile,
        weightKg: 1.5,
        sizeBand: ParcelSizeBandDto.small,
        handlingOptions: const [
          SpecialHandlingOptionDto(
            code: 'FRAGILE',
            label: 'Fragile (Handle with care)',
            surchargeKobo: 20000,
            isEnabled: true,
          ),
        ],
        couponCode: 'DELIVER20',
      );

      expect(quote.baseFareKobo, 200000);
      expect(quote.handlingFareKobo, 20000);
      expect(quote.discountKobo, 40000);
      expect(quote.totalAmountKobo, 210000);
      expect(quote.formattedTotalFare, '₦2,100');
    });

    test('createDelivery creates active delivery entity with tracking number', () async {
      final delivery = await repository.createDelivery(
        deliveryOption: DeliveryOptionDto.standard,
        pickupLocation: const LocationDto(
          latitude: 6.4281,
          longitude: 3.4219,
          address: 'Eko Hotel and Suites',
        ),
        destinationLocation: const LocationDto(
          latitude: 6.4357,
          longitude: 3.4418,
          address: 'Palms Mall',
        ),
        recipient: RecipientDetailsDto.defaultRecipient,
        packageDetails: const ParcelDetailsDto(
          category: ParcelCategoryDto.fragile,
          weightKg: 1.5,
          sizeBand: ParcelSizeBandDto.small,
        ),
        priceBreakdown: ParcelPriceBreakdownDto.defaultBreakdown,
        paymentMethod: PaymentMethod.wallet,
      );

      expect(delivery.trackingNumber, startsWith('DVL'));
      expect(delivery.riderName, 'Daniel Okafor');
      expect(delivery.status, BookingStatus.assigned);
    });

    test('getDelivery retrieves active delivery', () async {
      final delivery = await repository.getDelivery('del_12345');
      expect(delivery.id, 'del_12345');
      expect(delivery.trackingNumber, 'DVL12345678');
    });

    test('cancelDelivery executes cancellation', () async {
      final result = await repository.cancelDelivery(
        'del_test_123',
        reason: 'Customer cancelled',
      );
      expect(result, isTrue);
    });

    test('submitRating submits courier rating', () async {
      final result = await repository.submitRating(
        ParcelRatingDto(
          trackingNumber: 'DVL12345678',
          ratingStars: 5,
          compliments: const ['Excellent', 'On time'],
          submittedAt: DateTime.now(),
        ),
      );
      expect(result, isTrue);
    });
  });
}
