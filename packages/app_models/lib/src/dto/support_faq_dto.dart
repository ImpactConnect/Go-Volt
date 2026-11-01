import 'package:equatable/equatable.dart';

/// Help Centre FAQ article (§D3).
class SupportFaqDto extends Equatable {
  const SupportFaqDto({
    required this.id,
    required this.category, // 'Rides', 'Delivery', 'Market Errand', 'School Run', 'Wallet', 'Account', 'Safety'
    required this.question,
    required this.answer,
    this.helpfulCount = 0,
  });

  factory SupportFaqDto.fromJson(Map<String, dynamic> json) {
    return SupportFaqDto(
      id: json['id'] as String,
      category: json['category'] as String,
      question: json['question'] as String,
      answer: json['answer'] as String,
      helpfulCount: (json['helpful_count'] as num?)?.toInt() ?? 0,
    );
  }

  final String id;
  final String category;
  final String question;
  final String answer;
  final int helpfulCount;

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'question': question,
        'answer': answer,
        'helpful_count': helpfulCount,
      };

  @override
  List<Object?> get props => [id, category, question, answer, helpfulCount];
}

