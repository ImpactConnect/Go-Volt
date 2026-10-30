import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:design_system/design_system.dart';
import '../../../core/widgets/merchant_kpi_card.dart';
import '../../../core/widgets/merchant_modal_dialog.dart';
import '../application/partner_api_notifier.dart';
import '../domain/partner_api_models.dart';

class DeveloperApiScreen extends ConsumerStatefulWidget {
  const DeveloperApiScreen({super.key});

  @override
  ConsumerState<DeveloperApiScreen> createState() => _DeveloperApiScreenState();
}

class _DeveloperApiScreenState extends ConsumerState<DeveloperApiScreen> {
  bool _secretRevealed = false;

  void _copyToClipboard(BuildContext context, String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard!'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showWebhookPayloadDialog(BuildContext context, WebhookEventDelivery log) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        final encoder = const JsonEncoder.withIndent('  ');
        final prettyJson = encoder.convert(log.payload);

        return MerchantModalDialog(
          title: 'Webhook Event: ${log.eventType}',
          maxWidth: 620,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMetaRow('Event ID:', log.eventId),
              _buildMetaRow('Endpoint:', log.endpointUrl),
              _buildMetaRow(
                'Timestamp:',
                DateFormat('yyyy-MM-dd HH:mm:ss').format(log.timestamp),
              ),
              _buildMetaRow('Signature Header:', log.signatureHeader),
              const SizedBox(height: 12),
              const Text(
                'RAW PAYLOAD (JSON)',
                style: TextStyle(
                  color: GVColors.neutral400,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: GVColors.neutral950,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: GVColors.neutral800),
                ),
                child: SelectableText(
                  prettyJson,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    color: GVColors.voltGreen,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildMetaRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                color: GVColors.neutral400,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(
                color: GVColors.neutral100,
                fontSize: 12,
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final devState = ref.watch(partnerApiNotifierProvider);
    final notifier = ref.read(partnerApiNotifierProvider.notifier);
    final whConfig = devState.webhookConfig;
    final keys = devState.apiKeys;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner for alerts/success
          if (devState.successMessage != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: GVColors.voltGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: GVColors.voltGreen),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    color: GVColors.voltGreen,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      devState.successMessage!,
                      style: const TextStyle(
                        color: GVColors.voltGreen,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: GVColors.voltGreen,
                      size: 16,
                    ),
                    onPressed: () => notifier.clearMessages(),
                  ),
                ],
              ),
            ),
          ],

          // Title & Action Header
          LayoutBuilder(
            builder: (context, constraints) {
              final isNarrow = constraints.maxWidth < 650;
              final headerContent = [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Partner API & Webhooks',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: GVColors.neutral100,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'B2B REST endpoints, Idempotency-Key guarantees & HMAC-SHA256 signed webhooks',
                      style: TextStyle(
                        color: GVColors.neutral400,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Opening OpenAPI 3.0 /partner/v1 specification...',
                            ),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                      icon: const Icon(Icons.menu_book_rounded, size: 16),
                      label: const Text('API Reference'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: GVColors.neutral200,
                        side: const BorderSide(color: GVColors.neutral700),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: devState.isLoading
                          ? null
                          : () => notifier.sendTestWebhookPing(),
                      icon: devState.isLoading
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: GVColors.neutral900,
                              ),
                            )
                          : const Icon(Icons.send_rounded, size: 16),
                      label: const Text('Send Test Webhook'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GVColors.voltGreen,
                        foregroundColor: GVColors.neutral900,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ];

              return isNarrow
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        headerContent[0],
                        const SizedBox(height: 12),
                        headerContent[1],
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        headerContent[0],
                        headerContent[1],
                      ],
                    );
            },
          ),
          const SizedBox(height: 20),

          // Quick Metrics
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final crossAxisCount = width > 1000
                  ? 4
                  : width > 650
                      ? 2
                      : 1;

              final kpiCards = [
                MerchantKpiCard(
                  title: 'Active API Keys',
                  value: '${keys.where((k) => k.isActive).length} Keys',
                  subtitle: 'Production & Sandbox credentials',
                  icon: Icons.vpn_key_rounded,
                  iconColor: GVColors.voltGreen,
                ),
                MerchantKpiCard(
                  title: 'Webhook Deliveries',
                  value: '${devState.webhookLogs.length} Events',
                  subtitle: '100% 200 OK delivery rate',
                  icon: Icons.webhook_rounded,
                  iconColor: GVColors.electricBlue,
                ),
                const MerchantKpiCard(
                  title: 'Average Latency',
                  value: '112 ms',
                  subtitle: 'Lagos IXPN edge responses',
                  icon: Icons.speed_rounded,
                  iconColor: GVColors.warningOrange,
                ),
                const MerchantKpiCard(
                  title: 'Idempotency Cache',
                  value: 'Guaranteed',
                  subtitle: 'Zero duplicate dispatches on retry',
                  icon: Icons.security_rounded,
                  iconColor: GVColors.deepPurple,
                ),
              ];

              return GridView.count(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: crossAxisCount == 4
                    ? 1.8
                    : crossAxisCount == 2
                        ? 2.2
                        : 2.8,
                children: kpiCards,
              );
            },
          ),
          const SizedBox(height: 28),

          // API Keys Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: GVColors.neutral900,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GVColors.neutral800),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Partner API Keys',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: GVColors.neutral100,
                      ),
                    ),
                    Text(
                      'HTTP Bearer Auth',
                      style: TextStyle(
                        fontSize: 12,
                        color: GVColors.neutral400,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...keys.map((key) {
                  final isProd = key.environment == 'Production';
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: GVColors.neutral800.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: GVColors.neutral700),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isProd
                                ? GVColors.voltGreen.withValues(alpha: 0.15)
                                : GVColors.electricBlue.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            key.environment.toUpperCase(),
                            style: TextStyle(
                              color: isProd
                                  ? GVColors.voltGreen
                                  : GVColors.electricBlue,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                key.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: GVColors.neutral100,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                key.keyPrefix,
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  color: GVColors.neutral400,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.copy_rounded,
                            size: 18,
                            color: GVColors.neutral300,
                          ),
                          tooltip: 'Copy API Secret',
                          onPressed: () => _copyToClipboard(
                            context,
                            key.fullSecret,
                            'API Secret Key',
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: GVColors.neutral950,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: GVColors.neutral800),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'REQUIRED DISPATCH HEADERS',
                        style: TextStyle(
                          color: GVColors.neutral400,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 6),
                      Text(
                        'Authorization: Bearer volt_live_49f8...\n'
                        'Idempotency-Key: <unique_uuid_v4>\n'
                        'X-External-Reference: <your_pos_order_id>\n'
                        'X-GoVolts-Branch-Id: <branch_uuid>',
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: GVColors.neutral300,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Webhook Endpoint & Security Section
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: GVColors.neutral900,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GVColors.neutral800),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Outbound Webhook Configuration',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: GVColors.neutral100,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Signed events dispatched for dispatch lifecycle transitions',
                          style: TextStyle(
                            fontSize: 12,
                            color: GVColors.neutral400,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: whConfig.isActive
                            ? GVColors.voltGreen.withValues(alpha: 0.15)
                            : GVColors.neutral800,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        whConfig.isActive ? 'ACTIVE' : 'DISABLED',
                        style: TextStyle(
                          color: whConfig.isActive
                              ? GVColors.voltGreen
                              : GVColors.neutral400,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'ENDPOINT DESTINATION URL',
                  style: TextStyle(
                    color: GVColors.neutral400,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: GVColors.neutral800,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: GVColors.neutral700),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.link_rounded,
                        size: 18,
                        color: GVColors.voltGreen,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: SelectableText(
                          whConfig.url,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            color: GVColors.neutral100,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.copy_rounded,
                          size: 16,
                          color: GVColors.neutral400,
                        ),
                        onPressed: () => _copyToClipboard(
                          context,
                          whConfig.url,
                          'Webhook URL',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'HMAC-SHA256 SIGNING SECRET',
                  style: TextStyle(
                    color: GVColors.neutral400,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: GVColors.neutral800,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: GVColors.neutral700),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.key_rounded,
                        size: 18,
                        color: GVColors.warningOrange,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _secretRevealed
                              ? whConfig.secret
                              : '••••••••••••••••••••••••••••••••••••',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            color: GVColors.neutral100,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          _secretRevealed
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          size: 16,
                          color: GVColors.neutral400,
                        ),
                        onPressed: () {
                          setState(() {
                            _secretRevealed = !_secretRevealed;
                          });
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.copy_rounded,
                          size: 16,
                          color: GVColors.neutral400,
                        ),
                        onPressed: () => _copyToClipboard(
                          context,
                          whConfig.secret,
                          'Webhook Signing Secret',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'SUBSCRIBED TOPICS',
                  style: TextStyle(
                    color: GVColors.neutral400,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: whConfig.subscribedEvents.map((event) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: GVColors.neutral800,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: GVColors.neutral700),
                      ),
                      child: Text(
                        event,
                        style: const TextStyle(
                          color: GVColors.voltGreen,
                          fontSize: 12,
                          fontFamily: 'monospace',
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Webhook Delivery Logs Table
          Container(
            decoration: BoxDecoration(
              color: GVColors.neutral900,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: GVColors.neutral800),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recent Webhook Deliveries',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: GVColors.neutral100,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Real-time inspection of dispatched lifecycle payloads & HMAC signatures',
                            style: TextStyle(
                              fontSize: 12,
                              color: GVColors.neutral400,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: GVColors.neutral800,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '${devState.webhookLogs.length} Dispatched',
                          style: const TextStyle(
                            fontSize: 11,
                            color: GVColors.neutral300,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1, color: GVColors.neutral800),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(
                      GVColors.neutral800.withValues(alpha: 0.5),
                    ),
                    dataRowColor: WidgetStateProperty.resolveWith(
                      (states) => GVColors.neutral900,
                    ),
                    columns: const [
                      DataColumn(
                        label: Text(
                          'EVENT TYPE',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: GVColors.neutral400,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'EXTERNAL REF',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: GVColors.neutral400,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'STATUS',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: GVColors.neutral400,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'LATENCY',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: GVColors.neutral400,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'TIMESTAMP',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: GVColors.neutral400,
                          ),
                        ),
                      ),
                      DataColumn(
                        label: Text(
                          'PAYLOAD',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: GVColors.neutral400,
                          ),
                        ),
                      ),
                    ],
                    rows: devState.webhookLogs.map((log) {
                      return DataRow(
                        cells: [
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: GVColors.voltGreen.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                log.eventType,
                                style: const TextStyle(
                                  color: GVColors.voltGreen,
                                  fontSize: 11,
                                  fontFamily: 'monospace',
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              log.externalReference ?? '-',
                              style: const TextStyle(
                                color: GVColors.neutral200,
                                fontSize: 12,
                                fontFamily: 'monospace',
                              ),
                            ),
                          ),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: GVColors.voltGreen.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${log.httpStatusCode} OK',
                                style: const TextStyle(
                                  color: GVColors.voltGreen,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              '${log.durationMs}ms',
                              style: const TextStyle(
                                color: GVColors.neutral400,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          DataCell(
                            Text(
                              DateFormat('MMM dd, HH:mm:ss')
                                  .format(log.timestamp),
                              style: const TextStyle(
                                color: GVColors.neutral400,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          DataCell(
                            TextButton.icon(
                              onPressed: () =>
                                  _showWebhookPayloadDialog(context, log),
                              icon: const Icon(
                                Icons.data_object_rounded,
                                size: 14,
                                color: GVColors.voltGreen,
                              ),
                              label: const Text(
                                'Inspect',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: GVColors.voltGreen,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                minimumSize: Size.zero,
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
