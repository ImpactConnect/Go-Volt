import 'package:equatable/equatable.dart';
import '../enums/domain_enums.dart';

/// User profile and security information.
class ProfileDto extends Equatable {

  factory ProfileDto.fromJson(Map<String, dynamic> json) {
    final rawRoles = json['roles'] as List<dynamic>? ?? ['customer'];
    return ProfileDto(
      id: json['id'] as String,
      fullName: json['full_name'] as String? ?? 'User',
      phoneNumber: json['phone_number'] as String? ?? '',
      email: json['email'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      roles: rawRoles
          .map((r) => UserRole.fromString(r.toString()))
          .toList(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      carbonAvoidedKg:
          (json['carbon_avoided_kg'] as num?)?.toDouble() ?? 28.4,
      ecoPointsBalance: (json['eco_points_balance'] as num?)?.toInt() ?? 320,
    );
  }
  const ProfileDto({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.email,
    this.avatarUrl,
    this.roles = const [UserRole.customer],
    this.createdAt,
    this.updatedAt,
    this.carbonAvoidedKg = 28.4,
    this.ecoPointsBalance = 320,
  });

  final String id;
  final String fullName;
  final String phoneNumber;
  final String? email;
  final String? avatarUrl;
  final List<UserRole> roles;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final double carbonAvoidedKg;
  final int ecoPointsBalance;

  bool get isCustomer => roles.contains(UserRole.customer);
  bool get isRider => roles.contains(UserRole.rider);
  bool get isAdmin => roles.contains(UserRole.admin) || roles.contains(UserRole.superAdmin);

  Map<String, dynamic> toJson() => {
        'id': id,
        'full_name': fullName,
        'phone_number': phoneNumber,
        if (email != null) 'email': email,
        if (avatarUrl != null) 'avatar_url': avatarUrl,
        'roles': roles.map((r) => r.code).toList(),
        if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
        'carbon_avoided_kg': carbonAvoidedKg,
        'eco_points_balance': ecoPointsBalance,
      };

  @override
  List<Object?> get props => [
        id,
        fullName,
        phoneNumber,
        email,
        avatarUrl,
        roles,
        carbonAvoidedKg,
        ecoPointsBalance,
      ];
}
