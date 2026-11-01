import 'package:equatable/equatable.dart';

/// DTO for an item in a shopping errand list (Screen A3 & ME-A02).
class ShoppingItemDto extends Equatable {
  const ShoppingItemDto({
    required this.id,
    required this.name,
    required this.quantity,
    this.unit = 'kg',
    required this.estimatedPriceKobo,
    this.preferenceNotes,
    this.imageUrl,
    this.isPurchased = false,
    this.isUnavailable = false,
    this.actualPriceKobo,
  });

  factory ShoppingItemDto.fromJson(Map<String, dynamic> json) {
    return ShoppingItemDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unit: json['unit'] as String? ?? 'kg',
      estimatedPriceKobo: (json['estimated_price_kobo'] as num?)?.toInt() ?? 0,
      preferenceNotes: json['preference_notes'] as String?,
      imageUrl: json['image_url'] as String?,
      isPurchased: json['is_purchased'] as bool? ?? false,
      isUnavailable: json['is_unavailable'] as bool? ?? false,
      actualPriceKobo: (json['actual_price_kobo'] as num?)?.toInt(),
    );
  }

  final String id;
  final String name;
  final int quantity;
  final String unit;
  final int estimatedPriceKobo;
  final String? preferenceNotes;
  final String? imageUrl;
  final bool isPurchased;
  final bool isUnavailable;
  final int? actualPriceKobo;

  double get estimatedPriceNgn => estimatedPriceKobo / 100.0;
  double? get actualPriceNgn =>
      actualPriceKobo != null ? actualPriceKobo! / 100.0 : null;

  String get formattedQuantity => '$quantity $unit';
  String get formattedPrice => '₦${(estimatedPriceKobo / 100).toStringAsFixed(0)}';

  ShoppingItemDto copyWith({
    String? id,
    String? name,
    int? quantity,
    String? unit,
    int? estimatedPriceKobo,
    String? preferenceNotes,
    String? imageUrl,
    bool? isPurchased,
    bool? isUnavailable,
    int? actualPriceKobo,
  }) {
    return ShoppingItemDto(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      estimatedPriceKobo: estimatedPriceKobo ?? this.estimatedPriceKobo,
      preferenceNotes: preferenceNotes ?? this.preferenceNotes,
      imageUrl: imageUrl ?? this.imageUrl,
      isPurchased: isPurchased ?? this.isPurchased,
      isUnavailable: isUnavailable ?? this.isUnavailable,
      actualPriceKobo: actualPriceKobo ?? this.actualPriceKobo,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'quantity': quantity,
        'unit': unit,
        'estimated_price_kobo': estimatedPriceKobo,
        if (preferenceNotes != null) 'preference_notes': preferenceNotes,
        if (imageUrl != null) 'image_url': imageUrl,
        'is_purchased': isPurchased,
        'is_unavailable': isUnavailable,
        if (actualPriceKobo != null) 'actual_price_kobo': actualPriceKobo,
      };

  @override
  List<Object?> get props => [
        id,
        name,
        quantity,
        unit,
        estimatedPriceKobo,
        preferenceNotes,
        isPurchased,
        isUnavailable,
        actualPriceKobo,
      ];
}

