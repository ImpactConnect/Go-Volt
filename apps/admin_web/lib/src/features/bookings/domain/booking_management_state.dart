import 'package:app_models/app_models.dart';

class AdminBookingTimelineEvent {
  const AdminBookingTimelineEvent({
    required this.status,
    required this.timestamp,
    required this.note,
  });

  final String status;
  final String timestamp;
  final String note;
}

class AdminBookingItem {
  const AdminBookingItem({
    required this.id,
    required this.reference,
    required this.source,
    required this.customerName,
    required this.customerPhone,
    this.riderName,
    this.riderPhone,
    this.riderPlate,
    required this.serviceType,
    required this.status,
    required this.pickupAddress,
    required this.dropoffAddress,
    required this.grossFareKobo,
    required this.platformCommissionKobo,
    required this.createdAt,
    this.scheduledFor,
    required this.timeline,
  });

  final String id;
  final String reference;
  final String source; // 'Customer Mobile App', 'Retail Ai Partner', 'Merchant Portal'
  final String customerName;
  final String customerPhone;
  final String? riderName;
  final String? riderPhone;
  final String? riderPlate;
  final ServiceTierEligibility serviceType;
  final BookingStatus status;
  final String pickupAddress;
  final String dropoffAddress;
  final int grossFareKobo;
  final int platformCommissionKobo;
  final String createdAt;
  final String? scheduledFor;
  final List<AdminBookingTimelineEvent> timeline;

  double get grossFareNaira => grossFareKobo / 100.0;
  double get commissionNaira => platformCommissionKobo / 100.0;
  double get riderTakeHomeNaira => (grossFareKobo - platformCommissionKobo) / 100.0;
}

class BookingManagementState {
  const BookingManagementState({
    this.bookings = const [],
    this.selectedStatusFilter = 'ALL',
    this.selectedServiceFilter = 'ALL',
    this.searchQuery = '',
    this.selectedBooking,
    this.isLoading = false,
    this.actionMessage,
  });

  final List<AdminBookingItem> bookings;
  final String selectedStatusFilter;
  final String selectedServiceFilter;
  final String searchQuery;
  final AdminBookingItem? selectedBooking;
  final bool isLoading;
  final String? actionMessage;

  List<AdminBookingItem> get filteredBookings {
    return bookings.where((b) {
      if (selectedStatusFilter.toUpperCase() != 'ALL' && b.status.name.toLowerCase() != selectedStatusFilter.toLowerCase()) {
        return false;
      }
      if (selectedServiceFilter.toUpperCase() != 'ALL') {
        final filter = selectedServiceFilter.toLowerCase().replaceAll(RegExp(r'[\s\-_]'), '');
        final tier = b.serviceType.name.toLowerCase().replaceAll(RegExp(r'[\s\-_]'), '');
        if (!tier.contains(filter) && !filter.contains(tier)) {
          return false;
        }
      }
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        return b.reference.toLowerCase().contains(query) ||
            b.customerName.toLowerCase().contains(query) ||
            (b.riderName?.toLowerCase().contains(query) ?? false) ||
            b.pickupAddress.toLowerCase().contains(query);
      }
      return true;
    }).toList();
  }

  BookingManagementState copyWith({
    List<AdminBookingItem>? bookings,
    String? selectedStatusFilter,
    String? selectedServiceFilter,
    String? searchQuery,
    AdminBookingItem? selectedBooking,
    bool? isLoading,
    String? actionMessage,
  }) {
    return BookingManagementState(
      bookings: bookings ?? this.bookings,
      selectedStatusFilter: selectedStatusFilter ?? this.selectedStatusFilter,
      selectedServiceFilter: selectedServiceFilter ?? this.selectedServiceFilter,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedBooking: selectedBooking ?? this.selectedBooking,
      isLoading: isLoading ?? this.isLoading,
      actionMessage: actionMessage ?? this.actionMessage,
    );
  }
}
