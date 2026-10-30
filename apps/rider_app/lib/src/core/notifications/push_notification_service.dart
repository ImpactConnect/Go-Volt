import 'dart:io';
import 'package:api_client/api_client.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/api_providers.dart';

final riderPushNotificationServiceProvider = Provider<RiderPushNotificationService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return RiderPushNotificationService(apiClient: apiClient);
});

/// Service managing rider device FCM token registration, permissions, and dispatch notifications.
class RiderPushNotificationService {
  RiderPushNotificationService({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;
  String? _cachedFcmToken;

  String? get fcmToken => _cachedFcmToken;

  /// Initializes FCM listeners and registers token with Go-Volts backend.
  Future<void> initialize() async {
    if (Firebase.apps.isEmpty) {
      debugPrint('[RiderPushNotificationService] Firebase not initialized; running in mock mode.');
      return;
    }

    try {
      final messaging = FirebaseMessaging.instance;

      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // ignore: deprecated_member_use
        final token = await messaging.getToken();
        if (token != null) {
          _cachedFcmToken = token;
          await _registerTokenWithBackend(token);
        }

        // ignore: deprecated_member_use
        messaging.onTokenRefresh.listen((newToken) async {
          _cachedFcmToken = newToken;
          await _registerTokenWithBackend(newToken);
        });

        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('[RiderPushNotificationService] Received dispatch alert: ${message.notification?.title}');
        });
      }
    } catch (e, stack) {
      debugPrint('[RiderPushNotificationService] Failed to initialize FCM: $e\n$stack');
    }
  }

  Future<void> _registerTokenWithBackend(String token) async {
    try {
      final platform = kIsWeb
          ? 'web'
          : Platform.isIOS
              ? 'ios'
              : 'android';

      await _apiClient.registerDevice(
        fcmToken: token,
        platform: platform,
        deviceModel: kIsWeb ? 'Web Browser' : Platform.operatingSystemVersion,
      );
      debugPrint('[RiderPushNotificationService] Rider device token registered successfully.');
    } catch (e) {
      debugPrint('[RiderPushNotificationService] Failed to register token with backend: $e');
    }
  }

  Future<void> unregister() async {
    if (_cachedFcmToken != null) {
      try {
        await _apiClient.unregisterDevice(fcmToken: _cachedFcmToken!);
        _cachedFcmToken = null;
      } catch (e) {
        debugPrint('[RiderPushNotificationService] Failed to unregister device token: $e');
      }
    }
  }
}
