import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_theme.dart';
import '../../models/app_notification.dart';
import 'notifications_provider.dart';
import '../../core/theme/app_spacing.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: context.colors.background,
      appBar: AppBar(
        title: const Text('Notifications',
            style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [
          IconButton(
            tooltip: 'Mark all read',
            icon: const Icon(Icons.done_all_rounded),
            onPressed: () async {
              await ref.read(notificationsRepositoryProvider).markAllRead();
              ref.invalidate(notificationsProvider);
            },
          ),
        ],
      ),
      body: notifications.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _ErrorState(
          message: error.toString(),
          onRetry: () => ref.invalidate(notificationsProvider),
        ),
        data: (data) {
          if (data.notifications.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xxl),
                child: Text(
                  'No notifications yet.',
                  style: TextStyle(color: context.colors.textMuted),
                ),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(notificationsProvider),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(AppSpacing.xl, AppSpacing.lg, AppSpacing.xl, 40),
              itemCount: data.notifications.length,
              itemBuilder: (context, index) {
                final item = data.notifications[index];
                return Dismissible(
                  key: ValueKey(item.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                    alignment: Alignment.centerRight,
                    decoration: BoxDecoration(
                      color: FarmioColors.danger,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.close, color: Colors.white),
                  ),
                  onDismissed: (_) async {
                    await ref.read(notificationsRepositoryProvider).dismissNotification(item.id);
                    ref.invalidate(notificationsProvider);
                  },
                  child: _NotificationTile(
                    item: item,
                    onTap: () async {
                      if (!item.isRead) {
                        await ref.read(notificationsRepositoryProvider).markRead(item.id);
                        ref.invalidate(notificationsProvider);
                      }
                      if (item.link != null && context.mounted) context.push(item.link!);
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotification item;
  final VoidCallback onTap;
  const _NotificationTile({required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: item.isRead ? colors.surface : FarmioColors.infoBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: item.isRead ? colors.border : FarmioColors.info,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: item.link != null ? onTap : null,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  item.isRead
                      ? Icons.notifications_none_rounded
                      : Icons.notifications_active_rounded,
                  color: item.isRead ? colors.textMuted : FarmioColors.info,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.title,
                          style: TextStyle(
                              fontWeight: FontWeight.w800,
                              color: colors.textPrimary)),
                      const SizedBox(height: 2),
                      Text(item.message,
                          style: TextStyle(fontSize: 13, color: colors.textSecond)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Could not load notifications',
                style: TextStyle(
                    color: context.colors.textPrimary,
                    fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(message,
                textAlign: TextAlign.center,
                style: TextStyle(color: context.colors.textMuted)),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
