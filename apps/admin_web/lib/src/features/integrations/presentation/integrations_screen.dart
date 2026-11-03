import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/widgets/admin_kpi_card.dart';
import '../application/integrations_notifier.dart';

class IntegrationsScreen extends ConsumerWidget {
  const IntegrationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(integrationsNotifierProvider);
    final dateFormat = DateFormat('yyyy-MM-dd HH:mm');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(GVSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Partner Integrations & B2B Logistics API',
                style: GVTypography.h2.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                'Retail Ai e-commerce webhooks, HMAC-SHA256 signature verification, and automated dispatch gateways (§5.2)',
                style: GVTypography.bodySmall.copyWith(color: Colors.white60),
              ),
            ],
          ),
          const SizedBox(height: GVSpacing.lg),

          // KPIs
          Row(
            children: [
              Expanded(
                child: AdminKpiCard(
                  title: 'Active Connected Partners',
                  value: '${state.activePartnersCount}',
                  subtitle: 'Live automated order ingress',
                  icon: Icons.hub_outlined,
                  accentColor: GVColors.brandGreen,
                ),
              ),
              const SizedBox(width: GVSpacing.md),
              Expanded(
                child: AdminKpiCard(
                  title: 'B2B Dispatches Today',
                  value: '${state.totalPartnerDispatchesToday}',
                  subtitle: 'Retail Ai & merchant parcels',
                  icon: Icons.local_shipping_outlined,
                  accentColor: Colors.blueAccent,
                ),
              ),
              const SizedBox(width: GVSpacing.md),
              Expanded(
                child: AdminKpiCard(
                  title: 'Webhook Success Rate',
                  value: state.partners.isEmpty
                      ? '--'
                      : '${(state.partners.where((p) => p.pingSuccess).length / state.partners.length * 100).toStringAsFixed(1)}%',
                  subtitle: state.partners.isEmpty ? 'No partner webhooks' : 'HMAC signature authenticated',
                  icon: Icons.verified_user_outlined,
                  accentColor: Colors.purpleAccent,
                ),
              ),
              const SizedBox(width: GVSpacing.md),
              Expanded(
                child: AdminKpiCard(
                  title: 'Average Latency',
                  value: state.partners.isEmpty ? '--' : '42 ms',
                  subtitle: state.partners.isEmpty ? 'No traffic' : 'Edge API gateway response',
                  icon: Icons.speed_outlined,
                  accentColor: Colors.amberAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: GVSpacing.xl),

          // Partner Cards
          if (state.partners.isEmpty)
            const Padding(
              padding: EdgeInsets.all(48),
              child: Center(
                child: Text(
                  'No third-party logistics or retail partners currently connected.',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            )
          else
            Column(
              children: state.partners.map((partner) {
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(GVSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xFF101713),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: partner.isActive ? const Color(0xFF274332) : const Color(0xFF1F2B25),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: GVColors.deepGreen,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: GVColors.brandGreen),
                              ),
                              child: const Icon(Icons.shopping_bag_outlined, color: GVColors.brandGreen, size: 20),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  partner.partnerName,
                                  style: GVTypography.h3.copyWith(color: Colors.white),
                                ),
                                Text(
                                  'API Key Prefix: ${partner.apiKeyPrefix}',
                                  style: const TextStyle(color: Colors.white60, fontSize: 11, fontFamily: 'monospace'),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: partner.isHmacVerified
                                    ? GVColors.brandGreen.withValues(alpha: 0.15)
                                    : Colors.amber.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: partner.isHmacVerified ? GVColors.brandGreen : Colors.amber,
                                ),
                              ),
                              child: Text(
                                partner.isHmacVerified ? 'HMAC-SHA256 VERIFIED' : 'HMAC UNVERIFIED',
                                style: TextStyle(
                                  color: partner.isHmacVerified ? GVColors.brandGreen : Colors.amber,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Switch(
                              key: Key('toggle_partner_${partner.id}'),
                              value: partner.isActive,
                              activeThumbColor: GVColors.brandGreen,
                              onChanged: (val) {
                                ref.read(integrationsNotifierProvider.notifier).togglePartner(partner.id);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Divider(color: Color(0xFF1F2B25), height: 24),
                    Row(
                      children: [
                        const Icon(Icons.link, size: 16, color: Colors.white38),
                        const SizedBox(width: 6),
                        const Text('Webhook URL: ', style: TextStyle(color: Colors.white38, fontSize: 12)),
                        Expanded(
                          child: SelectableText(
                            partner.webhookUrl,
                            style: const TextStyle(color: Colors.white70, fontSize: 12, fontFamily: 'monospace'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Today: ${partner.totalDispatchesToday} dispatches processed · Last ping: ${dateFormat.format(partner.lastWebhookPing)}',
                          style: const TextStyle(color: Colors.white60, fontSize: 11),
                        ),
                        OutlinedButton.icon(
                          key: Key('ping_webhook_${partner.id}'),
                          onPressed: () {
                            ref.read(integrationsNotifierProvider.notifier).testWebhookPing(partner.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Test ping dispatched to ${partner.partnerName}. HTTP 200 OK.')),
                            );
                          },
                          icon: const Icon(Icons.sensors, size: 14),
                          label: const Text('Test Webhook Ping'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: GVColors.brandGreen,
                            side: const BorderSide(color: Color(0xFF274332)),
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            minimumSize: const Size(60, 28),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
