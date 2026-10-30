import 'package:flutter/material.dart';
import '../../foundation/gv_border_radius.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_spacing.dart';
import '../../foundation/gv_typography.dart';

/// Screen 5: Recipient form card and recent recipient quick-selection.
class GVRecipientFormCard extends StatelessWidget {
  const GVRecipientFormCard({
    super.key,
    required this.nameController,
    required this.phoneController,
    this.countryCode = '+234',
    required this.deliveryAddress,
    required this.onEditAddress,
    required this.additionalInfoController,
    required this.saveAsRecipient,
    required this.onSaveAsRecipientChanged,
    this.onPickContact,
  });

  final TextEditingController nameController;
  final TextEditingController phoneController;
  final String countryCode;
  final String deliveryAddress;
  final VoidCallback onEditAddress;
  final TextEditingController additionalInfoController;
  final bool saveAsRecipient;
  final ValueChanged<bool> onSaveAsRecipientChanged;
  final VoidCallback? onPickContact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;
    final cardBg = isDark ? const Color(0xFF1A221E) : GVColors.white;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Full Name
        Text(
          'Full name',
          style: GVTypography.bodySmallMedium.copyWith(
            color: isDark ? GVColors.white : GVColors.textPrimary,
          ),
        ),
        const SizedBox(height: GVSpacing.xs),
        TextFormField(
          controller: nameController,
          decoration: InputDecoration(
            hintText: 'Enter recipient full name',
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(GVBorderRadius.md),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(GVBorderRadius.md),
              borderSide: BorderSide(color: borderColor),
            ),
          ),
        ),
        const SizedBox(height: GVSpacing.md),

        // 2. Phone Number
        Text(
          'Phone number',
          style: GVTypography.bodySmallMedium.copyWith(
            color: isDark ? GVColors.white : GVColors.textPrimary,
          ),
        ),
        const SizedBox(height: GVSpacing.xs),
        Row(
          children: [
            // Country code pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                children: [
                  const Text('🇳🇬', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Text(
                    countryCode,
                    style: GVTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                      color: isDark ? GVColors.white : GVColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: GVSpacing.sm),

            // Number field
            Expanded(
              child: TextFormField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '0803 123 4567',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.contacts_rounded, size: 20),
                    onPressed: onPickContact,
                    color: GVColors.neutral500,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(GVBorderRadius.md),
                    borderSide: BorderSide(color: borderColor),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(GVBorderRadius.md),
                    borderSide: BorderSide(color: borderColor),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: GVSpacing.md),

        // 3. Delivery Address
        Text(
          'Delivery address',
          style: GVTypography.bodySmallMedium.copyWith(
            color: isDark ? GVColors.white : GVColors.textPrimary,
          ),
        ),
        const SizedBox(height: GVSpacing.xs),
        InkWell(
          onTap: onEditAddress,
          borderRadius: BorderRadius.circular(GVBorderRadius.md),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(GVBorderRadius.md),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on,
                  color: GVColors.brandGreen,
                  size: 20,
                ),
                const SizedBox(width: GVSpacing.sm),
                Expanded(
                  child: Text(
                    deliveryAddress,
                    style: GVTypography.bodyMedium.copyWith(
                      color: isDark ? GVColors.white : GVColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  color: GVColors.neutral500,
                  onPressed: onEditAddress,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: GVSpacing.md),

        // 4. Additional address info
        Text(
          'Additional address info (optional)',
          style: GVTypography.bodySmallMedium.copyWith(
            color: isDark ? GVColors.white : GVColors.textPrimary,
          ),
        ),
        const SizedBox(height: GVSpacing.xs),
        TextFormField(
          controller: additionalInfoController,
          decoration: InputDecoration(
            hintText: 'Shop B12, Second floor',
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(GVBorderRadius.md),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(GVBorderRadius.md),
              borderSide: BorderSide(color: borderColor),
            ),
          ),
        ),
        const SizedBox(height: GVSpacing.md),

        // 5. Save as recipient switch
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Save as recipient',
              style: GVTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: isDark ? GVColors.white : GVColors.textPrimary,
              ),
            ),
            Switch(
              value: saveAsRecipient,
              activeThumbColor: GVColors.brandGreen,
              onChanged: onSaveAsRecipientChanged,
            ),
          ],
        ),
      ],
    );
  }
}
