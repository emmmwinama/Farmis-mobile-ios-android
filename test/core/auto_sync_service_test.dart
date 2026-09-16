import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/core/sync/auto_sync_service.dart';

void main() {
  test('stays disabled and syncNow is a no-op pending the per-entity API port', () async {
    final notifier = AutoSyncNotifier();
    expect(notifier.state.status, SyncStatus.disabled);

    await notifier.syncNow();

    expect(notifier.state.status, SyncStatus.disabled);
  });
}
