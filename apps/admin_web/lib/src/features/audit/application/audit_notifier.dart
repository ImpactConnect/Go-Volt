import 'package:equatable/equatable.dart';
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
          AuditState(
            logs: _seedLogs,
          ),
        );

  static final List<AuditLogEntry> _seedLogs = [
    AuditLogEntry(
      id: 'aud_001',
      timestamp: DateTime(2026, 10, 24, 15, 20),
      actorId: 'staff_ops_ade',
      actorName: 'Adeola Sowande',
      actorRole: 'Operations Agent',
      category: AuditCategory.dispatchOverride,
      action: 'Manual Rider Reassignment Override',
      entityType: 'Booking',
      entityId: 'GV-TRIP-1092',
      previousStateJson: '{"assignedRiderId": "rd_musa_02", "reason": null}',
      newStateJson: '{"assignedRiderId": "rd_tunde_01", "overrideReason": "Tire puncture on rd_musa_02"}',
      ipAddress: '102.89.23.44',
      cryptographicHash: 'SHA256:e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855',
    ),
    AuditLogEntry(
      id: 'aud_002',
      timestamp: DateTime(2026, 10, 24, 14, 10),
      actorId: 'staff_fin_olumide',
      actorName: 'Olumide Bakare',
      actorRole: 'Finance Officer',
      category: AuditCategory.makerCheckerRefund,
      action: 'Dual Sign-Off Approved for ₦15,000 Refund',
      entityType: 'RefundRequest',
      entityId: 'ref_req_101',
      previousStateJson: '{"status": "pendingCheckerSignoff", "makerId": "staff_ops_ade"}',
      newStateJson: '{"status": "approved", "checkerId": "staff_fin_olumide", "payoutMode": "wallet_credit"}',
      ipAddress: '102.89.23.49',
      cryptographicHash: 'SHA256:8f434346648f6b96df89dda901c5176b10a6d83961dd3c1ac88b59b2dc327aa4',
    ),
    AuditLogEntry(
      id: 'aud_003',
      timestamp: DateTime(2026, 10, 24, 11, 45),
      actorId: 'admin_sys',
      actorName: 'System Administrator',
      actorRole: 'Operations Admin',
      category: AuditCategory.pricingTariff,
      action: 'Published Versioned Tariff v2.1 (Commute)',
      entityType: 'PricingRule',
      entityId: 'pr_commute_v2_1',
      previousStateJson: '{"activeVersion": "v2.0", "baseFareKobo": 50000}',
      newStateJson: '{"activeVersion": "v2.1", "baseFareKobo": 60000, "pastQuotes": "immutable"}',
      ipAddress: '197.210.8.12',
      cryptographicHash: 'SHA256:5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8',
    ),
    AuditLogEntry(
      id: 'aud_004',
      timestamp: DateTime(2026, 10, 24, 9, 30),
      actorId: 'safety_officer_ade',
      actorName: 'Dr. Adeola Balogun',
      actorRole: 'Safety Officer',
      category: AuditCategory.riderCompliance,
      action: 'Approved School-Run Chaperone Vetting Certification',
      entityType: 'RiderCompliance',
      entityId: 'rd_emeka_01',
      previousStateJson: '{"schoolRunCertified": false, "ninVerified": true}',
      newStateJson: '{"schoolRunCertified": true, "policeClearanceId": "NPF-CLR-8812"}',
      ipAddress: '102.89.23.10',
      cryptographicHash: 'SHA256:4b227777d4dd1fc61c6f884f48641d02b4d121d3fd328cb08b5531fcacdabf8a',
    ),
  ];

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
