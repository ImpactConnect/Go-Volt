import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../../../core/auth/auth_notifier.dart';

/// Screen A10: Go-Volts Customer Account, Safety Settings & Profile.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);
    final user = authState.profile;
    final fullName = user?.fullName.isNotEmpty == true ? user!.fullName : 'Customer';
    final phone = user?.phoneNumber.isNotEmpty == true ? user!.phoneNumber : 'No phone registered';
    final carbon = user?.carbonAvoidedKg ?? 0.0;

    return Scaffold(
      backgroundColor: GVColors.softBackground,
      appBar: const GVTopBar(title: 'Account & Settings'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(GVSpacing.md),
          children: [
            // User Profile Hero Card
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
                          fullName.isNotEmpty ? fullName[0] : 'U',
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
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: GVColors.statusActiveBg,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Verified',
                                    style: GVTypography.caption.copyWith(
                                      color: GVColors.brandGreen,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
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
                        icon: const Icon(Icons.edit_outlined,
                            color: GVColors.textSecondary),
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
                        const Icon(Icons.eco,
                            color: GVColors.brandGreen, size: 24),
                        const SizedBox(width: GVSpacing.xs),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${carbon.toStringAsFixed(1)} kg CO₂ Emissions Avoided',
                                style: GVTypography.bodySmallMedium
                                    .copyWith(color: GVColors.deepGreen),
                              ),
                              Text(
                                carbon > 0
                                    ? 'From your completed clean electric trips in Lagos'
                                    : 'Take your first clean electric ride to start saving carbon!',
                                style: GVTypography.caption
                                    .copyWith(color: GVColors.textSecondary),
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

            // Navigation Sections
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(GVBorderRadius.md),
              clipBehavior: Clip.antiAlias,
              elevation: 1,
              shadowColor: Colors.black.withValues(alpha: 0.05),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.place_outlined,
                        color: GVColors.deepGreen),
                    title: Text('Saved Places', style: GVTypography.bodyMedium),
                    subtitle: const Text('Home, Office, School'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(AppRoutes.savedPlaces),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.account_balance_wallet_outlined,
                        color: GVColors.deepGreen),
                    title: Text('Wallet & Payments',
                        style: GVTypography.bodyMedium),
                    subtitle: const Text('Paystack Cards, Transaction History'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(AppRoutes.wallet),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.shield_outlined,
                        color: GVColors.brandGreen),
                    title: Text('Safety Centre & Emergency SOS',
                        style: GVTypography.bodyMedium),
                    subtitle: const Text('Contacts, Lagos 112/767, In-ride Audio'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Safety Centre: Audio recording active during rides.'),
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.help_outline,
                        color: GVColors.deepGreen),
                    title: Text('Help & Customer Support',
                        style: GVTypography.bodyMedium),
                    subtitle: const Text('24/7 Operations Hotline, FAQs, Tickets'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(AppRoutes.support),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.settings_outlined,
                        color: GVColors.deepGreen),
                    title: Text('Preferences & Privacy',
                        style: GVTypography.bodyMedium),
                    subtitle: const Text('Notifications, Telematics, Data Rights'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(AppRoutes.preferences),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.description_outlined,
                        color: GVColors.deepGreen),
                    title: Text('Terms & Privacy Policies',
                        style: GVTypography.bodyMedium),
                    subtitle: const Text('Customer Terms, Minor Safety, SLAs'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.lg),

            // Logout Button
            GVDestructiveButton(
              label: 'Log Out',
              onPressed: () => _showLogoutDialog(context, ref),
            ),
            const SizedBox(height: GVSpacing.md),

            Center(
              child: Text(
                'Go-Volts Customer App v1.0.0 (Build 2026.10)\nClean Electric Mobility • Lagos, Nigeria',
                textAlign: TextAlign.center,
                style: GVTypography.caption
                    .copyWith(color: GVColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
