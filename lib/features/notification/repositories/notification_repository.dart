import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/constants/api_constants.dart';
import '../models/notification_model.dart';

class NotificationRepository {
  final Dio _dio = DioClient.instance.dio;

  Future<List<NotificationModel>> fetchNotifications({
    bool unreadOnly = false,
  }) async {
    final res = await _dio.get(
      ApiConstants.notifications,
      queryParameters: unreadOnly ? {'unread': 'true'} : null,
    );

    final data = res.data['data'] as List;

    return data.map((e) {
      // Laravel database notifications return the payload in a nested `data` field.
      final payload = (e['data'] is Map)
          ? e['data'] as Map<String, dynamic>
          : <String, dynamic>{};

      final mapped = <String, dynamic>{
        'id': e['id'].toString(),
        'type': e['type'] ?? payload['type'] ?? '',
        'title': payload['title'] ?? e['title'] ?? '',
        'message': payload['message'] ?? e['message'] ?? '',
        'isRead': e['isRead'] ?? (e['read_at'] != null),
        // Use created_at from backend (Laravel uses snake_case)
        'createdAt': e['created_at'] ?? e['createdAt'],
      };

      return NotificationModel.fromJson(mapped);
    }).toList();
  }

  Future<void> markAsRead(String id) async {
    // Backend expects a PATCH request for marking notification as read.
    await _dio.patch(ApiConstants.markNotificationRead(id));
  }
}
