import 'package:flutter_riverpod/legacy.dart';
import 'package:hall_booking_platform/features/admin/users/data/repositories/user_management_repository_impl.dart';
import 'package:hall_booking_platform/features/auth/domain/entities/app_user.dart';

/// State for the user management screen.
class UserManagementState {
  const UserManagementState({
    this.users = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isProcessing = false,
    this.error,
    this.successMessage,
    this.currentPage = 1,
    this.hasMore = true,
  });

  final List<AppUser> users;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isProcessing;
  final String? error;
  final String? successMessage;
  final int currentPage;
  final bool hasMore;

  UserManagementState copyWith({
    List<AppUser>? users,
    bool? isLoading,
    bool? isLoadingMore,
    bool? isProcessing,
    String? error,
    String? successMessage,
    int? currentPage,
    bool? hasMore,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return UserManagementState(
      users: users ?? this.users,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      isProcessing: isProcessing ?? this.isProcessing,
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Manages the admin user management state.
class UserManagementNotifier extends StateNotifier<UserManagementState> {
  UserManagementNotifier(this._repository)
      : super(const UserManagementState());

  final UserManagementRepositoryImpl _repository;

  /// Loads the first page of users.
  Future<void> loadUsers() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.getUsers(page: 1);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (users) => state = state.copyWith(
        isLoading: false,
        users: users,
        currentPage: 1,
        hasMore: users.length >= 20,
      ),
    );
  }

  /// Loads the next page of users.
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    final nextPage = state.currentPage + 1;
    final result = await _repository.getUsers(page: nextPage);

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingMore: false,
        error: failure.message,
      ),
      (users) => state = state.copyWith(
        isLoadingMore: false,
        users: [...state.users, ...users],
        currentPage: nextPage,
        hasMore: users.length >= 20,
      ),
    );
  }

  /// Updates a user's role and refreshes the user in the list.
  Future<void> updateUserRole(String userId, String newRole) async {
    state = state.copyWith(
      isProcessing: true,
      clearError: true,
      clearSuccess: true,
    );

    final result = await _repository.updateUserRole(userId, newRole);

    result.fold(
      (failure) => state = state.copyWith(
        isProcessing: false,
        error: failure.message,
      ),
      (_) {
        final updatedUsers = state.users.map((u) {
          if (u.id == userId) return u.copyWith(role: newRole);
          return u;
        }).toList();
        state = state.copyWith(
          isProcessing: false,
          users: updatedUsers,
          successMessage: 'User role updated successfully.',
        );
      },
    );
  }

  /// Deactivates a user account and updates the user in the list.
  Future<void> deactivateUser(String userId) async {
    state = state.copyWith(
      isProcessing: true,
      clearError: true,
      clearSuccess: true,
    );

    final result = await _repository.deactivateUser(userId);

    result.fold(
      (failure) => state = state.copyWith(
        isProcessing: false,
        error: failure.message,
      ),
      (_) {
        final updatedUsers = state.users.map((u) {
          if (u.id == userId) return u.copyWith(isActive: false);
          return u;
        }).toList();
        state = state.copyWith(
          isProcessing: false,
          users: updatedUsers,
          successMessage: 'User deactivated successfully.',
        );
      },
    );
  }

  /// Clears error state.
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Clears success message.
  void clearSuccess() {
    state = state.copyWith(clearSuccess: true);
  }
}

/// Riverpod provider for [UserManagementNotifier].
final userManagementNotifierProvider =
    StateNotifierProvider<UserManagementNotifier, UserManagementState>((ref) {
  return UserManagementNotifier(ref.watch(userManagementRepositoryProvider));
});
