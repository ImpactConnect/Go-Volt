import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_notifier.dart';
import '../../../core/auth/auth_state.dart';
import '../../../core/router/app_router.dart';

/// Screen 3: Sign Up Options (AUTH-01B-SIGNUP-OPTIONS)
/// Specification Section 4.2 & Design Board 1/2.
class SignUpOptionsScreen extends ConsumerWidget {
  const SignUpOptionsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF131A16) : Colors.white;
    final textColor = isDark ? Colors.white : GVColors.textPrimary;
    final subtextColor = isDark ? GVColors.neutral400 : GVColors.textSecondary;
    final buttonBg = isDark ? const Color(0xFF1C2420) : GVColors.white;
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;

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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: GVSpacing.md),
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
                'Join Go-Volts to start riding and sending parcels.',
                style: GVTypography.bodyMedium.copyWith(
                  color: subtextColor,
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: GVSpacing.xxl),

              // "Continue with Google" Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () async {
                    final success = await ref
                        .read(authNotifierProvider.notifier)
                        .signInWithGoogle();
                    if (success && context.mounted) {
                      final authState = ref.read(authNotifierProvider);
                      if (authState.status == AuthStatus.profileIncomplete ||
                          authState.profile?.isProfileComplete != true) {
                        context.go(AppRoutes.completeProfile);
                      } else {
                        context.go(AppRoutes.home);
                      }
                    }
                  },
                  style: OutlinedButton.styleFrom(
                    backgroundColor: buttonBg,
                    side: BorderSide(color: borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(GVBorderRadius.md),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'G',
                            style: TextStyle(
                              color: Color(0xFF4285F4),
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: GVSpacing.sm),
                      Text(
                        'Continue with Google',
                        style: GVTypography.buttonLarge.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: GVSpacing.md),

              // "Sign up with email" Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => context.push(AppRoutes.createAccount),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: buttonBg,
                    foregroundColor: textColor,
                    elevation: 0,
                    side: BorderSide(color: borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(GVBorderRadius.md),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.mail_outline_rounded,
                        size: 20,
                        color: textColor,
                      ),
                      const SizedBox(width: GVSpacing.sm),
                      Text(
                        'Sign up with email',
                        style: GVTypography.buttonLarge.copyWith(
                          color: textColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: GVSpacing.xl),

              // Divider "or"
              Row(
                children: [
                  Expanded(
                    child: Divider(
                      color: isDark ? const Color(0xFF2E3D35) : GVColors.divider,
                      thickness: 1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: GVSpacing.md),
                    child: Text(
                      'or',
                      style: GVTypography.bodySmall.copyWith(color: subtextColor),
                    ),
                  ),
                  Expanded(
                    child: Divider(
                      color: isDark ? const Color(0xFF2E3D35) : GVColors.divider,
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: GVSpacing.xl),

              // "Already have an account? Log in"
              Center(
                child: GestureDetector(
                  onTap: () => context.push(AppRoutes.login),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: GVTypography.bodySmall.copyWith(color: subtextColor),
                      ),
                      Text(
                        'Log in',
                        style: GVTypography.bodySmall.copyWith(
                          color: GVColors.brandGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Bottom Cityscape Graphic
              Center(
                child: Opacity(
                  opacity: 0.35,
                  child: Icon(
                    Icons.location_city_rounded,
                    size: 80,
                    color: GVColors.brandGreen.withValues(alpha: 0.5),
                  ),
                ),
              ),
              const SizedBox(height: GVSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
