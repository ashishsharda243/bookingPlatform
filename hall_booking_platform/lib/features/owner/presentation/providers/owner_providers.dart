import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hall_booking_platform/features/booking/domain/entities/booking.dart';
import 'package:hall_booking_platform/features/discovery/domain/entities/hall.dart';
import 'package:hall_booking_platform/features/owner/data/repositories/owner_hall_repository_impl.dart';
import 'package:hall_booking_platform/features/owner/earnings/domain/entities/earnings_report.dart';
import 'package:hall_booking_platform/features/owner/hall_management/domain/entities/hall_create_request.dart';
import 'package:hall_booking_platform/features/owner/hall_management/domain/entities/hall_update_request.dart';
import 'package:image_picker/image_picker.dart';

// ... (imports)

/// State for the owner dashboard (hall list).
class OwnerDashboardState {
  const OwnerDashboardState({
    this.halls = const [],
    this.isLoading = false,
    this.error,
  });

  final List<Hall> halls;
  final bool isLoading;
  final String? error;

  OwnerDashboardState copyWith({
    List<Hall>? halls,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return OwnerDashboardState(
      halls: halls ?? this.halls,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Manages the owner dashboard state: loading and refreshing halls.
class OwnerDashboardNotifier extends StateNotifier<OwnerDashboardState> {
  OwnerDashboardNotifier(this._repository) : super(const OwnerDashboardState());

  final OwnerHallRepositoryImpl _repository;

  /// Loads all halls owned by the current user.
  Future<void> loadHalls() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.getOwnerHalls();

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (halls) => state = state.copyWith(
        isLoading: false,
        halls: halls,
      ),
    );
  }

  /// Soft deletes a hall and reloads the list.
  Future<void> deleteHall(String hallId) async {
    state = state.copyWith(isLoading: true, clearError: true);
    
    final result = await _repository.deleteHall(hallId);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (_) {
        // Reload halls after successful deletion
        loadHalls();
      },
    );
  }
}

/// Riverpod provider for [OwnerDashboardNotifier].
final ownerDashboardNotifierProvider =
    StateNotifierProvider<OwnerDashboardNotifier, OwnerDashboardState>((ref) {
  return OwnerDashboardNotifier(ref.watch(ownerHallRepositoryProvider));
});

/// State for the add/edit hall form.
class HallFormState {
  const HallFormState({
    this.hall,
    this.isLoading = false,
    this.isSaving = false,
    this.isUploadingImages = false,
    this.error,
    this.successMessage,
    this.selectedImages = const [],
  });

  final Hall? hall;
  final bool isLoading;
  final bool isSaving;
  final bool isUploadingImages;
  final String? error;
  final String? successMessage;
  final List<XFile> selectedImages;

  HallFormState copyWith({
    Hall? hall,
    bool? isLoading,
    bool? isSaving,
    bool? isUploadingImages,
    String? error,
    String? successMessage,
    List<XFile>? selectedImages,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearHall = false,
  }) {
    return HallFormState(
      hall: clearHall ? null : (hall ?? this.hall),
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      isUploadingImages: isUploadingImages ?? this.isUploadingImages,
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
      selectedImages: selectedImages ?? this.selectedImages,
    );
  }
}

/// Manages the add/edit hall form state.
class HallFormNotifier extends StateNotifier<HallFormState> {
  HallFormNotifier(this._repository) : super(const HallFormState());

  final OwnerHallRepositoryImpl _repository;

  // ... (loadHall, createHall, updateHall unchanged)

