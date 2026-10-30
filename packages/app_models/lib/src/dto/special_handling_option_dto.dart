import 'package:equatable/equatable.dart';

/// DTO modeling special handling options (Screen 3: Special handling toggles).
///
/// Features:
/// - Fragile (Handle with care)
/// - Keep upright
/// - Perishable (e.g. food)
/// - Surcharge in integer kobo.
class SpecialHandlingOptionDto extends Equatable {
  const SpecialHandlingOptionDto({
    required this.code,
    required this.label,
    this.surchargeKobo = 0,
    this.isEnabled = false,
  });

  factory SpecialHandlingOptionDto.fromJson(Map<String, dynamic> json) {
    return SpecialHandlingOptionDto(
      code: (json['code'] as String? ?? 'FRAGILE').toUpperCase(),
      label: json['label'] as String? ?? 'Fragile (Handle with care)',
      surchargeKobo: (json['surcharge_kobo'] as num?)?.toInt() ?? 0,
      isEnabled: json['is_enabled'] as bool? ?? false,
    );
  }

  final String code;
  final String label;
  final int surchargeKobo;
  final bool isEnabled;

  SpecialHandlingOptionDto copyWith({
    String? code,
    String? label,
    int? surchargeKobo,
    bool? isEnabled,
  }) {
    return SpecialHandlingOptionDto(
      code: code ?? this.code,
      label: label ?? this.label,
      surchargeKobo: surchargeKobo ?? this.surchargeKobo,
      isEnabled: isEnabled ?? this.isEnabled,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'label': label,
      'surcharge_kobo': surchargeKobo,
      'is_enabled': isEnabled,
    };
  }

  static const SpecialHandlingOptionDto fragile = SpecialHandlingOptionDto(
    code: 'FRAGILE',
    label: 'Fragile (Handle with care)',
    surchargeKobo: 20000,
    isEnabled: false,
  );

  static const SpecialHandlingOptionDto keepUpright = SpecialHandlingOptionDto(
    code: 'KEEP_UPRIGHT',
    label: 'Keep upright',
    surchargeKobo: 0,
    isEnabled: false,
  );

  static const SpecialHandlingOptionDto perishable = SpecialHandlingOptionDto(
    code: 'PERISHABLE',
    label: 'Perishable (e.g. food)',
    surchargeKobo: 10000,
    isEnabled: false,
  );

  static const List<SpecialHandlingOptionDto> defaultOptions = [
    fragile,
    keepUpright,
    perishable,
  ];

  @override
  List<Object?> get props => [code, label, surchargeKobo, isEnabled];
}
