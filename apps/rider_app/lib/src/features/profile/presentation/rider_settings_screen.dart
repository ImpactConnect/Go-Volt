import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Screen RD27: Driver App Settings & Preferences (Board 5 Screen 3).
class RiderSettingsScreen extends ConsumerStatefulWidget {
  const RiderSettingsScreen({super.key});

  @override
  ConsumerState<RiderSettingsScreen> createState() => _RiderSettingsScreenState();
}

class _RiderSettingsScreenState extends ConsumerState<RiderSettingsScreen> {
  bool _notifications = true;
  bool _sound = true;
  bool _location = true;
  bool _biometric = true;
  bool _twoFactor = false;
  bool _appLock = false;

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
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(GVSpacing.md),
          children: [
            // App Preferences
            _buildSectionHeader('App Preferences'),
            _buildNavTile(
              icon: Icons.language,
              title: 'Language',
              trailingText: 'English',
              onTap: () {},
            ),
            _buildNavTile(
              icon: Icons.brightness_6,
              title: 'Theme',
              trailingText: 'System',
              onTap: () {},
            ),
            _buildSwitchTile(
              icon: Icons.notifications_none,
              title: 'Notifications',
              value: _notifications,
              onChanged: (val) => setState(() => _notifications = val),
            ),
            _buildSwitchTile(
              icon: Icons.volume_up_outlined,
              title: 'Sound',
              value: _sound,
              onChanged: (val) => setState(() => _sound = val),
            ),
            _buildSwitchTile(
              icon: Icons.location_on_outlined,
              title: 'Location Services',
              value: _location,
              onChanged: (val) => setState(() => _location = val),
            ),
            const SizedBox(height: GVSpacing.lg),

            // Privacy & Security
            _buildSectionHeader('Privacy & Security'),
            _buildNavTile(
              icon: Icons.lock_outline,
              title: 'Change Password',
              onTap: () {},
            ),
            _buildSwitchTile(
              icon: Icons.fingerprint,
              title: 'Biometric Login',
              value: _biometric,
              onChanged: (val) => setState(() => _biometric = val),
            ),
            _buildSwitchTile(
              icon: Icons.security,
              title: 'Two-Factor Authentication',
              value: _twoFactor,
              onChanged: (val) => setState(() => _twoFactor = val),
            ),
            _buildSwitchTile(
              icon: Icons.screen_lock_portrait,
              title: 'App Lock',
              value: _appLock,
              onChanged: (val) => setState(() => _appLock = val),
            ),
            const SizedBox(height: GVSpacing.lg),

            // Other
            _buildSectionHeader('Other'),
            _buildNavTile(
              icon: Icons.help_outline,
              title: 'Help & Support',
              onTap: () => context.push('/account/support'),
            ),
            _buildNavTile(
              icon: Icons.info_outline,
              title: 'About Go-Volts',
              trailingText: 'v1.0.0',
              onTap: () {},
            ),
            const SizedBox(height: GVSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: GVSpacing.xs, left: 4),
      child: Text(
        title,
        style: GVTypography.caption.copyWith(
          color: Colors.white60,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required String title,
    String? trailingText,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2420),
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        border: Border.all(color: const Color(0xFF2A3630)),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white70, size: 22),
        title: Text(
          title,
          style: GVTypography.bodyMedium.copyWith(color: Colors.white),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (trailingText != null) ...[
              Text(
                trailingText,
                style: GVTypography.caption.copyWith(color: Colors.white60),
              ),
              const SizedBox(width: 4),
            ],
            const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
          ],
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2420),
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        border: Border.all(color: const Color(0xFF2A3630)),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white70, size: 22),
        title: Text(
          title,
          style: GVTypography.bodyMedium.copyWith(color: Colors.white),
        ),
        trailing: Switch(
          value: value,
          activeThumbColor: GVColors.brandGreen,
          activeTrackColor: GVColors.deepGreen,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
