import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for admin operating locations management.
final adminLocationsProvider =
    StateNotifierProvider<AdminLocationsNotifier, List<OperatingLocationDto>>(
  (ref) => AdminLocationsNotifier(),
);

class AdminLocationsNotifier
    extends StateNotifier<List<OperatingLocationDto>> {
  AdminLocationsNotifier()
      : super([
          const OperatingLocationDto(
            id: 'loc_01',
            state: 'Ogun',
            city: 'Shaganu',
            isActive: true,
            status: 'fully_supported',
            statusDescription: 'Fully supported',
            availableServices: [
              'instant_ride',
              'instant_delivery',
              'scheduled_ride',
              'scheduled_pickup',
            ],
            centerLat: 6.8403,
            centerLng: 3.6487,
          ),
        ]);

  void addLocation(OperatingLocationDto location) {
    state = [...state, location];
  }

  void toggleActive(String id) {
    state = state
        .map((loc) =>
            loc.id == id ? loc.copyWith(isActive: !loc.isActive) : loc)
        .toList();
  }

  void updateLocation(OperatingLocationDto updated) {
    state = state.map((l) => l.id == updated.id ? updated : l).toList();
  }

  void removeLocation(String id) {
    state = state.where((l) => l.id != id).toList();
  }
}

/// Screen to view and provision operating cities & states for Go-Volt.
class OperatingLocationsScreen extends ConsumerStatefulWidget {
  const OperatingLocationsScreen({super.key});

  @override
  ConsumerState<OperatingLocationsScreen> createState() =>
      _OperatingLocationsScreenState();
}

class _OperatingLocationsScreenState
    extends ConsumerState<OperatingLocationsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showAddLocationDialog() {
    final stateCtrl = TextEditingController(text: 'Ogun');
    final cityCtrl = TextEditingController();
    final latCtrl = TextEditingController(text: '6.8403');
    final lngCtrl = TextEditingController(text: '3.6487');
    String selectedStatus = 'fully_supported';

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Provision Operating Location'),
          content: SizedBox(
            width: 440,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'State',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: stateCtrl,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Ogun, Lagos, Oyo',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'City',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: cityCtrl,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Shaganu, Abeokuta, Ijebu Ode',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Center Lat',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 4),
                            TextField(
                              controller: latCtrl,
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder()),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Center Lng',
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 13)),
                            const SizedBox(height: 4),
                            TextField(
                              controller: lngCtrl,
                              decoration: const InputDecoration(
                                  border: OutlineInputBorder()),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Operational Status',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<String>(
                    initialValue: selectedStatus,
                    items: const [
                      DropdownMenuItem(
                        value: 'fully_supported',
                        child: Text('Fully Supported'),
                      ),
                      DropdownMenuItem(
                        value: 'limited',
                        child: Text('Limited Services'),
                      ),
                      DropdownMenuItem(
                        value: 'coming_soon',
                        child: Text('Coming Soon'),
                      ),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setDialogState(() => selectedStatus = val);
                      }
                    },
                    decoration: const InputDecoration(border: OutlineInputBorder()),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: GVColors.brandGreen,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                final stateName = stateCtrl.text.trim();
                final cityName = cityCtrl.text.trim();
                if (stateName.isNotEmpty && cityName.isNotEmpty) {
                  ref.read(adminLocationsProvider.notifier).addLocation(
                        OperatingLocationDto(
                          id: 'loc_${DateTime.now().millisecondsSinceEpoch}',
                          state: stateName,
                          city: cityName,
                          isActive: true,
                          status: selectedStatus,
                          statusDescription: selectedStatus == 'fully_supported'
                              ? 'Fully supported'
                              : (selectedStatus == 'limited'
                                  ? 'Limited services'
                                  : 'Coming soon'),
                          availableServices: const [
                            'instant_ride',
                            'instant_delivery',
                            'scheduled_ride',
                            'scheduled_pickup',
                          ],
                          centerLat: double.tryParse(latCtrl.text),
                          centerLng: double.tryParse(lngCtrl.text),
                        ),
                      );
                  Navigator.of(ctx).pop();
                }
              },
              child: const Text('Provision City'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locations = ref.watch(adminLocationsProvider);
    final filtered = _searchQuery.isEmpty
        ? locations
        : locations
            .where((l) =>
                l.city.toLowerCase().contains(_searchQuery) ||
                l.state.toLowerCase().contains(_searchQuery))
            .toList();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Operating Locations & Service Cities',
                    style: GVTypography.h2.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Provision states and cities where Go-Volt offers EV ride and delivery services.',
                    style: GVTypography.bodyMedium
                        .copyWith(color: GVColors.textSecondary),
                  ),
                ],
              ),
              ElevatedButton.icon(
                icon: const Icon(Icons.add_location_alt_rounded),
                label: const Text('Provision New City'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GVColors.brandGreen,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                ),
                onPressed: _showAddLocationDialog,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Search Box
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search operating states or cities...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: GVColors.border),
              ),
            ),
            onChanged: (val) =>
                setState(() => _searchQuery = val.trim().toLowerCase()),
          ),
          const SizedBox(height: 16),

          // Table
          Expanded(
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: const BorderSide(color: GVColors.border),
              ),
              child: ListView.separated(
                itemCount: filtered.length,
                separatorBuilder: (c, i) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final loc = filtered[index];
                  return ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: loc.isActive
                            ? GVColors.brandGreen.withValues(alpha: 0.12)
                            : Colors.grey.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.location_city_rounded,
                        color: loc.isActive ? GVColors.brandGreen : Colors.grey,
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(
                          loc.displayName,
                          style: GVTypography.bodyMedium
                              .copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: loc.isFullySupported
                                ? GVColors.brandGreen.withValues(alpha: 0.15)
                                : Colors.amber.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            loc.statusDescription,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: loc.isFullySupported
                                  ? GVColors.brandGreen
                                  : Colors.amber.shade800,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(
                      'Center: (${loc.centerLat ?? 0.0}, ${loc.centerLng ?? 0.0}) • Services: ${loc.availableServices.join(", ")}',
                      style: GVTypography.caption
                          .copyWith(color: GVColors.textSecondary),
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Switch(
                          value: loc.isActive,
                          activeThumbColor: GVColors.brandGreen,
                          onChanged: (_) {
                            ref
                                .read(adminLocationsProvider.notifier)
                                .toggleActive(loc.id);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: GVColors.error),
                          onPressed: () {
                            ref
                                .read(adminLocationsProvider.notifier)
                                .removeLocation(loc.id);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
