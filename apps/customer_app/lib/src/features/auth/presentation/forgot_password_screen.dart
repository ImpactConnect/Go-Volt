import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_notifier.dart';
import '../../../core/router/app_router.dart';

/// Screen 8: Forgot Password (AUTH-06-FORGOT-PASSWORD)
/// Specification Section 8.1 & Design Board 1/2.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref
        .read(authNotifierProvider.notifier)
        .sendPasswordReset(_emailController.text.trim());

    if (success && mounted) {
      context.push(AppRoutes.resetPasswordOtp);
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
                  'Reset your password',
                  style: GVTypography.h1.copyWith(
                    color: textColor,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: GVSpacing.xs),
                Text(
                  'Enter your email and we\'ll send you a verification code.',
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
                    if (!val.contains('@')) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: GVSpacing.xl),

                // Primary CTA: "Send code"
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
                            'Send code',
                            style: GVTypography.buttonLarge.copyWith(
                              color: GVColors.nearBlack,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: GVSpacing.xxl * 2),

                // Bottom Envelope Graphic Illustration
                Center(
                  child: Opacity(
                    opacity: 0.35,
                    child: Container(
                      width: 130,
                      height: 95,
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF1E2E24) : GVColors.softBackground,
                        borderRadius: BorderRadius.circular(GVBorderRadius.lg),
                        border: Border.all(
                          color: GVColors.brandGreen.withValues(alpha: 0.3),
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.mail_outline_rounded,
                          size: 52,
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
