import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../application/shopping_errand_notifier.dart';

/// Screen A4 (ME-A03): Shopping Preferences.
/// Matches high-fidelity design template Row 1 Screen A4.
class ShoppingPreferencesScreen extends ConsumerStatefulWidget {
  const ShoppingPreferencesScreen({super.key});

  @override
  ConsumerState<ShoppingPreferencesScreen> createState() =>
      _ShoppingPreferencesScreenState();
}

class _ShoppingPreferencesScreenState
    extends ConsumerState<ShoppingPreferencesScreen> {
  late final TextEditingController _instructionsController;

  @override
  void initState() {
    super.initState();
    final currentInstructions = ref
        .read(shoppingErrandNotifierProvider)
        .preferences
        .additionalInstructions;
    _instructionsController = TextEditingController(text: currentInstructions);
  }

  @override
  void dispose() {
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(shoppingErrandNotifierProvider);
    final notifier = ref.read(shoppingErrandNotifierProvider.notifier);

    final currentPolicy = state.preferences.substitutionPolicy;

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
          'Shopping Preferences',
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

              Text(
                'Substitution preference',
                style: GVTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? GVColors.white : GVColors.textPrimary,
                ),
              ),

              const SizedBox(height: GVSpacing.md),

              // Option 1: Do not substitute
              _buildPolicyCard(
                context,
                isDark: isDark,
                title: 'Do not substitute',
                subtitle: 'Buy only the listed items.',
                isSelected: currentPolicy == SubstitutionPolicy.doNotSubstitute,
                onTap: () => notifier.setSubstitutionPolicy(
                  SubstitutionPolicy.doNotSubstitute,
                ),
              ),

              const SizedBox(height: GVSpacing.sm),

              // Option 2: Contact me first
              _buildPolicyCard(
                context,
                isDark: isDark,
                title: 'Contact me first',
                subtitle: 'Call or chat me before replacing any unavailable item.',
                isSelected: currentPolicy == SubstitutionPolicy.contactFirst,
                onTap: () => notifier.setSubstitutionPolicy(
                  SubstitutionPolicy.contactFirst,
                ),
              ),

              const SizedBox(height: GVSpacing.sm),

              // Option 3: Choose a similar alternative
              _buildPolicyCard(
                context,
                isDark: isDark,
                title: 'Choose a similar alternative',
                subtitle: 'Buy a similar item within my budget.',
                isSelected:
                    currentPolicy == SubstitutionPolicy.similarAlternative,
                onTap: () => notifier.setSubstitutionPolicy(
                  SubstitutionPolicy.similarAlternative,
                ),
              ),

              const SizedBox(height: GVSpacing.xl),

              // Additional Instructions Form
              Text(
                'Additional instructions (optional)',
                style: GVTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isDark ? GVColors.white : GVColors.textPrimary,
                ),
              ),

              const SizedBox(height: GVSpacing.sm),

              Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF161F1A) : GVColors.white,
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2A3D32) : const Color(0xFFE0E0E0),
                  ),
                ),
                child: TextField(
                  controller: _instructionsController,
                  maxLines: 4,
                  onChanged: (val) => notifier.setAdditionalInstructions(val),
                  decoration: InputDecoration(
                    hintText:
                        'e.g. Choose fresh items, check expiry date for packed goods.',
                    hintStyle: GVTypography.bodyMedium.copyWith(
                      color: isDark
                          ? GVColors.neutral500
                          : const Color(0xFF9E9E9E),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(GVSpacing.md),
                  ),
                ),
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
                notifier.setAdditionalInstructions(
                  _instructionsController.text.trim(),
                );
                context.push(AppRoutes.errandDelivery);
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

  Widget _buildPolicyCard(
    BuildContext context, {
    required bool isDark,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161F1A) : GVColors.white,
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF00C853)
              : (isDark ? const Color(0xFF2A3D32) : const Color(0xFFE0E0E0)),
          width: isSelected ? 1.8 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(GVBorderRadius.md),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(GVSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF00C853)
                          : (isDark ? GVColors.neutral500 : const Color(0xFFBDBDBD)),
                      width: 2,
                    ),
                    color: isSelected ? const Color(0xFF00C853) : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 14, color: GVColors.white)
                      : null,
                ),
                const SizedBox(width: GVSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GVTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? GVColors.white : GVColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: GVTypography.bodySmall.copyWith(
                          color: isDark ? GVColors.neutral400 : GVColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

