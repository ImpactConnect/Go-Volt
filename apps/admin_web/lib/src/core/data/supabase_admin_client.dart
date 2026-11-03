import 'package:supabase_flutter/supabase_flutter.dart';

/// Helper to safely retrieve the initialized [SupabaseClient].
/// Returns `null` if running in tests where Supabase has not been initialized.
SupabaseClient? tryGetSupabaseClient() {
  try {
    return Supabase.instance.client;
  } catch (_) {
    return null;
  }
}

/// Whether the admin web app is currently connected to live Supabase.
bool get isLiveSupabase => tryGetSupabaseClient() != null;
