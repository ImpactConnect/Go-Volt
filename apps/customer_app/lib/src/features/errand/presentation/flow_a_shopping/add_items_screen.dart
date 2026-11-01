import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../application/shopping_errand_notifier.dart';

/// Screen A3 (ME-A02): Add Items (Interactive shopping list builder).
/// Matches high-fidelity design template Row 1 Screen A3.
class AddItemsScreen extends ConsumerWidget {
  const AddItemsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(shoppingErrandNotifierProvider);
    final notifier = ref.read(shoppingErrandNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F1512) : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: isDark ? GVColors.white : GVColors.textPrimary,
            size: 20,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Add Items',
          style: GVTypography.h3.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? GVColors.white : GVColors.textPrimary,
          ),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
                children: [
                  const SizedBox(height: GVSpacing.sm),

                  // Shopping Store Summary chip
                  if (state.selectedShop != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: GVSpacing.md,
                        vertical: GVSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E2B23)
                            : const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(GVBorderRadius.md),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.storefront_rounded,
                            color: Color(0xFF00C853),
                            size: 20,
                          ),
                          const SizedBox(width: GVSpacing.sm),
                          Expanded(
                            child: Text(
                              'Shopping at: ${state.selectedShop!.name}',
                              style: GVTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? GVColors.white
                                    : const Color(0xFF2E7D32),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: GVSpacing.md),

                  // Shopping Items List
                  if (state.items.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.shopping_basket_outlined,
                              size: 48,
                              color: isDark
                                  ? GVColors.neutral500
                                  : const Color(0xFFBDBDBD),
                            ),
                            const SizedBox(height: GVSpacing.sm),
                            Text(
                              'Your shopping list is empty',
                              style: GVTypography.bodyMedium.copyWith(
                                color: isDark
                                    ? GVColors.neutral400
                                    : GVColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    for (final item in state.items) ...[
                      _buildItemCard(context, item, isDark, notifier),
                      const SizedBox(height: GVSpacing.sm),
                    ],

                  const SizedBox(height: GVSpacing.md),

                  // "+ Add another item" Button
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF00C853), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(GVBorderRadius.md),
                      ),
                      backgroundColor: isDark
                          ? const Color(0xFF161F1A)
                          : const Color(0xFFF1F8F4),
                    ),
                    onPressed: () => _showAddItemSheet(context, isDark, notifier),
                    icon: const Icon(
                      Icons.add_circle_outline_rounded,
                      color: Color(0xFF00C853),
                      size: 20,
                    ),
                    label: Text(
                      'Add another item',
                      style: GVTypography.bodyMedium.copyWith(
                        color: const Color(0xFF00C853),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(GVSpacing.lg),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF161F1A) : GVColors.white,
          border: Border(
            top: BorderSide(
              color: isDark ? const Color(0xFF2E3D35) : const Color(0xFFEEEEEE),
            ),
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: state.canProceedFromItems
                    ? const Color(0xFF00C853)
                    : const Color(0xFFA5D6A7),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                ),
              ),
              onPressed: state.canProceedFromItems
                  ? () => context.push(AppRoutes.errandPreferences)
                  : null,
              child: Text(
                'Continue',
                style: GVTypography.bodyLarge.copyWith(
                  color: GVColors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildItemCard(
    BuildContext context,
    ShoppingItemDto item,
    bool isDark,
    ShoppingErrandNotifier notifier,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161F1A) : GVColors.white,
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        border: Border.all(
          color: isDark ? const Color(0xFF2A3D32) : const Color(0xFFE0E0E0),
        ),
      ),
      padding: const EdgeInsets.all(GVSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Item Graphic Indicator
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF243329)
                  : const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(GVBorderRadius.sm),
            ),
            child: const Icon(
              Icons.eco_rounded,
              color: Color(0xFF00C853),
              size: 24,
            ),
          ),

          const SizedBox(width: GVSpacing.md),

          // Item Info (Name, Budget ceiling)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.name,
                        style: GVTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? GVColors.white : GVColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    InkWell(
                      onTap: () => notifier.removeItem(item.id),
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: Color(0xFFE53935),
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${item.quantity} ${item.unit} • Up to ₦${((item.estimatedPriceKobo * item.quantity) / 100).toStringAsFixed(0)}',
                  style: GVTypography.bodySmall.copyWith(
                    color: isDark ? GVColors.neutral400 : GVColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),

                // Stepper Buttons: [-] [qty] [+]
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStepperBtn(
                      icon: Icons.remove,
                      onTap: () => notifier.decrementQuantity(item.id),
                      isDark: isDark,
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: GVSpacing.md),
                      child: Text(
                        '${item.quantity} ${item.unit}',
                        style: GVTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? GVColors.white : GVColors.textPrimary,
                        ),
                      ),
                    ),
                    _buildStepperBtn(
                      icon: Icons.add,
                      onTap: () => notifier.incrementQuantity(item.id),
                      isDark: isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepperBtn({
    required IconData icon,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2A3D32) : const Color(0xFFEEEEEE),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: Icon(
          icon,
          size: 16,
          color: isDark ? GVColors.white : GVColors.textPrimary,
        ),
        onPressed: onTap,
      ),
    );
  }

  void _showAddItemSheet(
    BuildContext context,
    bool isDark,
    ShoppingErrandNotifier notifier,
  ) {
    final nameCtrl = TextEditingController();
    final qtyCtrl = TextEditingController(text: '1');
    final budgetCtrl = TextEditingController(text: '2000');
    final notesCtrl = TextEditingController();
    String selectedUnit = 'kg';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF161F1A) : GVColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(GVBorderRadius.lg)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: GVSpacing.lg,
                right: GVSpacing.lg,
                top: GVSpacing.lg,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + GVSpacing.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Add Item to List',
                        style: GVTypography.h3.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  const SizedBox(height: GVSpacing.md),
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Item Name *',
                      hintText: 'e.g. Fresh Tomatoes, Eggs, Milk',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: GVSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: qtyCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Quantity *',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: GVSpacing.sm),
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          initialValue: selectedUnit,
                          decoration: const InputDecoration(
                            labelText: 'Unit',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(value: 'kg', child: Text('kg')),
                            DropdownMenuItem(value: 'pcs', child: Text('pcs')),
                            DropdownMenuItem(value: 'packs', child: Text('packs')),
                            DropdownMenuItem(value: 'bags', child: Text('bags')),
                            DropdownMenuItem(value: 'bunches', child: Text('bunches')),
                            DropdownMenuItem(value: 'baskets', child: Text('baskets')),
                            DropdownMenuItem(value: 'litres', child: Text('litres')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              setSheetState(() => selectedUnit = val);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: GVSpacing.md),
                  TextField(
                    controller: budgetCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Estimated Unit Budget (₦) *',
                      hintText: 'e.g. 2000',
                      border: OutlineInputBorder(),
                      prefixText: '₦ ',
                    ),
                  ),
                  const SizedBox(height: GVSpacing.md),
                  TextField(
                    controller: notesCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Preferences / Brand / Quality notes (Optional)',
                      hintText: 'e.g. Fresh, ripe, well packaged',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: GVSpacing.lg),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00C853),
                      ),
                      onPressed: () {
                        final name = nameCtrl.text.trim();
                        final qty = int.tryParse(qtyCtrl.text.trim()) ?? 1;
                        final budget = int.tryParse(budgetCtrl.text.trim()) ?? 1000;
                        if (name.isNotEmpty) {
                          notifier.addItem(
                            ShoppingItemDto(
                              id: 'item_${DateTime.now().millisecondsSinceEpoch}',
                              name: name,
                              quantity: qty,
                              unit: selectedUnit,
                              estimatedPriceKobo: budget * 100,
                              preferenceNotes: notesCtrl.text.trim().isNotEmpty
                                  ? notesCtrl.text.trim()
                                  : null,
                            ),
                          );
                          Navigator.of(ctx).pop();
                        }
                      },
                      child: const Text(
                        'Add to Shopping List',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
