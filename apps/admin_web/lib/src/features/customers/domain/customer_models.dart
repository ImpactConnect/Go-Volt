import 'package:app_models/app_models.dart';
import 'package:equatable/equatable.dart';

/// Customer verification profile model for administrative review (§A4).
class CustomerVerificationItem extends Equatable {
  const CustomerVerificationItem({
    required this.id,
    required this.fullName,
    required this.phone,
    required this.email,
    required this.registeredAt,
    required this.status,
    this.tier = 'Tier 1 (Basic)',
    this.rejectionReason,
    this.submittedAt,
    this.verifiedAt,
    this.requiredDocuments = const ['Government Issued ID', 'Proof of Residential Address'],
    this.documentUrls = const {},
    this.ninNumber,
    this.residentialAddress,
    this.activeCommutePlansCount = 0,
    this.walletBalanceKobo = 0,
  });

  final String id;
  final String fullName;
  final String phone;
  final String email;
  final DateTime registeredAt;
  final VerificationStatus status;
  final String tier;
  final String? rejectionReason;
  final DateTime? submittedAt;
  final DateTime? verifiedAt;
  final List<String> requiredDocuments;
  final Map<String, String> documentUrls;
  final String? ninNumber;
  final String? residentialAddress;
  final int activeCommutePlansCount;
  final int walletBalanceKobo;

  bool get isVerified => status == VerificationStatus.verified;
  bool get isPending => status == VerificationStatus.pending;
  bool get needsAction =>
      status == VerificationStatus.actionRequired || status == VerificationStatus.rejected;

  CustomerVerificationItem copyWith({
    String? id,
    String? fullName,
    String? phone,
    String? email,
    DateTime? registeredAt,
    VerificationStatus? status,
    String? tier,
    String? rejectionReason,
    DateTime? submittedAt,
    DateTime? verifiedAt,
    List<String>? requiredDocuments,
    Map<String, String>? documentUrls,
    String? ninNumber,
    String? residentialAddress,
    int? activeCommutePlansCount,
    int? walletBalanceKobo,
  }) {
    return CustomerVerificationItem(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      registeredAt: registeredAt ?? this.registeredAt,
      status: status ?? this.status,
      tier: tier ?? this.tier,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      submittedAt: submittedAt ?? this.submittedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      requiredDocuments: requiredDocuments ?? this.requiredDocuments,
      documentUrls: documentUrls ?? this.documentUrls,
      ninNumber: ninNumber ?? this.ninNumber,
      residentialAddress: residentialAddress ?? this.residentialAddress,
      activeCommutePlansCount: activeCommutePlansCount ?? this.activeCommutePlansCount,
      walletBalanceKobo: walletBalanceKobo ?? this.walletBalanceKobo,
    );
  }

  @override
  List<Object?> get props => [
        id,
        fullName,
        phone,
        email,
        registeredAt,
        status,
        tier,
        rejectionReason,
        submittedAt,
        verifiedAt,
        requiredDocuments,
        documentUrls,
        ninNumber,
        residentialAddress,
        activeCommutePlansCount,
        walletBalanceKobo,
      ];
}

/// State for customer verification queue.
class CustomerVerificationState extends Equatable {
  const CustomerVerificationState({
    this.customers = const [],
    this.selectedStatus,
    this.searchQuery = '',
    this.isLoading = false,
    this.actionMessage,
  });

  final List<CustomerVerificationItem> customers;
  final VerificationStatus? selectedStatus;
  final String searchQuery;
  final bool isLoading;
  final String? actionMessage;

  int get totalSubmitted => customers.length;
  int get pendingCount => customers.where((c) => c.status == VerificationStatus.pending).length;
  int get verifiedCount => customers.where((c) => c.status == VerificationStatus.verified).length;
  int get actionRequiredCount =>
      customers.where((c) => c.status == VerificationStatus.actionRequired).length;
  int get rejectedCount => customers.where((c) => c.status == VerificationStatus.rejected).length;

  List<CustomerVerificationItem> get filteredCustomers {
    return customers.where((c) {
      if (selectedStatus != null && c.status != selectedStatus) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        return c.fullName.toLowerCase().contains(q) ||
            c.phone.toLowerCase().contains(q) ||
            c.email.toLowerCase().contains(q) ||
            (c.ninNumber?.toLowerCase().contains(q) ?? false);
      }
      return true;
    }).toList();
  }

  CustomerVerificationState copyWith({
    List<CustomerVerificationItem>? customers,
    VerificationStatus? selectedStatus,
    bool clearStatusFilter = false,
    String? searchQuery,
    bool? isLoading,
    String? actionMessage,
  }) {
    return CustomerVerificationState(
      customers: customers ?? this.customers,
      selectedStatus: clearStatusFilter ? null : (selectedStatus ?? this.selectedStatus),
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
      actionMessage: actionMessage,
    );
  }

  @override
  List<Object?> get props => [customers, selectedStatus, searchQuery, isLoading, actionMessage];
}

