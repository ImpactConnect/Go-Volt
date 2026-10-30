import 'package:equatable/equatable.dart';

/// DTO representing package dimension and weight bands (Screen 3: Package size dropdown).
class ParcelSizeBandDto extends Equatable {
  const ParcelSizeBandDto({
    required this.code,
    required this.label,
    required this.maxWeightKg,
    this.surchargeKobo = 0,
  });

  factory ParcelSizeBandDto.fromJson(Map<String, dynamic> json) {
    return ParcelSizeBandDto(
      code: (json['code'] as String? ?? 'SMALL').toUpperCase(),
      label: json['label'] as String? ?? 'Small (Up to 2 kg)',
      maxWeightKg: (json['max_weight_kg'] as num?)?.toDouble() ?? 2.0,
      surchargeKobo: (json['surcharge_kobo'] as num?)?.toInt() ?? 0,
    );
  }

  final String code;
  final String label;
  final double maxWeightKg;
  final int surchargeKobo;

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'label': label,
      'max_weight_kg': maxWeightKg,
      'surcharge_kobo': surchargeKobo,
    };
  }

  static const ParcelSizeBandDto small = ParcelSizeBandDto(
    code: 'SMALL',
    label: 'Small (Up to 2 kg)',
    maxWeightKg: 2.0,
    surchargeKobo: 0,
  );

  static const ParcelSizeBandDto medium = ParcelSizeBandDto(
    code: 'MEDIUM',
    label: 'Medium (Up to 5 kg)',
    maxWeightKg: 5.0,
    surchargeKobo: 20000,
  );

  static const ParcelSizeBandDto large = ParcelSizeBandDto(
    code: 'LARGE',
    label: 'Large (Up to 15 kg)',
    maxWeightKg: 15.0,
    surchargeKobo: 50000,
  );

  static const List<ParcelSizeBandDto> defaultBands = [
    small,
    medium,
    large,
  ];

  @override
  List<Object?> get props => [code, label, maxWeightKg, surchargeKobo];
}
