import 'package:equatable/equatable.dart';

/// Authoritative support ticket lifecycle status (§D5).
enum TicketStatus {
  submitted('SUBMITTED', 'Submitted'),
  underReview('UNDER_REVIEW', 'Under Review'),
  inProgress('IN_PROGRESS', 'In Progress'),
  resolved('RESOLVED', 'Resolved'),
  closed('CLOSED', 'Closed');

  const TicketStatus(this.code, this.label);

  final String code;
  final String label;

  static TicketStatus fromString(String raw) {
    return TicketStatus.values.firstWhere(
      (s) => s.code == raw.toUpperCase() || s.name == raw,
      orElse: () => TicketStatus.submitted,
    );
  }
}

/// Message exchange within a customer support ticket.
class SupportTicketMessageDto extends Equatable {
  const SupportTicketMessageDto({
    required this.id,
    required this.ticketId,
    required this.senderId,
    required this.senderName,
    required this.senderRole, // 'customer' or 'agent'
    required this.message,
    required this.createdAt,
    this.attachmentUrl,
  });

  factory SupportTicketMessageDto.fromJson(Map<String, dynamic> json) {
    return SupportTicketMessageDto(
      id: json['id'] as String,
      ticketId: json['ticket_id'] as String? ?? '',
      senderId: json['sender_id'] as String? ?? '',
      senderName: json['sender_name'] as String? ?? 'Support Agent',
      senderRole: json['sender_role'] as String? ?? 'agent',
      message: json['message'] as String? ?? '',
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      attachmentUrl: json['attachment_url'] as String?,
    );
  }

  final String id;
  final String ticketId;
  final String senderId;
  final String senderName;
  final String senderRole;
  final String message;
  final DateTime createdAt;
  final String? attachmentUrl;

  bool get isCustomer => senderRole == 'customer';

  Map<String, dynamic> toJson() => {
        'id': id,
        'ticket_id': ticketId,
        'sender_id': senderId,
        'sender_name': senderName,
        'sender_role': senderRole,
        'message': message,
        'created_at': createdAt.toIso8601String(),
        if (attachmentUrl != null) 'attachment_url': attachmentUrl,
      };

  @override
  List<Object?> get props => [id, ticketId, senderId, senderName, senderRole, message, createdAt, attachmentUrl];
}

/// Authoritative Go-Volts customer support ticket (§D4, §D5).
class SupportTicketDto extends Equatable {
  const SupportTicketDto({
    required this.id,
    required this.ticketNumber,
    required this.serviceCategory, // 'ride', 'parcel', 'errand', 'scheduled', 'wallet', 'account', 'safety'
    required this.issueType,
    required this.subject,
    required this.description,
    this.relatedEntityId,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.messages = const [],
    this.resolutionNotes,
    this.userId,
  });

  factory SupportTicketDto.fromJson(Map<String, dynamic> json) {
    final rawMessages = json['messages'] as List<dynamic>? ?? [];
    return SupportTicketDto(
      id: json['id'] as String,
      ticketNumber: json['ticket_number'] as String? ?? 'TKT-00000',
      serviceCategory: json['service_category'] as String? ?? 'general',
      issueType: json['issue_type'] as String? ?? 'General Inquiry',
      subject: json['subject'] as String? ?? '',
      description: json['description'] as String? ?? '',
      relatedEntityId: json['related_entity_id'] as String?,
      status: TicketStatus.fromString(json['status'] as String? ?? 'SUBMITTED'),
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ?? DateTime.now(),
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
      messages: rawMessages.map((m) => SupportTicketMessageDto.fromJson(m as Map<String, dynamic>)).toList(),
      resolutionNotes: json['resolution_notes'] as String?,
      userId: json['user_id'] as String?,
    );
  }

  final String id;
  final String ticketNumber;
  final String serviceCategory;
  final String issueType;
  final String subject;
  final String description;
  final String? relatedEntityId;
  final TicketStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<SupportTicketMessageDto> messages;
  final String? resolutionNotes;
  final String? userId;

  bool get isResolved => status == TicketStatus.resolved || status == TicketStatus.closed;
  bool get isOpen => !isResolved;

  SupportTicketDto copyWith({
    String? id,
    String? ticketNumber,
    String? serviceCategory,
    String? issueType,
    String? subject,
    String? description,
    String? relatedEntityId,
    TicketStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<SupportTicketMessageDto>? messages,
    String? resolutionNotes,
    String? userId,
  }) {
    return SupportTicketDto(
      id: id ?? this.id,
      ticketNumber: ticketNumber ?? this.ticketNumber,
      serviceCategory: serviceCategory ?? this.serviceCategory,
      issueType: issueType ?? this.issueType,
      subject: subject ?? this.subject,
      description: description ?? this.description,
      relatedEntityId: relatedEntityId ?? this.relatedEntityId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      messages: messages ?? this.messages,
      resolutionNotes: resolutionNotes ?? this.resolutionNotes,
      userId: userId ?? this.userId,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'ticket_number': ticketNumber,
        'service_category': serviceCategory,
        'issue_type': issueType,
        'subject': subject,
        'description': description,
        if (relatedEntityId != null) 'related_entity_id': relatedEntityId,
        'status': status.code,
        'created_at': createdAt.toIso8601String(),
        if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
        'messages': messages.map((m) => m.toJson()).toList(),
        if (resolutionNotes != null) 'resolution_notes': resolutionNotes,
        if (userId != null) 'user_id': userId,
      };

  @override
  List<Object?> get props => [
        id,
        ticketNumber,
        serviceCategory,
        issueType,
        subject,
        description,
        relatedEntityId,
        status,
        createdAt,
        updatedAt,
        messages,
        resolutionNotes,
        userId,
      ];
}

