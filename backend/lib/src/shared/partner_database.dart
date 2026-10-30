import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:logging/logging.dart';
import 'package:supabase/supabase.dart';
import 'package:uuid/uuid.dart';

final _log = Logger('PartnerDatabase');
const _uuid = Uuid();

/// Represents an authenticated partner context.
class PartnerContext {
  const PartnerContext({
    required this.integrationId,
    required this.integrationKey,
    required this.displayName,
    required this.environment,
    required this.allowedScopes,
    required this.callbackUrl,
    required this.signingSecret,
  });

  final String integrationId;
  final String integrationKey;
  final String displayName;
  final String environment;
  final List<String> allowedScopes;
  final String? callbackUrl;
  final String signingSecret;

  bool hasScope(String scope) => allowedScopes.contains(scope);
}

/// Result of an idempotency check.
sealed class IdempotencyCheckResult {
  const IdempotencyCheckResult();
}

class FreshIdempotency extends IdempotencyCheckResult {
  const FreshIdempotency();
}

class IdempotencyReplay extends IdempotencyCheckResult {
  const IdempotencyReplay(this.cachedResponse, this.statusCode);
  final Map<String, dynamic> cachedResponse;
  final int statusCode;
}

class IdempotencyConflict extends IdempotencyCheckResult {
  const IdempotencyConflict(this.message);
  final String message;
}

/// Thrown when a partner's corporate wallet does not have sufficient funds for dispatch.
class InsufficientWalletBalanceException implements Exception {
  const InsufficientWalletBalanceException({
    required this.availableBalanceKobo,
    required this.requiredFareKobo,
    this.message = 'Corporate wallet balance is insufficient for this delivery fare.',
  });

  final int availableBalanceKobo;
  final int requiredFareKobo;
  final String message;

  @override
  String toString() =>
      'InsufficientWalletBalanceException: $message (available: $availableBalanceKobo kobo, required: $requiredFareKobo kobo)';
}

/// Abstract interface for Partner Data Access.
abstract class PartnerDatabase {
  Future<PartnerContext?> validateApiKey(String rawApiKey);

  Future<IdempotencyCheckResult> checkIdempotency({
    required String integrationId,
    required String idempotencyKey,
    required String requestBody,
    String? externalReference,
  });

  Future<void> saveIdempotency({
    required String integrationId,
    required String idempotencyKey,
    required String requestPath,
    required String requestBody,
    required int statusCode,
    required Map<String, dynamic> responseBody,
    String? externalReference,
  });

  Future<Map<String, dynamic>> createDeliveryBooking({
    required PartnerContext partner,
    required Map<String, dynamic> deliveryInput,
  });

  Future<Map<String, dynamic>?> getDelivery(String trackingReference);

  Future<Map<String, dynamic>?> updateDeliveryTelemetry({
    required String trackingReference,
    required Map<String, dynamic> telemetry,
  });

  Future<Map<String, dynamic>?> cancelDelivery(String trackingReference);
}

/// Production implementation backed by Supabase PostgreSQL database.
class SupabasePartnerDatabase implements PartnerDatabase {
  SupabasePartnerDatabase({
    required String supabaseUrl,
    required String serviceRoleKey,
  }) : _client = SupabaseClient(supabaseUrl, serviceRoleKey);

  final SupabaseClient _client;

  @override
  Future<PartnerContext?> validateApiKey(String rawApiKey) async {
    final cleanKey = rawApiKey.trim();
    if (cleanKey.isEmpty) return null;

    final prefix = cleanKey.length >= 14 ? cleanKey.substring(0, 14) : cleanKey;
    final hash = sha256.convert(utf8.encode(cleanKey)).toString();

    try {
      final creds = await _client
          .from('partner_api_credentials')
          .select('id, partner_integration_id, scopes, environment, secret_hash, partner_integrations(*)')
          .eq('key_prefix', prefix)
          .eq('is_active', true)
          .maybeSingle();

      if (creds == null) return null;

      final storedHash = creds['secret_hash'] as String?;
      if (storedHash != hash) return null;

      final integration = creds['partner_integrations'] as Map<String, dynamic>?;
      if (integration == null || integration['status'] != 'active') return null;

      final scopes = (creds['scopes'] as List<dynamic>?)?.cast<String>() ??
          (integration['allowed_scopes'] as List<dynamic>?)?.cast<String>() ??
          const <String>[];

      return PartnerContext(
        integrationId: integration['id'] as String,
        integrationKey: integration['integration_key'] as String,
        displayName: integration['display_name'] as String,
        environment: integration['environment'] as String,
        allowedScopes: scopes,
        callbackUrl: integration['callback_url'] as String?,
        signingSecret: integration['callback_signing_secret'] as String? ?? 'whsec_default',
      );
    } catch (e, st) {
      _log.severe('Error validating API key against Supabase', e, st);
      return null;
    }
  }