  Future<Hall?> createHall(HallCreateRequest request) async {
    state =
        state.copyWith(isSaving: true, clearError: true, clearSuccess: true);

    final result = await _repository.createHall(request);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isSaving: false,
          error: failure.message,
        );
        return null;
      },
      (hall) {
        state = state.copyWith(
          isSaving: false,
          hall: hall,
          successMessage: 'Hall created successfully. Pending approval.',
        );
        return hall;
      },
    );
  }

  Future<void> loadHall(String hallId) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.getHall(hallId);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (hall) => state = state.copyWith(
        isLoading: false,
        hall: hall,
      ),
    );
  }

  Future<Hall?> updateHall(String hallId, HallUpdateRequest request) async {
    state =
        state.copyWith(isSaving: true, clearError: true, clearSuccess: true);

    final result = await _repository.updateHall(hallId, request);

    return result.fold(
      (failure) {
        state = state.copyWith(
          isSaving: false,
          error: failure.message,
        );
        return null;
      },
      (hall) {
        state = state.copyWith(
          isSaving: false,
          hall: hall,
          successMessage: 'Hall updated successfully.',
        );
        return hall;
      },
    );
  }

  /// Uploads images for a hall.
  Future<void> uploadImages(String hallId, List<XFile> images) async {
    state = state.copyWith(
      isUploadingImages: true,
      clearError: true,
      clearSuccess: true,
    );

    final result = await _repository.uploadHallImages(hallId, images);

    result.fold(
      (failure) => state = state.copyWith(
        isUploadingImages: false,
        error: failure.message,
      ),
      (urls) {
        // Merge new URLs with existing ones
        final existingUrls = state.hall?.imageUrls ?? [];
        final updatedHall = state.hall?.copyWith(
          imageUrls: [...existingUrls, ...urls],
        );
        state = state.copyWith(
          isUploadingImages: false,
          hall: updatedHall,
          selectedImages: [],
          successMessage: '${urls.length} image(s) uploaded.',
        );
      },
    );
  }

  /// Adds locally selected images (not yet uploaded).
  void addSelectedImages(List<XFile> images) {
    state = state.copyWith(
      selectedImages: [...state.selectedImages, ...images],
    );
  }

  /// Removes a locally selected image.
  void removeSelectedImage(int index) {
    final updated = [...state.selectedImages]..removeAt(index);
    state = state.copyWith(selectedImages: updated);
  }

  /// Clears error state.
  void clearError() {
    state = state.copyWith(clearError: true);
  }

  /// Clears success message.
  void clearSuccess() {
    state = state.copyWith(clearSuccess: true);
  }

  /// Resets the form state.
  void reset() {
    state = const HallFormState();
  }
}

/// Riverpod provider for [HallFormNotifier].
final hallFormNotifierProvider =
    StateNotifierProvider.autoDispose<HallFormNotifier, HallFormState>((ref) {
  return HallFormNotifier(ref.watch(ownerHallRepositoryProvider));
});

// =============================================================================
// Availability Management Providers
// =============================================================================

/// State for the availability calendar screen.
class AvailabilityCalendarState {
  const AvailabilityCalendarState({
    this.selectedDate,
    this.slotsForDate = const [],
    this.slotSummary = const {},
    this.isLoading = false,
    this.isLoadingSlots = false,
    this.isBlocking = false,
    this.error,
    this.successMessage,
  });

  final DateTime? selectedDate;
  final List<Map<String, dynamic>> slotsForDate;
  final Map<String, Map<String, int>> slotSummary;
  final bool isLoading;
  final bool isLoadingSlots;
  final bool isBlocking;
  final String? error;
  final String? successMessage;

