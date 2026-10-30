import 'package:app_models/app_models.dart';
import 'package:customer_app/src/features/home/application/home_notifier.dart';
import 'package:customer_app/src/features/home/application/notifications_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('HomeNotifier Unit Tests', () {
    test('initial state has default location, areas, and campaigns', () {
      final notifier = HomeNotifier();
      final state = notifier.state;

      expect(state.currentLocation.name, equals('Victoria Island'));
      expect(state.currentLocation.isFullySupported, isTrue);
      expect(state.isServiceAvailable(ServiceCode.instantRide), isTrue);
      expect(state.isServiceAvailable(ServiceCode.instantDelivery), isTrue);
      expect(state.serviceAreas.length, greaterThanOrEqualTo(3));
      expect(state.savedPlaces.length, equals(2));
      expect(state.campaigns.isNotEmpty, isTrue);
      expect(state.hasActiveBooking, isFalse);
    });

    test('selectLocation updates area and evaluates service availability', () {
      final notifier = HomeNotifier();

      // Select Ikoyi (which has limited services and no instant ride)
      final ikoyi = notifier.state.serviceAreas.firstWhere((a) => a.id == 'ikoyi');
      notifier.selectLocation(ikoyi);

      expect(notifier.state.currentLocation.name, equals('Ikoyi'));
      expect(notifier.state.currentLocation.isLimited, isTrue);
      // Instant ride is unavailable in Ikoyi
      expect(notifier.state.isServiceAvailable(ServiceCode.instantRide), isFalse);
      // Instant delivery is available
      expect(notifier.state.isServiceAvailable(ServiceCode.instantDelivery), isTrue);
    });

    test('setActiveBooking sets and clears active booking', () {
      final notifier = HomeNotifier();

      expect(notifier.state.hasActiveBooking, isFalse);

      notifier.setSampleActiveBooking();
      expect(notifier.state.hasActiveBooking, isTrue);
      expect(notifier.state.activeBooking?.referenceCode, equals('GV-824755'));
      expect(notifier.state.activeBooking?.riderName, equals('Babajide S.'));
      expect(notifier.state.activeBooking?.etaMinutes, equals(3));

      notifier.clearActiveBooking();
      expect(notifier.state.hasActiveBooking, isFalse);
    });

    test('addSavedPlace dynamically appends address', () {
      final notifier = HomeNotifier();
      final initialCount = notifier.state.savedPlaces.length;

      const newPlace = SavedPlaceDto(
        id: 'place_gym',
        label: 'Gym',
        address: 'Admiralty Way, Lekki',
        type: SavedPlaceType.custom,
        latitude: 6.45,
        longitude: 3.48,
      );

      notifier.addSavedPlace(newPlace);
      expect(notifier.state.savedPlaces.length, equals(initialCount + 1));
      expect(notifier.state.savedPlaces.last.label, equals('Gym'));
    });
  });

  group('NotificationsNotifier Unit Tests', () {
    test('initial state has notifications and accurate unread count', () {
      final notifier = NotificationsNotifier();
      final state = notifier.state;

      expect(state.notifications.isNotEmpty, isTrue);
      expect(state.unreadCount, equals(3));
      expect(state.filteredNotifications.length, equals(state.notifications.length));
    });

    test('selectCategory filters notifications properly', () {
      final notifier = NotificationsNotifier();

      notifier.selectCategory(NotificationCategory.bookings);
      expect(notifier.state.selectedCategory, equals(NotificationCategory.bookings));
      for (final n in notifier.state.filteredNotifications) {
        expect(n.category, equals(NotificationCategory.bookings));
      }

      notifier.selectCategory(NotificationCategory.promotions);
      expect(notifier.state.selectedCategory, equals(NotificationCategory.promotions));
      for (final n in notifier.state.filteredNotifications) {
        expect(n.category, equals(NotificationCategory.promotions));
      }
    });

    test('markAsRead updates item isRead and decrements unread count', () {
      final notifier = NotificationsNotifier();
      final initialUnread = notifier.state.unreadCount;

      notifier.markAsRead('notif_01');
      expect(notifier.state.unreadCount, equals(initialUnread - 1));
      final item = notifier.state.notifications.firstWhere((n) => n.id == 'notif_01');
      expect(item.isRead, isTrue);
    });

    test('markAllAsRead sets all items to read and resets unread count to 0', () {
      final notifier = NotificationsNotifier();
      expect(notifier.state.unreadCount, greaterThan(0));

      notifier.markAllAsRead();
      expect(notifier.state.unreadCount, equals(0));
      for (final n in notifier.state.notifications) {
        expect(n.isRead, isTrue);
      }
    });
  });
}

