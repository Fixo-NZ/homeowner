import 'package:dio/dio.dart';
import 'package:tradie/core/constants/api_constants.dart';
import 'package:tradie/core/network/api_response.dart';

import '../models/booking_model.dart';
import '../models/cancellation_request.dart';

class BookingRepository {
  final Dio _dio;

  BookingRepository(this._dio) {
    _dio.options.baseUrl = ApiConstants.baseUrl; // Correct base URL
    _dio.options.headers = {
      'Content-Type': ApiConstants.contentType,
      'Accept': ApiConstants.accept,
    };
  }

  void setAuthToken(String token) {
    _dio.options.headers[ApiConstants.authorization] =
        '${ApiConstants.bearer} $token';
  }

  Future<List<Booking>> getBookings() async {
    try {
      final response = await _dio.get('/bookings'); // FIXED
      final List data = response.data;
      return data.map((json) => Booking.fromJson(json)).toList();
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

      return ApiResponse(
        success: response.data['success'] ?? true,
        message: response.data['message'],
        data: Booking.fromJson(response.data['booking']),
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

      return ApiResponse(
        success: response.data['success'],
        message: response.data['message'],
        data: Booking.fromJson(response.data['booking']),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<ApiResponse<Booking>> cancelBooking(int bookingId) async {
    try {
      final response = await _dio.post('/bookings/$bookingId/cancel'); // FIXED

      return ApiResponse(
        success: response.data['success'],
        message: response.data['message'],
        data: Booking.fromJson(response.data['booking']),
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
