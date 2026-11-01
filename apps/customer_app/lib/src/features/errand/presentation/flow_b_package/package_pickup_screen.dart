import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../application/package_errand_notifier.dart';

/// Screen B2: Pickup Details (Pick Up a Package Flow).
/// Allows the customer to specify the pickup business/hub, address, contact person, and optional reference number.
class PackagePickupScreen extends ConsumerStatefulWidget {
  const PackagePickupScreen({super.key});

  @override
  ConsumerState<PackagePickupScreen> createState() => _PackagePickupScreenState();
}

class _PackagePickupScreenState extends ConsumerState<PackagePickupScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _businessController;
  late TextEditingController _addressController;
  late TextEditingController _contactController;
  late TextEditingController _phoneController;
  late TextEditingController _referenceController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(packageErrandNotifierProvider);
    _businessController =
        TextEditingController(text: state.pickupDetails.pickupBusinessName);
    _addressController =
        TextEditingController(text: state.pickupDetails.address);
    _contactController =
        TextEditingController(text: state.pickupDetails.contactPerson);
    _phoneController =
        TextEditingController(text: state.pickupDetails.phoneNumber);
    _referenceController = TextEditingController(
        text: state.pickupDetails.referenceOrderNumber ?? '');
  }

  @override
  void dispose() {
    _businessController.dispose();
    _addressController.dispose();
    _contactController.dispose();
    _phoneController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(packageErrandNotifierProvider.notifier).setPickupDetails(
            businessName: _businessController.text.trim(),
            address: _addressController.text.trim(),
            contactPerson: _contactController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            referenceOrderNumber: _referenceController.text.trim(),
          );
      context.push(AppRoutes.errandPackageDetails);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Pickup Details',
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
                      _buildSectionHeader('Pick up from'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _businessController,
                        decoration: _buildInputDecoration(
                          hintText: 'e.g. Jumia Pickup Point, Barnawa',
                          prefixIcon: Icons.storefront_outlined,
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                                ? 'Please enter the pickup location or hub name'
                                : null,
                      ),
                      const SizedBox(height: 18),
                      _buildSectionHeader('Address'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _addressController,
                        decoration: _buildInputDecoration(
                          hintText: 'Street address, area',
                          prefixIcon: Icons.place_outlined,
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                                ? 'Please enter the street address'
                                : null,
                      ),
                      const SizedBox(height: 18),
                      _buildSectionHeader('Contact person'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _contactController,
                        decoration: _buildInputDecoration(
                          hintText: 'Full name',
                          prefixIcon: Icons.person_outline,
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                                ? 'Please enter a contact name'
                                : null,
                      ),
                      const SizedBox(height: 18),
                      _buildSectionHeader('Phone number'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: _buildInputDecoration(
                          hintText: '0800 000 0000',
                          prefixIcon: Icons.phone_outlined,
                        ),
                        validator: (value) =>
                            (value == null || value.trim().length < 10)
                                ? 'Please enter a valid phone number'
                                : null,
                      ),
                      const SizedBox(height: 18),
                      _buildSectionHeader('Reference / Order No. (optional)'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _referenceController,
                        decoration: _buildInputDecoration(
                          hintText: 'e.g. JM-7788290',
                          prefixIcon: Icons.tag_outlined,
                        ),
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

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
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
