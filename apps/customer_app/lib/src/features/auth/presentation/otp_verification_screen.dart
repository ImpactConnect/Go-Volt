import 'dart:async';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:pinput/pinput.dart';

import '../../../core/auth/auth_notifier.dart';
import '../../../core/router/app_router.dart';

/// A05 — OTP Verification Screen
class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _pinController = TextEditingController();
  int _secondsRemaining = 30;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() => _secondsRemaining = 30);
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
    final destination = authState.pendingEmail ??
        authState.pendingPhoneNumber ??
        'your registered email';

    final defaultPinTheme = PinTheme(
      width: 52,
      height: 58,
      textStyle: GVTypography.h2.copyWith(
        fontWeight: FontWeight.bold,
        color: GVColors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: GVColors.softBackground,
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        border: Border.all(color: GVColors.border),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        border: Border.all(color: GVColors.brandGreen, width: 2),
        boxShadow: [
          BoxShadow(
            color: GVColors.brandGreen.withValues(alpha: 0.18),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const GVTopBar(title: 'Verification'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(GVSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Verify Your Email',
                style: GVTypography.h2.copyWith(
                  fontWeight: FontWeight.bold,
                  color: GVColors.textPrimary,
                ),
              ),
              const SizedBox(height: GVSpacing.xs),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Enter the 6-digit code sent to $destination',
                      style: GVTypography.bodyMedium.copyWith(
                        color: GVColors.textSecondary,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Text(
                      'Edit',
                      style: GVTypography.label.copyWith(
                        color: GVColors.brandGreen,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: GVSpacing.xl),

              if (authState.errorMessage != null) ...[
                Container(
                  padding: const EdgeInsets.all(GVSpacing.md),
                  decoration: BoxDecoration(
                    color: GVColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(GVBorderRadius.md),
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
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: GVSpacing.lg),
              ],

              // 6-digit Pinput
              Center(
                child: Pinput(
                  length: 6,
                  controller: _pinController,
                  defaultPinTheme: defaultPinTheme,
                  focusedPinTheme: focusedPinTheme,
                  autofocus: true,
                  onCompleted: _verify,
                ),
              ),
              const SizedBox(height: GVSpacing.xl),

              // Countdown / Resend
              Center(
                child: _secondsRemaining > 0
                    ? Text(
                        'Resend code in 00:${_secondsRemaining.toString().padLeft(2, '0')}',
                        style: GVTypography.bodyMedium.copyWith(
                          color: GVColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      )
                    : TextButton(
                        onPressed: () {
                          ref.read(authNotifierProvider.notifier).resendOtp();
                          _startCountdown();
                        },
                        child: Text(
                          'Resend Code via Email',
                          style: GVTypography.buttonMedium.copyWith(
                            color: GVColors.brandGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
              const SizedBox(height: GVSpacing.xl),

              // Submit Button
              GVPrimaryButton(
                label: 'Verify & Continue',
                isLoading: authState.isLoading,
                onPressed: () => _verify(_pinController.text),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
