import 'package:equatable/equatable.dart';
import '../enums/domain_enums.dart';

/// Notification model for the customer notification center.
class CustomerNotificationDto extends Equatable {
  const CustomerNotificationDto({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    required this.timestamp,
    this.isRead = false,
    this.targetRoute,
    this.metadata,
  });

  factory CustomerNotificationDto.fromJson(Map<String, dynamic> json) {
    return CustomerNotificationDto(
      id: json['id'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      category: NotificationCategory.fromString(json['category'] as String? ?? 'ALL'),
      timestamp: DateTime.parse(json['timestamp'] as String),
      isRead: json['is_read'] as bool? ?? false,
      targetRoute: json['target_route'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  final String id;
  final String title;
  final String message;
  final NotificationCategory category;
  final DateTime timestamp;
  final bool isRead;
  final String? targetRoute;
  final Map<String, dynamic>? metadata;

  CustomerNotificationDto copyWith({
    String? id,
    String? title,
    String? message,
    NotificationCategory? category,
    DateTime? timestamp,
    bool? isRead,
    String? targetRoute,
    Map<String, dynamic>? metadata,
  }) {
    return CustomerNotificationDto(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      category: category ?? this.category,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      targetRoute: targetRoute ?? this.targetRoute,
      metadata: metadata ?? this.metadata,
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} mins ago';
    if (diff.inHours < 24) return '${diff.inHours} ${diff.inHours == 1 ? "hour" : "hours"} ago';
    return '${diff.inDays} ${diff.inDays == 1 ? "day" : "days"} ago';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'message': message,
        'category': category.code,
        'timestamp': timestamp.toIso8601String(),
        'is_read': isRead,
        if (targetRoute != null) 'target_route': targetRoute,
        if (metadata != null) 'metadata': metadata,
      };

  @override
  List<Object?> get props => [id, title, message, category, timestamp, isRead, targetRoute, metadata];
}

