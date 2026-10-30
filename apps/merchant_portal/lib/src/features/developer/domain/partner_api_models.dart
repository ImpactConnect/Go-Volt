import 'package:equatable/equatable.dart';

class PartnerApiKey extends Equatable {
  const PartnerApiKey({
    required this.id,
    required this.name,
    required this.keyPrefix,
    required this.fullSecret,
    required this.createdAt,
    this.lastUsedAt,
    required this.environment,
    required this.isActive,
  });

  final String id;
  final String name;
  final String keyPrefix;
  final String fullSecret;
  final DateTime createdAt;
  final DateTime? lastUsedAt;
  final String environment;
  final bool isActive;

  PartnerApiKey copyWith({
    String? id,
    String? name,
    String? keyPrefix,
    String? fullSecret,
    DateTime? createdAt,
    DateTime? lastUsedAt,
    String? environment,
    bool? isActive,
  }) {
    return PartnerApiKey(
      id: id ?? this.id,
      name: name ?? this.name,
      keyPrefix: keyPrefix ?? this.keyPrefix,
      fullSecret: fullSecret ?? this.fullSecret,
      createdAt: createdAt ?? this.createdAt,
      lastUsedAt: lastUsedAt ?? this.lastUsedAt,
      environment: environment ?? this.environment,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        keyPrefix,
        fullSecret,
        createdAt,
        lastUsedAt,
        environment,
        isActive,
      ];
}

class WebhookEndpointConfig extends Equatable {
  const WebhookEndpointConfig({
    required this.id,
    required this.url,
    required this.secret,
    required this.subscribedEvents,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String url;
  final String secret;
  final List<String> subscribedEvents;
  final bool isActive;
  final DateTime createdAt;

  WebhookEndpointConfig copyWith({
    String? id,
    String? url,
    String? secret,
    List<String>? subscribedEvents,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return WebhookEndpointConfig(
      id: id ?? this.id,
      url: url ?? this.url,
      secret: secret ?? this.secret,
      subscribedEvents: subscribedEvents ?? this.subscribedEvents,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        url,
        secret,
        subscribedEvents,
        isActive,
        createdAt,
      ];
}

class WebhookEventDelivery extends Equatable {
  const WebhookEventDelivery({
    required this.id,
    required this.eventId,
    required this.eventType,
    required this.endpointUrl,
    required this.payload,
    required this.signatureHeader,
    required this.timestamp,
    required this.httpStatusCode,
    required this.isDelivered,
    required this.durationMs,
    this.externalReference,
  });

  final String id;
  final String eventId;
  final String eventType;
  final String endpointUrl;
  final Map<String, dynamic> payload;
  final String signatureHeader;
  final DateTime timestamp;
  final int httpStatusCode;
  final bool isDelivered;
  final int durationMs;
  final String? externalReference;

  @override
  List<Object?> get props => [
        id,
        eventId,
        eventType,
        endpointUrl,
        payload,
        signatureHeader,
        timestamp,
        httpStatusCode,
        isDelivered,
        durationMs,
        externalReference,
      ];
}

class PartnerApiRequestLog extends Equatable {
  const PartnerApiRequestLog({
    required this.id,
    required this.method,
    required this.endpoint,
    required this.idempotencyKey,
    required this.externalReference,
    required this.statusCode,
    required this.timestamp,
    required this.durationMs,
    required this.responsePayload,
  });

  final String id;
  final String method;
  final String endpoint;
  final String idempotencyKey;
  final String externalReference;
  final int statusCode;
  final DateTime timestamp;
  final int durationMs;
  final Map<String, dynamic> responsePayload;

  @override
  List<Object?> get props => [
        id,
        method,
        endpoint,
        idempotencyKey,
        externalReference,
        statusCode,
        timestamp,
        durationMs,
        responsePayload,
      ];
}