  AvailabilityCalendarState copyWith({
    DateTime? selectedDate,
    List<Map<String, dynamic>>? slotsForDate,
    Map<String, Map<String, int>>? slotSummary,
    bool? isLoading,
    bool? isLoadingSlots,
    bool? isBlocking,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearSelectedDate = false,
  }) {
    return AvailabilityCalendarState(
      selectedDate:
          clearSelectedDate ? null : (selectedDate ?? this.selectedDate),
      slotsForDate: slotsForDate ?? this.slotsForDate,
      slotSummary: slotSummary ?? this.slotSummary,
      isLoading: isLoading ?? this.isLoading,
      isLoadingSlots: isLoadingSlots ?? this.isLoadingSlots,
      isBlocking: isBlocking ?? this.isBlocking,
      error: clearError ? null : (error ?? this.error),
      successMessage:
          clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

/// Manages the availability calendar state for a specific hall.
class AvailabilityCalendarNotifier
    extends StateNotifier<AvailabilityCalendarState> {
  AvailabilityCalendarNotifier(this._repository, this.hallId)
      : super(const AvailabilityCalendarState());

  final OwnerHallRepositoryImpl _repository;
  final String hallId;

  /// Loads slot summary for the given month.
  Future<void> loadMonthSummary(DateTime month) async {
    state = state.copyWith(isLoading: true, clearError: true);

    debugPrint(
        'Loading month summary for hall: $hallId, month: ${month.month}/${month.year}');

    final startDate = DateTime(month.year, month.month, 1);
    final endDate = DateTime(month.year, month.month + 1, 0);

    final result = await _repository.getSlotSummary(hallId, startDate, endDate);

    result.fold(
      (failure) {
        debugPrint('Failed to load summary: ${failure.message}');
        state = state.copyWith(
          isLoading: false,
          error: failure.message,
        );
      },
      (summary) {
        debugPrint('Loaded summary with ${summary.length} dates');
        state = state.copyWith(
          isLoading: false,
          slotSummary: summary,
        );
      },
    );
  }

  /// Loads slots for a specific date.
  Future<void> selectDate(DateTime date) async {
    state = state.copyWith(
      selectedDate: date,
      isLoadingSlots: true,
      clearError: true,
    );

    final result = await _repository.getSlotsByDate(hallId, date);

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingSlots: false,
        error: failure.message,
      ),
      (slots) => state = state.copyWith(
        isLoadingSlots: false,
        slotsForDate: slots,
      ),
    );
  }

  /// Blocks slots for the given date range.
  Future<void> blockDates(DateTime start, DateTime end) async {
    state =
        state.copyWith(isBlocking: true, clearError: true, clearSuccess: true);

    final result = await _repository.blockSlots(
      hallId: hallId,
      startDate: start,
      endDate: end,
    );

    result.fold(
      (failure) => state = state.copyWith(
        isBlocking: false,
        error: failure.message,
      ),
      (_) {
        state = state.copyWith(
          isBlocking: false,
          successMessage: 'Dates blocked successfully.',
        );
        // Refresh data
        loadMonthSummary(start);
        if (state.selectedDate != null) {
          selectDate(state.selectedDate!);
        }
      },
    );
  }

  /// Unblocks slots for the given date range.
  Future<void> unblockDates(DateTime start, DateTime end) async {
    state =
        state.copyWith(isBlocking: true, clearError: true, clearSuccess: true);

    final result = await _repository.unblockSlots(
      hallId: hallId,
      startDate: start,
      endDate: end,
    );

    result.fold(
      (failure) => state = state.copyWith(
        isBlocking: false,
        error: failure.message,
      ),
      (_) {
        state = state.copyWith(
          isBlocking: false,
          successMessage: 'Dates unblocked successfully.',
        );
        // Refresh data
        loadMonthSummary(start);
        if (state.selectedDate != null) {
          selectDate(state.selectedDate!);
        }
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

/// Riverpod provider for [AvailabilityCalendarNotifier], scoped by hallId.
final availabilityCalendarNotifierProvider = StateNotifierProvider.family<
    AvailabilityCalendarNotifier,
    AvailabilityCalendarState,
    String>((ref, hallId) {
  return AvailabilityCalendarNotifier(
    ref.watch(ownerHallRepositoryProvider),
    hallId,
  );
});

// =============================================================================
// Owner Bookings Providers
// =============================================================================

/// State for the owner bookings screen.
class OwnerBookingsState {
  const OwnerBookingsState({
    this.bookings = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.currentPage = 1,
    this.hasMore = true,
  });

  final List<Booking> bookings;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int currentPage;
  final bool hasMore;

  OwnerBookingsState copyWith({
    List<Booking>? bookings,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? currentPage,
    bool? hasMore,
    bool clearError = false,
  }) {
    return OwnerBookingsState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: clearError ? null : (error ?? this.error),
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

/// Manages the owner bookings list state.
class OwnerBookingsNotifier extends StateNotifier<OwnerBookingsState> {
  OwnerBookingsNotifier(this._repository) : super(const OwnerBookingsState());

  final OwnerHallRepositoryImpl _repository;

  /// Loads the first page of bookings.
  Future<void> loadBookings() async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.getOwnerBookings(page: 1);

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (bookings) => state = state.copyWith(
        isLoading: false,
        bookings: bookings,
        currentPage: 1,
        hasMore: bookings.length >= 20,
      ),
    );
  }

  /// Loads the next page of bookings.
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    final nextPage = state.currentPage + 1;
    final result = await _repository.getOwnerBookings(page: nextPage);

    result.fold(
      (failure) => state = state.copyWith(
        isLoadingMore: false,
        error: failure.message,
      ),
      (bookings) => state = state.copyWith(
        isLoadingMore: false,
        bookings: [...state.bookings, ...bookings],
        currentPage: nextPage,
        hasMore: bookings.length >= 20,
      ),
    );
  }

  /// Accepts a pending booking.
  Future<void> acceptBooking(String bookingId) async {
    final result = await _repository.updateBookingStatus(
      bookingId,
      'confirmed',
    );

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) {
        // Optimistically update the UI
        final updatedBookings = state.bookings.map((b) {
          if (b.id == bookingId) {
            return b.copyWith(bookingStatus: 'confirmed');
          }
          return b;
        }).toList();
        state = state.copyWith(bookings: updatedBookings);
      },
    );
  }

  /// Rejects a pending booking and releases its slot.
  Future<void> rejectBooking(String bookingId, String slotId) async {
    final result = await _repository.updateBookingStatus(
      bookingId,
      'cancelled',
      slotIdToRelease: slotId,
    );

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) {
        // Optimistically update the UI
        final updatedBookings = state.bookings.map((b) {
          if (b.id == bookingId) {
            return b.copyWith(bookingStatus: 'cancelled');
          }
          return b;
        }).toList();
        state = state.copyWith(bookings: updatedBookings);
      },
    );
  }

