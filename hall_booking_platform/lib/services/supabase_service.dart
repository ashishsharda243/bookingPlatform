import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Provides the Supabase URL from environment variables.
/// Priority: .env file > --dart-define
final _supabaseUrl = dotenv.env['SUPABASE_URL'] ?? 
    const String.fromEnvironment('SUPABASE_URL');

/// Provides the Supabase anon key from environment variables.
/// Priority: .env file > --dart-define
final _supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'] ?? 
    const String.fromEnvironment('SUPABASE_ANON_KEY');

/// Service responsible for initializing and providing access to the Supabase client.
class SupabaseService {
  SupabaseService._();

  static SupabaseClient get client => Supabase.instance.client;

  static GoTrueClient get auth => client.auth;

  /// Returns the current session's access token, or null if not authenticated.
  static String? get accessToken =>
      auth.currentSession?.accessToken;

  /// Initializes Supabase. Must be called once before runApp.
  static Future<void> initialize() async {
    assert(
      _supabaseUrl.isNotEmpty && _supabaseAnonKey.isNotEmpty,
      'SUPABASE_URL and SUPABASE_ANON_KEY must be provided via --dart-define',
    );

    await Supabase.initialize(
      url: _supabaseUrl,
      anonKey: _supabaseAnonKey,
    );
  }
}

/// Riverpod provider for the Supabase client.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return SupabaseService.client;
});

/// Riverpod provider for the Supabase auth client.
final supabaseAuthProvider = Provider<GoTrueClient>((ref) {
  return SupabaseService.auth;
});
