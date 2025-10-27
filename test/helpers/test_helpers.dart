// Common test helpers for unit/widget tests
import 'package:tradie/features/urgentBooking/test_urgent_booking/fixtures.dart'
    as fixtures;
import 'package:tradie/features/urgentBooking/models/service_model.dart';
import 'package:tradie/features/urgentBooking/models/tradie_recommendation.dart';

T identity<T>(T value) => value;

// Re-export fixtures helpers for convenience
ServiceModel buildService({int id = 1, String status = 'Pending'}) =>
    fixtures.buildService(id: id, status: status);
TradieRecommendation buildTradie({int id = 1, String name = 'John'}) =>
    fixtures.buildTradie(id: id, name: name);
