import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/sync/auto_sync_service.dart';

/// Small cloud icon in the dashboard header showing background-sync status.
/// Hidden entirely for free/signed-out users — showing a sync icon they
/// can't use would just be confusing, and [AutoSyncState.status] never
/// leaves [SyncStatus.disabled] for them anyway.
class SyncStatusIcon extends ConsumerWidget {
  const SyncStatusIcon({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sync = ref.watch(autoSyncProvider);
    if (sync.status == SyncStatus.disabled) return const SizedBox.shrink();

    final icon = switch (sync.status) {
      SyncStatus.synced => Icons.cloud_done_outlined,
      SyncStatus.error => Icons.cloud_off_outlined,
      SyncStatus.idle || SyncStatus.disabled || SyncStatus.syncing => Icons.cloud_queue_outlined,
    };

    return IconButton(
      tooltip: describeSyncStatus(sync),
      icon: sync.status == SyncStatus.syncing
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
            )
          : Icon(icon, color: sync.status == SyncStatus.error ? Colors.orangeAccent : Colors.white),
      onPressed: sync.status == SyncStatus.error ? () => ref.read(autoSyncProvider.notifier).syncNow() : null,
    );
  }
}
