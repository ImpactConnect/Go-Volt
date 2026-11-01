import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

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

/// Screen H05: Saved Places Manager with Dependent Plan Deletion Guard.
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
  }

  void _addNewPlace() {
    final nameController = TextEditingController();
    final addressController = TextEditingController();
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
                  labelText: 'Label (e.g. Grandma\'s House)',
                  labelStyle: TextStyle(color: Colors.white60),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: addressController,
                style: const TextStyle(color: Colors.white),
                decoration: const InputDecoration(
                  labelText: 'Street Address',
                  labelStyle: TextStyle(color: Colors.white60),
                ),
              ),
              const SizedBox(height: 12),
              DropdownButton<PlaceType>(
                value: selectedType,
                dropdownColor: const Color(0xFF1C2420),
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: PlaceType.home, child: Text('Home', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: PlaceType.work, child: Text('Work', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: PlaceType.school, child: Text('School', style: TextStyle(color: Colors.white))),
                  DropdownMenuItem(value: PlaceType.custom, child: Text('Custom', style: TextStyle(color: Colors.white))),
                ],
                onChanged: (val) {
                  if (val != null) setDialogState(() => selectedType = val);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: GVColors.brandGreen),
              onPressed: () {
                if (nameController.text.trim().isNotEmpty && addressController.text.trim().isNotEmpty) {
                  setState(() {
                    _places.add(
                      SavedPlaceItem(
                        id: 'place_${DateTime.now().millisecondsSinceEpoch}',
                        name: nameController.text.trim(),
                        address: addressController.text.trim(),
                        type: selectedType,
                      ),
                    );
                  });
                  Navigator.of(dialogCtx).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Saved place added.'),
                      backgroundColor: GVColors.deepGreen,
                    ),
                  );
                }
              },
              child: const Text('Save Place', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(SavedPlaceItem place) {
    showDialog<void>(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: const Color(0xFF1C2420),
        title: Text('Delete ${place.name}?', style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to remove ${place.address}?', style: const TextStyle(color: Colors.white70)),
            if (place.isUsedInActivePlan) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.redAccent),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.redAccent, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'WARNING: An active School-Run or Recurring Commute plan depends on this address! Deleting will require plan re-quote.',
                        style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogCtx).pop(),
            child: const Text('Keep Place', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              setState(() {
                _places.removeWhere((p) => p.id == place.id);
              });
              Navigator.of(dialogCtx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${place.name} deleted from saved places.'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            },
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GVColors.darkBg,
      appBar: AppBar(
        title: const Text('Saved Places'),
        backgroundColor: GVColors.darkBg,
        elevation: 0,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(GVSpacing.md),
          children: [
            for (final place in _places)
              Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(GVSpacing.md),
                decoration: BoxDecoration(
                  color: const Color(0xFF1C2420),
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(color: const Color(0xFF2A3630)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: GVColors.deepGreen.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(_getPlaceIcon(place.type), color: GVColors.brandGreen, size: 22),
                    ),
                    const SizedBox(width: GVSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  place.name,
                                  style: GVTypography.bodyMedium.copyWith(color: Colors.white, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (place.isUsedInActivePlan) ...[
                                const SizedBox(width: 6),
                                const GVStatusChip(label: 'ACTIVE PLAN', status: GVStatusType.active),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            place.address,
                            style: GVTypography.caption.copyWith(color: Colors.white60),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.white54, size: 20),
                      onPressed: () => _confirmDelete(place),
                    ),
                  ],
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
                        child: const Icon(Icons.place_outlined,
                            size: 48, color: GVColors.brandGreen),
                      ),
                      const SizedBox(height: GVSpacing.md),
                      Text('No saved places yet',
                          style: GVTypography.h3.copyWith(color: Colors.white)),
                      const SizedBox(height: GVSpacing.xs),
                      Text(
                        'Save your frequent destinations like Home, Work, or School for quick 1-tap bookings.',
                        textAlign: TextAlign.center,
                        style: GVTypography.caption
                            .copyWith(color: Colors.white60),
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
}
