import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/onboarding_notifier.dart';

/// Screen RD04: Vehicle Information & Photo Upload (Board 1 Screen 4).
class RiderVehicleInfoScreen extends ConsumerStatefulWidget {
  const RiderVehicleInfoScreen({super.key});

  @override
  ConsumerState<RiderVehicleInfoScreen> createState() =>
      _RiderVehicleInfoScreenState();
}

class _RiderVehicleInfoScreenState
    extends ConsumerState<RiderVehicleInfoScreen> {
  final _formKey = GlobalKey<FormState>();

  GVVehicleType _selectedType = GVVehicleType.motorbike;
  String _selectedBrand = 'Bajaj';
  String _selectedModel = 'Boxer 150';
  String _selectedColor = 'Black';
  late final TextEditingController _plateController;

  bool _hasSidePhoto = true;
  bool _hasPlatePhoto = true;

  final List<String> _brands = ['Bajaj', 'Spiro EV', 'TVS', 'Max EV', 'Toyota'];
  final List<String> _models = ['Boxer 150', 'Commando EV', 'HLX 125', 'Corolla', 'King 200'];
  final List<String> _colors = ['Black', 'Green', 'White', 'Blue', 'Silver'];

  @override
  void initState() {
    super.initState();
    final state = ref.read(onboardingNotifierProvider);
    _plateController = TextEditingController(
      text: state.vehiclePlate.isNotEmpty ? state.vehiclePlate : 'ABC 123 XY',
    );
  }

  @override
  void dispose() {
    _plateController.dispose();
    super.dispose();
  }

  void _handleSaveAndContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(onboardingNotifierProvider.notifier).updateVehicleDetails(
            vehicleType: _selectedType == GVVehicleType.car
                ? VehicleType.electricVan
                : _selectedType == GVVehicleType.tricycle
                    ? VehicleType.electricTricycle
                    : VehicleType.electricBike,
            vehiclePlate: _plateController.text.trim().toUpperCase(),
            vehicleModel: '$_selectedBrand $_selectedModel',
            chassisNumber: 'CH-EV-${_plateController.text.trim().toUpperCase()}',
            batteryCapacityKwh: 'Dual 3.2 kWh Swappable Lithium Iron (LFP)',
          );
      context.push('/onboarding/review');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GVColors.darkBg,
      appBar: AppBar(
        backgroundColor: GVColors.darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: GVSpacing.sm),
                Text(
                  'Vehicle Information',
                  style: GVTypography.h2.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: GVSpacing.xs),
                Text(
                  'Add your vehicle details',
                  style: GVTypography.bodyMedium.copyWith(color: Colors.white60),
                ),
                const SizedBox(height: GVSpacing.lg),

                // Vehicle Category Selector (Motorbike, Car, Tricycle)
                GVVehicleCategorySelector(
                  selectedType: _selectedType,
                  onTypeSelected: (type) {
                    setState(() {
                      _selectedType = type;
                    });
                  },
                ),
                const SizedBox(height: GVSpacing.xl),

                // Vehicle Brand Dropdown
                _buildFieldLabel('Vehicle Brand'),
                _buildDropdown(
                  value: _selectedBrand,
                  items: _brands,
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedBrand = val);
                  },
                ),
                const SizedBox(height: GVSpacing.md),

                // Vehicle Model Dropdown
                _buildFieldLabel('Vehicle Model'),
                _buildDropdown(
                  value: _selectedModel,
                  items: _models,
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedModel = val);
                  },
                ),
                const SizedBox(height: GVSpacing.md),

                // Plate Number
                _buildFieldLabel('Plate Number'),
                TextFormField(
                  controller: _plateController,
                  textCapitalization: TextCapitalization.characters,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    hintText: 'ABC 123 XY',
                    hintStyle: const TextStyle(color: Colors.white38),
                    filled: true,
                    fillColor: const Color(0xFF1C2420),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(GVBorderRadius.md),
                      borderSide: const BorderSide(color: Color(0xFF2A3630)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(GVBorderRadius.md),
                      borderSide: const BorderSide(color: Color(0xFF2A3630)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(GVBorderRadius.md),
                      borderSide: const BorderSide(color: GVColors.brandGreen, width: 1.5),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Plate number is required' : null,
                ),
                const SizedBox(height: GVSpacing.md),

                // Vehicle Color Dropdown
                _buildFieldLabel('Vehicle Color'),
                _buildDropdown(
                  value: _selectedColor,
                  items: _colors,
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedColor = val);
                  },
                ),
                const SizedBox(height: GVSpacing.xl),

                // Upload Vehicle Photo Section
                Text(
                  'Upload Vehicle Photo',
                  style: GVTypography.bodyMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: GVSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: _buildPhotoUploadCard(
                        label: 'Side View',
                        icon: Icons.two_wheeler,
                        hasPhoto: _hasSidePhoto,
                        onRemove: () => setState(() => _hasSidePhoto = !_hasSidePhoto),
                      ),
                    ),
                    const SizedBox(width: GVSpacing.md),
                    Expanded(
                      child: _buildPhotoUploadCard(
                        label: 'Plate Number',
                        icon: Icons.pin,
                        hasPhoto: _hasPlatePhoto,
                        onRemove: () => setState(() => _hasPlatePhoto = !_hasPlatePhoto),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: GVSpacing.xxl),

                // Save & Continue Button
                GVPrimaryButton(
                  label: 'Save & Continue',
                  onPressed: _handleSaveAndContinue,
                ),
                const SizedBox(height: GVSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: GVTypography.caption.copyWith(
          color: Colors.white70,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1C2420),
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        border: Border.all(color: const Color(0xFF2A3630)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          dropdownColor: const Color(0xFF1C2420),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white60),
          isExpanded: true,
          style: const TextStyle(color: Colors.white, fontSize: 15),
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildPhotoUploadCard({
    required String label,
    required IconData icon,
    required bool hasPhoto,
    required VoidCallback onRemove,
  }) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 110,
              decoration: BoxDecoration(
                color: const Color(0xFF141917),
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                border: Border.all(
                  color: hasPhoto ? GVColors.brandGreen : const Color(0xFF2A3630),
                  width: hasPhoto ? 1.5 : 1,
                ),
                gradient: hasPhoto
                    ? LinearGradient(
                        colors: [
                          GVColors.deepGreen.withValues(alpha: 0.3),
                          const Color(0xFF141917),
                        ],
                      )
                    : null,
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: hasPhoto ? GVColors.brandGreen : Colors.white38,
                  size: 40,
                ),
              ),
            ),
            if (hasPhoto)
              Positioned(
                top: 6,
                right: 6,
                child: InkWell(
                  onTap: onRemove,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Color(0xFF1C2420),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white70,
                      size: 14,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GVTypography.caption.copyWith(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
