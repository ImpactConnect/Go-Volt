import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../application/parcel_booking_notifier.dart';

/// Screen 5 — Recipient Details:
/// Form inputs for recipient name, +234 phone number, delivery address, optional shop notes,
/// "Save as recipient" switch, and recent recipients list.
class RecipientDetailsScreen extends ConsumerStatefulWidget {
  const RecipientDetailsScreen({super.key});

  @override
  ConsumerState<RecipientDetailsScreen> createState() =>
      _RecipientDetailsScreenState();
}

class _RecipientDetailsScreenState
    extends ConsumerState<RecipientDetailsScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _additionalInfoController;
  late String _deliveryAddress;
  late bool _saveAsRecipient;

  final List<RecipientDetailsDto> _recentRecipients =
      RecipientDetailsDto.recentRecipients;

  @override
  void initState() {
    super.initState();
    final flowState = ref.read(parcelBookingNotifierProvider);
    final recipient = flowState.recipient;

    _nameController = TextEditingController(text: recipient?.fullName ?? '');
    _phoneController = TextEditingController(text: recipient?.phoneNumber ?? '');
    _additionalInfoController =
        TextEditingController(text: recipient?.additionalAddressInfo ?? '');
    _deliveryAddress = recipient?.deliveryAddress ?? '';
    _saveAsRecipient = recipient?.saveAsRecipient ?? false;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _additionalInfoController.dispose();
    super.dispose();
  }

  void _selectRecentRecipient(RecipientDetailsDto recent) {
    setState(() {
      _nameController.text = recent.fullName;
      _phoneController.text = recent.phoneNumber;
      _deliveryAddress = recent.deliveryAddress;
      _additionalInfoController.text = recent.additionalAddressInfo ?? '';
      _saveAsRecipient = recent.saveAsRecipient;
    });

    ref.read(parcelBookingNotifierProvider.notifier).setRecipient(recent);
  }

  void _onEditAddress() {
    final controller = TextEditingController(text: _deliveryAddress);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? const Color(0xFF1E2822) : GVColors.white,
        title: Text(
          'Edit Delivery Address',
          style: GVTypography.h3.copyWith(
            color: isDark ? GVColors.white : GVColors.textPrimary,
          ),
        ),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(
            labelText: 'Delivery Address',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(GVBorderRadius.md),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _deliveryAddress = controller.text.trim();
                });
              }
              Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: GVColors.brandGreen,
              foregroundColor: GVColors.white,
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _onContinue() {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter recipient full name')),
      );
      return;
    }
    if (_phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter recipient phone number')),
      );
      return;
    }

    final updated = RecipientDetailsDto(
      fullName: _nameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      countryCode: '+234',
      deliveryAddress: _deliveryAddress,
      additionalAddressInfo: _additionalInfoController.text.trim().isEmpty
          ? null
          : _additionalInfoController.text.trim(),
      saveAsRecipient: _saveAsRecipient,
    );

    ref.read(parcelBookingNotifierProvider.notifier).setRecipient(updated);

    if (GoRouter.maybeOf(context) != null) {
      context.push(AppRoutes.parcelDeliveryLocation);
    } else {
      Navigator.of(context).pushNamed(AppRoutes.parcelDeliveryLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1512) : GVColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? GVColors.white : GVColors.textPrimary,
            size: 20,
          ),
          onPressed: () {
            if (GoRouter.maybeOf(context) != null) {
              context.pop();
            } else {
              Navigator.of(context).maybePop();
            }
          },
        ),
        title: Text(
          'Recipient details',
          style: GVTypography.h3.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? GVColors.white : GVColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: GVSpacing.xs),

                      // Reusable Recipient Form Card Component
                      GVRecipientFormCard(
                        nameController: _nameController,
                        phoneController: _phoneController,
                        countryCode: '+234',
                        deliveryAddress: _deliveryAddress,
                        onEditAddress: _onEditAddress,
                        additionalInfoController: _additionalInfoController,
                        saveAsRecipient: _saveAsRecipient,
                        onSaveAsRecipientChanged: (val) {
                          setState(() {
                            _saveAsRecipient = val;
                          });
                        },
                      ),

                      const SizedBox(height: GVSpacing.lg),
                      const Divider(height: 1),
                      const SizedBox(height: GVSpacing.md),

                      if (_recentRecipients.isNotEmpty) ...[
                        // Recent Recipients Header
                        Text(
                          'Recent recipients',
                          style: GVTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isDark ? GVColors.white : GVColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: GVSpacing.sm),

                        // Recent Recipients List
                        for (final recent in _recentRecipients) ...[
                          _buildRecentRecipientTile(
                            recipient: recent,
                            isDark: isDark,
                            onTap: () => _selectRecentRecipient(recent),
                          ),
                          const SizedBox(height: GVSpacing.xs),
                        ],
                        const SizedBox(height: GVSpacing.md),
                      ],

                      const SizedBox(height: GVSpacing.xl),
                    ],
                  ),
                ),
              ),
            ),

            // Sticky Bottom CTA
            Container(
              padding: const EdgeInsets.all(GVSpacing.lg),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF131A16) : GVColors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    offset: const Offset(0, -4),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: GVPrimaryButton(
                label: 'Continue',
                onPressed: _onContinue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentRecipientTile({
    required RecipientDetailsDto recipient,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final isSelected = _nameController.text == recipient.fullName;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GVBorderRadius.md),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: GVSpacing.sm,
          vertical: GVSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                  ? GVColors.brandGreen.withValues(alpha: 0.15)
                  : const Color(0xFFF0FDF4))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(GVBorderRadius.md),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDark
                    ? const Color(0xFF26322A)
                    : const Color(0xFFE5E7EB),
              ),
              child: Icon(
                Icons.person_outline_rounded,
                size: 20,
                color: isDark ? GVColors.neutral400 : GVColors.neutral600,
              ),
            ),
            const SizedBox(width: GVSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipient.fullName,
                    style: GVTypography.bodyMedium.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                      color: isDark ? GVColors.white : GVColors.textPrimary,
                    ),
                  ),
                  Text(
                    recipient.deliveryAddress,
                    style: GVTypography.caption.copyWith(
                      color: isDark
                          ? GVColors.neutral400
                          : GVColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle_rounded,
                color: GVColors.brandGreen,
                size: 20,
              )
            else
              Icon(
                Icons.chevron_right_rounded,
                color: isDark ? GVColors.neutral500 : GVColors.neutral400,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
