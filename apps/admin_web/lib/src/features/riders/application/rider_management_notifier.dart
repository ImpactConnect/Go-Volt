import 'package:app_models/app_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/rider_management_state.dart';

final riderManagementNotifierProvider =
    StateNotifierProvider<RiderManagementNotifier, RiderManagementState>((ref) {
  return RiderManagementNotifier();
});

class RiderManagementNotifier extends StateNotifier<RiderManagementState> {
  RiderManagementNotifier() : super(const RiderManagementState()) {
    _loadInitialRiders();
  }

  void _loadInitialRiders() {
    state = state.copyWith(
      riders: [
        AdminRiderApplicant(
          id: 'RDR-APP-101',
          fullName: 'Babatunde Fashola',
          phone: '+2348021122334',
          email: 'tunde.fashola@govolts.ng',
          vehiclePlate: 'LA-999-IS',
          vehicleClass: 'Roam Air EV Bike',
          batteryCapacity: '3.2 kWh LFP',
          batteryHealthPercent: 96,
          status: RiderComplianceStatus.pendingReview,
          certifiedTiers: const [
            ServiceTierEligibility.parcelDelivery,
            ServiceTierEligibility.passengerRide,
          ],
          documents: [
            RiderDocumentDto(
              id: 'doc-1',
              type: DocumentType.nationalId,
              documentNumber: '10928374651',
              fileUrl: 'https://cdn.govolts.ng/docs/nin_fashola.jpg',
              expiryDate: DateTime.now().add(const Duration(days: 800)),
              status: DocumentVerificationStatus.approved,
            ),
            RiderDocumentDto(
              id: 'doc-2',
              type: DocumentType.driversLicense,
              documentNumber: 'DL-LAG-2024-991',
              fileUrl: 'https://cdn.govolts.ng/docs/dl_fashola.jpg',
              expiryDate: DateTime.now().add(const Duration(days: 360)),
              status: DocumentVerificationStatus.pending,
            ),
            RiderDocumentDto(
              id: 'doc-3',
              type: DocumentType.vehicleRegistration,
              documentNumber: 'VR-LAG-8821-EV',
              fileUrl: 'https://cdn.govolts.ng/docs/vr_fashola.jpg',
              expiryDate: DateTime.now().add(const Duration(days: 300)),
              status: DocumentVerificationStatus.pending,
            ),
          ],
          ratingAverage: 0.0,
          completedTrips: 0,
          appliedDate: '2026-10-24 11:30',
        ),
        AdminRiderApplicant(
          id: 'RDR-APP-102',
          fullName: 'Babajide Ogundipe',
          phone: '+2348031122334',
          email: 'babajide.ogundipe@govolts.ng',
          vehiclePlate: 'LAG-428-EV',
          vehicleClass: 'Roam Air EV Bike',
          batteryCapacity: '3.2 kWh LFP',
          batteryHealthPercent: 92,
          status: RiderComplianceStatus.approved,
          certifiedTiers: const [
            ServiceTierEligibility.parcelDelivery,
            ServiceTierEligibility.passengerRide,
            ServiceTierEligibility.schoolRunCommute,
          ],
          documents: [
            RiderDocumentDto(
              id: 'doc-4',
              type: DocumentType.nationalId,
              documentNumber: '10928374651',
              fileUrl: 'https://cdn.govolts.ng/docs/nin.jpg',
              expiryDate: DateTime.now().add(const Duration(days: 900)),
              status: DocumentVerificationStatus.approved,
            ),
            RiderDocumentDto(
              id: 'doc-5',
              type: DocumentType.driversLicense,
              documentNumber: 'DL-882-LAG',
              fileUrl: 'https://cdn.govolts.ng/docs/dl.jpg',
              expiryDate: DateTime.now().add(const Duration(days: 420)),
              status: DocumentVerificationStatus.approved,
            ),
          ],
          ratingAverage: 4.96,
          completedTrips: 184,
          appliedDate: '2026-09-12 09:15',
        ),
        AdminRiderApplicant(
          id: 'RDR-APP-103',
          fullName: 'Aminu Dantata',
          phone: '+2348051234567',
          email: 'aminu.dantata@govolts.ng',
          vehiclePlate: 'LAG-310-EV',
          vehicleClass: 'Roam Air EV Bike',
          batteryCapacity: '3.2 kWh LFP',
          batteryHealthPercent: 84,
          status: RiderComplianceStatus.suspended,
          certifiedTiers: const [
            ServiceTierEligibility.parcelDelivery,
          ],
          documents: [
            RiderDocumentDto(
              id: 'doc-6',
              type: DocumentType.driversLicense,
              documentNumber: 'DL-EXPIRED-777',
              fileUrl: 'https://cdn.govolts.ng/docs/dl_expired.jpg',
              expiryDate: DateTime.now().subtract(const Duration(days: 15)),
              status: DocumentVerificationStatus.rejected,
            ),
          ],
          ratingAverage: 4.2,
          completedTrips: 45,
          appliedDate: '2026-08-01 14:00',
        ),
      ],
    );
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
