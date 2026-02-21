import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hall_booking_platform/features/auth/domain/entities/app_user.dart';
import 'package:hall_booking_platform/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Remote data source for authentication operations using Supabase Auth.
class AuthRemoteDataSource {
  AuthRemoteDataSource(this._auth, this._client);

  final GoTrueClient _auth;
  final SupabaseClient _client;

  /// Sends an OTP to the given email.
  Future<void> signInWithOtp(String email) async {
    await _auth.signInWithOtp(email: email);
  }

  /// Signs up a new user with email and password.
  Future<AppUser?> signUpWithEmailPassword(
      String email, String password, String name) async {
    final response = await _auth.signUp(
      email: email,
      password: password,
      data: {'full_name': name},
    );

    // If session is null, it means email confirmation (OTP/Link) is required.
    // The user is not logged in yet.
    if (response.session == null) {
      return null;
    }

    return _resolveUser(response);
  }

  /// Signs in a user with email and password.
  Future<AppUser> signInWithEmailPassword(String email, String password) async {
    final response = await _auth.signInWithPassword(
      email: email,
      password: password,
    );
    return _resolveUser(response);
  }

  /// Verifies the OTP for the given email and returns the user.
  /// If the user is new, inserts a record into the users table.
  Future<AppUser> verifyOtp(String email, String otp, {OtpType type = OtpType.email}) async {
    final response = await _auth.verifyOTP(
      email: email,
      token: otp,
      type: type,
    );
    return _resolveUser(response);
  }

  /// Signs in with Google by obtaining an ID token via Google Sign-In
  /// and authenticating with Supabase.
  Future<AppUser> signInWithGoogle() async {
    final googleSignIn = GoogleSignIn.instance;
    await googleSignIn.initialize(
      serverClientId: const String.fromEnvironment('GOOGLE_SERVER_CLIENT_ID'),
    );

    GoogleSignInAccount googleUser;
    try {
      googleUser = await googleSignIn.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const AuthException('Google sign-in was cancelled.');
      }
      throw AuthException('Google sign-in failed: ${e.description}');
    }

    final googleAuth = googleUser.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null) {
      throw const AuthException('Failed to obtain Google ID token.');
    }

    final response = await _auth.signInWithIdToken(
      provider: OAuthProvider.google,
      idToken: idToken,
    );
    return _resolveUser(response);
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Stream of auth state changes mapped to [AppUser].
  Stream<AppUser?> authStateChanges() {
    return _auth.onAuthStateChange.asyncMap((event) async {
      final session = event.session;
      if (session == null) return null;
      return _fetchUserRecord(session.user.id);
    });
  }

  /// Resolves the Supabase auth response into an [AppUser].
  /// Creates a new user record in the users table if one doesn't exist.
  Future<AppUser> _resolveUser(AuthResponse response) async {
    final user = response.user;
    if (user == null) {
      throw const AuthException('Authentication failed: no user returned.');
    }
    return _ensureUserRecord(user);
  }

  /// Ensures a user record exists in the users table.
  /// If the user is new, inserts a record with role='user'.
  Future<AppUser> _ensureUserRecord(User user) async {
    final existing = await _client
        .from('users')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (existing != null) {
      return AppUser.fromJson(existing);
    }

    // New registration — insert with default role
    final newRecord = {
      'id': user.id,
      'role': 'user',
      'name': user.userMetadata?['full_name'] as String? ??
          user.userMetadata?['name'] as String? ??
          '',
      // Keep users.phone non-null to satisfy schema for email-based auth users.
      'phone': (user.phone?.isNotEmpty ?? false)
          ? user.phone
          : (user.email ?? user.id),
      'email': user.email,
      'created_at': DateTime.now().toIso8601String(),
    };

    final inserted = await _client
        .from('users')
        .upsert(newRecord)
        .select()
        .single();

    return AppUser.fromJson(inserted);
  }

  /// Fetches the user record from the users table by ID.
  Future<AppUser?> _fetchUserRecord(String userId) async {
    final data = await _client
        .from('users')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (data == null) return null;
    return AppUser.fromJson(data);
  }

  /// Fetches the current authenticated user from the database.
  Future<AppUser?> getCurrentUser() async {
    final session = _auth.currentSession;
    if (session == null) return null;
    return _fetchUserRecord(session.user.id);
  }
}

/// Riverpod provider for [AuthRemoteDataSource].
final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSource(
    ref.watch(supabaseAuthProvider),
    ref.watch(supabaseClientProvider),
  );
});
