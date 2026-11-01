import 'package:api_client/api_client.dart';
import 'package:app_models/app_models.dart';

class SettingsRepository {
  SettingsRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<NotificationPreferencesDto> getNotificationPreferences({String? userId}) async {
    try {
      final res = await _apiClient.getNotificationPreferences(userId: userId);
      if (res.isSuccess && res.data != null) {
        return res.data!;
      }
    } catch (_) {}

    return const NotificationPreferencesDto();
  }

  Future<NotificationPreferencesDto> updateNotificationPreferences({
    String? userId,
    required NotificationPreferencesDto preferences,
  }) async {
    try {
      final res = await _apiClient.updateNotificationPreferences(
        userId: userId,
        preferences: preferences,
      );
      if (res.isSuccess && res.data != null) {
        return res.data!;
      }
    } catch (_) {}

    return preferences;
  }
}

