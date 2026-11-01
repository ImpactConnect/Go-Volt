import 'package:equatable/equatable.dart';
import '../enums/domain_enums.dart';

/// Customer saved destination (e.g. Home, Work, School, Gym) (§B3).
class SavedPlaceDto extends Equatable {
  const SavedPlaceDto({
    required this.id,
    required this.label,
    required this.address,
    this.type = SavedPlaceType.custom,
    required this.latitude,
    required this.longitude,
    this.additionalInstructions,
    this.isUsedInActivePlan = false,
    this.userId,
  });

  factory SavedPlaceDto.fromJson(Map<String, dynamic> json) {
    return SavedPlaceDto(
      id: json['id'] as String,
      label: json['label'] as String,
      address: json['address'] as String,
      type: SavedPlaceType.fromString(json['type'] as String? ?? 'CUSTOM'),
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      additionalInstructions: json['additional_instructions'] as String?,
      isUsedInActivePlan: json['is_used_in_active_plan'] as bool? ?? false,
      userId: json['user_id'] as String?,
    );
  }

  final String id;
  final String label;
  final String address;
  final SavedPlaceType type;
  final double latitude;
  final double longitude;
  final String? additionalInstructions;
  final bool isUsedInActivePlan;
  final String? userId;

  bool get isHome => type == SavedPlaceType.home;
  bool get isWork => type == SavedPlaceType.work;
  bool get isSchool => type == SavedPlaceType.school;

  SavedPlaceDto copyWith({
    String? id,
    String? label,
    String? address,
    SavedPlaceType? type,
    double? latitude,
    double? longitude,
    String? additionalInstructions,
    bool? isUsedInActivePlan,
    String? userId,
  }) {
    return SavedPlaceDto(
      id: id ?? this.id,
      label: label ?? this.label,
      address: address ?? this.address,
      type: type ?? this.type,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      additionalInstructions: additionalInstructions ?? this.additionalInstructions,
      isUsedInActivePlan: isUsedInActivePlan ?? this.isUsedInActivePlan,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'label': label,
        'address': address,
        'type': type.code,
        'latitude': latitude,
        'longitude': longitude,
        if (additionalInstructions != null) 'additional_instructions': additionalInstructions,
        'is_used_in_active_plan': isUsedInActivePlan,
        if (userId != null) 'user_id': userId,
      };

  @override
  List<Object?> get props => [
        id,
        label,
        address,
        type,
        latitude,
        longitude,
        additionalInstructions,
        isUsedInActivePlan,
        userId,
      ];
}
