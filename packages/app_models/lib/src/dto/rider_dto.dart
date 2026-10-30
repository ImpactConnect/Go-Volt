import 'package:equatable/equatable.dart';
import '../enums/domain_enums.dart';

/// Current operational status of the rider.
enum RiderStatus {
  offline('OFFLINE', 'Offline'),
  online('ONLINE', 'Online & Available'),
  assigned('ASSIGNED', 'Job Assigned'),
  onPickup('ON_PICKUP', 'Approaching Pickup'),
  inTransit('IN_TRANSIT', 'In Transit'),
  pendingApproval('PENDING_APPROVAL', 'Application Under Review'),
  suspended('SUSPENDED', 'Account Suspended');

  const RiderStatus(this.code, this.label);
  final String code;
  final String label;

  static RiderStatus fromString(String raw) {
    return RiderStatus.values.firstWhere(
      (s) => s.code == raw || s.name == raw,
      orElse: () => RiderStatus.offline,
    );
  }
}

/// Regulatory and compliance documents required for rider verification.
enum DocumentType {
  nationalId('NIN', 'National Identity Card (NIN)'),
  driversLicense('DRIVERS_LICENSE', "Driver's / Rider's License"),
  lasrra('LASRRA', 'LASRRA Resident Card'),
  vehicleRegistration('VEHICLE_REG', 'Vehicle Registration & Ownership Proof'),
  insuranceCert('INSURANCE', 'Valid Motor Insurance Certificate'),
  roadworthinessCert('ROADWORTHINESS', 'State Roadworthiness Certificate');

  const DocumentType(this.code, this.title);
  final String code;
  final String title;

  static DocumentType fromString(String raw) {
    return DocumentType.values.firstWhere(
      (d) => d.code == raw || d.name == raw,
      orElse: () => DocumentType.nationalId,
    );
  }
}

/// Verification status of uploaded onboarding documents.
enum DocumentVerificationStatus {
  pending('PENDING', 'Under Review'),
  approved('APPROVED', 'Verified & Approved'),
  rejected('REJECTED', 'Action Required / Rejected'),
  expired('EXPIRED', 'Document Expired');

  const DocumentVerificationStatus(this.code, this.label);
  final String code;
  final String label;

  static DocumentVerificationStatus fromString(String raw) {
    return DocumentVerificationStatus.values.firstWhere(
      (s) => s.code == raw || s.name == raw,
      orElse: () => DocumentVerificationStatus.pending,
    );
  }
}

/// Service tiers a rider is vetted and certified to fulfill.
enum ServiceTierEligibility {
  parcelDelivery('PARCEL_DELIVERY', 'Parcel & Cargo Delivery'),
  passengerRide('PASSENGER_RIDE', 'Passenger EV Commute'),
  schoolRunCommute('SCHOOL_RUN', 'School-Run Dedicated Chaperone');

  const ServiceTierEligibility(this.code, this.label);
  final String code;
  final String label;

  static ServiceTierEligibility fromString(String raw) {
    return ServiceTierEligibility.values.firstWhere(
      (e) => e.code == raw || e.name == raw,
      orElse: () => ServiceTierEligibility.parcelDelivery,
    );
  }
}

/// KYC / Onboarding document metadata.
class RiderDocumentDto extends Equatable {
  const RiderDocumentDto({
    required this.id,
    required this.type,
    required this.documentNumber,
    required this.fileUrl,
    required this.expiryDate,
    this.status = DocumentVerificationStatus.pending,
    this.rejectionReason,
  });

  factory RiderDocumentDto.fromJson(Map<String, dynamic> json) {
    return RiderDocumentDto(
      id: json['id'] as String,
      type: DocumentType.fromString(json['type'] as String),
      documentNumber: json['document_number'] as String,
      fileUrl: json['file_url'] as String,
      expiryDate: DateTime.parse(json['expiry_date'] as String),
      status: DocumentVerificationStatus.fromString(
        json['status'] as String? ?? 'PENDING',
      ),
      rejectionReason: json['rejection_reason'] as String?,
    );
  }

