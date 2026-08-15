import 'package:farmio_mobile/core/sync/sync_queue_service.dart';
import 'package:farmio_mobile/models/sync_queue_item.dart';

/// In-memory stand-in for [SyncQueueService] so tests don't need real
/// secure-storage platform channels.
class FakeSyncQueueService extends SyncQueueService {
  final List<SyncQueueItem> items = [];

  @override
  Future<List<SyncQueueItem>> load() async => List.unmodifiable(items);

  @override
  Future<void> save(List<SyncQueueItem> next) async {
    items
      ..clear()
      ..addAll(next);
  }

  @override
  Future<List<SyncQueueItem>> enqueue({
    required String type,
    required String method,
    required String path,
    required Map<String, dynamic> payload,
  }) async {
    final item = SyncQueueItem(
      id: 'test-${items.length}',
      clientId: 'test-${items.length}',
      type: type,
      method: method,
      path: path,
      payload: payload,
      status: SyncQueueStatus.queued,
      createdAt: DateTime(2024, 1, 1),
    );
    items.add(item);
    return List.unmodifiable(items);
  }
}
