import 'package:equatable/equatable.dart';
import '../dto/location_dto.dart';
import 'errand_urgency.dart';

/// DTO for custom / Other Errand task requirements (Screens C2 & C3, ME-C01/C02).
class CustomErrandDetailsDto extends Equatable {
  const CustomErrandDetailsDto({
    required this.description,
    this.category = 'General Errand',
    this.urgency = ErrandUrgency.standard,
    required this.taskLocation,
    required this.contactPerson,
    required this.phoneNumber,
    this.deliveryLocation,
    this.additionalInstructions,
  });

  factory CustomErrandDetailsDto.fromJson(Map<String, dynamic> json) {
    return CustomErrandDetailsDto(
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? 'General Errand',
      urgency: ErrandUrgency.fromString(json['urgency'] as String?),
      taskLocation: json['task_location'] != null
          ? LocationDto.fromJson(json['task_location'] as Map<String, dynamic>)
          : const LocationDto(
              latitude: 0.0,
              longitude: 0.0,
              address: '',
            ),
      contactPerson: json['contact_person'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      deliveryLocation: json['delivery_location'] != null
          ? LocationDto.fromJson(
              json['delivery_location'] as Map<String, dynamic>)
          : null,
      additionalInstructions: json['additional_instructions'] as String?,
    );
  }

  final String description;
  final String category;
  final ErrandUrgency urgency;
  final LocationDto taskLocation;
  final String contactPerson;
  final String phoneNumber;
  final LocationDto? deliveryLocation;
  final String? additionalInstructions;

  Map<String, dynamic> toJson() => {
        'description': description,
        'category': category,
        'urgency': urgency.code,
        'task_location': taskLocation.toJson(),
        'contact_person': contactPerson,
        'phone_number': phoneNumber,
        if (deliveryLocation != null)
          'delivery_location': deliveryLocation!.toJson(),
        if (additionalInstructions != null)
          'additional_instructions': additionalInstructions,
      };

  @override
  List<Object?> get props => [
        description,
        category,
        urgency,
        taskLocation,
        contactPerson,
        phoneNumber,
        deliveryLocation,
      ];
}