  final String id;
  final DocumentType type;
  final String documentNumber;
  final String fileUrl;
  final DateTime expiryDate;
  final DocumentVerificationStatus status;
  final String? rejectionReason;

  bool get isExpired => expiryDate.isBefore(DateTime.now());
  bool get isValid =>
      status == DocumentVerificationStatus.approved && !isExpired;

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.code,
    'document_number': documentNumber,
    'file_url': fileUrl,
    'expiry_date': expiryDate.toIso8601String(),
    'status': status.code,
    if (rejectionReason != null) 'rejection_reason': rejectionReason,
  };

  @override
  List<Object?> get props => [
    id,
    type,
    documentNumber,
    fileUrl,
    expiryDate,
    status,
    rejectionReason,
  ];
}

/// Vetted referee or guarantor for rider accountability.
class RiderGuarantorDto extends Equatable {
  const RiderGuarantorDto({
    required this.fullName,
    required this.phoneNumber,
    required this.relationship,
    required this.residentialAddress,
    this.isVerified = false,
  });

  factory RiderGuarantorDto.fromJson(Map<String, dynamic> json) {
    return RiderGuarantorDto(
      fullName: json['full_name'] as String,
      phoneNumber: json['phone_number'] as String,
      relationship: json['relationship'] as String,
      residentialAddress: json['residential_address'] as String,
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }

  final String fullName;
  final String phoneNumber;
  final String relationship;
  final String residentialAddress;
  final bool isVerified;

  Map<String, dynamic> toJson() => {
    'full_name': fullName,
    'phone_number': phoneNumber,
    'relationship': relationship,
    'residential_address': residentialAddress,
    'is_verified': isVerified,
  };

  @override
  List<Object?> get props => [
    fullName,
    phoneNumber,
    relationship,
    residentialAddress,
    isVerified,
  ];
}

/// Comprehensive Rider entity.
class RiderDto extends Equatable {
  const RiderDto({
    required this.id,
    required this.profileId,
    required this.fullName,
    required this.phoneNumber,
    this.email,
    required this.vehiclePlate,
    required this.vehicleModel,
    this.vehicleType = VehicleType.electricBike,
    this.batteryLevelPercent = 92,
    this.rating = 4.95,
    this.totalTripsCompleted = 240,
    this.status = RiderStatus.offline,
    this.eligibilities = const [
      ServiceTierEligibility.parcelDelivery,
      ServiceTierEligibility.passengerRide,
    ],
    this.activeServiceZone = 'Lagos - Victoria Island / Lekki',
    this.documents = const [],
    this.guarantor,
    this.trainingCompleted = true,
  });

  factory RiderDto.fromJson(Map<String, dynamic> json) {
    return RiderDto(
      id: json['id'] as String,
      profileId: json['profile_id'] as String,
      fullName: json['full_name'] as String,
      phoneNumber: json['phone_number'] as String,
      email: json['email'] as String?,
      vehiclePlate: json['vehicle_plate'] as String,
      vehicleModel: json['vehicle_model'] as String,
      vehicleType: VehicleType.fromString(
        json['vehicle_type'] as String? ?? 'EV_BIKE',
      ),
      batteryLevelPercent:
          (json['battery_level_percent'] as num?)?.toInt() ?? 90,
      rating: (json['rating'] as num?)?.toDouble() ?? 5.0,
      totalTripsCompleted:
          (json['total_trips_completed'] as num?)?.toInt() ?? 0,
      status: RiderStatus.fromString(json['status'] as String? ?? 'OFFLINE'),
      eligibilities:
          (json['eligibilities'] as List<dynamic>?)
              ?.map((e) => ServiceTierEligibility.fromString(e.toString()))
              .toList() ??
          const [],
      activeServiceZone:
          json['active_service_zone'] as String? ??
          'Lagos - Victoria Island / Lekki',
      documents:
          (json['documents'] as List<dynamic>?)
              ?.map((d) => RiderDocumentDto.fromJson(d as Map<String, dynamic>))
              .toList() ??
          const [],
      guarantor:
          json['guarantor'] != null
              ? RiderGuarantorDto.fromJson(
                json['guarantor'] as Map<String, dynamic>,
              )
              : null,
      trainingCompleted: json['training_completed'] as bool? ?? false,
    );
  }

