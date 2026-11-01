import 'dart:async';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_notifier.dart';
import '../../../core/auth/auth_state.dart';
import '../../../core/router/app_router.dart';

/// Screen 5: Email OTP Verification (AUTH-03-EMAIL-OTP)
/// Specification Section 5 & Design Board 1/2.
class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _pinController = TextEditingController();
  int _secondsRemaining = 60;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsRemaining = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pinController.dispose();
    super.dispose();
  }

  Future<void> _verify(String code) async {
    if (code.length < 6) return;

    final success =
        await ref.read(authNotifierProvider.notifier).verifyOtp(code);
    if (success && mounted) {
      context.go(AppRoutes.home);
    }
  }

  String _maskEmail(String email) {
    if (!email.contains('@')) return email;
    final parts = email.split('@');
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return '$name***@$domain';
    return '${name[0]}***${name[name.length - 1]}@$domain';
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AuthState>(authNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated && mounted) {
        context.go(AppRoutes.home);
      } else if (next.status == AuthStatus.profileIncomplete && mounted) {
        context.go(AppRoutes.completeProfile);
      }
    });

    final authState = ref.watch(authNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF131A16) : Colors.white;
    final textColor = isDark ? Colors.white : GVColors.textPrimary;
    final subtextColor = isDark ? GVColors.neutral400 : GVColors.textSecondary;
    final rawEmail = authState.pendingEmail ?? 'alex@example.com';
    final maskedEmail = _maskEmail(rawEmail);

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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: GVSpacing.md),

              // Mail Icon Circular Badge
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1C2621)
                      : GVColors.brandGreen.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.mail_outline_rounded,
                    size: 32,
                    color: GVColors.brandGreen,
                  ),
                ),
              ),
              const SizedBox(height: GVSpacing.lg),

              // Title
              Text(
                'Check your email',
                style: GVTypography.h1.copyWith(
                  color: textColor,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: GVSpacing.xs),

              // Subtitle with masked email
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: GVSpacing.md),
                child: Text(
                  'We\'ve sent a 6-digit verification code to\n$maskedEmail',
                  textAlign: TextAlign.center,
                  style: GVTypography.bodyMedium.copyWith(
                    color: subtextColor,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: GVSpacing.xl),

              // Error notification banner if any
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
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: GVSpacing.md),
              ],

              // 6-digit Email OTP Input
              GVEmailOtpInput(
                controller: _pinController,
                hasError: authState.errorMessage != null,
                onCompleted: _verify,
              ),
              const SizedBox(height: GVSpacing.xl),

              // Cooldown / Resend Timer
              Text(
                'Didn\'t receive the code?',
                style: GVTypography.bodySmall.copyWith(color: subtextColor),
              ),
              const SizedBox(height: 4),
              if (_secondsRemaining > 0)
                Text(
                  'Resend code (${_secondsRemaining}s)',
                  style: GVTypography.bodySmall.copyWith(
                    color: subtextColor,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else
                TextButton(
                  onPressed: () {
                    ref.read(authNotifierProvider.notifier).resendOtp();
                    _startCountdown();
                  },
                  child: Text(
                    'Resend code',
                    style: GVTypography.bodySmall.copyWith(
                      color: GVColors.brandGreen,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              const SizedBox(height: GVSpacing.md),
              Container(
                padding: const EdgeInsets.all(GVSpacing.md),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF1B2620)
                      : GVColors.softBackground,
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(
                    color: isDark
                        ? const Color(0xFF2E3D35)
                        : GVColors.border,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.mark_email_read_outlined,
                      size: 20,
                      color: GVColors.brandGreen,
                    ),
                    const SizedBox(width: GVSpacing.sm),
                    Expanded(
                      child: Text(
                        'Tip: You can enter the 6-digit code or tap the confirmation link in your email to sign in automatically.',
                        style: GVTypography.caption.copyWith(
                          color: subtextColor,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: GVSpacing.xxl),

              // Bottom Open Envelope Illustration Graphic
              Center(
                child: Opacity(
                  opacity: 0.35,
                  child: Container(
                    width: 120,
                    height: 90,
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E2E24) : GVColors.softBackground,
                      borderRadius: BorderRadius.circular(GVBorderRadius.lg),
                      border: Border.all(
                        color: GVColors.brandGreen.withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.mark_email_read_outlined,
                        size: 48,
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
    );
  }
}
