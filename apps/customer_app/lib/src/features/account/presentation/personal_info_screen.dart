import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/auth/auth_notifier.dart';
import '../application/profile_notifier.dart';

/// Screen A3: Personal Information View with Data Privacy Masking (§A3).
class PersonalInfoScreen extends ConsumerWidget {
  const PersonalInfoScreen({super.key});

  String _maskPhone(String phone) {
    if (phone.length <= 6) return phone;
    final prefix = phone.substring(0, phone.length - 7);
    final suffix = phone.substring(phone.length - 4);
    return '$prefix *** $suffix';
  }

  String _maskEmail(String? email) {
    if (email == null || !email.contains('@')) return 'Not registered';
    final parts = email.split('@');
    final name = parts[0];
    final domain = parts[1];
    if (name.length <= 2) return '$name***@$domain';
    return '${name.substring(0, 2)}***@$domain';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileState = ref.watch(profileNotifierProvider);
    final authProfile = ref.watch(authNotifierProvider).profile;
    final user = profileState.profile ?? authProfile;

    final fullName = user?.fullName.isNotEmpty == true ? user!.fullName : 'Customer';
    final rawPhone = user?.phoneNumber.isNotEmpty == true ? user!.phoneNumber : 'Not registered';
    final maskedPhone = _maskPhone(rawPhone);
    final maskedEmail = _maskEmail(user?.email);
    final address = user?.currentAddress?.isNotEmpty == true ? user!.currentAddress! : 'Lagos, Nigeria';
    final state = user?.state ?? 'Lagos';
    final city = user?.city ?? 'Lagos Island';
    final gender = user?.gender ?? 'Prefer not to say';
    final memberSince = user?.createdAt != null
        ? '${user!.createdAt!.day}/${user.createdAt!.month}/${user.createdAt!.year}'
        : 'November 2026';

    return Scaffold(
      backgroundColor: GVColors.softBackground,
      appBar: const GVTopBar(title: 'Personal Information'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(GVSpacing.md),
          children: [
            // Informational Banner
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                boxShadow: GVShadows.card,
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, color: GVColors.brandGreen, size: 28),
                  const SizedBox(width: GVSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Privacy Protected', style: GVTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(
                          'Your contact identifiers are masked for security and compliant with Nigerian NDPR privacy standards.',
                          style: GVTypography.caption.copyWith(color: GVColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.md),

            // Profile Data Cards
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                boxShadow: GVShadows.card,
              ),
              child: Column(
                children: [
                  _buildDataRow(
                    label: 'Full Legal Name',
                    value: fullName,
                    icon: Icons.person_outline,
                  ),
                  const Divider(height: 1),
                  _buildDataRow(
                    label: 'Primary Phone Number',
                    value: maskedPhone,
                    icon: Icons.phone_outlined,
                    badge: 'Verified',
                  ),
                  const Divider(height: 1),
                  _buildDataRow(
                    label: 'Registered Email',
                    value: maskedEmail,
                    icon: Icons.email_outlined,
                  ),
                  const Divider(height: 1),
                  _buildDataRow(
                    label: 'Residential Address',
                    value: address,
                    icon: Icons.home_outlined,
                  ),
                  const Divider(height: 1),
                  _buildDataRow(
                    label: 'Location / State',
                    value: '$city, $state',
                    icon: Icons.location_on_outlined,
                  ),
                  const Divider(height: 1),
                  _buildDataRow(
                    label: 'Gender',
                    value: gender,
                    icon: Icons.wc_outlined,
                  ),
                  const Divider(height: 1),
                  _buildDataRow(
                    label: 'Member Since',
                    value: memberSince,
                    icon: Icons.calendar_today_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.lg),

            GVPrimaryButton(
              label: 'Edit Profile Information',
              onPressed: () => context.push(AppRoutes.editProfile),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataRow({
    required String label,
    required String value,
    required IconData icon,
    String? badge,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: GVSpacing.md, vertical: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: GVColors.deepGreen, size: 22),
          const SizedBox(width: GVSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GVTypography.caption.copyWith(color: GVColors.textSecondary)),
                const SizedBox(height: 2),
                Text(value, style: GVTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: GVColors.statusActiveBg,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                badge,
                style: const TextStyle(
                  color: GVColors.brandGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

