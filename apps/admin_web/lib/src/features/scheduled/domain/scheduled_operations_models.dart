import 'package:app_models/app_models.dart';
import 'package:equatable/equatable.dart';

/// School holiday or unplanned weather closure exception model (§21.6 & School Run Spec).
class SchoolCalendarExceptionModel extends Equatable {
  const SchoolCalendarExceptionModel({
    required this.id,
    required this.title,
    required this.reason,
    required this.startDate,
    required this.endDate,
    this.affectedSchools = const ['All Kaduna Schools'],
    this.isFullDay = true,
    this.notifyParents = true,
    this.notifyDrivers = true,
    this.status = 'ACTIVE', // ACTIVE, EXPIRED, CANCELLED
    required this.createdBy,
    required this.createdAt,
  });

  final String id;
  final String title;
  final String reason;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> affectedSchools;
  final bool isFullDay;
  final bool notifyParents;
  final bool notifyDrivers;
  final String status;
  final String createdBy;
  final DateTime createdAt;

  bool get isActive => status == 'ACTIVE';

  SchoolCalendarExceptionModel copyWith({
    String? id,
    String? title,
    String? reason,
    DateTime? startDate,
    DateTime? endDate,
    List<String>? affectedSchools,
    bool? isFullDay,
    bool? notifyParents,
    bool? notifyDrivers,
    String? status,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return SchoolCalendarExceptionModel(
      id: id ?? this.id,
      title: title ?? this.title,
      reason: reason ?? this.reason,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      affectedSchools: affectedSchools ?? this.affectedSchools,
      isFullDay: isFullDay ?? this.isFullDay,
      notifyParents: notifyParents ?? this.notifyParents,
      notifyDrivers: notifyDrivers ?? this.notifyDrivers,
      status: status ?? this.status,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        startDate,
        endDate,
        affectedSchools,
        status,
      ];
}

/// Minor student safekeeping and single-use handover OTP verification model (§21.2 & §21.6).
class GuardianSafekeepingModel extends Equatable {
  const GuardianSafekeepingModel({
    required this.passengerId,
    required this.passengerName,
    required this.age,
    required this.schoolName,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.morningTimeStr,
    required this.afternoonTimeStr,
    required this.authorizedContacts,
    required this.singleUseOtp,
    this.otpStatus = HandoverStatus.codePending,
    this.verifiedAt,
    this.verifiedByStaffOrDriver,
    this.specialCareNotes,
  });

  final String passengerId;
  final String passengerName;
  final int age;
  final String schoolName;
  final String pickupAddress;
  final String dropoffAddress;
  final String morningTimeStr;
  final String afternoonTimeStr;
  final List<AuthorizedContactDto> authorizedContacts;
  final String singleUseOtp;
  final HandoverStatus otpStatus;
  final DateTime? verifiedAt;
  final String? verifiedByStaffOrDriver;
  final String? specialCareNotes;

  bool get isVerified =>
      otpStatus == HandoverStatus.verified ||
      otpStatus == HandoverStatus.completed;

  GuardianSafekeepingModel copyWith({
    String? passengerId,
    String? passengerName,
    int? age,
    String? schoolName,
    String? pickupAddress,
    String? dropoffAddress,
    String? morningTimeStr,
    String? afternoonTimeStr,
    List<AuthorizedContactDto>? authorizedContacts,
    String? singleUseOtp,
    HandoverStatus? otpStatus,
    DateTime? verifiedAt,
    String? verifiedByStaffOrDriver,
    String? specialCareNotes,
  }) {
    return GuardianSafekeepingModel(
      passengerId: passengerId ?? this.passengerId,
      passengerName: passengerName ?? this.passengerName,
      age: age ?? this.age,
      schoolName: schoolName ?? this.schoolName,
      pickupAddress: pickupAddress ?? this.pickupAddress,
      dropoffAddress: dropoffAddress ?? this.dropoffAddress,
      morningTimeStr: morningTimeStr ?? this.morningTimeStr,
      afternoonTimeStr: afternoonTimeStr ?? this.afternoonTimeStr,
      authorizedContacts: authorizedContacts ?? this.authorizedContacts,
      singleUseOtp: singleUseOtp ?? this.singleUseOtp,
      otpStatus: otpStatus ?? this.otpStatus,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      verifiedByStaffOrDriver:
          verifiedByStaffOrDriver ?? this.verifiedByStaffOrDriver,
      specialCareNotes: specialCareNotes ?? this.specialCareNotes,
    );
  }

  @override
  List<Object?> get props => [
        passengerId,
        passengerName,
        schoolName,
        singleUseOtp,
        otpStatus,
        verifiedAt,
      ];
}