  @override
  Future<IdempotencyCheckResult> checkIdempotency({
    required String integrationId,
    required String idempotencyKey,
    required String requestBody,
    String? externalReference,
  }) async {
    try {
      final existing = await _client
          .from('partner_idempotency_records')
          .select('request_hash, response_status_code, response_body, response_headers, expires_at')
          .eq('partner_integration_id', integrationId)
          .eq('idempotency_key', idempotencyKey)
          .maybeSingle();

      if (existing == null) {
        return const FreshIdempotency();
      }

      final headers = (existing['response_headers'] as Map<String, dynamic>?) ?? {};
      final storedExtRef = headers['external_reference'] as String?;

      if (externalReference != null && storedExtRef != null && storedExtRef != externalReference) {
        return const IdempotencyConflict(
          'Idempotency key was previously submitted with a different external reference.',
        );
      }

      final statusCode = existing['response_status_code'] as int? ?? 200;
      final body = Map<String, dynamic>.from(existing['response_body'] as Map);
      return IdempotencyReplay(body, statusCode);
    } catch (e, st) {
      _log.warning('Error querying idempotency record', e, st);
      return const FreshIdempotency();
    }
  }

  @override
  Future<void> saveIdempotency({
    required String integrationId,
    required String idempotencyKey,
    required String requestPath,
    required String requestBody,
    required int statusCode,
    required Map<String, dynamic> responseBody,
    String? externalReference,
  }) async {
    final requestHash = sha256.convert(utf8.encode(requestBody)).toString();

    try {
      await _client.from('partner_idempotency_records').upsert({
        'partner_integration_id': integrationId,
        'idempotency_key': idempotencyKey,
        'request_path': requestPath,
        'request_hash': requestHash,
        'response_status_code': statusCode,
        'response_headers': {'external_reference': externalReference},
        'response_body': responseBody,
      });
    } catch (e, st) {
      _log.warning('Failed to persist idempotency snapshot', e, st);
    }
  }

  @override
  Future<Map<String, dynamic>> createDeliveryBooking({
    required PartnerContext partner,
    required Map<String, dynamic> deliveryInput,
  }) async {
    final bookingId = _uuid.v4();
    final trackingRef = 'GV-DEL-${DateTime.now().year}-${_uuid.v4().substring(0, 4).toUpperCase()}';
    const otp = '4912';

    final grossFareKobo = (deliveryInput['gross_fare_kobo'] as num?)?.toInt() ?? 285000;
    final externalRef = deliveryInput['external_reference'] as String? ?? 'EXT-UNKNOWN';

    final result = await _client.rpc<dynamic>('dispatch_partner_delivery', params: {
      'p_integration_id': partner.integrationId,
      'p_booking_id': bookingId,
      'p_booking_reference': trackingRef,
      'p_external_reference': externalRef,
      'p_gross_fare_kobo': grossFareKobo,
      'p_pickup_address': deliveryInput['pickup_address'] ?? 'Store Pickup',
      'p_pickup_lat': deliveryInput['pickup_lat'] ?? 6.4480,
      'p_pickup_lng': deliveryInput['pickup_lng'] ?? 3.4710,
      'p_dropoff_address': deliveryInput['delivery_address'] ?? 'Customer Address',
      'p_dropoff_lat': deliveryInput['delivery_lat'] ?? 6.4290,
      'p_dropoff_lng': deliveryInput['delivery_lng'] ?? 3.4225,
      'p_recipient_name': deliveryInput['recipient_name'] ?? 'Recipient',
      'p_recipient_phone': deliveryInput['recipient_phone'] ?? '+2348000000000',
      'p_delivery_otp': otp,
      'p_instructions': deliveryInput['instructions'],
    });

    final resMap = Map<String, dynamic>.from(result as Map);
    if (resMap['success'] != true) {
      if (resMap['error_code'] == 'INSUFFICIENT_WALLET_BALANCE') {
        throw InsufficientWalletBalanceException(
          availableBalanceKobo: (resMap['available_balance_kobo'] as num?)?.toInt() ?? 0,
          requiredFareKobo: (resMap['required_fare_kobo'] as num?)?.toInt() ?? grossFareKobo,
          message: resMap['message'] as String? ?? 'Corporate wallet balance is insufficient.',
        );
      }
      throw Exception(resMap['message'] ?? 'Failed to dispatch partner delivery');
    }

    return {
      'tracking_reference': trackingRef,
      'external_reference': externalRef,
      'status': 'SEARCHING_RIDER',
      'recipient_name': deliveryInput['recipient_name'] ?? 'Recipient',
      'recipient_otp': otp,
      'delivery_address': deliveryInput['delivery_address'] ?? 'Customer Address',
      'gross_fare_kobo': grossFareKobo,
      'remaining_balance_kobo': resMap['remaining_balance_kobo'],
      'currency': 'NGN',
      'created_at': DateTime.now().toUtc().toIso8601String(),
    };
  }

