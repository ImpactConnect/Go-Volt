import 'package:app_models/app_models.dart';
import 'package:customer_app/src/core/auth/auth_notifier.dart';
import 'package:customer_app/src/core/auth/auth_state.dart';
import 'package:customer_app/src/core/auth/supabase_auth_service.dart';
import 'package:customer_app/src/features/auth/presentation/complete_profile_screen.dart';
import 'package:customer_app/src/features/auth/presentation/create_account_screen.dart';
import 'package:customer_app/src/features/auth/presentation/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

class _FakeSupabaseAuthService extends SupabaseAuthService {
  @override
  bool get isInitialized => true;

  @override
  Future<void> sendEmailOtp(String email) async {}

  @override
  Future<AuthResponse> verifyEmailOtp({
    required String email,
    required String token,
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
  _MockProfileIncompleteNotifier() : super(authService: _FakeSupabaseAuthService()) {
    state = AuthState(
      status: AuthStatus.profileIncomplete,
      profile: ProfileDto(
        id: 'usr_google_test',
        fullName: 'Alex Odeh',
        email: 'alex.odeh@gmail.com',
        phoneNumber: '',
        roles: const [UserRole.customer],
        createdAt: DateTime.now(),
      ),
      pendingEmail: 'alex.odeh@gmail.com',
    );
  }
}

void main() {
  group('AuthNotifier Email OTP & Google Auth Unit Tests', () {
    test('register dispatches email OTP and sets pendingEmail', () async {
      final notifier = AuthNotifier(authService: _FakeSupabaseAuthService());

      final success = await notifier.register(
        fullName: 'Folake Adeleke',
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
        fullName: 'Folake Adeleke',
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

  group('Auth Screens Widget Tests', () {
    testWidgets('CreateAccountScreen renders Continue with Google and Email field',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: CreateAccountScreen(),
          ),
        ),
      );

      expect(find.text('Create Account'), findsWidgets);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('or register with email'), findsOneWidget);
      expect(find.text('Email Address'), findsOneWidget);
      expect(find.text('Phone Number'), findsOneWidget);
    });

    testWidgets('LoginScreen renders Continue with Google and credentials inputs',
        (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: LoginScreen(),
          ),
        ),
      );

      expect(find.text('Sign In'), findsWidgets);
      expect(find.text('Continue with Google'), findsOneWidget);
      expect(find.text('or sign in with password'), findsOneWidget);
      expect(find.text('Phone Number or Email'), findsOneWidget);
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
      expect(find.text('alex.odeh@gmail.com'), findsOneWidget);
      expect(find.textContaining('Phone Number'), findsOneWidget);
      expect(find.text('Complete Profile & Continue'), findsOneWidget);
    });
  });
}
