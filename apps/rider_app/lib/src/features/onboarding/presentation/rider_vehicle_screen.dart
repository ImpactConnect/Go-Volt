import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/onboarding_notifier.dart';

/// Screen RD05: Electric Vehicle Specification & Roadworthiness Inspection.
class RiderVehicleScreen extends ConsumerStatefulWidget {
  const RiderVehicleScreen({super.key});

  @override
  ConsumerState<RiderVehicleScreen> createState() => _RiderVehicleScreenState();
}

class _RiderVehicleScreenState extends ConsumerState<RiderVehicleScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _plateCtrl;
  late TextEditingController _modelCtrl;
  late TextEditingController _chassisCtrl;

  VehicleType _selectedType = VehicleType.electricBike;
  final String _batteryConfig = 'Dual 3.2 kWh Swappable Lithium Iron (LFP)';

  bool _brakesInspected = true;
  bool _lightsInspected = true;
  bool _helmetAvailable = true;
  bool _gpsTrackerLinked = true;

  @override
  void initState() {
    super.initState();
    final state = ref.read(onboardingNotifierProvider);
    _plateCtrl = TextEditingController(
      text: state.vehiclePlate.isNotEmpty ? state.vehiclePlate : 'LA-482-VI',
    );
    _modelCtrl = TextEditingController(
      text: state.vehicleModel.isNotEmpty
          ? state.vehicleModel
          : 'Spiro Commando EV',
    );
    _chassisCtrl = TextEditingController(
      text: state.chassisNumber.isNotEmpty
          ? state.chassisNumber
          : 'CH-EV-LAG-98214',
    );
    _selectedType = state.vehicleType;
  }

  @override
  void dispose() {
    _plateCtrl.dispose();
    _modelCtrl.dispose();
    _chassisCtrl.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(onboardingNotifierProvider.notifier).updateVehicleDetails(
            vehicleType: _selectedType,
            vehiclePlate: _plateCtrl.text.trim().toUpperCase(),
            vehicleModel: _modelCtrl.text.trim(),
            chassisNumber: _chassisCtrl.text.trim().toUpperCase(),
            batteryCapacityKwh: _batteryConfig,
          );
      context.push('/onboarding/guarantor');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider Application'),
        backgroundColor: GVColors.darkBg,
        elevation: 0,
      ),
      backgroundColor: GVColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            const LinearProgressIndicator(
              value: 0.60,
              backgroundColor: Color(0xFF232D28),
              valueColor: AlwaysStoppedAnimation(GVColors.brandGreen),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: GVSpacing.md,
                vertical: GVSpacing.xs,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Step 3 of 5: Vehicle Details',
                      style: GVTypography.caption.copyWith(
                        color: GVColors.brandGreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '60% completed',
                    style: GVTypography.caption.copyWith(color: Colors.white54),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF232D28), height: 1),

            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(GVSpacing.md),
                  children: [
                    Text(
                      'Electric Vehicle & Roadworthiness',
                      style: GVTypography.h2.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: GVSpacing.xs),
                    Text(
                      'All Go-Volts fleet vehicles must be 100% battery-electric and equipped with compatible hot-swap modules.',
                      style: GVTypography.caption.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: GVSpacing.lg),

                    // Vehicle Type Selector Cards
                    Text(
                      'Select Vehicle Category *',
                      style: GVTypography.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: GVSpacing.xs),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTypeCard(
                            type: VehicleType.electricBike,
                            title: 'EV Bike',
                            icon: Icons.two_wheeler,
                            desc: 'Motorcycle (Rides & Parcels)',
                          ),
                        ),
                        const SizedBox(width: GVSpacing.sm),
                        Expanded(
                          child: _buildTypeCard(
                            type: VehicleType.electricTricycle,
                            title: 'EV Trike',
                            icon: Icons.electric_rickshaw,
                            desc: 'Cargo & School Run (100kg)',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: GVSpacing.md),

                    // Vehicle Plate Number
                    TextFormField(
                      controller: _plateCtrl,
                      style: const TextStyle(
                        color: Colors.white,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                      ),
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Lagos State License Plate Number *',
                        prefixIcon: Icon(
                          Icons.badge,
                          color: GVColors.brandGreen,
                        ),
                        hintText: 'e.g. LA-482-VI or EKY-290-AA',
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'License plate is required' : null,
                    ),
                    const SizedBox(height: GVSpacing.md),

                    // Vehicle Make & Model
                    TextFormField(
                      controller: _modelCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Vehicle Make & Model *',
                        prefixIcon: Icon(
                          Icons.electric_moped,
                          color: GVColors.brandGreen,
                        ),
                        hintText: 'e.g. Spiro Commando EV / Roam Air',
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Make & model required' : null,
                    ),
                    const SizedBox(height: GVSpacing.md),

                    // Chassis / Frame Number
                    TextFormField(
                      controller: _chassisCtrl,
                      style: const TextStyle(color: Colors.white),
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Chassis / Motor VIN Number *',
                        prefixIcon: Icon(
                          Icons.confirmation_number,
                          color: GVColors.brandGreen,
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Chassis number required' : null,
                    ),
                    const SizedBox(height: GVSpacing.lg),

                    // Battery Configuration Card
                    Container(
                      padding: const EdgeInsets.all(GVSpacing.md),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C2420),
                        borderRadius: BorderRadius.circular(GVBorderRadius.md),
                        border: Border.all(color: const Color(0xFF2A3630)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.battery_charging_full,
                                color: GVColors.brandGreen,
                                size: 22,
                              ),
                              const SizedBox(width: GVSpacing.xs),
                              Expanded(
                                child: Text(
                                  'Swappable Battery System',
                                  style: GVTypography.bodyMedium.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: GVSpacing.xs),
                          Text(
                            'Config: $_batteryConfig (Compatible with all 25+ Lagos swap kiosks)',
                            style: GVTypography.caption.copyWith(
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: GVSpacing.lg),

                    // Safety Checklist
                    Text(
                      'Physical Safety Inspection Checklist',
                      style: GVTypography.bodyMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: GVSpacing.xs),
                    _buildCheckItem(
                      'Hydraulic Disc Brakes & Regenerative Braking',
                      _brakesInspected,
                      (val) => setState(() => _brakesInspected = val ?? true),
                    ),
                    _buildCheckItem(
                      'LED Headlights, Indicators & Brake Lights',
                      _lightsInspected,
                      (val) => setState(() => _lightsInspected = val ?? true),
                    ),
                    _buildCheckItem(
                      'DOT/ECE Certified Helmet & High-Vis Vest',
                      _helmetAvailable,
                      (val) => setState(() => _helmetAvailable = val ?? true),
                    ),
                    _buildCheckItem(
                      'Go-Volts IoT GPS Telematics Linked',
                      _gpsTrackerLinked,
                      (val) => setState(() => _gpsTrackerLinked = val ?? true),
                    ),
                    const SizedBox(height: GVSpacing.xl),
                  ],
                ),
              ),
            ),

            // Next CTA
            Padding(
              padding: const EdgeInsets.all(GVSpacing.md),
              child: GVPrimaryButton(
                label: 'Save & Continue to Guarantor',
                onPressed: _handleNext,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeCard({
    required VehicleType type,
    required String title,
    required IconData icon,
    required String desc,
  }) {
    final isSelected = _selectedType == type;

    return InkWell(
      onTap: () => setState(() => _selectedType = type),
      borderRadius: BorderRadius.circular(GVBorderRadius.md),
      child: Container(
        padding: const EdgeInsets.all(GVSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? GVColors.deepGreen : const Color(0xFF1C2420),
          borderRadius: BorderRadius.circular(GVBorderRadius.md),
          border: Border.all(
            color: isSelected ? GVColors.brandGreen : const Color(0xFF2A3630),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? GVColors.brandGreen : Colors.white70,
              size: 32,
            ),
            const SizedBox(height: GVSpacing.xs),
            Text(
              title,
              style: GVTypography.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              desc,
              textAlign: TextAlign.center,
              style: GVTypography.caption.copyWith(color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(
    String title,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      activeColor: GVColors.brandGreen,
      checkColor: GVColors.deepGreen,
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: GVTypography.caption.copyWith(color: Colors.white),
      ),
    );
  }
}
