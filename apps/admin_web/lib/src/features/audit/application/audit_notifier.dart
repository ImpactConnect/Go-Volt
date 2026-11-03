import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/audit_models.dart';

class AuditState extends Equatable {
  const AuditState({
    required this.logs,
    this.selectedCategory,
    this.searchQuery = '',
  });

  final List<AuditLogEntry> logs;
  final AuditCategory? selectedCategory;
  final String searchQuery;

  List<AuditLogEntry> get filteredLogs {
    return logs.where((log) {
      if (selectedCategory != null && log.category != selectedCategory) {
        return false;
      }
      if (searchQuery.isNotEmpty) {
        final query = searchQuery.toLowerCase();
        final matchesEntity = log.entityId.toLowerCase().contains(query);
        final matchesAction = log.action.toLowerCase().contains(query);
        final matchesActor = log.actorName.toLowerCase().contains(query);
        if (!matchesEntity && !matchesAction && !matchesActor) return false;
      }
      return true;
    }).toList();
  }

  AuditState copyWith({
    List<AuditLogEntry>? logs,
    AuditCategory? selectedCategory,
    bool clearCategory = false,
    String? searchQuery,
  }) {
    return AuditState(
      logs: logs ?? this.logs,
      selectedCategory: clearCategory ? null : (selectedCategory ?? this.selectedCategory),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  @override
  List<Object?> get props => [logs, selectedCategory, searchQuery];
}

class AuditNotifier extends StateNotifier<AuditState> {
  AuditNotifier()
      : super(
          const AuditState(
            logs: [],
          ),
        );

    @visibleForTesting
  void updateStateForTesting(AuditState newState) {
    state = newState;
  }

  void setCategory(AuditCategory? category) {
    if (category == null || state.selectedCategory == category) {
      state = state.copyWith(clearCategory: true);
    } else {
      state = state.copyWith(selectedCategory: category);
    }
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void appendAuditEntry(AuditLogEntry entry) {
    state = state.copyWith(logs: [entry, ...state.logs]);
  }
}

final auditNotifierProvider =
    StateNotifierProvider<AuditNotifier, AuditState>((ref) {
  return AuditNotifier();
});
