import 'package:flutter_riverpod/legacy.dart';
import 'package:hall_booking_platform/features/admin/analytics/data/repositories/analytics_repository_impl.dart';
import 'package:hall_booking_platform/features/admin/analytics/domain/entities/analytics_dashboard.dart';

/// State for the analytics dashboard screen.
class AnalyticsState {
  const AnalyticsState({
    this.dashboard,
    this.isLoading = false,
    this.error,
    this.selectedPeriod = 'monthly',
  });

  final AnalyticsDashboard? dashboard;
  final bool isLoading;
  final String? error;
  final String selectedPeriod;

  AnalyticsState copyWith({
    AnalyticsDashboard? dashboard,
    bool? isLoading,
    String? error,
    String? selectedPeriod,
    bool clearError = false,
  }) {
    return AnalyticsState(
      dashboard: dashboard ?? this.dashboard,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
    );
  }
}

/// Manages the admin analytics dashboard state.
class AnalyticsNotifier extends StateNotifier<AnalyticsState> {
  AnalyticsNotifier(this._repository) : super(const AnalyticsState());

  final AnalyticsRepositoryImpl _repository;

  /// Loads analytics for the currently selected period.
  Future<void> loadAnalytics() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.getAnalytics(state.selectedPeriod);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (dashboard) => state = state.copyWith(
        isLoading: false,
        dashboard: dashboard,
      ),
    );
  }

  /// Changes the selected period and reloads analytics.
  Future<void> changePeriod(String period) async {
    state = state.copyWith(selectedPeriod: period);
    await loadAnalytics();
  }

  /// Clears error state.
  void clearError() {
    state = state.copyWith(clearError: true);
  }
}

/// Riverpod provider for [AnalyticsNotifier].
final analyticsNotifierProvider =
    StateNotifierProvider<AnalyticsNotifier, AnalyticsState>((ref) {
  return AnalyticsNotifier(ref.watch(analyticsRepositoryProvider));
});
