import 'package:app_models/app_models.dart';
import 'package:equatable/equatable.dart';
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

  PricingRuleModel? get activeRule => rules.firstWhere(
        (r) => r.status == PricingRuleStatus.active && r.tier == selectedTier,
        orElse: () => rules.firstWhere((r) => r.status == PricingRuleStatus.active),
      );

  List<PricingRuleModel> get draftRules =>
      rules.where((r) => r.status == PricingRuleStatus.draft).toList();

  List<PricingRuleModel> get archivedRules =>
      rules.where((r) => r.status == PricingRuleStatus.archived).toList();

  ServiceAreaZoneModel? get currentZone =>
      zones.firstWhere((z) => z.zoneId == selectedZoneId, orElse: () => zones.first);

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
          PricingState(
            rules: _seedRules,
            zones: _seedZones,
          ),
        );

  static final List<PricingRuleModel> _seedRules = [
    PricingRuleModel(
      id: 'pr_commute_v2_1',
      version: 'v2.1',
      tier: ServiceTier.commute,
      baseFareKobo: BigInt.from(60000), // ₦600
      perKmKobo: BigInt.from(12000), // ₦120/km
      perMinuteKobo: BigInt.from(2500), // ₦25/min
      minimumFareKobo: BigInt.from(80000), // ₦800
      surgeMultiplierCap: 2.0,
      status: PricingRuleStatus.active,
      effectiveDate: DateTime(2026, 9, 1),
      createdBy: 'admin_sys',
      notes: 'Harmonized fuel subsidy price baseline for Lagos metropolis',
    ),
    PricingRuleModel(
      id: 'pr_parcel_v1_8',
      version: 'v1.8',
      tier: ServiceTier.expressParcel,
      baseFareKobo: BigInt.from(50000), // ₦500
      perKmKobo: BigInt.from(10000), // ₦100/km
      perMinuteKobo: BigInt.from(1500), // ₦15/min
      minimumFareKobo: BigInt.from(70000), // ₦700
      surgeMultiplierCap: 1.8,
      status: PricingRuleStatus.active,
      effectiveDate: DateTime(2026, 8, 15),
      createdBy: 'admin_sys',
      notes: 'B2B e-commerce parcel matrix baseline',
    ),
    PricingRuleModel(
      id: 'pr_school_v1_2',
      version: 'v1.2',
      tier: ServiceTier.schoolRun,
      baseFareKobo: BigInt.from(120000), // ₦1,200
      perKmKobo: BigInt.from(15000), // ₦150/km
      perMinuteKobo: BigInt.from(3000), // ₦30/min
      minimumFareKobo: BigInt.from(150000), // ₦1,500
      surgeMultiplierCap: 1.5,
      status: PricingRuleStatus.active,
      effectiveDate: DateTime(2026, 9, 10),
      createdBy: 'safety_officer_ade',
      notes: 'Child safeguard chaperone surcharge included',
    ),
    PricingRuleModel(
      id: 'pr_commute_v2_0_archived',
      version: 'v2.0',
      tier: ServiceTier.commute,
      baseFareKobo: BigInt.from(50000),
      perKmKobo: BigInt.from(10000),
      perMinuteKobo: BigInt.from(2000),
      minimumFareKobo: BigInt.from(70000),
      surgeMultiplierCap: 2.5,
      status: PricingRuleStatus.archived,
      effectiveDate: DateTime(2026, 5, 1),
      createdBy: 'admin_sys',
      notes: 'Superseded by v2.1 fuel adjustment',
    ),
  ];

  static final List<ServiceAreaZoneModel> _seedZones = [
    const ServiceAreaZoneModel(
      zoneId: 'lagos_island',
      zoneName: 'Lagos Island / VI / Lekki',
      city: 'Lagos',
      isActive: true,
      enabledTiers: {
        ServiceTier.commute,
        ServiceTier.expressParcel,
        ServiceTier.scheduled,
        ServiceTier.schoolRun,
      },
      currentSurgeMultiplier: 1.25,
      maxSurgeCap: 2.0,
      activeRidersCount: 42,
    ),
    const ServiceAreaZoneModel(
      zoneId: 'lagos_mainland',
      zoneName: 'Ikeja / Maryland / Surulere',
      city: 'Lagos',
      isActive: true,
      enabledTiers: {
        ServiceTier.commute,
        ServiceTier.expressParcel,
        ServiceTier.scheduled,
      },
      currentSurgeMultiplier: 1.0,
      maxSurgeCap: 1.8,
      activeRidersCount: 38,
    ),
    const ServiceAreaZoneModel(
      zoneId: 'abuja_central',
      zoneName: 'Abuja Central / Maitama / Wuse',
      city: 'Abuja',
      isActive: true,
      enabledTiers: {
        ServiceTier.commute,
        ServiceTier.expressParcel,
      },
      currentSurgeMultiplier: 1.0,
      maxSurgeCap: 1.5,
      activeRidersCount: 16,
    ),
  ];

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
