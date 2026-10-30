import 'package:app_models/app_models.dart';
import 'package:equatable/equatable.dart';

class DeliveryTimelineEvent extends Equatable {
  const DeliveryTimelineEvent({
    required this.status,
    required this.timestamp,
    required this.note,
  });

  final String status;
  final String timestamp;
  final String note;

  @override
  List<Object?> get props => [status, timestamp, note];
}

class MerchantDeliveryBooking extends Equatable {
  const MerchantDeliveryBooking({
    required this.id,
    required this.trackingReference,
    required this.branchId,
    required this.branchName,
    required this.recipientName,
    required this.recipientPhone,
    required this.deliveryAddress,
    required this.deliveryZone,
    required this.packageCategory,
    required this.weightKg,
    this.isFragile = false,
    this.specialInstructions = '',
    required this.grossFareKobo,
    required this.status,
    this.assignedRiderName,
    this.assignedRiderPhone,
    this.assignedRiderPlate,
    this.assignedRiderBattery,
    required this.recipientOtp,
    this.proofOfDeliveryUrl,
    required this.createdAt,
    required this.timeline,
  });

  final String id;
  final String trackingReference;
  final String branchId;
  final String branchName;
  final String recipientName;
  final String recipientPhone;
  final String deliveryAddress;
  final String deliveryZone;
  final String packageCategory;
  final double weightKg;
  final bool isFragile;
  final String specialInstructions;
  final int grossFareKobo;
  final BookingStatus status;
  final String? assignedRiderName;
  final String? assignedRiderPhone;
  final String? assignedRiderPlate;
  final int? assignedRiderBattery;
  final String recipientOtp;
  final String? proofOfDeliveryUrl;
  final DateTime createdAt;
  final List<DeliveryTimelineEvent> timeline;

  String get formattedFare {
    final naira = grossFareKobo / 100.0;
    return '₦${naira.toStringAsFixed(2).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  int? get assignedRiderBatterySoc => assignedRiderBattery;

  bool get canBeCancelled =>
      status == BookingStatus.draft ||
      status == BookingStatus.pending ||
      status == BookingStatus.searchingRider;

  MerchantDeliveryBooking copyWith({
    String? id,
    String? trackingReference,
    String? branchId,
    String? branchName,
    String? recipientName,
    String? recipientPhone,
    String? deliveryAddress,
    String? deliveryZone,
    String? packageCategory,
    double? weightKg,
    bool? isFragile,
    String? specialInstructions,
    int? grossFareKobo,
    BookingStatus? status,
    String? assignedRiderName,
    String? assignedRiderPhone,
    String? assignedRiderPlate,
    int? assignedRiderBattery,
    String? recipientOtp,
    String? proofOfDeliveryUrl,
    DateTime? createdAt,
    List<DeliveryTimelineEvent>? timeline,
  }) {
    return MerchantDeliveryBooking(
      id: id ?? this.id,
      trackingReference: trackingReference ?? this.trackingReference,
      branchId: branchId ?? this.branchId,
      branchName: branchName ?? this.branchName,
      recipientName: recipientName ?? this.recipientName,
      recipientPhone: recipientPhone ?? this.recipientPhone,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      deliveryZone: deliveryZone ?? this.deliveryZone,
      packageCategory: packageCategory ?? this.packageCategory,
      weightKg: weightKg ?? this.weightKg,
      isFragile: isFragile ?? this.isFragile,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      grossFareKobo: grossFareKobo ?? this.grossFareKobo,
      status: status ?? this.status,
      assignedRiderName: assignedRiderName ?? this.assignedRiderName,
      assignedRiderPhone: assignedRiderPhone ?? this.assignedRiderPhone,
      assignedRiderPlate: assignedRiderPlate ?? this.assignedRiderPlate,
      assignedRiderBattery: assignedRiderBattery ?? this.assignedRiderBattery,
      recipientOtp: recipientOtp ?? this.recipientOtp,
      proofOfDeliveryUrl: proofOfDeliveryUrl ?? this.proofOfDeliveryUrl,
      createdAt: createdAt ?? this.createdAt,
      timeline: timeline ?? this.timeline,
    );
  }

  @override
  List<Object?> get props => [
        id,
        trackingReference,
        branchId,
        branchName,
        recipientName,
        recipientPhone,
        deliveryAddress,
        deliveryZone,
        packageCategory,
        weightKg,
        isFragile,
        specialInstructions,
        grossFareKobo,
        status,
        assignedRiderName,
        assignedRiderPhone,
        assignedRiderPlate,
        assignedRiderBattery,
        recipientOtp,
        proofOfDeliveryUrl,
        createdAt,
        timeline,
      ];
}
