import 'package:tradie/features/booking_create_update_cancel/models/service_model.dart';
import 'package:tradie/features/booking_create_update_cancel/models/tradie_model.dart';

class Booking {
  final int id;
  final int homeownerId;
  final int tradieId;
  final int serviceId;
  final DateTime bookingStart;
  final DateTime bookingEnd;
  final String status;
  final Tradie? tradie;
  final Service? service;
  final String bookingNumber;

  Booking({
    required this.id,
    required this.homeownerId,
    required this.tradieId,
    required this.serviceId,
    required this.bookingStart,
    required this.bookingEnd,
    required this.status,
    this.tradie,
    this.service,
    required this.bookingNumber,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    // Handle different response structures
    final bookingData = json['booking'] ?? json['data'] ?? json;
    
    return Booking(
      id: bookingData['id'] is int
          ? bookingData['id'] as int
          : (int.tryParse('${bookingData['id']}') ?? 0),
      homeownerId: bookingData['homeowner_id'] is int
          ? bookingData['homeowner_id'] as int
          : (int.tryParse('${bookingData['homeowner_id']}') ?? 0),
      tradieId: bookingData['tradie_id'] is int
          ? bookingData['tradie_id'] as int
          : (int.tryParse('${bookingData['tradie_id']}') ?? 0),
      serviceId: bookingData['service_id'] is int
          ? bookingData['service_id'] as int
          : (int.tryParse('${bookingData['service_id']}') ?? 0),
      bookingStart: DateTime.tryParse(bookingData['booking_start'].toString()) ??
          DateTime.now(),
      bookingEnd: DateTime.tryParse(bookingData['booking_end'].toString()) ??
          DateTime.now(),
      status: bookingData['status']?.toString() ?? 'pending',
      tradie: bookingData['tradie'] != null 
          ? Tradie.fromJson(bookingData['tradie'] is Map 
              ? bookingData['tradie'] 
              : {}) 
          : null,
      service: bookingData['service'] != null
          ? Service.fromJson(bookingData['service'] is Map
              ? bookingData['service']
              : {})
          : null,
      bookingNumber: bookingData['booking_number'] ??
          '#BK-${bookingData['id'].toString().padLeft(4, '0')}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'homeowner_id': homeownerId,
      'tradie_id': tradieId,
      'service_id': serviceId,
      'booking_start': bookingStart.toIso8601String(),
      'booking_end': bookingEnd.toIso8601String(),
      'status': status,
    };
  }
}
