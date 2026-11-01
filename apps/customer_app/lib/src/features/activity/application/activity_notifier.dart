import 'package:app_models/app_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../errand/application/active_errand_provider.dart';
import '../domain/activity_item.dart';
import '../domain/activity_state.dart';

final activityNotifierProvider =
    StateNotifierProvider<ActivityNotifier, ActivityState>((ref) {
  final notifier = ActivityNotifier(initialItems: const []);

  ref.listen<ErrandDto?>(activeErrandProvider, (prev, next) {
    if (next != null) {
      notifier.addOrUpdateErrand(next);
    }
  });

  return notifier;
});

class ActivityNotifier extends StateNotifier<ActivityState> {
  ActivityNotifier({List<ActivityItem>? initialItems})
      : super(
          ActivityState(
            items: initialItems ?? const [],
            selectedStatus: ActivityStatus.upcoming,
          ),
        );

  void setStatusFilter(ActivityStatus status) {
    state = state.copyWith(selectedStatus: status);
  }

  void setServiceFilter(ActivityServiceType? service) {
    if (service == null) {
      state = state.copyWith(clearServiceFilter: true);
    } else {
      state = state.copyWith(selectedService: service);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void refresh() {
    state = state.copyWith(isLoading: true);
    Future.delayed(const Duration(milliseconds: 300), () {
      state = state.copyWith(isLoading: false);
    });
  }

  void addOrUpdateErrand(ErrandDto errand) {
    final newItem = ActivityItem.fromErrand(errand);
    final existingIndex = state.items.indexWhere(
      (i) => i.id == errand.id || i.reference == errand.referenceNumber,
    );
    if (existingIndex >= 0) {
      final updated = List<ActivityItem>.from(state.items);
      updated[existingIndex] = newItem;
      state = state.copyWith(items: updated);
    } else {
      state = state.copyWith(items: [newItem, ...state.items]);
    }
  }
}
