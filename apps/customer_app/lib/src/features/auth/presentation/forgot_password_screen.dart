import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// A06 — Forgot Password Screen
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _controller = TextEditingController();
  bool _submitted = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_controller.text.trim().isEmpty) return;

    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) {
      setState(() {
        _isLoading = false;
        _submitted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const GVTopBar(title: 'Reset Password'),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(GVSpacing.lg),
          child: _submitted ? _buildSuccessView() : _buildFormView(),
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Forgot Password?',
          style: GVTypography.h2.copyWith(
            fontWeight: FontWeight.bold,
            color: GVColors.textPrimary,
          ),
        ),
        const SizedBox(height: GVSpacing.xs),
        Text(
          'Enter your registered phone number or email address. We will send you instructions to reset your password.',
          style: GVTypography.bodyMedium.copyWith(
            color: GVColors.textSecondary,
          ),
        ),
        const SizedBox(height: GVSpacing.xl),
        GVFormField(
          label: 'Phone or Email',
          hint: 'e.g. 08012345678 or name@example.com',
          controller: _controller,
          prefix: const Icon(Icons.lock_reset_rounded),
        ),
        const SizedBox(height: GVSpacing.xl),
        GVPrimaryButton(
          label: 'Send Reset Instructions',
          isLoading: _isLoading,
          onPressed: _submit,
        ),
      ],
    );
  }

  Widget _buildSuccessView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(GVSpacing.lg),
            decoration: const BoxDecoration(
              color: GVColors.softBackground,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read_rounded,
              size: 64,
              color: GVColors.brandGreen,
            ),
          ),
          const SizedBox(height: GVSpacing.lg),
          Text(
            'Check Your Messages',
            style: GVTypography.h2.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: GVSpacing.sm),
          Text(
            'We have sent reset instructions to ${_controller.text.trim()}.',
            textAlign: TextAlign.center,
            style: GVTypography.bodyMedium.copyWith(
              color: GVColors.textSecondary,
            ),
          ),
          const SizedBox(height: GVSpacing.xl),
          GVPrimaryButton(
            label: 'Back to Sign In',
            onPressed: () => context.pop(),
          ),
        ],
      ),
    );
  }
}
