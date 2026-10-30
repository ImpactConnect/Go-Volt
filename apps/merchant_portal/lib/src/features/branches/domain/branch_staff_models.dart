import 'package:equatable/equatable.dart';
import '../../../core/auth/merchant_role.dart';

class MerchantBranch extends Equatable {
  const MerchantBranch({
    required this.id,
    required this.name,
    required this.address,
    required this.zone,
    required this.managerName,
    required this.phone,
    required this.activeOrdersCount,
    this.isActive = true,
  });

  final String id;
  final String name;
  final String address;
  final String zone;
  final String managerName;
  final String phone;
  final int activeOrdersCount;
  final bool isActive;

  MerchantBranch copyWith({
    String? id,
    String? name,
    String? address,
    String? zone,
    String? managerName,
    String? phone,
    int? activeOrdersCount,
    bool? isActive,
  }) {
    return MerchantBranch(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      zone: zone ?? this.zone,
      managerName: managerName ?? this.managerName,
      phone: phone ?? this.phone,
      activeOrdersCount: activeOrdersCount ?? this.activeOrdersCount,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        address,
        zone,
        managerName,
        phone,
        activeOrdersCount,
        isActive,
      ];
}

class MerchantStaffMember extends Equatable {
  const MerchantStaffMember({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    required this.assignedBranchIds,
    required this.status,
    required this.lastActive,
  });

  final String id;
  final String fullName;
  final String email;
  final MerchantRole role;
  final List<String> assignedBranchIds;
  final String status; // 'active', 'invited', 'suspended'
  final String lastActive;

  bool get isActive => status == 'active' || status == 'invited';
  String get name => fullName;
  String? get branchId => assignedBranchIds.isNotEmpty ? assignedBranchIds.first : null;

  MerchantStaffMember copyWith({
    String? id,
    String? fullName,
    String? email,
    MerchantRole? role,
    List<String>? assignedBranchIds,
    String? status,
    String? lastActive,
  }) {
    return MerchantStaffMember(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      assignedBranchIds: assignedBranchIds ?? this.assignedBranchIds,
      status: status ?? this.status,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        email,
        role,
        assignedBranchIds,
        status,
        lastActive,
      ];
}
