import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../application/other_errand_notifier.dart';

/// Screen C3: Task Details (Flow C: Other Errand).
/// Captures pickup and delivery locations, contact person, and operational instructions.
class TaskDetailsScreen extends ConsumerStatefulWidget {
  const TaskDetailsScreen({super.key});

  @override
  ConsumerState<TaskDetailsScreen> createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends ConsumerState<TaskDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _pickupController;
  late TextEditingController _contactController;
  late TextEditingController _phoneController;
  late TextEditingController _deliveryController;
  late TextEditingController _instructionsController;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final state = ref.read(otherErrandNotifierProvider);
    _pickupController =
        TextEditingController(text: state.pickupLocation.address);
    _contactController =
        TextEditingController(text: state.contactPerson);
    _phoneController =
        TextEditingController(text: state.phoneNumber);
    _deliveryController =
        TextEditingController(text: state.deliveryLocation.address);
    _instructionsController =
        TextEditingController(text: state.additionalInstructions);
  }

  @override
  void dispose() {
    _pickupController.dispose();
    _contactController.dispose();
    _phoneController.dispose();
    _deliveryController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  void _onSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isSubmitting = true);
      ref.read(otherErrandNotifierProvider.notifier).setTaskDetails(
            pickupAddress: _pickupController.text.trim(),
            contactPerson: _contactController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            deliveryAddress: _deliveryController.text.trim(),
            instructions: _instructionsController.text.trim(),
          );
      await ref.read(otherErrandNotifierProvider.notifier).requestQuote();
      if (mounted) {
        setState(() => _isSubmitting = false);
        context.push(AppRoutes.errandQuoteAvailable);
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
          'Task Details',
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
                      _buildLabel('Pickup location'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _pickupController,
                        decoration: _buildInputDecoration(
                          hintText: 'e.g. Bayero University, Registrar\'s Office',
                          prefixIcon: Icons.place_outlined,
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                                ? 'Please enter pickup location'
                                : null,
                      ),
                      const SizedBox(height: 18),
                      _buildLabel('Contact person'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _contactController,
                        decoration: _buildInputDecoration(
                          hintText: 'e.g. Mrs. Amina Yusuf',
                          prefixIcon: Icons.person_outline,
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                                ? 'Please enter contact person name'
                                : null,
                      ),
                      const SizedBox(height: 18),
                      _buildLabel('Phone number'),
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
                                ? 'Please enter valid phone number'
                                : null,
                      ),
                      const SizedBox(height: 18),
                      _buildLabel('Delivery location'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _deliveryController,
                        decoration: _buildInputDecoration(
                          hintText: 'e.g. My Home - Shaganu Central, Ogun State',
                          prefixIcon: Icons.home_outlined,
                        ),
                        validator: (value) =>
                            (value == null || value.trim().isEmpty)
                                ? 'Please enter delivery location'
                                : null,
                      ),
                      const SizedBox(height: 18),
                      _buildLabel('Additional instructions (optional)'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _instructionsController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: 'Collect the sealed document and deliver to me.',
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
                text: 'Submit Request',
                isLoading: _isSubmitting,
                onPressed: _onSubmit,
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
