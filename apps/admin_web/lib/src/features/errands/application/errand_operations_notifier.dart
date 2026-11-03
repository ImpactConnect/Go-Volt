import 'package:app_models/app_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/auth/admin_role.dart';
import '../domain/errand_operations_models.dart';

class ErrandOperationsState {
  const ErrandOperationsState({
    this.errands = const [],
    this.disputes = const [],
    this.reconciliations = const [],
    this.selectedType,
    this.selectedStatus,
    this.searchQuery = '',
    this.actionMessage,
    this.isLoading = false,
  });

  final List<ErrandDto> errands;
  final List<ErrandDisputeModel> disputes;
  final List<ErrandReconciliationModel> reconciliations;
  final ErrandType? selectedType;
  final ErrandStatus? selectedStatus;
  final String searchQuery;
  final String? actionMessage;
  final bool isLoading;

  int get totalErrands => errands.length;

  int get activeShoppingCount => errands
      .where((e) =>
          e.status == ErrandStatus.shoppingInProgress ||
          e.status == ErrandStatus.agentAssigned ||
          e.status == ErrandStatus.inProgress ||
          e.status == ErrandStatus.outForDelivery)
      .length;

  int get pendingReconciliationsCount => reconciliations
      .where((r) => r.status == 'PENDING' || r.status == 'MAKER_APPROVED')
      .length;

  int get disputeCount =>
      disputes.where((d) => d.status == 'PENDING_REVIEW').length;

  int get completedTodayCount =>
      errands.where((e) => e.status == ErrandStatus.completed).length;

  int get totalErrandVolumeKobo => errands.fold<int>(
        0,
        (sum, e) => sum + e.quote.totalKobo,
      );

