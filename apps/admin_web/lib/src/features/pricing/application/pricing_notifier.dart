import 'package:app_models/app_models.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/pricing_models.dart';

class PricingState extends Equatable {
  const PricingState({
    required this.rules,
    required this.zones,
    this.rideCategories = _defaultRideCategories,
    this.selectedZoneId = 'lagos_island',
    this.selectedTier = ServiceTier.commute,
  });

  final List<PricingRuleModel> rules;
  final List<ServiceAreaZoneModel> zones;
  final List<RideCategoryDto> rideCategories;
  final String selectedZoneId;
  final ServiceTier selectedTier;

  PricingRuleModel? get activeRule {
    if (rules.isEmpty) return null;
    final matching = rules.where((r) => r.status == PricingRuleStatus.active);
    final byTier = matching.where((r) => r.tier == selectedTier);
    if (byTier.isNotEmpty) return byTier.first;
    if (matching.isNotEmpty) return matching.first;
    return null;
  }

  List<PricingRuleModel> get draftRules =>
      rules.where((r) => r.status == PricingRuleStatus.draft).toList();

  List<PricingRuleModel> get archivedRules =>
      rules.where((r) => r.status == PricingRuleStatus.archived).toList();

  ServiceAreaZoneModel? get currentZone {
    if (zones.isEmpty) return null;
    final matching = zones.where((z) => z.zoneId == selectedZoneId);
    if (matching.isNotEmpty) return matching.first;
    return zones.first;
  }

  PricingState copyWith({
    List<PricingRuleModel>? rules,
    List<ServiceAreaZoneModel>? zones,
    List<RideCategoryDto>? rideCategories,
    String? selectedZoneId,
    ServiceTier? selectedTier,
  }) {
    return PricingState(
      rules: rules ?? this.rules,
      zones: zones ?? this.zones,
      rideCategories: rideCategories ?? this.rideCategories,
      selectedZoneId: selectedZoneId ?? this.selectedZoneId,
      selectedTier: selectedTier ?? this.selectedTier,
    );
  }

  @override
  List<Object?> get props => [rules, zones, rideCategories, selectedZoneId, selectedTier];
}

const List<RideCategoryDto> _defaultRideCategories = [
  RideCategoryDto(
    id: 'cat_bike_std',
    code: 'bike_standard',
    name: 'GoRide Moto',
    description: 'Fast and affordable solo rides on electric two-wheelers',
    passengerCapacity: 1,
    capacityLabel: '1 Seat (Helmet provided)',
    baseFareKobo: 120000,
    etaMinutes: 2,
    features: ['Helmet provided', '1 Passenger', 'Fastest in traffic', 'Zero emission'],
    iconKey: 'electric_bike',
    isAvailable: true,
    displayOrder: 1,
    co2OffsetGrams: 450,
  ),
  RideCategoryDto(
    id: 'cat_bike_plus',
    code: 'bike_plus',
    name: 'GoRide Moto Plus',
    description: 'Top-rated electric bike rider with sanitized helmet & hairnet',
    passengerCapacity: 1,
    capacityLabel: '1 Seat (Premium)',
    baseFareKobo: 180000,
    etaMinutes: 2,
    features: ['Sanitized helmet', 'Top-rated rider', 'Express lane', 'Zero emission'],
    iconKey: 'electric_bike',
    isAvailable: true,
    displayOrder: 2,
    co2OffsetGrams: 450,
  ),
  RideCategoryDto(
    id: 'cat_car_std',
    code: 'standard',
    name: 'GoRide Standard',
    description: 'Affordable, reliable everyday electric car rides',
    passengerCapacity: 3,
    capacityLabel: '3 Seats',
    baseFareKobo: 280000,
    etaMinutes: 2,
    features: ['AC', '3 Seats', 'Trusted drivers'],
    iconKey: 'electric_car',
    isAvailable: true,
    displayOrder: 3,
    co2OffsetGrams: 850,
  ),
  RideCategoryDto(
    id: 'cat_car_plus',
    code: 'plus',
    name: 'GoRide Plus',
    description: 'More comfort and legroom in premium electric sedans',
    passengerCapacity: 4,
    capacityLabel: '4 Seats',
    baseFareKobo: 350000,
    etaMinutes: 3,
    features: ['AC', 'Extra legroom', 'Top rated', 'Quiet ride'],
    iconKey: 'electric_car',
    isAvailable: true,
    displayOrder: 4,
    co2OffsetGrams: 950,
  ),
  RideCategoryDto(
    id: 'cat_car_xl',
    code: 'xl',
    name: 'GoRide XL',
    description: 'Bigger 6-seater electric vehicles for groups or extra luggage',
    passengerCapacity: 6,
    capacityLabel: '6 Seats',
    baseFareKobo: 450000,
    etaMinutes: 4,
    features: ['AC', '6 Seats', 'Spacious trunk', 'Group trips'],
    iconKey: 'electric_car',
    isAvailable: true,
    displayOrder: 5,
    co2OffsetGrams: 1200,
  ),
];

