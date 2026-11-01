import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../application/other_errand_notifier.dart';

/// Screen C2: Describe Your Errand (Flow C: Other Errand).
/// Allows the customer to specify their custom task request, category, and urgency level.
class DescribeErrandScreen extends ConsumerStatefulWidget {
  const DescribeErrandScreen({super.key});

  @override
  ConsumerState<DescribeErrandScreen> createState() => _DescribeErrandScreenState();
}

class _DescribeErrandScreenState extends ConsumerState<DescribeErrandScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _descriptionController;
  late String _selectedCategory;
  late ErrandUrgency _selectedUrgency;

  static const _categories = [
    'Document Collection',
    'Government / University Run',
    'Laundry & Dry Cleaning',
    'Bank / Utility Bill Run',
    'Personal Chores',
    'Equipment Pickup',
    'Other Custom Task',
  ];

  @override
  void initState() {
    super.initState();
    final state = ref.read(otherErrandNotifierProvider);
    _descriptionController =
        TextEditingController(text: state.taskDescription);
    _selectedCategory = _categories.contains(state.category)
        ? state.category
        : _categories.first;
    _selectedUrgency = state.urgency;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(otherErrandNotifierProvider.notifier).setDescribeDetails(
            description: _descriptionController.text.trim(),
            category: _selectedCategory,
            urgency: _selectedUrgency,
          );
      context.push(AppRoutes.errandTaskDetails);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Describe Your Errand',
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
                      _buildLabel('What do you need help with?'),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 5,
                        maxLength: 300,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText:
                              'Please describe your errand clearly, including any specific guidelines or contacts...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 14,
                          ),
                          contentPadding: const EdgeInsets.all(16),
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
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please describe your request';
                          }
                          if (value.trim().length < 10) {
                            return 'Please provide a bit more detail (min 10 characters)';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 18),
                      _buildLabel('Category (optional)'),
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
                      _buildLabel('Urgency'),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<ErrandUrgency>(
                        initialValue: _selectedUrgency,
                        decoration: _buildInputDecoration(
                          hintText: 'Select urgency',
                          prefixIcon: Icons.bolt_outlined,
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: ErrandUrgency.standard,
                            child: Text(
                              'Standard (same day)',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                          DropdownMenuItem(
                            value: ErrandUrgency.express,
                            child: Text(
                              'Express (within 2 hours)',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedUrgency = val);
                        },
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
