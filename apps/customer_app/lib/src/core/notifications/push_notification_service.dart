import 'dart:io';
import 'package:api_client/api_client.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/api_providers.dart';

final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return PushNotificationService(apiClient: apiClient);
});

/// Service managing device FCM token registration, permissions, and push payloads.
class PushNotificationService {
  PushNotificationService({required ApiClient apiClient})
      : _apiClient = apiClient;

  final ApiClient _apiClient;
  String? _cachedFcmToken;

  String? get fcmToken => _cachedFcmToken;

  /// Initializes FCM listeners and registers token with Go-Volts backend.
  Future<void> initialize() async {
    // Check if Firebase is available
    if (Firebase.apps.isEmpty) {
      debugPrint('[PushNotificationService] Firebase not initialized; running in mock mode.');
      return;
    }

    try {
      final messaging = FirebaseMessaging.instance;

      // Request notification permissions
      final settings = await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        // Fetch FCM device registration token
        // ignore: deprecated_member_use
        final token = await messaging.getToken();
        if (token != null) {
          _cachedFcmToken = token;
          await _registerTokenWithBackend(token);
        }

        // Listen for token refresh events
        // ignore: deprecated_member_use
        messaging.onTokenRefresh.listen((newToken) async {
          _cachedFcmToken = newToken;
          await _registerTokenWithBackend(newToken);
        });

        // Listen for foreground push messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          debugPrint('[PushNotificationService] Received foreground message: ${message.notification?.title}');
        });
      }
    } catch (e, stack) {
      debugPrint('[PushNotificationService] Failed to initialize FCM: $e\n$stack');
    }
  }

  /// Sends device token to backend /api/v1/devices.
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
      debugPrint('[PushNotificationService] Device token registered successfully.');
    } catch (e) {
      debugPrint('[PushNotificationService] Failed to register token with backend: $e');
    }
  }

  /// Unregisters device token on sign out.
  Future<void> unregister() async {
    if (_cachedFcmToken != null) {
      try {
        await _apiClient.unregisterDevice(fcmToken: _cachedFcmToken!);
        _cachedFcmToken = null;
      } catch (e) {
        debugPrint('[PushNotificationService] Failed to unregister device token: $e');
      }
    }
  }
}
