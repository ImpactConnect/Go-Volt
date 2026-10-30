import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Screen A15: Privacy, Security and Communication Preferences.
class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool _pushTripUpdates = true;
  bool _smsDispatchAlerts = true;
  bool _schoolRunSecurityAlerts = true;
  bool _marketingPromos = false;
  bool _shareAnonymousTelematics = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GVColors.darkBg,
      appBar: AppBar(
        title: const Text('Preferences & Privacy'),
        backgroundColor: GVColors.darkBg,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(GVSpacing.md),
          children: [
            // Section 1: Trip & Safety Notifications
            Text('Trip & Safety Notifications', style: GVTypography.h3.copyWith(color: Colors.white)),
            const SizedBox(height: GVSpacing.xs),
            _buildSwitchTile(
              title: 'Push Notifications for Live Trips',
              subtitle: 'Real-time arrival, driver approaching, and completed trip alerts.',
              value: _pushTripUpdates,
              onChanged: (val) => setState(() => _pushTripUpdates = val),
            ),
            _buildSwitchTile(
              title: 'SMS Dispatch Alerts',
              subtitle: 'Emergency SMS updates if mobile data is interrupted.',
              value: _smsDispatchAlerts,
              onChanged: (val) => setState(() => _smsDispatchAlerts = val),
            ),
            _buildSwitchTile(
              title: 'School-Run Handover Security Codes',
              subtitle: 'Instant transmission of single-use 6-digit verification codes.',
              value: _schoolRunSecurityAlerts,
              onChanged: (val) => setState(() => _schoolRunSecurityAlerts = val),
            ),
            const SizedBox(height: GVSpacing.lg),

            // Section 2: Marketing & Offers
            Text('Marketing & Rewards', style: GVTypography.h3.copyWith(color: Colors.white)),
            const SizedBox(height: GVSpacing.xs),
            _buildSwitchTile(
              title: 'Promotions & Green Volt Points',
              subtitle: 'Receive discount coupons, referral bonuses, and tier rewards.',
              value: _marketingPromos,
              onChanged: (val) => setState(() => _marketingPromos = val),
            ),
            const SizedBox(height: GVSpacing.lg),

            // Section 3: Privacy & Location
            Text('Privacy & Telematics', style: GVTypography.h3.copyWith(color: Colors.white)),
            const SizedBox(height: GVSpacing.xs),
            _buildSwitchTile(
              title: 'Anonymous Fleet Telematics',
              subtitle: 'Help optimize Lagos EV charging stations and battery swap kiosks.',
              value: _shareAnonymousTelematics,
              onChanged: (val) => setState(() => _shareAnonymousTelematics = val),
            ),
            const SizedBox(height: GVSpacing.lg),

            // Section 4: Data Rights & Account Management
            Text('Data Rights & Security', style: GVTypography.h3.copyWith(color: Colors.white)),
            const SizedBox(height: GVSpacing.xs),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1C2420),
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                border: Border.all(color: const Color(0xFF2A3630)),
              ),
              child: Material(
                color: Colors.transparent,
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.download, color: GVColors.brandGreen),
                      title: const Text('Export My Account Data', style: TextStyle(color: Colors.white, fontSize: 14)),
                      subtitle: const Text('Receive a full JSON/CSV export of your trips and receipts.',
                          style: TextStyle(color: Colors.white60, fontSize: 12)),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Data export request submitted. File will be sent to your email.'),
                            backgroundColor: GVColors.deepGreen,
                          ),
                        );
                      },
                    ),
                    const Divider(color: Colors.white24, height: 1),
                    ListTile(
                      leading: const Icon(Icons.delete_forever, color: Colors.redAccent),
                      title: const Text('Delete Account', style: TextStyle(color: Colors.redAccent, fontSize: 14)),
                      subtitle: const Text('Permanently erase account with a 30-day recovery window.',
                          style: TextStyle(color: Colors.white60, fontSize: 12)),
                      onTap: _showDeleteAccountDialog,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: GVSpacing.md, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2420),
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        border: Border.all(color: const Color(0xFF2A3630)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GVTypography.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle, style: GVTypography.caption.copyWith(color: Colors.white60)),
              ],
            ),
          ),
          Switch(
            value: value,
            activeThumbColor: GVColors.brandGreen,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1C2420),
        title: const Text('Delete Go-Volts Account?', style: TextStyle(color: Colors.redAccent)),
        content: const Text(
          'Your active subscriptions, wallet balance, and Green Volt points will be queued for permanent cancellation under Lagos regulatory data policies.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.of(dialogCtx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Account deletion requested. 30-day grace period active.'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            child: const Text('Confirm Deletion', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
