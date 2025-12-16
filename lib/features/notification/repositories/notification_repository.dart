import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<List<NotificationModel>> fetchNotifications() async {
    final res = await _dio.get(ApiConstants.notifications);

    final data = res.data['data'] as List;
    return data.map((e) => NotificationModel.fromJson(e)).toList();
  }

  Future<void> markAsRead(String id) async {
    await _dio.post(ApiConstants.markNotificationRead(id));
  }
}
