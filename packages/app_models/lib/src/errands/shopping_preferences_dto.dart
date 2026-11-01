import 'package:equatable/equatable.dart';
import 'substitution_policy.dart';

/// DTO for shopping substitution and quality preferences (Screen A4 & ME-A03).
class ShoppingPreferencesDto extends Equatable {
  const ShoppingPreferencesDto({
    this.substitutionPolicy = SubstitutionPolicy.contactFirst,
    this.additionalInstructions = '',
  });

  factory ShoppingPreferencesDto.fromJson(Map<String, dynamic> json) {
    return ShoppingPreferencesDto(
      substitutionPolicy: SubstitutionPolicy.fromString(
        json['substitution_policy'] as String?,
      ),
      additionalInstructions:
          json['additional_instructions'] as String? ?? '',
    );
  }

  final SubstitutionPolicy substitutionPolicy;
  final String additionalInstructions;

  ShoppingPreferencesDto copyWith({
    SubstitutionPolicy? substitutionPolicy,
    String? additionalInstructions,
  }) {
    return ShoppingPreferencesDto(
      substitutionPolicy: substitutionPolicy ?? this.substitutionPolicy,
      additionalInstructions:
          additionalInstructions ?? this.additionalInstructions,
    );
  }

  Map<String, dynamic> toJson() => {
        'substitution_policy': substitutionPolicy.code,
        'additional_instructions': additionalInstructions,
      };

  @override
  List<Object?> get props => [substitutionPolicy, additionalInstructions];
}

