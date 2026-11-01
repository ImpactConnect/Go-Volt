import 'package:equatable/equatable.dart';
import 'scheduled_plan_dto.dart';

/// Child passenger profile managed by verified guardian for School Run.
class SchoolPassengerProfileDto extends Equatable {
  const SchoolPassengerProfileDto({
    required this.id,
    required this.childName,
    required this.age,
    required this.grade,
    required this.schoolName,
    required this.pickupAddress,
    required this.emergencyPhone,
    this.authorizedContacts = const [],
    this.status = 'ACTIVE',
  });

  factory SchoolPassengerProfileDto.fromJson(Map<String, dynamic> json) {
    return SchoolPassengerProfileDto(
      id: json['id'] as String,
      childName: json['child_name'] as String,
      age: (json['age'] as num).toInt(),
      grade: json['grade'] as String,
      schoolName: json['school_name'] as String,
      pickupAddress: json['pickup_address'] as String,
      emergencyPhone: json['emergency_phone'] as String,
      authorizedContacts: (json['authorized_contacts'] as List<dynamic>?)
              ?.map((e) =>
                  AuthorizedContactDto.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      status: json['status'] as String? ?? 'ACTIVE',
    );
  }

  final String id;
  final String childName;
  final int age;
  final String grade;
  final String schoolName;
  final String pickupAddress;
  final String emergencyPhone;
  final List<AuthorizedContactDto> authorizedContacts;
  final String status;

  Map<String, dynamic> toJson() => {
        'id': id,
        'child_name': childName,
        'age': age,
        'grade': grade,
        'school_name': schoolName,
        'pickup_address': pickupAddress,
        'emergency_phone': emergencyPhone,
        'authorized_contacts':
            authorizedContacts.map((c) => c.toJson()).toList(),
        'status': status,
      };

  @override
  List<Object?> get props => [id, childName, schoolName, grade, status];
}

/// Verification payload submitted upon child arrival at school or destination.
class HandoverVerificationDto extends Equatable {
  const HandoverVerificationDto({
    required this.tripId,
    required this.passengerName,
    required this.schoolName,
    required this.authorizedRecipientName,
    required this.recipientRole,
    required this.verificationCode,
    this.verifiedAt,
    this.notes,
  });

  factory HandoverVerificationDto.fromJson(Map<String, dynamic> json) {
    return HandoverVerificationDto(
      tripId: json['trip_id'] as String,
      passengerName: json['passenger_name'] as String,
      schoolName: json['school_name'] as String,
      authorizedRecipientName: json['authorized_recipient_name'] as String,
      recipientRole: json['recipient_role'] as String,
      verificationCode: json['verification_code'] as String,
      verifiedAt: json['verified_at'] != null
          ? DateTime.tryParse(json['verified_at'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }

  final String tripId;
  final String passengerName;
  final String schoolName;
  final String authorizedRecipientName;
  final String recipientRole;
  final String verificationCode;
  final DateTime? verifiedAt;
  final String? notes;

  Map<String, dynamic> toJson() => {
        'trip_id': tripId,
        'passenger_name': passengerName,
        'school_name': schoolName,
        'authorized_recipient_name': authorizedRecipientName,
        'recipient_role': recipientRole,
        'verification_code': verificationCode,
        if (verifiedAt != null) 'verified_at': verifiedAt!.toIso8601String(),
        if (notes != null) 'notes': notes,
      };

  @override
  List<Object?> get props => [
        tripId,
        passengerName,
        authorizedRecipientName,
        verificationCode,
      ];
}
