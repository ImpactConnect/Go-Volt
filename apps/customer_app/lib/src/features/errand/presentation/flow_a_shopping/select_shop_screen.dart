import 'package:app_models/app_models.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../application/shopping_errand_notifier.dart';
import '../../data/errand_repository.dart';
import '../../domain/shopping_flow_state.dart';

/// Screen A2 (ME-A01): Select Shop or Market.
/// Matches high-fidelity design template Row 1 Screen A2.
class SelectShopScreen extends ConsumerStatefulWidget {
  const SelectShopScreen({super.key});

  @override
  ConsumerState<SelectShopScreen> createState() => _SelectShopScreenState();
}

class _SelectShopScreenState extends ConsumerState<SelectShopScreen> {
  final _searchController = TextEditingController();
  String _activeTab = 'nearby'; // 'nearby', 'popular', 'saved'
  List<ShopDto> _shops = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadShops();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadShops() async {
    setState(() => _isLoading = true);
    final repo = ref.read(errandRepositoryProvider);
    try {
      final list = await repo.getShops(
        tab: _activeTab,
        search: _searchController.text.trim(),
      );
      setState(() {
        _shops = list;
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  void _onTabChanged(String tab) {
    if (_activeTab == tab) return;
    setState(() => _activeTab = tab);
    _loadShops();
  }

  @override
  Widget build(BuildContext context) {
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
          'Select Shop / Market',
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
            // Search Input Field
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: GVSpacing.lg,
                vertical: GVSpacing.xs,
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E2B23) : GVColors.white,
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                  border: Border.all(
                    color: isDark ? const Color(0xFF2E4035) : const Color(0xFFE0E0E0),
                  ),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => _loadShops(),
                  decoration: InputDecoration(
                    hintText: 'Search shop, market or location',
                    hintStyle: GVTypography.bodyMedium.copyWith(
                      color: isDark ? GVColors.neutral500 : const Color(0xFF9E9E9E),
                    ),
                    prefixIcon: Icon(
                      Icons.search_rounded,
                      color: isDark ? GVColors.neutral400 : const Color(0xFF757575),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              _loadShops();
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: GVSpacing.md,
                      vertical: GVSpacing.sm,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: GVSpacing.xs),

            // Tab Filter Chips (Nearby, Popular, Saved)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
              child: Row(
                children: [
                  _buildTabChip('Nearby', 'nearby', isDark),
                  const SizedBox(width: GVSpacing.sm),
                  _buildTabChip('Popular', 'popular', isDark),
                  const SizedBox(width: GVSpacing.sm),
                  _buildTabChip('Saved', 'saved', isDark),
                ],
              ),
            ),

            const SizedBox(height: GVSpacing.md),

            // Shop List & Custom Shop Option
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: GVSpacing.lg),
                      children: [
                        for (final shop in _shops) ...[
                          _buildShopCard(
                            shop,
                            isSelected: state.selectedShop?.id == shop.id,
                            isDark: isDark,
                            onTap: () => notifier.selectShop(shop),
                          ),
                          const SizedBox(height: GVSpacing.sm),
                        ],

                        const SizedBox(height: GVSpacing.xs),

                        // "Use a custom shop" card
                        _buildCustomShopCard(isDark, state, notifier),

                        const SizedBox(height: 80),
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
                backgroundColor: state.canProceedFromShop
                    ? const Color(0xFF00C853)
                    : const Color(0xFFA5D6A7),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(GVBorderRadius.md),
                ),
              ),
              onPressed: state.canProceedFromShop
                  ? () => context.push(AppRoutes.errandAddItems)
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

  Widget _buildTabChip(String label, String key, bool isDark) {
    final isSelected = _activeTab == key;
    return InkWell(
      borderRadius: BorderRadius.circular(GVBorderRadius.full),
      onTap: () => _onTabChanged(key),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: GVSpacing.md,
          vertical: GVSpacing.xs + 2,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF00C853)
              : (isDark ? const Color(0xFF1E2B23) : const Color(0xFFEEEEEE)),
          borderRadius: BorderRadius.circular(GVBorderRadius.full),
        ),
        child: Text(
          label,
          style: GVTypography.bodySmall.copyWith(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? GVColors.white
                : (isDark ? GVColors.neutral300 : GVColors.textPrimary),
          ),
        ),
      ),
    );
  }

  Widget _buildShopCard(
    ShopDto shop, {
    required bool isSelected,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161F1A) : GVColors.white,
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF00C853)
              : (isDark ? const Color(0xFF2A3D32) : const Color(0xFFE0E0E0)),
          width: isSelected ? 1.8 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(GVBorderRadius.md),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(GVSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        shop.name,
                        style: GVTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? GVColors.white : GVColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${shop.address} • ${shop.formattedDistance}',
                        style: GVTypography.bodySmall.copyWith(
                          color: isDark ? GVColors.neutral400 : GVColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: GVSpacing.sm),
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFF00C853)
                          : (isDark ? GVColors.neutral500 : const Color(0xFFBDBDBD)),
                      width: 2,
                    ),
                    color: isSelected ? const Color(0xFF00C853) : Colors.transparent,
                  ),
                  child: isSelected
                      ? const Icon(Icons.check, size: 14, color: GVColors.white)
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomShopCard(
    bool isDark,
    ShoppingFlowState state,
    ShoppingErrandNotifier notifier,
  ) {
    final isCustomSelected = state.selectedShop?.isCustom == true;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF161F1A) : GVColors.white,
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        border: Border.all(
          color: isCustomSelected
              ? const Color(0xFF00C853)
              : (isDark ? const Color(0xFF2A3D32) : const Color(0xFFE0E0E0)),
          width: isCustomSelected ? 1.8 : 1.0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(GVBorderRadius.md),
          onTap: () => _showCustomShopDialog(context, isDark, notifier),
          child: Padding(
            padding: const EdgeInsets.all(GVSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF243329) : const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(GVBorderRadius.sm),
                  ),
                  child: const Icon(
                    Icons.store_outlined,
                    color: Color(0xFF00C853),
                    size: 22,
                  ),
                ),
                const SizedBox(width: GVSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isCustomSelected
                            ? state.selectedShop!.name
                            : 'Use a custom shop',
                        style: GVTypography.bodyLarge.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? GVColors.white : GVColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isCustomSelected
                            ? state.selectedShop!.address
                            : 'Enter shop/market details',
                        style: GVTypography.bodySmall.copyWith(
                          color: isDark ? GVColors.neutral400 : GVColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.edit_outlined,
                  size: 18,
                  color: isDark ? GVColors.neutral400 : GVColors.textSecondary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCustomShopDialog(
    BuildContext context,
    bool isDark,
    ShoppingErrandNotifier notifier,
  ) {
    final nameCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? const Color(0xFF161F1A) : GVColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(GVBorderRadius.lg)),
      ),
      builder: (ctx) {
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
                    'Custom Shop Details',
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
                  labelText: 'Shop / Market Name *',
                  hintText: 'e.g. Kasuwan Friday Store',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: GVSpacing.md),
              TextField(
                controller: addressCtrl,
                decoration: const InputDecoration(
                  labelText: 'Shop Address / Location *',
                  hintText: 'e.g. Near Shaganu Roundabout, Ogun State',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: GVSpacing.md),
              TextField(
                controller: phoneCtrl,
                decoration: const InputDecoration(
                  labelText: 'Contact Phone (Optional)',
                  hintText: '080...',
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
                    if (nameCtrl.text.trim().isNotEmpty &&
                        addressCtrl.text.trim().isNotEmpty) {
                      notifier.setCustomShop(
                        name: nameCtrl.text.trim(),
                        address: addressCtrl.text.trim(),
                        phoneNumber: phoneCtrl.text.trim(),
                      );
                      Navigator.of(ctx).pop();
                    }
                  },
                  child: const Text(
                    'Save Custom Shop',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
