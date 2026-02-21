import 'dart:async';

import 'package:flutter_riverpod/legacy.dart';
import 'package:hall_booking_platform/core/constants/app_constants.dart';
import 'package:hall_booking_platform/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:hall_booking_platform/features/auth/domain/entities/app_user.dart';
import 'package:hall_booking_platform/features/auth/domain/repositories/auth_repository.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Auth state holding the current user and lockout info.
class AuthState {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.otpSent = false,
    this.failedAttempts = 0,
    this.lockedUntil,
  });

  final AppUser? user;
  final bool isLoading;
  final String? error;
  final bool otpSent;
  final int failedAttempts;
  final DateTime? lockedUntil;

  bool get isAuthenticated => user != null && user!.id.isNotEmpty;

  bool get isLocked =>
      lockedUntil != null && DateTime.now().isBefore(lockedUntil!);

  AuthState copyWith({
    AppUser? user,
    bool? isLoading,
    String? error,
    bool? otpSent,
    int? failedAttempts,
    DateTime? lockedUntil,
    bool clearUser = false,
    bool clearError = false,
    bool clearLockedUntil = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      otpSent: otpSent ?? this.otpSent,
      failedAttempts: failedAttempts ?? this.failedAttempts,
      lockedUntil:
          clearLockedUntil ? null : (lockedUntil ?? this.lockedUntil),
    );
  }
}

/// Manages authentication state including OTP flow, Google sign-in,
/// and account lockout after failed attempts.
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._repository) : super(const AuthState()) {
    _authSubscription = _repository.authStateChanges().listen((user) {
      state = state.copyWith(user: user, clearUser: user == null);
    });
  }

  final AuthRepository _repository;
  StreamSubscription<AppUser?>? _authSubscription;

  /// Signs up with email and password.
  Future<void> signUp(String email, String password, String name) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result =
        await _repository.signUpWithEmailPassword(email, password, name);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (user) {
        if (user == null) {
          state = state.copyWith(
            isLoading: false,
            otpSent: true,
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            user: user,
          );
        }
      },
    );
  }

  /// Signs in with email and password.
  Future<void> signInWithPassword(String email, String password) async {
    if (state.isLocked) {
      state = state.copyWith(
        error:
            'Account locked. Try again after ${AppConstants.accountLockMinutes} minutes.',
      );
      return;
    }
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.signInWithEmailPassword(email, password);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (user) => state = state.copyWith(
        isLoading: false,
        user: user,
        failedAttempts: 0,
        clearLockedUntil: true,
      ),
    );
  }

  /// Sends an OTP to the given email.
  Future<void> sendOtp(String email) async {
    if (state.isLocked) {
      state = state.copyWith(
        error:
            'Account locked. Try again after ${AppConstants.accountLockMinutes} minutes.',
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.signInWithOtp(email);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (_) => state = state.copyWith(
        isLoading: false,
        otpSent: true,
      ),
    );
  }

  /// Verifies the OTP for the given email.
  /// Tracks failed attempts and locks after [AppConstants.maxAuthAttempts].
  Future<void> verifyOtp(String email, String otp, {OtpType type = OtpType.email}) async {
    if (state.isLocked) {
      state = state.copyWith(
        error:
            'Account locked. Try again after ${AppConstants.accountLockMinutes} minutes.',
      );
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.verifyOtp(email, otp, type: type);

    result.fold(
      (failure) {
        final attempts = state.failedAttempts + 1;
        if (attempts >= AppConstants.maxAuthAttempts) {
          state = state.copyWith(
            isLoading: false,
            error:
                'Too many failed attempts. Account locked for ${AppConstants.accountLockMinutes} minutes.',
            failedAttempts: attempts,
            lockedUntil: DateTime.now().add(
              Duration(minutes: AppConstants.accountLockMinutes),
            ),
          );
        } else {
          state = state.copyWith(
            isLoading: false,
            error: failure.message,
            failedAttempts: attempts,
          );
        }
      },
      (user) => state = state.copyWith(
        isLoading: false,
        user: user,
        failedAttempts: 0,
        clearLockedUntil: true,
      ),
    );
  }

  /// Signs in with Google OAuth.
  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.signInWithGoogle();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (user) => state = state.copyWith(
        isLoading: false,
        user: user,
        failedAttempts: 0,
        clearLockedUntil: true,
      ),
    );
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.signOut();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (_) => state = state.copyWith(
        isLoading: false,
        clearUser: true,
        otpSent: false,
        failedAttempts: 0,
        clearLockedUntil: true,
      ),
    );
  }

  /// Resets the OTP sent flag (e.g. when navigating back from OTP screen).
  void resetOtpState() {
    state = state.copyWith(otpSent: false, clearError: true);
  }

  /// Clears any displayed error.
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Manually refreshes the current user data.
  Future<void> refreshUser() async {
    final currentUser = state.user;
    if (currentUser == null) return;

    state = state.copyWith(isLoading: true);

    // We can reuse the repository's logic to fetch the user by ID.
    // However, AuthRepository currently doesn't expose a simple "getUser(id)" method 
    // that returns AppUser directly without auth state change stream.
    // We'll rely on the existing stream or add a method to Repo.
    // A quick hack is to re-emit the current user from the stream if possible, 
    // but the stream is passive.
    
    // Better approach: assume the repository can fetch the current session's user.
    final updatedUser = await _repository.getCurrentUser();
    
    if (updatedUser != null) {
      state = state.copyWith(
        isLoading: false,
        user: updatedUser,
      );
    } else {
       state = state.copyWith(isLoading: false);
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}

/// Riverpod provider for [AuthNotifier].
final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authRepositoryProvider));
});