  @override
  Future<Map<String, dynamic>?> getDelivery(String trackingReference) async {
    final booking = await _client
        .from('bookings')
        .select('*')
        .eq('booking_reference', trackingReference)
        .maybeSingle();

    if (booking == null) return null;

    return {
      'tracking_reference': booking['booking_reference'],
      'external_reference': booking['external_reference'],
      'status': booking['status'],
      'recipient_name': booking['recipient_name'],
      'delivery_address': booking['dropoff_address'],
      'gross_fare_kobo': ((booking['total_amount'] as num) * 100).toInt(),
      'currency': 'NGN',
      'created_at': booking['created_at'],
    };
  }

  @override
  Future<Map<String, dynamic>?> updateDeliveryTelemetry({
    required String trackingReference,
    required Map<String, dynamic> telemetry,
  }) async {
    final status = telemetry['status'] as String? ?? 'IN_PROGRESS';
    final updated = await _client
        .from('bookings')
        .update({'status': status})
        .eq('booking_reference', trackingReference)
        .select()
        .maybeSingle();

    return updated;
  }

  @override
  Future<Map<String, dynamic>?> cancelDelivery(String trackingReference) async {
    final updated = await _client
        .from('bookings')
        .update({'status': 'CANCELLED'})
        .eq('booking_reference', trackingReference)
        .select()
        .maybeSingle();

    if (updated == null) return null;

    return {
      'tracking_reference': trackingReference,
      'status': 'CANCELLED',
      'cancelled_at': DateTime.now().toUtc().toIso8601String(),
    };
  }
}

/// In-Memory fallback implementation for standalone unit tests.
class InMemoryPartnerDatabase implements PartnerDatabase {
  final Map<String, Map<String, dynamic>> _idempotency = {};
  final Map<String, Map<String, dynamic>> _deliveries = {};
  final Map<String, Map<String, dynamic>> _telemetry = {};

  static const defaultPartner = PartnerContext(
    integrationId: '11111111-2222-3333-4444-555555555555',
    integrationKey: 'int_sand_retailai_001',
    displayName: 'Retail AI Sandbox',
    environment: 'sandbox',
    allowedScopes: [
      'deliveries:create',
      'deliveries:read',
      'deliveries:quote',
      'deliveries:cancel'
    ],
    callbackUrl: 'https://api.retail-ai.ng/webhooks/govolts',
    signingSecret: 'whsec_908f7e6d5c4b3a210fedcba987654321',
  );

  @override
  Future<PartnerContext?> validateApiKey(String rawApiKey) async {
    if (rawApiKey.startsWith('volt_test_99a1') || rawApiKey.startsWith('volt_live_49f8')) {
      return defaultPartner;
    }
    return null;
  }

  @override
  Future<IdempotencyCheckResult> checkIdempotency({
    required String integrationId,
    required String idempotencyKey,
    required String requestBody,
    String? externalReference,
  }) async {
    final cached = _idempotency['$integrationId:$idempotencyKey'];
    if (cached == null) return const FreshIdempotency();

    if (externalReference != null &&
        cached['external_reference'] != null &&
        cached['external_reference'] != externalReference) {
      return const IdempotencyConflict(
        'Idempotency key was previously submitted with a different external reference.',
      );
    }

    return IdempotencyReplay(
      Map<String, dynamic>.from(cached['response_body'] as Map),
      cached['status_code'] as int? ?? 200,
    );
  }

