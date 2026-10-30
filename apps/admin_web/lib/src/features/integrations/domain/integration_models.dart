import 'package:equatable/equatable.dart';

class PartnerIntegrationModel extends Equatable {
  const PartnerIntegrationModel({
    required this.id,
    required this.partnerName,
    required this.apiKeyPrefix,
    required this.webhookUrl,
    required this.isActive,
    required this.isHmacVerified,
    required this.totalDispatchesToday,
    required this.lastWebhookPing,
    required this.pingSuccess,
  });

  final String id;
  final String partnerName;
  final String apiKeyPrefix;
  final String webhookUrl;
  final bool isActive;
  final bool isHmacVerified;
  final int totalDispatchesToday;
  final DateTime lastWebhookPing;
  final bool pingSuccess;

  PartnerIntegrationModel copyWith({
    String? id,
    String? partnerName,
    String? apiKeyPrefix,
    String? webhookUrl,
    bool? isActive,
    bool? isHmacVerified,
    int? totalDispatchesToday,
    DateTime? lastWebhookPing,
    bool? pingSuccess,
  }) {
    return PartnerIntegrationModel(
      id: id ?? this.id,
      partnerName: partnerName ?? this.partnerName,
      apiKeyPrefix: apiKeyPrefix ?? this.apiKeyPrefix,
      webhookUrl: webhookUrl ?? this.webhookUrl,
      isActive: isActive ?? this.isActive,
      isHmacVerified: isHmacVerified ?? this.isHmacVerified,
      totalDispatchesToday: totalDispatchesToday ?? this.totalDispatchesToday,
      lastWebhookPing: lastWebhookPing ?? this.lastWebhookPing,
      pingSuccess: pingSuccess ?? this.pingSuccess,
    );
  }

  @override
  List<Object?> get props => [
        id,
        partnerName,
        apiKeyPrefix,
        webhookUrl,
        isActive,
        isHmacVerified,
        totalDispatchesToday,
        lastWebhookPing,
        pingSuccess,
      ];
}
