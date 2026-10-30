import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_notifier.dart';
import '../../../core/router/app_router.dart';

/// A03 — Create Account Screen
class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _agreedToTerms = false;
  String _passwordStrength = 'Weak';
  Color _strengthColor = GVColors.error;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onPasswordChanged(String val) {
    if (val.length >= 8 &&
        val.contains(RegExp(r'[A-Z]')) &&
        val.contains(RegExp(r'[0-9]'))) {
      setState(() {
        _passwordStrength = 'Strong';
        _strengthColor = GVColors.brandGreen;
      });
    } else if (val.length >= 6) {
      setState(() {
        _passwordStrength = 'Fair';
        _strengthColor = GVColors.warning;
      });
    } else {
      setState(() {
        _passwordStrength = 'Weak';
        _strengthColor = GVColors.error;
      });
    }
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

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms of Service to proceed.'),
          backgroundColor: GVColors.error,
        ),
      );
      return;
    }

    final success = await ref.read(authNotifierProvider.notifier).register(
          fullName: _nameController.text.trim(),
          phoneNumber: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (success && mounted) {
      context.push(AppRoutes.otpVerify);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const GVTopBar(
        title: 'Create Account',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(GVSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Join the Electric Future',
                style: GVTypography.h2.copyWith(
                  fontWeight: FontWeight.bold,
                  color: GVColors.textPrimary,
                ),
              ),
              const SizedBox(height: GVSpacing.xs),
              Text(
                'Book rides and send parcels seamlessly across Lagos.',
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

              // Google Sign-In Quick Action
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
                      'or register with email',
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
                    // Full Name
                    GVFormField(
                      label: 'Full Name',
                      hint: 'e.g. Folake Adeleke',
                      controller: _nameController,
                      prefix: const Icon(Icons.person_outline_rounded),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter your full name';
                        }
                        if (val.trim().split(' ').length < 2) {
                          return 'Please enter both first and last name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: GVSpacing.md),

                    // Email (Required for OTP Verification)
                    GVFormField(
                      label: 'Email Address',
                      hint: 'name@example.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefix: const Icon(Icons.mail_outline_rounded),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter your email address';
                        }
                        final emailRegex =
                            RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                        if (!emailRegex.hasMatch(val.trim())) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: GVSpacing.md),

                    // Phone Number with +234
                    GVFormField(
                      label: 'Phone Number',
                      hint: '801 234 5678',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      prefix: Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: GVSpacing.sm),
                        alignment: Alignment.centerLeft,
                        width: 72,
                        child: Text(
                          '🇳🇬 +234',
                          style: GVTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter your phone number';
                        }
                        final cleaned =
                            val.replaceAll(RegExp(r'\s+'), '');
                        if (cleaned.length < 10) {
                          return 'Enter a valid 10 or 11 digit Nigerian number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: GVSpacing.md),

                    // Password
                    GVFormField(
                      label: 'Password',
                      hint: 'At least 8 characters',
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      onChanged: _onPasswordChanged,
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
                        if (val == null || val.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: GVSpacing.xs),

                    // Password strength indicator
                    if (_passwordController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: GVSpacing.xs),
                        child: Row(
                          children: [
                            Text(
                              'Strength: ',
                              style: GVTypography.caption,
                            ),
                            Text(
                              _passwordStrength,
                              style: GVTypography.caption.copyWith(
                                color: _strengthColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: GVSpacing.md),

                    // Terms agreement checkbox
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          value: _agreedToTerms,
                          activeColor: GVColors.brandGreen,
                          onChanged: (val) {
                            setState(() {
                              _agreedToTerms = val ?? false;
                            });
                          },
                        ),
                        Expanded(
                          child: Text(
                            'I agree to the Go-Volts Terms of Service & Privacy Policy',
                            style: GVTypography.bodySmall.copyWith(
                              color: GVColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: GVSpacing.lg),

                    // Submit button
                    GVPrimaryButton(
                      label: 'Create Account',
                      isLoading: authState.isLoading,
                      onPressed: _submit,
                    ),
                    const SizedBox(height: GVSpacing.lg),

                    // Sign in link
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: GVTypography.bodyMedium.copyWith(
                              color: GVColors.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push(AppRoutes.login),
                            child: Text(
                              'Sign In',
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
