import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../application/onboarding_notifier.dart';

/// Screen RD03: Personal Information & KYC Profile.
class RiderPersonalScreen extends ConsumerStatefulWidget {
  const RiderPersonalScreen({super.key});

  @override
  ConsumerState<RiderPersonalScreen> createState() =>
      _RiderPersonalScreenState();
}

class _RiderPersonalScreenState extends ConsumerState<RiderPersonalScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _addressController;
  late TextEditingController _emergencyNameController;
  late TextEditingController _emergencyPhoneController;

  String _selectedLga = 'Ikeja';

  final List<String> _lagosLgas = [
    'Ikeja',
    'Eti-Osa (VI / Lekki)',
    'Lagos Island',
    'Lagos Mainland',
    'Surulere',
    'Yaba / Ebute Metta',
    'Kosofe (Gbagada / Ogudu)',
    'Alimosho',
    'Oshodi-Isolo',
    'Ikorodu',
  ];

  @override
  void initState() {
    super.initState();
    final state = ref.read(onboardingNotifierProvider);
    _nameController = TextEditingController(
      text: state.fullName.isNotEmpty ? state.fullName : 'Babajide Ogundipe',
    );
    _phoneController = TextEditingController(
      text: state.phoneNumber.isNotEmpty
          ? state.phoneNumber
          : '+2348031122334',
    );
    _emailController = TextEditingController(
      text: state.email.isNotEmpty
          ? state.email
          : 'babajide.ogundipe@govolts.ng',
    );
    _addressController = TextEditingController(
      text: state.residentialAddress.isNotEmpty
          ? state.residentialAddress
          : '18 Admiralty Way, Lekki Phase 1',
    );
    _emergencyNameController = TextEditingController(
      text: state.emergencyContactName.isNotEmpty
          ? state.emergencyContactName
          : 'Funke Ogundipe',
    );
    _emergencyPhoneController = TextEditingController(
      text: state.emergencyContactPhone.isNotEmpty
          ? state.emergencyContactPhone
          : '+2348029988776',
    );
    _selectedLga = state.lagosLga.isNotEmpty ? state.lagosLga : 'Eti-Osa (VI / Lekki)';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  void _handleNext() {
    if (_formKey.currentState?.validate() ?? false) {
      ref.read(onboardingNotifierProvider.notifier).updatePersonalDetails(
            fullName: _nameController.text.trim(),
            phoneNumber: _phoneController.text.trim(),
            email: _emailController.text.trim(),
            residentialAddress: _addressController.text.trim(),
            lagosLga: _selectedLga,
            emergencyContactName: _emergencyNameController.text.trim(),
            emergencyContactPhone: _emergencyPhoneController.text.trim(),
          );
      context.push('/onboarding/documents');
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
              value: 0.20,
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
                      'Step 1 of 5: Personal KYC',
                      style: GVTypography.caption.copyWith(color: GVColors.brandGreen),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '20% completed',
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
                      'Applicant Personal Profile',
                      style: GVTypography.h2.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: GVSpacing.xs),
                    Text(
                      'Enter your legal name as it appears on your official Nigerian ID and Lagos State credentials.',
                      style: GVTypography.caption.copyWith(color: Colors.white70),
                    ),
                    const SizedBox(height: GVSpacing.lg),

                    // Full Legal Name
                    TextFormField(
                      controller: _nameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Full Legal Name *',
                        prefixIcon: Icon(Icons.person, color: GVColors.brandGreen),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Full name is required' : null,
                    ),
                    const SizedBox(height: GVSpacing.md),

                    // Phone Number (+234 E.164)
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Mobile Phone Number (+234...) *',
                        prefixIcon: Icon(Icons.phone, color: GVColors.brandGreen),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().length < 10) ? 'Enter a valid Nigerian phone number' : null,
                    ),
                    const SizedBox(height: GVSpacing.md),

                    // Email Address
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Email Address *',
                        prefixIcon: Icon(Icons.email, color: GVColors.brandGreen),
                      ),
                      validator: (v) =>
                          (v == null || !v.contains('@')) ? 'Enter a valid email address' : null,
                    ),
                    const SizedBox(height: GVSpacing.md),

                    // Residential Address
                    TextFormField(
                      controller: _addressController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Residential Street Address *',
                        prefixIcon: Icon(Icons.home, color: GVColors.brandGreen),
                      ),
                      validator: (v) =>
                          (v == null || v.trim().isEmpty) ? 'Address is required for verification' : null,
                    ),
                    const SizedBox(height: GVSpacing.md),

                    // Lagos LGA Dropdown
                    DropdownButtonFormField<String>(
                      initialValue: _lagosLgas.contains(_selectedLga) ? _selectedLga : _lagosLgas.first,
                      dropdownColor: const Color(0xFF1C2420),
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Lagos Local Government Area (LGA) *',
                        prefixIcon: Icon(Icons.location_city, color: GVColors.brandGreen),
                      ),
                      isExpanded: true,
                      items: _lagosLgas
                          .map((lga) => DropdownMenuItem(value: lga, child: Text(lga)))
                          .toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedLga = val);
                      },
                    ),
                    const SizedBox(height: GVSpacing.lg),

                    // Emergency Contact Card
                    Container(
                      padding: const EdgeInsets.all(GVSpacing.md),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1C2420),
                        borderRadius: BorderRadius.circular(GVBorderRadius.md),
                        border: Border.all(color: const Color(0xFF2A3630)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.shield, color: GVColors.brandGreen, size: 20),
                              const SizedBox(width: GVSpacing.xs),
                              Text(
                                'Emergency Contact',
                                style: GVTypography.bodyMedium.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: GVSpacing.sm),
                          TextFormField(
                            controller: _emergencyNameController,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Contact Name (Spouse / Kin) *',
                              prefixIcon: Icon(Icons.person_outline, color: Colors.white54),
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty) ? 'Emergency contact name is required' : null,
                          ),
                          const SizedBox(height: GVSpacing.sm),
                          TextFormField(
                            controller: _emergencyPhoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Emergency Phone Number *',
                              prefixIcon: Icon(Icons.phone_outlined, color: Colors.white54),
                            ),
                            validator: (v) =>
                                (v == null || v.trim().length < 10) ? 'Enter a valid emergency phone' : null,
                          ),
                        ],
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
                label: 'Save & Continue to Documents',
                onPressed: _handleNext,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
