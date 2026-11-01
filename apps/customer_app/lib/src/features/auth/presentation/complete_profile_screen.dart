import 'package:cached_network_image/cached_network_image.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/auth/auth_notifier.dart';
import '../../../core/router/app_router.dart';
import '../data/operating_location_repository.dart';

/// A06 — Complete Profile Screen (full registration)
///
/// Triggered after Google OAuth or Email signup.
/// Collects: name, gender, phone, state/city (from DB), address,
/// emergency contact, and optional profile photo.
class CompleteProfileScreen extends ConsumerStatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  ConsumerState<CompleteProfileScreen> createState() =>
      _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends ConsumerState<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;

  // ── Controllers ──────────────────────────────────────────────────────────
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyNameController = TextEditingController();
  final _emergencyPhoneController = TextEditingController();

  // ── State ─────────────────────────────────────────────────────────────────
  String? _selectedGender;
  String? _selectedState;
  String? _selectedCity;
  String? _avatarLocalPath; // local file path from image picker
  bool _isSubmitting = false;

  static const List<Map<String, String>> _genders = [
    {'value': 'male', 'label': 'Male', 'emoji': '👨'},
    {'value': 'female', 'label': 'Female', 'emoji': '👩'},
    {'value': 'non_binary', 'label': 'Non-binary', 'emoji': '🧑'},
    {'value': 'prefer_not_to_say', 'label': 'Prefer not to say', 'emoji': '🤐'},
  ];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(authNotifierProvider).profile;
    _firstNameController = TextEditingController(
      text: profile?.firstName ?? '',
    );
    _lastNameController = TextEditingController(text: profile?.lastName ?? '');
  }

  @override
  void dispose() {
    _pageController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _emergencyNameController.dispose();
    _emergencyPhoneController.dispose();
    super.dispose();
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  bool _validateCurrentPage() {
    switch (_currentPage) {
      case 0:
        // Personal details page
        if (_firstNameController.text.trim().isEmpty) return false;
        if (_lastNameController.text.trim().isEmpty) return false;
        if (_selectedGender == null) return false;
        if (_phoneController.text.trim().isEmpty) return false;
        final digits = _phoneController.text.replaceAll(RegExp(r'[^0-9]'), '');
        if (digits.length < 10) return false;
        return true;
      case 1:
        // Location page
        if (_selectedState == null) return false;
        if (_selectedCity == null) return false;
        if (_addressController.text.trim().isEmpty) return false;
        return true;
      case 2:
        // Emergency contact page
        if (_emergencyNameController.text.trim().isEmpty) return false;
        final eDigits = _emergencyPhoneController.text.replaceAll(
          RegExp(r'[^0-9]'),
          '',
        );
        if (eDigits.length < 10) return false;
        return true;
    }
    return true;
  }

  // ── Image Picker ──────────────────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final file = await picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (file != null && mounted) {
        setState(() => _avatarLocalPath = file.path);
      }
    } catch (_) {
      // silently ignore permission errors — avatar is optional
    }
  }

  void _showImagePickerSheet() {
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(
                Icons.camera_alt_rounded,
                color: GVColors.brandGreen,
              ),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(
                Icons.photo_library_rounded,
                color: GVColors.brandGreen,
              ),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  // ── Submit ────────────────────────────────────────────────────────────────

  Future<void> _submit() async {
    if (!_validateCurrentPage()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields.'),
          backgroundColor: GVColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final fullName =
        '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'
            .trim();

    final success = await ref
        .read(authNotifierProvider.notifier)
        .completeProfile(
          fullName: fullName,
          phoneNumber: _phoneController.text.trim(),
          gender: _selectedGender,
          state: _selectedState,
          city: _selectedCity,
          currentAddress: _addressController.text.trim(),
          emergencyContactName: _emergencyNameController.text.trim(),
          emergencyContactPhone: _emergencyPhoneController.text.trim(),
        );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        context.go(AppRoutes.locationPermission);
      }
    }
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final profile = authState.profile;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // ── Progress Header ──────────────────────────────────────────
            _buildProgressHeader(),

            // ── Error Banner ─────────────────────────────────────────────
            if (authState.errorMessage != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
                padding: const EdgeInsets.all(GVSpacing.sm),
                decoration: BoxDecoration(
                  color: GVColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.error_outline_rounded,
                      color: GVColors.error,
                      size: 18,
                    ),
                    const SizedBox(width: GVSpacing.sm),
                    Expanded(
                      child: Text(
                        authState.errorMessage!,
                        style: GVTypography.bodySmall.copyWith(
                          color: GVColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ── Page Views ───────────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentPage = i),
                children: [
                  _buildPersonalDetailsPage(profile),
                  _buildLocationPage(),
                  _buildEmergencyContactPage(profile),
                ],
              ),
            ),

            // ── Bottom Navigation ─────────────────────────────────────────
            _buildBottomNav(),
          ],
        ),
      ),
    );
  }

  // ── Progress Header ───────────────────────────────────────────────────────

  Widget _buildProgressHeader() {
    const steps = ['Personal', 'Location', 'Emergency'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        GVSpacing.lg,
        GVSpacing.lg,
        GVSpacing.lg,
        GVSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button + title row
          Row(
            children: [
              if (_currentPage > 0)
                GestureDetector(
                  onTap: _prevPage,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: GVColors.softBackground,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: GVColors.border),
                    ),
                    child: const Icon(
                      Icons.arrow_back_rounded,
                      size: 20,
                      color: GVColors.textPrimary,
                    ),
                  ),
                )
              else
                const SizedBox(width: 36),
              const SizedBox(width: GVSpacing.sm),
              Expanded(
                child: Text(
                  'Complete Your Profile',
                  style: GVTypography.h3.copyWith(
                    fontWeight: FontWeight.bold,
                    color: GVColors.textPrimary,
                  ),
                ),
              ),
              Text(
                '${_currentPage + 1}/3',
                style: GVTypography.bodySmall.copyWith(
                  color: GVColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: GVSpacing.sm),
          // Step progress bar
          Row(
            children: List.generate(steps.length, (i) {
              final done = i < _currentPage;
              final active = i == _currentPage;
              return Expanded(
                child: Container(
                  margin: EdgeInsets.only(right: i < steps.length - 1 ? 6 : 0),
                  height: 4,
                  decoration: BoxDecoration(
                    color: done || active
                        ? GVColors.brandGreen
                        : GVColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 6),
          Row(
            children: List.generate(steps.length, (i) {
              return Expanded(
                child: Text(
                  steps[i],
                  style: GVTypography.caption.copyWith(
                    color: i == _currentPage
                        ? GVColors.brandGreen
                        : GVColors.textSecondary,
                    fontWeight: i == _currentPage
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 11,
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // ── Page 1: Personal Details ──────────────────────────────────────────────

  Widget _buildPersonalDetailsPage(dynamic profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(GVSpacing.lg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar picker
            Center(child: _buildAvatarPicker(profile)),
            const SizedBox(height: GVSpacing.lg),

            // Google profile preview card
            _buildGoogleProfileCard(profile),
            const SizedBox(height: GVSpacing.lg),

            // First Name
            _buildFieldLabel('First Name *'),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _firstNameController,
              hint: 'Enter first name',
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: GVSpacing.md),

            // Last Name
            _buildFieldLabel('Last Name *'),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _lastNameController,
              hint: 'Enter last name',
              icon: Icons.person_outline_rounded,
            ),
            const SizedBox(height: GVSpacing.md),

            // Gender
            _buildFieldLabel('Gender *'),
            const SizedBox(height: 8),
            _buildGenderSelector(),
            const SizedBox(height: GVSpacing.md),

            // Phone Number
            _buildFieldLabel('Phone Number *'),
            const SizedBox(height: 6),
            _buildPhoneField(),
            const SizedBox(height: 4),
            Text(
              'Used for driver communication and trip safety (NDPR protected)',
              style: GVTypography.caption.copyWith(
                color: GVColors.textSecondary,
                fontSize: 11,
              ),
            ),
            const SizedBox(height: GVSpacing.xl),
          ],
        ),
      ),
    );
  }

  // ── Page 2: Location ─────────────────────────────────────────────────────

  Widget _buildLocationPage() {
    final statesAsync = ref.watch(operatingStatesProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(GVSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '📍 Your Service Area',
            style: GVTypography.h3.copyWith(
              fontWeight: FontWeight.bold,
              color: GVColors.textPrimary,
            ),
          ),
          const SizedBox(height: GVSpacing.xs),
          Text(
            'Select the state and city where you\'ll be using Go-Volt. Only cities we currently operate in are listed.',
            style: GVTypography.bodySmall.copyWith(
              color: GVColors.textSecondary,
            ),
          ),
          const SizedBox(height: GVSpacing.lg),

          // State dropdown
          _buildFieldLabel('State *'),
          const SizedBox(height: 6),
          statesAsync.when(
            data: (states) => _buildDropdown<String>(
              value: _selectedState,
              items: states,
              hint: 'Select state',
              itemLabel: (s) => s,
              onChanged: (val) {
                setState(() {
                  _selectedState = val;
                  _selectedCity = null; // reset city when state changes
                });
              },
            ),
            loading: () => const _LoadingDropdown(),
            error: (e, s) => _buildDropdown<String>(
              value: _selectedState,
              items: const ['Ogun'],
              hint: 'Select state',
              itemLabel: (s2) => s2,
              onChanged: (val) => setState(() => _selectedState = val),
            ),
          ),
          const SizedBox(height: GVSpacing.md),

          // City dropdown (filtered by state)
          _buildFieldLabel('City *'),
          const SizedBox(height: 6),
          if (_selectedState == null)
            _buildDisabledDropdown('Select a state first')
          else
            ref
                .watch(operatingCitiesProvider(_selectedState!))
                .when(
                  data: (cities) => _buildDropdown<String>(
                    value: _selectedCity,
                    items: cities.map((c) => c.city).toList(),
                    hint: 'Select city',
                    itemLabel: (c) => c,
                    onChanged: (val) => setState(() => _selectedCity = val),
                  ),
                  loading: () => const _LoadingDropdown(),
                  error: (e, s) => _buildDropdown<String>(
                    value: _selectedCity,
                    items: const ['Shagamu'],
                    hint: 'Select city',
                    itemLabel: (c) => c,
                    onChanged: (val) => setState(() => _selectedCity = val),
                  ),
                ),
          const SizedBox(height: GVSpacing.md),

          // Current Address
          _buildFieldLabel('Current Address *'),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _addressController,
            hint: 'Street, house number, landmark',
            icon: Icons.home_outlined,
            maxLines: 2,
          ),
          const SizedBox(height: GVSpacing.xl),
        ],
      ),
    );
  }

  // ── Page 3: Emergency Contact ─────────────────────────────────────────────

  Widget _buildEmergencyContactPage(dynamic profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(GVSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Info card
          Container(
            padding: const EdgeInsets.all(GVSpacing.md),
            decoration: BoxDecoration(
              color: GVColors.brandGreen.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(GVBorderRadius.lg),
              border: Border.all(
                color: GVColors.brandGreen.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.shield_outlined,
                  color: GVColors.brandGreen,
                  size: 22,
                ),
                const SizedBox(width: GVSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Emergency Contact',
                        style: GVTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: GVColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'We\'ll only contact them if there\'s an emergency during your trip. Required for rider and passenger safety.',
                        style: GVTypography.caption.copyWith(
                          color: GVColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: GVSpacing.lg),

          _buildFieldLabel('Emergency Contact Name *'),
          const SizedBox(height: 6),
          _buildTextField(
            controller: _emergencyNameController,
            hint: 'Full name of contact',
            icon: Icons.person_pin_outlined,
          ),
          const SizedBox(height: GVSpacing.md),

          _buildFieldLabel('Emergency Contact Phone *'),
          const SizedBox(height: 6),
          _buildPhoneField(controller: _emergencyPhoneController),
          const SizedBox(height: GVSpacing.xl),

          // Final summary preview
          if (profile != null) _buildProfileSummaryCard(profile),
        ],
      ),
    );
  }

  // ── Widgets ───────────────────────────────────────────────────────────────

  Widget _buildAvatarPicker(dynamic profile) {
    final initials = profile?.initials ?? 'U';
    final networkUrl = profile?.avatarUrl as String?;

    return GestureDetector(
      onTap: _showImagePickerSheet,
      child: Stack(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: GVColors.brandGreen.withValues(alpha: 0.15),
              border: Border.all(color: GVColors.brandGreen, width: 2),
            ),
            child: ClipOval(
              child: _avatarLocalPath != null
                  ? Image.network(
                      _avatarLocalPath!,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, st) => _avatarInitials(initials),
                    )
                  : (networkUrl != null && networkUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: networkUrl,
                            fit: BoxFit.cover,
                            placeholder: (ctx, url) =>
                                _avatarInitials(initials),
                            errorWidget: (ctx, url, err) =>
                                _avatarInitials(initials),
                          )
                        : _avatarInitials(initials)),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              width: 28,
              height: 28,
              decoration: const BoxDecoration(
                color: GVColors.brandGreen,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarInitials(String initials) => Center(
    child: Text(
      initials,
      style: GVTypography.h2.copyWith(
        color: GVColors.brandGreen,
        fontWeight: FontWeight.bold,
      ),
    ),
  );

  Widget _buildGoogleProfileCard(dynamic profile) {
    if (profile == null) return const SizedBox.shrink();
    final email = profile.email as String? ?? '';

    return Container(
      padding: const EdgeInsets.all(GVSpacing.md),
      decoration: BoxDecoration(
        color: GVColors.softBackground,
        borderRadius: BorderRadius.circular(GVBorderRadius.lg),
        border: Border.all(color: GVColors.border),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.verified_user_rounded,
            color: GVColors.brandGreen,
            size: 22,
          ),
          const SizedBox(width: GVSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Google account verified',
                  style: GVTypography.bodySmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: GVColors.textPrimary,
                  ),
                ),
                if (email.isNotEmpty)
                  Text(
                    email,
                    style: GVTypography.caption.copyWith(
                      color: GVColors.textSecondary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _genders.map((g) {
        final isSelected = _selectedGender == g['value'];
        return GestureDetector(
          onTap: () => setState(() => _selectedGender = g['value']),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: isSelected
                  ? GVColors.brandGreen.withValues(alpha: 0.12)
                  : GVColors.softBackground,
              borderRadius: BorderRadius.circular(GVBorderRadius.md),
              border: Border.all(
                color: isSelected ? GVColors.brandGreen : GVColors.border,
                width: isSelected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(g['emoji']!, style: const TextStyle(fontSize: 14)),
                const SizedBox(width: 6),
                Text(
                  g['label']!,
                  style: GVTypography.bodySmall.copyWith(
                    color: isSelected
                        ? GVColors.brandGreen
                        : GVColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPhoneField({TextEditingController? controller}) {
    final ctrl = controller ?? _phoneController;
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        border: Border.all(color: GVColors.border),
        color: Colors.white,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: GVSpacing.sm,
              vertical: 14,
            ),
            margin: const EdgeInsets.only(right: GVSpacing.xs),
            decoration: const BoxDecoration(
              border: Border(right: BorderSide(color: GVColors.border)),
            ),
            child: Text(
              '🇳🇬 +234',
              style: GVTypography.bodySmall.copyWith(
                fontWeight: FontWeight.bold,
                color: GVColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: TextField(
              controller: ctrl,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                hintText: '08012345678',
                hintStyle: TextStyle(
                  color: GVColors.textSecondary,
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: GVSpacing.sm,
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: GVColors.textSecondary, fontSize: 14),
        prefixIcon: Icon(icon, color: GVColors.textSecondary, size: 20),
        filled: true,
        fillColor: GVColors.softBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: GVSpacing.md,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GVBorderRadius.md),
          borderSide: const BorderSide(color: GVColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(GVBorderRadius.md),
          borderSide: const BorderSide(color: GVColors.brandGreen, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T? value,
    required List<T> items,
    required String hint,
    required String Function(T) itemLabel,
    required void Function(T?) onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: GVSpacing.md),
      decoration: BoxDecoration(
        color: GVColors.softBackground,
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        border: Border.all(color: GVColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(
            hint,
            style: TextStyle(color: GVColors.textSecondary, fontSize: 14),
          ),
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: GVColors.textSecondary,
          ),
          items: items
              .map(
                (item) => DropdownMenuItem<T>(
                  value: item,
                  child: Text(
                    itemLabel(item),
                    style: GVTypography.bodyMedium.copyWith(
                      color: GVColors.textPrimary,
                    ),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildDisabledDropdown(String hint) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GVSpacing.md,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: GVColors.softBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        border: Border.all(color: GVColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              hint,
              style: TextStyle(color: GVColors.textSecondary, fontSize: 14),
            ),
          ),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: GVColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: GVTypography.bodySmall.copyWith(
        fontWeight: FontWeight.w600,
        color: GVColors.textPrimary,
      ),
    );
  }

  Widget _buildProfileSummaryCard(dynamic profile) {
    final name =
        '${_firstNameController.text.trim()} ${_lastNameController.text.trim()}'
            .trim();
    final location = (_selectedCity != null && _selectedState != null)
        ? '$_selectedCity, $_selectedState'
        : '—';

    return Container(
      padding: const EdgeInsets.all(GVSpacing.md),
      decoration: BoxDecoration(
        color: GVColors.softBackground,
        borderRadius: BorderRadius.circular(GVBorderRadius.lg),
        border: Border.all(color: GVColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Profile Summary',
            style: GVTypography.bodySmall.copyWith(
              fontWeight: FontWeight.bold,
              color: GVColors.textPrimary,
            ),
          ),
          const Divider(height: GVSpacing.md),
          _summaryRow(Icons.person_rounded, 'Name', name.isEmpty ? '—' : name),
          _summaryRow(
            Icons.wc_rounded,
            'Gender',
            _genders.firstWhere(
              (g) => g['value'] == _selectedGender,
              orElse: () => {'label': '—'},
            )['label']!,
          ),
          _summaryRow(Icons.location_city_rounded, 'Location', location),
          _summaryRow(
            Icons.home_rounded,
            'Address',
            _addressController.text.trim().isEmpty
                ? '—'
                : _addressController.text.trim(),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: GVSpacing.sm),
      child: Row(
        children: [
          Icon(icon, size: 16, color: GVColors.brandGreen),
          const SizedBox(width: GVSpacing.sm),
          Text(
            '$label: ',
            style: GVTypography.caption.copyWith(
              color: GVColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GVTypography.caption.copyWith(color: GVColors.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  // ── Bottom Nav ─────────────────────────────────────────────────────────────

  Widget _buildBottomNav() {
    final isLast = _currentPage == 2;
    final canProceed = _validateCurrentPage();

    return Container(
      padding: const EdgeInsets.fromLTRB(
        GVSpacing.lg,
        GVSpacing.sm,
        GVSpacing.lg,
        GVSpacing.lg,
      ),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: GVColors.border)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: canProceed
                  ? (_isSubmitting ? null : (isLast ? _submit : _nextPage))
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: GVColors.brandGreen,
                disabledBackgroundColor: GVColors.border,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      isLast ? 'Complete Profile & Continue' : 'Next',
                      style: GVTypography.buttonLarge.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: GVSpacing.xs),
          TextButton(
            onPressed: () => context.go(AppRoutes.locationPermission),
            child: Text(
              'Skip for now',
              style: GVTypography.bodySmall.copyWith(
                color: GVColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Loading placeholder for dropdown while async data loads.
class _LoadingDropdown extends StatelessWidget {
  const _LoadingDropdown();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(
        horizontal: GVSpacing.md,
        vertical: 14,
      ),
      decoration: BoxDecoration(
        color: GVColors.softBackground,
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        border: Border.all(color: GVColors.border),
      ),
      child: const Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: GVColors.brandGreen,
            ),
          ),
          SizedBox(width: GVSpacing.sm),
          Text('Loading...'),
        ],
      ),
    );
  }
}
