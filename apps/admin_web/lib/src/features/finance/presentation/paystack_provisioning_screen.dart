import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/admin_kpi_card.dart';
import '../application/paystack_provisioning_notifier.dart';

class PaystackProvisioningScreen extends ConsumerStatefulWidget {
  const PaystackProvisioningScreen({super.key});

  @override
  ConsumerState<PaystackProvisioningScreen> createState() =>
      _PaystackProvisioningScreenState();
}

class _PaystackProvisioningScreenState
    extends ConsumerState<PaystackProvisioningScreen> {
  final _publicKeyController = TextEditingController();
  final _secretKeyController = TextEditingController();
  final _webhookSecretController = TextEditingController();
  final _merchantEmailController = TextEditingController();
  final _subaccountController = TextEditingController();

  bool _isLiveMode = false;
  bool _isEnabled = true;
  final Set<String> _selectedChannels = {'card', 'bank_transfer', 'ussd', 'qr'};
  bool _initialized = false;

  @override
  void dispose() {
    _publicKeyController.dispose();
    _secretKeyController.dispose();
    _webhookSecretController.dispose();
    _merchantEmailController.dispose();
    _subaccountController.dispose();
    super.dispose();
  }

  void _syncControllers(PaystackProvisioningState state) {
    if (!_initialized) {
      _publicKeyController.text = state.settings.publicKey;
      _secretKeyController.text = state.isSecretRevealed
          ? state.settings.secretKey
          : state.settings.maskedSecretKey;
      _webhookSecretController.text = state.settings.webhookSecret;
      _merchantEmailController.text = state.settings.merchantEmail;
      _subaccountController.text = state.settings.subaccountCode ?? '';
      _isLiveMode = state.settings.isLiveMode;
      _isEnabled = state.settings.isEnabled;
      _selectedChannels.clear();
      _selectedChannels.addAll(state.settings.supportedChannels);
      _initialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paystackProvisioningNotifierProvider);
    final notifier = ref.read(paystackProvisioningNotifierProvider.notifier);

    _syncControllers(state);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(GVSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Paystack Gateway Provisioning',
                      style: GVTypography.h2.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Configure production payment tokens, API secret keys, webhook signatures and settlement routing (§5.8 & §8.8).',
                      style: GVTypography.bodySmall.copyWith(color: Colors.white60),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: GVColors.brandGreen,
                  foregroundColor: GVColors.deepGreen,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: state.isSaving
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: GVColors.deepGreen),
                      )
                    : const Icon(Icons.save_outlined, size: 18),
                label: Text(
                  state.isSaving ? 'Deploying...' : 'Save Configuration',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onPressed: state.isSaving
                    ? null
                    : () async {
                        final ok = await notifier.saveSettings(
                          publicKey: _publicKeyController.text,
                          secretKey: _secretKeyController.text,
                          webhookSecret: _webhookSecretController.text,
                          isLiveMode: _isLiveMode,
                          isEnabled: _isEnabled,
                          supportedChannels: _selectedChannels.toList(),
                          subaccountCode: _subaccountController.text.isNotEmpty
                              ? _subaccountController.text
                              : null,
                          merchantEmail: _merchantEmailController.text.isNotEmpty
                              ? _merchantEmailController.text
                              : null,
                        );

                        if (context.mounted && ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Paystack Gateway configuration updated successfully!'),
                              backgroundColor: GVColors.brandGreen,
                            ),
                          );
                        }
                      },
              ),
            ],
          ),
          const SizedBox(height: GVSpacing.lg),

          // KPIs
          Row(
            children: [
              Expanded(
                child: AdminKpiCard(
                  title: 'Gateway State',
                  value: _isEnabled ? 'ACTIVE' : 'SUSPENDED',
                  subtitle: _isEnabled ? 'Accepting customer deposits' : 'Deposits paused',
                  icon: Icons.power_settings_new,
                  accentColor: _isEnabled ? GVColors.brandGreen : Colors.redAccent,
                ),
              ),
              const SizedBox(width: GVSpacing.md),
              Expanded(
                child: AdminKpiCard(
                  title: 'Environment Mode',
                  value: _isLiveMode ? 'LIVE PRODUCTION' : 'SANDBOX TEST',
                  subtitle: _isLiveMode ? 'Real NGN settlements' : 'Test tokens and cards',
                  icon: Icons.shield_outlined,
                  accentColor: _isLiveMode ? Colors.blueAccent : Colors.amberAccent,
                ),
              ),
              const SizedBox(width: GVSpacing.md),
              Expanded(
                child: AdminKpiCard(
                  title: 'Active Channels',
                  value: '${_selectedChannels.length} Channels',
                  subtitle: _selectedChannels.join(', ').toUpperCase(),
                  icon: Icons.payment_outlined,
                  accentColor: Colors.purpleAccent,
                ),
              ),
              const SizedBox(width: GVSpacing.md),
              const Expanded(
                child: AdminKpiCard(
                  title: 'Security & Webhook',
                  value: 'HMAC-SHA512',
                  subtitle: 'Signed event ingress',
                  icon: Icons.lock_outline,
                  accentColor: Colors.tealAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: GVSpacing.xl),

          // Status Notification Banner
          if (state.statusMessage != null) ...[
            Container(
              margin: const EdgeInsets.only(bottom: GVSpacing.md),
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: GVColors.brandGreen.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: GVColors.brandGreen),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle_outline, color: GVColors.brandGreen, size: 22),
                  const SizedBox(width: GVSpacing.md),
                  Expanded(
                    child: Text(
                      state.statusMessage!,
                      style: const TextStyle(color: GVColors.brandGreen, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Form Sections
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Credentials Form
              Expanded(
                flex: 3,
                child: Container(
                  padding: const EdgeInsets.all(GVSpacing.lg),
                  decoration: BoxDecoration(
                    color: const Color(0xFF101713),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF1F2B25)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.key, color: GVColors.brandGreen, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'API Credentials & Encryption Keys',
                            style: GVTypography.h3.copyWith(color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Credentials obtained from your Paystack Dashboard (Settings -> API Keys & Webhooks).',
                        style: GVTypography.bodySmall.copyWith(color: Colors.white60),
                      ),
                      const SizedBox(height: GVSpacing.lg),

                      // Public Key
                      TextField(
                        controller: _publicKeyController,
                        style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                        decoration: const InputDecoration(
                          labelText: 'Paystack Public Key (pk_live_... or pk_test_...)',
                          labelStyle: TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Color(0xFF14241B),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.public, color: GVColors.brandGreen),
                        ),
                      ),
                      const SizedBox(height: GVSpacing.md),

                      // Secret Key
                      TextField(
                        controller: _secretKeyController,
                        obscureText: !state.isSecretRevealed,
                        style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                        decoration: InputDecoration(
                          labelText: 'Paystack Secret Key (sk_live_... or sk_test_...)',
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: const Color(0xFF14241B),
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.security, color: Colors.amberAccent),
                          suffixIcon: IconButton(
                            icon: Icon(
                              state.isSecretRevealed ? Icons.visibility_off : Icons.visibility,
                              color: Colors.white70,
                            ),
                            onPressed: () {
                              notifier.toggleRevealSecret();
                              setState(() {
                                _secretKeyController.text = !state.isSecretRevealed
                                    ? state.settings.secretKey
                                    : state.settings.maskedSecretKey;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: GVSpacing.md),

                      // Webhook Secret
                      TextField(
                        controller: _webhookSecretController,
                        style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                        decoration: const InputDecoration(
                          labelText: 'Webhook Secret Key / Signature Hash',
                          labelStyle: TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Color(0xFF14241B),
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.webhook, color: Colors.purpleAccent),
                        ),
                      ),
                      const SizedBox(height: GVSpacing.lg),

                      // Merchant Email & Subaccount
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _merchantEmailController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                labelText: 'Merchant Settlement Email',
                                labelStyle: TextStyle(color: Colors.white70),
                                filled: true,
                                fillColor: Color(0xFF14241B),
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.email_outlined, color: Colors.white70),
                              ),
                            ),
                          ),
                          const SizedBox(width: GVSpacing.md),
                          Expanded(
                            child: TextField(
                              controller: _subaccountController,
                              style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
                              decoration: const InputDecoration(
                                labelText: 'Subaccount Code (Optional Split Settlement)',
                                labelStyle: TextStyle(color: Colors.white70),
                                filled: true,
                                fillColor: Color(0xFF14241B),
                                border: OutlineInputBorder(),
                                prefixIcon: Icon(Icons.account_balance_outlined, color: Colors.white70),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: GVSpacing.lg),

              // Right Column: Environment & Channels
              Expanded(
                flex: 2,
                child: Column(
                  children: [
                    // Environment Controls Card
                    Container(
                      padding: const EdgeInsets.all(GVSpacing.lg),
                      decoration: BoxDecoration(
                        color: const Color(0xFF101713),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF1F2B25)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Gateway Switches',
                            style: GVTypography.h3.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: GVSpacing.md),

                          // Live Mode Toggle
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Live Mode (Production)', style: TextStyle(color: Colors.white)),
                            subtitle: Text(
                              _isLiveMode
                                  ? 'Routing real payments through Paystack live infrastructure'
                                  : 'Sandbox test mode active (no real money deducted)',
                              style: const TextStyle(color: Colors.white60, fontSize: 12),
                            ),
                            value: _isLiveMode,
                            activeThumbColor: GVColors.brandGreen,
                            onChanged: (val) => setState(() => _isLiveMode = val),
                          ),
                          const Divider(color: Color(0xFF1F2B25)),

                          // Master Enable Toggle
                          SwitchListTile(
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Enable Paystack Gateway', style: TextStyle(color: Colors.white)),
                            subtitle: const Text(
                              'Master kill switch to pause or resume customer wallet funding',
                              style: TextStyle(color: Colors.white60, fontSize: 12),
                            ),
                            value: _isEnabled,
                            activeThumbColor: GVColors.brandGreen,
                            onChanged: (val) => setState(() => _isEnabled = val),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: GVSpacing.lg),

                    // Supported Channels Card
                    Container(
                      padding: const EdgeInsets.all(GVSpacing.lg),
                      decoration: BoxDecoration(
                        color: const Color(0xFF101713),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFF1F2B25)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Enabled Payment Channels',
                            style: GVTypography.h3.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Select which payment methods are accepted on checkout:',
                            style: GVTypography.bodySmall.copyWith(color: Colors.white60),
                          ),
                          const SizedBox(height: GVSpacing.md),

                          _buildChannelCheckbox('card', 'Debit & Credit Cards (Mastercard, Visa, Verve)'),
                          _buildChannelCheckbox('bank_transfer', 'Dedicated Virtual NUBAN Bank Transfer'),
                          _buildChannelCheckbox('ussd', 'USSD Bank Dial Codes (*737#, etc.)'),
                          _buildChannelCheckbox('qr', 'Visa QR & Scan to Pay'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChannelCheckbox(String channelKey, String label) {
    final isChecked = _selectedChannels.contains(channelKey);
    return CheckboxListTile(
      contentPadding: EdgeInsets.zero,
      dense: true,
      title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 13)),
      value: isChecked,
      activeColor: GVColors.brandGreen,
      checkColor: GVColors.deepGreen,
      onChanged: (val) {
        setState(() {
          if (val == true) {
            _selectedChannels.add(channelKey);
          } else {
            if (_selectedChannels.length > 1) {
              _selectedChannels.remove(channelKey);
            }
          }
        });
      },
    );
  }
}