  /// Cancels an already confirmed booking and releases its slot.
  Future<void> cancelBooking(String bookingId, String slotId) async {
    final result = await _repository.updateBookingStatus(
      bookingId,
      'cancelled',
      slotIdToRelease: slotId,
    );

    result.fold(
      (failure) => state = state.copyWith(error: failure.message),
      (_) {
        // Optimistically update the UI
        final updatedBookings = state.bookings.map((b) {
          if (b.id == bookingId) {
            return b.copyWith(bookingStatus: 'cancelled');
          }
          return b;
        }).toList();
        state = state.copyWith(bookings: updatedBookings);
      },
    );
  }
}

/// Riverpod provider for [OwnerBookingsNotifier].
final ownerBookingsNotifierProvider =
    StateNotifierProvider<OwnerBookingsNotifier, OwnerBookingsState>((ref) {
  return OwnerBookingsNotifier(ref.watch(ownerHallRepositoryProvider));
});

// =============================================================================
// Earnings Report Providers
// =============================================================================

/// State for the earnings report screen.
class EarningsReportState {
  const EarningsReportState({
    this.report,
    this.isLoading = false,
    this.error,
    this.selectedPeriod = 'monthly',
  });

  final EarningsReport? report;
  final bool isLoading;
  final String? error;
  final String selectedPeriod;

  EarningsReportState copyWith({
    EarningsReport? report,
    bool? isLoading,
    String? error,
    String? selectedPeriod,
    bool clearError = false,
    bool clearReport = false,
  }) {
    return EarningsReportState(
      report: clearReport ? null : (report ?? this.report),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      selectedPeriod: selectedPeriod ?? this.selectedPeriod,
    );
  }
}

/// Manages the earnings report state.
class EarningsReportNotifier extends StateNotifier<EarningsReportState> {
  EarningsReportNotifier(this._repository) : super(const EarningsReportState());

  final OwnerHallRepositoryImpl _repository;

  /// Loads earnings report for all owned halls.
  Future<void> loadEarnings({String? period}) async {
    final selectedPeriod = period ?? state.selectedPeriod;
    state = state.copyWith(
      isLoading: true,
      clearError: true,
      selectedPeriod: selectedPeriod,
    );

    final result = await _repository.getOwnerEarnings(
      period: selectedPeriod,
    );

    result.fold(
      (failure) => state = state.copyWith(
        isLoading: false,
        error: failure.message,
      ),
      (report) => state = state.copyWith(
        isLoading: false,
        report: report,
      ),
    );
  }

  /// Changes the selected period and reloads.
  Future<void> changePeriod(String period) async {
    await loadEarnings(period: period);
  }
}

/// Riverpod provider for [EarningsReportNotifier].
final earningsReportNotifierProvider =
    StateNotifierProvider<EarningsReportNotifier, EarningsReportState>((ref) {
  return EarningsReportNotifier(ref.watch(ownerHallRepositoryProvider));
});
