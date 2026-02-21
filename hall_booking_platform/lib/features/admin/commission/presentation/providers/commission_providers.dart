import 'package:flutter_riverpod/legacy.dart';
import 'package:hall_booking_platform/features/admin/commission/data/repositories/commission_repository_impl.dart';

/// State for the commission management screen.
class CommissionState {
  const CommissionState({
    this.currentPercentage,
    this.isLoading = false,
    this.isUpdating = false,
    this.error,
    this.successMessage,
  });

  final double? currentPercentage;
  final bool isLoading;
  final bool isUpdating;
  final String? error;
  final String? successMessage;

  CommissionState copyWith({
    double? currentPercentage,
    bool? isLoading,
    bool? isUpdating,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return CommissionState(
      currentPercentage: currentPercentage ?? this.currentPercentage,
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

/// Manages the admin commission management state.
class CommissionNotifier extends StateNotifier<CommissionState> {
  CommissionNotifier(this._repository) : super(const CommissionState());

  final CommissionRepositoryImpl _repository;

  /// Loads the current commission percentage.
  Future<void> loadCommission() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.getCommissionPercentage();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (percentage) => state = state.copyWith(
        isLoading: false,
        currentPercentage: percentage,
      ),
    );
  }

  /// Updates the commission percentage.
  Future<void> updateCommission(double percentage) async {
    state = state.copyWith(
      isUpdating: true,
      clearError: true,
      clearSuccess: true,
    );

    final result = await _repository.setCommissionPercentage(percentage);

    result.fold(
      (failure) => state = state.copyWith(
        isUpdating: false,
        error: failure.message,
      ),
      (_) => state = state.copyWith(
        isUpdating: false,
        currentPercentage: percentage,
        successMessage: 'Commission updated to ${percentage.toStringAsFixed(1)}%.',
      ),
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

/// Riverpod provider for [CommissionNotifier].
final commissionNotifierProvider =
    StateNotifierProvider<CommissionNotifier, CommissionState>((ref) {
  return CommissionNotifier(ref.watch(commissionRepositoryProvider));
});
