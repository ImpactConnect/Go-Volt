import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/onboarding_notifier.dart';

/// Screen RD02: Driver Registration / Account Creation (Board 1 Screen 2).
class RiderRegisterScreen extends ConsumerStatefulWidget {
  const RiderRegisterScreen({super.key});

  @override
  ConsumerState<RiderRegisterScreen> createState() =>
      _RiderRegisterScreenState();
}

class _RiderRegisterScreenState extends ConsumerState<RiderRegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    final state = ref.read(onboardingNotifierProvider);
    _nameController = TextEditingController(
      text: state.fullName.isNotEmpty ? state.fullName : 'Chinedu Okafor',
    );
    _phoneController = TextEditingController(
      text: state.phoneNumber.isNotEmpty
          ? state.phoneNumber
          : '0803 123 4567',
    );
    _emailController = TextEditingController(
      text: state.email.isNotEmpty
          ? state.email
          : 'chineduokafor@gmail.com',
    );
    _passwordController = TextEditingController(text: '••••••••');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleCreateAccount() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(onboardingNotifierProvider.notifier).updatePersonalDetails(
            fullName: _nameController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            email: _emailController.text.trim(),
            residentialAddress: 'Victoria Island, Lagos',
            lagosLga: 'Eti-Osa (VI / Lekki)',
            emergencyContactName: 'Amara Okafor',
            emergencyContactPhone: '0802 987 6543',
          );
      context.push('/onboarding/identity');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GVColors.darkBg,
      appBar: AppBar(
        backgroundColor: GVColors.darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: GVSpacing.sm),
                Text(
                  'Create Driver Account',
                  style: GVTypography.h2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: GVSpacing.xs),
                Text(
                  'Enter your details to continue',
                  style: GVTypography.bodyMedium.copyWith(color: Colors.white60),
                ),
                const SizedBox(height: GVSpacing.xl),

                // Full Name
                _buildFieldLabel('Full Name'),
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration(
                    hint: 'e.g. Chinedu Okafor',
                    prefixIcon: Icons.person_outline,
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Full name is required' : null,
                ),
                const SizedBox(height: GVSpacing.md),

                // Phone Number
                _buildFieldLabel('Phone Number'),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration(
                    hint: '0803 123 4567',
                    prefixIcon: Icons.phone_outlined,
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Phone number is required' : null,
                ),
                const SizedBox(height: GVSpacing.md),

                // Email Address
                _buildFieldLabel('Email Address'),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration(
                    hint: 'chineduokafor@gmail.com',
                    prefixIcon: Icons.email_outlined,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: GVSpacing.md),

                // Set Password
                _buildFieldLabel('Set Password'),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  style: const TextStyle(color: Colors.white),
                  decoration: _buildInputDecoration(
                    hint: '••••••••',
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                        color: Colors.white60,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                ),
                const SizedBox(height: GVSpacing.xl),

                // Primary CTA
                GVPrimaryButton(
                  label: 'Create Account',
                  onPressed: _handleCreateAccount,
                ),
                const SizedBox(height: GVSpacing.lg),

                // Social Auth Divider
                Row(
                  children: [
                    const Expanded(child: Divider(color: Colors.white24)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'or continue with',
                        style: GVTypography.caption.copyWith(color: Colors.white54),
                      ),
                    ),
                    const Expanded(child: Divider(color: Colors.white24)),
                  ],
                ),
                const SizedBox(height: GVSpacing.md),

                // Google & Apple Buttons
                _buildSocialButton(
                  icon: Icons.g_mobiledata,
                  label: 'Continue with Google',
                  onTap: () => _handleCreateAccount(),
                ),
                const SizedBox(height: GVSpacing.sm),
                _buildSocialButton(
                  icon: Icons.apple,
                  label: 'Continue with Apple',
                  onTap: () => _handleCreateAccount(),
                ),
                const SizedBox(height: GVSpacing.xl),

                // Footer Log In Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Already have an account? ',
                      style: GVTypography.caption.copyWith(color: Colors.white70),
                    ),
                    InkWell(
                      onTap: () => context.push('/home'),
                      child: Text(
                        'Log In',
                        style: GVTypography.caption.copyWith(
                          color: GVColors.brandGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: GVSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: GVTypography.caption.copyWith(
          color: Colors.white70,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hint,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      prefixIcon: Icon(prefixIcon, color: Colors.white60, size: 20),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFF1C2420),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        borderSide: const BorderSide(color: Color(0xFF2A3630)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        borderSide: const BorderSide(color: Color(0xFF2A3630)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        borderSide: const BorderSide(color: GVColors.brandGreen, width: 1.5),
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GVBorderRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF1C2420),
          borderRadius: BorderRadius.circular(GVBorderRadius.md),
          border: Border.all(color: const Color(0xFF2A3630)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 22),
            const SizedBox(width: 8),
            Text(
              label,
              style: GVTypography.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
