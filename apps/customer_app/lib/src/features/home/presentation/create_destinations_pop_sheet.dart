import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../application/home_notifier.dart';
import '../../../features/auth/data/operating_location_repository.dart';

/// Pop screen presented to prompt the user to create and save frequent destinations.
/// Matches Go-Volts Design Language and Specification.
class CreateDestinationsPopSheet extends ConsumerStatefulWidget {
  const CreateDestinationsPopSheet({super.key});

  /// Presents the bottom sheet modal.
  static Future<SavedPlaceDto?> show(BuildContext context) {
    return showModalBottomSheet<SavedPlaceDto>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const CreateDestinationsPopSheet(),
    );
  }

  @override
  ConsumerState<CreateDestinationsPopSheet> createState() =>
      _CreateDestinationsPopSheetState();
}

class _CreateDestinationsPopSheetState
    extends ConsumerState<CreateDestinationsPopSheet> {
  SavedPlaceType _selectedType = SavedPlaceType.home;
  late final TextEditingController _labelController;
  late final TextEditingController _addressController;
  double _selectedLat = 6.8403; // Shagamu, Ogun default
  double _selectedLng = 3.6487;
  String? _errorText;

  // Quick locations are loaded from the operating_locations DB.
  // No hardcoded city names.

  @override
  void initState() {
    super.initState();
    _labelController = TextEditingController(text: 'Home');
    _addressController = TextEditingController();
  }

  @override
  void dispose() {
    _labelController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _onTypeChanged(SavedPlaceType type) {
    setState(() {
      _selectedType = type;
      if (type == SavedPlaceType.home) {
        _labelController.text = 'Home';
      } else if (type == SavedPlaceType.work) {
        _labelController.text = 'Work';
      } else if (_labelController.text == 'Home' ||
          _labelController.text == 'Work') {
        _labelController.text = '';
      }
      _errorText = null;
    });
  }

  void _saveDestination() {
    final label = _labelController.text.trim();
    final address = _addressController.text.trim();

    if (label.isEmpty) {
      setState(() => _errorText = 'Please enter a label for this place.');
      return;
    }
    if (address.isEmpty) {
      setState(() => _errorText = 'Please enter or select a street address.');
      return;
    }

    final newPlace = SavedPlaceDto(
      id: 'saved_${DateTime.now().millisecondsSinceEpoch}',
      label: label,
      address: address,
      type: _selectedType,
      latitude: _selectedLat,
      longitude: _selectedLng,
    );

    ref.read(homeNotifierProvider.notifier).addSavedPlace(newPlace);

    Navigator.of(context).pop(newPlace);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('"$label" saved to your frequent destinations!'),
        backgroundColor: GVColors.brandGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? const Color(0xFF141B17) : Colors.white;
    final textPrimary = isDark ? Colors.white : GVColors.textPrimary;
    final textSecondary = isDark ? GVColors.neutral400 : GVColors.textSecondary;
    final borderColor = isDark ? const Color(0xFF2A3630) : GVColors.border;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: GVShadows.elevated,
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),
                // Drag handle
                Center(
                  child: Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Icon + Header Row
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: GVColors.brandGreen.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.bookmark_add_rounded,
                          color: GVColors.brandGreen,
                          size: 26,
                        ),
                      ),
                    ),
                    const SizedBox(width: GVSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Save Frequent Destinations',
                            style: GVTypography.h2.copyWith(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Quick 1-tap bookings for your regular trips',
                            style: GVTypography.caption.copyWith(
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: textSecondary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: GVSpacing.lg),

                // Destination Type Selector
                Text(
                  'Choose Destination Type',
                  style: GVTypography.labelLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: GVSpacing.sm),
                Row(
                  children: [
                    _buildTypeChip(
                      type: SavedPlaceType.home,
                      icon: Icons.home_rounded,
                      label: 'Home',
                      isDark: isDark,
                    ),
                    const SizedBox(width: GVSpacing.sm),
                    _buildTypeChip(
                      type: SavedPlaceType.work,
                      icon: Icons.work_rounded,
                      label: 'Work',
                      isDark: isDark,
                    ),
                    const SizedBox(width: GVSpacing.sm),
                    _buildTypeChip(
                      type: SavedPlaceType.custom,
                      icon: Icons.place_rounded,
                      label: 'Custom',
                      isDark: isDark,
                    ),
                  ],
                ),
                const SizedBox(height: GVSpacing.md),

                // Place Label Input
                Text(
                  'Destination Label',
                  style: GVTypography.bodySmallMedium.copyWith(
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _labelController,
                  style: TextStyle(color: textPrimary),
                  decoration: InputDecoration(
                    hintText: 'e.g. Home, Work, Gym, School',
                    hintStyle: TextStyle(color: textSecondary),
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF1C2420)
                        : GVColors.softBackground,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: GVColors.brandGreen,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: GVSpacing.md),

                // Street Address Input
                Text(
                  'Street Address or Landmark',
                  style: GVTypography.bodySmallMedium.copyWith(
                    color: textPrimary,
                  ),
                ),
                const SizedBox(height: 6),
                TextField(
                  controller: _addressController,
                  style: TextStyle(color: textPrimary),
                  decoration: InputDecoration(
                    hintText: 'Enter street address, building or area',
                    hintStyle: TextStyle(color: textSecondary),
                    prefixIcon: const Icon(
                      Icons.location_on_outlined,
                      color: GVColors.brandGreen,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF1C2420)
                        : GVColors.softBackground,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: borderColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: GVColors.brandGreen,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: GVSpacing.sm),

                // Quick locations from operating areas
                Consumer(
                  builder: (context, ref, _) {
                    final locationsAsync =
                        ref.watch(operatingLocationsProvider);
                    return locationsAsync.when(
                      data: (locations) {
                        if (locations.isEmpty) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Quick popular locations:',
                              style: GVTypography.caption
                                  .copyWith(color: textSecondary),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              spacing: 8,
                              runSpacing: 6,
                              children: locations.map((loc) {
                                return ActionChip(
                                  label: Text(
                                    loc.city,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: isDark
                                          ? Colors.white
                                          : GVColors.nearBlack,
                                    ),
                                  ),
                                  backgroundColor: isDark
                                      ? const Color(0xFF1F2B24)
                                      : GVColors.brandGreen
                                          .withValues(alpha: 0.08),
                                  side: BorderSide(
                                    color: isDark
                                        ? const Color(0xFF2A3A30)
                                        : GVColors.brandGreen
                                            .withValues(alpha: 0.25),
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _addressController.text =
                                          '${loc.city}, ${loc.state}';
                                      _selectedLat =
                                          loc.centerLat ?? 6.8403;
                                      _selectedLng =
                                          loc.centerLng ?? 3.6487;
                                      _errorText = null;
                                    });
                                  },
                                );
                              }).toList(),
                            ),
                          ],
                        );
                      },
                      loading: () => const SizedBox.shrink(),
                      error: (e, s) => const SizedBox.shrink(),
                    );
                  },
                ),

                // Error Message if any
                if (_errorText != null) ...[
                  const SizedBox(height: GVSpacing.sm),
                  Text(
                    _errorText!,
                    style: const TextStyle(
                      color: GVColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],

                const SizedBox(height: GVSpacing.lg),

                // Save Button
                GVPrimaryButton(
                  label: 'Save Destination',
                  onPressed: _saveDestination,
                ),
                const SizedBox(height: 8),

                // Skip / Later Button
                Center(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Skip for now',
                      style: GVTypography.label.copyWith(color: textSecondary),
                    ),
                  ),
                ),
                const SizedBox(height: GVSpacing.md),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeChip({
    required SavedPlaceType type,
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    final isSelected = _selectedType == type;
    return Expanded(
      child: InkWell(
        onTap: () => _onTypeChanged(type),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected
                ? GVColors.brandGreen
                : (isDark ? const Color(0xFF1C2420) : GVColors.neutral100),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected
                  ? GVColors.brandGreen
                  : (isDark ? const Color(0xFF2A3630) : GVColors.border),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 20,
                color: isSelected ? GVColors.deepGreen : GVColors.brandGreen,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                  color: isSelected
                      ? GVColors.deepGreen
                      : (isDark ? Colors.white70 : GVColors.textPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
