import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Modal dialog for Go Online prerequisite confirmation (Board 2 Screen 2).
class GoOnlineModal extends StatelessWidget {
  const GoOnlineModal({
    super.key,
    required this.onConfirm,
    required this.onCancel,
  });

  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF141917),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg, vertical: GVSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: GVSpacing.md),

          // Illustration Icon
          Center(
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: GVColors.deepGreen.withValues(alpha: 0.5),
                shape: BoxShape.circle,
                border: Border.all(color: GVColors.brandGreen, width: 2),
              ),
              child: const Icon(
                Icons.two_wheeler,
                color: GVColors.brandGreen,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: GVSpacing.md),

          Text(
            'Go Online?',
            textAlign: TextAlign.center,
            style: GVTypography.h2.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: GVSpacing.xs),
          Text(
            'You will start receiving ride requests in your area.',
            textAlign: TextAlign.center,
            style: GVTypography.bodyMedium.copyWith(color: Colors.white60),
          ),
          const SizedBox(height: GVSpacing.lg),

          // Checklist
          Container(
            padding: const EdgeInsets.all(GVSpacing.md),
            decoration: BoxDecoration(
              color: const Color(0xFF1C2420),
              borderRadius: BorderRadius.circular(GVBorderRadius.md),
              border: Border.all(color: const Color(0xFF2A3630)),
            ),
            child: Column(
              children: [
                _buildCheckItem('Location access enabled'),
                const SizedBox(height: 10),
                _buildCheckItem('Vehicle is verified'),
                const SizedBox(height: 10),
                _buildCheckItem('Documents are approved'),
                const SizedBox(height: 10),
                _buildCheckItem('You are in a service area'),
              ],
            ),
          ),
          const SizedBox(height: GVSpacing.xl),

          // Action Buttons
          GVPrimaryButton(
            label: 'Go Online',
            onPressed: onConfirm,
          ),
          const SizedBox(height: GVSpacing.xs),
          TextButton(
            onPressed: onCancel,
            child: Text(
              'Cancel',
              style: GVTypography.bodyMedium.copyWith(color: Colors.white60),
            ),
          ),
          const SizedBox(height: GVSpacing.xs),
        ],
      ),
    );
  }

  Widget _buildCheckItem(String label) {
    return Row(
      children: [
        const Icon(Icons.check_circle, color: GVColors.brandGreen, size: 20),
        const SizedBox(width: 10),
        Text(
          label,
          style: GVTypography.bodyMedium.copyWith(
            color: Colors.white,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
