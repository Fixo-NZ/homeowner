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
    return Booking(
      id: json['id'],
      homeownerId: json['homeowner_id'],
      tradieId: json['tradie_id'],
      serviceId: json['service_id'],
      bookingStart: DateTime.parse(json['booking_start']),
      bookingEnd: DateTime.parse(json['booking_end']),
      status: json['status'],
      tradie: json['tradie'] != null ? Tradie.fromJson(json['tradie']) : null,
      service: json['service'] != null
          ? Service.fromJson(json['service'])
          : null,
      bookingNumber:
          json['booking_number'] ??
          '#BK-${json['id'].toString().padLeft(4, '0')}',
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
