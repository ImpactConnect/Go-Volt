import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_router.dart';
import '../application/booking_notifier.dart';

/// H03 & R01 — Location Picker & Address Search Screen
class LocationPickerScreen extends ConsumerStatefulWidget {
  const LocationPickerScreen({super.key});

  @override
  ConsumerState<LocationPickerScreen> createState() =>
      _LocationPickerScreenState();
}

class _LocationPickerScreenState extends ConsumerState<LocationPickerScreen> {
  final _searchController = TextEditingController();
  bool _isSelectingPickup = false; // default is selecting destination

  // Lagos preset locations with coordinates
  static const List<LocationDto> _popularDestinations = [
    LocationDto(
      latitude: 6.4281,
      longitude: 3.4219,
      address: 'Victoria Island, Lagos',
      label: 'Victoria Island Financial District',
    ),
    LocationDto(
      latitude: 6.4474,
      longitude: 3.4723,
      address: 'Admiralty Way, Lekki Phase 1',
      label: 'Lekki Phase 1',
    ),
    LocationDto(
      latitude: 6.6018,
      longitude: 3.3515,
      address: 'Alausa, Ikeja, Lagos',
      label: 'Ikeja City Mall & Secretariat',
    ),
    LocationDto(
      latitude: 6.5168,
      longitude: 3.3768,
      address: 'Commercial Avenue, Yaba',
      label: 'Yaba Tech Corridor',
    ),
    LocationDto(
      latitude: 6.5244,
      longitude: 3.3792,
      address: 'Marina, Lagos Island',
      label: 'Marina Ferry & CMS Terminal',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // Default pickup location to Marina if not set
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final booking = ref.read(bookingNotifierProvider);
      if (booking.pickupLocation == null) {
        ref.read(bookingNotifierProvider.notifier).setPickupLocation(
              const LocationDto(
                latitude: 6.5244,
                longitude: 3.3792,
                address: '14 Marina Street, Lagos Island',
                label: 'Current Location',
              ),
            );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSelectLocation(LocationDto location) {
    final notifier = ref.read(bookingNotifierProvider.notifier);
    if (_isSelectingPickup) {
      notifier.setPickupLocation(location);
      setState(() => _isSelectingPickup = false);
    } else {
      notifier.setDropoffLocation(location);
      _proceedToServiceFlow();
    }
  }

  void _proceedToServiceFlow() {
    final bookingState = ref.read(bookingNotifierProvider);
    switch (bookingState.serviceCode) {
      case ServiceCode.instantRide:
        context.push(AppRoutes.rideBooking);
        break;
      case ServiceCode.instantDelivery:
        context.push(AppRoutes.packageDetails);
        break;
      case ServiceCode.scheduledRide:
      case ServiceCode.scheduledPickup:
        context.push(AppRoutes.scheduledBooking);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookingState = ref.watch(bookingNotifierProvider);
    final pickup = bookingState.pickupLocation?.address ?? 'Current Location';
    final dropoff = bookingState.dropoffLocation?.address;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: GVTopBar(
        title: _isSelectingPickup ? 'Set Pickup Spot' : 'Where to?',
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Dual location card (Pickup & Destination)
            Container(
              margin: const EdgeInsets.all(GVSpacing.md),
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: GVColors.softBackground,
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                border: Border.all(color: GVColors.border),
              ),
              child: Column(
                children: [
                  // Pickup location row
                  GVLocationField(
                    label: 'PICKUP',
                    value: pickup,
                    isPickup: true,
                    onTap: () => setState(() => _isSelectingPickup = true),
                  ),
                  const SizedBox(height: GVSpacing.sm),

                  // Destination location row
                  GVLocationField(
                    label: 'DESTINATION',
                    value: dropoff,
                    hint: 'Enter dropoff address...',
                    isPickup: false,
                    onTap: () => setState(() => _isSelectingPickup = false),
                  ),
                ],
              ),
            ),

            // Search filter field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: GVSpacing.md),
              child: GVFormField(
                label: 'Search address or landmark',
                hint: 'e.g. Landmark Beach, Ikeja Mall...',
                controller: _searchController,
                prefix: const Icon(Icons.search_rounded),
                onChanged: (_) => setState(() {}),
              ),
            ),
            const SizedBox(height: GVSpacing.md),

            // Saved place shortcuts
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: GVSpacing.md),
              child: Row(
                children: [
                  _buildQuickChip(
                    icon: Icons.home_rounded,
                    label: 'Home',
                    location: const LocationDto(
                      latitude: 6.5244,
                      longitude: 3.3792,
                      address: '14 Marina Street, Lagos Island',
                      label: 'Home',
                    ),
                  ),
                  const SizedBox(width: GVSpacing.sm),
                  _buildQuickChip(
                    icon: Icons.work_rounded,
                    label: 'Work',
                    location: const LocationDto(
                      latitude: 6.4281,
                      longitude: 3.4219,
                      address: '25 Adeola Odeku, Victoria Island',
                      label: 'Work',
                    ),
                  ),
                  const SizedBox(width: GVSpacing.sm),
                  _buildQuickChip(
                    icon: Icons.school_rounded,
                    label: 'School',
                    location: const LocationDto(
                      latitude: 6.5168,
                      longitude: 3.3768,
                      address: 'University of Lagos, Akoka',
                      label: 'Campus',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.sm),
            const Divider(),

            // Suggestions List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: GVSpacing.md),
                itemCount: _filteredDestinations.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final loc = _filteredDestinations[index];
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(vertical: 4),
                    leading: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: GVColors.softBackground,
                        borderRadius: BorderRadius.circular(GVBorderRadius.sm),
                      ),
                      child: const Icon(
                        Icons.electric_bolt_rounded,
                        color: GVColors.brandGreen,
                        size: 22,
                      ),
                    ),
                    title: Text(
                      loc.label ?? loc.address,
                      style: GVTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      loc.address,
                      style: GVTypography.caption.copyWith(
                        color: GVColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: GVColors.textSecondary,
                    ),
                    onTap: () => _onSelectLocation(loc),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<LocationDto> get _filteredDestinations {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _popularDestinations;
    return _popularDestinations.where((loc) {
      final label = loc.label?.toLowerCase() ?? '';
      final address = loc.address.toLowerCase();
      return label.contains(query) || address.contains(query);
    }).toList();
  }

  Widget _buildQuickChip({
    required IconData icon,
    required String label,
    required LocationDto location,
  }) {
    return ActionChip(
      avatar: Icon(icon, size: 16, color: GVColors.brandGreen),
      label: Text(label, style: GVTypography.caption),
      backgroundColor: GVColors.softBackground,
      side: const BorderSide(color: GVColors.border),
      onPressed: () => _onSelectLocation(location),
    );
  }
}
