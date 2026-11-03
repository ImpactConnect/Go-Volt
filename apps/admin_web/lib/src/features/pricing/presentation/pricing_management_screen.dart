import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/auth/admin_auth_notifier.dart';
import '../../../core/widgets/admin_kpi_card.dart';
import '../../../core/widgets/admin_modal_dialog.dart';
import '../application/pricing_notifier.dart';
import '../domain/pricing_models.dart';

class PricingManagementScreen extends ConsumerStatefulWidget {
  const PricingManagementScreen({super.key});

  @override
  ConsumerState<PricingManagementScreen> createState() =>
      _PricingManagementScreenState();
}

class _PricingManagementScreenState
    extends ConsumerState<PricingManagementScreen> {
  final _dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  void _showCreateDraftModal(BuildContext context) {
    final baseFareController = TextEditingController(text: '700');
    final perKmController = TextEditingController(text: '140');
    final perMinController = TextEditingController(text: '30');
    final minFareController = TextEditingController(text: '900');
    final notesController = TextEditingController(text: 'Updated tariff calculation');
    ServiceTier selectedTier = ref.read(pricingNotifierProvider).selectedTier;

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AdminModalDialog(
              title: 'Create Draft Pricing Version',
              icon: Icons.price_change_outlined,
              primaryActionLabel: 'Save Draft',
              onPrimaryAction: () {
                final baseFare = BigInt.from((double.tryParse(baseFareController.text) ?? 700) * 100);
                final perKm = BigInt.from((double.tryParse(perKmController.text) ?? 140) * 100);
                final perMin = BigInt.from((double.tryParse(perMinController.text) ?? 30) * 100);
                final minFare = BigInt.from((double.tryParse(minFareController.text) ?? 900) * 100);
                final authState = ref.read(adminAuthNotifierProvider);

                ref.read(pricingNotifierProvider.notifier).createDraftRule(
                      tier: selectedTier,
                      baseFareKobo: baseFare,
                      perKmKobo: perKm,
                      perMinuteKobo: perMin,
                      minimumFareKobo: minFare,
                      surgeMultiplierCap: 2.0,
                      createdBy: authState.userId,
                      notes: notesController.text,
                    );
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Draft pricing rule created.')),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Changes will be saved as a draft. Publishing will archive current active rule without altering past booking quotes.',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<ServiceTier>(
                    initialValue: selectedTier,
                    decoration: const InputDecoration(
                      labelText: 'Service Tier',
                      filled: true,
                      fillColor: Color(0xFF14241B),
                    ),
                    dropdownColor: const Color(0xFF14241B),
                    items: ServiceTier.values.map((tier) {
                      return DropdownMenuItem(
                        value: tier,
                        child: Text(tier.label, style: const TextStyle(color: Colors.white)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        setModalState(() => selectedTier = val);
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: baseFareController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Base Fare (₦)',
                            filled: true,
                            fillColor: Color(0xFF14241B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: perKmController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Per KM (₦)',
                            filled: true,
                            fillColor: Color(0xFF14241B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: perMinController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Per Min (₦)',
                            filled: true,
                            fillColor: Color(0xFF14241B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: minFareController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Minimum Fare (₦)',
                            filled: true,
                            fillColor: Color(0xFF14241B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                      labelText: 'Governance Audit Notes',
                      filled: true,
                      fillColor: Color(0xFF14241B),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddRideOptionModal(BuildContext context) {
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final baseFareController = TextEditingController(text: '3000');
    final capacityController = TextEditingController(text: '4');
    final etaController = TextEditingController(text: '3');
    final featuresController = TextEditingController(text: 'AC, Extra Legroom, Zero Emission');
    final descController = TextEditingController();
    String vehicleType = 'electric_car';

    showDialog<void>(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AdminModalDialog(
              title: 'Add New Ride Option',
              icon: Icons.electric_car_outlined,
              primaryActionLabel: 'Save Ride Option',
              onPrimaryAction: () {
                final baseKobo = ((double.tryParse(baseFareController.text) ?? 3000) * 100).round();
                final capacity = int.tryParse(capacityController.text) ?? (vehicleType == 'electric_bike' ? 1 : 4);
                final eta = int.tryParse(etaController.text) ?? 3;
                final features = featuresController.text
                    .split(',')
                    .map((s) => s.trim())
                    .where((s) => s.isNotEmpty)
                    .toList();

                final category = RideCategoryDto(
                  id: 'cat_${codeController.text.trim().toLowerCase().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}',
                  code: codeController.text.trim().toLowerCase().replaceAll(' ', '_'),
                  name: nameController.text.trim().isNotEmpty ? nameController.text.trim() : 'New Ride Option',
                  description: descController.text.trim().isNotEmpty ? descController.text.trim() : 'Eco-friendly electric ride',
                  passengerCapacity: capacity,
                  capacityLabel: '$capacity Seat${capacity > 1 ? 's' : ''}',
                  baseFareKobo: baseKobo,
                  etaMinutes: eta,
                  features: features.isNotEmpty ? features : ['AC', 'Zero Emission'],
                  iconKey: vehicleType,
                  isAvailable: true,
                  displayOrder: ref.read(pricingNotifierProvider).rideCategories.length + 1,
                  co2OffsetGrams: vehicleType == 'electric_bike' ? 450 : 850,
                );

                ref.read(pricingNotifierProvider.notifier).addRideCategory(category);
                Navigator.pop(dialogCtx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Added "${category.name}" to ride catalogue.')),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Configure an admin-managed ride category that customers can book on the mobile app (§5.4 & §6.8.1).',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          key: const Key('add_category_name_field'),
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: 'Display Name (e.g. GoRide Express)',
                            filled: true,
                            fillColor: Color(0xFF14241B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          key: const Key('add_category_code_field'),
                          controller: codeController,
                          decoration: const InputDecoration(
                            labelText: 'Category Code (e.g. express)',
                            filled: true,
                            fillColor: Color(0xFF14241B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          key: const Key('add_category_type_dropdown'),
                          initialValue: vehicleType,
                          decoration: const InputDecoration(
                            labelText: 'Vehicle Type',
                            filled: true,
                            fillColor: Color(0xFF14241B),
                          ),
                          dropdownColor: const Color(0xFF14241B),
                          items: const [
                            DropdownMenuItem(
                              value: 'electric_bike',
                              child: Text('🏍️ Electric Two-Wheeler (Bike)', style: TextStyle(color: Colors.white)),
                            ),
                            DropdownMenuItem(
                              value: 'electric_car',
                              child: Text('🚗 Electric Four-Wheeler (Car)', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setModalState(() {
                                vehicleType = val;
                                if (val == 'electric_bike' && capacityController.text == '4') {
                                  capacityController.text = '1';
                                }
                              });
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          key: const Key('add_category_base_fare_field'),
                          controller: baseFareController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Base Fare (₦)',
                            filled: true,
                            fillColor: Color(0xFF14241B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          key: const Key('add_category_capacity_field'),
                          controller: capacityController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Seats / Capacity',
                            filled: true,
                            fillColor: Color(0xFF14241B),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          key: const Key('add_category_eta_field'),
                          controller: etaController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Typical ETA (minutes)',
                            filled: true,
                            fillColor: Color(0xFF14241B),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('add_category_features_field'),
                    controller: featuresController,
                    decoration: const InputDecoration(
                      labelText: 'Features (comma separated)',
                      hintText: 'AC, Extra legroom, Zero emission',
                      filled: true,
                      fillColor: Color(0xFF14241B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    key: const Key('add_category_desc_field'),
                    controller: descController,
                    decoration: const InputDecoration(
                      labelText: 'Description',
                      filled: true,
                      fillColor: Color(0xFF14241B),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final pricingState = ref.watch(pricingNotifierProvider);
    final activeRule = pricingState.activeRule;

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
                      'Pricing Engine & Service Areas',
                      style: GVTypography.h2.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Version-controlled tariffs, zone-level tier gating, and immutable past quote safety (§5.3)',
                      style: GVTypography.bodySmall.copyWith(color: Colors.white60),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: GVSpacing.md),
              OutlinedButton.icon(
                key: const Key('add_ride_option_top_btn'),
                onPressed: () => _showAddRideOptionModal(context),
                icon: const Icon(Icons.electric_car, size: 18, color: GVColors.brandGreen),
                label: const Text('Add Ride Option', style: TextStyle(color: Colors.white)),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: GVColors.brandGreen),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
              const SizedBox(width: GVSpacing.sm),
              ElevatedButton.icon(
                key: const Key('create_draft_pricing_btn'),
                onPressed: () => _showCreateDraftModal(context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Create Draft Version'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GVColors.brandGreen,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: GVSpacing.lg),

          // KPIs
          Row(
            children: [
              Expanded(
                child: AdminKpiCard(
                  title: 'Active Tariff Version',
                  value: activeRule != null ? '${activeRule.tier.label} ${activeRule.version}' : 'None',
                  subtitle: 'Immutable snapshots guaranteed',
                  icon: Icons.verified_outlined,
                  accentColor: GVColors.brandGreen,
                ),
              ),
              const SizedBox(width: GVSpacing.md),
              Expanded(
                child: AdminKpiCard(
                  title: 'Base Fare',
                  value: activeRule?.formattedBaseFare ?? '₦0',
                  subtitle: 'Starting tariff before distance',
                  icon: Icons.start_outlined,
                  accentColor: Colors.blueAccent,
                ),
              ),
              const SizedBox(width: GVSpacing.md),
              Expanded(
                child: AdminKpiCard(
                  title: 'Per KM / Per Min',
                  value: activeRule != null ? '${activeRule.formattedPerKm} · ${activeRule.formattedPerMinute}' : '₦0',
                  subtitle: 'Continuous metered rate',
                  icon: Icons.speed_outlined,
                  accentColor: Colors.amberAccent,
                ),
              ),
              const SizedBox(width: GVSpacing.md),
              Expanded(
                child: AdminKpiCard(
                  title: 'Surge Multiplier Cap',
                  value: '${activeRule?.surgeMultiplierCap ?? 1.0}x Max',
                  subtitle: 'Strict safety cap against gouging',
                  icon: Icons.electric_bolt_outlined,
                  accentColor: Colors.purpleAccent,
                ),
              ),
            ],
          ),
          const SizedBox(height: GVSpacing.xl),

          // Service Tier Filter Chips
          Wrap(
            spacing: 8,
            children: ServiceTier.values.map((tier) {
              final isSelected = pricingState.selectedTier == tier;
              return FilterChip(
                label: Text(tier.label),
                selected: isSelected,
                selectedColor: GVColors.brandGreen.withValues(alpha: 0.3),
                checkmarkColor: GVColors.brandGreen,
                labelStyle: TextStyle(
                  color: isSelected ? GVColors.brandGreen : Colors.white70,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                backgroundColor: const Color(0xFF14241B),
                onSelected: (selected) {
                  if (selected) {
                    ref.read(pricingNotifierProvider.notifier).selectTier(tier);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: GVSpacing.md),

          // Pricing Version History Table
          Container(
            padding: const EdgeInsets.all(GVSpacing.md),
            decoration: BoxDecoration(
              color: const Color(0xFF101713),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1F2B25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tariff Version Registry (${pricingState.selectedTier.label})',
                      style: GVTypography.h3.copyWith(color: Colors.white),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: GVColors.brandGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: GVColors.brandGreen),
                      ),
                      child: const Text(
                        'Past quotes immutable',
                        style: TextStyle(color: GVColors.brandGreen, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: GVSpacing.md),
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1.2),
                    1: FlexColumnWidth(1.8),
                    2: FlexColumnWidth(1.2),
                    3: FlexColumnWidth(1.2),
                    4: FlexColumnWidth(1.0),
                    5: FlexColumnWidth(1.4),
                    6: FlexColumnWidth(1.6),
                  },
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0xFF1F2B25))),
                      ),
                      children: [
                        _headerCell('VERSION'),
                        _headerCell('EFFECTIVE DATE'),
                        _headerCell('BASE FARE'),
                        _headerCell('RATES'),
                        _headerCell('SURGE CAP'),
                        _headerCell('STATUS'),
                        _headerCell('ACTION'),
                      ],
                    ),
                    ...pricingState.rules
                        .where((r) => r.tier == pricingState.selectedTier)
                        .map((rule) {
                      Color statusColor;
                      switch (rule.status) {
                        case PricingRuleStatus.active:
                          statusColor = GVColors.brandGreen;
                          break;
                        case PricingRuleStatus.draft:
                          statusColor = Colors.amber;
                          break;
                        case PricingRuleStatus.archived:
                          statusColor = Colors.white38;
                          break;
                      }

                      return TableRow(
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xFF18221D))),
                        ),
                        children: [
                          _dataCell(
                            Text(rule.version, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                          ),
                          _dataCell(
                            Text(_dateFormat.format(rule.effectiveDate), style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          ),
                          _dataCell(
                            Text(rule.formattedBaseFare, style: const TextStyle(color: Colors.white)),
                          ),
                          _dataCell(
                            Text('${rule.formattedPerKm}\n${rule.formattedPerMinute}', style: const TextStyle(color: Colors.white70, fontSize: 11)),
                          ),
                          _dataCell(
                            Text('${rule.surgeMultiplierCap}x', style: const TextStyle(color: Colors.white)),
                          ),
                          _dataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: statusColor),
                              ),
                              child: Text(
                                rule.status.name.toUpperCase(),
                                style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          _dataCell(
                            rule.status == PricingRuleStatus.draft
                                ? ElevatedButton(
                                    key: Key('publish_btn_${rule.id}'),
                                    onPressed: () {
                                      ref.read(pricingNotifierProvider.notifier).publishDraftRule(rule.id);
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Version ${rule.version} published.')),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: GVColors.brandGreen,
                                      foregroundColor: Colors.black,
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      minimumSize: const Size(60, 28),
                                    ),
                                    child: const Text('Publish', style: TextStyle(fontSize: 11)),
                                  )
                                : const Text('—', style: TextStyle(color: Colors.white38)),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: GVSpacing.xl),

          // Published Customer Ride Options Catalogue (v1.3 §5.4 & §6.8.1)
          Container(
            padding: const EdgeInsets.all(GVSpacing.md),
            decoration: BoxDecoration(
              color: const Color(0xFF101713),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1F2B25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Published Ride Options Catalogue (Customer App)',
                            style: GVTypography.h3.copyWith(color: Colors.white),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Dynamic vehicle options fetched and displayed in customer app (§5.4 & §6.8.1).',
                            style: TextStyle(color: Colors.white60, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: GVSpacing.md),
                    ElevatedButton.icon(
                      key: const Key('add_ride_option_section_btn'),
                      onPressed: () => _showAddRideOptionModal(context),
                      icon: const Icon(Icons.add, size: 16),
                      label: const Text('Add Ride Option', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: GVColors.brandGreen,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: GVSpacing.md),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    _kpiChip(
                      label: 'Total Options',
                      value: '${pricingState.rideCategories.length}',
                      color: Colors.white70,
                    ),
                    _kpiChip(
                      label: '🏍️ Electric Bikes',
                      value: '${pricingState.rideCategories.where((c) => c.iconKey == 'electric_bike').length}',
                      color: Colors.tealAccent,
                    ),
                    _kpiChip(
                      label: '🚗 Electric Cars',
                      value: '${pricingState.rideCategories.where((c) => c.iconKey != 'electric_bike').length}',
                      color: Colors.blueAccent,
                    ),
                    _kpiChip(
                      label: 'Live in Customer App',
                      value: '${pricingState.rideCategories.where((c) => c.isAvailable).length}',
                      color: GVColors.brandGreen,
                    ),
                  ],
                ),
                const SizedBox(height: GVSpacing.md),
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(1.6),
                    1: FlexColumnWidth(1.8),
                    2: FlexColumnWidth(1.4),
                    3: FlexColumnWidth(1.1),
                    4: FlexColumnWidth(2.0),
                    5: FlexColumnWidth(1.3),
                  },
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(
                        border: Border(bottom: BorderSide(color: Color(0xFF1F2B25))),
                      ),
                      children: [
                        _headerCell('VEHICLE TYPE'),
                        _headerCell('NAME & CODE'),
                        _headerCell('CAPACITY & ETA'),
                        _headerCell('BASE FARE'),
                        _headerCell('FEATURES'),
                        _headerCell('STATUS / LIVE'),
                      ],
                    ),
                    ...pricingState.rideCategories.map((category) {
                      final isBike = category.iconKey == 'electric_bike';
                      return TableRow(
                        decoration: const BoxDecoration(
                          border: Border(bottom: BorderSide(color: Color(0xFF18221D))),
                        ),
                        children: [
                          _dataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: (isBike ? Colors.teal : GVColors.brandGreen).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Icon(
                                    isBike ? Icons.two_wheeler_rounded : Icons.directions_car_rounded,
                                    size: 18,
                                    color: isBike ? Colors.tealAccent : GVColors.brandGreen,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    isBike ? 'Electric Bike' : 'Electric Car',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: isBike ? Colors.tealAccent : Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _dataCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.name,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  category.code,
                                  style: const TextStyle(
                                    color: Colors.white54,
                                    fontSize: 11,
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          _dataCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.capacityLabel,
                                  style: const TextStyle(color: Colors.white, fontSize: 12),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '~${category.etaMinutes} min away',
                                  style: const TextStyle(color: GVColors.brandGreen, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          _dataCell(
                            Text(
                              category.formattedPrice,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          _dataCell(
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: category.features.map((feat) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1B2B20),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: const Color(0xFF263F30)),
                                  ),
                                  child: Text(
                                    feat,
                                    style: const TextStyle(color: Colors.white70, fontSize: 10),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          _dataCell(
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Switch(
                                  key: Key('toggle_ride_cat_${category.id}'),
                                  value: category.isAvailable,
                                  activeThumbColor: GVColors.brandGreen,
                                  onChanged: (val) {
                                    ref.read(pricingNotifierProvider.notifier).toggleRideCategory(category.id, val);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          '${category.name} is now ${val ? "active" : "disabled"} for customers.',
                                        ),
                                      ),
                                    );
                                  },
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  category.isAvailable ? 'LIVE' : 'OFF',
                                  style: TextStyle(
                                    color: category.isAvailable ? GVColors.brandGreen : Colors.white38,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: GVSpacing.xl),

          // Zone Service Tier Gating Matrix
          Container(
            padding: const EdgeInsets.all(GVSpacing.md),
            decoration: BoxDecoration(
              color: const Color(0xFF101713),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF1F2B25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Service Area Gating & Dynamic Surge Override',
                  style: GVTypography.h3.copyWith(color: Colors.white),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Control active service tiers per operational zone (e.g. enable School-Run Chaperone in vetted corridors)',
                  style: TextStyle(color: Colors.white60, fontSize: 12),
                ),
                const SizedBox(height: GVSpacing.md),
                ...pricingState.zones.map((zone) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF14241B),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF274332)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 3,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                zone.zoneName,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${zone.city} · ${zone.activeRidersCount} Active Riders Online',
                                style: const TextStyle(color: Colors.white60, fontSize: 11),
                              ),
                            ],
                          ),
                        ),
                        // Current Surge Indicator
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: zone.currentSurgeMultiplier > 1.0
                                ? Colors.amber.withValues(alpha: 0.2)
                                : GVColors.brandGreen.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: zone.currentSurgeMultiplier > 1.0 ? Colors.amber : GVColors.brandGreen,
                            ),
                          ),
                          child: Text(
                            'Surge: ${zone.currentSurgeMultiplier}x',
                            style: TextStyle(
                              color: zone.currentSurgeMultiplier > 1.0 ? Colors.amber : GVColors.brandGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Service Tier Toggles
                        Expanded(
                          flex: 5,
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 8,
                            children: ServiceTier.values.map((tier) {
                              final isEnabled = zone.isTierEnabled(tier);
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    tier.label,
                                    style: TextStyle(
                                      color: isEnabled ? Colors.white : Colors.white38,
                                      fontSize: 11,
                                    ),
                                  ),
                                  Switch(
                                    key: Key('toggle_${zone.zoneId}_${tier.name}'),
                                    value: isEnabled,
                                    activeThumbColor: GVColors.brandGreen,
                                    onChanged: (val) {
                                      ref.read(pricingNotifierProvider.notifier).toggleZoneServiceTier(
                                            zone.zoneId,
                                            tier,
                                            val,
                                          );
                                    },
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerCell(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Text(
        title,
        style: GVTypography.caption.copyWith(
          color: Colors.white38,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _dataCell(Widget child) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: child,
    );
  }

  Widget _kpiChip({required String label, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF14241B),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF233B2C)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
          const SizedBox(width: 6),
          Text(
            value,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
