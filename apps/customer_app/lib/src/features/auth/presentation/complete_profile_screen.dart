import 'package:cached_network_image/cached_network_image.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/auth_notifier.dart';
import '../../../core/router/app_router.dart';

/// A06 — Complete Profile Screen
/// Triggered after Google OAuth or Email signup when the user's phone number is missing.
class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final profile = ref.read(authNotifierProvider).profile;
    _nameController = TextEditingController(text: profile?.fullName ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final success = await ref.read(authNotifierProvider.notifier).completeProfile(
          phoneNumber: _phoneController.text.trim(),
          fullName: _nameController.text.trim(),
        );

    if (success && mounted) {
      context.go(AppRoutes.locationPermission);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final profile = authState.profile;
    final email = profile?.email ?? authState.pendingEmail ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: const GVTopBar(
        title: 'Complete Profile',
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(GVSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Almost There! ⚡',
                  style: GVTypography.h2.copyWith(
                    fontWeight: FontWeight.bold,
                    color: GVColors.textPrimary,
                  ),
                ),
                const SizedBox(height: GVSpacing.xs),
                Text(
                  'We need your contact phone number to coordinate pickups, dispatch drivers, and ensure safety.',
                  style: GVTypography.bodyMedium.copyWith(
                    color: GVColors.textSecondary,
                  ),
                ),
                const SizedBox(height: GVSpacing.xl),

                // Google Profile Preview Card
                Container(
                  padding: const EdgeInsets.all(GVSpacing.md),
                  decoration: BoxDecoration(
                    color: GVColors.softBackground,
                    borderRadius: BorderRadius.circular(GVBorderRadius.lg),
                    border: Border.all(color: GVColors.border),
                  ),
                  child: Row(
                    children: [
                      ClipOval(
                        child: Container(
                          width: 56,
                          height: 56,
                          color: GVColors.brandGreen.withValues(alpha: 0.15),
                          child: (profile?.avatarUrl != null &&
                                  profile!.avatarUrl!.isNotEmpty)
                              ? CachedNetworkImage(
                                  imageUrl: profile.avatarUrl!,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Center(
                                    child: Text(
                                      (profile.fullName.isNotEmpty
                                              ? profile.fullName[0]
                                              : 'U')
                                          .toUpperCase(),
                                      style: GVTypography.h3.copyWith(
                                        color: GVColors.brandGreen,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Center(
                                    child: Text(
                                      (profile.fullName.isNotEmpty
                                              ? profile.fullName[0]
                                              : 'U')
                                          .toUpperCase(),
                                      style: GVTypography.h3.copyWith(
                                        color: GVColors.brandGreen,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    (profile?.fullName.isNotEmpty == true
                                            ? profile!.fullName[0]
                                            : 'U')
                                        .toUpperCase(),
                                    style: GVTypography.h3.copyWith(
                                      color: GVColors.brandGreen,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: GVSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    profile?.fullName ?? 'Authenticated User',
                                    style: GVTypography.bodyMedium.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: GVColors.textPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: GVColors.brandGreen,
                                  size: 16,
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              email,
                              style: GVTypography.caption.copyWith(
                                color: GVColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
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

                // Full Name field
                GVFormField(
                  label: 'Full Name',
                  hint: 'Enter your legal full name',
                  controller: _nameController,
                  prefix: const Icon(Icons.person_outline_rounded),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: GVSpacing.lg),

                // Phone Number field (Required)
                GVFormField(
                  label: 'Phone Number (Required for Dispatch)',
                  hint: 'e.g. 08012345678',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  prefix: Container(
                    padding: const EdgeInsets.symmetric(horizontal: GVSpacing.sm),
                    margin: const EdgeInsets.only(right: GVSpacing.sm),
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(color: GVColors.border),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '🇳🇬 +234',
                          style: GVTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: GVColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Phone number is required for dispatch safety';
                    }
                    final cleaned = val.replaceAll(RegExp(r'[^0-9]'), '');
                    if (cleaned.length < 10) {
                      return 'Please enter a valid Nigerian phone number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: GVSpacing.xs),
                Text(
                  'Your phone number is protected under NDPR and used exclusively for driver communication and trip safety.',
                  style: GVTypography.caption.copyWith(
                    color: GVColors.textSecondary,
                  ),
                ),
                const SizedBox(height: GVSpacing.xl),

                // Submit button
                GVPrimaryButton(
                  label: 'Complete Profile & Continue',
                  isLoading: authState.isLoading,
                  onPressed: _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
