import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Screen RD29: Driver Incentives, Referrals & More Features (Board 5 Screen 5).
class MoreFeaturesScreen extends ConsumerWidget {
  const MoreFeaturesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          'More',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(GVSpacing.md),
          children: [
            // Incentive Hero Banner
            Container(
              padding: const EdgeInsets.all(GVSpacing.lg),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [GVColors.deepGreen, Color(0xFF133B26)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(GVBorderRadius.lg),
                boxShadow: GVShadows.elevated,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.emoji_events, color: Colors.amber, size: 32),
                  ),
                  const SizedBox(width: GVSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Drive More, Earn More!',
                          style: GVTypography.h3.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Take advantage of bonuses, challenges and rewards.',
                          style: GVTypography.caption.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.lg),

            // Features List
            _buildFeatureTile(
              icon: Icons.flash_on,
              title: 'Promotions & Challenges',
              subtitle: 'View current incentives',
              onTap: () {},
            ),
            _buildFeatureTile(
              icon: Icons.person_add_alt_1,
              title: 'Refer a Driver',
              subtitle: 'Invite friends and earn rewards',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Referral link copied! Share with fellow drivers.')),
                );
              },
            ),
            _buildFeatureTile(
              icon: Icons.menu_book,
              title: 'Learning Center',
              subtitle: 'Tips to improve your earnings',
              onTap: () {},
            ),
            _buildFeatureTile(
              icon: Icons.shield_outlined,
              title: 'Safety Tips',
              subtitle: 'Stay safe on the road',
              onTap: () {},
            ),
            _buildFeatureTile(
              icon: Icons.rule,
              title: 'Community Guidelines',
              subtitle: 'Our rules and standards',
              onTap: () {},
            ),
            _buildFeatureTile(
              icon: Icons.star_border,
              title: 'Rate the App',
              subtitle: 'Share your feedback',
              onTap: () {},
            ),
            const SizedBox(height: GVSpacing.md),

            // Log Out Button
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1C2420),
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                border: Border.all(color: const Color(0xFF2A3630)),
              ),
              child: ListTile(
                leading: const Icon(Icons.logout, color: Colors.redAccent, size: 22),
                title: const Text(
                  'Log Out',
                  style: TextStyle(
                    color: Colors.redAccent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () {
                  showDialog<void>(
                    context: context,
                    builder: (dCtx) => AlertDialog(
                      backgroundColor: const Color(0xFF1C2420),
                      title: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                      content: const Text(
                        'Are you sure you want to log out of your driver account?',
                        style: TextStyle(color: Colors.white70),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dCtx).pop(),
                          child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                          onPressed: () {
                            Navigator.of(dCtx).pop();
                            context.go('/welcome');
                          },
                          child: const Text('Log Out', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: GVSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2420),
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        border: Border.all(color: const Color(0xFF2A3630)),
      ),
      child: ListTile(
        leading: Icon(icon, color: GVColors.brandGreen, size: 22),
        title: Text(
          title,
          style: GVTypography.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: GVTypography.caption.copyWith(color: Colors.white60),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white38, size: 20),
        onTap: onTap,
      ),
    );
  }
}
