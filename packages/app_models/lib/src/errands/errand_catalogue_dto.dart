import 'package:equatable/equatable.dart';
import 'shop_dto.dart';
import 'shopping_item_dto.dart';

/// Catalogue of available markets, errand categories, units, and policy rules (ME-01 & v1.6 §2038).
class ErrandCatalogueDto extends Equatable {
  const ErrandCatalogueDto({
    this.shops = const [],
    this.popularShoppingItems = const [],
    this.packageCategories = const [],
    this.customErrandCategories = const [],
    this.supportedUnits = const ['kg', 'pcs', 'packs', 'bags', 'bunches', 'baskets'],
    this.weightBands = const [
      'Under 1 kg',
      '1 - 2 kg',
      '2 - 5 kg',
      '5 - 10 kg',
      '10 - 20 kg',
    ],
    this.sizeBands = const [
      'Small (fits in pocket/handbag)',
      'Medium (up to 50 cm)',
      'Large (box / bulk package)',
    ],
    this.urgencyOptions = const ['Standard (same day)', 'Express (urgent)'],
    this.defaultShoppingServiceFeeKobo = 80000, // ₦800
    this.defaultPackageServiceFeeKobo = 70000,  // ₦700
    this.defaultCustomErrandServiceFeeKobo = 100000, // ₦1,000
    this.deliveryRatePerKmKobo = 10000,         // ₦100/km
    this.baseDeliveryFareKobo = 100000,          // ₦1,000
  });

  factory ErrandCatalogueDto.fromJson(Map<String, dynamic> json) {
    return ErrandCatalogueDto(
      shops: (json['shops'] as List<dynamic>?)
              ?.map((s) => ShopDto.fromJson(s as Map<String, dynamic>))
              .toList() ??
          const [],
      popularShoppingItems: (json['popular_shopping_items'] as List<dynamic>?)
              ?.map((i) => ShoppingItemDto.fromJson(i as Map<String, dynamic>))
              .toList() ??
          const [],
      packageCategories: (json['package_categories'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      customErrandCategories:
          (json['custom_errand_categories'] as List<dynamic>?)
                  ?.map((e) => e.toString())
                  .toList() ??
              const [],
      supportedUnits: (json['supported_units'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['kg', 'pcs', 'packs', 'bags', 'bunches', 'baskets'],
      weightBands: (json['weight_bands'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      sizeBands: (json['size_bands'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      urgencyOptions: (json['urgency_options'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      defaultShoppingServiceFeeKobo:
          (json['default_shopping_service_fee_kobo'] as num?)?.toInt() ?? 80000,
      defaultPackageServiceFeeKobo:
          (json['default_package_service_fee_kobo'] as num?)?.toInt() ?? 70000,
      defaultCustomErrandServiceFeeKobo:
          (json['default_custom_errand_service_fee_kobo'] as num?)?.toInt() ??
              100000,
      deliveryRatePerKmKobo:
          (json['delivery_rate_per_km_kobo'] as num?)?.toInt() ?? 10000,
      baseDeliveryFareKobo:
          (json['base_delivery_fare_kobo'] as num?)?.toInt() ?? 100000,
    );
  }

  final List<ShopDto> shops;
  final List<ShoppingItemDto> popularShoppingItems;
  final List<String> packageCategories;
  final List<String> customErrandCategories;
  final List<String> supportedUnits;
  final List<String> weightBands;
  final List<String> sizeBands;
  final List<String> urgencyOptions;
  final int defaultShoppingServiceFeeKobo;
  final int defaultPackageServiceFeeKobo;
  final int defaultCustomErrandServiceFeeKobo;
  final int deliveryRatePerKmKobo;
  final int baseDeliveryFareKobo;

  Map<String, dynamic> toJson() => {
        'shops': shops.map((s) => s.toJson()).toList(),
        'popular_shopping_items':
            popularShoppingItems.map((i) => i.toJson()).toList(),
        'package_categories': packageCategories,
        'custom_errand_categories': customErrandCategories,
        'supported_units': supportedUnits,
        'weight_bands': weightBands,
        'size_bands': sizeBands,
        'urgency_options': urgencyOptions,
        'default_shopping_service_fee_kobo': defaultShoppingServiceFeeKobo,
        'default_package_service_fee_kobo': defaultPackageServiceFeeKobo,
        'default_custom_errand_service_fee_kobo':
            defaultCustomErrandServiceFeeKobo,
        'delivery_rate_per_km_kobo': deliveryRatePerKmKobo,
        'base_delivery_fare_kobo': baseDeliveryFareKobo,
      };

  @override
  List<Object?> get props => [
        shops,
        popularShoppingItems,
        packageCategories,
        customErrandCategories,
      ];
}
