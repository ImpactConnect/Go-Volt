import 'package:equatable/equatable.dart';
import '../dto/location_dto.dart';
import '../dto/parcel_details_dto.dart';
import '../dto/recipient_details_dto.dart';
import '../dto/rider_dto.dart';
import '../enums/domain_enums.dart';
import 'custom_errand_details_dto.dart';
import 'errand_quote_dto.dart';
import 'errand_status.dart';
import 'errand_type.dart';
import 'package:app_models/src/errands/package_pickup_details_dto.dart';
import 'shop_dto.dart';
import 'shopping_item_dto.dart';
import 'shopping_preferences_dto.dart';

/// Central aggregate model for an Errand job across Flows A, B, and C (v1.6 §1975-2004).
class ErrandDto extends Equatable {
  const ErrandDto({
    required this.id,
    required this.referenceNumber,
    required this.customerId,
    required this.type,
    required this.status,
    this.shop,
    this.items = const [],
    this.preferences,
    this.pickupDetails,
    this.packageDetails,
    this.customErrandDetails,
    required this.deliveryLocation,
    required this.recipient,
    this.deliveryTimeStr = 'As soon as possible',
    this.deliveryNotes,
    required this.quote,
    this.paymentMethod = PaymentMethod.wallet,
    this.paymentStatus = PaymentStatus.pending,
    this.assignedRider,
    this.statusTimeline = const [],
    required this.createdAt,
    this.completedAt,
    this.cancellationReason,
    this.rating,
  });

