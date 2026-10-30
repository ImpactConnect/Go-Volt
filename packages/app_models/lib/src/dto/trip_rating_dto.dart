import 'package:equatable/equatable.dart';

/// Post-trip rating and feedback submission (Screen 17: RIDE-13).
class TripRatingDto extends Equatable {
  TripRatingDto({
    required this.bookingId,
    required this.rating,
    this.compliments = const [],
    this.comment,
    this.wouldRideAgain,
    this.tipAmountKobo = 0,
    DateTime? submittedAt,
  }) : submittedAt = submittedAt ?? DateTime.now();

  factory TripRatingDto.fromJson(Map<String, dynamic> json) {
    return TripRatingDto(
      bookingId: json['booking_id'] as String,
      rating: (json['rating'] as num).toInt(),
      compliments: (json['compliments'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      comment: json['comment'] as String?,
      wouldRideAgain: json['would_ride_again'] as bool?,
      tipAmountKobo: (json['tip_amount_kobo'] as num?)?.toInt() ?? 0,
      submittedAt: json['submitted_at'] != null
          ? DateTime.parse(json['submitted_at'] as String)
          : null,
    );
  }

  final String bookingId;
  final int rating;
  final List<String> compliments;
  final String? comment;
  final bool? wouldRideAgain;
  final int tipAmountKobo;
  final DateTime submittedAt;

  Map<String, dynamic> toJson() => {
        'booking_id': bookingId,
        'rating': rating,
        'compliments': compliments,
        'comment': comment,
        'would_ride_again': wouldRideAgain,
        'tip_amount_kobo': tipAmountKobo,
        'submitted_at': submittedAt.toIso8601String(),
      };

  @override
  List<Object?> get props => [
        bookingId,
        rating,
        compliments,
        comment,
        wouldRideAgain,
        tipAmountKobo,
        submittedAt,
      ];
}
