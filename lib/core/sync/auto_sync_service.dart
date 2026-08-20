import 'dart:async';

import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/account_provider.dart';
import '../db/database_provider.dart';
import '../migration/export_service.dart';

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

/// Watches this device's local database for writes and pushes a fresh whole-
/// farm backup to the cloud a few seconds after the last one, for as long as
/// the signed-in account is on a paid (syncEnabled) plan — no manual "back up
/// now" tap needed. Free/signed-out users never trigger this (status stays
/// [SyncStatus.disabled]).
///
/// There's no per-row dirty tracking; every sync re-exports the whole local
/// database, same as the manual backup button in AccountSyncSection. That's
/// fine at farm-record scale and keeps this from needing to touch every
/// individual repository's create/update/delete methods — it hooks in once,
/// at the database layer, via drift's tableUpdates() stream.
class AutoSyncNotifier extends StateNotifier<AutoSyncState> {
  final Ref _ref;
  StreamSubscription<Set<TableUpdate>>? _dbSubscription;
  Timer? _debounce;
  bool _syncing = false;

  static const _debounceDelay = Duration(seconds: 8);

  AutoSyncNotifier(this._ref) : super(const AutoSyncState.initial()) {
    _ref.listen<AccountState>(accountProvider, (_, next) => _onAccountChanged(next), fireImmediately: true);
  }

  void _onAccountChanged(AccountState account) {
    final eligible = account.account?.subscription?.isPaid ?? false;
    if (eligible && _dbSubscription == null) {
      _startWatching();
    } else if (!eligible && _dbSubscription != null) {
      _stopWatching();
    }
  }

  void _startWatching() {
    state = state.copyWith(status: SyncStatus.idle);
    final db = _ref.read(databaseProvider);
    _dbSubscription = db.tableUpdates().listen((_) => _scheduleSync());
    // A courtesy sync as soon as sync becomes available — covers data
    // entered before the account existed or before upgrading.
    _scheduleSync();
  }

  void _stopWatching() {
    _dbSubscription?.cancel();
    _dbSubscription = null;
    _debounce?.cancel();
    _debounce = null;
    state = const AutoSyncState.initial();
  }

  void _scheduleSync() {
    _debounce?.cancel();
    _debounce = Timer(_debounceDelay, syncNow);
  }

  /// Runs a sync immediately (skipping the debounce) — used for the courtesy
  /// sync and available for a manual "retry" tap on the status icon.
  Future<void> syncNow() async {
    if (_syncing || _dbSubscription == null) return;
    _syncing = true;
    state = state.copyWith(status: SyncStatus.syncing);
    try {
      final db = _ref.read(databaseProvider);
      final json = await ExportService(db).exportToJson();
      await _ref.read(accountRepositoryProvider).backup(json);
      state = AutoSyncState(status: SyncStatus.synced, lastSyncedAt: DateTime.now());
    } catch (e) {
      state = state.copyWith(status: SyncStatus.error, errorMessage: e.toString());
    } finally {
      _syncing = false;
    }
  }

  @override
  void dispose() {
    _dbSubscription?.cancel();
    _debounce?.cancel();
    super.dispose();
  }
}

final autoSyncProvider = StateNotifierProvider<AutoSyncNotifier, AutoSyncState>(
  (ref) => AutoSyncNotifier(ref),
);

/// Shared status copy for the dashboard's [SyncStatusIcon] and the Profile
/// screen's Account & Sync card, so the two surfaces never disagree.
String describeSyncStatus(AutoSyncState state) {
  switch (state.status) {
    case SyncStatus.disabled:
      return 'Sync not available on your plan';
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
