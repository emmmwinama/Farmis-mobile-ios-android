import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/sync_queue_item.dart';
import 'sync_queue_service.dart';

final syncQueueServiceProvider = Provider<SyncQueueService>(
  (_) => SyncQueueService(),
);

final syncQueueProvider =
    StateNotifierProvider<SyncQueueNotifier, AsyncValue<List<SyncQueueItem>>>(
  (ref) => SyncQueueNotifier(ref.read(syncQueueServiceProvider))..load(),
);

class SyncQueueNotifier extends StateNotifier<AsyncValue<List<SyncQueueItem>>> {
  final SyncQueueService _service;

  SyncQueueNotifier(this._service) : super(const AsyncValue.loading());

  Future<void> load() async {
    state = AsyncValue.data(await _service.load());
  }

  Future<void> enqueue({
    required String type,
    required String method,
    required String path,
    required Map<String, dynamic> payload,
  }) async {
    state = AsyncValue.data(await _service.enqueue(
      type: type,
      method: method,
      path: path,
      payload: payload,
    ));
  }

  Future<void> syncNow() async {
    state = const AsyncValue.loading();
    state = AsyncValue.data(await _service.syncNow());
  }

  Future<void> delete(String id) async {
    state = AsyncValue.data(await _service.delete(id));
  }
}
