import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/onboarding_notifier.dart';

/// Screen RD06: Guarantor & Referee Accountability Verification.
class RiderGuarantorScreen extends ConsumerStatefulWidget {
  const RiderGuarantorScreen({super.key});

  @override
  ConsumerState<RiderGuarantorScreen> createState() =>
      _RiderGuarantorScreenState();
}

class _RiderGuarantorScreenState extends ConsumerState<RiderGuarantorScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameCtrl;
  late TextEditingController _phoneCtrl;
  late TextEditingController _relCtrl;
  late TextEditingController _addressCtrl;

  bool _consentAgreed = true;

  @override
  void initState() {
    super.initState();
    final state = ref.read(onboardingNotifierProvider);
    final g = state.guarantor;
    _nameCtrl = TextEditingController(
      text: g?.fullName ?? 'Chief Michael Ogundipe',
    );
    _phoneCtrl = TextEditingController(
      text: g?.phoneNumber ?? '+2348023344556',
    );
    _relCtrl = TextEditingController(
      text: g?.relationship ?? 'Uncle / Senior Civil Servant',
    );
    _addressCtrl = TextEditingController(
      text: g?.residentialAddress ?? '14 Bode Thomas St, Surulere, Lagos',
    );
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _relCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (!_consentAgreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please confirm guarantor consent before proceeding.'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      ref.read(onboardingNotifierProvider.notifier).updateGuarantorDetails(
            fullName: _nameCtrl.text.trim(),
            phoneNumber: _phoneCtrl.text.trim(),
            relationship: _relCtrl.text.trim(),
            residentialAddress: _addressCtrl.text.trim(),
          );
      context.push('/onboarding/training');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Rider Application'),
        backgroundColor: GVColors.darkBg,
        elevation: 0,
      ),
      backgroundColor: GVColors.darkBg,
      body: SafeArea(
        child: Column(
          children: [
            // Progress Indicator
            const LinearProgressIndicator(
              value: 0.80,
              backgroundColor: Color(0xFF232D28),
              valueColor: AlwaysStoppedAnimation(GVColors.brandGreen),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: GVSpacing.md,
                vertical: GVSpacing.xs,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'Step 4 of 5: Guarantor Details',
                      style: GVTypography.caption.copyWith(
                        color: GVColors.brandGreen,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '80% completed',
                    style: GVTypography.caption.copyWith(color: Colors.white54),
                  ),
                ],
              ),
            ),
            const Divider(color: Color(0xFF232D28), height: 1),

            Expanded(
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.all(GVSpacing.md),
                  children: [
                    Text(
                      'Guarantor & Referee Verification',
                      style: GVTypography.h2.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: GVSpacing.xs),
                    Text(
                      'To protect passenger safety and high-value parcel delivery, provide details of a reputable guarantor residing in Lagos State.',
                      style: GVTypography.caption.copyWith(
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: GVSpacing.lg),

                    // Guarantor Name
                    TextFormField(
                      controller: _nameCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Guarantor Full Legal Name *',
                        prefixIcon: Icon(
                          Icons.person,
                          color: GVColors.brandGreen,
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Guarantor name is required' : null,
                    ),
                    const SizedBox(height: GVSpacing.md),

                    // Phone Number
                    TextFormField(
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Guarantor Mobile Phone Number (+234...) *',
                        prefixIcon: Icon(
                          Icons.phone,
                          color: GVColors.brandGreen,
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().length < 10) ? 'Valid phone number required' : null,
                    ),
                    const SizedBox(height: GVSpacing.md),

                    // Relationship / Profession
                    TextFormField(
                      controller: _relCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Relationship & Profession in Lagos *',
                        prefixIcon: Icon(
                          Icons.work,
                          color: GVColors.brandGreen,
                        ),
                        hintText: 'e.g. Senior Civil Servant, Business Owner',
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Relationship is required' : null,
                    ),
                    const SizedBox(height: GVSpacing.md),

                    // Residential Address
                    TextFormField(
                      controller: _addressCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Guarantor Residential Address (Lagos State) *',
                        prefixIcon: Icon(
                          Icons.home_work,
                          color: GVColors.brandGreen,
                        ),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Address is required' : null,
                    ),
                    const SizedBox(height: GVSpacing.lg),

                    // Consent Checkbox
                    CheckboxListTile(
                      value: _consentAgreed,
                      onChanged: (v) => setState(() => _consentAgreed = v ?? true),
                      activeColor: GVColors.brandGreen,
                      checkColor: GVColors.deepGreen,
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        'I confirm that my guarantor has consented to phone and physical address verification by Go-Volts fleet compliance officers.',
                        style: GVTypography.caption.copyWith(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: GVSpacing.xl),
                  ],
                ),
              ),
            ),

            // Next CTA
            Padding(
              padding: const EdgeInsets.all(GVSpacing.md),
              child: GVPrimaryButton(
                label: 'Save & Continue to Safety Training',
                onPressed: _handleNext,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
