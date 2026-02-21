import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'supabase_service.dart';

/// Top-level background message handler.
/// Must be a top-level function (not a class method) for Firebase Messaging.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  debugPrint('FCM background message: ${message.messageId}');
}

/// Service responsible for Firebase Cloud Messaging integration.
///
/// Handles:
/// - Requesting notification permissions
/// - Retrieving and storing the FCM token in the users table
/// - Listening for foreground messages
/// - Registering the background message handler
///
/// Service responsible for Firebase Cloud Messaging integration.
///
/// Handles:
/// - Requesting notification permissions
/// - Retrieving and storing the FCM token in the users table
/// - Listening for foreground messages
/// - Registering the background message handler
///
/// Requirements: 8.1, 8.2, 8.3, 8.4
class FcmService {
  FcmService(this._messaging, this._supabaseClient);

  final FirebaseMessaging? _messaging;
  final SupabaseClient _supabaseClient;
  
  bool get _isSupported => _messaging != null;

  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<String>? _tokenRefreshSubscription;

  /// Callback invoked when a foreground message is received.
  /// Set this to show a snackbar, local notification, or custom UI.
  void Function(RemoteMessage message)? onForegroundMessage;

  /// Initializes FCM: sets up background handler, requests permissions,
  /// and begins listening for foreground messages and token refreshes.
  Future<void> initialize() async {
    if (!_isSupported) return;
    
    try {
      // Register the top-level background handler
      FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

      // Request notification permissions (iOS / web)
      await requestPermission();

      // Listen for foreground messages
      _foregroundSubscription =
          FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

      // Listen for token refreshes and update the stored token
      _tokenRefreshSubscription =
          _messaging!.onTokenRefresh.listen(_onTokenRefresh);
    } catch (e) {
      debugPrint('FCM initialization failed: $e');
    }
  }

  /// Requests notification permissions from the user.
  /// Returns the resulting [NotificationSettings].
  Future<NotificationSettings?> requestPermission() async {
    if (!_isSupported) return null;
    try {
      final settings = await _messaging!.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      debugPrint('FCM permission status: ${settings.authorizationStatus}');
      return settings;
    } catch (e) {
      debugPrint('FCM requestPermission failed: $e');
      return null;
    }
  }

  /// Retrieves the current FCM token and stores it in the users table
  /// for the currently authenticated user.
  ///
  /// Should be called after successful login (Requirement 8.4).
  Future<void> registerToken() async {
    if (!_isSupported) return;
    
    final user = _supabaseClient.auth.currentUser;
    if (user == null) {
      debugPrint('FCM registerToken: no authenticated user');
      return;
    }

    try {
      final token = await _messaging!.getToken();
      if (token == null) {
        debugPrint('FCM registerToken: unable to retrieve token');
        return;
      }

      await _saveToken(user.id, token);
    } catch (e) {
       debugPrint('FCM registerToken failed: $e');
    }
  }

  /// Removes the stored FCM token for the current user.
  /// Should be called on logout to stop receiving notifications.
  Future<void> unregisterToken() async {
    if (!_isSupported) return;
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return;

    try {
      await _supabaseClient
          .from('users')
          .update({'fcm_token': null}).eq('id', user.id);

      debugPrint('FCM token cleared for user ${user.id}');
    } catch (e) {
      debugPrint('FCM unregisterToken failed: $e');
    }
  }

  /// Disposes listeners. Call when the service is no longer needed.
  void dispose() {
    _foregroundSubscription?.cancel();
    _tokenRefreshSubscription?.cancel();
  }

  // ---------------------------------------------------------------------------
  // Private helpers
  // ---------------------------------------------------------------------------

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint(
      'FCM foreground message: ${message.notification?.title} – ${message.notification?.body}',
    );
    onForegroundMessage?.call(message);
  }

  Future<void> _onTokenRefresh(String newToken) async {
    final user = _supabaseClient.auth.currentUser;
    if (user == null) return;
    await _saveToken(user.id, newToken);
  }

  Future<void> _saveToken(String userId, String token) async {
    try {
      await _supabaseClient
        .from('users')
        .update({'fcm_token': token}).eq('id', userId);

      debugPrint('FCM token saved for user $userId');
    } catch (e) {
      debugPrint('FCM _saveToken failed: $e');
    }
  }
}

/// Riverpod provider for [FcmService].
final fcmServiceProvider = Provider<FcmService>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  
  FirebaseMessaging? messaging;
  try {
    // Try to access instance, but safely handle if Firebase isn't initialized
    // or if we are on web without proper config.
    messaging = FirebaseMessaging.instance;
  } catch (e) {
    debugPrint('FirebaseMessaging not available: $e');
    // On web, checking .instance might throw if not initialized.
  }
  
  final service = FcmService(messaging, supabase);
  ref.onDispose(service.dispose);
  return service;
});
