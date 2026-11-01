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
          (json['carbon_avoided_kg'] as num?)?.toDouble() ?? 0.0,
      ecoPointsBalance: (json['eco_points_balance'] as num?)?.toInt() ?? 0,
      gender: json['gender'] as String?,
      state: json['state'] as String?,
      city: json['city'] as String?,
      currentAddress: json['current_address'] as String?,
      emergencyContactName: json['emergency_contact_name'] as String?,
      emergencyContactPhone: json['emergency_contact_phone'] as String?,
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
    this.carbonAvoidedKg = 0.0,
    this.ecoPointsBalance = 0,
    this.gender,
    this.state,
    this.city,
    this.currentAddress,
    this.emergencyContactName,
    this.emergencyContactPhone,
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

  /// Gender: 'male', 'female', 'non_binary', 'prefer_not_to_say'
  final String? gender;

  /// State selected from operating locations (e.g. 'Ogun')
  final String? state;

  /// City selected from operating locations (e.g. 'Shagamu')
  final String? city;

  /// User's current residential address
  final String? currentAddress;

  /// Emergency contact full name
  final String? emergencyContactName;

  /// Emergency contact phone number
  final String? emergencyContactPhone;

  bool get isCustomer => roles.contains(UserRole.customer);
  bool get isRider => roles.contains(UserRole.rider);
  bool get isAdmin => roles.contains(UserRole.admin) || roles.contains(UserRole.superAdmin);

  /// Returns true when all required profile fields are filled.
  bool get isProfileComplete =>
      phoneNumber.isNotEmpty &&
      gender != null &&
      state != null &&
      city != null &&
      currentAddress != null &&
      currentAddress!.isNotEmpty &&
      emergencyContactName != null &&
      emergencyContactName!.isNotEmpty &&
      emergencyContactPhone != null &&
      emergencyContactPhone!.isNotEmpty;

  /// Convenient helper to get first name dynamically.
  String get firstName {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.isNotEmpty && parts.first.isNotEmpty ? parts.first : 'Customer';
  }

  /// Convenient helper to get last name dynamically.
  String get lastName {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.length > 1 ? parts.sublist(1).join(' ') : '';
  }

  /// Profile avatar initials.
  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    if (f.isNotEmpty && l.isNotEmpty) return '$f$l';
    if (f.isNotEmpty) return f;
    return 'U';
  }

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
        if (gender != null) 'gender': gender,
        if (state != null) 'state': state,
        if (city != null) 'city': city,
        if (currentAddress != null) 'current_address': currentAddress,
        if (emergencyContactName != null) 'emergency_contact_name': emergencyContactName,
        if (emergencyContactPhone != null) 'emergency_contact_phone': emergencyContactPhone,
      };

  ProfileDto copyWith({
    String? id,
    String? fullName,
    String? phoneNumber,
    String? email,
    String? avatarUrl,
    List<UserRole>? roles,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? carbonAvoidedKg,
    int? ecoPointsBalance,
    String? gender,
    String? state,
    String? city,
    String? currentAddress,
    String? emergencyContactName,
    String? emergencyContactPhone,
  }) {
    return ProfileDto(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      roles: roles ?? this.roles,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      carbonAvoidedKg: carbonAvoidedKg ?? this.carbonAvoidedKg,
      ecoPointsBalance: ecoPointsBalance ?? this.ecoPointsBalance,
      gender: gender ?? this.gender,
      state: state ?? this.state,
      city: city ?? this.city,
      currentAddress: currentAddress ?? this.currentAddress,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
    );
  }

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
        gender,
        state,
        city,
        currentAddress,
        emergencyContactName,
        emergencyContactPhone,
      ];
}
