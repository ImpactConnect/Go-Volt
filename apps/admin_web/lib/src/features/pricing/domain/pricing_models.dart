import 'package:equatable/equatable.dart';

enum PricingRuleStatus {
  draft,
  active,
  archived,
}

enum ServiceTier {
  commute(label: 'Standard Commute'),
  expressParcel(label: 'Express Parcel Delivery'),
  scheduled(label: 'Scheduled Rental / Hourly'),
  schoolRun(label: 'School-Run Chaperone');

  const ServiceTier({required this.label});
  final String label;
}

class PricingRuleModel extends Equatable {
  const PricingRuleModel({
    required this.id,
    required this.version,
    required this.tier,
    required this.baseFareKobo,
    required this.perKmKobo,
    required this.perMinuteKobo,
    required this.minimumFareKobo,
    required this.surgeMultiplierCap,
    required this.status,
    required this.effectiveDate,
    required this.createdBy,
    this.notes,
  });

  final String id;
  final String version;
  final ServiceTier tier;
  final BigInt baseFareKobo;
  final BigInt perKmKobo;
  final BigInt perMinuteKobo;
  final BigInt minimumFareKobo;
  final double surgeMultiplierCap;
  final PricingRuleStatus status;
  final DateTime effectiveDate;
  final String createdBy;
  final String? notes;

  String get formattedBaseFare => '₦${(baseFareKobo / BigInt.from(100)).toStringAsFixed(0)}';
  String get formattedPerKm => '₦${(perKmKobo / BigInt.from(100)).toStringAsFixed(0)}/km';
  String get formattedPerMinute => '₦${(perMinuteKobo / BigInt.from(100)).toStringAsFixed(0)}/min';

  PricingRuleModel copyWith({
    String? id,
    String? version,
    ServiceTier? tier,
    BigInt? baseFareKobo,
    BigInt? perKmKobo,
    BigInt? perMinuteKobo,
    BigInt? minimumFareKobo,
    double? surgeMultiplierCap,
    PricingRuleStatus? status,
    DateTime? effectiveDate,
    String? createdBy,
    String? notes,
  }) {
    return PricingRuleModel(
      id: id ?? this.id,
      version: version ?? this.version,
      tier: tier ?? this.tier,
      baseFareKobo: baseFareKobo ?? this.baseFareKobo,
      perKmKobo: perKmKobo ?? this.perKmKobo,
      perMinuteKobo: perMinuteKobo ?? this.perMinuteKobo,
      minimumFareKobo: minimumFareKobo ?? this.minimumFareKobo,
      surgeMultiplierCap: surgeMultiplierCap ?? this.surgeMultiplierCap,
      status: status ?? this.status,
      effectiveDate: effectiveDate ?? this.effectiveDate,
      createdBy: createdBy ?? this.createdBy,
      notes: notes ?? this.notes,
    );
  }

  @override
  List<Object?> get props => [
        id,
        version,
        tier,
        baseFareKobo,
        perKmKobo,
        perMinuteKobo,
        minimumFareKobo,
        surgeMultiplierCap,
        status,
        effectiveDate,
        createdBy,
        notes,
      ];
}

class ServiceAreaZoneModel extends Equatable {
  const ServiceAreaZoneModel({
    required this.zoneId,
    required this.zoneName,
    required this.city,
    required this.isActive,
    required this.enabledTiers,
    required this.currentSurgeMultiplier,
    required this.maxSurgeCap,
    required this.activeRidersCount,
  });

  final String zoneId;
  final String zoneName;
  final String city;
  final bool isActive;
  final Set<ServiceTier> enabledTiers;
  final double currentSurgeMultiplier;
  final double maxSurgeCap;
  final int activeRidersCount;

  bool isTierEnabled(ServiceTier tier) => enabledTiers.contains(tier);

  ServiceAreaZoneModel copyWith({
    String? zoneId,
    String? zoneName,
    String? city,
    bool? isActive,
    Set<ServiceTier>? enabledTiers,
    double? currentSurgeMultiplier,
    double? maxSurgeCap,
    int? activeRidersCount,
  }) {
    return ServiceAreaZoneModel(
      zoneId: zoneId ?? this.zoneId,
      zoneName: zoneName ?? this.zoneName,
      city: city ?? this.city,
      isActive: isActive ?? this.isActive,
      enabledTiers: enabledTiers ?? this.enabledTiers,
      currentSurgeMultiplier: currentSurgeMultiplier ?? this.currentSurgeMultiplier,
      maxSurgeCap: maxSurgeCap ?? this.maxSurgeCap,
      activeRidersCount: activeRidersCount ?? this.activeRidersCount,
    );
  }

  @override
  List<Object?> get props => [
        zoneId,
        zoneName,
        city,
        isActive,
        enabledTiers,
        currentSurgeMultiplier,
        maxSurgeCap,
        activeRidersCount,
      ];
}
