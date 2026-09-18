import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/api_client.dart';
import '../db/database_provider.dart';
import 'sync_service.dart';

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

/// Watches every local write (`db.tableUpdates()`, fires regardless of
/// which repository made it) and, after a short debounce, flushes the
/// offline batch queue and pulls in whatever changed elsewhere — see
/// `SyncService` and docs/MOBILE-API.md §8. Runs for every signed-in
/// account, not gated on plan/tier: unlike the old Node backend, where
/// cloud sync was a paid-only backup of otherwise-local data, Ulimi's
/// mobile API is the actual source of truth for every farm, and reaching
/// any screen that can trigger this already implies a signed-in session
/// (the router redirects to /login otherwise — see account_provider.dart).
class AutoSyncNotifier extends StateNotifier<AutoSyncState> {
  AutoSyncNotifier(this._ref) : super(const AutoSyncState.initial()) {
    _subscription = _ref.read(databaseProvider).tableUpdates().listen((_) => _scheduleSync());
  }

  final Ref _ref;
  StreamSubscription<void>? _subscription;
  Timer? _debounce;

  static const _debounceDelay = Duration(seconds: 8);

  void _scheduleSync() {
    _debounce?.cancel();
    _debounce = Timer(_debounceDelay, syncNow);
  }

  Future<void> syncNow() async {
    state = state.copyWith(status: SyncStatus.syncing);
    try {
      final service = SyncService(_ref.read(databaseProvider), _ref.read(apiClientProvider));
      await service.pushQueued();
      await service.pullChanges();
      state = state.copyWith(status: SyncStatus.synced, lastSyncedAt: DateTime.now(), errorMessage: null);
    } catch (e) {
      state = state.copyWith(status: SyncStatus.error, errorMessage: e.toString());
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}

final autoSyncProvider = StateNotifierProvider<AutoSyncNotifier, AutoSyncState>(
  (ref) => AutoSyncNotifier(ref),
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
