import 'package:flutter_riverpod/legacy.dart';
import 'package:hall_booking_platform/features/admin/approval/data/repositories/admin_repository_impl.dart';
import 'package:hall_booking_platform/features/discovery/domain/entities/hall.dart';

/// State for the hall approval screen.
class HallApprovalState {
  const HallApprovalState({
    this.halls = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.isProcessing = false,
    this.error,
    this.successMessage,
    this.currentPage = 1,
    this.hasMore = true,
  });

  final List<Hall> halls;
  final bool isLoading;
  final bool isLoadingMore;
  final bool isProcessing;
  final String? error;
  final String? successMessage;
  final int currentPage;
  final bool hasMore;

  HallApprovalState copyWith({
    List<Hall>? halls,
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
    return HallApprovalState(
      halls: halls ?? this.halls,
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

/// Manages the admin hall approval queue state.
class HallApprovalNotifier extends StateNotifier<HallApprovalState> {
  HallApprovalNotifier(this._repository)
      : super(const HallApprovalState());

  final AdminRepositoryImpl _repository;

  /// Loads the first page of pending halls.
  Future<void> loadPendingHalls() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.getPendingHalls(page: 1);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (halls) => state = state.copyWith(
        isLoading: false,
        halls: halls,
        currentPage: 1,
        hasMore: halls.length >= 20,
      ),
    );
  }

  /// Loads the next page of pending halls.
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    final nextPage = state.currentPage + 1;
    final result = await _repository.getPendingHalls(page: nextPage);

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingMore: false,
        error: failure.message,
      ),
      (halls) => state = state.copyWith(
        isLoadingMore: false,
        halls: [...state.halls, ...halls],
        currentPage: nextPage,
        hasMore: halls.length >= 20,
      ),
    );
  }

  /// Approves a hall and removes it from the pending list.
  Future<void> approveHall(String hallId) async {
    state = state.copyWith(
      isProcessing: true,
      clearError: true,
      clearSuccess: true,
    );

    final result = await _repository.approveHall(hallId);

    result.fold(
      (failure) => state = state.copyWith(
        isProcessing: false,
        error: failure.message,
      ),
      (_) {
        final updatedHalls =
            state.halls.where((h) => h.id != hallId).toList();
        state = state.copyWith(
          isProcessing: false,
          halls: updatedHalls,
          successMessage: 'Hall approved successfully.',
        );
      },
    );
  }

  /// Rejects a hall with a reason and removes it from the pending list.
  Future<void> rejectHall(String hallId, String reason) async {
    state = state.copyWith(
      isProcessing: true,
      clearError: true,
      clearSuccess: true,
    );

    final result = await _repository.rejectHall(hallId, reason);

    result.fold(
      (failure) => state = state.copyWith(
        isProcessing: false,
        error: failure.message,
      ),
      (_) {
        final updatedHalls =
            state.halls.where((h) => h.id != hallId).toList();
        state = state.copyWith(
          isProcessing: false,
          halls: updatedHalls,
          successMessage: 'Hall rejected.',
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

/// Riverpod provider for [HallApprovalNotifier].
final hallApprovalNotifierProvider =
    StateNotifierProvider<HallApprovalNotifier, HallApprovalState>((ref) {
  return HallApprovalNotifier(ref.watch(adminRepositoryProvider));
});
