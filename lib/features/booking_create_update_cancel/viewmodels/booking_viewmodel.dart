import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/dio_client.dart';
import '../models/booking_model.dart';
import '../models/cancellation_request.dart';
import '../repositories/booking_repository.dart';

// Providers
final bookingRepositoryProvider = Provider((ref) {
  return BookingRepository(DioClient.instance.dio);
});

final bookingViewModelProvider =
    StateNotifierProvider<BookingViewModel, BookingState>((ref) {
      return BookingViewModel(ref.watch(bookingRepositoryProvider));
    });

// State
class BookingState {
  final List<Booking> bookings;
  final bool isLoading;
  final String? error;
  final String? successMessage;

  BookingState({
    this.bookings = const [],
    this.isLoading = false,
    this.error,
    this.successMessage,
  });

  BookingState copyWith({
    List<Booking>? bookings,
    bool? isLoading,
    String? error,
    String? successMessage,
  }) {
    return BookingState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      successMessage: successMessage,
    );
  }
}

// ViewModel
class BookingViewModel extends StateNotifier<BookingState> {
  final BookingRepository _repository;

  BookingViewModel(this._repository) : super(BookingState());

  // Load all bookings
  Future<void> loadBookings() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final bookings = await _repository.getBookings();
      state = state.copyWith(bookings: bookings, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Get bookings by status
  List<Booking> getBookingsByStatus(String status) {
    return state.bookings
        .where(
          (booking) => booking.status.toLowerCase() == status.toLowerCase(),
        )
        .toList();
  }

  // Get booking by ID
  Booking? getBookingById(int id) {
    try {
      return state.bookings.firstWhere((booking) => booking.id == id);
    } catch (e) {
      return null;
    }
  }

  // Create booking
  Future<bool> createBooking({
    required int tradieId,
    required int serviceId,
    required DateTime bookingStart,
    required DateTime bookingEnd,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.createBooking(
        tradieId: tradieId,
        serviceId: serviceId,
        bookingStart: bookingStart,
        bookingEnd: bookingEnd,
      );

      if (response.success && response.data != null) {
        state = state.copyWith(
          bookings: [...state.bookings, response.data!],
          isLoading: false,
          successMessage: response.message,
        );
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // Update booking
  Future<bool> updateBooking({
    required int bookingId,
    required DateTime bookingStart,
    required DateTime bookingEnd,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.updateBooking(
        bookingId: bookingId,
        bookingStart: bookingStart,
        bookingEnd: bookingEnd,
      );

      if (response.success && response.data != null) {
        final updatedBookings = state.bookings.map((booking) {
          return booking.id == bookingId ? response.data! : booking;
        }).toList();

        state = state.copyWith(
          bookings: updatedBookings,
          isLoading: false,
          successMessage: response.message,
        );
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // Cancel booking
  Future<bool> cancelBooking(int bookingId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.cancelBooking(bookingId);

      if (response.success && response.data != null) {
        final updatedBookings = state.bookings.map((booking) {
          return booking.id == bookingId ? response.data! : booking;
        }).toList();

        state = state.copyWith(
          bookings: updatedBookings,
          isLoading: false,
          successMessage: response.message,
        );
        return true;
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  // Submit cancellation request
  Future<String?> submitCancellationRequest(CancellationRequest request) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final response = await _repository.submitCancellationRequest(request);

      if (response.success) {
        state = state.copyWith(
          isLoading: false,
          successMessage: response.message,
        );
        return response.data as String?;
      } else {
        state = state.copyWith(isLoading: false, error: response.message);
        return null;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  // Load booking history (upcoming and past)
  Future<void> loadBookingHistory() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final history = await _repository.getBookingHistory();
      
      // Combine upcoming and past bookings with explicit type
      final List<Booking> allBookings = [
        ...(history['upcoming'] as List<Booking>? ?? <Booking>[]),
        ...(history['past'] as List<Booking>? ?? <Booking>[]),
      ];
      
      state = state.copyWith(
        bookings: allBookings,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  // Get upcoming bookings
  List<Booking> get upcomingBookings {
    final now = DateTime.now();
    return state.bookings
        .where((booking) => booking.bookingStart.isAfter(now))
        .toList()
      ..sort((a, b) => a.bookingStart.compareTo(b.bookingStart));
  }

  // Get past bookings
  List<Booking> get pastBookings {
    final now = DateTime.now();
    return state.bookings
        .where((booking) => booking.bookingStart.isBefore(now) || 
                           booking.bookingStart.isAtSameMomentAs(now))
        .toList()
      ..sort((a, b) => b.bookingStart.compareTo(a.bookingStart));
  }

  // Clear messages
  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }
}
