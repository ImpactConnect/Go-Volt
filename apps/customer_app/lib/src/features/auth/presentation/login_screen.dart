import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_notifier.dart';
import '../../../core/router/app_router.dart';

/// A04 — Sign In Screen
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithGoogle() async {
    final success =
        await ref.read(authNotifierProvider.notifier).signInWithGoogle();
    if (success && mounted) {
      final authState = ref.read(authNotifierProvider);
      if (authState.isProfileIncomplete) {
        context.go(AppRoutes.completeProfile);
      } else {
        context.go(AppRoutes.home);
      }
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authNotifierProvider.notifier).login(
          identifier: _identifierController.text.trim(),
          password: _passwordController.text,
        );

    if (success && mounted) {
      final authState = ref.read(authNotifierProvider);
      if (authState.isProfileIncomplete) {
        context.go(AppRoutes.completeProfile);
      } else {
        context.go(AppRoutes.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const GVTopBar(
        title: 'Sign In',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(GVSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome Back 👋',
                style: GVTypography.h2.copyWith(
                  fontWeight: FontWeight.bold,
                  color: GVColors.textPrimary,
                ),
              ),
              const SizedBox(height: GVSpacing.xs),
              Text(
                'Sign in to manage your rides, deliveries, and wallet.',
                style: GVTypography.bodyMedium.copyWith(
                  color: GVColors.textSecondary,
                ),
              ),
              const SizedBox(height: GVSpacing.xl),

              if (authState.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(GVSpacing.md),
                  decoration: BoxDecoration(
                    color: GVColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(GVBorderRadius.md),
                    border: Border.all(
                      color: GVColors.error.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline_rounded,
                          color: GVColors.error, size: 20),
                      const SizedBox(width: GVSpacing.sm),
                      Expanded(
                        child: Text(
                          authState.errorMessage!,
                          style: GVTypography.bodySmall.copyWith(
                            color: GVColors.error,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: GVSpacing.lg),
              ],

              // Google Sign-In Button
              _GoogleAuthButton(
                isLoading: authState.isLoading,
                onPressed: _signInWithGoogle,
              ),
              const SizedBox(height: GVSpacing.lg),

              // Divider
              Row(
                children: [
                  const Expanded(child: Divider(color: GVColors.border)),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: GVSpacing.md),
                    child: Text(
                      'or sign in with password',
                      style: GVTypography.caption.copyWith(
                        color: GVColors.textSecondary,
                      ),
                    ),
                  ),
                  const Expanded(child: Divider(color: GVColors.border)),
                ],
              ),
              const SizedBox(height: GVSpacing.lg),

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Phone or Email
                    GVFormField(
                      label: 'Phone Number or Email',
                      hint: 'e.g. 08012345678 or name@example.com',
                      controller: _identifierController,
                      keyboardType: TextInputType.emailAddress,
                      prefix: const Icon(Icons.person_outline_rounded),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter your phone number or email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: GVSpacing.md),

                    // Password
                    GVFormField(
                      label: 'Password',
                      hint: 'Enter your password',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      prefix: const Icon(Icons.lock_outline_rounded),
                      suffix: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                      validator: (val) {
                        if (val == null || val.isEmpty) {
                          return 'Please enter your password';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: GVSpacing.xs),

                    // Forgot Password link
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.push(AppRoutes.forgotPassword),
                        child: Text(
                          'Forgot Password?',
                          style: GVTypography.label.copyWith(
                            color: GVColors.brandGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: GVSpacing.md),

                    // Submit button
                    GVPrimaryButton(
                      label: 'Sign In',
                      isLoading: authState.isLoading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: GVSpacing.xl),

                    // Sign up footer
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: GVTypography.bodyMedium.copyWith(
                              color: GVColors.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push(AppRoutes.createAccount),
                            child: Text(
                              'Create Account',
                              style: GVTypography.bodyMedium.copyWith(
                                color: GVColors.brandGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Google OAuth branded button adhering to Go-Volts design system
class _GoogleAuthButton extends StatelessWidget {
  const _GoogleAuthButton({
    required this.onPressed,
    this.isLoading = false,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: GVColors.nearBlack,
          backgroundColor: GVColors.white,
          side: const BorderSide(color: GVColors.border, width: 1.5),
          shape: const RoundedRectangleBorder(
            borderRadius: GVBorderRadius.buttonRadius,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: GVColors.textSecondary,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      'G',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: Color(0xFF4285F4),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Continue with Google',
                    style: GVTypography.buttonLarge.copyWith(
                      color: GVColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
