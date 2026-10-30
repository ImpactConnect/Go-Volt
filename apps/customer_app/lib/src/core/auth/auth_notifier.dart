import 'package:app_config/app_config.dart';
import 'package:app_models/app_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

import 'auth_state.dart';
import 'supabase_auth_service.dart';

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(supabaseAuthServiceProvider);
  return AuthNotifier(authService: authService);
});

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier({SupabaseAuthService? authService})
      : _authService = authService ?? SupabaseAuthService(),
        super(const AuthState());

  final SupabaseAuthService _authService;

  /// Checks active Supabase session at app startup.
  Future<void> checkSession() async {
    state = state.copyWith(status: AuthStatus.authenticating);

    if (_authService.isInitialized && _authService.currentUser != null) {
      final user = _authService.currentUser!;
      final token = _authService.currentAccessToken;

      final phone = user.phone ??
          (user.userMetadata?['phone_number'] as String?) ??
          '';

      final profile = ProfileDto(
        id: user.id,
        fullName: (user.userMetadata?['full_name'] as String?) ??
            (user.userMetadata?['name'] as String?) ??
            'Go-Volts Customer',
        phoneNumber: phone,
        email: user.email,
        avatarUrl: user.userMetadata?['avatar_url'] as String?,
        roles: const [UserRole.customer],
        createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
      );

      // If user signed in with Google but hasn't entered a phone number yet
      if (phone.isEmpty) {
        state = state.copyWith(
          status: AuthStatus.profileIncomplete,
          profile: profile,
          pendingEmail: user.email,
          token: token,
        );
        return;
      }

      state = state.copyWith(
        status: AuthStatus.authenticated,
        profile: profile,
        token: token,
      );
      return;
    }

    state = state.copyWith(status: AuthStatus.unauthenticated);
  }

  /// Registers user and dispatches a 6-digit verification code to their Email.
  Future<bool> register({
    required String fullName,
    required String email,
    String? phoneNumber,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.authenticating, errorMessage: null);

    final cleanEmail = email.trim().toLowerCase();
    final formattedPhone = phoneNumber != null && phoneNumber.trim().isNotEmpty
        ? SupabaseAuthService.formatPhoneNumber(phoneNumber.trim())
        : null;

    try {
      if (_authService.isInitialized) {
        await _authService.sendEmailOtp(cleanEmail);
      } else {
        throw const AuthException(
          'Authentication service is not connected. Please verify your connection or try again later.',
        );
      }

      state = state.copyWith(
        status: AuthStatus.otpSent,
        pendingEmail: cleanEmail,
        pendingPhoneNumber: formattedPhone,
        pendingPassword: password,
        profile: ProfileDto(
          id: 'temp_reg',
          fullName: fullName,
          phoneNumber: formattedPhone ?? '',
          email: cleanEmail,
          roles: const [UserRole.customer],
          createdAt: DateTime.now(),
        ),
      );
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage:
            'Failed to dispatch email verification code: ${e.toString().replaceAll("Exception: ", "")}',
      );
      return false;
    }
  }

  /// Verifies the 6-digit OTP code sent to Email.
  Future<bool> verifyOtp(String code) async {
    state = state.copyWith(status: AuthStatus.authenticating, errorMessage: null);

    final email = state.pendingEmail;
    if (email == null) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Missing registration email. Please register again.',
      );
      return false;
    }

    try {
      if (_authService.isInitialized) {
        final response = await _authService.verifyEmailOtp(
          email: email,
          token: code,
        );

        final user = response.user;
        final session = response.session;

        if (user != null) {
          final phone = user.phone ??
              (user.userMetadata?['phone_number'] as String?) ??
              state.pendingPhoneNumber ??
              '';
          final name = state.profile?.fullName ??
              (user.userMetadata?['full_name'] as String?) ??
              'Go-Volts Customer';

          if (state.pendingPassword != null && state.pendingPassword!.isNotEmpty) {
            try {
              await _authService.updateUserCredentials(
                password: state.pendingPassword,
                fullName: name,
                phoneNumber: phone.isNotEmpty ? phone : null,
              );
            } catch (_) {}
          }

          final profile = ProfileDto(
            id: user.id,
            fullName: name,
            phoneNumber: phone,
            email: user.email ?? email,
            roles: const [UserRole.customer],
            createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
          );

          if (phone.isEmpty) {
            state = state.copyWith(
              status: AuthStatus.profileIncomplete,
              profile: profile,
              token: session?.accessToken ?? '',
            );
            return true;
          }

          state = state.copyWith(
            status: AuthStatus.authenticated,
            profile: profile,
            token: session?.accessToken ?? '',
          );
          return true;
        } else {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: 'Invalid OTP code. Please check your email and try again.',
          );
          return false;
        }
      } else {
        // Fallback for offline testing
        if (code == '123456' || code.length == 6) {
          final phone = state.pendingPhoneNumber ?? '';
          final profile = ProfileDto(
            id: 'usr_test_${DateTime.now().millisecondsSinceEpoch}',
            fullName: state.profile?.fullName ?? 'Go-Volts Member',
            phoneNumber: phone,
            email: email,
            roles: const [UserRole.customer],
            createdAt: DateTime.now(),
          );

          if (phone.isEmpty) {
            state = state.copyWith(
              status: AuthStatus.profileIncomplete,
              profile: profile,
              token: 'test-jwt-token',
            );
            return true;
          }

          state = state.copyWith(
            status: AuthStatus.authenticated,
            profile: profile,
            token: 'test-jwt-token',
          );
          return true;
        } else {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: 'Invalid 6-digit verification code.',
          );
          return false;
        }
      }
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Verification failed: ${e.toString().replaceAll("Exception: ", "")}',
      );
      return false;
    }
  }

  /// Initiates Google OAuth Sign-In & registration.
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.authenticating, errorMessage: null);

    try {
      if (_authService.isInitialized) {
        final success = await _authService.signInWithGoogle(
          serverClientId: AppConfig.current.googleWebClientId,
        );
        if (!success) {
          state = state.copyWith(status: AuthStatus.unauthenticated);
          return false;
        }

        final user = _authService.currentUser;
        if (user != null) {
          final phone = (user.userMetadata?['phone_number'] as String?) ?? '';
          final profile = ProfileDto(
            id: user.id,
            fullName: (user.userMetadata?['full_name'] as String?) ??
                (user.userMetadata?['name'] as String?) ??
                'Google User',
            phoneNumber: phone,
            email: user.email,
            avatarUrl: user.userMetadata?['avatar_url'] as String?,
            roles: const [UserRole.customer],
            createdAt: DateTime.now(),
          );

          if (phone.isEmpty) {
            state = state.copyWith(
              status: AuthStatus.profileIncomplete,
              profile: profile,
              pendingEmail: user.email,
              token: _authService.currentAccessToken,
            );
            return true;
          }

          state = state.copyWith(
            status: AuthStatus.authenticated,
            profile: profile,
            token: _authService.currentAccessToken,
          );
          return true;
        }
        return true;
      } else {
        throw const AuthException(
          'Authentication service is not connected. Please register with your email address below.',
        );
      }
    } on AuthException catch (e) {
      var msg = e.message;
      if (msg.toLowerCase().contains('unsupported provider') ||
          msg.toLowerCase().contains('not enabled')) {
        msg =
            'Google Sign-In is not yet enabled on this Supabase project. Please register using your email and password below.';
      }
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: msg,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Google Sign-In failed: ${e.toString().replaceAll("Exception: ", "")}',
      );
      return false;
    }
  }

  /// Completes user profile after Google auth (adds required phone number).
  Future<bool> completeProfile({
    required String phoneNumber,
    String? fullName,
  }) async {
    state = state.copyWith(status: AuthStatus.authenticating, errorMessage: null);

    final formattedPhone = SupabaseAuthService.formatPhoneNumber(phoneNumber);
    final currentProfile = state.profile;

    if (currentProfile == null) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'No active profile found. Please authenticate again.',
      );
      return false;
    }

    try {
      if (_authService.isInitialized) {
        await _authService.updateUserMetadata(
          phoneNumber: formattedPhone,
          fullName: fullName ?? currentProfile.fullName,
        );
      }

      final updatedProfile = ProfileDto(
        id: currentProfile.id,
        fullName: fullName?.trim().isNotEmpty == true ? fullName!.trim() : currentProfile.fullName,
        phoneNumber: formattedPhone,
        email: currentProfile.email,
        avatarUrl: currentProfile.avatarUrl,
        roles: currentProfile.roles,
        createdAt: currentProfile.createdAt,
        updatedAt: DateTime.now(),
        carbonAvoidedKg: currentProfile.carbonAvoidedKg,
        ecoPointsBalance: currentProfile.ecoPointsBalance,
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        profile: updatedProfile,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Failed to update profile: ${e.toString().replaceAll("Exception: ", "")}',
      );
      return false;
    }
  }

  /// Resends Email OTP code with renewed countdown.
  Future<void> resendOtp() async {
    final email = state.pendingEmail;
    if (email != null && _authService.isInitialized) {
      try {
        await _authService.sendEmailOtp(email);
      } catch (e) {
        state = state.copyWith(
          errorMessage: 'Failed to resend code: ${e.toString().replaceAll("Exception: ", "")}',
        );
      }
    }
  }

  /// Authenticates existing user with email and password.
  Future<bool> login({
    required String identifier,
    required String password,
  }) async {
    state = state.copyWith(status: AuthStatus.authenticating, errorMessage: null);

    try {
      if (_authService.isInitialized) {
        final response = await _authService.signInWithPassword(
          identifier: identifier,
          password: password,
        );
        final user = response?.user;
        final session = response?.session;

        if (user != null) {
          final phone = (user.userMetadata?['phone_number'] as String?) ?? user.phone ?? '';
          final profile = ProfileDto(
            id: user.id,
            fullName: (user.userMetadata?['full_name'] as String?) ?? 'Go-Volts Customer',
            phoneNumber: phone,
            email: user.email,
            roles: const [UserRole.customer],
            createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
          );

          if (phone.isEmpty) {
            state = state.copyWith(
              status: AuthStatus.profileIncomplete,
              profile: profile,
              token: session?.accessToken ?? '',
            );
            return true;
          }

          state = state.copyWith(
            status: AuthStatus.authenticated,
            profile: profile,
            token: session?.accessToken ?? '',
          );
          return true;
        } else {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: 'Invalid credentials. Please verify and try again.',
          );
          return false;
        }
      } else {
        // Fallback login
        if (password.length >= 6) {
          final profile = ProfileDto(
            id: 'usr_mock_001',
            fullName: 'Folake Adeleke',
            phoneNumber: '+2348012345678',
            email: identifier.contains('@') ? identifier : 'folake@example.com',
            roles: const [UserRole.customer],
            createdAt: DateTime.now(),
          );

          state = state.copyWith(
            status: AuthStatus.authenticated,
            profile: profile,
            token: 'mock-jwt-token-xyz',
          );
          return true;
        } else {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage: 'Invalid credentials. Please verify and try again.',
          );
          return false;
        }
      }
    } on AuthException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Login failed: ${e.toString().replaceAll("Exception: ", "")}',
      );
      return false;
    }
  }

  /// Signs out user and clears local session.
  Future<void> signOut() async {
    if (_authService.isInitialized) {
      await _authService.signOut();
    }
    state = const AuthState(status: AuthStatus.unauthenticated);
  }
}
