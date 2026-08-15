import 'package:flutter_test/flutter_test.dart';
import 'package:farmio_mobile/models/sync_queue_item.dart';

void main() {
  test('round-trips through toJson/fromJson', () {
    final item = SyncQueueItem(
      id: '1',
      clientId: 'finance_123',
      type: 'finance',
      method: 'POST',
      path: '/mobile/finance',
      payload: const {'amount': '100', 'clientId': 'finance_123'},
      status: SyncQueueStatus.failed,
      error: 'timed out',
      createdAt: DateTime(2024, 1, 1, 12),
      syncedAt: DateTime(2024, 1, 2, 8),
    );

    final restored = SyncQueueItem.fromJson(item.toJson());

    expect(restored.id, item.id);
    expect(restored.clientId, item.clientId);
    expect(restored.type, item.type);
    expect(restored.method, item.method);
    expect(restored.path, item.path);
    expect(restored.payload, item.payload);
    expect(restored.status, item.status);
    expect(restored.error, item.error);
    expect(restored.createdAt, item.createdAt);
    expect(restored.syncedAt, item.syncedAt);
  });

  test('defaults to queued status when the stored value is unrecognized', () {
    final json = {
      'id': '1',
      'clientId': 'c1',
      'type': 'finance',
      'method': 'POST',
      'path': '/mobile/finance',
      'payload': <String, dynamic>{},
      'status': 'not_a_real_status',
      'error': null,
      'createdAt': DateTime(2024, 1, 1).toIso8601String(),
      'syncedAt': null,
    };

    expect(SyncQueueItem.fromJson(json).status, SyncQueueStatus.queued);
  });

  test('encodeList/decodeList round-trips a full queue', () {
    final items = [
      SyncQueueItem(
        id: '1',
        clientId: 'c1',
        type: 'finance',
        method: 'POST',
        path: '/mobile/finance',
        payload: const {'amount': '10'},
        status: SyncQueueStatus.queued,
        createdAt: DateTime(2024, 1, 1),
      ),
      SyncQueueItem(
        id: '2',
        clientId: 'c2',
        type: 'activity',
        method: 'POST',
        path: '/mobile/activities',
        payload: const {'note': 'sprayed'},
        status: SyncQueueStatus.synced,
        createdAt: DateTime(2024, 1, 2),
        syncedAt: DateTime(2024, 1, 3),
      ),
    ];

    final decoded = SyncQueueItem.decodeList(SyncQueueItem.encodeList(items));

    expect(decoded, hasLength(2));
    expect(decoded[0].id, '1');
    expect(decoded[1].status, SyncQueueStatus.synced);
  });

  test('decodeList treats null/empty input as an empty queue', () {
    expect(SyncQueueItem.decodeList(null), isEmpty);
    expect(SyncQueueItem.decodeList(''), isEmpty);
  });
}
