import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
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
          const IntegrationsState(
            partners: [],
          ),
        );

    @visibleForTesting
  void updateStateForTesting(IntegrationsState newState) {
    state = newState;
  }

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