  final String id;
  final String profileId;
  final String fullName;
  final String phoneNumber;
  final String? email;
  final String vehiclePlate;
  final String vehicleModel;
  final VehicleType vehicleType;
  final int batteryLevelPercent;
  final double rating;
  final int totalTripsCompleted;
  final RiderStatus status;
  final List<ServiceTierEligibility> eligibilities;
  final String activeServiceZone;
  final List<RiderDocumentDto> documents;
  final RiderGuarantorDto? guarantor;
  final bool trainingCompleted;

  bool get canGoOnline {
    if (status == RiderStatus.suspended || status == RiderStatus.pendingApproval) {
      return false;
    }
    if (batteryLevelPercent < 15) return false;
    final hasExpiredDocs = documents.any((d) => d.isExpired);
    return !hasExpiredDocs;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'profile_id': profileId,
    'full_name': fullName,
    'phone_number': phoneNumber,
    if (email != null) 'email': email,
    'vehicle_plate': vehiclePlate,
    'vehicle_model': vehicleModel,
    'vehicle_type': vehicleType.code,
    'battery_level_percent': batteryLevelPercent,
    'rating': rating,
    'total_trips_completed': totalTripsCompleted,
    'status': status.code,
    'eligibilities': eligibilities.map((e) => e.code).toList(),
    'active_service_zone': activeServiceZone,
    'documents': documents.map((d) => d.toJson()).toList(),
    if (guarantor != null) 'guarantor': guarantor!.toJson(),
    'training_completed': trainingCompleted,
  };

  @override
  List<Object?> get props => [
    id,
    profileId,
    fullName,
    phoneNumber,
    email,
    vehiclePlate,
    vehicleModel,
    vehicleType,
    batteryLevelPercent,
    rating,
    totalTripsCompleted,
    status,
    eligibilities,
    activeServiceZone,
    documents,
    guarantor,
    trainingCompleted,
  ];
}

/// Daily shift performance and metrics.
class RiderShiftDto extends Equatable {
  const RiderShiftDto({
    required this.onlineHoursToday,
    required this.earningsTodayKobo,
    required this.jobsCompletedToday,
    required this.acceptanceRatePercent,
    this.batterySwapRecommended = false,
  });

  factory RiderShiftDto.fromJson(Map<String, dynamic> json) {
    return RiderShiftDto(
      onlineHoursToday:
          (json['online_hours_today'] as num?)?.toDouble() ?? 0.0,
      earningsTodayKobo: (json['earnings_today_kobo'] as num?)?.toInt() ?? 0,
      jobsCompletedToday: (json['jobs_completed_today'] as num?)?.toInt() ?? 0,
      acceptanceRatePercent:
          (json['acceptance_rate_percent'] as num?)?.toInt() ?? 100,
      batterySwapRecommended:
          json['battery_swap_recommended'] as bool? ?? false,
    );
  }

  final double onlineHoursToday;
  final int earningsTodayKobo;
  final int jobsCompletedToday;
  final int acceptanceRatePercent;
  final bool batterySwapRecommended;

  double get earningsTodayNaira => earningsTodayKobo / 100.0;

  Map<String, dynamic> toJson() => {
    'online_hours_today': onlineHoursToday,
    'earnings_today_kobo': earningsTodayKobo,
    'jobs_completed_today': jobsCompletedToday,
    'acceptance_rate_percent': acceptanceRatePercent,
    'battery_swap_recommended': batterySwapRecommended,
  };

  @override
  List<Object?> get props => [
    onlineHoursToday,
    earningsTodayKobo,
    jobsCompletedToday,
    acceptanceRatePercent,
    batterySwapRecommended,
  ];
}
