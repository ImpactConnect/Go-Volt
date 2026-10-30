import 'package:equatable/equatable.dart';

/// DTO representing backend-published parcel categories (Screen 3: Package Category Grid).
///
/// Features:
/// - Canonical codes matching Product Spec §22.3: DOCUMENTS, ELECTRONICS, CLOTHING, FOOD, FRAGILE, OTHER.
/// - Associated icons and weight constraints.
class ParcelCategoryDto extends Equatable {
  const ParcelCategoryDto({
    required this.id,
    required this.code,
    required this.name,
    required this.iconKey,
    this.description,
    this.maxWeightKg = 15.0,
    this.requiresSpecialHandling = false,
  });

  factory ParcelCategoryDto.fromJson(Map<String, dynamic> json) {
    return ParcelCategoryDto(
      id: json['id'] as String? ?? 'cat_documents',
      code: (json['code'] as String? ?? 'DOCUMENTS').toUpperCase(),
      name: json['name'] as String? ?? 'Documents',
      iconKey: json['icon_key'] as String? ?? 'description',
      description: json['description'] as String?,
      maxWeightKg: (json['max_weight_kg'] as num?)?.toDouble() ?? 15.0,
      requiresSpecialHandling:
          json['requires_special_handling'] as bool? ?? false,
    );
  }

  final String id;
  final String code;
  final String name;
  final String iconKey;
  final String? description;
  final double maxWeightKg;
  final bool requiresSpecialHandling;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'icon_key': iconKey,
      if (description != null) 'description': description,
      'max_weight_kg': maxWeightKg,
      'requires_special_handling': requiresSpecialHandling,
    };
  }

  static const ParcelCategoryDto documents = ParcelCategoryDto(
    id: 'cat_doc_01',
    code: 'DOCUMENTS',
    name: 'Documents',
    iconKey: 'description',
    maxWeightKg: 5.0,
  );

  static const ParcelCategoryDto electronics = ParcelCategoryDto(
    id: 'cat_elec_02',
    code: 'ELECTRONICS',
    name: 'Electronics',
    iconKey: 'smartphone',
    maxWeightKg: 10.0,
    requiresSpecialHandling: true,
  );

  static const ParcelCategoryDto clothing = ParcelCategoryDto(
    id: 'cat_cloth_03',
    code: 'CLOTHING',
    name: 'Clothing',
    iconKey: 'checkroom',
    maxWeightKg: 15.0,
  );

  static const ParcelCategoryDto food = ParcelCategoryDto(
    id: 'cat_food_04',
    code: 'FOOD',
    name: 'Food',
    iconKey: 'restaurant',
    maxWeightKg: 10.0,
    requiresSpecialHandling: true,
  );

  static const ParcelCategoryDto fragile = ParcelCategoryDto(
    id: 'cat_fragile_05',
    code: 'FRAGILE',
    name: 'Fragile',
    iconKey: 'wine_bar',
    maxWeightKg: 10.0,
    requiresSpecialHandling: true,
  );

  static const ParcelCategoryDto other = ParcelCategoryDto(
    id: 'cat_other_06',
    code: 'OTHER',
    name: 'Other',
    iconKey: 'more_horiz',
    maxWeightKg: 15.0,
  );

  static const List<ParcelCategoryDto> defaultCategories = [
    documents,
    electronics,
    clothing,
    food,
    fragile,
    other,
  ];

  @override
  List<Object?> get props => [
        id,
        code,
        name,
        iconKey,
        description,
        maxWeightKg,
        requiresSpecialHandling,
      ];
}
