import 'package:app_models/app_models.dart';

enum RiderComplianceStatus {
  pendingReview(label: 'Pending Review'),
  approved(label: 'Certified & Active'),
  suspended(label: 'Suspended');

  const RiderComplianceStatus({required this.label});
  final String label;
}

class AdminRiderApplicant {
  const AdminRiderApplicant({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.vehiclePlate,
    required this.vehicleClass,
    required this.batteryCapacity,
    required this.batteryHealthPercent,
    required this.status,
    required this.certifiedTiers,
    required this.documents,
    required this.ratingAverage,
    required this.completedTrips,
    required this.appliedDate,
  });

  final String id;
  final String fullName;
  final String phone;
  final String email;
  final String vehiclePlate;
  final String vehicleClass;
  final String batteryCapacity;
  final int batteryHealthPercent;
  final RiderComplianceStatus status;
  final List<ServiceTierEligibility> certifiedTiers;
  final List<RiderDocumentDto> documents;
  final double ratingAverage;
  final int completedTrips;
  final String appliedDate;

  bool get isSchoolRunCertified => certifiedTiers.contains(ServiceTierEligibility.schoolRunCommute);

  AdminRiderApplicant copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? email,
    String? vehiclePlate,
    String? vehicleClass,
    String? batteryCapacity,
    int? batteryHealthPercent,
    RiderComplianceStatus? status,
    List<ServiceTierEligibility>? certifiedTiers,
    List<RiderDocumentDto>? documents,
    double? ratingAverage,
    int? completedTrips,
    String? appliedDate,
  }) {
    return AdminRiderApplicant(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      vehiclePlate: vehiclePlate ?? this.vehiclePlate,
      vehicleClass: vehicleClass ?? this.vehicleClass,
      batteryCapacity: batteryCapacity ?? this.batteryCapacity,
      batteryHealthPercent: batteryHealthPercent ?? this.batteryHealthPercent,
      status: status ?? this.status,
      certifiedTiers: certifiedTiers ?? this.certifiedTiers,
      documents: documents ?? this.documents,
      ratingAverage: ratingAverage ?? this.ratingAverage,
      completedTrips: completedTrips ?? this.completedTrips,
      appliedDate: appliedDate ?? this.appliedDate,
    );
  }
}

class RiderManagementState {
  const RiderManagementState({
    this.riders = const [],
    this.selectedStatusFilter = 'ALL',
    this.searchQuery = '',
    this.selectedRider,
    this.isLoading = false,
    this.actionMessage,
  });

  final List<AdminRiderApplicant> riders;
  final String selectedStatusFilter;
  final String searchQuery;
  final AdminRiderApplicant? selectedRider;
  final bool isLoading;
  final String? actionMessage;

  List<AdminRiderApplicant> get filteredRiders {
    return riders.where((r) {
      if (selectedStatusFilter != 'ALL' && r.status.name != selectedStatusFilter) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        return r.fullName.toLowerCase().contains(q) ||
            r.vehiclePlate.toLowerCase().contains(q) ||
            r.phone.contains(q);
      }
      return true;
    }).toList();
  }

  int get pendingCount => riders.where((r) => r.status == RiderComplianceStatus.pendingReview).length;
  int get approvedCount => riders.where((r) => r.status == RiderComplianceStatus.approved).length;
  int get suspendedCount => riders.where((r) => r.status == RiderComplianceStatus.suspended).length;

  RiderManagementState copyWith({
    List<AdminRiderApplicant>? riders,
    String? selectedStatusFilter,
    String? searchQuery,
    AdminRiderApplicant? selectedRider,
    bool? isLoading,
    String? actionMessage,
  }) {
    return RiderManagementState(
      riders: riders ?? this.riders,
      selectedStatusFilter: selectedStatusFilter ?? this.selectedStatusFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedRider: selectedRider ?? this.selectedRider,
      isLoading: isLoading ?? this.isLoading,
      actionMessage: actionMessage ?? this.actionMessage,
    );
  }
}
