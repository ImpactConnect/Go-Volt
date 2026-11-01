import 'package:equatable/equatable.dart';

/// Data Transfer Object representing Paystack payment gateway provisioning
/// configured and managed by Platform Administrators.
class PaystackSettingsDto extends Equatable {
  const PaystackSettingsDto({
    required this.publicKey,
    required this.secretKey,
    required this.webhookSecret,
    required this.isLiveMode,
    required this.isEnabled,
    this.supportedChannels = const ['card', 'bank_transfer', 'ussd', 'qr'],
    this.subaccountCode,
    this.merchantEmail = 'payments@govolts.ng',
    this.updatedAt,
  });

  factory PaystackSettingsDto.fromJson(Map<String, dynamic> json) {
    return PaystackSettingsDto(
      publicKey: json['public_key'] as String? ?? '',
      secretKey: json['secret_key'] as String? ?? '',
      webhookSecret: json['webhook_secret'] as String? ?? '',
      isLiveMode: json['is_live_mode'] as bool? ?? false,
      isEnabled: json['is_enabled'] as bool? ?? true,
      supportedChannels: (json['supported_channels'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const ['card', 'bank_transfer', 'ussd', 'qr'],
      subaccountCode: json['subaccount_code'] as String?,
      merchantEmail: json['merchant_email'] as String? ?? 'payments@govolts.ng',
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  final String publicKey;
  final String secretKey;
  final String webhookSecret;
  final bool isLiveMode;
  final bool isEnabled;
  final List<String> supportedChannels;
  final String? subaccountCode;
  final String merchantEmail;
  final DateTime? updatedAt;

  /// Returns masked secret key for secure UI presentation.
  String get maskedSecretKey {
    if (secretKey.isEmpty) return 'Not configured';
    if (secretKey.length <= 10) return '••••••••';
    final prefix = secretKey.substring(0, 7); // e.g. "sk_test" or "sk_live"
    final suffix = secretKey.substring(secretKey.length - 4);
    return '$prefix••••••••$suffix';
  }

  Map<String, dynamic> toJson({bool maskSecret = false}) {
    return {
      'public_key': publicKey,
      'secret_key': maskSecret ? maskedSecretKey : secretKey,
      'webhook_secret': maskSecret ? '••••••••' : webhookSecret,
      'is_live_mode': isLiveMode,
      'is_enabled': isEnabled,
      'supported_channels': supportedChannels,
      if (subaccountCode != null) 'subaccount_code': subaccountCode,
      'merchant_email': merchantEmail,
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  PaystackSettingsDto copyWith({
    String? publicKey,
    String? secretKey,
    String? webhookSecret,
    bool? isLiveMode,
    bool? isEnabled,
    List<String>? supportedChannels,
    String? subaccountCode,
    String? merchantEmail,
    DateTime? updatedAt,
  }) {
    return PaystackSettingsDto(
      publicKey: publicKey ?? this.publicKey,
      secretKey: secretKey ?? this.secretKey,
      webhookSecret: webhookSecret ?? this.webhookSecret,
      isLiveMode: isLiveMode ?? this.isLiveMode,
      isEnabled: isEnabled ?? this.isEnabled,
      supportedChannels: supportedChannels ?? this.supportedChannels,
      subaccountCode: subaccountCode ?? this.subaccountCode,
      merchantEmail: merchantEmail ?? this.merchantEmail,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        publicKey,
        secretKey,
        webhookSecret,
        isLiveMode,
        isEnabled,
        supportedChannels,
        subaccountCode,
        merchantEmail,
        updatedAt,
      ];
}
