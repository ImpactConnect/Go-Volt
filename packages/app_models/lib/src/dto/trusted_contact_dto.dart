import 'package:equatable/equatable.dart';

/// Customer emergency and trip-sharing trusted contact (§D2).
class TrustedContactDto extends Equatable {
  const TrustedContactDto({
    required this.id,
    required this.name,
    required this.phoneNumber,
    this.relationship = 'Friend',
    this.autoShareRides = false,
    this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory TrustedContactDto.fromJson(Map<String, dynamic> json) {
    return TrustedContactDto(
      id: json['id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phone_number'] as String,
      relationship: json['relationship'] as String? ?? 'Friend',
      autoShareRides: json['auto_share_rides'] as bool? ?? false,
      userId: json['user_id'] as String?,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
    );
  }

  final String id;
  final String name;
  final String phoneNumber;
  final String relationship;
  final bool autoShareRides;
  final String? userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TrustedContactDto copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? relationship,
    bool? autoShareRides,
    String? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TrustedContactDto(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      relationship: relationship ?? this.relationship,
      autoShareRides: autoShareRides ?? this.autoShareRides,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone_number': phoneNumber,
        'relationship': relationship,
        'auto_share_rides': autoShareRides,
        if (userId != null) 'user_id': userId,
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
      };

  @override
  List<Object?> get props => [id, name, phoneNumber, relationship, autoShareRides, userId, createdAt, updatedAt];
}

