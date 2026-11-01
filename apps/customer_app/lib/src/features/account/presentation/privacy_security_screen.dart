import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/auth_notifier.dart';
import '../application/settings_notifier.dart';

/// Screen B5: Privacy Controls, Password & Device Session Management (§B5 & Master Spec).
class PrivacySecurityScreen extends ConsumerStatefulWidget {
  const PrivacySecurityScreen({super.key});

  @override
  ConsumerState<PrivacySecurityScreen> createState() => _PrivacySecurityScreenState();
}

class _PrivacySecurityScreenState extends ConsumerState<PrivacySecurityScreen> {
  void _showChangePasswordDialog() {
    final currentPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1C2420),
        title: const Text('Change Password', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPassController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Current Password',
                labelStyle: TextStyle(color: Colors.white60),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: newPassController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'New Password',
                labelStyle: TextStyle(color: Colors.white60),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: confirmPassController,
              obscureText: true,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Confirm New Password',
                labelStyle: TextStyle(color: Colors.white60),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: GVColors.brandGreen, foregroundColor: Colors.black),
            onPressed: () {
              if (newPassController.text.length < 6) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Password must be at least 6 characters.'), backgroundColor: GVColors.error),
                );
                return;
              }
              if (newPassController.text != confirmPassController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Passwords do not match.'), backgroundColor: GVColors.error),
                );
                return;
              }

              Navigator.pop(dialogCtx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Password changed successfully across active sessions.'),
                  backgroundColor: GVColors.deepGreen,
                ),
              );
            },
            child: const Text('Update Password'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsNotifierProvider);
    final user = ref.watch(authNotifierProvider).profile;

    return Scaffold(
      backgroundColor: GVColors.softBackground,
      appBar: const GVTopBar(title: 'Privacy & Security'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(GVSpacing.md),
          children: [
            // Security Section
            Text('Account Security', style: GVTypography.caption.copyWith(fontWeight: FontWeight.bold, color: GVColors.textSecondary)),
            const SizedBox(height: GVSpacing.xs),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(GVBorderRadius.md),
              elevation: 1,
              shadowColor: Colors.black.withValues(alpha: 0.05),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.key_rounded, color: GVColors.deepGreen),
                    title: const Text('Change Password', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Update login security password'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: _showChangePasswordDialog,
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.g_mobiledata_rounded, color: GVColors.deepGreen, size: 28),
                    title: const Text('Google Authentication', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(user?.email != null ? 'Connected: ${user!.email}' : 'Not linked'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: GVColors.statusActiveBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('ACTIVE', style: TextStyle(color: GVColors.brandGreen, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.md),

            // Active Devices / Sessions
            Text('Active Sessions & Devices', style: GVTypography.caption.copyWith(fontWeight: FontWeight.bold, color: GVColors.textSecondary)),
            const SizedBox(height: GVSpacing.xs),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(GVBorderRadius.md),
              elevation: 1,
              shadowColor: Colors.black.withValues(alpha: 0.05),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.phone_iphone_rounded, color: GVColors.brandGreen),
                    title: const Text('iPhone 18 Pro (This Device)', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Lagos, Nigeria • Active now'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: GVColors.statusActiveBg,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text('CURRENT', style: TextStyle(color: GVColors.brandGreen, fontSize: 11, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.laptop_mac_rounded, color: GVColors.textSecondary),
                    title: const Text('Web Dashboard Session', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Chrome on macOS • 2 days ago'),
                    trailing: TextButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Session revoked.'), backgroundColor: GVColors.deepGreen),
                        );
                      },
                      child: const Text('Log Out', style: TextStyle(color: Colors.red)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.md),

            // Privacy & Telematics
            Text('Privacy & Telematics', style: GVTypography.caption.copyWith(fontWeight: FontWeight.bold, color: GVColors.textSecondary)),
            const SizedBox(height: GVSpacing.xs),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(GVBorderRadius.md),
              elevation: 1,
              shadowColor: Colors.black.withValues(alpha: 0.05),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  SwitchListTile.adaptive(
                    activeTrackColor: GVColors.brandGreen,
                    secondary: const Icon(Icons.location_on_outlined, color: GVColors.deepGreen),
                    title: const Text('Precise GPS Dispatching', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Allow high-accuracy EV positioning during rides and deliveries'),
                    value: settings.locationPermissionsEnabled,
                    onChanged: (val) {
                      ref.read(settingsNotifierProvider.notifier).toggleLocationPermissions(val);
                    },
                  ),
                  const Divider(height: 1),
                  SwitchListTile.adaptive(
                    activeTrackColor: GVColors.brandGreen,
                    secondary: const Icon(Icons.speed_outlined, color: GVColors.deepGreen),
                    title: const Text('Anonymous Fleet Telematics', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Share anonymized travel telemetry to optimize Lagos solar swap kiosks'),
                    value: settings.anonymousTelematics,
                    onChanged: (val) {
                      ref.read(settingsNotifierProvider.notifier).toggleTelematics(val);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.md),

            // Data Rights & Export
            Text('Data Rights & Compliance', style: GVTypography.caption.copyWith(fontWeight: FontWeight.bold, color: GVColors.textSecondary)),
            const SizedBox(height: GVSpacing.xs),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(GVBorderRadius.md),
              elevation: 1,
              shadowColor: Colors.black.withValues(alpha: 0.05),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.download_rounded, color: GVColors.deepGreen),
                    title: const Text('Export My Account Data', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Receive a verified JSON/CSV export of your trips and receipts'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Data export request submitted. File link will be sent to your email.'),
                          backgroundColor: GVColors.deepGreen,
                        ),
                      );
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.privacy_tip_outlined, color: GVColors.deepGreen),
                    title: const Text('NDPR Compliance & Data Rights', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('View your legal rights under Nigerian Data Protection Regulation'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Go-Volts operates in full compliance with NDPR/NITDA.'), backgroundColor: GVColors.deepGreen),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
