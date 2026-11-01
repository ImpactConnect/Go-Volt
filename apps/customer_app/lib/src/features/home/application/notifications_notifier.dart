import 'package:app_models/app_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notifications_state.dart';

final notificationsNotifierProvider =
    StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier();
});

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  NotificationsNotifier({List<CustomerNotificationDto>? initialNotifications})
      : super(
          NotificationsState(
            notifications: initialNotifications ?? defaultNotifications,
            selectedCategory: NotificationCategory.all,
          ),
        );

  /// Clears notifications for a clean new user baseline.
  void clearForNewUser() {
    state = state.copyWith(notifications: const []);
  }

  static final List<CustomerNotificationDto> defaultNotifications = [
    CustomerNotificationDto(
      id: 'notif_01',
      title: 'Rider approaching',
      message: 'Your rider is 3 minutes away',
      category: NotificationCategory.bookings,
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      isRead: false,
      targetRoute: '/live-tracking',
    ),
    CustomerNotificationDto(
      id: 'notif_02',
      title: 'Delivery completed',
      message: 'Your parcel has been delivered',
      category: NotificationCategory.bookings,
      timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      isRead: false,
      targetRoute: '/trips',
    ),
    CustomerNotificationDto(
      id: 'notif_03',
      title: 'Special offer',
      message: 'Get 20% off your next ride',
      category: NotificationCategory.promotions,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
      isRead: false,
      targetRoute: '/ride-booking',
    ),
    CustomerNotificationDto(
      id: 'notif_04',
      title: 'Reward points earned',
      message: 'You earned 50 points',
      category: NotificationCategory.account,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      targetRoute: '/wallet-rewards',
    ),
    CustomerNotificationDto(
      id: 'notif_05',
      title: 'Account verified',
      message: 'Your email has been verified',
      category: NotificationCategory.account,
      timestamp: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      isRead: true,
      targetRoute: '/account',
    ),
  ];


  /// Sets the active notification filter category tab.
  void selectCategory(NotificationCategory category) {
    state = state.copyWith(selectedCategory: category);
  }

  /// Marks a specific notification as read.
  void markAsRead(String id) {
    final updated = state.notifications.map((n) {
      if (n.id == id) {
        return n.copyWith(isRead: true);
      }
      return n;
    }).toList();
    state = state.copyWith(notifications: updated);
  }

  /// Marks all notifications as read.
  void markAllAsRead() {
    final updated = state.notifications.map((n) => n.copyWith(isRead: true)).toList();
    state = state.copyWith(notifications: updated);
  }

  /// Adds a new notification dynamically.
  void addNotification(CustomerNotificationDto notification) {
    state = state.copyWith(
      notifications: [notification, ...state.notifications],
    );
  }
}

