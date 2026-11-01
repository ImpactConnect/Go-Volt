import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_notifier.dart';
import '../../../core/router/app_router.dart';

/// Screen 4: Sign Up (Email) (AUTH-02-SIGNUP)
/// Specification Section 4 & Design Board 1/2.
class CreateAccountScreen extends ConsumerStatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  ConsumerState<CreateAccountScreen> createState() =>
      _CreateAccountScreenState();
}

class _CreateAccountScreenState extends ConsumerState<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  String _currentPassword = '';

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final indicator = GVPasswordValidationIndicator(password: _currentPassword);
    if (!indicator.isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please satisfy all password security criteria.'),
          backgroundColor: GVColors.error,
        ),
      );
      return;
    }

    final success = await ref
        .read(authNotifierProvider.notifier)
        .register(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

    if (success && mounted) {
      context.go(AppRoutes.completeProfile);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF131A16) : Colors.white;
    final textColor = isDark ? Colors.white : GVColors.textPrimary;
    final subtextColor = isDark ? GVColors.neutral400 : GVColors.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: isDark ? Colors.white : GVColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: GVSpacing.sm),
                Text(
                  'Create your account',
                  style: GVTypography.h1.copyWith(
                    color: textColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: GVSpacing.xs),
                Text(
                  'Enter your details to get started.',
                  style: GVTypography.bodyMedium.copyWith(
                    color: subtextColor,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: GVSpacing.xl),

                if (authState.errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(GVSpacing.md),
                    decoration: BoxDecoration(
                      color: GVColors.error.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(GVBorderRadius.md),
                      border: Border.all(
                        color: GVColors.error.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: GVColors.error,
                          size: 20,
                        ),
                        const SizedBox(width: GVSpacing.sm),
                        Expanded(
                          child: Text(
                            authState.errorMessage!,
                            style: GVTypography.bodySmall.copyWith(
                              color: GVColors.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: GVSpacing.md),
                ],

                // First Name Field
                GVFormField(
                  label: 'First name',
                  hint: 'Alex',
                  controller: _firstNameController,
                  prefix: const Icon(Icons.person_outline_rounded, size: 20),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your first name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: GVSpacing.md),

                // Last Name Field
                GVFormField(
                  label: 'Last name',
                  hint: 'Johnson',
                  controller: _lastNameController,
                  prefix: const Icon(Icons.person_outline_rounded, size: 20),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your last name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: GVSpacing.md),

                // Email Field
                GVFormField(
                  label: 'Email',
                  hint: 'alex@example.com',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  prefix: const Icon(Icons.mail_outline_rounded, size: 20),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!val.contains('@') || !val.contains('.')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: GVSpacing.md),

                // Password Field with Eye Toggle
                GVFormField(
                  label: 'Password',
                  hint: '••••••••',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  prefix: const Icon(Icons.lock_outline_rounded, size: 20),
                  suffix: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: subtextColor,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  onChanged: (val) => setState(() => _currentPassword = val),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please enter a password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: GVSpacing.md),

                // Real-Time Password Validation Checklist
                GVPasswordValidationIndicator(password: _currentPassword),
                const SizedBox(height: GVSpacing.xl),

                // Primary CTA: "Continue"
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: authState.isLoading ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GVColors.brandGreen,
                      foregroundColor: GVColors.nearBlack,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(GVBorderRadius.md),
                      ),
                    ),
                    child: authState.isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: GVColors.nearBlack,
                            ),
                          )
                        : Text(
                            'Continue',
                            style: GVTypography.buttonLarge.copyWith(
                              color: GVColors.nearBlack,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: GVSpacing.lg),

                // Terms of Service and Privacy Policy Consent
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: GVSpacing.sm,
                    ),
                    child: Wrap(
                      alignment: WrapAlignment.center,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          'By continuing, you agree to our ',
                          style: GVTypography.caption.copyWith(
                            color: subtextColor,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Terms of Service',
                          style: GVTypography.caption.copyWith(
                            color: GVColors.brandGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          ' and ',
                          style: GVTypography.caption.copyWith(
                            color: subtextColor,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          'Privacy Policy',
                          style: GVTypography.caption.copyWith(
                            color: GVColors.brandGreen,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '.',
                          style: GVTypography.caption.copyWith(
                            color: subtextColor,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: GVSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
