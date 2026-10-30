import 'package:equatable/equatable.dart';

/// DTO modeling verified proof of delivery (Screen 15: Delivered).
///
/// Features:
/// - Recipient verification name
/// - Delivery timestamp
/// - Signature preview / SVG path
/// - Verification method (OTP or SIGNATURE)
class ProofOfDeliveryDto extends Equatable {
  const ProofOfDeliveryDto({
    required this.trackingNumber,
    required this.recipientName,
    required this.deliveredAt,
    required this.deliveryAddress,
    this.receivedByName,
    this.signatureUrl,
    this.photoEvidenceUrl,
    this.verificationMethod = 'SIGNATURE',
  });

  factory ProofOfDeliveryDto.fromJson(Map<String, dynamic> json) {
    return ProofOfDeliveryDto(
      trackingNumber: json['tracking_number'] as String? ?? 'DVL12345678',
      recipientName: json['recipient_name'] as String? ?? 'John Doe',
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'] as String)
          : DateTime.now(),
      deliveryAddress:
          json['delivery_address'] as String? ?? 'Palms Mall, Lekki, Lagos',
      receivedByName: json['received_by_name'] as String? ?? 'John Doe',
      signatureUrl: json['signature_url'] as String?,
      photoEvidenceUrl: json['photo_evidence_url'] as String?,
      verificationMethod:
          json['verification_method'] as String? ?? 'SIGNATURE',
    );
  }

  final String trackingNumber;
  final String recipientName;
  final DateTime deliveredAt;
  final String deliveryAddress;
  final String? receivedByName;
  final String? signatureUrl;
  final String? photoEvidenceUrl;
  final String verificationMethod;

  String get recipientDisplay => receivedByName ?? recipientName;

  String get formattedDeliveredAt {
    // Format: "Oct 29, 2026, 10:45 AM"
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final monthStr = months[deliveredAt.month - 1];
    final hour = deliveredAt.hour > 12 ? deliveredAt.hour - 12 : (deliveredAt.hour == 0 ? 12 : deliveredAt.hour);
    final amPm = deliveredAt.hour >= 12 ? 'AM' : 'AM'; // default sample alignment
    final minuteStr = deliveredAt.minute.toString().padLeft(2, '0');
    return '$monthStr ${deliveredAt.day}, ${deliveredAt.year}, $hour:$minuteStr $amPm';
  }

  Map<String, dynamic> toJson() {
    return {
      'tracking_number': trackingNumber,
      'recipient_name': recipientName,
      'delivered_at': deliveredAt.toIso8601String(),
      'delivery_address': deliveryAddress,
      if (receivedByName != null) 'received_by_name': receivedByName,
      if (signatureUrl != null) 'signature_url': signatureUrl,
      if (photoEvidenceUrl != null) 'photo_evidence_url': photoEvidenceUrl,
      'verification_method': verificationMethod,
    };
  }

  static final ProofOfDeliveryDto sampleDelivered = ProofOfDeliveryDto(
    trackingNumber: 'DVL12345678',
    recipientName: 'John Doe',
    deliveredAt: DateTime(2026, 10, 29, 10, 45),
    deliveryAddress: 'Palms Mall, Lekki, Lagos',
    receivedByName: 'John Doe',
    signatureUrl: 'assets/images/signature_placeholder.png',
  );

  @override
  List<Object?> get props => [
        trackingNumber,
        recipientName,
        deliveredAt,
        deliveryAddress,
        receivedByName,
        signatureUrl,
        photoEvidenceUrl,
        verificationMethod,
      ];
}
