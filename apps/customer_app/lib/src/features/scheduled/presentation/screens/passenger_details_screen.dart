import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/auth/auth_notifier.dart';
import '../../../../core/router/app_router.dart';
import '../../application/scheduled_booking_notifier.dart';

/// Screen 8 (SP-08): Passenger Details Screen
/// Configures passenger contact info, guardian instructions, and saved traveler preferences.
class PassengerDetailsScreen extends ConsumerStatefulWidget {
  const PassengerDetailsScreen({super.key});

  @override
  ConsumerState<PassengerDetailsScreen> createState() =>
      _PassengerDetailsScreenState();
}

class _PassengerDetailsScreenState
    extends ConsumerState<PassengerDetailsScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _instructionsController;

  bool _isMyself = true;
  bool _savePassenger = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(authNotifierProvider).profile;
    final initialName = profile?.fullName ?? '';
    final rawPhone = profile?.phoneNumber ?? '';
    final initialPhone = rawPhone.replaceFirst(RegExp(r'^\+?234\s*'), '');

    _nameController = TextEditingController(text: initialName);
    _phoneController = TextEditingController(text: initialPhone);
    _instructionsController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _instructionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(scheduledBookingNotifierProvider.notifier);

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF131A16) : Colors.white;
    final textColor = isDark ? Colors.white : GVColors.textPrimary;
    final subtextColor = isDark ? GVColors.neutral400 : GVColors.textSecondary;
    final cardBg = isDark ? const Color(0xFF1C2420) : const Color(0xFFF6F8F7);
    final borderColor = isDark ? const Color(0xFF2E3D35) : GVColors.border;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 20,
            color: textColor,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: GVSpacing.xs),
              Text(
                'Passenger details',
                style: GVTypography.h1.copyWith(
                  color: textColor,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: GVSpacing.lg),

              // Who will be travelling? Segmented control
              Text(
                'Who will be travelling?',
                style: GVTypography.labelLarge.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: GVSpacing.sm),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildPassengerTab(
                        title: 'Myself',
                        isSelected: _isMyself,
                        onTap: () {
                          setState(() {
                            _isMyself = true;
                            final profile = ref.read(authNotifierProvider).profile;
                            _nameController.text = profile?.fullName ?? '';
                            final rawPhone = profile?.phoneNumber ?? '';
                            _phoneController.text = rawPhone.replaceFirst(RegExp(r'^\+?234\s*'), '');
                          });
                        },
                      ),
                    ),
                    Expanded(
                      child: _buildPassengerTab(
                        title: 'Someone else',
                        isSelected: !_isMyself,
                        onTap: () {
                          setState(() {
                            _isMyself = false;
                            _nameController.clear();
                            _phoneController.clear();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: GVSpacing.xl),

              // Full name Field
              Text(
                'Full name',
                style: GVTypography.labelMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: GVSpacing.xs),
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(color: borderColor),
                ),
                child: TextField(
                  controller: _nameController,
                  style: GVTypography.bodyMedium.copyWith(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'Enter full name',
                    hintStyle: GVTypography.bodyMedium.copyWith(
                      color: subtextColor,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: GVSpacing.md),

              // Phone number Field
              Text(
                'Phone number',
                style: GVTypography.labelMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: GVSpacing.xs),
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(color: borderColor),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 14, right: 8),
                      child: Row(
                        children: [
                          const Text('🇳🇬', style: TextStyle(fontSize: 18)),
                          const SizedBox(width: 6),
                          Text(
                            '+234',
                            style: GVTypography.bodyMedium.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(width: 1, height: 24, color: borderColor),
                    Expanded(
                      child: TextField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        style: GVTypography.bodyMedium.copyWith(
                          color: textColor,
                        ),
                        decoration: InputDecoration(
                          hintText: '801 234 5678',
                          hintStyle: GVTypography.bodyMedium.copyWith(
                            color: subtextColor,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: GVSpacing.lg),

              // Add to saved passengers toggle
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Add to saved passengers',
                      style: GVTypography.bodyMedium.copyWith(
                        color: textColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  Switch.adaptive(
                    value: _savePassenger,
                    activeTrackColor: GVColors.primary,
                    onChanged: (val) {
                      setState(() => _savePassenger = val);
                    },
                  ),
                ],
              ),

              const SizedBox(height: GVSpacing.md),

              // Special instructions (optional)
              Text(
                'Special instructions (optional)',
                style: GVTypography.labelMedium.copyWith(
                  color: textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: GVSpacing.xs),
              Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(color: borderColor),
                ),
                child: TextField(
                  controller: _instructionsController,
                  maxLines: 2,
                  style: GVTypography.bodyMedium.copyWith(color: textColor),
                  decoration: InputDecoration(
                    hintText: 'e.g. Pick from main gate',
                    hintStyle: GVTypography.bodyMedium.copyWith(
                      color: subtextColor,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: GVSpacing.xxl),

              // CTA: Continue
              GVButton(
                text: 'Continue',
                onPressed: () {
                  final formattedPhone = '+234 ${_phoneController.text.trim()}';
                  notifier.setPassengerDetails(
                    name: _nameController.text.trim(),
                    phone: formattedPhone,
                    isMyself: _isMyself,
                    savePassenger: _savePassenger,
                    instructions: _instructionsController.text.trim(),
                  );
                  context.push(AppRoutes.scheduledPreferredDriver);
                },
              ),
              const SizedBox(height: GVSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPassengerTab({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(GVBorderRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? GVColors.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(GVBorderRadius.sm),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: isSelected ? Colors.white : GVColors.textSecondary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
}
