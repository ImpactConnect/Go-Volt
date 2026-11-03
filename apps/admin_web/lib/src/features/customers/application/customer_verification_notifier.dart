import 'package:app_models/app_models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/supabase_admin_client.dart';
import '../domain/customer_models.dart';

final customerVerificationNotifierProvider =
    StateNotifierProvider<CustomerVerificationNotifier, CustomerVerificationState>((ref) {
  return CustomerVerificationNotifier();
});

class CustomerVerificationNotifier extends StateNotifier<CustomerVerificationState> {
  CustomerVerificationNotifier() : super(const CustomerVerificationState()) {
    fetchRealCustomers();
  }

  Future<void> fetchRealCustomers() async {
    final client = tryGetSupabaseClient();
    if (client == null) return;

    try {
      state = state.copyWith(isLoading: true);
      final res = await client.from('profiles').select();
      final list = res as List<dynamic>;

      final mapped = list.map((p) {
        final statusRaw = p['kyc_status']?.toString().toLowerCase() ?? '';
        VerificationStatus status = VerificationStatus.pending;
        if (statusRaw == 'verified' || statusRaw == 'approved') {
          status = VerificationStatus.verified;
        } else if (statusRaw == 'action_required' || statusRaw == 'rejected') {
          status = VerificationStatus.actionRequired;
        }

        final createdAt = p['created_at'] != null
            ? DateTime.tryParse(p['created_at'].toString())
            : null;

        return CustomerVerificationItem(
          id: p['id']?.toString() ?? '',
          fullName: p['full_name']?.toString() ?? 'Customer',
          phone: p['phone']?.toString() ?? '',
          email: p['email']?.toString() ?? '',
          registeredAt: createdAt ?? DateTime.now(),
          status: status,
          tier: p['tier']?.toString() ?? 'Tier 1 (Basic)',
          submittedAt: createdAt ?? DateTime.now(),
          ninNumber: p['nin']?.toString() ?? '',
          residentialAddress: p['residential_address']?.toString() ?? 'Lagos',
          activeCommutePlansCount: 0,
          walletBalanceKobo: 0,
          requiredDocuments: const ['National Identification Number (NIN)'],
          documentUrls: const {},
        );
      }).toList();

      state = state.copyWith(
        isLoading: false,
        customers: mapped,
      );
    } catch (e) {
      debugPrint('[CustomerVerificationNotifier] Error fetching customers: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  @visibleForTesting
  void updateStateForTesting(CustomerVerificationState newState) {
    state = newState;
  }


  /// Approve customer account verification and elevate verification status.
  Future<bool> approveVerification({
    required String customerId,
    required String reviewerName,
  }) async {
    state = state.copyWith(isLoading: true);
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final updated = state.customers.map((c) {
      if (c.id == customerId) {
        return c.copyWith(
          status: VerificationStatus.verified,
          verifiedAt: DateTime.now(),
          rejectionReason: null,
          tier: 'Tier 2 (Identity Verified)',
        );
      }
      return c;
    }).toList();

    state = state.copyWith(
      isLoading: false,
      customers: updated,
      actionMessage: 'Customer $customerId verification APPROVED by $reviewerName.',
    );
    return true;
  }

  /// Request customer action (e.g. re-upload blurred document).
  Future<bool> requestAction({
    required String customerId,
    required String reason,
    required String reviewerName,
  }) async {
    if (reason.trim().isEmpty) return false;

    state = state.copyWith(isLoading: true);
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final updated = state.customers.map((c) {
      if (c.id == customerId) {
        return c.copyWith(
          status: VerificationStatus.actionRequired,
          rejectionReason: reason.trim(),
        );
      }
      return c;
    }).toList();

    state = state.copyWith(
      isLoading: false,
      customers: updated,
      actionMessage: 'Action requested for customer $customerId: "$reason" ($reviewerName).',
    );
    return true;
  }

  /// Reject customer verification with authoritative reason.
  Future<bool> rejectVerification({
    required String customerId,
    required String reason,
    required String reviewerName,
  }) async {
    if (reason.trim().isEmpty) return false;

    state = state.copyWith(isLoading: true);
    await Future<void>.delayed(const Duration(milliseconds: 100));

    final updated = state.customers.map((c) {
      if (c.id == customerId) {
        return c.copyWith(
          status: VerificationStatus.rejected,
          rejectionReason: reason.trim(),
        );
      }
      return c;
    }).toList();

    state = state.copyWith(
      isLoading: false,
      customers: updated,
      actionMessage: 'Customer $customerId verification REJECTED: "$reason" ($reviewerName).',
    );
    return true;
  }

  void filterByStatus(VerificationStatus? status) {
    if (status == null) {
      state = state.copyWith(clearStatusFilter: true);
    } else {
      state = state.copyWith(selectedStatus: status);
    }
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void clearActionMessage() {
    state = state.copyWith(actionMessage: null);
  }
}

