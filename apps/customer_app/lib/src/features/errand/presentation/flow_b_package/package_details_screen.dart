import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../application/package_errand_notifier.dart';

/// Screen B3: Package Details (Pick Up a Package Flow).
/// Allows specifying the item description, category, size band, weight band, and special care flags.
class ErrandPackageDetailsScreen extends ConsumerStatefulWidget {
  const ErrandPackageDetailsScreen({super.key});

  @override
  ConsumerState<ErrandPackageDetailsScreen> createState() => _ErrandPackageDetailsScreenState();
}

class _ErrandPackageDetailsScreenState extends ConsumerState<ErrandPackageDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _descriptionController;
  late String _selectedCategory;
  late String _selectedSize;
  late String _selectedWeight;
  late bool _isFragile;
  late bool _keepUpright;

  static const _categories = [
    'Electronics',
    'Fashion & Apparel',
    'Documents & Books',
    'Food & Groceries',
    'Medical Supplies',
    'Hardware & Tools',
    'Other Item',
  ];

  static const _sizeBands = [
    'Small (under 20 cm)',
    'Medium (up to 50 cm)',
    'Large (up to 100 cm)',
    'Extra Large (> 100 cm)',
  ];

  static const _weightBands = [
    'Under 1 kg',
    '1 - 2 kg',
    '2 - 5 kg',
    '5 - 10 kg',
    'Over 10 kg',
  ];

  @override
  void initState() {
    super.initState();
    final state = ref.read(packageErrandNotifierProvider);
    _descriptionController =
        TextEditingController(text: state.packageDescription);
    _selectedCategory = _categories.contains(state.category)
        ? state.category
        : _categories.first;
    _selectedSize = _sizeBands.contains(state.sizeBand)
        ? state.sizeBand
        : _sizeBands[1]; // Medium
    _selectedWeight = _weightBands.contains(state.weightBand)
        ? state.weightBand
        : _weightBands[2]; // 2 - 5 kg
    _isFragile = state.isFragile;
    _keepUpright = state.keepUpright;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(packageErrandNotifierProvider.notifier).setPackageSpecs(
            description: _descriptionController.text.trim(),
            category: _selectedCategory,
            sizeBand: _selectedSize,
            weightBand: _selectedWeight,
            isFragile: _isFragile,
            keepUpright: _keepUpright,
          );
      context.push(AppRoutes.errandPackageDelivery);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Package Details',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Package description'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        decoration: _buildInputDecoration(
                          hintText: 'e.g. Electronics (Headset)',
                          prefixIcon: Icons.inventory_2_outlined,
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                                ? 'Please describe what needs to be picked up'
                                : null,
                      ),
                      const SizedBox(height: 18),
                      _buildLabel('Category'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        decoration: _buildInputDecoration(
                          hintText: 'Select category',
                          prefixIcon: Icons.category_outlined,
                        ),
                        items: _categories
                            .map((cat) => DropdownMenuItem(
                                  value: cat,
                                  child: Text(cat, style: const TextStyle(fontSize: 14)),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCategory = val);
                        },
                      ),
                      const SizedBox(height: 18),
                      _buildLabel('Size (approx.)'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedSize,
                        decoration: _buildInputDecoration(
                          hintText: 'Select size',
                          prefixIcon: Icons.straighten_outlined,
                        ),
                        items: _sizeBands
                            .map((size) => DropdownMenuItem(
                                  value: size,
                                  child: Text(size, style: const TextStyle(fontSize: 14)),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedSize = val);
                        },
                      ),
                      const SizedBox(height: 18),
                      _buildLabel('Weight (approx.)'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        initialValue: _selectedWeight,
                        decoration: _buildInputDecoration(
                          hintText: 'Select weight band',
                          prefixIcon: Icons.scale_outlined,
                        ),
                        items: _weightBands
                            .map((w) => DropdownMenuItem(
                                  value: w,
                                  child: Text(w, style: const TextStyle(fontSize: 14)),
                                ))
                            .toList(),
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedWeight = val);
                        },
                      ),
                      const SizedBox(height: 24),
                      _buildCheckboxTile(
                        title: 'Fragile / Handle with care',
                        value: _isFragile,
                        onChanged: (v) => setState(() => _isFragile = v ?? false),
                      ),
                      const SizedBox(height: 10),
                      _buildCheckboxTile(
                        title: 'Keep upright',
                        value: _keepUpright,
                        onChanged: (v) => setState(() => _keepUpright = v ?? false),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: GVButton(
                text: 'Continue',
                onPressed: _onContinue,
                expanded: true,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return InkWell(
      onTap: () => onChanged(!value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: value ? GVColors.primary : Colors.grey.shade300,
            width: value ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            SizedBox(
              height: 22,
              width: 22,
              child: Checkbox(
                value: value,
                activeColor: GVColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: value ? FontWeight.w600 : FontWeight.w400,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: TextStyle(
        color: Colors.grey.shade400,
        fontSize: 14,
      ),
      prefixIcon: Icon(
        prefixIcon,
        color: GVColors.primary,
        size: 20,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: GVColors.primary, width: 1.5),
      ),
    );
  }
}
