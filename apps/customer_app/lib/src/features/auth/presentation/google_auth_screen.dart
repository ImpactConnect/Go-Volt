import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_notifier.dart';
import '../../../core/router/app_router.dart';

/// Screen 6: Google Sign Up / Confirmation (AUTH-04-GOOGLE-AUTH)
/// Specification Section 6 & Design Board 1/2.
class GoogleAuthConfirmationScreen extends ConsumerWidget {
  const GoogleAuthConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.profile;
    final fullName = user?.fullName ?? 'Alex Johnson';
    final email = user?.email ?? 'alex@gmail.com';
    final avatarUrl = user?.avatarUrl;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF131A16) : Colors.white;
    final textColor = isDark ? Colors.white : GVColors.textPrimary;
    final subtextColor = isDark ? GVColors.neutral400 : GVColors.textSecondary;
    final cardBg = isDark ? const Color(0xFF1C2420) : GVColors.white;
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: GVSpacing.lg),

              // Google 'G' Logo Badge
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1C2420) : GVColors.softBackground,
                  shape: BoxShape.circle,
                  border: Border.all(color: borderColor),
                ),
                child: const Center(
                  child: Text(
                    'G',
                    style: TextStyle(
                      color: Color(0xFF4285F4),
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: GVSpacing.lg),

              // Title
              Text(
                'Continue with Google',
                style: GVTypography.h1.copyWith(
                  color: textColor,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: GVSpacing.xs),

              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: GVSpacing.md),
                child: Text(
                  'You\'ll be signed in using your Google account via Supabase.',
                  textAlign: TextAlign.center,
                  style: GVTypography.bodyMedium.copyWith(
                    color: subtextColor,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: GVSpacing.xxl),

              // Account Card Preview
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: GVSpacing.md,
                  vertical: GVSpacing.sm + 4,
                ),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: GVBorderRadius.cardRadius,
                  border: Border.all(color: borderColor),
                  boxShadow: isDark ? null : GVShadows.card,
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: GVColors.brandGreen.withValues(alpha: 0.2),
                      backgroundImage:
                          avatarUrl != null ? NetworkImage(avatarUrl) : null,
                      child: avatarUrl == null
                          ? Text(
                              fullName.isNotEmpty ? fullName[0].toUpperCase() : 'G',
                              style: GVTypography.h3.copyWith(
                                color: GVColors.brandGreen,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: GVSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            fullName,
                            style: GVTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.bold,
                              color: textColor,
                            ),
                          ),
                          Text(
                            email,
                            style: GVTypography.caption.copyWith(
                              color: subtextColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: subtextColor,
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Primary "Continue" Button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: () => context.go(AppRoutes.home),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: GVColors.brandGreen,
                    foregroundColor: GVColors.nearBlack,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(GVBorderRadius.md),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: GVTypography.buttonLarge.copyWith(
                      color: GVColors.nearBlack,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: GVSpacing.md),

              // Consent Disclaimer
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: GVSpacing.sm),
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
              const SizedBox(height: GVSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}