class PricingNotifier extends StateNotifier<PricingState> {
  PricingNotifier()
      : super(
          const PricingState(
            rules: [],
            zones: [],
          ),
        );

    @visibleForTesting
  void updateStateForTesting(PricingState newState) {
    state = newState;
  }

  void selectZone(String zoneId) {
    state = state.copyWith(selectedZoneId: zoneId);
  }

  void selectTier(ServiceTier tier) {
    state = state.copyWith(selectedTier: tier);
  }

  /// Create a draft pricing rule for review.
  void createDraftRule({
    required ServiceTier tier,
    required BigInt baseFareKobo,
    required BigInt perKmKobo,
    required BigInt perMinuteKobo,
    required BigInt minimumFareKobo,
    required double surgeMultiplierCap,
    required String createdBy,
    String? notes,
  }) {
    final newVersion = 'v${state.rules.length + 1}.0-draft';
    final newRule = PricingRuleModel(
      id: 'pr_${tier.name}_${DateTime.now().millisecondsSinceEpoch}',
      version: newVersion,
      tier: tier,
      baseFareKobo: baseFareKobo,
      perKmKobo: perKmKobo,
      perMinuteKobo: perMinuteKobo,
      minimumFareKobo: minimumFareKobo,
      surgeMultiplierCap: surgeMultiplierCap,
      status: PricingRuleStatus.draft,
      effectiveDate: DateTime.now().add(const Duration(days: 1)),
      createdBy: createdBy,
      notes: notes,
    );

    state = state.copyWith(rules: [newRule, ...state.rules]);
  }

  /// Publish draft rule: marks existing active rule as archived (preserving immutable past snapshots),
  /// and promotes this rule to active status with new version string.
  void publishDraftRule(String draftRuleId) {
    final draft = state.rules.firstWhere((r) => r.id == draftRuleId);
    final activeCount = state.rules.where((r) => r.tier == draft.tier && r.status == PricingRuleStatus.archived).length;
    final publishedVersion = 'v${activeCount + 2}.0';

    final updatedRules = state.rules.map((rule) {
      if (rule.tier == draft.tier && rule.status == PricingRuleStatus.active) {
        // Archive current active
        return rule.copyWith(status: PricingRuleStatus.archived);
      } else if (rule.id == draftRuleId) {
        // Promote draft to active
        return rule.copyWith(
          status: PricingRuleStatus.active,
          version: publishedVersion,
          effectiveDate: DateTime.now(),
        );
      }
      return rule;
    }).toList();

    state = state.copyWith(rules: updatedRules);
  }

  /// Toggle service tier gating in a specific zone.
  void toggleZoneServiceTier(String zoneId, ServiceTier tier, bool enable) {
    final updatedZones = state.zones.map((zone) {
      if (zone.zoneId == zoneId) {
        final currentTiers = Set<ServiceTier>.from(zone.enabledTiers);
        if (enable) {
          currentTiers.add(tier);
        } else {
          currentTiers.remove(tier);
        }
        return zone.copyWith(enabledTiers: currentTiers);
      }
      return zone;
    }).toList();

    state = state.copyWith(zones: updatedZones);
  }

  /// Update zone surge multiplier.
  void updateZoneSurge(String zoneId, double newSurge) {
    final updatedZones = state.zones.map((zone) {
      if (zone.zoneId == zoneId) {
        final cappedSurge = newSurge.clamp(1.0, zone.maxSurgeCap);
        return zone.copyWith(currentSurgeMultiplier: cappedSurge);
      }
      return zone;
    }).toList();

    state = state.copyWith(zones: updatedZones);
  }

  /// Toggle customer availability of a ride option (2 bikes, 3 cars).
  void toggleRideCategory(String categoryId, bool isAvailable) {
    final updated = state.rideCategories.map((cat) {
      if (cat.id == categoryId) {
        return cat.copyWith(isAvailable: isAvailable);
      }
      return cat;
    }).toList();

    state = state.copyWith(rideCategories: updated);
  }

  /// Add a new ride option to the published customer catalogue.
  void addRideCategory(RideCategoryDto category) {
    state = state.copyWith(
      rideCategories: [...state.rideCategories, category],
    );
  }

  /// Update an existing ride option in the catalogue.
  void updateRideCategory(RideCategoryDto category) {
    final updated = state.rideCategories.map((c) {
      return c.id == category.id ? category : c;
    }).toList();
    state = state.copyWith(rideCategories: updated);
  }
}

final pricingNotifierProvider =
    StateNotifierProvider<PricingNotifier, PricingState>((ref) {
  return PricingNotifier();
});
