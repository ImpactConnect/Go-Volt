import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'merchant_role.dart';

class MerchantUserState extends Equatable {
  const MerchantUserState({
    this.isAuthenticated = true,
    this.userId = 'usr_merchant_001',
    this.fullName = 'Babatunde Alade',
    this.email = 'babatunde@mamacass.ng',
    this.role = MerchantRole.storeOwner,
    this.businessId = 'merch_mamacass_01',
    this.businessName = 'Mama Cass Quick Express Foods Ltd',
    this.rcNumber = 'RC-1849204',
    this.isKycVerified = true,
    this.accessibleBranchIds = const ['br_lekki_01', 'br_vi_02', 'br_ikeja_03'],
    this.activeBranchId = 'br_lekki_01',
    this.activeBranchName = 'Lekki Phase 1 Flagship',
    this.walletBalanceKobo = 24500000, // ₦245,000.00
  });

  final bool isAuthenticated;
  final String userId;
  final String fullName;
  final String email;
  final MerchantRole role;
  final String businessId;
  final String businessName;
  final String rcNumber;
  final bool isKycVerified;
  final List<String> accessibleBranchIds;
  final String activeBranchId;
  final String activeBranchName;
  final int walletBalanceKobo;

  String get formattedWalletBalance {
    final naira = walletBalanceKobo / 100.0;
    return '₦${naira.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  MerchantUserState copyWith({
    bool? isAuthenticated,
    String? userId,
    String? fullName,
    String? email,
    MerchantRole? role,
    String? businessId,
    String? businessName,
    String? rcNumber,
    bool? isKycVerified,
    List<String>? accessibleBranchIds,
    String? activeBranchId,
    String? activeBranchName,
    int? walletBalanceKobo,
  }) {
    return MerchantUserState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      businessId: businessId ?? this.businessId,
      businessName: businessName ?? this.businessName,
      rcNumber: rcNumber ?? this.rcNumber,
      isKycVerified: isKycVerified ?? this.isKycVerified,
      accessibleBranchIds: accessibleBranchIds ?? this.accessibleBranchIds,
      activeBranchId: activeBranchId ?? this.activeBranchId,
      activeBranchName: activeBranchName ?? this.activeBranchName,
      walletBalanceKobo: walletBalanceKobo ?? this.walletBalanceKobo,
    );
  }

  @override
  List<Object?> get props => [
        isAuthenticated,
        userId,
        fullName,
        email,
        role,
        businessId,
        businessName,
        rcNumber,
        isKycVerified,
        accessibleBranchIds,
        activeBranchId,
        activeBranchName,
        walletBalanceKobo,
      ];
}

class MerchantAuthNotifier extends StateNotifier<MerchantUserState> {
  MerchantAuthNotifier() : super(const MerchantUserState());

  void signIn({
    required String email,
    required MerchantRole role,
    String? branchId,
    String? branchName,
  }) {
    state = state.copyWith(
      isAuthenticated: true,
      email: email,
      role: role,
      activeBranchId: branchId ?? state.activeBranchId,
      activeBranchName: branchName ?? state.activeBranchName,
    );
  }

  void switchBranch({
    required String branchId,
    required String branchName,
  }) {
    if (!state.accessibleBranchIds.contains(branchId) && !state.role.canSwitchAllBranches) {
      return;
    }
    state = state.copyWith(
      activeBranchId: branchId,
      activeBranchName: branchName,
    );
  }

  void setRole(MerchantRole role) {
    state = state.copyWith(role: role);
  }

  void switchRole(MerchantRole role) => setRole(role);

  void updateWalletBalance(int newBalanceKobo) {
    state = state.copyWith(walletBalanceKobo: newBalanceKobo);
  }

  void topUpWalletBalance(int deltaKobo) {
    updateWalletBalance(state.walletBalanceKobo + deltaKobo);
  }

  void signOut() {
    state = state.copyWith(isAuthenticated: false);
  }
}

final merchantAuthNotifierProvider =
    StateNotifierProvider<MerchantAuthNotifier, MerchantUserState>((ref) {
  return MerchantAuthNotifier();
});
