import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../core/network/dio_client.dart';

class BookingService {
  final Dio _dio = DioClient.instance.dio;

  /// Fetch bookings (upcoming and past) from backend
  /// First tries /bookings/history, then falls back to /urgent-bookings
  Future<Map<String, dynamic>> getBookingsHistory() async {
    try {
      debugPrint('📚 Fetching bookings history from /bookings/history');
      
      try {
        final resp = await _dio.get('/bookings/history');
        debugPrint('✅ /bookings/history response: ${resp.data.runtimeType}');
        final result = _parseBookingsResponse(resp.data);
        
        // Log first booking structure for debugging
        final upcoming = (result['upcoming'] as List?) ?? [];
        if (upcoming.isNotEmpty) {
          debugPrint('📍 First booking structure:');
          debugPrint('   Keys: ${(upcoming[0] as Map).keys}');
          debugPrint('   Full booking: ${upcoming[0]}');
        }
        
        return result;
      } catch (e1) {
        debugPrint('⚠️  /bookings/history failed, trying /urgent-bookings');
        try {
          final resp = await _dio.get('/urgent-bookings');
          debugPrint('✅ /urgent-bookings response: ${resp.data.runtimeType}');
          return _parseUrgentBookingsToHistory(resp.data);
        } catch (e2) {
          debugPrint('⚠️  /urgent-bookings also failed, returning empty');
          return {'upcoming': [], 'past': []};
        }
      }
    } catch (e) {
      debugPrint('❌ Error in getBookingsHistory: $e');
      rethrow;
    }
  }
  
  Map<String, dynamic> _parseBookingsResponse(dynamic data) {
    if (data is Map) {
      final map = data as Map<String, dynamic>;
      debugPrint('   Result keys: ${map.keys}');
      
      // Get bookings from response (could be 'upcoming' and 'past' or 'bookings')
      List<dynamic> allBookings = [];
      
      if (map['upcoming'] is List && map['past'] is List) {
        // Already separated by backend - combine and re-separate by payment status
        allBookings = [...(map['upcoming'] as List), ...(map['past'] as List)];
      } else if (map['bookings'] is List) {
        allBookings = map['bookings'] as List;
      }
      
      // Re-categorize bookings by payment status (not by date)
      // A booking is "upcoming" if payment status is 'pending' or has no payment
      // A booking is "past" (history) if payment status is 'completed' or 'paid'
      final upcoming = <dynamic>[];
      final past = <dynamic>[];
      
      for (var booking in allBookings) {
        if (booking is Map<String, dynamic>) {
          // Check booking status and payment fields
          final bookingStatus = booking['status']; // 'pending', 'completed', 'cancelled' etc
          final paymentId = booking['payment_id'];
          final paymentStatus = booking['payment_status'];
          
          // Check if booking has been paid
          final hasPayment = paymentId != null && paymentId.toString().isNotEmpty;
          final isPaid = paymentStatus == 'completed' || paymentStatus == 'paid';
          final isPending = bookingStatus == 'pending';
          
          debugPrint('   📝 Booking ${booking['id']}: status=$bookingStatus, payment_id=$paymentId, payment_status=$paymentStatus');
          
          if (isPending || (!hasPayment && !isPaid)) {
            // No payment yet or status is pending - goes to upcoming
            upcoming.add(booking);
            debugPrint('      → Added to UPCOMING');
          } else if (hasPayment || isPaid || bookingStatus == 'completed') {
            // Booking has been paid or is completed - goes to history
            past.add(booking);
            debugPrint('      → Added to PAST (has payment or completed)');
          } else {
            // Default: if not pending, assume it's past
            past.add(booking);
            debugPrint('      → Added to PAST (default)');
          }
        }
      }
      
      debugPrint('   Upcoming: ${upcoming.length}, Past: ${past.length}');
      return {'upcoming': upcoming, 'past': past};
    }
    debugPrint('⚠️  Response was not a Map: $data');
    return {'upcoming': [], 'past': []};
  }
  
  Map<String, dynamic> _parseUrgentBookingsToHistory(dynamic data) {
    List<dynamic> bookings = [];
    
    if (data is List) {
      bookings = data;
    } else if (data is Map && data['data'] is List) {
      bookings = data['data'];
    }
    
    // Separate by status or date
    final upcoming = <dynamic>[];
    final past = <dynamic>[];
    
    for (var booking in bookings) {
      if (booking is Map) {
        final status = booking['status'];
        if (status == 'completed' || status == 'cancelled') {
          past.add(booking);
        } else {
          upcoming.add(booking);
        }
      }
    }
    
    debugPrint('   Parsed urgent bookings: ${upcoming.length} upcoming, ${past.length} past');
    return {'upcoming': upcoming, 'past': past};
  }
}
