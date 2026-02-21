import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:hall_booking_platform/core/constants/app_constants.dart';
import 'package:hall_booking_platform/features/booking/data/datasources/booking_remote_data_source.dart';
import 'package:hall_booking_platform/features/booking/data/repositories/booking_repository_impl.dart';
import 'package:hall_booking_platform/features/booking/domain/entities/booking.dart';
import 'package:hall_booking_platform/features/booking/domain/entities/slot.dart';
import 'package:hall_booking_platform/features/booking/domain/repositories/booking_repository.dart';

/// Selected date for slot selection screen.
final selectedDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

/// Fetches slots for a hall on the selected date.
final slotsProvider = FutureProvider.autoDispose
    .family<List<Slot>, String>((ref, hallId) async {
  final date = ref.watch(selectedDateProvider);
  final repo = ref.read(bookingRepositoryProvider);
  final result = await repo.getAvailableSlots(hallId: hallId, date: date);
  return result.fold(
    (failure) => throw failure,
    (slots) => slots,
  );
});

/// State for booking creation.
class BookingCreationState {
  const BookingCreationState({
    this.isLoading = false,
    this.booking,
    this.error,
  });

  final bool isLoading;
  final Booking? booking;
  final String? error;

  BookingCreationState copyWith({
    bool? isLoading,
    Booking? booking,
    String? error,
    bool clearError = false,
    bool clearBooking = false,
  }) {
    return BookingCreationState(
      isLoading: isLoading ?? this.isLoading,
      booking: clearBooking ? null : (booking ?? this.booking),
      error: clearError ? null : (error ?? this.error),
    );
  }
}

/// Notifier for creating a booking.
class BookingCreationNotifier extends StateNotifier<BookingCreationState> {
  BookingCreationNotifier(this._repository)
      : super(const BookingCreationState());

  final BookingRepository _repository;

  Future<bool> createBooking({
    required String hallId,
    required String slotId,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);

    final result = await _repository.createBooking(
      hallId: hallId,
      slotId: slotId,
    );

    return result.fold(
      (failure) {
        state = state.copyWith(isLoading: false, error: failure.message);
        return false;
      },
      (booking) {
        state = state.copyWith(isLoading: false, booking: booking);
        return true;
      },
    );
  }

  void reset() {
    state = const BookingCreationState();
  }
}

final bookingCreationProvider =
    StateNotifierProvider<BookingCreationNotifier, BookingCreationState>((ref) {
  return BookingCreationNotifier(ref.watch(bookingRepositoryProvider));
});

/// Manages paginated booking history with load-more support.
class BookingHistoryNotifier extends StateNotifier<AsyncValue<List<Booking>>> {
  BookingHistoryNotifier(this._repository)
      : super(const AsyncValue.loading());

  final BookingRepository _repository;
  int _currentPage = 1;
  bool _hasMore = true;
  bool _isLoadingMore = false;

  bool get hasMore => _hasMore;
  bool get isLoadingMore => _isLoadingMore;

  Future<void> loadInitial() async {
    _currentPage = 1;
    _hasMore = true;
    state = const AsyncValue.loading();
    try {
      final result = await _repository.getUserBookings(
        page: 1,
        pageSize: AppConstants.defaultPageSize,
      );
      result.fold(
        (failure) => state = AsyncValue.error(failure, StackTrace.current),
        (bookings) {
          _hasMore = bookings.length >= AppConstants.defaultPageSize;
          state = AsyncValue.data(bookings);
        },
      );
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;

    try {
      _currentPage++;
      final result = await _repository.getUserBookings(
        page: _currentPage,
        pageSize: AppConstants.defaultPageSize,
      );
      result.fold(
        (failure) => _currentPage--,
        (bookings) {
          _hasMore = bookings.length >= AppConstants.defaultPageSize;
          final current = state.asData?.value ?? [];
          state = AsyncValue.data([...current, ...bookings]);
        },
      );
    } catch (_) {
      _currentPage--;
    } finally {
      _isLoadingMore = false;
    }
  }
}

final bookingHistoryProvider =
    StateNotifierProvider<BookingHistoryNotifier, AsyncValue<List<Booking>>>(
        (ref) {
  return BookingHistoryNotifier(ref.watch(bookingRepositoryProvider));
});

/// Fetches a single booking by ID using the data source directly.
final bookingDetailProvider = FutureProvider.autoDispose
    .family<Booking, String>((ref, bookingId) async {
  final dataSource = ref.read(bookingRemoteDataSourceProvider);
  return dataSource.getBookingById(bookingId);
});

/// State for booking cancellation.
class BookingCancellationState {
  const BookingCancellationState({
    this.isLoading = false,
    this.error,
    this.isCancelled = false,
  });

  final bool isLoading;
  final String? error;
  final bool isCancelled;
}

/// Notifier for cancelling a booking.
class BookingCancellationNotifier
    extends StateNotifier<BookingCancellationState> {
  BookingCancellationNotifier(this._repository)
      : super(const BookingCancellationState());

  final BookingRepository _repository;

  Future<bool> cancelBooking(String bookingId) async {
    state = const BookingCancellationState(isLoading: true);

    final result = await _repository.cancelBooking(bookingId);

    return result.fold(
      (failure) {
        state = BookingCancellationState(error: failure.message);
        return false;
      },
      (_) {
        state = const BookingCancellationState(isCancelled: true);
        return true;
      },
    );
  }
}

final bookingCancellationProvider = StateNotifierProvider.autoDispose<
    BookingCancellationNotifier, BookingCancellationState>((ref) {
  return BookingCancellationNotifier(ref.watch(bookingRepositoryProvider));
});
