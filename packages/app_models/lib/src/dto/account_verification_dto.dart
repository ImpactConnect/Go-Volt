import 'package:equatable/equatable.dart';

/// Account identity verification states (§A4).
enum VerificationStatus {
  notRequired('NOT_REQUIRED', 'Not Required'),
  pending('PENDING', 'Pending Verification'),
  verified('VERIFIED', 'Verified'),
  actionRequired('ACTION_REQUIRED', 'Action Required'),
  rejected('REJECTED', 'Verification Rejected');

  const VerificationStatus(this.code, this.label);

  final String code;
  final String label;

  static VerificationStatus fromString(String raw) {
    return VerificationStatus.values.firstWhere(
      (v) => v.code == raw.toUpperCase() || v.name == raw,
      orElse: () => VerificationStatus.notRequired,
    );
  }
}

/// Customer account verification status and submitted documents (§A4).
class AccountVerificationDto extends Equatable {
  const AccountVerificationDto({
    required this.status,
    this.tier = 'Tier 1 (Basic)',
    this.rejectionReason,
    this.submittedAt,
    this.verifiedAt,
    this.requiredDocuments = const ['Government Issued ID', 'Proof of Residential Address'],
    this.documentUrls = const {},
  });

  factory AccountVerificationDto.fromJson(Map<String, dynamic> json) {
    final docs = (json['required_documents'] as List<dynamic>?)?.map((e) => e.toString()).toList() ??
        const ['Government Issued ID', 'Proof of Residential Address'];
    final urls = (json['document_urls'] as Map<String, dynamic>?)?.map((k, v) => MapEntry(k, v.toString())) ??
        const <String, String>{};

    return AccountVerificationDto(
      status: VerificationStatus.fromString(json['status'] as String? ?? 'NOT_REQUIRED'),
      tier: json['tier'] as String? ?? 'Tier 1 (Basic)',
      rejectionReason: json['rejection_reason'] as String?,
      submittedAt: json['submitted_at'] != null ? DateTime.tryParse(json['submitted_at'] as String) : null,
      verifiedAt: json['verified_at'] != null ? DateTime.tryParse(json['verified_at'] as String) : null,
      requiredDocuments: docs,
      documentUrls: urls,
    );
  }

  final VerificationStatus status;
  final String tier;
  final String? rejectionReason;
  final DateTime? submittedAt;
  final DateTime? verifiedAt;
  final List<String> requiredDocuments;
  final Map<String, String> documentUrls;

  bool get isVerified => status == VerificationStatus.verified;
  bool get isPending => status == VerificationStatus.pending;
  bool get needsAction => status == VerificationStatus.actionRequired || status == VerificationStatus.rejected;

  AccountVerificationDto copyWith({
    VerificationStatus? status,
    String? tier,
    String? rejectionReason,
    DateTime? submittedAt,
    DateTime? verifiedAt,
    List<String>? requiredDocuments,
    Map<String, String>? documentUrls,
  }) {
    return AccountVerificationDto(
      status: status ?? this.status,
      tier: tier ?? this.tier,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      submittedAt: submittedAt ?? this.submittedAt,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      requiredDocuments: requiredDocuments ?? this.requiredDocuments,
      documentUrls: documentUrls ?? this.documentUrls,
    );
  }

  Map<String, dynamic> toJson() => {
        'status': status.code,
        'tier': tier,
        if (rejectionReason != null) 'rejection_reason': rejectionReason,
        if (submittedAt != null) 'submitted_at': submittedAt!.toIso8601String(),
        if (verifiedAt != null) 'verified_at': verifiedAt!.toIso8601String(),
        'required_documents': requiredDocuments,
        'document_urls': documentUrls,
      };

  @override
  List<Object?> get props => [status, tier, rejectionReason, submittedAt, verifiedAt, requiredDocuments, documentUrls];
}

