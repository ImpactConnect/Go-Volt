import 'package:equatable/equatable.dart';
import 'activity_item.dart';

class ActivityState extends Equatable {
  const ActivityState({
    this.items = const [],
    this.selectedService,
    this.selectedStatus = ActivityStatus.upcoming,
    this.searchQuery = '',
    this.isLoading = false,
  });

  final List<ActivityItem> items;
  final ActivityServiceType? selectedService;
  final ActivityStatus selectedStatus;
  final String searchQuery;
  final bool isLoading;

  List<ActivityItem> get filteredItems {
    return items.where((item) {
      if (item.status != selectedStatus) return false;
      if (selectedService != null && item.serviceType != selectedService) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final match = item.title.toLowerCase().contains(query) ||
            item.pickupAddress.toLowerCase().contains(query) ||
            item.dropoffAddress.toLowerCase().contains(query) ||
            item.reference.toLowerCase().contains(query) ||
            (item.driverName?.toLowerCase().contains(query) ?? false) ||
            (item.recipientName?.toLowerCase().contains(query) ?? false);
        if (!match) return false;
      }
      return true;
    }).toList();
  }

  int get activeCount =>
      items.where((i) => i.status == ActivityStatus.active).length;
  int get upcomingCount =>
      items.where((i) => i.status == ActivityStatus.upcoming).length;
  int get completedCount =>
      items.where((i) => i.status == ActivityStatus.completed).length;
  int get cancelledCount =>
      items.where((i) => i.status == ActivityStatus.cancelled).length;

  ActivityState copyWith({
    List<ActivityItem>? items,
    ActivityServiceType? selectedService,
    bool clearServiceFilter = false,
    ActivityStatus? selectedStatus,
    String? searchQuery,
    bool? isLoading,
  }) {
    return ActivityState(
      items: items ?? this.items,
      selectedService: clearServiceFilter
          ? null
          : (selectedService ?? this.selectedService),
      selectedStatus: selectedStatus ?? this.selectedStatus,
      searchQuery: searchQuery ?? this.searchQuery,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [
        items,
        selectedService,
        selectedStatus,
        searchQuery,
        isLoading,
      ];
}
