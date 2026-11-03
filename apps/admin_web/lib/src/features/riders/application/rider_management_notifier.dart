import 'package:app_models/app_models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/supabase_admin_client.dart';
import '../domain/rider_management_state.dart';

final riderManagementNotifierProvider =
    StateNotifierProvider<RiderManagementNotifier, RiderManagementState>((ref) {
  return RiderManagementNotifier();
});

class RiderManagementNotifier extends StateNotifier<RiderManagementState> {
  RiderManagementNotifier() : super(const RiderManagementState()) {
    fetchRealRiders();
  }

  Future<void> fetchRealRiders() async {
    final client = tryGetSupabaseClient();
    if (client == null) return;

    try {
      state = state.copyWith(isLoading: true);
      final res = await client.from('rider_profiles').select();
      final list = res as List<dynamic>;

      final mapped = list.map((r) {
        final statusRaw = r['compliance_status']?.toString().toLowerCase() ??
            r['status']?.toString().toLowerCase() ??
            '';
        RiderComplianceStatus status = RiderComplianceStatus.pendingReview;
        if (statusRaw == 'approved' || statusRaw == 'active') {
          status = RiderComplianceStatus.approved;
        } else if (statusRaw == 'suspended') {
          status = RiderComplianceStatus.suspended;
        }

        return AdminRiderApplicant(
          id: r['id']?.toString() ?? '',
          fullName: r['full_name']?.toString() ?? 'Rider Applicant',
          phone: r['phone']?.toString() ?? '',
          email: r['email']?.toString() ?? '',
          vehiclePlate: r['vehicle_plate']?.toString() ?? 'N/A',
          vehicleClass: r['vehicle_model']?.toString() ?? 'Roam Air EV Bike',
          batteryCapacity: '3.2 kWh LFP',
          batteryHealthPercent:
              (r['battery_health_percent'] as num?)?.toInt() ?? 95,
          status: status,
          certifiedTiers: const [
            ServiceTierEligibility.parcelDelivery,
            ServiceTierEligibility.passengerRide,
          ],
          documents: const [],
          ratingAverage: (r['rating'] as num?)?.toDouble() ?? 5.0,
          completedTrips: (r['completed_trips'] as num?)?.toInt() ?? 0,
          appliedDate: r['created_at']?.toString() ?? '',
        );
      }).toList();

      state = state.copyWith(
        isLoading: false,
        riders: mapped,
      );
    } catch (e) {
      debugPrint('[RiderManagementNotifier] Error fetching riders: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  @visibleForTesting
  void updateStateForTesting(RiderManagementState newState) {
    state = newState;
  }


  void setStatusFilter(String filter) {
    state = state.copyWith(selectedStatusFilter: filter);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void selectRider(AdminRiderApplicant? rider) {
    state = state.copyWith(selectedRider: rider);
  }

  /// Approve rider application, certify service tiers, and record audit note.
  Future<bool> approveRider({
    required String riderId,
    required List<ServiceTierEligibility> certifiedTiers,
    required String auditNote,
  }) async {
    state = state.copyWith(isLoading: true);
    await Future<void>.delayed(const Duration(milliseconds: 150));

    final updated = state.riders.map((r) {
      if (r.id == riderId) {
        final verifiedDocs = r.documents.map((d) {
          return RiderDocumentDto(
            id: d.id,
            type: d.type,
            documentNumber: d.documentNumber,
            fileUrl: d.fileUrl,
            expiryDate: d.expiryDate,
            status: DocumentVerificationStatus.approved,
          );
        }).toList();

        return r.copyWith(
          status: RiderComplianceStatus.approved,
          certifiedTiers: certifiedTiers,
          documents: verifiedDocs,
        );
      }
      return r;
    }).toList();

    state = state.copyWith(
      isLoading: false,
      riders: updated,
      actionMessage: 'Rider $riderId approved & certified for ${certifiedTiers.length} service tiers (Audit: $auditNote)',
    );
    return true;
  }

  /// Suspend a rider with a mandatory compliance reason.
  Future<bool> suspendRider({
    required String riderId,
    required String mandatoryReason,
  }) async {
    if (mandatoryReason.trim().isEmpty) return false;

    state = state.copyWith(isLoading: true);
    await Future<void>.delayed(const Duration(milliseconds: 150));

    final updated = state.riders.map((r) {
      if (r.id == riderId) {
        return r.copyWith(status: RiderComplianceStatus.suspended);
      }
      return r;
    }).toList();

    state = state.copyWith(
      isLoading: false,
      riders: updated,
      actionMessage: 'Rider $riderId suspended. Reason: $mandatoryReason',
    );
    return true;
  }

  /// Toggle service tier certification for a rider.
  void toggleServiceTierCertification({
    required String riderId,
    required ServiceTierEligibility tier,
  }) {
    final updated = state.riders.map((r) {
      if (r.id == riderId) {
        final current = List<ServiceTierEligibility>.from(r.certifiedTiers);
        if (current.contains(tier)) {
          current.remove(tier);
        } else {
          current.add(tier);
        }
        return r.copyWith(certifiedTiers: current);
      }
      return r;
    }).toList();

    state = state.copyWith(riders: updated);
  }
}
