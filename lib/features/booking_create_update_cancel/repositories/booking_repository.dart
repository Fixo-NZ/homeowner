import 'package:dio/dio.dart';
import 'package:tradie/core/constants/api_constants.dart';
import 'package:tradie/core/network/api_response.dart';

import '../models/booking_model.dart';
import '../models/cancellation_request.dart';

class BookingRepository {
  final Dio _dio;

  BookingRepository(this._dio);

  void setAuthToken(String token) {
    _dio.options.headers[ApiConstants.authorization] =
    '${ApiConstants.bearer} $token';
  }

  // ================================
  // GET BOOKINGS (MAIN FIXED METHOD)
  // ================================
  Future<List<Booking>> getBookings() async {
    try {
      final response = await _dio.get('/bookings');
      final body = response.data;

      print("📦 [BOOKINGS] Raw response: $body");

      // Laravel returns: either [...] OR { data: [...] }
      List<dynamic> list = [];

      if (body is List) {
        list = body;
      } else if (body is Map<String, dynamic>) {
        if (body["data"] is List) {
          list = body["data"];
        } else if (body["bookings"] is List) {
          list = body["bookings"];
        }
      }

      print("📦 [BOOKINGS] Parsed count: ${list.length}");

      return list
          .map((json) => Booking.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print("❌ [BOOKINGS] Dio error: ${e.response?.data}");
      throw _handleError(e);
    }
  }

  // BOOKING HISTORY
  Future<Map<String, List<Booking>>> getBookingHistory() async {
    try {
      final response = await _dio.get('/bookings/history');
      final body = response.data;

      Map<String, List<Booking>> result = {
        'upcoming': [],
        'past': [],
      };

      if (body is Map<String, dynamic>) {
        if (body['upcoming'] is List) {
          result['upcoming'] = (body['upcoming'] as List)
              .map((json) => Booking.fromJson(json))
              .toList();
        }
        if (body['past'] is List) {
          result['past'] = (body['past'] as List)
              .map((json) => Booking.fromJson(json))
              .toList();
        }
      }

      return result;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // CREATE BOOKING
  Future<ApiResponse<Booking>> createBooking({
    required int tradieId,
    required int serviceId,
    required DateTime bookingStart,
    required DateTime bookingEnd,
  }) async {
    try {
      final response = await _dio.post(
        '/bookings',
        data: {
          'tradie_id': tradieId,
          'service_id': serviceId,
          'booking_start': bookingStart.toIso8601String(),
          'booking_end': bookingEnd.toIso8601String(),
        },
      );

      final body = response.data;
      Booking? booking;

      if (body is Map<String, dynamic>) {
        booking = _extractBooking(body);
      }

      return ApiResponse(
        success: body['success'] ?? true,
        message: body['message'] ?? 'Booking created successfully',
        data: booking,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // UPDATE BOOKING
  Future<ApiResponse<Booking>> updateBooking({
    required int bookingId,
    required DateTime bookingStart,
    required DateTime bookingEnd,
  }) async {
    try {
      final response = await _dio.put(
        '/bookings/$bookingId',
        data: {
          'booking_start': bookingStart.toIso8601String(),
          'booking_end': bookingEnd.toIso8601String(),
        },
      );

      final body = response.data;
      Booking? booking;

      if (body is Map<String, dynamic>) {
        booking = _extractBooking(body);
      }

      return ApiResponse(
        success: body['success'] ?? true,
        message: body['message'] ?? 'Booking updated successfully',
        data: booking,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // CANCEL BOOKING
  Future<ApiResponse<Booking>> cancelBooking(int bookingId) async {
    try {
      final response = await _dio.post('/bookings/$bookingId/cancel');
      final body = response.data;

      Booking? booking;

      if (body is Map<String, dynamic>) {
        booking = _extractBooking(body);
      }

      return ApiResponse(
        success: body['success'] ?? true,
        message: body['message'] ?? 'Booking cancelled successfully',
        data: booking,
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // CANCEL REQUEST
  Future<ApiResponse<dynamic>> submitCancellationRequest(
      CancellationRequest request,
      ) async {
    try {
      final response = await _dio.post(
        '/bookings/${request.bookingId}/cancel-request',
        data: request.toJson(),
      );

      return ApiResponse(
        success: response.data['success'],
        message: response.data['message'],
        data: response.data['reference_number'],
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // Extract booking from ANY API format
  Booking _extractBooking(Map<String, dynamic> body) {
    if (body['booking'] is Map<String, dynamic>) {
      return Booking.fromJson(body['booking']);
    }
    if (body['data'] is Map<String, dynamic>) {
      return Booking.fromJson(body['data']);
    }
    return Booking.fromJson(body); // fallback
  }

  // Generalized Error Handler
  String _handleError(DioException error) {
    if (error.response?.statusCode == 401) {
      return 'Unauthenticated. Please log in again.';
    }

    final data = error.response?.data;

    if (data is Map<String, dynamic>) {
      if (data['errors'] is Map) {
        final first = (data['errors'] as Map).values.first;
        if (first is List && first.isNotEmpty) {
          return first.first.toString();
        }
      }

      return data['message']?.toString() ?? 'Unknown server error';
    }

    return error.message ?? 'Network error. Please check your connection.';
  }
}