  List<ErrandDto> get filteredErrands {
    return errands.where((e) {
      if (selectedType != null && e.type != selectedType) {
        return false;
      }
      if (selectedStatus != null && e.status != selectedStatus) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final q = searchQuery.toLowerCase();
        final matchRef = e.referenceNumber.toLowerCase().contains(q);
        final matchCustomer = e.recipient.fullName.toLowerCase().contains(q);
        final matchRider = e.assignedRider?.fullName.toLowerCase().contains(q) ?? false;
        final matchShop = e.shop?.name.toLowerCase().contains(q) ?? false;
        final matchAddress = e.deliveryLocation.address.toLowerCase().contains(q);
        if (!matchRef && !matchCustomer && !matchRider && !matchShop && !matchAddress) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  ErrandOperationsState copyWith({
    List<ErrandDto>? errands,
    List<ErrandDisputeModel>? disputes,
    List<ErrandReconciliationModel>? reconciliations,
    ErrandType? selectedType,
    bool clearSelectedType = false,
    ErrandStatus? selectedStatus,
    bool clearSelectedStatus = false,
    String? searchQuery,
    String? actionMessage,
    bool clearActionMessage = false,
    bool? isLoading,
  }) {
    return ErrandOperationsState(
      errands: errands ?? this.errands,
      disputes: disputes ?? this.disputes,
      reconciliations: reconciliations ?? this.reconciliations,
      selectedType:
          clearSelectedType ? null : (selectedType ?? this.selectedType),
      selectedStatus:
          clearSelectedStatus ? null : (selectedStatus ?? this.selectedStatus),
      searchQuery: searchQuery ?? this.searchQuery,
      actionMessage: clearActionMessage
          ? null
          : (actionMessage ?? this.actionMessage),
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ErrandOperationsNotifier extends StateNotifier<ErrandOperationsState> {
  ErrandOperationsNotifier() : super(const ErrandOperationsState()) {
    _loadSeedData();
  }

  void _loadSeedData() {
    final now = DateTime.now();

    const riderAhmed = RiderDto(
      id: 'RIDER-001',
      profileId: 'PROF-001',
      fullName: 'Ahmed Ibrahim',
      phoneNumber: '+2348031234567',
      email: 'ahmed.ibrahim@govolts.ng',
      rating: 4.8,
      status: RiderStatus.assigned,
      vehiclePlate: 'ABC-123XY',
      vehicleModel: 'Spiro Commuter EV',
      batteryLevelPercent: 82,
    );

    const riderMusa = RiderDto(
      id: 'RIDER-002',
      profileId: 'PROF-002',
      fullName: 'Musa Bello',
      phoneNumber: '+2348069876543',
      email: 'musa.bello@govolts.ng',
      rating: 4.9,
      status: RiderStatus.assigned,
      vehiclePlate: 'KD-456-EF',
      vehicleModel: 'Roam Air EV',
      batteryLevelPercent: 64,
    );

    const riderFatima = RiderDto(
      id: 'RIDER-003',
      profileId: 'PROF-003',
      fullName: 'Fatima Abubakar',
      phoneNumber: '+2348023456789',
      email: 'fatima.abubakar@govolts.ng',
      rating: 4.95,
      status: RiderStatus.online,
      vehiclePlate: 'KN-789-GH',
      vehicleModel: 'Ampersand Cargo EV',
      batteryLevelPercent: 91,
    );

    // Errand 1: Flow A - Buy Items From a Shop (Shopping in progress, Kakuri Market)
    final errand1 = ErrandDto(
      id: 'ERRAND-001',
      referenceNumber: 'ERR-2026-0019',
      customerId: 'CUST-001',
      type: ErrandType.buyItems,
      status: ErrandStatus.shoppingInProgress,
      shop: const ShopDto(
        id: 'SHOP-01',
        name: 'Kakuri Main Market',
        address: 'Kakuri, Kaduna South, Kaduna',
        latitude: 10.4578,
        longitude: 7.4123,
      ),
      items: const [
        ShoppingItemDto(
          id: 'ITEM-01',
          name: 'Tomatoes',
          quantity: 2,
          unit: 'kg',
          estimatedPriceKobo: 400000,
          isPurchased: true,
          actualPriceKobo: 380000,
        ),
        ShoppingItemDto(
          id: 'ITEM-02',
          name: 'Onions',
          quantity: 1,
          unit: 'kg',
          estimatedPriceKobo: 150000,
          isPurchased: true,
          actualPriceKobo: 150000,
        ),
        ShoppingItemDto(
          id: 'ITEM-03',
          name: 'Rice (Mama\'s Pride)',
          quantity: 5,
          unit: 'kg',
          estimatedPriceKobo: 850000,
          isPurchased: false,
        ),
      ],
      preferences: const ShoppingPreferencesDto(
        substitutionPolicy: SubstitutionPolicy.contactFirst,
        additionalInstructions: 'Choose fresh items, check expiry date for packed goods.',
      ),
      deliveryLocation: const LocationDto(
        latitude: 10.5105,
        longitude: 7.4165,
        address: '3, Ahmadu Bello Way, Bayero University, Kaduna',
      ),
      recipient: const RecipientDetailsDto(
        fullName: 'Omotayo Kehinde',
        phoneNumber: '08034567890',
        deliveryAddress: '3, Ahmadu Bello Way, Bayero University, Kaduna',
        additionalAddressInfo: 'Call me when you are nearby.',
      ),
      deliveryTimeStr: 'As soon as possible',
      quote: const ErrandQuoteDto(
        id: 'Q-001',
        errandType: ErrandType.buyItems,
        estimatedItemsCostKobo: 1400000,
        serviceFeeKobo: 80000,
        deliveryFeeKobo: 120000,
        totalKobo: 1600000,
      ),
      assignedRider: riderAhmed,
      paymentMethod: PaymentMethod.wallet,
      paymentStatus: PaymentStatus.captured,
      createdAt: now.subtract(const Duration(minutes: 42)),
    );

    // Errand 2: Flow B - Pick Up a Package (In Transit from Jumia Pickup Point)
    final errand2 = ErrandDto(
      id: 'ERRAND-002',
      referenceNumber: 'ERR-2026-0020',
      customerId: 'CUST-002',
      type: ErrandType.pickupPackage,
      status: ErrandStatus.outForDelivery,
      pickupDetails: const PackagePickupDetailsDto(
        pickupBusinessName: 'Jumia Pickup Point, Barnawa',
        address: 'Barnawa Shopping Mall, Kaduna',
        latitude: 10.4850,
        longitude: 7.4320,
        contactPerson: 'Mr. Sani Musa',
        phoneNumber: '0806 321 0987',
        referenceOrderNumber: 'JM-7788290',
      ),
      packageDetails: const ParcelDetailsDto(
        description: 'Electronics (Headset)',
        category: ParcelCategoryDto.electronics,
        sizeBand: ParcelSizeBandDto.medium,
        weightKg: 3.5,
      ),
      deliveryLocation: const LocationDto(
        latitude: 10.5230,
        longitude: 7.4210,
        address: '3, De-West Plaza, Agwa, Kaduna',
      ),
      recipient: const RecipientDetailsDto(
        fullName: 'Omotayo Kehinde',
        phoneNumber: '08034567890',
        deliveryAddress: '3, De-West Plaza, Agwa, Kaduna',
        additionalAddressInfo: 'Ring the bell and hand over to the reception.',
      ),
      quote: const ErrandQuoteDto(
        id: 'Q-002',
        errandType: ErrandType.pickupPackage,
        estimatedItemsCostKobo: 0,
        serviceFeeKobo: 70000,
        deliveryFeeKobo: 110000,
        totalKobo: 180000,
      ),
      assignedRider: riderAhmed,
      paymentMethod: PaymentMethod.wallet,
      paymentStatus: PaymentStatus.captured,
      createdAt: now.subtract(const Duration(minutes: 65)),
    );

    // Errand 3: Flow C - Other Errand (Bayero University Certificate Collection, In Progress)
    final errand3 = ErrandDto(
      id: 'ERRAND-003',
      referenceNumber: 'ERR-2026-0021',
      customerId: 'CUST-003',
      type: ErrandType.otherErrand,
      status: ErrandStatus.inProgress,
      customErrandDetails: const CustomErrandDetailsDto(
        description: 'Please collect my documents from the university registrar\'s office and deliver them to my home.',
        category: 'Document Collection',
        urgency: ErrandUrgency.standard,
        taskLocation: LocationDto(
          latitude: 10.5105,
          longitude: 7.4165,
          address: 'Bayero University Registrar Office, Kaduna',
        ),
        contactPerson: 'Mrs. Amina Yusuf',
        phoneNumber: '0806 765 4321',
      ),
      deliveryLocation: const LocationDto(
        latitude: 10.4600,
        longitude: 7.4100,
        address: 'My Home – Kakuri, Kaduna',
      ),
      recipient: const RecipientDetailsDto(
        fullName: 'Mrs. Amina Yusuf',
        phoneNumber: '08067654321',
        deliveryAddress: 'My Home – Kakuri, Kaduna',
        additionalAddressInfo: 'Collect the sealed document and deliver to me.',
      ),
      quote: const ErrandQuoteDto(
        id: 'Q-003',
        errandType: ErrandType.otherErrand,
        estimatedItemsCostKobo: 0,
        serviceFeeKobo: 100000,
        deliveryFeeKobo: 120000,
        totalKobo: 220000,
      ),
      assignedRider: riderMusa,
      paymentMethod: PaymentMethod.wallet,
      paymentStatus: PaymentStatus.captured,
      createdAt: now.subtract(const Duration(minutes: 90)),
    );

    // Errand 4: Flow A - Completed Errand with Receipt Reconciliation (Murtala Supermarket)
    final errand4 = ErrandDto(
      id: 'ERRAND-004',
      referenceNumber: 'ERR-2026-0018',
      customerId: 'CUST-004',
      type: ErrandType.buyItems,
      status: ErrandStatus.completed,
      shop: const ShopDto(
        id: 'SHOP-02',
        name: 'Murtala Supermarket',
        address: 'Murtala Square, Kaduna',
        latitude: 10.5180,
        longitude: 7.4380,
      ),
      items: const [
        ShoppingItemDto(
          id: 'ITEM-11',
          name: 'Golden Penny Sugar (500g)',
          quantity: 2,
          unit: 'packs',
          estimatedPriceKobo: 180000,
          isPurchased: true,
          actualPriceKobo: 170000,
        ),
        ShoppingItemDto(
          id: 'ITEM-12',
          name: 'Peak Evaporated Milk (158g)',
          quantity: 6,
          unit: 'tins',
          estimatedPriceKobo: 360000,
          isPurchased: true,
          actualPriceKobo: 340000,
        ),
      ],
      preferences: const ShoppingPreferencesDto(
        substitutionPolicy: SubstitutionPolicy.similarAlternative,
      ),
      deliveryLocation: const LocationDto(
        latitude: 10.5050,
        longitude: 7.4200,
        address: '14 Independence Way, Kaduna',
      ),
      recipient: const RecipientDetailsDto(
        fullName: 'Dr. Kabir Danladi',
        phoneNumber: '08021112233',
        deliveryAddress: '14 Independence Way, Kaduna',
      ),
      quote: const ErrandQuoteDto(
        id: 'Q-004',
        errandType: ErrandType.buyItems,
        estimatedItemsCostKobo: 540000,
        serviceFeeKobo: 80000,
        deliveryFeeKobo: 100000,
        totalKobo: 720000,
      ),
      assignedRider: riderFatima,
      paymentMethod: PaymentMethod.wallet,
      paymentStatus: PaymentStatus.captured,
      createdAt: now.subtract(const Duration(hours: 3)),
      completedAt: now.subtract(const Duration(hours: 1)),
    );

    // Errand 5: Flow A - Disputed Errand (Items price difference exceedance)
    final errand5 = ErrandDto(
      id: 'ERRAND-005',
      referenceNumber: 'ERR-2026-0015',
      customerId: 'CUST-005',
      type: ErrandType.buyItems,
      status: ErrandStatus.issueReported,
      shop: const ShopDto(
        id: 'SHOP-03',
        name: 'De-West Stores',
        address: 'Agwa, Kaduna',
        latitude: 10.5210,
        longitude: 7.4230,
      ),
      items: const [
        ShoppingItemDto(
          id: 'ITEM-21',
          name: 'Cooking Oil (Kings 5L)',
          quantity: 1,
          unit: 'bottle',
          estimatedPriceKobo: 950000,
          isPurchased: true,
          actualPriceKobo: 1250000,
        ),
      ],
      preferences: const ShoppingPreferencesDto(
        substitutionPolicy: SubstitutionPolicy.doNotSubstitute,
        additionalInstructions: 'Only buy Kings brand, no other oil.',
      ),
      deliveryLocation: const LocationDto(
        latitude: 10.5300,
        longitude: 7.4290,
        address: 'Plot 4, Constitution Road, Kaduna',
      ),
      recipient: const RecipientDetailsDto(
        fullName: 'Grace Eze',
        phoneNumber: '08059998877',
        deliveryAddress: 'Plot 4, Constitution Road, Kaduna',
      ),
      quote: const ErrandQuoteDto(
        id: 'Q-005',
        errandType: ErrandType.buyItems,
        estimatedItemsCostKobo: 950000,
        serviceFeeKobo: 80000,
        deliveryFeeKobo: 110000,
        totalKobo: 1140000,
      ),
      assignedRider: riderAhmed,
      paymentMethod: PaymentMethod.wallet,
      paymentStatus: PaymentStatus.captured,
      createdAt: now.subtract(const Duration(hours: 5)),
    );

    // Seed Reconciliations
    final reconciliations = [
      ErrandReconciliationModel(
        id: 'REC-001',
        errandId: 'ERRAND-004',
        referenceNumber: 'ERR-2026-0018',
        customerId: 'CUST-004',
        customerName: 'Dr. Kabir Danladi',
        shopperName: 'Fatima Abubakar',
        shopName: 'Murtala Supermarket',
        budgetedKobo: 540000,
        actualKobo: 510000,
        differenceKobo: -30000, // ₦300 refund to customer
        type: 'REFUND_CUSTOMER',
        status: 'PENDING',
        createdAt: now.subtract(const Duration(hours: 1)),
      ),
      ErrandReconciliationModel(
        id: 'REC-002',
        errandId: 'ERRAND-005',
        referenceNumber: 'ERR-2026-0015',
        customerId: 'CUST-005',
        customerName: 'Grace Eze',
        shopperName: 'Ahmed Ibrahim',
        shopName: 'De-West Stores',
        budgetedKobo: 950000,
        actualKobo: 1250000,
        differenceKobo: 300000, // ₦3,000 extra charge disputed
        type: 'CHARGE_CUSTOMER',
        status: 'PENDING',
        createdAt: now.subtract(const Duration(hours: 4)),
      ),
      // High value reconciliation (> ₦10,000 / 1,000,000 kobo) requiring Maker-Checker dual signoff
      ErrandReconciliationModel(
        id: 'REC-003',
        errandId: 'ERRAND-006',
        referenceNumber: 'ERR-2026-0010',
        customerId: 'CUST-006',
        customerName: 'Chief Emmanuel Okon',
        shopperName: 'Musa Bello',
        shopName: 'Kano Wholesale Grain Depot',
        budgetedKobo: 4500000,
        actualKobo: 3200000,
        differenceKobo: -1300000, // ₦13,000 refund -> requires Maker-Checker!
        type: 'REFUND_CUSTOMER',
        status: 'MAKER_APPROVED',
        makerStaffName: 'Ops Agent Tunde',
        makerNotes: 'Wholesale price discount verified with paper receipt photo.',
        createdAt: now.subtract(const Duration(hours: 6)),
      ),
    ];

    // Seed Disputes
    final disputes = [
      const ErrandDisputeModel(
        id: 'DISP-001',
        errandId: 'ERRAND-005',
        referenceNumber: 'ERR-2026-0015',
        customerName: 'Grace Eze',
        customerPhone: '0805 999 8877',
        shopperName: 'Ahmed Ibrahim',
        shopperPhone: '+2348031234567',
        shopName: 'De-West Stores',
        disputeReason: 'Shopper purchased higher priced oil without contacting me first.',
        customerNote: 'My preference was strictly "Do not substitute". I budgeted ₦9,500 and the receipt is ₦12,500.',
        budgetedAmountKobo: 950000,
        actualReceiptKobo: 1250000,
        differenceKobo: 300000,
        status: 'PENDING_REVIEW',
      ),
    ];

    state = state.copyWith(
      errands: [errand1, errand2, errand3, errand4, errand5],
      reconciliations: reconciliations,
      disputes: disputes,
    );
  }

  void search(String query) {
    state = state.copyWith(searchQuery: query.trim());
  }

  void filterByType(ErrandType? type) {
    if (type == null) {
      state = state.copyWith(clearSelectedType: true);
    } else {
      state = state.copyWith(selectedType: type);
    }
  }

  void filterByStatus(ErrandStatus? status) {
    if (status == null) {
      state = state.copyWith(clearSelectedStatus: true);
    } else {
      state = state.copyWith(selectedStatus: status);
    }
  }

  /// Reassigns a shopper/rider to the specified errand.
  Future<bool> reassignShopper(
    String errandId,
    RiderDto newShopper, {
    required String reason,
  }) async {
    final updatedErrands = state.errands.map((e) {
      if (e.id == errandId) {
        return e.copyWith(
          assignedRider: newShopper,
          status: ErrandStatus.agentAssigned,
        );
      }
      return e;
    }).toList();

    state = state.copyWith(
      errands: updatedErrands,
      actionMessage:
          'Shopper reassigned to ${newShopper.fullName} for order $errandId ($reason)',
    );
    return true;
  }

  /// Approves item substitution on a shopping list.
  Future<bool> approveItemSubstitution(
    String errandId,
    String itemId,
    int adjustedPriceKobo, {
    required String approverName,
  }) async {
    final updatedErrands = state.errands.map((e) {
      if (e.id == errandId) {
        final updatedItems = e.items.map((item) {
          if (item.id == itemId) {
            return item.copyWith(
              isPurchased: true,
              actualPriceKobo: adjustedPriceKobo,
            );
          }
          return item;
        }).toList();

        return e.copyWith(items: updatedItems);
      }
      return e;
    }).toList();

    state = state.copyWith(
      errands: updatedErrands,
      actionMessage:
          'Substitution approved for item $itemId by $approverName (Adjusted: ₦${(adjustedPriceKobo / 100).toStringAsFixed(0)})',
    );
    return true;
  }

  /// Approves price reconciliation, enforcing Maker-Checker if diff > ₦10,000 (§5.1).
  Future<bool> approveReconciliation(
    String reconciliationId, {
    required String staffName,
    required StaffRole staffRole,
  }) async {
    final rec = state.reconciliations.firstWhere((r) => r.id == reconciliationId);

    if (rec.needsDualApproval) {
      // Maker stage
      if (rec.status == 'PENDING') {
        final updatedRecs = state.reconciliations.map((r) {
          if (r.id == reconciliationId) {
            return r.copyWith(
              status: 'MAKER_APPROVED',
              makerStaffName: staffName,
              makerNotes: 'Maker sign-off granted by $staffName (${staffRole.label})',
            );
          }
          return r;
        }).toList();

        state = state.copyWith(
          reconciliations: updatedRecs,
          actionMessage:
              'Maker approval granted for ${rec.referenceNumber}. Awaiting Checker sign-off (Difference > ₦10,000).',
        );
        return true;
      }

      // Checker stage: Requires Finance Officer, Super Admin, or Operations Admin
      final canCheck = staffRole == StaffRole.finance ||
          staffRole == StaffRole.superAdmin ||
          staffRole == StaffRole.admin;

      if (!canCheck) {
        state = state.copyWith(
          actionMessage:
              'Error: Dual-approval checker requires Finance Officer or Super Admin role.',
        );
        return false;
      }

      final updatedRecs = state.reconciliations.map((r) {
        if (r.id == reconciliationId) {
          return r.copyWith(
            status: 'CHECKER_APPROVED',
            checkerStaffName: staffName,
            approvedAt: DateTime.now(),
          );
        }
        return r;
      }).toList();

      state = state.copyWith(
        reconciliations: updatedRecs,
        actionMessage:
            'Checker approved! Refund/Adjustment of ₦${rec.differenceNgn.toStringAsFixed(0)} processed to customer wallet.',
      );
      return true;
    } else {
      // Direct single approval for adjustments <= ₦10,000
      final updatedRecs = state.reconciliations.map((r) {
        if (r.id == reconciliationId) {
          return r.copyWith(
            status: 'CHECKER_APPROVED',
            makerStaffName: staffName,
            checkerStaffName: staffName,
            approvedAt: DateTime.now(),
          );
        }
        return r;
      }).toList();

      state = state.copyWith(
        reconciliations: updatedRecs,
        actionMessage:
            'Reconciliation approved by $staffName: ₦${rec.differenceNgn.toStringAsFixed(0)} successfully settled.',
      );
      return true;
    }
  }

  /// Resolves an errand dispute with optional wallet refund.
  Future<bool> resolveDispute(
    String disputeId, {
    required bool refundCustomer,
    required int refundAmountKobo,
    required String resolutionNotes,
    required String staffName,
  }) async {
    final updatedDisputes = state.disputes.map((d) {
      if (d.id == disputeId) {
        return d.copyWith(
          status: refundCustomer ? 'RESOLVED_REFUND' : 'REJECTED',
          resolutionNotes: resolutionNotes,
          resolvedBy: staffName,
          resolvedAt: DateTime.now(),
        );
      }
      return d;
    }).toList();

    state = state.copyWith(
      disputes: updatedDisputes,
      actionMessage: refundCustomer
          ? 'Dispute $disputeId resolved: ₦${(refundAmountKobo / 100).toStringAsFixed(0)} refunded to customer by $staffName.'
          : 'Dispute $disputeId rejected by $staffName ($resolutionNotes).',
    );
    return true;
  }

  /// Updates status of an errand (e.g. Delivered, Completed, Cancelled).
  Future<bool> updateErrandStatus(
    String errandId,
    ErrandStatus newStatus, {
    String? notes,
  }) async {
    final updatedErrands = state.errands.map((e) {
      if (e.id == errandId) {
        return e.copyWith(
          status: newStatus,
          completedAt: newStatus == ErrandStatus.completed ? DateTime.now() : e.completedAt,
        );
      }
      return e;
    }).toList();

    state = state.copyWith(
      errands: updatedErrands,
      actionMessage: 'Errand $errandId status updated to ${newStatus.label}.',
    );
    return true;
  }
}

final errandOperationsNotifierProvider =
    StateNotifierProvider<ErrandOperationsNotifier, ErrandOperationsState>((ref) {
  return ErrandOperationsNotifier();
});
