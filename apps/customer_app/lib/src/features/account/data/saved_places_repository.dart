import 'package:api_client/api_client.dart';
import 'package:app_models/app_models.dart';

class SavedPlacesRepository {
  SavedPlacesRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<SavedPlaceDto>> getPlaces({String? userId}) async {
    try {
      final res = await _apiClient.getSavedPlaces(userId: userId);
      if (res.isSuccess && res.data != null) {
        return res.data!;
      }
    } catch (_) {}

    return const [];
  }

  Future<SavedPlaceDto> addPlace({
    String? userId,
    required String label,
    required String address,
    required SavedPlaceType type,
    required double latitude,
    required double longitude,
    String? additionalInstructions,
  }) async {
    try {
      final res = await _apiClient.addSavedPlace(
        userId: userId,
        label: label,
        address: address,
        type: type,
        latitude: latitude,
        longitude: longitude,
        additionalInstructions: additionalInstructions,
      );
      if (res.isSuccess && res.data != null) {
        return res.data!;
      }
    } catch (_) {}

    return SavedPlaceDto(
      id: 'plc_${DateTime.now().millisecondsSinceEpoch}',
      label: label,
      address: address,
      type: type,
      latitude: latitude,
      longitude: longitude,
      additionalInstructions: additionalInstructions,
      userId: userId,
    );
  }

  Future<SavedPlaceDto?> updatePlace({
    required String placeId,
    String? userId,
    String? label,
    String? address,
    SavedPlaceType? type,
    double? latitude,
    double? longitude,
    String? additionalInstructions,
  }) async {
    try {
      final res = await _apiClient.updateSavedPlace(
        placeId: placeId,
        userId: userId,
        label: label,
        address: address,
        type: type,
        latitude: latitude,
        longitude: longitude,
        additionalInstructions: additionalInstructions,
      );
      if (res.isSuccess && res.data != null) {
        return res.data;
      }
    } catch (_) {}
    return null;
  }

  Future<String?> deletePlace({
    required String placeId,
    String? userId,
    bool force = false,
  }) async {
    try {
      final res = await _apiClient.deleteSavedPlace(
        placeId: placeId,
        userId: userId,
        force: force,
      );
      if (!res.isSuccess) {
        return res.error?.message ?? 'Failed to delete place.';
      }
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}

