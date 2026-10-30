import 'package:equatable/equatable.dart';
import '../enums/domain_enums.dart';

/// Customer saved destination (e.g. Home, Work, Gym).
class SavedPlaceDto extends Equatable {
  const SavedPlaceDto({
    required this.id,
    required this.label,
    required this.address,
    this.type = SavedPlaceType.custom,
    required this.latitude,
    required this.longitude,
  });

  factory SavedPlaceDto.fromJson(Map<String, dynamic> json) {
    return SavedPlaceDto(
      id: json['id'] as String,
      label: json['label'] as String,
      address: json['address'] as String,
      type: SavedPlaceType.fromString(json['type'] as String? ?? 'CUSTOM'),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  final String id;
  final String label;
  final String address;
  final SavedPlaceType type;
  final double latitude;
  final double longitude;

  bool get isHome => type == SavedPlaceType.home;
  bool get isWork => type == SavedPlaceType.work;

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'address': address,
        'type': type.code,
        'latitude': latitude,
        'longitude': longitude,
      };

  @override
  List<Object?> get props => [id, label, address, type, latitude, longitude];
}

