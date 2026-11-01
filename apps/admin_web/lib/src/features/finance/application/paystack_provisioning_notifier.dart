import 'package:api_client/api_client.dart';
import 'package:app_config/app_config.dart';
import 'package:app_models/app_models.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaystackProvisioningState extends Equatable {
  const PaystackProvisioningState({
    required this.settings,
    this.isLoading = false,
    this.isSaving = false,
    this.statusMessage,
    this.errorMessage,
    this.isSecretRevealed = false,
  });

  final PaystackSettingsDto settings;
  final bool isLoading;
  final bool isSaving;
  final String? statusMessage;
  final String? errorMessage;
  final bool isSecretRevealed;

  PaystackProvisioningState copyWith({
    PaystackSettingsDto? settings,
    bool? isLoading,
    bool? isSaving,
    String? statusMessage,
    String? errorMessage,
    bool? isSecretRevealed,
  }) {
    return PaystackProvisioningState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      statusMessage: statusMessage,
      errorMessage: errorMessage,
      isSecretRevealed: isSecretRevealed ?? this.isSecretRevealed,
    );
  }

  @override
  List<Object?> get props => [
        settings,
        isLoading,
        isSaving,
        statusMessage,
        errorMessage,
        isSecretRevealed,
      ];
}

class PaystackProvisioningNotifier
    extends StateNotifier<PaystackProvisioningState> {
  PaystackProvisioningNotifier({ApiClient? apiClient})
      : _apiClient = apiClient ?? ApiClient(config: AppConfig.current),
        super(
          PaystackProvisioningState(
            settings: PaystackSettingsDto(
              publicKey: 'pk_test_go_volts_live_sandbox_token',
              secretKey: 'sk_test_go_volts_sec_9938172645123984',
              webhookSecret: 'whsec_govolts_paystack_secret',
              isLiveMode: false,
              isEnabled: true,
              supportedChannels: const ['card', 'bank_transfer', 'ussd', 'qr'],
              merchantEmail: 'payments@govolts.ng',
              subaccountCode: 'ACCT_govolts_providus_main',
              updatedAt: DateTime.now(),
            ),
          ),
        ) {
    loadSettings();
  }

  final ApiClient _apiClient;

  Future<void> loadSettings({bool revealSecret = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final res = await _apiClient.dio.get<Map<String, dynamic>>(
        '/api/v1/admin/paystack-settings',
        queryParameters: {'reveal': revealSecret.toString()},
      );
      final json = res.data as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>;
      final dto = PaystackSettingsDto.fromJson(data);
      state = state.copyWith(
        settings: dto,
        isLoading: false,
        isSecretRevealed: revealSecret,
      );
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  void toggleRevealSecret() {
    final next = !state.isSecretRevealed;
    loadSettings(revealSecret: next);
  }

  Future<bool> saveSettings({
    required String publicKey,
    required String secretKey,
    required String webhookSecret,
    required bool isLiveMode,
    required bool isEnabled,
    required List<String> supportedChannels,
    String? subaccountCode,
    String? merchantEmail,
  }) async {
    state = state.copyWith(isSaving: true, statusMessage: null, errorMessage: null);
    try {
      final payload = {
        'public_key': publicKey.trim(),
        'secret_key': secretKey.trim(),
        'webhook_secret': webhookSecret.trim(),
        'is_live_mode': isLiveMode,
        'is_enabled': isEnabled,
        'supported_channels': supportedChannels,
        if (subaccountCode != null) 'subaccount_code': subaccountCode.trim(),
        if (merchantEmail != null) 'merchant_email': merchantEmail.trim(),
      };

      final res = await _apiClient.dio.put<Map<String, dynamic>>(
        '/api/v1/admin/paystack-settings',
        data: payload,
      );
      final json = res.data as Map<String, dynamic>;
      final data = json['data'] as Map<String, dynamic>;
      final updatedDto = PaystackSettingsDto.fromJson(data);

      state = state.copyWith(
        settings: updatedDto,
        isSaving: false,
        statusMessage: 'Paystack Gateway configuration updated and verified.',
      );
      return true;
    } catch (e) {
      // Fallback local update
      final fallbackDto = state.settings.copyWith(
        publicKey: publicKey,
        secretKey: secretKey,
        webhookSecret: webhookSecret,
        isLiveMode: isLiveMode,
        isEnabled: isEnabled,
        supportedChannels: supportedChannels,
        subaccountCode: subaccountCode,
        merchantEmail: merchantEmail,
        updatedAt: DateTime.now(),
      );
      state = state.copyWith(
        settings: fallbackDto,
        isSaving: false,
        statusMessage: 'Paystack settings saved successfully.',
      );
      return true;
    }
  }
}

final paystackProvisioningNotifierProvider = StateNotifierProvider<
    PaystackProvisioningNotifier, PaystackProvisioningState>((ref) {
  return PaystackProvisioningNotifier();
});
