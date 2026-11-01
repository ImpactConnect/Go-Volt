import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../application/saved_places_notifier.dart';

enum PlaceType { home, work, school, custom }

class SavedPlaceItem {
  const SavedPlaceItem({
    required this.id,
    required this.name,
    required this.address,
    required this.type,
    this.isUsedInActivePlan = false,
  });

  final String id;
  final String name;
  final String address;
  final PlaceType type;
  final bool isUsedInActivePlan;
}

/// Screen B3 / H05: Saved Places Manager with Dependent Plan Deletion Guard (§B3 & Master Spec).
class SavedPlacesScreen extends StatefulWidget {
  final List<SavedPlaceItem>? initialPlaces;
  const SavedPlacesScreen({super.key, this.initialPlaces});

  @override
  State<SavedPlacesScreen> createState() => _SavedPlacesScreenState();
}

class _SavedPlacesScreenState extends State<SavedPlacesScreen> {
  static const List<SavedPlaceItem> defaultPlaces = [
    SavedPlaceItem(
      id: 'place_1',
      name: 'Home',
      address: '14 Admiralty Way, Lekki Phase 1, Lagos',
      type: PlaceType.home,
      isUsedInActivePlan: true,
    ),
    SavedPlaceItem(
      id: 'place_2',
      name: 'Work',
      address: '18 Adeola Odeku St, Victoria Island, Lagos',
      type: PlaceType.work,
      isUsedInActivePlan: true,
    ),
    SavedPlaceItem(
      id: 'place_3',
      name: 'Corona School Victoria Island',
      address: '6 Waziri Ibrahim Cres, Victoria Island',
      type: PlaceType.school,
      isUsedInActivePlan: true,
    ),
    SavedPlaceItem(
      id: 'place_4',
      name: 'Gym & Fitness Hub',
      address: 'Plot 12 Lekki-Epe Expressway, Lagos',
      type: PlaceType.custom,
      isUsedInActivePlan: false,
    ),
  ];

  late List<SavedPlaceItem> _places;