  factory ErrandDto.fromJson(Map<String, dynamic> json) {
    return ErrandDto(
      id: json['id'] as String? ?? '',
      referenceNumber: json['reference_number'] as String? ?? '',
      customerId: json['customer_id'] as String? ?? '',
      type: ErrandType.fromString(json['type'] as String?),
      status: ErrandStatus.fromString(json['status'] as String?),
      shop: json['shop'] != null
          ? ShopDto.fromJson(json['shop'] as Map<String, dynamic>)
          : null,
      items: (json['items'] as List<dynamic>?)
              ?.map((i) => ShoppingItemDto.fromJson(i as Map<String, dynamic>))
              .toList() ??
          const [],
      preferences: json['preferences'] != null
          ? ShoppingPreferencesDto.fromJson(
              json['preferences'] as Map<String, dynamic>)
          : null,
      pickupDetails: json['pickup_details'] != null
          ? PackagePickupDetailsDto.fromJson(
              json['pickup_details'] as Map<String, dynamic>)
          : null,
      packageDetails: json['package_details'] != null
          ? ParcelDetailsDto.fromJson(
              json['package_details'] as Map<String, dynamic>)
          : null,
      customErrandDetails: json['custom_errand_details'] != null
          ? CustomErrandDetailsDto.fromJson(
              json['custom_errand_details'] as Map<String, dynamic>)
          : null,
      deliveryLocation: json['delivery_location'] != null
          ? LocationDto.fromJson(
              json['delivery_location'] as Map<String, dynamic>)
          : const LocationDto(
              latitude: 0.0,
              longitude: 0.0,
              address: '',
            ),
      recipient: json['recipient'] != null
          ? RecipientDetailsDto.fromJson(
              json['recipient'] as Map<String, dynamic>)
          : RecipientDetailsDto.defaultRecipient,
      deliveryTimeStr:
          json['delivery_time_str'] as String? ?? 'As soon as possible',
      deliveryNotes: json['delivery_notes'] as String?,
      quote: json['quote'] != null
          ? ErrandQuoteDto.fromJson(json['quote'] as Map<String, dynamic>)
          : const ErrandQuoteDto(
              id: '',
              errandType: ErrandType.buyItems,
              serviceFeeKobo: 0,
              deliveryFeeKobo: 0,
              totalKobo: 0,
            ),
      paymentMethod: PaymentMethod.fromString(
        json['payment_method'] as String? ?? 'WALLET',
      ),
      paymentStatus: PaymentStatus.fromString(
        json['payment_status'] as String? ?? 'PENDING',
      ),
      assignedRider: json['assigned_rider'] != null
          ? RiderDto.fromJson(json['assigned_rider'] as Map<String, dynamic>)
          : null,
      statusTimeline: (json['status_timeline'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          const [],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
      completedAt: json['completed_at'] != null
          ? DateTime.tryParse(json['completed_at'] as String)
          : null,
      cancellationReason: json['cancellation_reason'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
    );
  }

  final String id;
  final String referenceNumber;
  final String customerId;
  final ErrandType type;
  final ErrandStatus status;
  final ShopDto? shop;
  final List<ShoppingItemDto> items;
  final ShoppingPreferencesDto? preferences;
  final PackagePickupDetailsDto? pickupDetails;
  final ParcelDetailsDto? packageDetails;
  final CustomErrandDetailsDto? customErrandDetails;
  final LocationDto deliveryLocation;
  final RecipientDetailsDto recipient;
  final String deliveryTimeStr;
  final String? deliveryNotes;
  final ErrandQuoteDto quote;
  final PaymentMethod paymentMethod;
  final PaymentStatus paymentStatus;
  final RiderDto? assignedRider;
  final List<Map<String, dynamic>> statusTimeline;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? cancellationReason;
  final double? rating;

  ErrandDto copyWith({
    String? id,
    String? referenceNumber,
    String? customerId,
    ErrandType? type,
    ErrandStatus? status,
    ShopDto? shop,
    List<ShoppingItemDto>? items,
    ShoppingPreferencesDto? preferences,
    PackagePickupDetailsDto? pickupDetails,
    ParcelDetailsDto? packageDetails,
    CustomErrandDetailsDto? customErrandDetails,
    LocationDto? deliveryLocation,
    RecipientDetailsDto? recipient,
    String? deliveryTimeStr,
    String? deliveryNotes,
    ErrandQuoteDto? quote,
    PaymentMethod? paymentMethod,
    PaymentStatus? paymentStatus,
    RiderDto? assignedRider,
    List<Map<String, dynamic>>? statusTimeline,
    DateTime? createdAt,
    DateTime? completedAt,
    String? cancellationReason,
    double? rating,
  }) {
    return ErrandDto(
      id: id ?? this.id,
      referenceNumber: referenceNumber ?? this.referenceNumber,
      customerId: customerId ?? this.customerId,
      type: type ?? this.type,
      status: status ?? this.status,
      shop: shop ?? this.shop,
      items: items ?? this.items,
      preferences: preferences ?? this.preferences,
      pickupDetails: pickupDetails ?? this.pickupDetails,
      packageDetails: packageDetails ?? this.packageDetails,
      customErrandDetails: customErrandDetails ?? this.customErrandDetails,
      deliveryLocation: deliveryLocation ?? this.deliveryLocation,
      recipient: recipient ?? this.recipient,
      deliveryTimeStr: deliveryTimeStr ?? this.deliveryTimeStr,
      deliveryNotes: deliveryNotes ?? this.deliveryNotes,
      quote: quote ?? this.quote,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      assignedRider: assignedRider ?? this.assignedRider,
      statusTimeline: statusTimeline ?? this.statusTimeline,
      createdAt: createdAt ?? this.createdAt,
      completedAt: completedAt ?? this.completedAt,
      cancellationReason: cancellationReason ?? this.cancellationReason,
      rating: rating ?? this.rating,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reference_number': referenceNumber,
        'customer_id': customerId,
        'type': type.code,
        'status': status.code,
        if (shop != null) 'shop': shop!.toJson(),
        'items': items.map((i) => i.toJson()).toList(),
        if (preferences != null) 'preferences': preferences!.toJson(),
        if (pickupDetails != null) 'pickup_details': pickupDetails!.toJson(),
        if (packageDetails != null) 'package_details': packageDetails!.toJson(),
        if (customErrandDetails != null)
          'custom_errand_details': customErrandDetails!.toJson(),
        'delivery_location': deliveryLocation.toJson(),
        'recipient': recipient.toJson(),
        'delivery_time_str': deliveryTimeStr,
        if (deliveryNotes != null) 'delivery_notes': deliveryNotes,
        'quote': quote.toJson(),
        'payment_method': paymentMethod.code,
        'payment_status': paymentStatus.code,
        if (assignedRider != null) 'assigned_rider': assignedRider!.toJson(),
        'status_timeline': statusTimeline,
        'created_at': createdAt.toIso8601String(),
        if (completedAt != null) 'completed_at': completedAt!.toIso8601String(),
        if (cancellationReason != null)
          'cancellation_reason': cancellationReason,
        if (rating != null) 'rating': rating,
      };

  @override
  List<Object?> get props => [
        id,
        referenceNumber,
        type,
        status,
        quote,
        paymentStatus,
        assignedRider,
      ];
}

