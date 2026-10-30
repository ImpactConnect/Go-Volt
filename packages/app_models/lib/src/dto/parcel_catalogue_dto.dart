import 'package:equatable/equatable.dart';

import 'delivery_option_dto.dart';
import 'parcel_category_dto.dart';
import 'parcel_size_band_dto.dart';
import 'special_handling_option_dto.dart';

/// DTO representing published parcel delivery catalogue configuration (v1.4 §6.4 & §22.3).
class ParcelCatalogueDto extends Equatable {
  const ParcelCatalogueDto({
    this.deliveryOptions = DeliveryOptionDto.defaultOptions,
    this.packageCategories = ParcelCategoryDto.defaultCategories,
    this.sizeBands = ParcelSizeBandDto.defaultBands,
    this.handlingOptions = SpecialHandlingOptionDto.defaultOptions,
    this.policyVersion = 'v1.4',
    this.prohibitedItemsNotice =
        'Hazardous materials, cash, perishable unpackaged goods, firearms, and illegal substances are strictly prohibited on Go-Volts Send.',
  });

  factory ParcelCatalogueDto.fromJson(Map<String, dynamic> json) {
    return ParcelCatalogueDto(
      deliveryOptions: (json['delivery_options'] as List<dynamic>?)
              ?.map((e) => DeliveryOptionDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          DeliveryOptionDto.defaultOptions,
      packageCategories: (json['package_categories'] as List<dynamic>?)
              ?.map((e) => ParcelCategoryDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          ParcelCategoryDto.defaultCategories,
      sizeBands: (json['size_bands'] as List<dynamic>?)
              ?.map((e) => ParcelSizeBandDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          ParcelSizeBandDto.defaultBands,
      handlingOptions: (json['handling_options'] as List<dynamic>?)
              ?.map((e) =>
                  SpecialHandlingOptionDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          SpecialHandlingOptionDto.defaultOptions,
      policyVersion: json['policy_version'] as String? ?? 'v1.4',
      prohibitedItemsNotice: json['prohibited_items_notice'] as String? ??
          'Hazardous materials, cash, perishable unpackaged goods, firearms, and illegal substances are strictly prohibited on Go-Volts Send.',
    );
  }

  final List<DeliveryOptionDto> deliveryOptions;
  final List<ParcelCategoryDto> packageCategories;
  final List<ParcelSizeBandDto> sizeBands;
  final List<SpecialHandlingOptionDto> handlingOptions;
  final String policyVersion;
  final String prohibitedItemsNotice;

  Map<String, dynamic> toJson() {
    return {
      'delivery_options': deliveryOptions.map((e) => e.toJson()).toList(),
      'package_categories': packageCategories.map((e) => e.toJson()).toList(),
      'size_bands': sizeBands.map((e) => e.toJson()).toList(),
      'handling_options': handlingOptions.map((e) => e.toJson()).toList(),
      'policy_version': policyVersion,
      'prohibited_items_notice': prohibitedItemsNotice,
    };
  }

  @override
  List<Object?> get props => [
        deliveryOptions,
        packageCategories,
        sizeBands,
        handlingOptions,
        policyVersion,
        prohibitedItemsNotice,
      ];
}
