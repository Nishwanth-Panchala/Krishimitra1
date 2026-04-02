import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/providers/app_providers.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _markAllReadOnce();
  }

  bool _markedOnce = false;

  Future<void> _markAllReadOnce() async {
    if (_markedOnce) return;
    _markedOnce = true;

    final service = ref.read(notificationServiceProvider);
    final notifications = await service.loadAll();
    final readIds = await service.loadReadIds();

    final allIds = notifications.map((e) => e.id).toSet();
    final toMark = allIds.difference(readIds);
    if (toMark.isEmpty) return;

    await service.markAsRead(toMark);
    // Refresh list if needed (we don't display unread count, but we might in future).
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final notificationsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: notificationsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, _) => Center(child: Text('Failed to load: $err')),
          data: (notifications) {
            if (notifications.isEmpty) {
              return const Center(child: Text('No notifications yet.'));
            }

            return ListView.separated(
              itemCount: notifications.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final n = notifications[index];
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          n.message,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          n.createdAt.toLocal().toString().split(".").first,
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

