import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Screen RD25: Rider Profile, Certifications, Document Validity & Safety SOS.
class RiderProfileScreen extends StatelessWidget {
  const RiderProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GVColors.darkBg,
      appBar: AppBar(
        title: const Text('Rider Profile'),
        backgroundColor: GVColors.darkBg,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(GVSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            // Profile Card
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2420),
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                border: Border.all(color: const Color(0xFF2A3630)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: GVColors.deepGreen,
                    child: Text(
                      'BO',
                      style: GVTypography.h2.copyWith(color: GVColors.brandGreen),
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
                                'Babajide Ogundipe',
                                style: GVTypography.h3.copyWith(color: Colors.white),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            const Icon(Icons.verified,
                                color: GVColors.brandGreen, size: 18),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '+234 803 112 2334 · ID: RDR-2026-1082',
                          style: GVTypography.caption.copyWith(color: Colors.white60),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: GVSpacing.xs),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber, size: 16),
                            const SizedBox(width: 2),
                            Text(
                              '4.96 Rating',
                              style: GVTypography.caption.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(width: GVSpacing.sm),
                            Expanded(
                              child: Text(
                                '· 428 Trips Completed',
                                style: GVTypography.caption.copyWith(
                                  color: Colors.white60,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.lg),

            // Account & Fleet Features (Flow E Screen 1)
            Text(
              'Account & Fleet Features',
              style: GVTypography.h3.copyWith(color: Colors.white),
            ),
            const SizedBox(height: GVSpacing.xs),
            _buildNavMenuTile(
              icon: Icons.folder_shared_outlined,
              title: 'Driver Documents & KYC',
              subtitle: 'National ID, Driver License, Vehicle MOT',
              onTap: () => context.push('/account/documents'),
            ),
            _buildNavMenuTile(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Wallet & Payouts',
              subtitle: 'Manage bank accounts and instant withdrawals',
              onTap: () => context.push('/wallet'),
            ),
            _buildNavMenuTile(
              icon: Icons.bolt,
              title: 'Battery Swap Hubs',
              subtitle: 'Find and reserve charged battery packs',
              onTap: () => context.push('/swaps'),
            ),
            _buildNavMenuTile(
              icon: Icons.settings_outlined,
              title: 'App Settings & Security',
              subtitle: 'Biometrics, 2FA, Dark theme, Speed limit',
              onTap: () => context.push('/account/settings'),
            ),
            _buildNavMenuTile(
              icon: Icons.help_outline,
              title: 'Help & Support Center',
              subtitle: 'Live chat, hotline, FAQs, emergency guide',
              onTap: () => context.push('/account/support'),
            ),
            _buildNavMenuTile(
              icon: Icons.explore_outlined,
              title: 'More Features & Referrals',
              subtitle: 'Refer a driver, fuel savings, safety tips',
              onTap: () => context.push('/account/more'),
            ),
            const SizedBox(height: GVSpacing.lg),

            // Certifications
            Text(
              'Active Fleet Certifications',
              style: GVTypography.h3.copyWith(color: Colors.white),
            ),
            const SizedBox(height: GVSpacing.xs),
            _buildCertTile(
              title: 'Parcel Delivery Certification',
              status: 'ACTIVE',
              icon: Icons.local_shipping,
            ),
            _buildCertTile(
              title: 'Passenger EV Commute License',
              status: 'VERIFIED',
              icon: Icons.two_wheeler,
            ),
            _buildCertTile(
              title: 'School-Run Chaperone Security Badge',
              status: 'VETTED',
              icon: Icons.school,
            ),
            const SizedBox(height: GVSpacing.lg),

            // Regulatory Documents
            Text(
              'Compliance Documents',
              style: GVTypography.h3.copyWith(color: Colors.white),
            ),
            const SizedBox(height: GVSpacing.xs),
            _buildDocStatus(
              'National ID (NIN)',
              'Expires in 1,200 days',
              Icons.check_circle,
              GVColors.brandGreen,
            ),
            _buildDocStatus(
              'Lagos Driver\'s License',
              'Expires in 420 days',
              Icons.check_circle,
              GVColors.brandGreen,
            ),
            _buildDocStatus(
              'Vehicle Registration & MOT',
              'Expires in 310 days',
              Icons.check_circle,
              GVColors.brandGreen,
            ),
            const SizedBox(height: GVSpacing.lg),

            // Safety & Support
            Text(
              'Safety & Assistance',
              style: GVTypography.h3.copyWith(color: Colors.white),
            ),
            const SizedBox(height: GVSpacing.xs),
            ListTile(
              tileColor: const Color(0xFF1C2420),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                side: const BorderSide(color: Color(0xFF2A3630)),
              ),
              leading: const Icon(Icons.sos, color: Colors.redAccent, size: 28),
              title: Text(
                'Emergency SOS & Incident Response',
                style: GVTypography.bodyMedium.copyWith(color: Colors.white),
              ),
              subtitle: Text(
                'Instant dispatch alert to Lagos Police & MOT',
                style: GVTypography.caption.copyWith(color: Colors.white60),
              ),
              onTap: () => _showSosDialog(context),
            ),
            const SizedBox(height: GVSpacing.sm),
            ListTile(
              tileColor: const Color(0xFF1C2420),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                side: const BorderSide(color: Color(0xFF2A3630)),
              ),
              leading: const Icon(Icons.help_center, color: GVColors.brandGreen),
              title: Text(
                'Fleet Support & Payout Disputes',
                style: GVTypography.bodyMedium.copyWith(color: Colors.white),
              ),
              subtitle: Text(
                'Toll-free rider assistance: +234 1 800 4686',
                style: GVTypography.caption.copyWith(color: Colors.white60),
              ),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Support line: +234 1 800 4686 (Go-Volts Ops)'),
                  ),
                );
              },
            ),
            const SizedBox(height: GVSpacing.lg),

            // Logout
            GVSecondaryButton(
              label: 'Sign Out of Rider Account',
              onPressed: () => _handleSignOut(context),
            ),
          ],
        ),
      ),
    ),
  );
  }

  void _showSosDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1C2420),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.redAccent),
            SizedBox(width: 8),
            Text('EMERGENCY SOS', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Triggering SOS will transmit your live telematics coordinates to Go-Volts Emergency Dispatch, Lagos State Command (112), and LASTMA MOT (767).',
              style: TextStyle(color: Colors.white70),
            ),
            SizedBox(height: 12),
            Text(
              'Emergency Hotlines:\n• Lagos Police & Ambulance: 112\n• LASTMA & MOT Emergency: 767',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
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
                  content: Text('SOS Alert Broadcast! Operations unit is monitoring your beacon.'),
                  backgroundColor: Colors.redAccent,
                  duration: Duration(seconds: 4),
                ),
              );
            },
            child: const Text('BROADCAST SOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void _handleSignOut(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1C2420),
        title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to go offline and sign out of your Go-Volts Rider account?',
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
              try {
                context.go('/welcome');
              } catch (_) {
                if (Navigator.of(context).canPop()) {
                  Navigator.of(context).pop();
                }
              }
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  static Widget _buildCertTile({
    required String title,
    required String status,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: GVSpacing.md, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2420),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2A3630)),
      ),
      child: Row(
        children: [
          Icon(icon, color: GVColors.brandGreen, size: 20),
          const SizedBox(width: GVSpacing.xs),
          Expanded(
            child: Text(
              title,
              style: GVTypography.bodyMedium.copyWith(color: Colors.white),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          GVStatusChip(label: status, status: GVStatusType.active),
        ],
      ),
    );
  }

  static Widget _buildDocStatus(
    String name,
    String validity,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: GVSpacing.md, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2420),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF2A3630)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: GVSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: GVTypography.bodyMedium.copyWith(color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  validity,
                  style: GVTypography.caption.copyWith(color: Colors.white54),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Text('VALID',
              style: TextStyle(
                  color: GVColors.brandGreen,
                  fontSize: 11,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildNavMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: GVSpacing.sm),
      child: ListTile(
        tileColor: const Color(0xFF1C2420),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GVBorderRadius.md),
          side: const BorderSide(color: Color(0xFF2A3630)),
        ),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: GVColors.deepGreen.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: GVColors.brandGreen, size: 20),
        ),
        title: Text(
          title,
          style: GVTypography.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GVTypography.caption.copyWith(color: Colors.white60),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.white54),
        onTap: onTap,
      ),
    );
  }
}
