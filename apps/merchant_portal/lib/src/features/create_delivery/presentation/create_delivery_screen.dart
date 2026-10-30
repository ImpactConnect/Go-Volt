import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/auth/merchant_auth_notifier.dart';
import '../../bookings/application/merchant_bookings_notifier.dart';
import '../../bookings/domain/merchant_delivery_model.dart';
import 'package:app_models/app_models.dart';

class CreateDeliveryScreen extends ConsumerStatefulWidget {
  const CreateDeliveryScreen({super.key});

  @override
  ConsumerState<CreateDeliveryScreen> createState() => _CreateDeliveryScreenState();
}

class _CreateDeliveryScreenState extends ConsumerState<CreateDeliveryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Single form controllers
  final _recipientNameController = TextEditingController(text: 'Chief Emeka Obi');
  final _recipientPhoneController = TextEditingController(text: '+2348023344556');
  final _addressController = TextEditingController(text: '7 Adeola Odeku Street, Victoria Island');
  final _notesController = TextEditingController(text: 'Deliver to 3rd floor reception');
  String _selectedZone = 'Lekki / Victoria Island';
  String _selectedCategory = 'Food & Hot Meal';
  double _weightKg = 1.5;
  bool _isFragile = false;

  // Bulk simulated items
  List<MerchantDeliveryBooking> _bulkPreview = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _recipientNameController.dispose();
    _recipientPhoneController.dispose();
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  int get _calculatedFareKobo {
    // Base ₦1,200 + Weight surcharge + Zone rate - Green discount
    const base = 120000;
    final weightSurcharge = ((_weightKg - 1.0).clamp(0.0, 50.0) * 20000).toInt();
    final zoneRate = _selectedZone == 'Ikeja / Mainland' ? 80000 : 50000;
    const greenDiscount = 20000; // -₦200 green discount
    return base + weightSurcharge + zoneRate - greenDiscount;
  }

  String get _formattedCalculatedFare {
    final naira = _calculatedFareKobo / 100.0;
    return '₦${naira.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  void _dispatchSingleDelivery() async {
    final userState = ref.read(merchantAuthNotifierProvider);
    final bookingsNotifier = ref.read(merchantBookingsNotifierProvider.notifier);

    await bookingsNotifier.createDeliveryBooking(
      branchId: userState.activeBranchId,
      branchName: userState.activeBranchName,
      recipientName: _recipientNameController.text.trim(),
      recipientPhone: _recipientPhoneController.text.trim(),
      deliveryAddress: _addressController.text.trim(),
      deliveryZone: _selectedZone,
      packageCategory: _selectedCategory,
      weightKg: _weightKg,
      isFragile: _isFragile,
      specialInstructions: _notesController.text.trim(),
      grossFareKobo: _calculatedFareKobo,
    );

    if (mounted) {
      context.go('/bookings');
    }
  }

  void _simulateCsvLoad() {
    final userState = ref.read(merchantAuthNotifierProvider);
    final now = DateTime.now();

    setState(() {
      _bulkPreview = [
        MerchantDeliveryBooking(
          id: 'dlv_bulk_01',
          trackingReference: 'GV-MC-BULK-01',
          branchId: userState.activeBranchId,
          branchName: userState.activeBranchName,
          recipientName: 'Sarah Danjuma',
          recipientPhone: '+2348031112223',
          deliveryAddress: 'Block 4, 1004 Estate, VI',
          deliveryZone: 'Lagos Island',
          packageCategory: 'Food & Hot Meal',
          weightKg: 1.0,
          grossFareKobo: 200000,
          status: BookingStatus.searchingRider,
          recipientOtp: '3312',
          createdAt: now,
          timeline: const [DeliveryTimelineEvent(status: 'BULK_INGESTED', timestamp: 'Just now', note: 'Uploaded via CSV batch')],
        ),
        MerchantDeliveryBooking(
          id: 'dlv_bulk_02',
          trackingReference: 'GV-MC-BULK-02',
          branchId: userState.activeBranchId,
          branchName: userState.activeBranchName,
          recipientName: 'Kolawole Sanusi',
          recipientPhone: '+2348094445556',
          deliveryAddress: '24 Bourdillon Road, Ikoyi',
          deliveryZone: 'Lagos Island',
          packageCategory: 'Documents & Contract',
          weightKg: 0.5,
          isFragile: true,
          grossFareKobo: 220000,
          status: BookingStatus.searchingRider,
          recipientOtp: '8904',
          createdAt: now,
          timeline: const [DeliveryTimelineEvent(status: 'BULK_INGESTED', timestamp: 'Just now', note: 'Uploaded via CSV batch')],
        ),
      ];
    });
  }

  void _dispatchBulkDeliveries() async {
    if (_bulkPreview.isEmpty) return;
    final bookingsNotifier = ref.read(merchantBookingsNotifierProvider.notifier);
    await bookingsNotifier.batchCreateDeliveries(_bulkPreview);
    if (mounted) {
      context.go('/bookings');
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(merchantAuthNotifierProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0C120F),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(GVSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dispatch Delivery Booking',
                        style: GVTypography.h1.copyWith(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Generate instant upfront quote and dispatch nearest high-battery electric moped',
                        style: GVTypography.bodyMedium.copyWith(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: GVSpacing.lg),

            // Tabs: Single Delivery vs Bulk Batch CSV
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF141C18),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF223028)),
              ),
              child: TabBar(
                controller: _tabController,
                indicatorColor: GVColors.brandGreen,
                labelColor: GVColors.brandGreen,
                unselectedLabelColor: Colors.white60,
                tabs: const [
                  Tab(icon: Icon(Icons.delivery_dining), text: 'Single Dispatch Order'),
                  Tab(icon: Icon(Icons.upload_file), text: 'Bulk CSV Ingestion'),
                ],
              ),
            ),

            const SizedBox(height: GVSpacing.lg),

            SizedBox(
              height: 640,
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Tab 1: Single Dispatch Form
                  _buildSingleDispatchForm(userState),

                  // Tab 2: Bulk CSV Upload Tab
                  _buildBulkCsvTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSingleDispatchForm(MerchantUserState userState) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left Column: Order Inputs
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(GVSpacing.lg),
            decoration: BoxDecoration(
              color: const Color(0xFF141C18),
              borderRadius: BorderRadius.circular(GVBorderRadius.md),
              border: Border.all(color: const Color(0xFF223028)),
            ),
            child: ListView(
              children: [
                Text(
                  '1. PICKUP & RECIPIENT INFORMATION',
                  style: GVTypography.caption.copyWith(color: GVColors.brandGreen, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: GVSpacing.md),

                // Pickup Branch (read-only active branch)
                TextFormField(
                  initialValue: userState.activeBranchName,
                  enabled: false,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Pickup Branch Location',
                    prefixIcon: Icon(Icons.storefront, color: GVColors.brandGreen),
                    border: OutlineInputBorder(),
                    fillColor: Color(0xFF1B241F),
                    filled: true,
                  ),
                ),
                const SizedBox(height: GVSpacing.md),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        key: const Key('recipient_name_field'),
                        controller: _recipientNameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Recipient Full Name *',
                          prefixIcon: Icon(Icons.person, color: Colors.white60),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: GVSpacing.md),
                    Expanded(
                      child: TextField(
                        key: const Key('recipient_phone_field'),
                        controller: _recipientPhoneController,
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Recipient Phone (+234...) *',
                          prefixIcon: Icon(Icons.phone, color: Colors.white60),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: GVSpacing.md),

                TextField(
                  key: const Key('recipient_address_field'),
                  controller: _addressController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Delivery Street Address *',
                    prefixIcon: Icon(Icons.location_on, color: Colors.white60),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: GVSpacing.md),

                // Service Zone Dropdown
                DropdownButtonFormField<String>(
                  initialValue: _selectedZone,
                  dropdownColor: const Color(0xFF1B241F),
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Delivery Lagos Zone *',
                    prefixIcon: Icon(Icons.map, color: Colors.white60),
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Lekki / Victoria Island', child: Text('Lekki / Victoria Island (Zone A)')),
                    DropdownMenuItem(value: 'Lagos Island', child: Text('Lagos Island / Ikoyi (Zone B)')),
                    DropdownMenuItem(value: 'Ikeja / Mainland', child: Text('Ikeja / Mainland (Zone C)')),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _selectedZone = val);
                  },
                ),

                const SizedBox(height: GVSpacing.lg),
                Text(
                  '2. PACKAGE DETAILS',
                  style: GVTypography.caption.copyWith(color: GVColors.brandGreen, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: GVSpacing.md),

                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: _selectedCategory,
                        dropdownColor: const Color(0xFF1B241F),
                        style: const TextStyle(color: Colors.white),
                        decoration: const InputDecoration(
                          labelText: 'Package Category *',
                          prefixIcon: Icon(Icons.category, color: Colors.white60),
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(value: 'Food & Hot Meal', child: Text('Food & Hot Meal')),
                          DropdownMenuItem(value: 'Documents & Contract', child: Text('Documents & Contract')),
                          DropdownMenuItem(value: 'Electronics', child: Text('Electronics & Gadgets')),
                          DropdownMenuItem(value: 'Retail Parcel', child: Text('Retail Goods / Clothing')),
                        ],
                        onChanged: (val) {
                          if (val != null) setState(() => _selectedCategory = val);
                        },
                      ),
                    ),
                    const SizedBox(width: GVSpacing.md),
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: Slider(
                              value: _weightKg,
                              min: 0.5,
                              max: 10.0,
                              divisions: 19,
                              label: '$_weightKg kg',
                              activeColor: GVColors.brandGreen,
                              onChanged: (val) => setState(() => _weightKg = double.parse(val.toStringAsFixed(1))),
                            ),
                          ),
                          Text('$_weightKg kg', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: GVSpacing.sm),

                CheckboxListTile(
                  title: const Text('Fragile Package (Handle with extreme care)', style: TextStyle(color: Colors.white)),
                  value: _isFragile,
                  activeColor: GVColors.brandGreen,
                  checkColor: Colors.black,
                  onChanged: (val) => setState(() => _isFragile = val ?? false),
                ),

                TextField(
                  controller: _notesController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Special Delivery Instructions (Optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: GVSpacing.lg),

        // Right Column: Upfront Price Breakdown & Submit
        Expanded(
          flex: 2,
          child: Container(
            padding: const EdgeInsets.all(GVSpacing.lg),
            decoration: BoxDecoration(
              color: const Color(0xFF141C18),
              borderRadius: BorderRadius.circular(GVBorderRadius.md),
              border: Border.all(color: const Color(0xFF223028)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bolt, color: GVColors.brandGreen, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'UPFRONT FARE QUOTE',
                      style: GVTypography.h3.copyWith(color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Guaranteed server price lock. Deducted from corporate wallet upon confirmation.',
                  style: GVTypography.caption.copyWith(color: Colors.white60),
                ),
                const Divider(color: Color(0xFF223028), height: GVSpacing.xl),

                _buildQuoteRow('Base Dispatch Tariff', '₦1,200.00'),
                const SizedBox(height: 8),
                _buildQuoteRow('Zone Transit Fee', _selectedZone == 'Ikeja / Mainland' ? '₦800.00' : '₦500.00'),
                const SizedBox(height: 8),
                _buildQuoteRow('Weight Surcharge (>1kg)', '₦${((_weightKg - 1.0).clamp(0.0, 50.0) * 200).toStringAsFixed(2)}'),
                const SizedBox(height: 8),
                _buildQuoteRow('Green EV Fleet Discount', '-₦200.00', isDiscount: true),

                const Divider(color: Color(0xFF223028), height: GVSpacing.xl),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Upfront Fare', style: GVTypography.h3.copyWith(color: Colors.white)),
                    Text(
                      _formattedCalculatedFare,
                      key: const Key('total_fare_display'),
                      style: GVTypography.h1.copyWith(color: GVColors.brandGreen, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),

                const Spacer(),

                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF18241D),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF2B3D32)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.account_balance_wallet, color: GVColors.brandGreen, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Payment via Corporate Wallet (${userState.formattedWalletBalance})',
                          style: GVTypography.caption.copyWith(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: GVSpacing.md),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    key: const Key('confirm_dispatch_btn'),
                    onPressed: _dispatchSingleDelivery,
                    icon: const Icon(Icons.send, size: 18),
                    label: const Text('Confirm & Dispatch Order'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GVColors.brandGreen,
                      foregroundColor: GVColors.nearBlack,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBulkCsvTab() {
    return Container(
      padding: const EdgeInsets.all(GVSpacing.lg),
      decoration: BoxDecoration(
        color: const Color(0xFF141C18),
        borderRadius: BorderRadius.circular(GVBorderRadius.md),
        border: Border.all(color: const Color(0xFF223028)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bulk CSV E-Commerce Batch Ingestion',
                    style: GVTypography.h3.copyWith(color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Upload formatted CSV file (recipient_name, phone, address, zone, package_category, weight_kg)',
                    style: GVTypography.caption.copyWith(color: Colors.white60),
                  ),
                ],
              ),
              ElevatedButton.icon(
                key: const Key('simulate_csv_upload_btn'),
                onPressed: _simulateCsvLoad,
                icon: const Icon(Icons.file_upload, size: 18),
                label: const Text('Upload orders.csv'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF23362B),
                  foregroundColor: GVColors.brandGreen,
                ),
              ),
            ],
          ),
          const Divider(color: Color(0xFF223028), height: GVSpacing.xl),

          if (_bulkPreview.isEmpty)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.cloud_upload_outlined, size: 48, color: Colors.white38),
                    SizedBox(height: 12),
                    Text('No CSV batch loaded yet. Click "Upload orders.csv" to preview bulk orders.',
                        style: TextStyle(color: Colors.white54)),
                  ],
                ),
              ),
            )
          else ...[
            Text('Validated Batch Preview (${_bulkPreview.length} Deliveries Ready):',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            const SizedBox(height: GVSpacing.sm),
            Expanded(
              child: ListView.builder(
                itemCount: _bulkPreview.length,
                itemBuilder: (ctx, i) {
                  final item = _bulkPreview[i];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A2620),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.trackingReference, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            Text('${item.recipientName} (${item.recipientPhone}) · ${item.deliveryAddress}',
                                style: GVTypography.caption.copyWith(color: Colors.white60)),
                          ],
                        ),
                        Text(item.formattedFare, style: const TextStyle(color: GVColors.brandGreen, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: GVSpacing.md),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                key: const Key('confirm_bulk_dispatch_btn'),
                onPressed: _dispatchBulkDeliveries,
                icon: const Icon(Icons.rocket_launch, size: 18),
                label: Text('Dispatch All ${_bulkPreview.length} Orders Immediately'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: GVColors.brandGreen,
                  foregroundColor: GVColors.nearBlack,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuoteRow(String label, String value, {bool isDiscount = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70)),
        Text(
          value,
          style: TextStyle(
            color: isDiscount ? Colors.lightGreenAccent : Colors.white,
            fontWeight: isDiscount ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
