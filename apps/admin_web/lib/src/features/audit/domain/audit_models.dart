import 'package:equatable/equatable.dart';

enum AuditCategory {
  dispatchOverride,
  pricingTariff,
  makerCheckerRefund,
  riderCompliance,
  promotions,
  securityRbac,
}

class AuditLogEntry extends Equatable {
  const AuditLogEntry({
    required this.id,
    required this.timestamp,
    required this.actorId,
    required this.actorName,
    required this.actorRole,
    required this.category,
    required this.action,
    required this.entityType,
    required this.entityId,
    required this.previousStateJson,
    required this.newStateJson,
    required this.ipAddress,
    required this.cryptographicHash,
  });

  final String id;
  final DateTime timestamp;
  final String actorId;
  final String actorName;
  final String actorRole;
  final AuditCategory category;
  final String action;
  final String entityType;
  final String entityId;
  final String previousStateJson;
  final String newStateJson;
  final String ipAddress;
  final String cryptographicHash;

  @override
  List<Object?> get props => [
        id,
        timestamp,
        actorId,
        actorName,
        actorRole,
        category,
        action,
        entityType,
        entityId,
        previousStateJson,
        newStateJson,
        ipAddress,
        cryptographicHash,
      ];
}
