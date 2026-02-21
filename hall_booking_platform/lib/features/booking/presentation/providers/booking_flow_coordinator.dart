import 'package:flutter_riverpod/legacy.dart';
import 'package:hall_booking_platform/features/booking/domain/entities/booking.dart';
import 'package:hall_booking_platform/features/booking/presentation/providers/booking_providers.dart';
import 'package:hall_booking_platform/features/payment/domain/repositories/payment_repository.dart';
import 'package:hall_booking_platform/features/payment/data/repositories/payment_repository_impl.dart';
import 'package:hall_booking_platform/features/payment/presentation/providers/payment_providers.dart';
import 'package:hall_booking_platform/services/fcm_service.dart';

/// Phases of the booking flow.
enum BookingFlowPhase {
  /// User is selecting a slot.
  slotSelection,

  /// User is reviewing the booking summary.
  confirmation,

  /// Booking created, creating Razorpay order.
  creatingOrder,

  /// Razorpay checkout is open / payment in progress.
  payment,

  /// Payment verified, booking confirmed.
  completed,

  /// An error occurred at some point in the flow.
  error,
}

/// State for the end-to-end booking flow.
class BookingFlowState {
  const BookingFlowState({
    this.phase = BookingFlowPhase.slotSelection,
    this.hallId,
    this.slotId,
    this.booking,
    this.razorpayOrderId,
    this.errorMessage,
  });

  final BookingFlowPhase phase;
  final String? hallId;
  final String? slotId;
  final Booking? booking;
  final String? razorpayOrderId;
  final String? errorMessage;

  BookingFlowState copyWith({
    BookingFlowPhase? phase,
    String? hallId,
    String? slotId,
    Booking? booking,
    String? razorpayOrderId,
    String? errorMessage,
    bool clearError = false,
    bool clearBooking = false,
    bool clearOrderId = false,
  }) {
    return BookingFlowState(
      phase: phase ?? this.phase,
      hallId: hallId ?? this.hallId,
      slotId: slotId ?? this.slotId,
      booking: clearBooking ? null : (booking ?? this.booking),
      razorpayOrderId:
          clearOrderId ? null : (razorpayOrderId ?? this.razorpayOrderId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Coordinates the complete booking flow:
/// Slot selection → Booking creation → Razorpay order → Payment → Confirmation → Notification.
///
/// Requirements: 4.3, 5.1, 5.2, 5.3, 8.1
class BookingFlowCoordinator extends StateNotifier<BookingFlowState> {
  BookingFlowCoordinator({
    required this.bookingCreationNotifier,
    required this.paymentRepository,
    required this.paymentNotifier,
    required this.fcmService,
  }) : super(const BookingFlowState());

  final BookingCreationNotifier bookingCreationNotifier;
  final PaymentRepository paymentRepository;
  final PaymentNotifier paymentNotifier;
  final FcmService fcmService;

  /// Starts the flow for a given hall.
  void startFlow({required String hallId}) {
    state = BookingFlowState(
      phase: BookingFlowPhase.slotSelection,
      hallId: hallId,
    );
  }

  /// Moves to the confirmation phase after a slot is selected.
  void selectSlot({required String slotId}) {
    state = state.copyWith(
      phase: BookingFlowPhase.confirmation,
      slotId: slotId,
    );
  }

  /// Creates the booking and then creates a Razorpay order.
  /// Returns the Razorpay order ID on success, or null on failure.
  ///
  /// Requirements: 4.3, 5.1
  Future<String?> confirmBookingAndCreateOrder({
    required String hallId,
    required String slotId,
  }) async {
    state = state.copyWith(
      phase: BookingFlowPhase.creatingOrder,
      clearError: true,
    );

    // Step 1: Create the booking (pending status)
    final bookingSuccess = await bookingCreationNotifier.createBooking(
      hallId: hallId,
      slotId: slotId,
    );

    if (!bookingSuccess) {
      final error = bookingCreationNotifier.state.error;
      state = state.copyWith(
        phase: BookingFlowPhase.error,
        errorMessage: error ?? 'Failed to create booking.',
      );
      return null;
    }

    final booking = bookingCreationNotifier.state.booking;
    if (booking == null) {
      state = state.copyWith(
        phase: BookingFlowPhase.error,
        errorMessage: 'Booking created but data unavailable.',
      );
      return null;
    }

    state = state.copyWith(booking: booking);

    // Step 2: Create Razorpay order for the booking amount
    final orderResult = await paymentRepository.createRazorpayOrder(
      bookingId: booking.id,
      amount: booking.totalPrice,
    );

    return orderResult.fold(
      (failure) {
        state = state.copyWith(
          phase: BookingFlowPhase.error,
          errorMessage: failure.message,
        );
        return null;
      },
      (orderId) {
        // Feature: Skip Payment Flow (Direct Booking)
        if (orderId == 'skipped_payment') {
          state = state.copyWith(
            phase: BookingFlowPhase.completed,
            razorpayOrderId: orderId,
          );
          // Trigger any necessary post-booking logic (e.g. notifications)
          onPaymentVerified(); 
          return orderId;
        }

        state = state.copyWith(
          phase: BookingFlowPhase.payment,
          razorpayOrderId: orderId,
        );
        return orderId;
      },
    );
  }

  /// Called when payment is successfully verified.
  /// Triggers notification and moves to completed phase.
  ///
  /// Requirements: 5.3, 8.1
  void onPaymentVerified() {
    state = state.copyWith(phase: BookingFlowPhase.completed);

    // Trigger FCM token refresh to ensure notifications are received
    // The actual booking confirmation notification is sent server-side
    // by the verify-payment Edge Function (Requirement 8.1).
    _refreshFcmToken();
  }

  /// Called when payment fails.
  ///
  /// Requirement: 5.4
  void onPaymentFailed(String message) {
    state = state.copyWith(
      phase: BookingFlowPhase.error,
      errorMessage: message,
    );
  }

  /// Resets the flow state. Call when the user exits or completes the flow.
  void reset() {
    bookingCreationNotifier.reset();
    paymentNotifier.reset();
    state = const BookingFlowState();
  }

  /// Ensures FCM token is registered so the user receives the
  /// booking confirmation notification sent by the Edge Function.
  Future<void> _refreshFcmToken() async {
    try {
      await fcmService.registerToken();
    } catch (_) {
      // Non-critical — don't block the flow for FCM errors.
    }
  }
}

/// Riverpod provider for [BookingFlowCoordinator].
///
/// Uses autoDispose so providers are cleaned up when the user
/// leaves the booking flow screens.
final bookingFlowCoordinatorProvider =
    StateNotifierProvider.autoDispose<BookingFlowCoordinator, BookingFlowState>(
  (ref) {
    final coordinator = BookingFlowCoordinator(
      bookingCreationNotifier: ref.watch(bookingCreationProvider.notifier),
      paymentRepository: ref.watch(paymentRepositoryProvider),
      paymentNotifier: ref.watch(paymentNotifierProvider.notifier),
      fcmService: ref.watch(fcmServiceProvider),
    );

    // Reset state when the provider is disposed (user leaves the flow).
    ref.onDispose(() {
      coordinator.reset();
    });

    return coordinator;
  },
);
