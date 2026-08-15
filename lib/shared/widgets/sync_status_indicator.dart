import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/sync/sync_queue_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/sync_queue_item.dart';

class SyncStatusIndicator extends ConsumerWidget {
  final bool compact;

  const SyncStatusIndicator({super.key, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queue = ref.watch(syncQueueProvider);

    return queue.when(
      loading: () => const _Pill(
        icon: Icons.sync_rounded,
        label: 'Syncing',
        color: FarmioColors.info,
      ),
      error: (_, __) => const _Pill(
        icon: Icons.cloud_off_outlined,
        label: 'Sync unavailable',
        color: FarmioColors.danger,
      ),
      data: (items) {
        final pending = items
            .where((item) =>
                item.status == SyncQueueStatus.queued ||
                item.status == SyncQueueStatus.failed)
            .length;
        final failed =
            items.where((item) => item.status == SyncQueueStatus.failed).length;
        final label = pending == 0
            ? (compact ? 'Synced' : 'All records synced')
            : failed > 0
                ? '$failed failed'
                : '$pending queued';
        final color = failed > 0
            ? FarmioColors.danger
            : pending > 0
                ? FarmioColors.warning
                : FarmioColors.success;

        return InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: () => ref.read(syncQueueProvider.notifier).syncNow(),
          child: _Pill(
            icon: pending == 0
                ? Icons.cloud_done_outlined
                : Icons.cloud_sync_outlined,
            label: label,
            color: color,
          ),
        );
      },
    );
  }
}

class _Pill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _Pill({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 32),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
