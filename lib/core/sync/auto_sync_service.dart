import 'package:flutter_riverpod/flutter_riverpod.dart';

enum SyncStatus { disabled, idle, syncing, synced, error }

class AutoSyncState {
  final SyncStatus status;
  final DateTime? lastSyncedAt;
  final String? errorMessage;

  const AutoSyncState({required this.status, this.lastSyncedAt, this.errorMessage});
  const AutoSyncState.initial() : status = SyncStatus.disabled, lastSyncedAt = null, errorMessage = null;

  AutoSyncState copyWith({SyncStatus? status, DateTime? lastSyncedAt, String? errorMessage}) => AutoSyncState(
        status: status ?? this.status,
        lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
        errorMessage: errorMessage,
      );
}

/// Placeholder pending the per-entity API port: the old whole-farm backup
/// blob this used to push (`/api/mobile/backup`) doesn't exist on the real
/// backend — every screen now reads/writes Ulimi's mobile API directly
/// per-entity instead, which makes an explicit "sync" step largely moot for
/// the entities that are already ported. This stays wired up (rather than
/// deleted) as the home for a real offline-queue flush via
/// `POST /api/mobile/sync` once the entities that still write local-only
/// (offline captures) are identified.
class AutoSyncNotifier extends StateNotifier<AutoSyncState> {
  AutoSyncNotifier() : super(const AutoSyncState.initial());

  Future<void> syncNow() async {}
}

final autoSyncProvider = StateNotifierProvider<AutoSyncNotifier, AutoSyncState>(
  (ref) => AutoSyncNotifier(),
);

String describeSyncStatus(AutoSyncState state) {
  switch (state.status) {
    case SyncStatus.disabled:
      return 'Synced automatically when online';
    case SyncStatus.idle:
      return 'Waiting to sync';
    case SyncStatus.syncing:
      return 'Syncing to the cloud…';
    case SyncStatus.error:
      return 'Sync failed — tap to retry';
    case SyncStatus.synced:
      final at = state.lastSyncedAt;
      if (at == null) return 'Synced';
      final delta = DateTime.now().difference(at);
      if (delta.inMinutes < 1) return 'Synced just now';
      if (delta.inMinutes < 60) return 'Synced ${delta.inMinutes}m ago';
      if (delta.inHours < 24) return 'Synced ${delta.inHours}h ago';
      return 'Synced ${delta.inDays}d ago';
  }
}
