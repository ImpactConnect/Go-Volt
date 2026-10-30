import 'package:app_models/app_models.dart';
import 'package:equatable/equatable.dart';

/// State representation for the Customer Notifications Center.
class NotificationsState extends Equatable {
  const NotificationsState({
    this.notifications = const [],
    this.selectedCategory = NotificationCategory.all,
    this.isLoading = false,
  });

  final List<CustomerNotificationDto> notifications;
  final NotificationCategory selectedCategory;
  final bool isLoading;

  /// Count of unread notifications.
  int get unreadCount => notifications.where((n) => !n.isRead).length;

  /// Filtered notifications list according to selected category tab.
  List<CustomerNotificationDto> get filteredNotifications {
    if (selectedCategory == NotificationCategory.all) {
      return notifications;
    }
    return notifications.where((n) => n.category == selectedCategory).toList();
  }

  NotificationsState copyWith({
    List<CustomerNotificationDto>? notifications,
    NotificationCategory? selectedCategory,
    bool? isLoading,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [notifications, selectedCategory, isLoading];
}

