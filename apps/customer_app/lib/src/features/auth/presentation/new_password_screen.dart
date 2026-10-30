import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_notifier.dart';
import '../../../core/router/app_router.dart';

/// Screen 10: New Password (AUTH-07B-NEW-PASSWORD)
/// Specification Section 8.2 & Design Board 1/2.
class NewPasswordScreen extends ConsumerStatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  ConsumerState<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends ConsumerState<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _currentPassword = '';

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Passwords do not match.'),
          backgroundColor: GVColors.error,
        ),
      );
      return;
    }

    final success = await ref
        .read(authNotifierProvider.notifier)
        .resetPassword(_passwordController.text);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password updated successfully! Please log in.'),
          backgroundColor: GVColors.brandGreen,
        ),
      );
      context.go(AppRoutes.login);
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
                  'Create a new password',
                  style: GVTypography.h1.copyWith(
                    color: textColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: GVSpacing.xs),
                Text(
                  'Enter a new password for your account.',
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
                    child: Text(
                      authState.errorMessage!,
                      style: GVTypography.bodySmall.copyWith(
                        color: GVColors.error,
                      ),
                    ),
                  ),
                  const SizedBox(height: GVSpacing.md),
                ],

                // New Password Input
                GVFormField(
                  label: 'New password',
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
                      return 'Please enter your new password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: GVSpacing.md),

                // Real-Time Password Validation Checklist
                GVPasswordValidationIndicator(password: _currentPassword),
                const SizedBox(height: GVSpacing.lg),

                // Confirm New Password Input
                GVFormField(
                  label: 'Confirm new password',
                  hint: '••••••••',
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  prefix: const Icon(Icons.lock_outline_rounded, size: 20),
                  suffix: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      size: 20,
                      color: subtextColor,
                    ),
                    onPressed: () => setState(() =>
                        _obscureConfirmPassword = !_obscureConfirmPassword),
                  ),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please confirm your new password';
                    }
                    if (val != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: GVSpacing.xl),

                // Primary CTA: "Reset password"
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
                            'Reset password',
                            style: GVTypography.buttonLarge.copyWith(
                              color: GVColors.nearBlack,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: GVSpacing.xxl),

                // Bottom Shield Graphic Illustration
                Center(
                  child: Opacity(
                    opacity: 0.35,
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E2E24) : GVColors.softBackground,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: GVColors.brandGreen.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.security_rounded,
                          size: 54,
                          color: GVColors.brandGreen,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: GVSpacing.lg),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

