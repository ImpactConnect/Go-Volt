import 'package:equatable/equatable.dart';

/// DTO representing delivery feedback and courier rating (Screen 17: Rate your experience).
class ParcelRatingDto extends Equatable {
  const ParcelRatingDto({
    required this.trackingNumber,
    required this.ratingStars,
    this.compliments = const [],
    this.comment,
    this.riderName = 'Courier',
    this.riderVehicle = 'Go-Volt Delivery',
    required this.submittedAt,
  });

  factory ParcelRatingDto.fromJson(Map<String, dynamic> json) {
    return ParcelRatingDto(
      trackingNumber: json['tracking_number'] as String? ?? '',
      ratingStars: (json['rating_stars'] as num?)?.toInt() ?? 5,
      compliments: (json['compliments'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      comment: json['comment'] as String?,
      riderName: json['rider_name'] as String? ?? 'Courier',
      riderVehicle: json['rider_vehicle'] as String? ?? 'Go-Volt Delivery',
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
          : DateTime.now(),
    );
  }

  final String trackingNumber;
  final int ratingStars;
  final List<String> compliments;
  final String? comment;
  final String riderName;
  final String riderVehicle;
  final DateTime submittedAt;

  Map<String, dynamic> toJson() {
    return {
      'tracking_number': trackingNumber,
      'rating_stars': ratingStars,
      'compliments': compliments,
      if (comment != null) 'comment': comment,
      'rider_name': riderName,
      'rider_vehicle': riderVehicle,
      'submitted_at': submittedAt.toIso8601String(),
    };
  }

  static const List<String> availableCompliments = [
    'Excellent',
    'Good',
    'On time',
    'Handled with care',
    'Great communication',
    'Others',
  ];

  @override
  List<Object?> get props => [
        trackingNumber,
        ratingStars,
        compliments,
        comment,
        riderName,
        riderVehicle,
        submittedAt,
      ];
}
