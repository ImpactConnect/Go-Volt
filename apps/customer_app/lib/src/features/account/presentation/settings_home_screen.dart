import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';
import '../application/settings_notifier.dart';

/// Screen B1: Settings & Preferences Control Centre (§B1 & Master Spec).
class SettingsHomeScreen extends ConsumerWidget {
  const SettingsHomeScreen({super.key});

  void _showLanguagePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final currentLang = ref.watch(settingsNotifierProvider).language;
        final languages = ['English (Nigeria)', 'Yorùbá', 'Hausa', 'Igbo', 'Pidgin English'];

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Select App Language', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...languages.map(
                  (lang) => ListTile(
                    title: Text(lang),
                    trailing: currentLang == lang ? const Icon(Icons.check, color: GVColors.brandGreen) : null,
                    onTap: () {
                      ref.read(settingsNotifierProvider.notifier).setLanguage(lang);
                      Navigator.pop(ctx);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showAppearancePicker(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final currentTheme = ref.watch(settingsNotifierProvider).appearance;
        final themes = ['System Default', 'Light Theme', 'Dark Green Theme'];

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Choose Appearance', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...themes.map(
                  (theme) => ListTile(
                    title: Text(theme),
                    trailing: currentTheme == theme ? const Icon(Icons.check, color: GVColors.brandGreen) : null,
                    onTap: () {
                      ref.read(settingsNotifierProvider.notifier).setAppearance(theme);
                      Navigator.pop(ctx);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);

    return Scaffold(
      backgroundColor: GVColors.softBackground,
      appBar: const GVTopBar(title: 'Settings & Preferences'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(GVSpacing.md),
          children: [
            // Account Preferences
            Text('Account Preferences', style: GVTypography.caption.copyWith(fontWeight: FontWeight.bold, color: GVColors.textSecondary)),
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
                    leading: const Icon(Icons.notifications_none_rounded, color: GVColors.deepGreen),
                    title: Text('Notifications', style: GVTypography.bodyMedium),
                    subtitle: const Text('Manage alerts by service'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(AppRoutes.notificationSettings),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.place_outlined, color: GVColors.deepGreen),
                    title: Text('Saved Places', style: GVTypography.bodyMedium),
                    subtitle: const Text('Home, Office, School destinations'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(AppRoutes.savedPlaces),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.payment_outlined, color: GVColors.deepGreen),
                    title: Text('Payment Methods', style: GVTypography.bodyMedium),
                    subtitle: const Text('Paystack tokenized cards & virtual account'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(AppRoutes.walletPaymentMethods),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.md),

            // App Preferences
            Text('App Preferences', style: GVTypography.caption.copyWith(fontWeight: FontWeight.bold, color: GVColors.textSecondary)),
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
                    leading: const Icon(Icons.language_rounded, color: GVColors.deepGreen),
                    title: Text('Language', style: GVTypography.bodyMedium),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(settings.language, style: TextStyle(color: GVColors.brandGreen, fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: () => _showLanguagePicker(context, ref),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.palette_outlined, color: GVColors.deepGreen),
                    title: Text('Appearance', style: GVTypography.bodyMedium),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(settings.appearance, style: TextStyle(color: GVColors.brandGreen, fontSize: 13, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                    onTap: () => _showAppearancePicker(context, ref),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.cleaning_services_outlined, color: GVColors.deepGreen),
                    title: Text('Clear Local Cache', style: GVTypography.bodyMedium),
                    subtitle: const Text('Free up temporary image storage'),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('App cache cleared successfully.'),
                          backgroundColor: GVColors.deepGreen,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.md),

            // Privacy & Security
            Text('Privacy & Security', style: GVTypography.caption.copyWith(fontWeight: FontWeight.bold, color: GVColors.textSecondary)),
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
                    leading: const Icon(Icons.lock_outline_rounded, color: GVColors.deepGreen),
                    title: const Text('Password & Authentication', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Change password, Google auth status'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(AppRoutes.privacySecurity),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.devices_outlined, color: GVColors.deepGreen),
                    title: const Text('Active Sessions & Devices', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Manage logged in mobile devices'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(AppRoutes.privacySecurity),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.md),

            // Support Hub
            Text('Help & Safety', style: GVTypography.caption.copyWith(fontWeight: FontWeight.bold, color: GVColors.textSecondary)),
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
                    leading: const Icon(Icons.shield_outlined, color: GVColors.brandGreen),
                    title: const Text('Safety Centre', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('Lagos 112/767, Emergency Contacts'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(AppRoutes.safetyCentre),
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.help_outline, color: GVColors.deepGreen),
                    title: const Text('Help Centre', style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text('FAQs, Articles, Submit Ticket'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => context.push(AppRoutes.support),
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
