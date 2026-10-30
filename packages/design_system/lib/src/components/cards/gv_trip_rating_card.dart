import 'package:flutter/material.dart';
import '../../foundation/gv_border_radius.dart';
import '../../foundation/gv_colors.dart';
import '../../foundation/gv_spacing.dart';
import '../../foundation/gv_typography.dart';
import '../buttons/gv_primary_button.dart';

/// Interactive trip rating and feedback card matching Screen 17.
///
/// Features:
/// - Driver information preview.
/// - 5-star interactive rating bar.
/// - Compliment tag pills (multi-selectable).
/// - Comment input with character counter (max 200).
/// - "Would you ride again?" toggle (Yes / No).
/// - Submit & Done action buttons.
class GVTripRatingCard extends StatefulWidget {
  const GVTripRatingCard({
    super.key,
    required this.driverName,
    required this.driverVehicle,
    this.driverAvatarUrl,
    this.initialRating = 5,
    this.availableTags = const [
      'Great driver',
      'Safe ride',
      'Clean car',
      'On time',
      'Friendly',
      'Others',
    ],
    this.onSubmit,
    this.onDone,
    this.isSubmitting = false,
  });

  final String driverName;
  final String driverVehicle;
  final String? driverAvatarUrl;
  final int initialRating;
  final List<String> availableTags;
  final void Function({
    required int rating,
    required List<String> tags,
    required String comment,
    required bool wouldRideAgain,
  })? onSubmit;
  final VoidCallback? onDone;
  final bool isSubmitting;

  @override
  State<GVTripRatingCard> createState() => _GVTripRatingCardState();
}

class _GVTripRatingCardState extends State<GVTripRatingCard> {
  late int _rating;
  late final Set<String> _selectedTags;
  final TextEditingController _commentController = TextEditingController();
  bool _wouldRideAgain = true;

