import 'package:app_config/app_config.dart';
import 'package:app_models/app_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show AuthException;

import 'auth_state.dart';
import 'supabase_auth_service.dart';

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((
  ref,
) {
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

      final phone =
          user.phone ?? (user.userMetadata?['phone_number'] as String?) ?? '';

      final profile = ProfileDto(
        id: user.id,
        fullName:
            (user.userMetadata?['full_name'] as String?) ??
            (user.userMetadata?['name'] as String?) ??
            'Customer',
        phoneNumber: phone,
        email: user.email,
        avatarUrl: user.userMetadata?['avatar_url'] as String?,
        roles: const [UserRole.customer],
        createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
      );

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
    String? firstName,
    String? lastName,
    String? fullName,
    required String email,
    required String password,
    String? phoneNumber,
  }) async {
    state = state.copyWith(
      status: AuthStatus.authenticating,
      errorMessage: null,
    );

    final cleanEmail = email.trim().toLowerCase();
    final formattedPhone = phoneNumber != null && phoneNumber.trim().isNotEmpty
        ? SupabaseAuthService.formatPhoneNumber(phoneNumber.trim())
        : null;

    final effectiveFirstName =
        firstName?.trim() ??
        (fullName != null && fullName.trim().isNotEmpty
            ? fullName.trim().split(RegExp(r'\s+')).first
            : 'Customer');
    final effectiveLastName =
        lastName?.trim() ??
        (fullName != null && fullName.trim().contains(' ')
            ? fullName.trim().split(RegExp(r'\s+')).sublist(1).join(' ')
            : '');
    final effectiveFullName = '$effectiveFirstName $effectiveLastName'.trim();

    try {
      if (_authService.isInitialized) {
        await _authService.signUpWithEmail(
          email: cleanEmail,
          password: password,
          firstName: effectiveFirstName,
          lastName: effectiveLastName,
        );
      }

      state = state.copyWith(
        status: AuthStatus.otpSent,
        pendingFirstName: effectiveFirstName,
        pendingLastName: effectiveLastName,
        pendingEmail: cleanEmail,
        pendingPhoneNumber: formattedPhone,
        pendingPassword: password,
        profile: ProfileDto(
          id: 'temp_reg',
          fullName: effectiveFullName,
          phoneNumber: formattedPhone ?? '',
          email: cleanEmail,
          roles: const [UserRole.customer],
          createdAt: DateTime.now(),
        ),
      );
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
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

  /// Verifies the 6-digit OTP code sent to Email for signup.
  Future<bool> verifyOtp(String code) async {
    state = state.copyWith(
      status: AuthStatus.authenticating,
      errorMessage: null,
    );

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
          final phone =
              user.phone ??
              (user.userMetadata?['phone_number'] as String?) ??
              state.pendingPhoneNumber ??
              '';
          final name =
              state.profile?.fullName ??
              (user.userMetadata?['full_name'] as String?) ??
              'Customer';

          final profile = ProfileDto(
            id: user.id,
            fullName: name,
            phoneNumber: phone,
            email: user.email ?? email,
            roles: const [UserRole.customer],
            createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
          );

          state = state.copyWith(
            status: AuthStatus.authenticated,
            profile: profile,
            token: session?.accessToken ?? '',
          );
          return true;
        } else {
          state = state.copyWith(
            status: AuthStatus.error,
            errorMessage:
                'Invalid OTP code. Please check your email and try again.',
          );
          return false;
        }
      } else {
        // Fallback for offline development/testing
        if (code == '123456' || code.length == 6) {
          final phone = state.pendingPhoneNumber ?? '';
          final profile = ProfileDto(
            id: 'usr_mock_${DateTime.now().millisecondsSinceEpoch}',
            fullName: state.profile?.fullName ?? 'Go-Volts Customer',
            phoneNumber: phone,
            email: email,
            roles: const [UserRole.customer],
            createdAt: DateTime.now(),
          );

          state = state.copyWith(
            status: AuthStatus.authenticated,
            profile: profile,
            token: 'mock-jwt-token',
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
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage:
            'Verification failed: ${e.toString().replaceAll("Exception: ", "")}',
      );
      return false;
    }
  }

  /// Sends a password reset code to the specified email.
  Future<bool> sendPasswordReset(String email) async {
    state = state.copyWith(
      status: AuthStatus.authenticating,
      errorMessage: null,
    );
    final cleanEmail = email.trim().toLowerCase();

    try {
      if (_authService.isInitialized) {
        await _authService.sendPasswordResetEmail(cleanEmail);
      }

      state = state.copyWith(
        status: AuthStatus.recoveryOtpSent,
        pendingEmail: cleanEmail,
      );
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage:
            'Failed to send reset code: ${e.toString().replaceAll("Exception: ", "")}',
      );
      return false;
    }
  }

  /// Verifies the 6-digit recovery OTP code sent to Email for password reset.
  Future<bool> verifyRecoveryOtp(String code) async {
    state = state.copyWith(
      status: AuthStatus.authenticating,
      errorMessage: null,
    );

    final email = state.pendingEmail;
    if (email == null) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Missing email address for recovery.',
      );
      return false;
    }

    try {
      if (_authService.isInitialized) {
        await _authService.verifyRecoveryOtp(email: email, token: code);
      }

      state = state.copyWith(status: AuthStatus.recoveryOtpVerified);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage:
            'Recovery verification failed: ${e.toString().replaceAll("Exception: ", "")}',
      );
      return false;
    }
  }

  /// Resets user password after OTP verification.
  Future<bool> resetPassword(String newPassword) async {
    state = state.copyWith(
      status: AuthStatus.authenticating,
      errorMessage: null,
    );

    try {
      if (_authService.isInitialized) {
        await _authService.updatePassword(newPassword);
      }

      state = state.copyWith(status: AuthStatus.passwordResetSuccess);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage:
            'Failed to update password: ${e.toString().replaceAll("Exception: ", "")}',
      );
      return false;
    }
  }

  /// Initiates Google OAuth Sign-In & registration.
  Future<bool> signInWithGoogle() async {
    state = state.copyWith(
      status: AuthStatus.authenticating,
      errorMessage: null,
    );

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
          final phone =
              user.phone ??
              (user.userMetadata?['phone_number'] as String?) ??
              '';
          final profile = ProfileDto(
            id: user.id,
            fullName:
                (user.userMetadata?['full_name'] as String?) ??
                (user.userMetadata?['name'] as String?) ??
                'Customer',
            phoneNumber: phone,
            email: user.email,
            avatarUrl: user.userMetadata?['avatar_url'] as String?,
            roles: const [UserRole.customer],
            createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
          );

          if (phone.isEmpty) {
            state = state.copyWith(
              status: AuthStatus.profileIncomplete,
              profile: profile,
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
      } else {
        // Fallback for offline testing
        final profile = ProfileDto(
          id: 'usr_google_mock',
          fullName: 'Alex Johnson',
          phoneNumber: '',
          email: 'alex@example.com',
          roles: const [UserRole.customer],
          createdAt: DateTime.now(),
        );

        state = state.copyWith(
          status: AuthStatus.profileIncomplete,
          profile: profile,
          token: 'mock-google-token',
        );
        return true;
      }

      state = state.copyWith(status: AuthStatus.unauthenticated);
      return false;
    } on AuthException catch (e) {
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage:
            'Google Sign-In failed: ${e.toString().replaceAll("Exception: ", "")}',
      );
      return false;
    }
  }

  /// Completes profile by adding or updating phone number and/or name.
  Future<bool> completeProfile({
    String? fullName,
    required String phoneNumber,
  }) async {
    state = state.copyWith(
      status: AuthStatus.authenticating,
      errorMessage: null,
    );

    try {
      final formattedPhone = SupabaseAuthService.formatPhoneNumber(phoneNumber);
      final effectiveName = fullName ?? state.profile?.fullName ?? 'Customer';

      if (_authService.isInitialized) {
        await _authService.updateUserMetadata(
          fullName: effectiveName,
          phoneNumber: formattedPhone,
        );
      }

      final currentProfile = state.profile;
      final updatedProfile = ProfileDto(
        id: currentProfile?.id ?? 'usr_current',
        fullName: effectiveName,
        phoneNumber: formattedPhone,
        email: currentProfile?.email,
        avatarUrl: currentProfile?.avatarUrl,
        roles: currentProfile?.roles ?? const [UserRole.customer],
        createdAt: currentProfile?.createdAt,
        updatedAt: DateTime.now(),
        carbonAvoidedKg: currentProfile?.carbonAvoidedKg ?? 28.4,
        ecoPointsBalance: currentProfile?.ecoPointsBalance ?? 320,
      );

      state = state.copyWith(
        status: AuthStatus.authenticated,
        profile: updatedProfile,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage:
            'Failed to update profile: ${e.toString().replaceAll("Exception: ", "")}',
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
          errorMessage:
              'Failed to resend code: ${e.toString().replaceAll("Exception: ", "")}',
        );
      }
    }
  }

  /// Authenticates existing user with email and password.
  Future<bool> login({
    required String identifier,
    required String password,
  }) async {
    state = state.copyWith(
      status: AuthStatus.authenticating,
      errorMessage: null,
    );

    try {
      if (_authService.isInitialized) {
        final response = await _authService.signInWithPassword(
          identifier: identifier,
          password: password,
        );
        final user = response?.user;
        final session = response?.session;

        if (user != null) {
          final phone =
              (user.userMetadata?['phone_number'] as String?) ??
              user.phone ??
              '';
          final profile = ProfileDto(
            id: user.id,
            fullName:
                (user.userMetadata?['full_name'] as String?) ?? 'Customer',
            phoneNumber: phone,
            email: user.email,
            roles: const [UserRole.customer],
            createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
          );

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
        // Fallback login for development
        if (password.length >= 6) {
          final profile = ProfileDto(
            id: 'usr_dev_${DateTime.now().millisecondsSinceEpoch}',
            fullName: identifier.contains('@')
                ? identifier.split('@').first
                : 'Customer',
            phoneNumber: '',
            email: identifier.contains('@')
                ? identifier
                : '$identifier@example.com',
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
      state = state.copyWith(status: AuthStatus.error, errorMessage: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage:
            'Login failed: ${e.toString().replaceAll("Exception: ", "")}',
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