  @override
  Future<void> saveIdempotency({
    required String integrationId,
    required String idempotencyKey,
    required String requestPath,
    required String requestBody,
    required int statusCode,
    required Map<String, dynamic> responseBody,
    String? externalReference,
  }) async {
    final requestHash = sha256.convert(utf8.encode(requestBody)).toString();
    _idempotency['$integrationId:$idempotencyKey'] = {
      'request_hash': requestHash,
      'external_reference': externalReference,
      'status_code': statusCode,
      'response_body': responseBody,
    };
  }

  final Map<String, int> _partnerWalletBalancesKobo = {
    '11111111-2222-3333-4444-555555555555': 50000000, // ₦500,000.00
  };
  final List<Map<String, dynamic>> _partnerWalletTransactions = [];

  void setWalletBalance(String integrationId, int balanceKobo) {
    _partnerWalletBalancesKobo[integrationId] = balanceKobo;
  }

  int getWalletBalance(String integrationId) {
    return _partnerWalletBalancesKobo[integrationId] ?? 50000000;
  }

  @override
  Future<Map<String, dynamic>> createDeliveryBooking({
    required PartnerContext partner,
    required Map<String, dynamic> deliveryInput,
  }) async {
    final grossFareKobo = (deliveryInput['gross_fare_kobo'] as num?)?.toInt() ?? 285000;
    final currentBalance = getWalletBalance(partner.integrationId);

    if (currentBalance < grossFareKobo) {
      throw InsufficientWalletBalanceException(
        availableBalanceKobo: currentBalance,
        requiredFareKobo: grossFareKobo,
      );
    }

    _partnerWalletBalancesKobo[partner.integrationId] = currentBalance - grossFareKobo;

    final bookingId = _uuid.v4();
    final trackingRef = 'GV-DEL-${DateTime.now().year}-${_uuid.v4().substring(0, 4).toUpperCase()}';
    
    _partnerWalletTransactions.add({
      'partner_integration_id': partner.integrationId,
      'amount_kobo': grossFareKobo,
      'type': 'DEBIT',
      'reference': 'WAL-DEB-$trackingRef',
      'booking_id': bookingId,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });

    final deliveryData = {
      'tracking_reference': trackingRef,
      'external_reference': deliveryInput['external_reference'] ?? 'EXT-REF-UNKNOWN',
      'status': 'SEARCHING_RIDER',
      'recipient_name': deliveryInput['recipient_name'] ?? 'Recipient',
      'recipient_otp': '4912',
      'delivery_address': deliveryInput['delivery_address'] ?? 'Plot 14, Victoria Island, Lagos',
      'gross_fare_kobo': grossFareKobo,
      'remaining_balance_kobo': currentBalance - grossFareKobo,
      'currency': 'NGN',
      'created_at': DateTime.now().toUtc().toIso8601String(),
    };
    _deliveries[trackingRef] = deliveryData;
    return deliveryData;
  }

  @override
  Future<Map<String, dynamic>?> getDelivery(String trackingReference) async {
    final del = _deliveries[trackingReference];
    if (del == null) return null;
    final res = Map<String, dynamic>.from(del);
    final tel = _telemetry[trackingReference];
    if (tel != null) res['telemetry'] = tel;
    return res;
  }

  @override
  Future<Map<String, dynamic>?> updateDeliveryTelemetry({
    required String trackingReference,
    required Map<String, dynamic> telemetry,
  }) async {
    _telemetry[trackingReference] = telemetry;
    final del = _deliveries[trackingReference];
    if (del != null) {
      del['status'] = telemetry['status'] ?? 'IN_TRANSIT';
      del['assigned_rider'] = telemetry['rider_name'];
      del['vehicle_plate'] = telemetry['vehicle_plate'];
      del['battery_soc'] = telemetry['battery_soc'];
    }
    return del;
  }

  @override
  Future<Map<String, dynamic>?> cancelDelivery(String trackingReference) async {
    final del = _deliveries[trackingReference];
    if (del == null) return null;
    del['status'] = 'CANCELLED';
    del['cancelled_at'] = DateTime.now().toUtc().toIso8601String();
    final fare = (del['gross_fare_kobo'] as int?) ?? 0;
    _partnerWalletBalancesKobo[defaultPartner.integrationId] =
        (_partnerWalletBalancesKobo[defaultPartner.integrationId] ?? 0) + fare;
    del['remaining_balance_kobo'] = _partnerWalletBalancesKobo[defaultPartner.integrationId];
    return del;
  }
}
