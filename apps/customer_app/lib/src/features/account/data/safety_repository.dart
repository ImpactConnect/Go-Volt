import 'package:api_client/api_client.dart';
import 'package:app_models/app_models.dart';

class SafetyRepository {
  SafetyRepository({required ApiClient apiClient}) : _apiClient = apiClient;

  final ApiClient _apiClient;

  Future<List<TrustedContactDto>> getTrustedContacts({String? userId}) async {
    try {
      final res = await _apiClient.getTrustedContacts(userId: userId);
      if (res.isSuccess && res.data != null) {
        return res.data!;
      }
    } catch (_) {}

    return const [];
  }

  Future<TrustedContactDto> addTrustedContact({
    String? userId,
    required String name,
    required String phoneNumber,
    String relationship = 'Friend',
    bool autoShareRides = false,
  }) async {
    try {
      final res = await _apiClient.addTrustedContact(
        userId: userId,
        name: name,
        phoneNumber: phoneNumber,
        relationship: relationship,
        autoShareRides: autoShareRides,
      );
      if (res.isSuccess && res.data != null) {
        return res.data!;
      }
    } catch (_) {}

    return TrustedContactDto(
      id: 'tc_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      phoneNumber: phoneNumber,
      relationship: relationship,
      autoShareRides: autoShareRides,
      userId: userId,
    );
  }

  Future<bool> deleteTrustedContact({
    required String contactId,
    String? userId,
  }) async {
    try {
      final res = await _apiClient.deleteTrustedContact(
        contactId: contactId,
        userId: userId,
      );
      return res.isSuccess;
    } catch (_) {
      return true;
    }
  }

  Future<bool> reportIncident({
    String? userId,
    required String category,
    required String description,
    String? relatedBookingId,
  }) async {
    try {
      final res = await _apiClient.reportSafetyIncident(
        userId: userId,
        category: category,
        description: description,
        relatedBookingId: relatedBookingId,
      );
      return res.isSuccess;
    } catch (_) {
      return true;
    }
  }
}

