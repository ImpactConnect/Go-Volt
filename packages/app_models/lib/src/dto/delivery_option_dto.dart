import 'package:equatable/equatable.dart';

/// DTO modeling backend-published parcel delivery types (Screen 2: Choose Delivery Type).
///
/// Features:
/// - Canonical codes: STANDARD, EXPRESS, SCHEDULED.
/// - Turnaround service-level descriptions.
/// - Integer minor base fare (`baseFareKobo`).
class DeliveryOptionDto extends Equatable {
  const DeliveryOptionDto({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.iconKey,
    required this.baseFareKobo,
    this.estimatedHoursMin,
    this.estimatedHoursMax,
    this.isDefault = false,
  });

  factory DeliveryOptionDto.fromJson(Map<String, dynamic> json) {
    return DeliveryOptionDto(
      id: json['id'] as String? ?? 'del_opt_standard',
      code: (json['code'] as String? ?? 'STANDARD').toUpperCase(),
      title: json['title'] as String? ?? 'Standard Delivery',
      description: json['description'] as String? ?? 'Delivery within 2 - 4 hours',
      iconKey: json['icon_key'] as String? ?? 'inventory_2',
      baseFareKobo: (json['base_fare_kobo'] as num?)?.toInt() ?? 200000,
      estimatedHoursMin: (json['estimated_hours_min'] as num?)?.toDouble() ?? 2.0,
      estimatedHoursMax: (json['estimated_hours_max'] as num?)?.toDouble() ?? 4.0,
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  final String id;
  final String code;
  final String title;
  final String description;
  final String iconKey;
  final int baseFareKobo;
  final double? estimatedHoursMin;
  final double? estimatedHoursMax;
  final bool isDefault;

  String get formattedBaseFare {
    final naira = (baseFareKobo / 100).toStringAsFixed(0);
    return '₦$naira';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'description': description,
      'icon_key': iconKey,
      'base_fare_kobo': baseFareKobo,
      'estimated_hours_min': estimatedHoursMin,
      'estimated_hours_max': estimatedHoursMax,
      'is_default': isDefault,
    };
  }

  static const DeliveryOptionDto standard = DeliveryOptionDto(
    id: 'del_opt_std_01',
    code: 'STANDARD',
    title: 'Standard Delivery',
    description: 'Delivery within 2 - 4 hours',
    iconKey: 'inventory_2',
    baseFareKobo: 200000,
    estimatedHoursMin: 2.0,
    estimatedHoursMax: 4.0,
    isDefault: true,
  );

  static const DeliveryOptionDto express = DeliveryOptionDto(
    id: 'del_opt_exp_02',
    code: 'EXPRESS',
    title: 'Express Delivery',
    description: 'Faster delivery within 1 hour',
    iconKey: 'bolt',
    baseFareKobo: 350000,
    estimatedHoursMin: 0.5,
    estimatedHoursMax: 1.0,
    isDefault: false,
  );

  static const DeliveryOptionDto scheduled = DeliveryOptionDto(
    id: 'del_opt_sch_03',
    code: 'SCHEDULED',
    title: 'Scheduled Delivery',
    description: 'Choose a date and time',
    iconKey: 'calendar_month',
    baseFareKobo: 250000,
    isDefault: false,
  );

  static const List<DeliveryOptionDto> defaultOptions = [
    standard,
    express,
    scheduled,
  ];

  @override
  List<Object?> get props => [
        id,
        code,
        title,
        description,
        iconKey,
        baseFareKobo,
        estimatedHoursMin,
        estimatedHoursMax,
        isDefault,
      ];
}
