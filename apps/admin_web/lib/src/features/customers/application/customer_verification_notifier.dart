import 'package:app_models/app_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/customer_models.dart';

final customerVerificationNotifierProvider =
    StateNotifierProvider<CustomerVerificationNotifier, CustomerVerificationState>((ref) {
  return CustomerVerificationNotifier();
});

class CustomerVerificationNotifier extends StateNotifier<CustomerVerificationState> {
  CustomerVerificationNotifier() : super(const CustomerVerificationState()) {
    _loadInitialSeedData();
  }

  void _loadInitialSeedData() {
    state = state.copyWith(
      customers: [
        CustomerVerificationItem(
          id: 'CUST-001',
          fullName: 'Alexander Cole',
          phone: '+234 801 234 5678',
          email: 'alexander.cole@example.com',
          registeredAt: DateTime.now().subtract(const Duration(days: 45)),
          status: VerificationStatus.pending,
          tier: 'Tier 2 (Identity Verified)',
          submittedAt: DateTime.now().subtract(const Duration(hours: 3)),
          ninNumber: '28471928374',
          residentialAddress: '14 Admiralty Way, Lekki Phase 1, Lagos',
          activeCommutePlansCount: 1,
          walletBalanceKobo: 2500000,
          requiredDocuments: const ['National Identification Number (NIN)', 'Utility Bill (Proof of Address)'],
          documentUrls: const {
            'National Identification Number (NIN)': 'https://storage.govolts.ng/docs/cust001_nin.pdf',
            'Utility Bill (Proof of Address)': 'https://storage.govolts.ng/docs/cust001_utility.pdf',
          },
        ),
        CustomerVerificationItem(
          id: 'CUST-002',
          fullName: 'Dr. Aisha Adeleke',
          phone: '+234 802 987 6543',
          email: 'aisha.adeleke@medlagos.ng',
          registeredAt: DateTime.now().subtract(const Duration(days: 120)),
          status: VerificationStatus.verified,
          tier: 'Tier 3 (Safeguarded Guardian)',
          submittedAt: DateTime.now().subtract(const Duration(days: 60)),
          verifiedAt: DateTime.now().subtract(const Duration(days: 59)),
          ninNumber: '91827364510',
          residentialAddress: 'Block 4, Parkview Estate, Ikoyi, Lagos',
          activeCommutePlansCount: 2,
          walletBalanceKobo: 8400000,
          requiredDocuments: const ['National Identification Number (NIN)', 'LASRRA Resident ID', 'School Guardian Consent'],
          documentUrls: const {
            'National Identification Number (NIN)': 'https://storage.govolts.ng/docs/cust002_nin.pdf',
            'LASRRA Resident ID': 'https://storage.govolts.ng/docs/cust002_lasrra.jpg',
            'School Guardian Consent': 'https://storage.govolts.ng/docs/cust002_guardian.pdf',
          },
        ),
        CustomerVerificationItem(
          id: 'CUST-003',
          fullName: 'Kehinde Balogun',
          phone: '+234 803 555 1212',
          email: 'k.balogun@techhub.ng',
          registeredAt: DateTime.now().subtract(const Duration(days: 18)),
          status: VerificationStatus.actionRequired,
          tier: 'Tier 1 (Basic)',
          submittedAt: DateTime.now().subtract(const Duration(days: 2)),
          rejectionReason: 'The uploaded NIN slip is blurred and illegible. Please re-upload a clear scanned copy.',
          ninNumber: '67482910394',
          residentialAddress: 'Ozumba Mbadiwe Ave, Victoria Island, Lagos',
          activeCommutePlansCount: 0,
          walletBalanceKobo: 150000,
          requiredDocuments: const ['National Identification Number (NIN)', 'Proof of Address'],
          documentUrls: const {
            'National Identification Number (NIN)': 'https://storage.govolts.ng/docs/cust003_nin_blurry.jpg',
          },
        ),
        CustomerVerificationItem(
          id: 'CUST-004',
          fullName: 'Folashade Alakija',
          phone: '+234 809 111 2233',
          email: 'fola.alakija@trade.com.ng',
          registeredAt: DateTime.now().subtract(const Duration(days: 5)),
          status: VerificationStatus.pending,
          tier: 'Tier 2 (Identity Verified)',
          submittedAt: DateTime.now().subtract(const Duration(hours: 1)),
          ninNumber: '39485720193',
          residentialAddress: '22 Isaac John St, GRA Ikeja, Lagos',
          activeCommutePlansCount: 1,
          walletBalanceKobo: 5200000,
          requiredDocuments: const ['National Identification Number (NIN)', 'LASRRA Resident Card'],
          documentUrls: const {
            'National Identification Number (NIN)': 'https://storage.govolts.ng/docs/cust004_nin.pdf',
            'LASRRA Resident Card': 'https://storage.govolts.ng/docs/cust004_lasrra.jpg',
          },
        ),
        CustomerVerificationItem(
          id: 'CUST-005',
          fullName: 'Tunde Bakare',
          phone: '+234 805 777 8899',
          email: 'tunde.bakare@freightexpress.ng',
          registeredAt: DateTime.now().subtract(const Duration(days: 10)),
          status: VerificationStatus.rejected,
          tier: 'Tier 1 (Basic)',
          submittedAt: DateTime.now().subtract(const Duration(days: 4)),
          rejectionReason: 'ID submitted does not match the customer legal name registered on account.',
          ninNumber: '11223344556',
          residentialAddress: 'Plot 8 Commercial Ave, Yaba, Lagos',
          activeCommutePlansCount: 0,
          walletBalanceKobo: 0,
          requiredDocuments: const ['Government Issued ID'],
          documentUrls: const {
            'Government Issued ID': 'https://storage.govolts.ng/docs/cust005_mismatch_id.jpg',
          },
        ),
      ],
    );
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

