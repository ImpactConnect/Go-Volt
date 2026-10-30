import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Screen A11: Edit Profile with Sensitive Identifier Verification & Parent Status.
class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController(text: 'Alexander Cole');
  final _emailController = TextEditingController(text: 'alex.cole@example.com');
  final _phoneController = TextEditingController(text: '+234 801 234 5678');
  final _addressController = TextEditingController(text: '14 Admiralty Way, Lekki Phase 1, Lagos');

  bool _isSaving = false;
  bool _phoneModified = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GVColors.darkBg,
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: GVColors.darkBg,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(GVSpacing.md),
          children: [
            // Avatar Header
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 46,
                    backgroundColor: GVColors.deepGreen,
                    child: Text(
                      'AC',
                      style: GVTypography.h1.copyWith(color: GVColors.brandGreen),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: GVColors.brandGreen,
                      child: IconButton(
                        icon: const Icon(Icons.camera_alt, size: 16, color: Colors.black),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Avatar upload via Supabase Storage triggered.')),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.lg),

            // Parent/Guardian Verification Badge (SP Requirement)
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFF133B26),
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                border: Border.all(color: GVColors.brandGreen),
              ),
              child: Row(
                children: [
                  const Icon(Icons.verified_user, color: GVColors.brandGreen, size: 28),
                  const SizedBox(width: GVSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Verified Parent / Guardian',
                          style: GVTypography.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'LASRRA & NIN identity verified. Authorized for School-Run security handover.',
                          style: GVTypography.caption.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const GVStatusChip(label: 'VETTED', status: GVStatusType.active),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.lg),

            // Form Fields
            _buildField(
              label: 'Full Legal Name',
              controller: _nameController,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: GVSpacing.md),

            _buildField(
              label: 'Email Address',
              controller: _emailController,
              icon: Icons.email_outlined,
            ),
            const SizedBox(height: GVSpacing.md),

            _buildField(
              label: 'Phone Number (Primary E.164)',
              controller: _phoneController,
              icon: Icons.phone_outlined,
              onChanged: (val) {
                if (!_phoneModified) setState(() => _phoneModified = true);
              },
            ),
            if (_phoneModified) ...[
              const SizedBox(height: 4),
              const Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.amber, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Changing your phone number requires SMS OTP verification.',
                    style: TextStyle(color: Colors.amber, fontSize: 11),
                  ),
                ],
              ),
            ],
            const SizedBox(height: GVSpacing.md),

            _buildField(
              label: 'Residential Address',
              controller: _addressController,
              icon: Icons.home_outlined,
            ),
            const SizedBox(height: GVSpacing.xl),

            GVPrimaryButton(
              label: _isSaving ? 'Saving Changes...' : 'Save Profile',
              onPressed: _isSaving ? null : _saveProfile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    ValueChanged<String>? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1C2420),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFF2A3630)),
          ),
          child: Row(
            children: [
              Icon(icon, color: GVColors.brandGreen, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  style: const TextStyle(color: Colors.white, fontSize: 14),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _saveProfile() async {
    setState(() => _isSaving = true);
    await Future<void>.delayed(const Duration(milliseconds: 300));
    setState(() => _isSaving = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully.'),
          backgroundColor: GVColors.deepGreen,
        ),
      );
    }
  }
}
