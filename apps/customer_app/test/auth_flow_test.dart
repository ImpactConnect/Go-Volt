import 'package:app_models/app_models.dart';
import 'package:customer_app/src/core/auth/auth_notifier.dart';
import 'package:customer_app/src/core/auth/auth_state.dart';
import 'package:customer_app/src/core/auth/supabase_auth_service.dart';
import 'package:customer_app/src/features/auth/presentation/complete_profile_screen.dart';
import 'package:customer_app/src/features/auth/presentation/create_account_screen.dart';
import 'package:customer_app/src/features/auth/presentation/forgot_password_screen.dart';
import 'package:customer_app/src/features/auth/presentation/google_auth_screen.dart';
import 'package:customer_app/src/features/auth/presentation/login_screen.dart';
import 'package:customer_app/src/features/auth/presentation/new_password_screen.dart';
import 'package:customer_app/src/features/auth/presentation/otp_verification_screen.dart';
import 'package:customer_app/src/features/auth/presentation/reset_password_otp_screen.dart';
import 'package:customer_app/src/features/auth/presentation/signup_options_screen.dart';
import 'package:customer_app/src/features/auth/presentation/welcome_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

class _FakeSupabaseAuthService extends SupabaseAuthService {
  @override
  bool get isInitialized => true;

  @override
  Future<void> sendEmailOtp(String email) async {}

  @override
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    return AuthResponse(
      user: User(
        id: 'usr_test_123',
        appMetadata: {},
        userMetadata: {
          'first_name': firstName,
          'last_name': lastName,
          'full_name': '$firstName $lastName',
        },
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: email,
      ),
    );
  }

  @override
  Future<AuthResponse> verifyEmailOtp({
    required String email,
    required String token,
    OtpType type = OtpType.signup,
  }) async {
    return AuthResponse(
      user: User(
        id: 'usr_test_123',
        appMetadata: {},
        userMetadata: {
          'full_name': 'Folake Adeleke',
          'phone_number': '+2348012345678',
        },
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: email,
      ),
      session: Session(
        accessToken: 'fake-access-token',
        tokenType: 'bearer',
        user: User(
          id: 'usr_test_123',
          appMetadata: {},
          userMetadata: {
            'full_name': 'Folake Adeleke',
            'phone_number': '+2348012345678',
          },
          aud: 'authenticated',
          createdAt: DateTime.now().toIso8601String(),
          email: email,
        ),
      ),
    );
  }

  @override
  Future<bool> signInWithGoogle({String? serverClientId}) async => true;

  @override
  User? get currentUser => User(
        id: 'usr_google_test',
        appMetadata: {},
        userMetadata: {
          'full_name': 'Alex Odeh',
          'avatar_url':
              'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
        },
        aud: 'authenticated',
        createdAt: DateTime.now().toIso8601String(),
        email: 'alex.odeh@gmail.com',
      );

  @override
  String? get currentAccessToken => 'fake-google-token';

  @override
  Future<UserResponse> updateUserMetadata({
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
  }) async {
    return UserResponse.fromJson({
      'id': 'usr_google_test',
      'aud': 'authenticated',
      'created_at': DateTime.now().toIso8601String(),
      'user_metadata': {
        'full_name': fullName ?? 'Alex Odeh',
        'phone_number': phoneNumber ?? '',
      },
    });
  }
}

class _MockProfileIncompleteNotifier extends AuthNotifier {
  _MockProfileIncompleteNotifier()
      : super(authService: _FakeSupabaseAuthService()) {
    state = AuthState(
      status: AuthStatus.profileIncomplete,
      token: 'fake-token',
      profile: ProfileDto(
        id: 'usr_google_test',
        fullName: 'Alex Odeh',
        phoneNumber: '',
        email: 'alex.odeh@gmail.com',
        avatarUrl:
            'https://images.unsplash.com/photo-1534528741775-53994a69daeb',
        roles: const [UserRole.customer],
        createdAt: DateTime.now(),
      ),
    );
  }
}

