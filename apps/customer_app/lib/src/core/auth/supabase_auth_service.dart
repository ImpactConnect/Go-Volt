import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseAuthServiceProvider = Provider<SupabaseAuthService>((ref) {
  return SupabaseAuthService();
});

/// Service managing Supabase authentication, Email OTP, Google OAuth, and session persistence.
class SupabaseAuthService {
  SupabaseAuthService({SupabaseClient? client}) : _client = client;

  final SupabaseClient? _client;

  SupabaseClient? get client {
    if (_client != null) return _client;
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// True if Supabase has been initialized with valid credentials.
  bool get isInitialized => client != null;

  /// Returns current authenticated user or null.
  User? get currentUser => client?.auth.currentUser;

  /// Returns active JWT access token or null.
  String? get currentAccessToken => client?.auth.currentSession?.accessToken;

  /// Stream of Supabase auth state changes.
  Stream<AuthState>? get authStateChanges => client?.auth.onAuthStateChange;

  /// Formats a Nigerian or international phone number to E.164 format (+234...).
  static String formatPhoneNumber(String raw) {
    var cleaned = raw.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    if (cleaned.startsWith('+234')) return cleaned;
    if (cleaned.startsWith('234')) return '+$cleaned';
    if (cleaned.startsWith('0')) cleaned = cleaned.substring(1);
    return '+234$cleaned';
  }

  /// Sends a 6-digit OTP code to the specified email address.
  Future<void> sendEmailOtp(String email) async {
    final sb = client;
    if (sb == null) {
      throw const AuthException(
        'Supabase is not initialized. Unable to dispatch email verification OTP.',
      );
    }

    await sb.auth.signInWithOtp(
      email: email.trim(),
      shouldCreateUser: true,
    );
  }

  /// Updates user credentials and profile metadata after registration.
  Future<UserResponse?> updateUserCredentials({
    String? password,
    String? fullName,
    String? phoneNumber,
  }) async {
    final sb = client;
    if (sb == null) return null;

    final data = <String, dynamic>{};
    if (fullName != null && fullName.isNotEmpty) data['full_name'] = fullName;
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      data['phone_number'] = formatPhoneNumber(phoneNumber);
    }

    return await sb.auth.updateUser(
      UserAttributes(
        password: (password != null && password.isNotEmpty) ? password : null,
        data: data.isNotEmpty ? data : null,
      ),
    );
  }

  /// Verifies a 6-digit Email OTP code.
  Future<AuthResponse> verifyEmailOtp({
    required String email,
    required String token,
  }) async {
    final sb = client;
    if (sb == null) {
      throw const AuthException(
        'Supabase is not initialized. Unable to verify email OTP.',
      );
    }

    return await sb.auth.verifyOTP(
      email: email.trim(),
      token: token.trim(),
      type: OtpType.email,
    );
  }

  /// Initiates native in-app Google Sign-In displaying the device account picker popup.
  Future<bool> signInWithGoogle({String? serverClientId}) async {
    final sb = client;
    if (sb == null) {
      throw const AuthException('Supabase is not initialized.');
    }

    try {
      final googleSignIn = GoogleSignIn(
        serverClientId: serverClientId,
        scopes: const ['email', 'profile'],
      );

      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // User canceled / dismissed the popup without selecting an account
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;
      final accessToken = googleAuth.accessToken;

      if (idToken == null) {
        throw const AuthException(
          'Failed to retrieve Google ID Token. Ensure the Web Client ID is configured in Supabase.',
        );
      }

      final response = await sb.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      return response.user != null;
    } on AuthException {
      rethrow;
    } catch (e) {
      final err = e.toString();
      if (err.contains('10') || err.contains('Developer error')) {
        throw const AuthException(
          'Google Sign-In configuration error: Check that your Android SHA-1 fingerprint and package name match in Google Cloud Console.',
        );
      }
      throw AuthException(
        'Google Sign-In failed: ${err.replaceAll("Exception: ", "")}',
      );
    }
  }

  /// Updates user profile metadata (e.g. after Google OAuth).
  Future<UserResponse> updateUserMetadata({
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
  }) async {
    final sb = client;
    if (sb == null) {
      throw const AuthException('Supabase is not initialized.');
    }

    final data = <String, dynamic>{};
    if (fullName != null) data['full_name'] = fullName;
    if (phoneNumber != null) data['phone_number'] = formatPhoneNumber(phoneNumber);
    if (avatarUrl != null) data['avatar_url'] = avatarUrl;

    return await sb.auth.updateUser(
      UserAttributes(data: data),
    );
  }

  /// Sends an SMS OTP to a Nigerian phone number (+234...).
  Future<void> sendPhoneOtp(String phoneNumber) async {
    final sb = client;
    if (sb == null) {
      throw const AuthException(
        'Supabase is not initialized. Please set SUPABASE_URL and SUPABASE_ANON_KEY to dispatch real SMS OTPs.',
      );
    }

    final formatted = formatPhoneNumber(phoneNumber);
    await sb.auth.signInWithOtp(
      phone: formatted,
      channel: OtpChannel.sms,
    );
  }

  /// Verifies a 6-digit SMS OTP code.
  Future<AuthResponse> verifyPhoneOtp({
    required String phoneNumber,
    required String token,
  }) async {
    final sb = client;
    if (sb == null) {
      throw const AuthException(
        'Supabase is not initialized. Unable to verify real SMS OTP.',
      );
    }

    final formatted = formatPhoneNumber(phoneNumber);
    return await sb.auth.verifyOTP(
      phone: formatted,
      token: token,
      type: OtpType.sms,
    );
  }

  /// Signs in with password (phone or email).
  Future<AuthResponse?> signInWithPassword({
    required String identifier,
    required String password,
  }) async {
    final sb = client;
    if (sb == null) return null;

    if (identifier.contains('@')) {
      return await sb.auth.signInWithPassword(
        email: identifier,
        password: password,
      );
    } else {
      final formatted = formatPhoneNumber(identifier);
      return await sb.auth.signInWithPassword(
        phone: formatted,
        password: password,
      );
    }
  }

  /// Signs out and clears local session.
  Future<void> signOut() async {
    final sb = client;
    if (sb != null) {
      await sb.auth.signOut();
    }
  }
}
