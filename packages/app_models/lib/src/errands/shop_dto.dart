import 'package:equatable/equatable.dart';

/// DTO for a merchant store, supermarket, or open market (Screen A2 & ME-A01).
class ShopDto extends Equatable {
  const ShopDto({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.category = 'Supermarket',
    this.distanceKm = 0.0,
    this.isPopular = false,
    this.isSaved = false,
    this.phoneNumber,
    this.operatingHours = '8:00 AM - 9:00 PM',
    this.rating = 4.8,
    this.imageUrl,
    this.isCustom = false,
  });

  factory ShopDto.fromJson(Map<String, dynamic> json) {
    return ShopDto(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      address: json['address'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      category: json['category'] as String? ?? 'Supermarket',
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0.0,
      isPopular: json['is_popular'] as bool? ?? false,
      isSaved: json['is_saved'] as bool? ?? false,
      phoneNumber: json['phone_number'] as String?,
      operatingHours: json['operating_hours'] as String? ?? '8:00 AM - 9:00 PM',
      rating: (json['rating'] as num?)?.toDouble() ?? 4.8,
      imageUrl: json['image_url'] as String?,
      isCustom: json['is_custom'] as bool? ?? false,
    );
  }

  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String category;
  final double distanceKm;
  final bool isPopular;
  final bool isSaved;
  final String? phoneNumber;
  final String operatingHours;
  final double rating;
  final String? imageUrl;
  final bool isCustom;

  String get formattedDistance => '${distanceKm.toStringAsFixed(1)} km';

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'latitude': latitude,
        'longitude': longitude,
        'category': category,
        'distance_km': distanceKm,
        'is_popular': isPopular,
        'is_saved': isSaved,
        if (phoneNumber != null) 'phone_number': phoneNumber,
        'operating_hours': operatingHours,
        'rating': rating,
        if (imageUrl != null) 'image_url': imageUrl,
        'is_custom': isCustom,
      };

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        latitude,
        longitude,
        distanceKm,
        isPopular,
        isSaved,
      ];
}