void main() {
  setUpAll(() {
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  group('AuthNotifier Email OTP & Google Auth Unit Tests', () {
    test('register dispatches email OTP and sets pendingEmail', () async {
      final notifier = AuthNotifier(authService: _FakeSupabaseAuthService());

      final success = await notifier.register(
        firstName: 'Folake',
        lastName: 'Adeleke',
        phoneNumber: '08012345678',
        email: 'folake@example.com',
        password: 'Password123!',
      );

      expect(success, isTrue);
      expect(notifier.state.status, equals(AuthStatus.otpSent));
      expect(notifier.state.pendingEmail, equals('folake@example.com'));
      expect(notifier.state.pendingPhoneNumber, equals('+2348012345678'));
    });

    test('verifyOtp verifies code and completes authentication', () async {
      final notifier = AuthNotifier(authService: _FakeSupabaseAuthService());

      await notifier.register(
        firstName: 'Folake',
        lastName: 'Adeleke',
        phoneNumber: '08012345678',
        email: 'folake@example.com',
        password: 'Password123!',
      );

      final success = await notifier.verifyOtp('123456');

      expect(success, isTrue);
      expect(notifier.state.status, equals(AuthStatus.authenticated));
      expect(notifier.state.isAuthenticated, isTrue);
      expect(notifier.state.profile?.fullName, equals('Folake Adeleke'));
      expect(notifier.state.profile?.phoneNumber, equals('+2348012345678'));
    });

    test('signInWithGoogle triggers profileIncomplete when phone is empty', () async {
      final notifier = AuthNotifier(authService: _FakeSupabaseAuthService());

      final success = await notifier.signInWithGoogle();

      expect(success, isTrue);
      expect(notifier.state.status, equals(AuthStatus.profileIncomplete));
      expect(notifier.state.isProfileIncomplete, isTrue);
      expect(notifier.state.profile?.email, contains('gmail.com'));
      expect(notifier.state.profile?.phoneNumber, isEmpty);
    });

    test('completeProfile updates phone and sets authenticated', () async {
      final notifier = AuthNotifier(authService: _FakeSupabaseAuthService());

      await notifier.signInWithGoogle();
      expect(notifier.state.isProfileIncomplete, isTrue);

      final success = await notifier.completeProfile(
        phoneNumber: '08098765432',
      );

      expect(success, isTrue);
      expect(notifier.state.status, equals(AuthStatus.authenticated));
      expect(notifier.state.isAuthenticated, isTrue);
      expect(notifier.state.profile?.phoneNumber, equals('+2348098765432'));
    });
  });

  group('Auth Screens 1–10 Widget Tests', () {
    testWidgets('Screen 2: WelcomeScreen renders value prop and CTA buttons',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: WelcomeScreen(),
        ),
      );

      expect(find.text('Move faster.\nGo greener.\nGo further.'), findsOneWidget);
      expect(find.text('Get started'), findsOneWidget);
      expect(find.text('Skip'), findsOneWidget);
      expect(find.text('I already have an account'), findsOneWidget);
    });

    testWidgets('Screen 3: SignUpOptionsScreen renders Google and Email buttons',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: SignUpOptionsScreen(),
          ),
        ),
      );

      expect(find.text('Create your account'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Sign up with email'), findsOneWidget);
      expect(find.text('Already have an account? '), findsOneWidget);
    });

    testWidgets('Screen 4: CreateAccountScreen renders First/Last name and live checklist',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CreateAccountScreen(),
          ),
        ),
      );

      expect(find.text('Create your account'), findsOneWidget);
      expect(find.text('First name'), findsOneWidget);
      expect(find.text('Last name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.text('At least 8 characters'), findsOneWidget);
    });

    testWidgets('Screen 5: OtpVerificationScreen renders masked email and Pinput',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: OtpVerificationScreen(),
          ),
        ),
      );

      expect(find.text('Check your email'), findsOneWidget);
      expect(find.textContaining('verification code'), findsOneWidget);
      expect(find.text('Didn\'t receive the code?'), findsOneWidget);
    });

    testWidgets('Screen 6: GoogleAuthConfirmationScreen renders Google preview card',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: GoogleAuthConfirmationScreen(),
          ),
        ),
      );

      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);
      expect(find.textContaining('Terms of Service'), findsOneWidget);
    });

    testWidgets('Screen 7: LoginScreen renders email/password and Forgot password link',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Forgot password?'), findsOneWidget);
      expect(find.text('Log in'), findsOneWidget);
      expect(find.text('Continue with Google'), findsOneWidget);
    });

    testWidgets('Screen 8: ForgotPasswordScreen renders email input and Send code CTA',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ForgotPasswordScreen(),
          ),
        ),
      );

      expect(find.text('Reset your password'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Send code'), findsOneWidget);
    });

    testWidgets('Screen 9: ResetPasswordOtpScreen renders recovery OTP',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ResetPasswordOtpScreen(),
          ),
        ),
      );

      expect(find.text('Check your email'), findsOneWidget);
      expect(find.text('Didn\'t receive the code?'), findsOneWidget);
    });

    testWidgets('Screen 10: NewPasswordScreen renders password inputs and validation checklist',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: NewPasswordScreen(),
          ),
        ),
      );

      expect(find.text('Create a new password'), findsOneWidget);
      expect(find.text('New password'), findsOneWidget);
      expect(find.text('Confirm new password'), findsOneWidget);
      expect(find.text('Reset password'), findsOneWidget);
      expect(find.text('At least 8 characters'), findsOneWidget);
    });

    testWidgets('CompleteProfileScreen renders Google profile badge and phone input',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authNotifierProvider.overrideWith((ref) => _MockProfileIncompleteNotifier()),
          ],
          child: const MaterialApp(
            home: CompleteProfileScreen(),
          ),
        ),
      );

      expect(find.text('Complete Profile'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
      expect(find.text('Alex Odeh'), findsNWidgets(2));
    });
  });
}