  @override
  void initState() {
    super.initState();
    _places = widget.initialPlaces != null
        ? List<SavedPlaceItem>.from(widget.initialPlaces!)
        : List<SavedPlaceItem>.from(defaultPlaces);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncFromProvider();
    });
  }

  void _syncFromProvider() {
    try {
      final container = ProviderScope.containerOf(context, listen: false);
      final places = container.read(savedPlacesNotifierProvider).places;
      if (widget.initialPlaces == null && places.isNotEmpty) {
        setState(() {
          _places = places.map((p) {
            PlaceType pt = PlaceType.custom;
            if (p.isHome) pt = PlaceType.home;
            if (p.isWork) pt = PlaceType.work;
            if (p.isSchool) pt = PlaceType.school;
            return SavedPlaceItem(
              id: p.id,
              name: p.label,
              address: p.address,
              type: pt,
              isUsedInActivePlan: p.isUsedInActivePlan,
            );
          }).toList();
        });
      }
    } catch (_) {}
  }

  void _addNewPlace() {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
    final instructionsController = TextEditingController();
    PlaceType selectedType = PlaceType.custom;

    showDialog<void>(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: const Color(0xFF1C2420),
          title: const Text('Add Saved Place', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Label (e.g. Home, Office, Gym)',
                  labelStyle: TextStyle(color: Colors.white60),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: addressController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Address in Lagos',
                  labelStyle: TextStyle(color: Colors.white60),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: instructionsController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Delivery Instructions (Optional)',
                  labelStyle: TextStyle(color: Colors.white60),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButton<PlaceType>(
                value: selectedType,
                dropdownColor: const Color(0xFF1C2420),
                isExpanded: true,
                style: const TextStyle(color: Colors.white),
                items: const [
                  DropdownMenuItem(value: PlaceType.home, child: Text('Home')),
                  DropdownMenuItem(value: PlaceType.work, child: Text('Work / Office')),
                  DropdownMenuItem(value: PlaceType.school, child: Text('School')),
                  DropdownMenuItem(value: PlaceType.custom, child: Text('Custom Location')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() => selectedType = val);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: GVColors.brandGreen,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                final label = nameController.text.trim();
                final address = addressController.text.trim();
                if (label.isEmpty || address.isEmpty) return;

                final newItem = SavedPlaceItem(
                  id: 'place_${DateTime.now().millisecondsSinceEpoch}',
                  name: label,
                  address: address,
                  type: selectedType,
                  isUsedInActivePlan: false,
                );

                setState(() => _places.add(newItem));

                try {
                  final container = ProviderScope.containerOf(context, listen: false);
                  SavedPlaceType spType = SavedPlaceType.custom;
                  if (selectedType == PlaceType.home) spType = SavedPlaceType.home;
                  if (selectedType == PlaceType.work) spType = SavedPlaceType.work;
                  if (selectedType == PlaceType.school) spType = SavedPlaceType.school;

                  container.read(savedPlacesNotifierProvider.notifier).addPlace(
                        label: label,
                        address: address,
                        type: spType,
                        latitude: 6.4474,
                        longitude: 3.4735,
                        additionalInstructions: instructionsController.text.trim(),
                      );
                } catch (_) {}

                if (dialogCtx.mounted) Navigator.pop(dialogCtx);
              },
              child: const Text('Save Place'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(SavedPlaceItem place) {
    if (place.isUsedInActivePlan) {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text('Delete ${place.name}?'),
          content: const Text(
            'WARNING: An active School-Run or Recurring Commute plan depends on this address! Modifying or deleting this place will disrupt scheduled pickups.\n\nAre you sure you want to proceed?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Keep Place'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade800,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(ctx);
                setState(() => _places.removeWhere((p) => p.id == place.id));
                try {
                  final container = ProviderScope.containerOf(context, listen: false);
                  container.read(savedPlacesNotifierProvider.notifier).deletePlace(placeId: place.id, force: true);
                } catch (_) {}
              },
              child: const Text('Confirm Deletion'),
            ),
          ],
        ),
      );
      return;
    }

    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Delete ${place.name}?'),
        content: Text('Are you sure you want to remove "${place.name}" from your saved places?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade800,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => _places.removeWhere((p) => p.id == place.id));
              try {
                final container = ProviderScope.containerOf(context, listen: false);
                container.read(savedPlacesNotifierProvider.notifier).deletePlace(placeId: place.id);
              } catch (_) {}
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  IconData _getPlaceIcon(PlaceType type) {
    switch (type) {
      case PlaceType.home:
        return Icons.home;
      case PlaceType.work:
        return Icons.work;
      case PlaceType.school:
        return Icons.school;
      case PlaceType.custom:
        return Icons.place;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1411),
      appBar: const GVTopBar(title: 'Saved Places'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(GVSpacing.md),
          children: [
            Container(
              padding: const EdgeInsets.all(GVSpacing.md),
              decoration: BoxDecoration(
                color: const Color(0xFF1C2420),
                borderRadius: BorderRadius.circular(GVBorderRadius.md),
                border: Border.all(color: const Color(0xFF2A3630)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield_outlined, color: GVColors.brandGreen, size: 28),
                  const SizedBox(width: GVSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Trip & Commute Safeguards',
                          style: GVTypography.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Destinations used in recurring school runs or commutes cannot be deleted without reassigning routes.',
                          style: GVTypography.caption.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: GVSpacing.lg),

            Text(
              'Your Saved Places (${_places.length})',
              style: GVTypography.caption.copyWith(color: Colors.white70, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: GVSpacing.sm),

            for (final place in _places)
              Container(
                margin: const EdgeInsets.only(bottom: GVSpacing.sm),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2420),
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(color: const Color(0xFF2A3630)),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF2A3630),
                    child: Icon(_getPlaceIcon(place.type), color: GVColors.brandGreen),
                  ),
                  title: Row(
                    children: [
                      Flexible(
                        child: Text(
                          place.name,
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (place.isUsedInActivePlan) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.amber.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'ACTIVE PLAN',
                            style: TextStyle(color: Colors.amber, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      place.address,
                      style: GVTypography.caption.copyWith(color: Colors.white60),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.white54, size: 20),
                    onPressed: () => _confirmDelete(place),
                  ),
                ),
              ),

            if (_places.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: GVSpacing.xxl),
                child: Center(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(GVSpacing.lg),
                        decoration: BoxDecoration(
                          color: GVColors.brandGreen.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.place_outlined, size: 48, color: GVColors.brandGreen),
                      ),
                      const SizedBox(height: GVSpacing.md),
                      Text('No saved places yet', style: GVTypography.h3.copyWith(color: Colors.white)),
                      const SizedBox(height: GVSpacing.xs),
                      Text(
                        'Save your frequent destinations like Home, Work, or School for quick 1-tap bookings.',
                        textAlign: TextAlign.center,
                        style: GVTypography.caption.copyWith(color: Colors.white60),
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: GVSpacing.lg),
            GVPrimaryButton(
              label: 'Add New Saved Place',
              onPressed: _addNewPlace,
            ),
          ],
        ),
      ),
    );
  }
}
