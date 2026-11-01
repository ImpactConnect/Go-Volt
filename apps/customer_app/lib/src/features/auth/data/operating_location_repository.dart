import 'package:app_models/app_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository that fetches operating locations from the Supabase DB.
/// Falls back to the seed location (Ogun/Shagamu) when Supabase is unavailable.
class OperatingLocationRepository {
  OperatingLocationRepository({SupabaseClient? client})
    : _client = client ?? _tryGetClient();

  final SupabaseClient? _client;

  static SupabaseClient? _tryGetClient() {
    try {
      return Supabase.instance.client;
    } catch (_) {
      return null;
    }
  }

  /// Seed fallback — matches the DB migration seed exactly.
  static const List<OperatingLocationDto> _fallback = [
    OperatingLocationDto(
      id: 'ogun-shaganu',
      state: 'Ogun',
      city: 'Shaganu',
      isActive: true,
      status: 'fully_supported',
      statusDescription: 'Fully supported',
      availableServices: [
        'instant_ride',
        'instant_delivery',
        'scheduled_ride',
        'scheduled_pickup',
      ],
      centerLat: 6.8403,
      centerLng: 3.6487,
    ),
  ];

  /// Returns all active operating locations.
  Future<List<OperatingLocationDto>> getActiveLocations() async {
    final client = _client;
    if (client == null) return _fallback;
    try {
      final response = await client
          .from('operating_locations')
          .select()
          .eq('is_active', true)
          .order('state')
          .order('city');

      final list = (response as List<dynamic>)
          .map(
            (row) => OperatingLocationDto.fromJson(row as Map<String, dynamic>),
          )
          .toList();
      return list.isEmpty ? _fallback : list;
    } catch (_) {
      return _fallback;
    }
  }

  /// Returns all distinct active states.
  Future<List<String>> getActiveStates() async {
    final locations = await getActiveLocations();
    final states = locations.map((l) => l.state).toSet().toList()..sort();
    return states;
  }

  /// Returns active locations for a given state.
  Future<List<OperatingLocationDto>> getCitiesForState(String state) async {
    final client = _client;
    if (client == null) {
      return _fallback.where((l) => l.state == state).toList();
    }
    try {
      final response = await client
          .from('operating_locations')
          .select()
          .eq('is_active', true)
          .eq('state', state)
          .order('city');

      final list = (response as List<dynamic>)
          .map(
            (row) => OperatingLocationDto.fromJson(row as Map<String, dynamic>),
          )
          .toList();
      return list.isEmpty
          ? _fallback.where((l) => l.state == state).toList()
          : list;
    } catch (_) {
      return _fallback.where((l) => l.state == state).toList();
    }
  }
}

// ── Providers ─────────────────────────────────────────────────────────────────

final operatingLocationRepositoryProvider =
    Provider<OperatingLocationRepository>((ref) {
      return OperatingLocationRepository();
    });

/// All active operating locations.
final operatingLocationsProvider = FutureProvider<List<OperatingLocationDto>>((
  ref,
) {
  return ref.read(operatingLocationRepositoryProvider).getActiveLocations();
});

/// Distinct active states.
final operatingStatesProvider = FutureProvider<List<String>>((ref) {
  return ref.read(operatingLocationRepositoryProvider).getActiveStates();
});

/// Cities for a specific state (family provider).
final operatingCitiesProvider =
    FutureProvider.family<List<OperatingLocationDto>, String>((ref, state) {
      return ref
          .read(operatingLocationRepositoryProvider)
          .getCitiesForState(state);
    });
