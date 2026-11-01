import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../application/package_errand_notifier.dart';

/// Screen B4: Delivery Details (Pick Up a Package Flow).
/// Allows specifying the destination address, recipient contact information, and delivery instructions.
class PackageDeliveryScreen extends ConsumerStatefulWidget {
  const PackageDeliveryScreen({super.key});

  @override
  ConsumerState<PackageDeliveryScreen> createState() => _PackageDeliveryScreenState();
}

class _PackageDeliveryScreenState extends ConsumerState<PackageDeliveryScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _addressController;
  late TextEditingController _recipientController;
  late TextEditingController _phoneController;
  late TextEditingController _instructionsController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(packageErrandNotifierProvider);
    _addressController =
        TextEditingController(text: state.deliveryLocation.address);
    _recipientController =
        TextEditingController(text: state.recipient.fullName);
    _phoneController =
        TextEditingController(text: state.recipient.phoneNumber);
    _instructionsController =
        TextEditingController(text: state.deliveryInstructions);
  }

  @override
  void dispose() {
    _addressController.dispose();
    _recipientController.dispose();
    _phoneController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _onContinue() async {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(packageErrandNotifierProvider.notifier).setDeliveryDetails(
            address: _addressController.text.trim(),
            recipientName: _recipientController.text.trim(),
            recipientPhone: _phoneController.text.trim(),
            instructions: _instructionsController.text.trim(),
          );
      await ref.read(packageErrandNotifierProvider.notifier).calculateQuote();
      if (mounted) {
        context.push(AppRoutes.errandPackageReview);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Delivery Details',
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
                      _buildLabel('Deliver to'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _addressController,
                        decoration: _buildInputDecoration(
                          hintText: 'Destination address',
                          prefixIcon: Icons.place_outlined,
                          suffixIcon: Icons.chevron_right,
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                                ? 'Please enter destination address'
                                : null,
                      ),
                      const SizedBox(height: 18),
                      _buildLabel('Recipient'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _recipientController,
                        decoration: _buildInputDecoration(
                          hintText: 'Recipient full name',
                          prefixIcon: Icons.person_outline,
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                                ? 'Please enter recipient name'
                                : null,
                      ),
                      const SizedBox(height: 18),
                      _buildLabel('Phone number'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: _buildInputDecoration(
                          hintText: 'Recipient phone number',
                          prefixIcon: Icons.phone_outlined,
                        ),
                        validator: (value) =>
                            (value == null || value.trim().length < 10)
                                ? 'Please enter a valid phone number'
                                : null,
                      ),
                      const SizedBox(height: 18),
                      _buildLabel('Delivery instructions'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _instructionsController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Ring the bell and hand over to the reception.',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          contentPadding: const EdgeInsets.all(14),
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
                            borderSide:
                                const BorderSide(color: GVColors.primary, width: 1.5),
                          ),
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

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    IconData? suffixIcon,
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
      suffixIcon: suffixIcon != null
          ? Icon(suffixIcon, color: Colors.grey.shade500)
          : null,
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
