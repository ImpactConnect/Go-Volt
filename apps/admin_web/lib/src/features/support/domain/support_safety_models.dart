import 'package:equatable/equatable.dart';

enum TicketPriority { normal, high, urgent }

enum TicketStatus { open, inProgress, resolved }

class SupportTicketModel extends Equatable {
  const SupportTicketModel({
    required this.id,
    required this.ticketRef,
    required this.customerName,
    required this.riderName,
    required this.category,
    required this.priority,
    required this.status,
    required this.subject,
    required this.description,
    required this.createdAt,
    this.assignedAgentId,
  });

  final String id;
  final String ticketRef;
  final String customerName;
  final String riderName;
  final String category; // 'Lost Item', 'Fare Dispute', 'App Bug', 'General'
  final TicketPriority priority;
  final TicketStatus status;
  final String subject;
  final String description;
  final DateTime createdAt;
  final String? assignedAgentId;

  SupportTicketModel copyWith({
    String? id,
    String? ticketRef,
    String? customerName,
    String? riderName,
    String? category,
    TicketPriority? priority,
    TicketStatus? status,
    String? subject,
    String? description,
    DateTime? createdAt,
    String? assignedAgentId,
  }) {
    return SupportTicketModel(
      id: id ?? this.id,
      ticketRef: ticketRef ?? this.ticketRef,
      customerName: customerName ?? this.customerName,
      riderName: riderName ?? this.riderName,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      assignedAgentId: assignedAgentId ?? this.assignedAgentId,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ticketRef,
        customerName,
        riderName,
        category,
        priority,
        status,
        subject,
        description,
        createdAt,
        assignedAgentId,
      ];
}

enum SafetyIncidentSeverity { critical, high, medium }

enum SafetyIncidentStatus { investigating, escalatedAuthorities, resolved }

class SafetyIncidentModel extends Equatable {
  const SafetyIncidentModel({
    required this.id,
    required this.incidentRef,
    required this.bookingRef,
    required this.incidentType,
    required this.severity,
    required this.status,
    required this.partiesInvolved,
    required this.locationNarrative,
    required this.description,
    required this.reportedAt,
    required this.investigationNotes,
    this.lawEnforcementReportRef,
    this.resolvedAt,
  });

  final String id;
  final String incidentRef;
  final String bookingRef;
  final String incidentType; // 'Child Safeguarding Escort Deviation', 'Severe Crash / Injury', 'Battery Thermal Runaway', 'Harassment'
  final SafetyIncidentSeverity severity;
  final SafetyIncidentStatus status;
  final String partiesInvolved;
  final String locationNarrative;
  final String description;
  final DateTime reportedAt;
  final List<String> investigationNotes;
  final String? lawEnforcementReportRef;
  final DateTime? resolvedAt;

  SafetyIncidentModel copyWith({
    String? id,
    String? incidentRef,
    String? bookingRef,
    String? incidentType,
    SafetyIncidentSeverity? severity,
    SafetyIncidentStatus? status,
    String? partiesInvolved,
    String? locationNarrative,
    String? description,
    DateTime? reportedAt,
    List<String>? investigationNotes,
    String? lawEnforcementReportRef,
    DateTime? resolvedAt,
  }) {
    return SafetyIncidentModel(
      id: id ?? this.id,
      incidentRef: incidentRef ?? this.incidentRef,
      bookingRef: bookingRef ?? this.bookingRef,
      incidentType: incidentType ?? this.incidentType,
      severity: severity ?? this.severity,
      status: status ?? this.status,
      partiesInvolved: partiesInvolved ?? this.partiesInvolved,
      locationNarrative: locationNarrative ?? this.locationNarrative,
      description: description ?? this.description,
      reportedAt: reportedAt ?? this.reportedAt,
      investigationNotes: investigationNotes ?? this.investigationNotes,
      lawEnforcementReportRef: lawEnforcementReportRef ?? this.lawEnforcementReportRef,
      resolvedAt: resolvedAt ?? this.resolvedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        incidentRef,
        bookingRef,
        incidentType,
        severity,
        status,
        partiesInvolved,
        locationNarrative,
        description,
        reportedAt,
        investigationNotes,
        lawEnforcementReportRef,
        resolvedAt,
      ];
}
