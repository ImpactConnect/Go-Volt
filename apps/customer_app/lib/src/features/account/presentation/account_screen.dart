import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/auth/auth_notifier.dart';
import '../application/profile_notifier.dart';

/// Screen A1: Go-Volts Customer Profile & Account Home (§A1 & Master Spec).
class AccountScreen extends ConsumerStatefulWidget {
  const AccountScreen({super.key});

  @override
  ConsumerState<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends ConsumerState<AccountScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final sessionProfile = ref.read(authNotifierProvider).profile;
      ref.read(profileNotifierProvider.notifier).loadProfile(
            userId: sessionProfile?.id,
            sessionProfile: sessionProfile,
          );
    });
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out of Go-Volts?'),
        content: const Text(
          'You will need to sign in with your phone number and password to access your bookings and wallet.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: GVColors.error,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) {
                context.go(AppRoutes.welcome);
              }
            },
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _showDeactivateDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete / Deactivate Account?'),
        content: const Text(
          'This action will permanently delete your account, saved destinations, and ride history under NDPR regulations. Unused wallet balances will require customer support review.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade800,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion request submitted for compliance verification.'),
                  backgroundColor: GVColors.error,
                ),
              );
            },
            child: const Text('Confirm Deletion'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileNotifierProvider);
    final authProfile = ref.watch(authNotifierProvider).profile;
    final user = profileState.profile ?? authProfile;

    final fullName = user?.fullName.isNotEmpty == true ? user!.fullName : 'Customer';
    final phone = user?.phoneNumber.isNotEmpty == true ? user!.phoneNumber : 'No phone registered';
    final carbon = user?.carbonAvoidedKg ?? 0.0;
    final verificationStatus = profileState.verification.status.label;

    return Scaffold(
      backgroundColor: GVColors.softBackground,
      appBar: const GVTopBar(title: 'Account & Settings'),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(GVSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // User Profile Hero Card (A1 Header)
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                boxShadow: GVShadows.card,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: GVColors.statusActiveBg,
                        child: Text(
                          fullName.isNotEmpty ? fullName[0].toUpperCase() : 'U',
                          style: GVTypography.h1.copyWith(
                            color: GVColors.brandGreen,
                            fontSize: 24,
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
                                    fullName,
                                    style: GVTypography.h3,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                InkWell(
                                  onTap: () => context.push(AppRoutes.accountVerification),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: profileState.verification.isVerified
                                          ? GVColors.statusActiveBg
                                          : Colors.amber.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      profileState.verification.isVerified ? 'Verified' : verificationStatus,
                                      style: GVTypography.caption.copyWith(
                                        color: profileState.verification.isVerified
                                            ? GVColors.brandGreen
                                            : Colors.amber.shade800,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(phone, style: GVTypography.bodySmall),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_outlined, color: GVColors.textSecondary),
                        onPressed: () => context.push(AppRoutes.editProfile),
                      ),
                    ],
                  ),
                  const Divider(height: GVSpacing.lg),

                  // Carbon Avoided Impact Bar
                  Container(
                    padding: const EdgeInsets.all(GVSpacing.sm),
                    decoration: BoxDecoration(
                      color: GVColors.statusActiveBg,
                      borderRadius: BorderRadius.circular(GVBorderRadius.sm),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.eco, color: GVColors.brandGreen, size: 24),
                        const SizedBox(width: GVSpacing.xs),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${carbon.toStringAsFixed(1)} kg CO₂ Emissions Avoided',
                                style: GVTypography.bodySmallMedium.copyWith(color: GVColors.deepGreen),
                              ),
                              Text(
                                carbon > 0
                                    ? 'From your completed clean electric trips in Lagos'
                                    : 'Take your first clean electric ride to start saving carbon!',
                                style: GVTypography.caption.copyWith(color: GVColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.md),

            // Account Information Section
            Text('Account Information', style: GVTypography.caption.copyWith(fontWeight: FontWeight.bold, color: GVColors.textSecondary)),
            const SizedBox(height: GVSpacing.xs),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(GVBorderRadius.md),
              clipBehavior: Clip.antiAlias,
              elevation: 1,
              shadowColor: Colors.black.withValues(alpha: 0.05),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.person_outline, color: GVColors.deepGreen),
                    title: Text('Personal Information', style: GVTypography.bodyMedium),
                    subtitle: const Text('Legal Name, Contact Details, KYC'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(AppRoutes.personalInfo),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.place_outlined, color: GVColors.deepGreen),
                    title: Text('Saved Places', style: GVTypography.bodyMedium),
                    subtitle: const Text('Home, Office, School'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(AppRoutes.savedPlaces),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.account_balance_wallet_outlined, color: GVColors.deepGreen),
                    title: Text('Wallet & Payments', style: GVTypography.bodyMedium),
                    subtitle: const Text('Paystack Cards, Transaction History'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(AppRoutes.walletPaymentMethods),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.md),

            // Preferences & Privacy Section
            Text('Preferences & Settings', style: GVTypography.caption.copyWith(fontWeight: FontWeight.bold, color: GVColors.textSecondary)),
            const SizedBox(height: GVSpacing.xs),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(GVBorderRadius.md),
              clipBehavior: Clip.antiAlias,
              elevation: 1,
              shadowColor: Colors.black.withValues(alpha: 0.05),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings_outlined, color: GVColors.deepGreen),
                    title: Text('Preferences & Privacy', style: GVTypography.bodyMedium),
                    subtitle: const Text('Language, Theme, Communication'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(AppRoutes.settings),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.notifications_none_rounded, color: GVColors.deepGreen),
                    title: Text('Notification Settings', style: GVTypography.bodyMedium),
                    subtitle: const Text('Ride, Parcel, Errand, Marketing'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(AppRoutes.notificationSettings),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.lock_outline_rounded, color: GVColors.deepGreen),
                    title: Text('Privacy & Security', style: GVTypography.bodyMedium),
                    subtitle: const Text('Password, Sessions, Telematics, Data Rights'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(AppRoutes.privacySecurity),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.md),

            // Safety & Support Section
            Text('Safety & Assistance', style: GVTypography.caption.copyWith(fontWeight: FontWeight.bold, color: GVColors.textSecondary)),
            const SizedBox(height: GVSpacing.xs),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(GVBorderRadius.md),
              clipBehavior: Clip.antiAlias,
              elevation: 1,
              shadowColor: Colors.black.withValues(alpha: 0.05),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.shield_outlined, color: GVColors.brandGreen),
                    title: Text('Safety Centre & Emergency SOS', style: GVTypography.bodyMedium),
                    subtitle: const Text('Contacts, Lagos 112/767, In-ride Audio'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(AppRoutes.safetyCentre),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.help_outline, color: GVColors.deepGreen),
                    title: Text('Help & Customer Support', style: GVTypography.bodyMedium),
                    subtitle: const Text('24/7 Operations Hotline, FAQs, Tickets'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(AppRoutes.support),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.description_outlined, color: GVColors.deepGreen),
                    title: Text('Terms & Privacy Policies', style: GVTypography.bodyMedium),
                    subtitle: const Text('Customer Terms, Minor Safety, SLAs'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Opening Go-Volts Terms & NDPR Privacy Policies.'),
                          backgroundColor: GVColors.deepGreen,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.lg),

            // Logout & Account Actions
            GVDestructiveButton(
              label: 'Log Out',
              onPressed: () => _showLogoutDialog(context),
            ),
            const SizedBox(height: GVSpacing.sm),

            Center(
              child: TextButton(
                onPressed: () => _showDeactivateDialog(context),
                child: Text(
                  'Delete or Deactivate Account',
                  style: TextStyle(color: Colors.red.shade700, fontSize: 13, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: GVSpacing.xs),

            Center(
              child: Text(
                'Go-Volts Customer App v1.0.0 (Build 2026.11)\nClean Electric Mobility • Lagos, Nigeria',
                textAlign: TextAlign.center,
                style: GVTypography.caption.copyWith(color: GVColors.textSecondary),
              ),
            ),
            const SizedBox(height: GVSpacing.md),
          ],
        ),
      ),
    ),
  );
  }
}
