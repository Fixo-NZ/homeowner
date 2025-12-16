import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';

final notificationRepositoryProvider = Provider<NotificationRepository>((ref) {
  return NotificationRepository();
});

final notificationViewModelProvider =
    StateNotifierProvider<
      NotificationViewModel,
      AsyncValue<List<NotificationModel>>
    >((ref) {
      final repo = ref.read(notificationRepositoryProvider);
      return NotificationViewModel(repo);
    });

class NotificationViewModel
    extends StateNotifier<AsyncValue<List<NotificationModel>>> {
  final NotificationRepository _repository;

  NotificationViewModel(this._repository) : super(const AsyncValue.loading()) {
    loadNotifications();
  }

  Future<void> loadNotifications() async {
    state = const AsyncValue.loading();
    try {
      final notifications = await _repository.fetchNotifications();
      state = AsyncValue.data(notifications);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _repository.markAsRead(id);
      // Refresh list
      await loadNotifications();
    } catch (e, st) {
      // Handle error
    }
  }
}
