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

  Future<List<Booking>> getBookings() async {
    try {
      final response = await _dio.get('/bookings');
      final body = response.data;
      
      List data = [];
      if (body is List) {
        data = body;
      } else if (body is Map<String, dynamic>) {
        // Laravel returns: { data: [...] } or { bookings: [...] }
        if (body['data'] is List) {
          data = List.from(body['data']);
        } else if (body['bookings'] is List) {
          data = List.from(body['bookings']);
        }
      }
      
      return data.map((json) => Booking.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

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
              .map((json) => Booking.fromJson(json as Map<String, dynamic>))
              .toList();
        }
        if (body['past'] is List) {
          result['past'] = (body['past'] as List)
              .map((json) => Booking.fromJson(json as Map<String, dynamic>))
              .toList();
        }
      }
      
      return result;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<Booking>> createBooking({
    required int tradieId,
    required int serviceId,
    required DateTime bookingStart,
    required DateTime bookingEnd,
  }) async {
    try {
      final response = await _dio.post(
        '/bookings', // FIXED
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
        if (body['booking'] is Map<String, dynamic>) {
          booking = Booking.fromJson(body['booking'] as Map<String, dynamic>);
        } else if (body['data'] is Map<String, dynamic>) {
          booking = Booking.fromJson(body['data'] as Map<String, dynamic>);
        } else {
          // Try parsing the whole response as booking
          booking = Booking.fromJson(body);
        }
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

  Future<ApiResponse<Booking>> updateBooking({
    required int bookingId,
    required DateTime bookingStart,
    required DateTime bookingEnd,
  }) async {
    try {
      final response = await _dio.put(
        '/bookings/$bookingId', // FIXED
        data: {
          'booking_start': bookingStart.toIso8601String(),
          'booking_end': bookingEnd.toIso8601String(),
        },
      );

      final body = response.data;
      Booking? booking;
      
      if (body is Map<String, dynamic>) {
        if (body['booking'] is Map<String, dynamic>) {
          booking = Booking.fromJson(body['booking'] as Map<String, dynamic>);
        } else if (body['data'] is Map<String, dynamic>) {
          booking = Booking.fromJson(body['data'] as Map<String, dynamic>);
        } else {
          booking = Booking.fromJson(body);
        }
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

  Future<ApiResponse<Booking>> cancelBooking(int bookingId) async {
    try {
      final response = await _dio.post('/bookings/$bookingId/cancel'); // FIXED

      final body = response.data;
      Booking? booking;
      
      if (body is Map<String, dynamic>) {
        if (body['booking'] is Map<String, dynamic>) {
          booking = Booking.fromJson(body['booking'] as Map<String, dynamic>);
        } else if (body['data'] is Map<String, dynamic>) {
          booking = Booking.fromJson(body['data'] as Map<String, dynamic>);
        } else {
          booking = Booking.fromJson(body);
        }
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

  String _handleError(DioException error) {
    if (error.response != null &&
        error.response!.data is Map<String, dynamic>) {
      return error.response!.data['message'] ?? 'Unknown server error';
    }
    return error.message ?? 'Network error';
  }
}
