import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/notification_viewmodel.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/dashboard'),
        ),
      ),
      body: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (notifications) {
          if (notifications.isEmpty) {
            return const Center(child: Text('No notifications yet.'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: notifications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final n = notifications[index];

              return ListTile(
                tileColor: n.isRead ? Colors.white : Colors.blue.shade50,
                title: Text(
                  n.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(n.message),
                trailing: n.isRead
                    ? null
                    : const Icon(Icons.circle, color: Colors.blue, size: 12),
                onTap: () async {
                  await ref
                      .read(notificationViewModelProvider.notifier)
                      .markAsRead(n.id);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Notification marked as read'),
                      ),
                    );
                  }
                },
              );
            },
          );
        },
      ),
    );
  }
}