  @override
  void initState() {
    super.initState();
    _rating = widget.initialRating;
    _selectedTags = {};
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Text(
            'Rate your trip',
            style: GVTypography.headlineSmall.copyWith(
              fontWeight: FontWeight.w800,
              color: isDark ? GVColors.white : GVColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'How was your experience?',
            style: GVTypography.bodyMedium.copyWith(
              color: isDark ? GVColors.neutral400 : GVColors.textSecondary,
            ),
          ),
          const SizedBox(height: GVSpacing.lg),

          // Driver preview
          Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 34,
                  backgroundColor: isDark
                      ? const Color(0xFF243029)
                      : GVColors.softBackground,
                  backgroundImage: widget.driverAvatarUrl != null
                      ? NetworkImage(widget.driverAvatarUrl!)
                      : null,
                  child: widget.driverAvatarUrl == null
                      ? const Icon(Icons.person,
                          size: 38, color: GVColors.brandGreen)
                      : null,
                ),
                const SizedBox(height: GVSpacing.sm),
                Text(
                  widget.driverName,
                  style: GVTypography.titleMedium.copyWith(
                    fontWeight: FontWeight.w800,
                    color: isDark ? GVColors.white : GVColors.textPrimary,
                  ),
                ),
                Text(
                  widget.driverVehicle,
                  style: GVTypography.bodySmall.copyWith(
                    color:
                        isDark ? GVColors.neutral400 : GVColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: GVSpacing.lg),

          // 5-Star Rating Bar
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              final starNumber = index + 1;
              final isFilled = starNumber <= _rating;

              return IconButton(
                iconSize: 38,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                onPressed: () {
                  setState(() => _rating = starNumber);
                },
                icon: Icon(
                  isFilled ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: isFilled ? GVColors.warning : GVColors.neutral300,
                ),
              );
            }),
          ),
          const SizedBox(height: GVSpacing.lg),

          // Compliment Tags
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: widget.availableTags.map((tag) {
              final isSelected = _selectedTags.contains(tag);
              return FilterChip(
                label: Text(tag),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedTags.add(tag);
                    } else {
                      _selectedTags.remove(tag);
                    }
                  });
                },
                labelStyle: GVTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isSelected
                      ? GVColors.brandGreen
                      : (isDark ? GVColors.white : GVColors.textPrimary),
                ),
                selectedColor: isDark
                    ? const Color(0xFF132A1C)
                    : const Color(0xFFE8F5E9),
                backgroundColor: isDark
                    ? const Color(0xFF1A221E)
                    : GVColors.softBackground,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected
                        ? GVColors.brandGreen
                        : (isDark ? const Color(0xFF2E3D35) : GVColors.border),
                  ),
                ),
                showCheckmark: false,
              );
            }).toList(),
          ),
          const SizedBox(height: GVSpacing.lg),

          // Add a comment section
          Text(
            'Add a comment (optional)',
            style: GVTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? GVColors.white : GVColors.textPrimary,
            ),
          ),
          const SizedBox(height: GVSpacing.xs),
          TextField(
            controller: _commentController,
            maxLength: 200,
            maxLines: 3,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'Tell us more about your experience...',
              hintStyle: GVTypography.bodyMedium.copyWith(
                color: isDark ? GVColors.neutral500 : GVColors.textDisabled,
              ),
              filled: true,
              fillColor: isDark
                  ? const Color(0xFF1A221E)
                  : GVColors.softBackground,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? const Color(0xFF2E3D35) : GVColors.border,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isDark ? const Color(0xFF2E3D35) : GVColors.border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: GVColors.brandGreen,
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: GVSpacing.md),

          // "Would you ride again?" Section
          Text(
            'Would you ride with ${widget.driverName.split(" ").first} again?',
            style: GVTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: isDark ? GVColors.white : GVColors.textPrimary,
            ),
          ),
          const SizedBox(height: GVSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _RideAgainOptionButton(
                  icon: Icons.thumb_up_alt_rounded,
                  label: 'Yes',
                  isSelected: _wouldRideAgain,
                  onTap: () => setState(() => _wouldRideAgain = true),
                  isDark: isDark,
                  activeColor: GVColors.brandGreen,
                ),
              ),
              const SizedBox(width: GVSpacing.md),
              Expanded(
                child: _RideAgainOptionButton(
                  icon: Icons.thumb_down_alt_rounded,
                  label: 'No',
                  isSelected: !_wouldRideAgain,
                  onTap: () => setState(() => _wouldRideAgain = false),
                  isDark: isDark,
                  activeColor: GVColors.neutral500,
                ),
              ),
            ],
          ),
          const SizedBox(height: GVSpacing.xl),

          // Submit Button
          GVPrimaryButton(
            label: 'Submit',
            isLoading: widget.isSubmitting,
            onPressed: widget.onSubmit == null
                ? null
                : () {
                    widget.onSubmit!(
                      rating: _rating,
                      tags: _selectedTags.toList(),
                      comment: _commentController.text.trim(),
                      wouldRideAgain: _wouldRideAgain,
                    );
                  },
          ),
          if (widget.onDone != null) ...[
            const SizedBox(height: GVSpacing.sm),
            TextButton(
              onPressed: widget.onDone,
              child: Text(
                'Done',
                style: GVTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDark ? GVColors.neutral400 : GVColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _RideAgainOptionButton extends StatelessWidget {
  const _RideAgainOptionButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.isDark,
    required this.activeColor,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isDark;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final bg = isSelected
        ? (isDark ? const Color(0xFF13221A) : const Color(0xFFF0FDF4))
        : (isDark ? const Color(0xFF1A221E) : GVColors.softBackground);

    return InkWell(
      onTap: onTap,
      borderRadius: GVBorderRadius.cardRadius,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: GVBorderRadius.cardRadius,
          border: Border.all(
            color: isSelected
                ? activeColor
                : (isDark ? const Color(0xFF2E3D35) : GVColors.border),
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected
                  ? activeColor
                  : (isDark ? GVColors.neutral400 : GVColors.neutral600),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: GVTypography.bodyMedium.copyWith(
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? (isDark ? GVColors.white : GVColors.textPrimary)
                    : (isDark ? GVColors.neutral400 : GVColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

