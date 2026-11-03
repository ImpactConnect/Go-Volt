import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/supabase_admin_client.dart';
import 'admin_role.dart';

class AdminUserState {
  const AdminUserState({
    this.userId = '',
    this.fullName = 'Operations Admin',
    this.email = 'admin@govolts.ng',
    this.role = StaffRole.superAdmin,
    this.selectedServiceArea = 'Lekki / Victoria Island',
    this.isAuthenticated = true,
  });

  final String userId;
  final String fullName;
  final String email;
  final StaffRole role;
  final String selectedServiceArea;
  final bool isAuthenticated;

  String get userName => fullName;

  AdminUserState copyWith({
    String? userId,
    String? fullName,
    String? email,
    StaffRole? role,
    String? selectedServiceArea,
    bool? isAuthenticated,
  }) {
    return AdminUserState(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      selectedServiceArea: selectedServiceArea ?? this.selectedServiceArea,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
    );
  }
}

final adminAuthNotifierProvider =
    StateNotifierProvider<AdminAuthNotifier, AdminUserState>((ref) {
  return AdminAuthNotifier();
});

class AdminAuthNotifier extends StateNotifier<AdminUserState> {
  AdminAuthNotifier() : super(const AdminUserState()) {
    _syncLiveUser();
  }

  void _syncLiveUser() {
    final client = tryGetSupabaseClient();
    final user = client?.auth.currentUser;
    if (user != null) {
      final meta = user.userMetadata;
      state = state.copyWith(
        userId: user.id,
        email: user.email ?? '',
        fullName: meta?['full_name']?.toString() ??
            meta?['name']?.toString() ??
            user.email?.split('@').first ??
            'Operations Admin',
      );
    }
  }

  void setRole(StaffRole newRole) {
    state = state.copyWith(role: newRole);
  }

  void setServiceArea(String area) {
    state = state.copyWith(selectedServiceArea: area);
  }

  void signOut() {
    state = state.copyWith(isAuthenticated: false);
  }

  void signIn({required String email, required StaffRole role}) {
    state = state.copyWith(
      isAuthenticated: true,
      email: email,
      role: role,
    );
  }
}
