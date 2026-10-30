import 'package:app_models/app_models.dart';
import 'package:equatable/equatable.dart';

enum AuthStatus {
  initial,
  unauthenticated,
  authenticating,
  otpSent,
  recoveryOtpSent,
  recoveryOtpVerified,
  passwordResetSuccess,
  profileIncomplete,
  authenticated,
  error,
}

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.profile,
    this.pendingFirstName,
    this.pendingLastName,
    this.pendingEmail,
    this.pendingPhoneNumber,
    this.pendingPassword,
    this.token,
    this.errorMessage,
  });

  final AuthStatus status;
  final ProfileDto? profile;
  final String? pendingFirstName;
  final String? pendingLastName;
  final String? pendingEmail;
  final String? pendingPhoneNumber;
  final String? pendingPassword;
  final String? token;
  final String? errorMessage;

  bool get isAuthenticated => status == AuthStatus.authenticated && profile != null;
  bool get isProfileIncomplete => status == AuthStatus.profileIncomplete;
  bool get isLoading => status == AuthStatus.authenticating;

  AuthState copyWith({
    AuthStatus? status,
    ProfileDto? profile,
    String? pendingFirstName,
    String? pendingLastName,
    String? pendingEmail,
    String? pendingPhoneNumber,
    String? pendingPassword,
    String? token,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      profile: profile ?? this.profile,
      pendingFirstName: pendingFirstName ?? this.pendingFirstName,
      pendingLastName: pendingLastName ?? this.pendingLastName,
      pendingEmail: pendingEmail ?? this.pendingEmail,
      pendingPhoneNumber: pendingPhoneNumber ?? this.pendingPhoneNumber,
      pendingPassword: pendingPassword ?? this.pendingPassword,
      token: token ?? this.token,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        profile,
        pendingFirstName,
        pendingLastName,
        pendingEmail,
        pendingPhoneNumber,
        pendingPassword,
        token,
        errorMessage,
      ];
}
