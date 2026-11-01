import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../application/shopping_errand_notifier.dart';

/// Screen A5 (ME-A05): Delivery Details.
/// Matches high-fidelity design template Row 1 Screen A5.
class ShoppingDeliveryScreen extends ConsumerStatefulWidget {
  const ShoppingDeliveryScreen({super.key});

  @override
  ConsumerState<ShoppingDeliveryScreen> createState() =>
      _ShoppingDeliveryScreenState();
}

class _ShoppingDeliveryScreenState
    extends ConsumerState<ShoppingDeliveryScreen> {
  late final TextEditingController _addressController;
  late final TextEditingController _recipientNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(shoppingErrandNotifierProvider);
    _addressController =
        TextEditingController(text: state.deliveryLocation.address);
    _recipientNameController =
        TextEditingController(text: state.recipient.fullName);
    _phoneController =
        TextEditingController(text: state.recipient.phoneNumber);
    _noteController =
        TextEditingController(text: state.deliveryNotes ?? '');
  }

  @override
  void dispose() {
    _addressController.dispose();
    _recipientNameController.dispose();
    _phoneController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(shoppingErrandNotifierProvider);
    final notifier = ref.read(shoppingErrandNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1512) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? GVColors.white : GVColors.textPrimary,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Delivery Details',
          style: GVTypography.h3.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? GVColors.white : GVColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: GVSpacing.sm),

              // Delivery Address Card
              _buildSectionHeader('Delivery address', isDark),
              const SizedBox(height: GVSpacing.xs),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF161F1A) : GVColors.white,
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2A3D32) : const Color(0xFFE0E0E0),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: ListTile(
                    leading: const Icon(
                      Icons.location_on_rounded,
                      color: Color(0xFF00C853),
                    ),
                    title: TextField(
                      controller: _addressController,
                      onChanged: (val) {
                        notifier.setDeliveryLocation(
                          state.deliveryLocation.copyWith(address: val),
                        );
                      },
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Enter destination address',
                        isDense: true,
                      ),
                      style: GVTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? GVColors.white : GVColors.textPrimary,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                  ),
                ),
              ),

              const SizedBox(height: GVSpacing.lg),

              // Recipient Name
              _buildSectionHeader('Recipient', isDark),
              const SizedBox(height: GVSpacing.xs),
              _buildTextField(
                controller: _recipientNameController,
                isDark: isDark,
                hintText: 'e.g. Omotayo Kehinde',
                icon: Icons.person_outline_rounded,
                onChanged: (val) {
                  notifier.setRecipient(
                    state.recipient.copyWith(fullName: val),
                  );
                },
              ),

              const SizedBox(height: GVSpacing.lg),

              // Phone Number
              _buildSectionHeader('Phone number', isDark),
              const SizedBox(height: GVSpacing.xs),
              _buildTextField(
                controller: _phoneController,
                isDark: isDark,
                hintText: '0803 456 7890',
                keyboardType: TextInputType.phone,
                icon: Icons.phone_outlined,
                onChanged: (val) {
                  notifier.setRecipient(
                    state.recipient.copyWith(phoneNumber: val),
                  );
                },
              ),

              const SizedBox(height: GVSpacing.lg),

              // Delivery Time Selector
              _buildSectionHeader('Delivery time', isDark),
              const SizedBox(height: GVSpacing.xs),
              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF161F1A) : GVColors.white,
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2A3D32) : const Color(0xFFE0E0E0),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: ListTile(
                    leading: const Icon(
                      Icons.access_time_rounded,
                      color: Color(0xFF00C853),
                    ),
                    title: Text(
                      state.deliveryTimeStr,
                      style: GVTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isDark ? GVColors.white : GVColors.textPrimary,
                      ),
                    ),
                    trailing: const Icon(Icons.chevron_right_rounded),
                    onTap: () => _showDeliveryTimeSheet(context, isDark, notifier),
                  ),
                ),
              ),

              const SizedBox(height: GVSpacing.lg),

              // Note (optional)
              _buildSectionHeader('Note (optional)', isDark),
              const SizedBox(height: GVSpacing.xs),
              _buildTextField(
                controller: _noteController,
                isDark: isDark,
                hintText: 'Call me when you are nearby.',
                icon: Icons.chat_bubble_outline_rounded,
                onChanged: (val) => notifier.setDeliveryNotes(val),
              ),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(GVSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161F1A) : GVColors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF2E3D35) : const Color(0xFFEEEEEE),
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00C853),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                ),
              ),
              onPressed: () {
                notifier.setDeliveryLocation(
                  state.deliveryLocation.copyWith(
                    address: _addressController.text.trim(),
                  ),
                );
                notifier.setRecipient(
                  state.recipient.copyWith(
                    fullName: _recipientNameController.text.trim(),
                    phoneNumber: _phoneController.text.trim(),
                  ),
                );
                notifier.setDeliveryNotes(_noteController.text.trim());
                notifier.calculateQuote();
                context.push(AppRoutes.errandReview);
              },
              child: Text(
                'Continue',
                style: GVTypography.bodyLarge.copyWith(
                  color: GVColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title,
      style: GVTypography.bodyMedium.copyWith(
        fontWeight: FontWeight.bold,
        color: isDark ? GVColors.white : GVColors.textPrimary,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required bool isDark,
    required String hintText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161F1A) : GVColors.white,
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3D32) : const Color(0xFFE0E0E0),
        ),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: GVTypography.bodyMedium.copyWith(
          color: isDark ? GVColors.white : GVColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GVTypography.bodyMedium.copyWith(
            color: isDark ? GVColors.neutral500 : const Color(0xFF9E9E9E),
          ),
          prefixIcon: Icon(icon, size: 20, color: const Color(0xFF757575)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: GVSpacing.md,
            vertical: GVSpacing.md,
          ),
        ),
      ),
    );
  }

  void _showDeliveryTimeSheet(
    BuildContext context,
    bool isDark,
    ShoppingErrandNotifier notifier,
  ) {
    final options = [
      'As soon as possible',
      'Today, within 2 hours',
      'Today, in the evening (5:00 PM - 7:00 PM)',
      'Tomorrow morning (9:00 AM - 11:00 AM)',
    ];

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: isDark ? const Color(0xFF161F1A) : GVColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(GVBorderRadius.lg)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(GVSpacing.md),
                child: Text(
                  'Select Delivery Time',
                  style: GVTypography.h3.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              const Divider(),
              for (final opt in options)
                ListTile(
                  title: Text(opt),
                  onTap: () {
                    notifier.setDeliveryTime(opt);
                    Navigator.of(ctx).pop();
                  },
                ),
              const SizedBox(height: GVSpacing.md),
            ],
          ),
        );
      },
    );
  }
}
