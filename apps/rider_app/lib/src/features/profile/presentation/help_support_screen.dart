import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Screen RD28: Driver Help & Support Center (Board 5 Screen 4).
class HelpSupportScreen extends ConsumerWidget {
  const HelpSupportScreen({super.key});

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
          'Help & Support',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(GVSpacing.md),
          children: [
            // Search Input
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search for help...',
                hintStyle: const TextStyle(color: Colors.white38),
                prefixIcon: const Icon(Icons.search, color: Colors.white60),
                filled: true,
                fillColor: const Color(0xFF1C2420),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  borderSide: const BorderSide(color: Color(0xFF2A3630)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  borderSide: const BorderSide(color: Color(0xFF2A3630)),
                ),
              ),
            ),
            const SizedBox(height: GVSpacing.lg),

            // Popular Topics Heading
            Text(
              'Popular Topics',
              style: GVTypography.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: GVSpacing.sm),

            // 4-Card Grid
            Row(
              children: [
                Expanded(
                  child: _buildTopicCard(
                    icon: Icons.directions_car_outlined,
                    title: 'Trip Issues',
                    subtitle: 'Pickup, drop-off or fare issues',
                  ),
                ),
                const SizedBox(width: GVSpacing.sm),
                Expanded(
                  child: _buildTopicCard(
                    icon: Icons.account_balance_wallet_outlined,
                    title: 'Earnings & Payments',
                    subtitle: 'Wallet, withdrawals and payouts',
                  ),
                ),
              ],
            ),
            const SizedBox(height: GVSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _buildTopicCard(
                    icon: Icons.description_outlined,
                    title: 'Account & Documents',
                    subtitle: 'Verification and document issues',
                  ),
                ),
                const SizedBox(width: GVSpacing.sm),
                Expanded(
                  child: _buildTopicCard(
                    icon: Icons.settings_suggest_outlined,
                    title: 'App & Technical',
                    subtitle: 'App errors and technical support',
                  ),
                ),
              ],
            ),
            const SizedBox(height: GVSpacing.xl),

            // Direct Contact Channels
            Text(
              'Contact Us',
              style: GVTypography.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: GVSpacing.sm),
            _buildContactTile(
              icon: Icons.headset_mic_outlined,
              title: 'Contact Support',
              subtitle: 'Chat with our support team',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Starting live chat session with Go-Volts Support...')),
                );
              },
            ),
            _buildContactTile(
              icon: Icons.phone_in_talk_outlined,
              title: 'Call Support',
              subtitle: '+234 700 123 4567',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Calling +234 700 123 4567...')),
                );
              },
            ),
            _buildContactTile(
              icon: Icons.mail_outline,
              title: 'Send an Email',
              subtitle: 'support@go-volts.com',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Email support: support@go-volts.com')),
                );
              },
            ),
            _buildContactTile(
              icon: Icons.help_outline,
              title: 'FAQs',
              subtitle: 'Find answers to common questions',
              onTap: () {},
            ),
            const SizedBox(height: GVSpacing.xl),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(GVSpacing.md),
      height: 120,
      decoration: BoxDecoration(
        color: const Color(0xFF1C2420),
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        border: Border.all(color: const Color(0xFF2A3630)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: GVColors.brandGreen, size: 24),
          const Spacer(),
          Text(
            title,
            style: GVTypography.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: GVTypography.caption.copyWith(
              color: Colors.white60,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTile({
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
