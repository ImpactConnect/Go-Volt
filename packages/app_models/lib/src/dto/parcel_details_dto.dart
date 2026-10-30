import 'package:equatable/equatable.dart';

import 'parcel_category_dto.dart';
import 'parcel_size_band_dto.dart';
import 'special_handling_option_dto.dart';

/// DTO representing the complete package specification (Screen 3: Package details).
class ParcelDetailsDto extends Equatable {
  const ParcelDetailsDto({
    required this.category,
    required this.weightKg,
    required this.sizeBand,
    this.handlingOptions = const [],
    this.declaredValueKobo = 0,
    this.description,
  });

  factory ParcelDetailsDto.fromJson(Map<String, dynamic> json) {
    return ParcelDetailsDto(
      category: json['category'] != null
          ? ParcelCategoryDto.fromJson(json['category'] as Map<String, dynamic>)
          : ParcelCategoryDto.fragile,
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 1.5,
      sizeBand: json['size_band'] != null
          ? ParcelSizeBandDto.fromJson(json['size_band'] as Map<String, dynamic>)
          : ParcelSizeBandDto.small,
      handlingOptions: (json['handling_options'] as List<dynamic>?)
              ?.map((h) =>
                  SpecialHandlingOptionDto.fromJson(h as Map<String, dynamic>))
              .toList() ??
          [],
      declaredValueKobo: (json['declared_value_kobo'] as num?)?.toInt() ?? 0,
      description: json['description'] as String?,
    );
  }

  final ParcelCategoryDto category;
  final double weightKg;
  final ParcelSizeBandDto sizeBand;
  final List<SpecialHandlingOptionDto> handlingOptions;
  final int declaredValueKobo;
  final String? description;

  String get formattedWeight => '${weightKg.toStringAsFixed(1)} kg';

  bool get isFragile =>
      handlingOptions.any((h) => h.code == 'FRAGILE' && h.isEnabled) ||
      category.code == 'FRAGILE';

  bool get keepUpright =>
      handlingOptions.any((h) => h.code == 'KEEP_UPRIGHT' && h.isEnabled);

  bool get isPerishable =>
      handlingOptions.any((h) => h.code == 'PERISHABLE' && h.isEnabled) ||
      category.code == 'FOOD';

  int get totalHandlingSurchargeKobo {
    return handlingOptions
        .where((h) => h.isEnabled)
        .fold(0, (acc, h) => acc + h.surchargeKobo);
  }

  ParcelDetailsDto copyWith({
    ParcelCategoryDto? category,
    double? weightKg,
    ParcelSizeBandDto? sizeBand,
    List<SpecialHandlingOptionDto>? handlingOptions,
    int? declaredValueKobo,
    String? description,
  }) {
    return ParcelDetailsDto(
      category: category ?? this.category,
      weightKg: weightKg ?? this.weightKg,
      sizeBand: sizeBand ?? this.sizeBand,
      handlingOptions: handlingOptions ?? this.handlingOptions,
      declaredValueKobo: declaredValueKobo ?? this.declaredValueKobo,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category.toJson(),
      'weight_kg': weightKg,
      'size_band': sizeBand.toJson(),
      'handling_options': handlingOptions.map((h) => h.toJson()).toList(),
      'declared_value_kobo': declaredValueKobo,
      if (description != null) 'description': description,
    };
  }

  static const ParcelDetailsDto defaultFragile = ParcelDetailsDto(
    category: ParcelCategoryDto.fragile,
    weightKg: 1.5,
    sizeBand: ParcelSizeBandDto.small,
    handlingOptions: [
      SpecialHandlingOptionDto(
        code: 'FRAGILE',
        label: 'Fragile (Handle with care)',
        surchargeKobo: 20000,
        isEnabled: true,
      ),
      SpecialHandlingOptionDto(
        code: 'KEEP_UPRIGHT',
        label: 'Keep upright',
        surchargeKobo: 0,
        isEnabled: false,
      ),
      SpecialHandlingOptionDto(
        code: 'PERISHABLE',
        label: 'Perishable (e.g. food)',
        surchargeKobo: 10000,
        isEnabled: false,
      ),
    ],
  );

  @override
  List<Object?> get props => [
        category,
        weightKg,
        sizeBand,
        handlingOptions,
        declaredValueKobo,
        description,
      ];
}
