import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/integration_models.dart';

class IntegrationsState extends Equatable {
  const IntegrationsState({
    required this.partners,
  });

  final List<PartnerIntegrationModel> partners;

  int get activePartnersCount => partners.where((p) => p.isActive).length;
  int get totalPartnerDispatchesToday => partners.fold(0, (acc, p) => acc + p.totalDispatchesToday);

  IntegrationsState copyWith({
    List<PartnerIntegrationModel>? partners,
  }) {
    return IntegrationsState(
      partners: partners ?? this.partners,
    );
  }

  @override
  List<Object?> get props => [partners];
}

class IntegrationsNotifier extends StateNotifier<IntegrationsState> {
  IntegrationsNotifier()
      : super(
          IntegrationsState(
            partners: _seedPartners,
          ),
        );

  static final List<PartnerIntegrationModel> _seedPartners = [
    PartnerIntegrationModel(
      id: 'int_retail_ai',
      partnerName: 'Retail Ai Smart Logistics',
      apiKeyPrefix: 'gv_live_rt_ai_8891...xK8',
      webhookUrl: 'https://api.retail-ai.africa/v1/logistics/go-volt-webhook',
      isActive: true,
      isHmacVerified: true,
      totalDispatchesToday: 134,
      lastWebhookPing: DateTime(2026, 10, 24, 15, 45),
      pingSuccess: true,
    ),
    PartnerIntegrationModel(
      id: 'int_shoprite_lekki',
      partnerName: 'Shoprite Express On-Demand',
      apiKeyPrefix: 'gv_live_sp_lek_3021...p9L',
      webhookUrl: 'https://delivery.shoprite.ng/integrations/go-volt/status',
      isActive: true,
      isHmacVerified: true,
      totalDispatchesToday: 48,
      lastWebhookPing: DateTime(2026, 10, 24, 15, 30),
      pingSuccess: true,
    ),
    PartnerIntegrationModel(
      id: 'int_jumia_food',
      partnerName: 'Jumia Quick Commerce Hub',
      apiKeyPrefix: 'gv_test_jm_qck_7190...m1Z',
      webhookUrl: 'https://staging.jumia.com.ng/b2b-fulfillment/callback',
      isActive: false,
      isHmacVerified: false,
      totalDispatchesToday: 0,
      lastWebhookPing: DateTime(2026, 10, 23, 12, 0),
      pingSuccess: false,
    ),
  ];

  void togglePartner(String id) {
    final updated = state.partners.map((p) {
      if (p.id == id) {
        return p.copyWith(isActive: !p.isActive);
      }
      return p;
    }).toList();

    state = state.copyWith(partners: updated);
  }

  void testWebhookPing(String id) {
    final updated = state.partners.map((p) {
      if (p.id == id) {
        return p.copyWith(
          lastWebhookPing: DateTime.now(),
          pingSuccess: true,
        );
      }
      return p;
    }).toList();

    state = state.copyWith(partners: updated);
  }
}

final integrationsNotifierProvider =
    StateNotifierProvider<IntegrationsNotifier, IntegrationsState>((ref) {
  return IntegrationsNotifier();
});
